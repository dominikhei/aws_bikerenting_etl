select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      -- This test tests for the fact, that the fact table has the same amount of rows as the stage table.

with inter as (
select

sum((select count(*) from "bikerenting"."dbt_dbikerenting"."trips_fact" where loaded_at = '2022-09-29') - (select count(*) from "bikerenting"."dbt_dbikerenting"."trips_stg")) as result
from "bikerenting"."dbt_dbikerenting"."trips_stg"
)

select * from inter
where result > 0
      
    ) dbt_internal_test