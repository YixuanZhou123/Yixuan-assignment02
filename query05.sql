/*

Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset 
from the Septa GTFS bus feed. Use the GTFS documentation for help. 
Use some creativity in the metric you devise in rating neighborhoods.

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
order by accessibility_index DESC;

/*

Description:

To evaluate neighborhood accessibility for wheelchair users,
I created an Accessibility Index based on the distribution of wheelchair-accessible
and inaccessible bus stops across Philadelphia neighborhoods.
I used the OpenDataPhilly neighborhoods dataset and the SEPTA GTFS bus_stops feed,
particularly the wheelchair_boarding field, where:

1 indicates wheelchair accessibility, and

2 indicates inaccessibility.

First, I counted the number of accessible and inaccessible stops within each neighborhood boundary
using ST_Contains(). To account for neighborhood size and ensure fairness,
I normalized these counts by the area (in hectares) of each neighborhood using ST_Area().

Then, I computed an Accessibility Index defined as:

access_score / (inaccess_score + 1)

This ratio rewards neighborhoods with more accessible stops and penalizes those with inaccessible ones,
while preventing division by zero. A higher index reflects better wheelchair access per unit of area
and lower presence of inaccessible stops.

*/