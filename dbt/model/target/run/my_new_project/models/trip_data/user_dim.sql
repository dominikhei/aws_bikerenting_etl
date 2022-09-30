

  create  table
    "bikerenting"."dbt_dbikerenting"."user_dim__dbt_tmp"
    
    
    
  as (
    

with user_dim as (

select 
     md5(cast(coalesce(cast(usertype as TEXT), '') || '-' || coalesce(cast(gender as TEXT), '') as TEXT)) as id,
     usertype,
     gender
from 
     "bikerenting"."dbt_dbikerenting"."trips_stg" 
group by 
     usertype,
     gender     

)

select * 
from user_dim
  );