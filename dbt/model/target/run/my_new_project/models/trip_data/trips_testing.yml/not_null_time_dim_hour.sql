select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select hour
from "bikerenting"."dbt_dbikerenting"."time_dim"
where hour is null



      
    ) dbt_internal_test