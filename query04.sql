/*

Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.

*/



-- set search_path to public, septa;


-- CREATE INDEX IF NOT EXISTS idx_bus_shapes_shape_seq
-- ON septa.bus_shapes (shape_id, shape_pt_sequence);
-- SET enable_seqscan = OFF;-- force index use if needed to ensure best plan with spatial and ordering indexes

-- Strategy 1 - run in about 1m 27s
-- WITH shape_lengths AS (
--     SELECT
--         r.route_short_name,
--         t.trip_headsign,
--         ST_MakeLine(s.geog::geometry ORDER BY s.shape_pt_sequence)::geography AS shape_geog,
--         ST_Length(ST_MakeLine(s.geog::geometry ORDER BY s.shape_pt_sequence)::geography)::numeric AS shape_length
--     FROM septa.bus_shapes as s
--     JOIN septa.bus_trips as t ON s.shape_id = t.shape_id
--     JOIN septa.bus_routes r ON t.route_id = r.route_id
--     WHERE r.route_short_name IS NOT NULL
--     -- Filter out routes without short name
--         AND s.shape_id IN (
--             SELECT shape_id 
--             FROM septa.bus_shapes 
--             GROUP BY shape_id 
--             HAVING COUNT(*) > 5)
--     -- Filter out shapes with few points (could be noise)
--     GROUP BY r.route_short_name, t.trip_headsign, t.shape_id
-- ),
-- ranked_shapes AS (
--     SELECT *,
--            ROW_NUMBER() OVER (ORDER BY shape_length DESC) AS rank
--     FROM shape_lengths
-- )
-- SELECT 
--     route_short_name,
--     trip_headsign,
--     shape_geog,
--     ROUND(shape_length, 2) AS shape_length
-- FROM ranked_shapes
-- WHERE rank <= 2;


--- Strategy 2 -  I got this query to run in about 2s
WITH trip_shape AS (
    SELECT
        s.shape_id,
        ST_MakeLine(s.geog::geometry ORDER BY s.shape_pt_sequence) AS shape_geog
    FROM septa.bus_shapes as s
    GROUP BY s.shape_id
),
trip_length AS (
    SELECT 
        ts.shape_id,
        ts.shape_geog,
        t.trip_headsign,
        t.route_id,
        ST_LENGTH(ts.shape_geog) as shape_length
    FROM trip_shape as ts
    LEFT JOIN septa.bus_trips as t on ts.shape_id = t.shape_id
    GROUP BY ts.shape_id, ts.shape_geog,t.trip_headsign, t.route_id, shape_length
),
ranked_shapes AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY shape_length DESC) AS rank
    FROM trip_length
)
SELECT 
    r.route_short_name,
    rs.trip_headsign,
    shape_geog,
    ROUND(rs.shape_length::numeric, 2) AS shape_length
FROM ranked_shapes as rs
LEFT JOIN septa.bus_routes as r on rs.route_id = r.route_id
WHERE rank <= 2;