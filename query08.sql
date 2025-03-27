/*

With a query, find out how many census block groups Penn's main campus fully contains.
Discuss which dataset you chose for defining Penn's campus.

*/
set search_path to public, septa, phl, census;

with penn_parcels as (
    select 
        p.objectid,
        p.geog::geometry as geom
    from phl.pwd_parcels as p
    where owner1 like '%TRUSTEES OF THE UNIVERSIT%'
        or
        owner1 like '%TRS UNIV OF PENN%'
        or
        owner1 like '%UNIV OF PENNSYLVANIA%'
        or
        owner1 like '%THE UNIVERSITY OF PENNA%'
        or
        owner1 like '%UNIVERSITY CITY ASSOC%'
        or
        owner2 like '%TRUSTEES OF THE UNIVERSIT%'
        or
        owner2 like '%TRS UNIV OF PENN%'
        or
        owner2 like '%UNIV OF PENNSYLVANIA%'
        or
        owner2 like '%THE UNIVERSITY OF PENNA%'
        or
        owner2 like '%UNIVERSITY CITY ASSOC%'
),
penn_campus as (
    SELECT
        st_union(geom) as geom
    from penn_parcels
)
SELECT
    count(*) as count_block_groups
from census.blockgroups_2020 as bg,
     penn_campus as pc
where st_contains(pc.geom, bg.geog::geometry);

/*

Discussion:

I used the code to see is there any parcels related  to UPenn.

SELECT *
FROM phl.pwd_parcels
WHERE 
owner1 like '%UNIV%'
or owner1 like '%PENN%'
or owner2 like '%UNIV%'
or owner2 like '%PENN%';

Then I got about 50 results. Then I saw them one by one and finally got the list of owner1 and owner2
that were related to Upenn campus.

*/