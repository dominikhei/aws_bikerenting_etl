{{ config ( materialized="table" )}}

with startdate_dim as (

    select 
         SUBSTRING(startdate,1,4) as year,
         SUBSTRING(startdate,6,2) as month,
         SUBSTRING(startdate,9,2) as day
    from 
         {{ ref ('trips_stg')}} 
    group by 
         SUBSTRING(startdate,1,4),
         SUBSTRING(startdate,6,2),
         SUBSTRING(startdate,9,2)
         
),

stopdate_dim as(

    select 
         SUBSTRING(stopdate,1,4) as year,
         SUBSTRING(stopdate,6,2) as month,
         SUBSTRING(stopdate,9,2) as day
         
    from 
         {{ ref ('trips_stg')}} 
    group by 
         SUBSTRING(stopdate,1,4),
         SUBSTRING(stopdate,6,2),
         SUBSTRING(stopdate,9,2)
         
),

both_dates_intm as (

    select *
    from stopdate_dim
    union all
    select *
    from startdate_dim
),

date_dim as (

    select 
         {{ dbt_utils.surrogate_key('year','month','day') }} as id,
         year,
         month,
         day
    from 
         both_dates_intm
    group by 
         year,
         month,
         day
)

select * from date_dim