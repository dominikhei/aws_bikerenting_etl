select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select user_group_id
from "bikerenting"."dbt_dbikerenting"."trips_fact"
where user_group_id is null



      
    ) dbt_internal_test