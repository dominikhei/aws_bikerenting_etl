import pandas as pd
from datetime import datetime
from datetime import timedelta
from datetime import time
import boto3
from botocore.client import Config
from io import StringIO
import redshift_connector
from aws_secrets import *

###################################################
# AWS-Credentials and names:
###################################################

#AWS Credentials are imported from the secrets file


###################################################
# Get data on bike renting and do first transforms
###################################################

def transform_data():

    rows_changed = 0
    rows_dropped = 0

    data = pd.read_csv("/app/NYC-BikeShare-2015-2017-combined.csv")

    start_hour = data["Start Time"].str.slice(11,19)
    start_date = data["Start Time"].str.slice(0,10)
    stop_hour = data["Stop Time"].str.slice(11,19)
    stop_date = data["Stop Time"].str.slice(0,10)

    data.insert(4, "Start Hour", start_hour)
    data.insert(3, "Start Date", start_date)
    data.insert(6, "Stop Hour", stop_hour)
    data.insert(5, "Stop Date", stop_date)

    data = data.astype({'Birth Year' : 'int'})
    data.drop(data.columns[[1, 2, 4,]], axis=1, inplace=True)

    data = data.rename(columns={data.columns[0]: "id"})
    data['id'] +=1

    for i in range(0,len(data)):
        if len(str(data['Start Date'][i])) != 10:
            if len(str(data['Stop Date'][i])) == 10 and data['Trip_Duration_in_min'][i] >=0:
                if data['Trip_Duration_in_min'][i] < 1440:
                    data['Start Date'][i]=data['Stop Date'][i]
                    rows_changed += 1
                else:
                    days = data['Trip_Duration_in_min'][i]/1440
                    date = datetime.strptime(data['Stop Date'][i], '%Y-%m-%d') - timedelta(days=int(days))
                    data.loc[[i], ['Start Date']]=date.date()
                    rows_changed += 1


    for i in range(0,len(data)):
        if len(str(data['Stop Date'][i])) != 10:
            if len(str(data['Start Date'][i])) == 10 and data['Trip_Duration_in_min'][i] >=0:
                if data['Trip_Duration_in_min'][i] < 1440:
                    data['Stop Date'][i]=data['Start Date'][i]
                    rows_changed += 1
                else:
                    days = data['Trip_Duration_in_min'][i]/1440
                    date = datetime.strptime(data['Start Date'][i], '%Y-%m-%d') + timedelta(days=int(days))
                    data.loc[[i], ['Stop Date']]=date.date()
                    rows_changed += 1



    for i in range(0,len(data)):
        if len(str(data['Start Hour'][i])) != 8:
            if len(str(data['Stop Hour'][i]))== 8 and data['Trip_Duration_in_min'][i]>=0:
                start_hour = datetime.strptime(str(data['Stop Hour'][i]),"%H:%M:%S") - timedelta(minutes=int(data['Trip_Duration_in_min'][i]))
                data.loc[[i], ['Start Hour']] = start_hour.time()
                rows_changed += 1
            elif len(str(data['Stop Hour'][i])) != 8 and data['Trip_Duration_in_min'][i]>=0:
                data.loc[[i], ['Start Hour']] = time(12,0,0)
                stop_hour = datetime.strptime(str(data['Start Hour'][i]),"%H:%M:%S")+ timedelta(minutes=int(data['Trip_Duration_in_min'][i]))
                data.loc[[i], ['Stop Hour']] = stop_hour.time()
                rows_changed += 1
            else:
                data.drop([i], axis=0, inplace=True)
                rows_dropped += 1

    for i in range(0,len(data)):
        if len(str(data['Stop Hour'][i])) != 8:
            if len(str(data['Start Hour'][i]))== 8 and data['Trip_Duration_in_min'][i]>=0:
                stop_hour = datetime.strptime(str(data['Start Hour'][i]),"%H:%M:%S") + timedelta(minutes=int(data['Trip_Duration_in_min'][i]))
                data.loc[[i], ['Stop Hour']] = stop_hour.time()
                rows_changed += 1
            else:
                data.drop([i], axis=0, inplace=True)
                rows_dropped += 1


    for i in range(0,len(data)):
        if data['Trip_Duration_in_min'][i] ==0:
            if data['Start Station'][i] != data['Stop Station'][i]:
                data.drop([i], axis=0, inplace=True)
                rows_dropped += 1


    for i in range(0,len(data)):
        if data['User Type'][i] not in ('Customer', 'Subscriber'):
            data.drop([i], axis=0, inplace=True)
            rows_dropped += 1


    print(rows_changed, "had to be changed and", rows_dropped, "had to be dropped.")
    data.drop(data.columns[[0]], axis=1, inplace=True)

    data.columns = [ 'StartDate', 'StopDate', 'StartHour', 'StopHour',
    'StartStationID', 'StartStationName', 'StartStationLatitude',
    'StartStationLongitude', 'EndStationID', 'EndStationName', 'EndStationLatitude',
    'EndStationLongitude','BikeID', 'UserType', 'BirthYear', 'Gender', 'Duration']

    return data

