-- EX 1

CREATE TABLE movies
    AS
        SELECT
            *
        FROM
            ztpd.movies;
            
-- EX 2

DESCRIBE movies;

SELECT
    *
FROM
    movies;

-- EX 3

SELECT
    id,
    title
FROM
    movies
WHERE
    cover IS NULL;
    
-- EX 4

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    cover IS NOT NULL;
    
-- EX 5

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    cover IS NULL;
    
-- EX 6

SELECT
    directory_name,
    directory_path
FROM
    all_directories;
    
-- EX 7

UPDATE movies
SET
    cover = empty_blob(),
    mime_type = 'image/jpeg'
WHERE
    id = 66;

COMMIT;

-- EX 8

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    id IN ( 65, 66 );
    
-- EX 9

DECLARE
    lobd BLOB;
    fils BFILE := bfilename('TPD_DIR', 'escape.jpg');
BEGIN
    SELECT
        cover
    INTO lobd
    FROM
        movies
    WHERE
        id = 66
    FOR UPDATE;

    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lobd, fils, dbms_lob.getlength(fils));
    dbms_lob.fileclose(fils);
    COMMIT;
END;

-- EX 10

CREATE TABLE temp_covers (
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);

-- EX 11

INSERT INTO temp_covers VALUES (
    65,
    bfilename('TPD_DIR', 'eagles.jpg'),
    'image/jpeg'
);

COMMIT;

-- EX 12

SELECT
    movie_id,
    dbms_lob.getlength(image) AS filesize
FROM
    temp_covers;
    
-- EX 13

DECLARE
    lobd      BLOB;
    fils      BFILE;
    mime_type VARCHAR2(50);
BEGIN
    -- 1)
    SELECT
        image,
        mime_type
    INTO
        fils,
        mime_type
    FROM
        temp_covers
    WHERE
        movie_id = 65;

    -- 2)
    dbms_lob.createtemporary(lobd, TRUE);
    
    -- 3)
    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lobd, fils, dbms_lob.getlength(fils));
    dbms_lob.fileclose(fils);
    
    -- 4)
    UPDATE movies
    SET
        cover = lobd,
        mime_type = mime_type
    WHERE
        id = 65;
    
    -- 5)
    dbms_lob.freetemporary(lobd);
    
    -- 6)
    COMMIT;
END;

-- EX 14

SELECT
    id,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    id IN ( 65, 66 );
    
-- EX 15

DROP TABLE movies;