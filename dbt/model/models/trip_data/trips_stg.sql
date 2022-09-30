--{{ config ( materialized="table" )}}

with trips_stg as (

    select *

    from {{ source('trips_data', 'trip_stage_table') }}
)

select * from trips_stg