select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select minute
from "bikerenting"."dbt_dbikerenting"."time_dim"
where minute is null



      
    ) dbt_internal_test