-- EX 1

CREATE TABLE dokumenty (
    id       NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

-- EX 2

DECLARE
    lobd CLOB;
BEGIN
    FOR i IN 1..10000 LOOP
        lobd := lobd || 'Oto tekst. ';
    END LOOP;

    INSERT INTO dokumenty VALUES (
        1,
        lobd
    );

END;

-- EX 3

SELECT
    *
FROM
    dokumenty;

SELECT
    id,
    upper(dokument)
FROM
    dokumenty;

SELECT
    length(dokument)
FROM
    dokumenty;

SELECT
    dbms_lob.getlength(dokument)
FROM
    dokumenty;

SELECT
    substr(dokument, 5, 1000)
FROM
    dokumenty;

SELECT
    dbms_lob.substr(dokument, 1000, 5)
FROM
    dokumenty;
    
-- EX 4

INSERT INTO dokumenty VALUES (
    2,
    empty_clob()
);

-- EX 5

INSERT INTO dokumenty VALUES (
    3,
    NULL
);

COMMIT;

-- EX 6

SELECT
    *
FROM
    dokumenty;

SELECT
    id,
    upper(dokument)
FROM
    dokumenty;

SELECT
    length(dokument)
FROM
    dokumenty;

SELECT
    dbms_lob.getlength(dokument)
FROM
    dokumenty;

SELECT
    substr(dokument, 5, 1000)
FROM
    dokumenty;

SELECT
    dbms_lob.substr(dokument, 1000, 5)
FROM
    dokumenty;
    
-- EX 7

DECLARE
    lobd    CLOB;
    fils    BFILE := bfilename('TPD_DIR', 'dokument.txt');
    doffset INTEGER := 1;
    soffset INTEGER := 1;
    langctx INTEGER := 0;
    warn    INTEGER := NULL;
BEGIN
    SELECT
        dokument
    INTO lobd
    FROM
        dokumenty
    WHERE
        id = 2
    FOR UPDATE;

    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadclobfromfile(lobd, fils, dbms_lob.lobmaxsize, doffset, soffset,
                             0, langctx, warn);

    dbms_lob.fileclose(fils);
    COMMIT;
    dbms_output.put_line('Status operacji: ' || warn);
END;

-- EX 8

UPDATE dokumenty
SET
    dokument = to_clob(bfilename('TPD_DIR', 'dokument.txt'),
                       0)
WHERE
    id = 3;
    
-- EX 9

SELECT
    *
FROM
    dokumenty;
    
-- EX 10

SELECT
    id,
    dbms_lob.getlength(dokument)
FROM
    dokumenty;
    
-- EX 11

DROP TABLE dokumenty;

-- EX 12

CREATE OR REPLACE PROCEDURE clob_censor (
    p_clob           IN OUT NOCOPY CLOB,
    p_text_to_censor IN VARCHAR2
) IS
    v_replace_length INTEGER := length(p_text_to_censor);
    v_position       INTEGER := 0;
BEGIN
    LOOP
        v_position := dbms_lob.instr(p_clob, p_text_to_censor);
        IF v_position LIKE 0 THEN
            EXIT;
        END IF;
        dbms_lob.write(p_clob, v_replace_length, v_position, rpad('.', v_replace_length, '.'));

    END LOOP;
END;

-- EX 13

CREATE TABLE biographies
    AS
        SELECT
            *
        FROM
            ztpd.biographies;

DECLARE
    lob CLOB;
BEGIN
    SELECT
        bio
    INTO lob
    FROM
        biographies
    FOR UPDATE;

    clob_censor(lob, 'Cimrman');
    COMMIT;
END;

SELECT
    *
FROM
    biographies;
    
-- EX 14

DROP TABLE biographies;