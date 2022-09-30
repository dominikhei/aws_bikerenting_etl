select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select day
from "bikerenting"."dbt_dbikerenting"."date_dim"
where day is null



      
    ) dbt_internal_test