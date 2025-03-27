/*

What are the top five neighborhoods according to your accessibility metric?

*/

set search_path to public, septa, phl;

with num_access as (
    SELECT
        n.name as neighborhood_name,
        count(*) filter (where s.wheelchair_boarding=1)::int as num_bus_stops_accessible,
        count(*) filter (where s.wheelchair_boarding=2)::int as num_bus_stops_inaccessible,
        n.geog
    from phl.neighborhoods as n
    join septa.bus_stops as s
        on st_contains(n.geog::geometry, s.geog::geometry)
    group by n.name, n.geog
),
score_access as (
    select 
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        round(("num_bus_stops_accessible"/(st_area(geog::geometry))/10000)::numeric, 1) as access_score,
        round(("num_bus_stops_inaccessible"/(st_area(geog::geometry))/10000)::numeric, 1) as inaccess_score
    from num_access as na
)
select *,
    round(access_score/(inaccess_score+1), 2) as accessibility_index
from score_access
order by accessibility_index DESC
limit 5;



