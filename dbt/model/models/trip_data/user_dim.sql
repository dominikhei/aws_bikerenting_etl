{{ config ( materialized="table" )}}

with user_dim as (

select 
     {{ dbt_utils.surrogate_key('usertype','gender') }} as id,
     usertype,
     gender
from 
     {{ ref ('trips_stg')}} 
group by 
     usertype,
     gender     

)

select * 
from user_dim