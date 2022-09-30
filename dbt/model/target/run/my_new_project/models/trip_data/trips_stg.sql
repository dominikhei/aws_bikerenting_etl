

  create  table
    "bikerenting"."dbt_dbikerenting"."trips_stg__dbt_tmp"
    
    
    
  as (
    --

with trips_stg as (

    select *

    from "bikerenting"."public"."trip_stage_table"
)

select * from trips_stg
  );