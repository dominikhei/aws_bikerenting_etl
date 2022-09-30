select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select loaded_at
from "bikerenting"."dbt_dbikerenting"."trips_fact"
where loaded_at is null



      
    ) dbt_internal_test