###################################################
# upload the CSV-files to the S3 bucket:
###################################################


def upload_rental_data_to_s3():
    session = boto3.Session(
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key
    )

    s3_res = session.resource('s3')
    data = transform_data()
    csv_buffer =  StringIO()
    data.to_csv(csv_buffer)

    try:
        s3_res.Object(bucket_name, s3_object_name).put(Body=csv_buffer.getvalue())
        print("Bikerental Dataframe is saved as CSV in S3 bucket")
    except Exception as e:
        print(f"Could not upload CSV to S3 bucket, due to exception {e}")


def create_bucket_if_not_exists():
    session = boto3.Session(
    aws_access_key_id=access_key_id,
    aws_secret_access_key=secret_access_key
    )
    s3 = session.resource('s3')
    bucket = s3.Bucket(bucket_name)

    if bucket.creation_date:
        print(f"Bucket {bucket_name} already exists, proceeding further")
    else:
        print(f"The bucket {bucket_name} does not exist")
        s3.create_bucket(bucket_name)
        print(f"Created the bucket {bucket_name}")


def upload():

    create_bucket_if_not_exists()
    upload_rental_data_to_s3()


###################################################
# Copy data from S3 in redshift stage-tables:
###################################################


def load_data_in_redshift():


    conn = redshift_connector.connect(host=aws_host,
                                  database='bikerenting',
                                  port=5439,
                                  user=aws_rs_user,
                                  password=aws_rs_pw)
    conn.autocommit = True


    cursor = conn.cursor()

    try:
        cursor.execute("""create table IF NOT EXISTS public.trip_stage_table(
                                            id int,
                                            StartDate varchar,
                                            StopDate varchar,
                                            StartHour varchar,
                                            StopHour varchar,
                                            StartStationID int,
                                            StartStationName varchar,
                                            StartStationLatitude varchar,
                                            StartStationLongitude varchar,
                                            EndStationID int,
                                            EndStationName varchar,
                                            EndStationLatitude varchar,
                                            EndStationLongitude varchar,
                                            BikeID int,
                                            UserType varchar,
                                            BirthYear int,
                                            Gender int,
                                            Duration int); """)
        print("Created the trip_stage_table and commited")
    except Exception as e:
        print(f"Could not create the table, due to error {e}")

    try:
        cursor.execute("TRUNCATE TABLE public.trip_stage_table;")
        print("Truncated the temp table")
        cursor.execute("copy public.trip_stage_table from 's3://bikerenting/bikerenting_2015' iam_role 'arn:aws:iam::903466892742:role/bikesharing_project_redshift' IGNOREHEADER 1 csv;")
        print("Inserted data into the stage table")
    except Exception as e:
        print(f"Could not insert into the table, due to error {e}")

#################################################################
# Truncate tables:
#################################################################

def truncate_dbt_stage():
    try:
        conn = redshift_connector.connect(host=aws_host,
                                database='bikerenting',
                                port=5439,
                                user=aws_rs_user,
                                password=aws_rs_pw)
        print("Connected to Redshift")
    except Exception as e:
        print(f"Could not connect to Redshift, due to error {e}")

    conn.autocommit = True

    cursor = conn.cursor()

    try:
        cursor.execute("TRUNCATE TABLE dbt_dbikerenting.trips_stg;")
        print("Truncated the dbt stage table")
    except Exception as e:
        print(f"Could not truncate the table, due to error {e}")


upload()
load_data_in_redshift()
truncate_dbt_stage()
