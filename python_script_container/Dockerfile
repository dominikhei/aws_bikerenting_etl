FROM python:3

COPY /NYC-BikeShare-2015-2017-combined.csv /app/NYC-BikeShare-2015-2017-combined.csv

ADD load_script.py /

ADD aws_secrets.py /

RUN pip install pandas datetime boto3 botocore redshift_connector

CMD ["python", "./load_script.py"]
