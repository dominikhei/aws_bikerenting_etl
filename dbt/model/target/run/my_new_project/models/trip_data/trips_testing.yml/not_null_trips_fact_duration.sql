select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select duration
from "bikerenting"."dbt_dbikerenting"."trips_fact"
where duration is null



      
    ) dbt_internal_test