/*

You're tasked with giving more contextual information to rail stops to
fill the stop_desc field in a GTFS feed. Using any of the data sets above,
PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions,
build a description (alias as stop_desc) for each stop. Feel free to supplement
with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships.
SQL's CASE statements may be helpful for some operations.

*/

set search_path to public, septa, phl, census;

with landmarks as (
    SELECT
        s.stop_id::INTEGER,
        s.stop_name::TEXT,
        s.stop_desc::TEXT,
        s.stop_lon::DOUBLE PRECISION,
        s.stop_lat::DOUBLE PRECISION,
        l.name as landmark,
        ROUND(s.geog <-> l.geog)::numeric AS distance
    from septa.rail_stops as s
    cross join lateral (
        select
            l.name,
            l.geog
        from phl.landmarks as l
        order by l.geog::geometry <-> s.geog::geometry -- Nearest by geography
        limit 1
    ) as l
)
select
    stop_id,
    stop_name,
    round(distance)::TEXT || ' meters from' ||landmark as stop_desc,
    stop_lon,
    stop_lat
from landmarks;
