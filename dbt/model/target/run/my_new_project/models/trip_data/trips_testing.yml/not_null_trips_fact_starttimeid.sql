select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select starttimeid
from "bikerenting"."dbt_dbikerenting"."trips_fact"
where starttimeid is null



      
    ) dbt_internal_test