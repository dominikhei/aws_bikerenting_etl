{{ config ( materialized="table" )}}

with startstation_dim as (

    SELECT startstationid as id,
        startstationname as name,
        startstationlongitude as longitude,
        startstationlatitude as latitude
    FROM {{ ref ('trips_stg')}} 
    GROUP BY startstationid, startstationname, startstationlongitude, startstationlatitude
),
    stopstation_dim as (

    SELECT endstationid as id,
        endstationname as name,
        endstationlongitude as longitude,
        endstationlatitude as latitude
    FROM {{ ref ('trips_stg')}} 
    GROUP BY endstationid, endstationname, endstationlongitude, endstationlatitude
),
    both_stations_intm as (

        select * from stopstation_dim
        UNION ALL
        select * from startstation_dim
),

    station_dim as (

        select 
             id,
             name,
             longitude,
             latitude,
             '{{ run_started_at.strftime("%Y-%m-%d") }}' as valid_from,
             '9999-12-31' as valid_to
        from both_stations_intm
        group by 
             id,
             name,
             longitude,
             latitude
)

select * from station_dim