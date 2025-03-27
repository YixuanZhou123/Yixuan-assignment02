/*

With a query involving PWD parcels and census block groups, 
find the geo_id of the block group that contains Meyerson Hall. 
ST_MakePoint() and functions like that are not allowed.

*/

set search_path to public, septa, phl, census;
SELECT
    cb.geoid as geo_id
FROM census.blockgroups_2020 as cb
join phl.pwd_parcels as pp
    on st_contains(cb.geog::geometry, pp.geog::geometry)
where pp.address = '220-30 S 34TH ST';
