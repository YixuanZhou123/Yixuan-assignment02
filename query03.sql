/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. The final result should give the parcel
address, bus stop name, and distance apart in meters, rounded to two decimals. Order
by distance (largest on top).

*/

set search_path to public, septa;
-- -- 1. add spatial indexes to speed it up
-- -- (1) on bus_stops
-- CREATE INDEX IF NOT EXISTS idx_bus_stops_geog_geom
-- ON septa.bus_stops USING GIST ((geog::geometry));
-- -- (2) on pwd_parcels
-- CREATE INDEX IF NOT EXISTS idx_parcels_geog_geom
-- ON phl.pwd_parcels USING GIST ((geog::geometry));


SELECT
    p.address AS parcel_address,
    s.stop_name,
    ROUND((p.geog::geometry <-> s.geog::geometry)::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN LATERAL (
    SELECT
        s.stop_name,
        s.geog
    FROM septa.bus_stops AS s
    ORDER BY s.geog::geometry <-> p.geog::geometry
    LIMIT 1
) AS s
ORDER BY distance ASC;