{{ config ( materialized="table" )}}

with trips_fact as(
Select st.id,
       dd1.id as startdate,
       dd2.id as stopdate,
       sta1.id as startstationid,
       sta2.id as stopstationid,
       st.duration,
       ti1.id as starttimeid,
       ti2.id as stoptimeid,
       ud.id as user_group_id,
       '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at

FROM {{ref ('trips_stg')}} st
JOIN  {{ref ('date_dim')}} dd1 
ON st.startdate = CONCAT(dd1.year,CONCAT('-',CONCAT(dd1.month,CONCAT('-',dd1.day))))
JOIN  {{ref ('date_dim')}} dd2 
ON st.stopdate = CONCAT(dd2.year,CONCAT('-',CONCAT(dd2.month,CONCAT('-',dd2.day))))
JOIN {{ref ('stations_dim')}} sta1
ON st.startstationid = sta1.id
JOIN {{ref ('stations_dim')}} sta2
ON st.endstationid = sta2.id
JOIN {{ref ('time_dim')}} ti1
ON st.starthour = CONCAT(ti1.hour,CONCAT(':',CONCAT(ti1.minute,CONCAT(':',ti1.second))))
JOIN {{ref ('time_dim')}} ti2
ON st.stophour = CONCAT(ti2.hour,CONCAT(':',CONCAT(ti2.minute,CONCAT(':',ti2.second))))
JOIN {{ref ('user_dim')}} ud
ON st.gender = ud.gender
AND st.usertype = ud.usertype
)

select *
from trips_fact
