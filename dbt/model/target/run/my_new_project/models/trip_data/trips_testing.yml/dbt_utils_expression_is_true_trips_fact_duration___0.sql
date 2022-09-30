select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with meet_condition as (
    select * from "bikerenting"."dbt_dbikerenting"."trips_fact" where 1=1
)

select
    *
from meet_condition

where not(duration  >= 0)


      
    ) dbt_internal_test