-- Ćwiczenie 1
-- A

CREATE TABLE figury (
    id      NUMBER(1) PRIMARY KEY,
    ksztalt mdsys.sdo_geometry
);

-- B

INSERT INTO figury VALUES (
    1,
    mdsys.sdo_geometry(2003,
                       NULL,
                       NULL,
                       mdsys.sdo_elem_info_array(1, 1003, 4),
                       mdsys.sdo_ordinate_array(5, 7, 3, 5, 5, 3))
);

INSERT INTO figury VALUES (
    2,
    mdsys.sdo_geometry(2003,
                       NULL,
                       NULL,
                       mdsys.sdo_elem_info_array(1, 1003, 3),
                       mdsys.sdo_ordinate_array(1, 1, 5, 5))
);

INSERT INTO figury VALUES (
    3,
    mdsys.sdo_geometry(2006,
                       NULL,
                       NULL,
                       mdsys.sdo_elem_info_array(1, 4, 2, 1, 2, 1, 5, 2, 2),
                       mdsys.sdo_ordinate_array(3, 2, 6, 2, 7, 3, 8, 2, 7, 1))
);

-- C

INSERT INTO figury VALUES (
    4,
    mdsys.sdo_geometry(2003,
                       NULL,
                       NULL,
                       mdsys.sdo_elem_info_array(1, 1003, 4),
                       mdsys.sdo_ordinate_array(1, 7, 3, 5, 5, 3))
);

-- D

SELECT
    id,
    sdo_geom.validate_geometry_with_context(ksztalt, 0.005) AS val
FROM
    figury;

-- E

DELETE FROM figury
WHERE
    sdo_geom.validate_geometry_with_context(ksztalt, 0.005) NOT LIKE 'TRUE';

-- F

COMMIT;