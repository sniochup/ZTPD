-- EX 1: A.

SELECT
    *
FROM
    figury;

INSERT INTO user_sdo_geom_metadata VALUES (
    'FIGURY',
    'KSZTALT',
    mdsys.sdo_dim_array(mdsys.sdo_dim_element('X', 0, 9, 0.01),
                        mdsys.sdo_dim_element('Y', 0, 8, 0.01)),
    NULL
);

-- EX 1: B.

SELECT
    sdo_tune.estimate_rtree_index_size(3000000, 8192, 10, 2, 0)
FROM
    dual;
    
-- EX 1: C. 

CREATE INDEX figury_idx ON
    figury (
        ksztalt
    )
        INDEXTYPE IS mdsys.spatial_index_v2;
        
-- EX 1: D.

SELECT
    id
FROM
    figury
WHERE
    sdo_filter(ksztalt,
               sdo_geometry(2001,
                            NULL,
                            sdo_point_type(3, 3, NULL),
                            NULL,
                            NULL)) = 'TRUE';

-- EX 1: E.

SELECT
    id
FROM
    figury
WHERE
    sdo_relate(ksztalt,
               sdo_geometry(2001,
                            NULL,
                            sdo_point_type(3, 3, NULL),
                            NULL,
                            NULL),
               'mask=ANYINTERACT') = 'TRUE';
               
-- EX 2: A.

SELECT
    city_name          AS miasto,
    sdo_nn_distance(1) AS odl
FROM
    major_cities
WHERE
        city_name != 'Warsaw'
    AND sdo_nn(geom,(
        SELECT
            geom
        FROM
            major_cities
        WHERE
            city_name = 'Warsaw'
    ), 'sdo_num_res=10 unit=km', 1) = 'TRUE';
    
-- EX 2: B.

SELECT
    city_name AS miasto
FROM
    major_cities
WHERE
        city_name != 'Warsaw'
    AND sdo_within_distance(geom,(
        SELECT
            geom
        FROM
            major_cities
        WHERE
            city_name = 'Warsaw'
    ), 'distance=100 unit=km') = 'TRUE';

-- EX 2: C.

SELECT
    b.cntry_name AS kraj,
    c.city_name  AS miasto
FROM
    country_boundaries b,
    major_cities       c
WHERE
        sdo_relate(c.geom, b.geom, 'mask=INSIDE') = 'TRUE'
    AND b.cntry_name = 'Slovakia';
    
-- EX 2: D.

SELECT
    b.cntry_name             AS panstwo,
    sdo_geom.sdo_distance((
        SELECT
            geom
        FROM
            country_boundaries
        WHERE
            cntry_name = 'Poland'
    ), b.geom, 1, 'unit=km') AS odl
FROM
    country_boundaries b
WHERE
    sdo_relate((
        SELECT
            geom
        FROM
            country_boundaries
        WHERE
            cntry_name = 'Poland'
    ), b.geom, 'mask=ANYINTERACT') = 'FALSE';
    
-- EX 3: A.

SELECT
    cntry_name,
    sdo_geom.sdo_length(sdo_geom.sdo_intersection((
        SELECT
            geom
        FROM
            country_boundaries
        WHERE
            cntry_name = 'Poland'
    ), geom, 1),
                        1,
                        'unit=km') AS odleglosc
FROM
    country_boundaries
WHERE
    sdo_relate((
        SELECT
            geom
        FROM
            country_boundaries
        WHERE
            cntry_name = 'Poland'
    ), geom, 'mask=TOUCH') = 'TRUE';
    
-- EX 3: B.

SELECT
    cntry_name
FROM
    (
        SELECT
            cntry_name,
            round(sdo_geom.sdo_area(geom, 1, 'unit=SQ_KM'))
        FROM
            country_boundaries
        ORDER BY
            2 DESC
    )
FETCH FIRST 1 ROWS ONLY;

-- EX 3: C.

SELECT
    sdo_geom.sdo_area(sdo_aggr_mbr(geom),
                      1,
                      'unit=SQ_KM') AS sq_km
FROM
    major_cities
WHERE
    city_name IN ( 'Warsaw', 'Lodz' );

-- EX 3: D.

SELECT
    sdo_geom.sdo_union(a.geom, b.geom, 1).sdo_gtype gtype
FROM
    country_boundaries a,
    major_cities       b
WHERE
        a.cntry_name = 'Poland'
    AND b.city_name = 'Prague';

-- EX 3: E.

SELECT
    b.city_name,
    a.cntry_name
FROM
    country_boundaries a,
    major_cities       b
WHERE
    sdo_geom.sdo_distance(sdo_geom.sdo_centroid(a.geom, 1),
                          b.geom,
                          1) = (
        SELECT
            MIN(sdo_geom.sdo_distance(sdo_geom.sdo_centroid(a.geom, 1),
                                      b.geom,
                                      1))
        FROM
            country_boundaries a,
            major_cities       b
    );

-- EX 3: F.

SELECT
    r.name,
    SUM(sdo_geom.sdo_length(sdo_geom.sdo_intersection(b.geom, r.geom, 1),
                            1,
                            'unit=KM')) AS dlugosc
FROM
    country_boundaries b,
    rivers             r
WHERE
        b.cntry_name = 'Poland'
    AND sdo_relate(b.geom, r.geom, 'mask=ANYINTERACT') = 'TRUE'
GROUP BY
    r.name;