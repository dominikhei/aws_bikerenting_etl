from airflow import DAG
from datetime import datetime
from datetime import timedelta
from airflow.operators.docker_operator import DockerOperator
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2022,9,27),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=1)
}

dag = DAG(
    'aws_bikerenting_loading',
    default_args=default_args,
    description='',
    schedule_interval=timedelta(days=30),
)

load = DockerOperator(
    task_id='run_loading_container',
    image='aws_bike_loading',
    api_version='auto',
    auto_remove=True,
    docker_url="unix://var/run/docker.sock",
    network_mode="bridge",
    dag=dag
)

wait = BashOperator(
     task_id='wait_one_minute',
     bash_command='sleep 1m'
)

dwh_transformations = DockerOperator(
                    task_id='dwh_transformations',
                    image='bf0b42316889',
                    api_version='auto',
                    command='cd .dbt/bikerenting_model && dbt deps && dbt test && dbt run'
                    auto_remove=True,
                    docker_url="unix://var/run/docker.sock",
                    network_mode="bridge",
                    dag=dag
                )

load >> wait >> dwh_transformations
