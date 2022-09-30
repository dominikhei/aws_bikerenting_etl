{{ config ( materialized="table" )}}

with starttime_dim as (

    select 
         SUBSTRING(starthour,1,2) as hour,
         SUBSTRING(starthour,4,2) as minute,
         SUBSTRING(starthour,7,2) as second
    from 
         {{ ref ('trips_stg')}} 
    group by 
         SUBSTRING(starthour,1,2),
         SUBSTRING(starthour,4,2),
         SUBSTRING(starthour,7,2)
),

stoptime_dim as(

    select 
         SUBSTRING(stophour,1,2) as hour,
         SUBSTRING(stophour,4,2) as minute,
         SUBSTRING(stophour,7,2) as second
    from 
         {{ ref ('trips_stg')}} 
    group by 
         SUBSTRING(stophour,1,2),
         SUBSTRING(stophour,4,2),
         SUBSTRING(stophour,7,2)
),

both_times_intm as (

    select *
    from stoptime_dim
    union all
    select *
    from starttime_dim
),

time_dim as (

    select 
         {{ dbt_utils.surrogate_key('hour','minute','second') }} as id,
         hour,
         minute,
         second
    from 
         both_times_intm
    group by 
         hour,
         minute,
         second
)

select * from time_dim