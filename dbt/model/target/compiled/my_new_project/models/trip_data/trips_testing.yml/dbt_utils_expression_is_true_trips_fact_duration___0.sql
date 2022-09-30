

with meet_condition as (
    select * from "bikerenting"."dbt_dbikerenting"."trips_fact" where 1=1
)

select
    *
from meet_condition

where not(duration  >= 0)

