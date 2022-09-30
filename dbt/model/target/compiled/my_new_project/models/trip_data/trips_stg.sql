--

with trips_stg as (

    select *

    from "bikerenting"."public"."trip_stage_table"
)

select * from trips_stg