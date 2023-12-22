-- EX 1 A.

SELECT
    lpad('-', 2 *(level - 1), '|-')
    || t.owner
    || '.'
    || t.type_name
    || ' (FINAL:'
    || t.final
    || ', INSTANTIABLE:'
    || t.instantiable
    || ', ATTRIBUTES:'
    || t.attributes
    || ', METHODS:'
    || t.methods
    || ')'
FROM
    all_types t
START WITH
    t.type_name = 'ST_GEOMETRY'
CONNECT BY PRIOR t.type_name = t.supertype_name
           AND PRIOR t.owner = t.owner;
           
-- EX 1 B.

SELECT DISTINCT
    m.method_name
FROM
    all_type_methods m
WHERE
    m.type_name LIKE 'ST_POLYGON'
    AND m.owner = 'MDSYS'
ORDER BY
    1;
    
-- EX 1 C.

CREATE TABLE myst_major_cities (
    fips_cntry VARCHAR2(2),
    city_name  VARCHAR2(40),
    stgeom     st_point
);

-- EX 1 D.

DESCRIBE major_cities;

INSERT INTO myst_major_cities
    SELECT
        fips_cntry,
        city_name,
        st_point(geom)
    FROM
        major_cities;

-- EX 2 A.

INSERT INTO myst_major_cities VALUES (
    'PL',
    'Szczyrk',
    st_point(19.036107, 49.718655, 8307)
);

-- EX 3 A.

CREATE TABLE myst_country_boundaries (
    fips_cntry VARCHAR2(2),
    cntry_name VARCHAR2(40),
    stgeom     st_multipolygon
);

-- EX 3 B.

DESCRIBE country_boundaries;

INSERT INTO myst_country_boundaries
    SELECT
        fips_cntry,
        cntry_name,
        st_multipolygon(geom)
    FROM
        country_boundaries;
        
-- EX 3 C.

SELECT
    mcb.stgeom.st_geometrytype() typ_obiektu,
    COUNT(*)                     ile
FROM
    myst_country_boundaries mcb
GROUP BY
    mcb.stgeom.st_geometrytype();
    
-- EX 3 D.

SELECT
    b.stgeom.st_issimple()
FROM
    myst_country_boundaries b;
    
-- EX 4 A.

SELECT
    b.cntry_name,
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
    c.stgeom.st_within(b.stgeom) = 1
GROUP BY
    b.cntry_name;
    
-- EX 4 B.

SELECT
    a.cntry_name a_name,
    b.cntry_name b_name
FROM
    myst_country_boundaries a,
    myst_country_boundaries b
WHERE
        a.stgeom.st_touches(b.stgeom) = 1
    AND b.cntry_name = 'Czech Republic';
    
-- EX 4 C.

SELECT DISTINCT
    b.cntry_name,
    r.name
FROM
    myst_country_boundaries b,
    rivers                  r
WHERE
        b.cntry_name = 'Czech Republic'
    AND st_linestring(r.geom).st_intersects(b.stgeom) = 1;

-- EX 4 D.

SELECT
    TREAT(a.stgeom.st_union(b.stgeom) AS st_polygon).st_area() powierzchnia
FROM
    myst_country_boundaries a,
    myst_country_boundaries b
WHERE
        a.cntry_name = 'Czech Republic'
    AND b.cntry_name = 'Slovakia';

-- EX 4 E.

SELECT
    b.stgeom                                                      obiekt,
    b.stgeom.st_difference(st_geometry(w.geom)).st_geometrytype() wegry_bez
FROM
    myst_country_boundaries b,
    water_bodies            w
WHERE
        b.cntry_name = 'Hungary'
    AND w.name = 'Balaton';
    
-- EX 5 A.

SELECT
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
        sdo_within_distance(c.stgeom, b.stgeom, 'distance=100 unit=km') = 'TRUE'
    AND b.cntry_name = 'Poland';

-- EX 5 B.

INSERT INTO user_sdo_geom_metadata
    SELECT
        'MYST_MAJOR_CITIES',
        'STGEOM',
        t.diminfo,
        t.srid
    FROM
        all_sdo_geom_metadata t
    WHERE
        t.table_name = 'MAJOR_CITIES';

INSERT INTO user_sdo_geom_metadata
    SELECT
        'MYST_COUNTRY_BOUNDARIES',
        'STGEOM',
        t.diminfo,
        t.srid
    FROM
        all_sdo_geom_metadata t
    WHERE
        t.table_name = 'COUNTRY_BOUNDARIES';

-- EX 5 C.

CREATE INDEX myst_major_cities_idx ON
    myst_major_cities (
        stgeom
    )
        INDEXTYPE IS mdsys.spatial_index;

CREATE INDEX myst_country_boundaries_idx ON
    myst_country_boundaries (
        stgeom
    )
        INDEXTYPE IS mdsys.spatial_index;

-- EX 5 D.

SELECT
    b.cntry_name a_name,
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
        sdo_within_distance(c.stgeom, b.stgeom, 'distance=100 unit=km') = 'TRUE'
    AND b.cntry_name = 'Poland'
GROUP BY
    b.cntry_name;

EXPLAIN PLAN
    FOR
SELECT
    a.cntry_name,
    COUNT(*)
FROM
    myst_country_boundaries a,
    myst_major_cities       b
WHERE
        sdo_within_distance(b.stgeom, a.stgeom, 'distance=100 unit=km') = 'TRUE'
    AND a.cntry_name = 'Poland'
GROUP BY
    a.cntry_name;

SELECT
    *
FROM
    TABLE ( dbms_xplan.display );