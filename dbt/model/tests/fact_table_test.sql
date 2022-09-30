-- This test tests for the fact, that the fact table has the same amount of rows as the stage table.

with inter as (
select

sum((select count(*) from {{ref ('trips_fact')}} where loaded_at = '{{ run_started_at.strftime("%Y-%m-%d") }}') - (select count(*) from {{ ref ('trips_stg')}})) as result
from {{ ref ('trips_stg')}}
)

select * from inter
where result > 0