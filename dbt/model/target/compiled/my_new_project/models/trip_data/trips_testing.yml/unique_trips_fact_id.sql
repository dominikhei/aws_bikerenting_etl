
    
    

select
    id as unique_field,
    count(*) as n_records

from "bikerenting"."dbt_dbikerenting"."trips_fact"
where id is not null
group by id
having count(*) > 1


