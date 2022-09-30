
    
    

with all_values as (

    select
        usertype as value_field,
        count(*) as n_records

    from "bikerenting"."dbt_dbikerenting"."user_dim"
    group by usertype

)

select *
from all_values
where value_field not in (
    'Subscriber','Customer'
)


