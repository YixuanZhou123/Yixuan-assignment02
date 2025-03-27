/*

This file contains the SQL commands to prepare the database for your queries.
Before running this file, you should have created your database, created the
schemas (see below), and loaded your data into the database.

Creating your schemas
---------------------

You can create your schemas by running the following statements in PG Admin:

    create schema if not exists septa;
    create schema if not exists phl;
    create schema if not exists census;

Also, don't forget to enable PostGIS on your database:

    create extension if not exists postgis;

Loading your data
-----------------

After you've created the schemas, load your data into the database specified in
the assignment README.

Finally, you can run this file either by copying it all into PG Admin, or by
running the following command from the command line:

    psql -U postgres -d <YOUR_DATABASE_NAME> -f db_structure.sql

*/

-- 1. Create a table: septa.bus_stops
CREATE TABLE septa.bus_stops (
    stop_id TEXT,
    stop_code TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT,
    location_type INTEGER,
    parent_station TEXT,
    stop_timezone TEXT,
    wheelchair_boarding INTEGER
);
copy septa.bus_stops
from'D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\google_bus\stops.txt'
with (format CSV, header true);

-- 1.1 Add a column to the septa.bus_stops table to store the geometry of each stop.
set search_path to public;
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- 1.2 Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);

SELECT * FROM septa.bus_stops LIMIT 100


-- 2. Create a table: septa.bus_routes
CREATE TABLE septa.bus_routes (
    route_id TEXT,
    agency_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_desc TEXT,
    route_type TEXT,
    route_url TEXT,
    route_color TEXT,
    route_text_color TEXT
);
copy septa.bus_routes
from'D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\google_bus\routes.txt'
with (format CSV, header true);
SELECT * FROM septa.bus_routes;



-- 3. Create a table: septa.bus_trips
CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    trip_short_name TEXT,
    direction_id TEXT,
    block_id TEXT,
    shape_id TEXT,
    wheelchair_accessible INTEGER,
    bikes_allowed INTEGER
);
copy septa.bus_trips
from'D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\google_bus\trips.txt'
with (format CSV, header true);
SELECT * FROM septa.bus_trips LIMIT 100;



-- 4. Create a table: septa.bus_shapes
CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);
copy septa.bus_shapes
from'D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\google_bus\shapes.txt'
with (format CSV, header true);
SELECT * FROM septa.bus_shapes LIMIT 100;

-- 4.1 Add a column to the septa.bus_shapes table to store the geometry of each stop.
set search_path to public;
alter table septa.bus_shapes
add column if not exists geog geography;

update septa.bus_shapes
set geog = st_makepoint(shape_pt_lat, shape_pt_lon)::geography;

-- 4.2 Create an index on the geog column.
create index if not exists septa_bus_shapes__geog__idx
on septa.bus_shapes using gist
(geog);

SELECT * FROM septa.bus_shapes LIMIT 100



-- 5. Create a table: septa.rail_stops
CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);
copy septa.rail_stops
from'D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\google_rail\stops.txt'
with (format CSV, header true);

-- 5.1 Add a column to the septa.rail_stops table to store the geometry of each stop.
set search_path to public;
alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- 5.2 Create an index on the geog column.
create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);

SELECT * FROM septa.bus_stops LIMIT 100

-- 6. Load data: phl.pwd_parcels
/* ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=990928" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\PWD_PARCELS\PWD_PARCELS.shp"
*/

-- 7. Load data: phl.neighborhoods
/* ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=990928" \
    -nln phl.neighborhoods \
    -nlt MULTIPOLYGON \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\philadelphia-neighborhoods\philadelphia-neighborhoods.geojson"
*/

-- 8. Load data: census.blockgroups_2020
/* ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=990928" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\tl_2020_42_bg\tl_2020_42_bg.shp"
*/



-- 9. Load data:census.population_2020
-- 9.1 Convert original data with data_pre.py from json to csv, then use ogr2ogr to load data
-- ogr2ogr -f "PostgreSQL"  -nln "population_2020_orig"  -lco "SCHEMA=census"  -lco "GEOM_TYPE=geography" -lco "GEOMETRY_NAME=geog" -lco "OVERWRITE=yes" PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=990928" "D:/Upenn/25spring/MUSA-5090 Geospatial Cloud Computing & Visualization/GITHUB/Yixuan-assignment02/data/DECENNIALPL2020.P1_2025-03-10T181522/census_data.csv"
-- 9.2 deal with the data & create a table: census.population_2020
select * from census.population_2020_orig;
CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);
/*Ensure Data is Convertible to INTEGER*/
SELECT p1_001n
FROM census.population_2020_orig
WHERE NOT p1_001n ~ '^[0-9]+$';  -- Finds non-numeric values
/*Convert p1_001 to INTEGER*/
ALTER TABLE census.population_2020_orig
ALTER COLUMN p1_001n TYPE INTEGER 
USING p1_001n::INTEGER;
/*Load data into population_2020*/
INSERT INTO census.population_2020 (geoid, geoname, total)
SELECT geo_id, name, p1_001n
FROM census.population_2020_orig;
select * from census.population_2020;

-- 10. Load Landmarks
/* ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=990928" \
    -nln phl.landmarks \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "D:\Upenn\25spring\MUSA-5090 Geospatial Cloud Computing & Visualization\GITHUB\Yixuan-assignment02\data\landmarks\Landmark_Points.shp"
*/