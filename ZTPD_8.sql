--- Operator CONTAINS - Podstawy ---

-- EX 1

CREATE TABLE cytaty
    AS
        SELECT
            *
        FROM
            ztpd.cytaty;
            
-- EX 2

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    lower(tekst) LIKE '%optymista%'
    AND lower(tekst) LIKE '%pesymista%';
    
-- EX 3

CREATE INDEX cytaty_idx ON
    cytaty (
        tekst
    )
        INDEXTYPE IS ctxsys.context;
        
-- EX 4

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'optymista and pesymista') > 0;
    
-- EX 5

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'pesymista ~ optymista') > 0;
    
-- EX 6

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'near((optymista, pesymista), 3)') > 0;
    
-- EX 7

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'near((optymista, pesymista), 10)') > 0;
    
-- EX 8

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'życi%') > 0;
    
-- EX 9

SELECT
    autor,
    tekst,
    contains(tekst, 'życi%') score
FROM
    cytaty
WHERE
    contains(tekst, 'życi%') > 0;
    
-- EX 10

SELECT
    autor,
    tekst,
    contains(tekst, 'życi%') dopasowanie
FROM
    cytaty
WHERE
        contains(tekst, 'życi%') > 0
    AND ROWNUM <= 1
ORDER BY
    dopasowanie DESC;
    
-- EX 11

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'fuzzy(‘problem’)') > 0;
    
-- EX 12

INSERT INTO cytaty VALUES (
    39,
    'Bertrand Russell',
    'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);

COMMIT;

-- EX 13

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'głupcy') > 0;
    
-- EX 14

SELECT
    *
FROM
    dr$cytaty_idx$i
WHERE
    token_text = 'głupcy';
    
-- EX 15

DROP INDEX cytaty_idx;

CREATE INDEX cytaty_idx ON
    cytaty (
        tekst
    )
        INDEXTYPE IS ctxsys.context;
        
-- EX 16

SELECT
    autor,
    tekst
FROM
    cytaty
WHERE
    contains(tekst, 'głupcy') > 0;
    
-- EX 17

DROP INDEX cytaty_idx;

DROP TABLE cytaty;

--- Zaawansowane indeksowanie i wyszukiwanie ---

-- EX 1

CREATE TABLE quotes
    AS
        SELECT
            *
        FROM
            ztpd.quotes;
            
-- EX 2

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context;
        
-- EX 3

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'work') > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(text, '$work') > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'working') > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(text, '$working') > 0;
    
-- EX 4

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'it') > 0;
    
-- EX 5

SELECT
    *
FROM
    ctx_stoplists;
    
-- EX 6

SELECT
    *
FROM
    ctx_stopwords;
    
-- EX 7

DROP INDEX quotes_idx;

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'stoplist CTXSYS.EMPTY_STOPLIST' );
        
-- EX 8 (Yes)

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'it') > 0;
    
-- EX 9

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'fool and humans') > 0;

-- EX 10

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'fool and computer') > 0;
    
-- EX 11

SELECT
    *
FROM
    quotes
WHERE
    contains(text, '(fool and humans) within sentence') > 0;
    
-- EX 12

DROP INDEX quotes_idx;

-- EX 13

BEGIN
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
END;

-- EX 14

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'section group nullgroup' );
        
-- EX 15

SELECT
    *
FROM
    quotes
WHERE
    contains(text, '(fool and humans) within sentence') > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(text, '(fool and computer) within sentence') > 0;
    
-- EX 16

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'humans') > 0;
    
-- EX 17

DROP INDEX quotes_idx;

BEGIN
    ctx_ddl.create_preference('lex_z_m', 'BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '_-');
    ctx_ddl.set_attribute('lex_z_m', 'index_text', 'YES');
END;

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'lexer lex_z_m' );
        
-- EX 18 (No)

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'humans') > 0;
    
-- EX 19

SELECT
    *
FROM
    quotes
WHERE
    contains(text, 'non\-humans') > 0;
    
-- EX 20
DROP INDEX quotes_idx;

DROP TABLE quotes;