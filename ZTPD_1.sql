-- EX 1

CREATE TYPE samochod AS OBJECT (
        marka          VARCHAR2(20),
        model          VARCHAR2(20),
        kilometry      NUMBER,
        data_produkcji DATE,
        cena           NUMBER(10, 2)
);

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES (
    NEW samochod ( 'FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'FORD', 'MONDERO', 80000, DATE '1997-05-10', 45000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'MAZDA', '323', 12000, DATE '2000-09-22', 52000 )
);

desc samochod;

SELECT
    *
FROM
    samochody;
    
-- EX 2

CREATE TYPE wlasciciel AS OBJECT (
        imie     VARCHAR2(100),
        nazwisko VARCHAR2(100),
        auto     samochod
);

CREATE TABLE wlasciciele OF wlasciciel;

INSERT INTO wlasciciele VALUES (
    NEW wlasciciel ( 'JAN', 'KOWALSKI', NEW samochod('FIAT', 'SEICHENTO', 30000, DATE '0010-12-20', 19500) )
);

INSERT INTO wlasciciele VALUES (
    NEW wlasciciel ( 'ADAM', 'NOWAK', NEW samochod('OPEL', 'ASTRA', 34000, DATE '0009-06-01', 33700) )
);

desc wlasciciele;

SELECT
    *
FROM
    wlasciciele;

SELECT
    *
FROM
    samochody;

-- EX 3

ALTER TYPE samochod REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN power(0.9, extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji)) * cena;
    END wartosc;

END;

SELECT
    s.marka,
    s.cena,
    s.wartosc()
FROM
    samochody s;

-- EX 4

ALTER TYPE samochod ADD MAP MEMBER FUNCTION ODWZORUJ 
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN power(0.9, extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji)) * cena;
    END wartosc;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji) + floor(kilometry / 10000);
    END odwzoruj;

END;

SELECT
    *
FROM
    samochody s
ORDER BY
    value(s);

-- EX 5

DROP TABLE wlasciciele;
DROP TYPE wlasciciel;

CREATE TYPE wlasciciel AS OBJECT (
        imie     VARCHAR2(100),
        nazwisko VARCHAR2(100)
);

CREATE TABLE wlasciciele OF wlasciciel;

ALTER TYPE samochod ADD ATTRIBUTE ( col_wlasciciel REF wlasciciel )
    CASCADE;

DROP TABLE samochody;
CREATE TABLE samochody OF samochod;
ALTER TABLE samochody ADD SCOPE FOR ( col_wlasciciel ) IS wlasciciele;

INSERT INTO wlasciciele VALUES (
    NEW wlasciciel ( 'JAN', 'KOWALSKI')
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000, 
    (select
    ref ( w ) FROM wlasciciele w WHERE
        w.imie = 'JAN' ))
);

SELECT
    *
FROM
    samochody;
    
SELECT
    *
FROM
    wlasciciele;

-- EX 6

DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty
t_przedmioty := t_przedmioty('');

BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.extend(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;

    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;

    moje_przedmioty.trim(2);
    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;

    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    moje_przedmioty.extend();
    moje_przedmioty(9) := 9;
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    moje_przedmioty.DELETE();
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
END;

-- EX 7

DECLARE
 TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
 moje_ksiazki
t_ksiazki := t_ksiazki('');

BEGIN
    moje_ksiazki(1) := 'Pan Tadeusz';
    moje_ksiazki.extend(9);
    FOR i IN 2..10 LOOP
        moje_ksiazki(i) := 'TYTUL_' || i;
    END LOOP;

    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;

    moje_ksiazki.trim(5);
    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;

    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
    moje_ksiazki.extend();
    moje_ksiazki(6) := 6;
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
    moje_ksiazki.DELETE();
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
END;

-- EX 8

DECLARE
 TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
 moi_wykladowcy
t_wykladowcy := t_wykladowcy();

BEGIN
    moi_wykladowcy.extend(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.extend(8);
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;

    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.trim(2);
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.DELETE(5, 7);
    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            dbms_output.put_line(moi_wykladowcy(i));
        END IF;
    END LOOP;

    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            dbms_output.put_line(moi_wykladowcy(i));
        END IF;
    END LOOP;

    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
END;

-- EX 9

DECLARE
 TYPE t_miesiace IS TABLE OF VARCHAR2(20);
 miesiace
t_miesiace := t_miesiace();

BEGIN
    miesiace.extend(12);
    miesiace(1) := 'January';
    miesiace(2) := 'February';
    miesiace(3) := 'March';
    miesiace(4) := 'April';
    miesiace(5) := 'May';
    miesiace(6) := 'June';
    miesiace(7) := 'July';
    miesiace(8) := 'August';
    miesiace(9) := 'September';
    miesiace(10) := 'October';
    miesiace(11) := 'November';
    miesiace(12) := 'December';
    dbms_output.put_line('Limit: ' || miesiace.limit());
    dbms_output.put_line('Liczba elementow: ' || miesiace.count());
    miesiace.DELETE(9, 11);
    FOR i IN miesiace.first()..miesiace.last() LOOP
        IF miesiace.EXISTS(i) THEN
            dbms_output.put_line(miesiace(i));
        END IF;
    END LOOP;

    dbms_output.put_line('Limit: ' || miesiace.limit());
    dbms_output.put_line('Liczba elementow: ' || miesiace.count());
END;

-- EX 10

CREATE TYPE jezyki_obce AS
    VARRAY(10) OF VARCHAR2(20);
/

CREATE TYPE stypendium AS OBJECT (
        nazwa  VARCHAR2(50),
        kraj   VARCHAR2(30),
        jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES (
    'SOKRATES',
    'FRANCJA',
    jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI')
);

INSERT INTO stypendia VALUES (
    'ERASMUS',
    'NIEMCY',
    jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI')
);

SELECT
    *
FROM
    stypendia;

SELECT
    s.jezyki
FROM
    stypendia s;

UPDATE stypendia
SET
    jezyki = jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI', 'FRANCUSKI')
WHERE
    nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS
    TABLE OF VARCHAR2(20);
/

CREATE TYPE semestr AS OBJECT (
        numer    NUMBER,
        egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES ( semestr(1,
                                      lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')) );

INSERT INTO semestry VALUES ( semestr(2,
                                      lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')) );

SELECT
    s.numer,
    e.*
FROM
    semestry             s,
    TABLE ( s.egzaminy ) e;

SELECT
    e.*
FROM
    semestry             s,
    TABLE ( s.egzaminy ) e;

SELECT
    *
FROM
    TABLE (
        SELECT
            s.egzaminy
        FROM
            semestry s
        WHERE
            numer = 1
    );

INSERT INTO TABLE (
    SELECT
        s.egzaminy
    FROM
        semestry s
    WHERE
        numer = 2
) VALUES ( 'METODY NUMERYCZNE' );

UPDATE TABLE (
    SELECT
        s.egzaminy
    FROM
        semestry s
    WHERE
        numer = 2
) e
SET
    e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE
    e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE (
    SELECT
        s.egzaminy
    FROM
        semestry s
    WHERE
        numer = 2
) e
WHERE
    e.column_value = 'BAZY DANYCH';

-- EX 11

CREATE TYPE koszyk AS
    TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
        name             VARCHAR2(20),
        koszyk_produktow koszyk
);

CREATE TABLE zakupy OF zakup
NESTED TABLE koszyk_produktow STORE AS tab_koszyk_produktow;

INSERT INTO zakupy VALUES ( zakup('Lidl',
                                  koszyk('Piwo', 'Pieluszki', 'Pomidor')) );

INSERT INTO zakupy VALUES ( zakup('Biedronka',
                                  koszyk('Pieczywo', 'Pierogi')) );

SELECT
    z.name,
    k.*
FROM
    zakupy                       z,
    TABLE ( z.koszyk_produktow ) k;

SELECT
    k.*
FROM
    zakupy                       z,
    TABLE ( z.koszyk_produktow ) k;

SELECT
    *
FROM
    TABLE (
        SELECT
            z.koszyk_produktow
        FROM
            zakupy z
        WHERE
            z.name LIKE 'Lidl'
    );

INSERT INTO TABLE (
    SELECT
        z.koszyk_produktow
    FROM
        zakupy z
    WHERE
        z.name LIKE 'Lidl'
) VALUES ( 'Marchew' );

UPDATE TABLE (
    SELECT
        z.koszyk_produktow
    FROM
        zakupy z
    WHERE
        z.name LIKE 'Biedronka'
) k
SET
    k.column_value = 'Buła'
WHERE
    k.column_value = 'Pieczywo';

DELETE FROM TABLE (
    SELECT
        z.koszyk_produktow
    FROM
        zakupy z
    WHERE
        z.name LIKE 'Lidl'
) k
WHERE
    k.column_value = 'Piwo';

SELECT
    z.name,
    k.*
FROM
    zakupy                       z,
    TABLE ( z.koszyk_produktow ) k;

-- EX 12

CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
 
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/

CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/

CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
 
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/

DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian
instrument_klawiszowy := instrument_klawiszowy('fortepian', 'pingping', 'steinway');

BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;

-- EX 13

CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
 
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
 
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;

DECLARE
 KrolLew lew := lew('LEW',4);
 InnaIstota
istota := istota('JAKIES ZWIERZE');

BEGIN
    dbms_output.put_line(krollew.poluj('antylopa'));
END;

-- EX 14

DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka   instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn', 'brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki', 'ding-ding', 'metalowe');
    trabka := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
 -- saksofon := instrument('saksofon','tra-taaaa');
 -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- EX 15

CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty VALUES ( instrument('tamburyn', 'brzdek-brzdek') );

INSERT INTO instrumenty VALUES ( instrument_dety('trabka', 'tra-ta-ta', 'metalowa') );

INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian', 'pingping', 'steinway') );

SELECT
    i.nazwa,
    i.graj()
FROM
    instrumenty i;

-- EX 16

CREATE TABLE przedmioty (
    nazwa      VARCHAR2(50),
    nauczyciel NUMBER
        REFERENCES pracownicy ( id_prac )
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    100
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    100
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    110
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    110
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    120
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    120
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    130
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    140
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    140
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    140
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    150
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    150
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    160
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    160
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    170
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    180
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    180
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    190
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    200
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    210
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    220
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    220
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    230
);

-- EX 17

CREATE TYPE ZESPOL AS OBJECT (
 ID_ZESP NUMBER,
 NAZWA VARCHAR2(50),
 ADRES VARCHAR2(100)
);

-- EX 18

CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
WITH OBJECT IDENTIFIER(ID_ZESP)
AS SELECT ID_ZESP, NAZWA, ADRES FROM
zespoly;

-- EX 19

CREATE TYPE przedmioty_tab AS
    TABLE OF VARCHAR2(100);
/

CREATE TYPE pracownik AS OBJECT (
        id_prac       NUMBER,
        nazwisko      VARCHAR2(30),
        etat          VARCHAR2(20),
        zatrudniony   DATE,
        placa_pod     NUMBER(10, 2),
        miejsce_pracy REF zespol,
        przedmioty    przedmioty_tab,
        MEMBER FUNCTION ile_przedmiotow RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY pracownik AS
    MEMBER FUNCTION ile_przedmiotow RETURN NUMBER IS
    BEGIN
        RETURN przedmioty.count();
    END ile_przedmiotow;

END;

-- EX 20

CREATE OR REPLACE VIEW pracownicy_v
    OF pracownik WITH OBJECT IDENTIFIER ( id_prac )
AS
    SELECT
        id_prac,
        nazwisko,
        etat,
        zatrudniony,
        placa_pod,
        make_ref(zespoly_v, id_zesp),
        CAST(MULTISET(
            SELECT
                nazwa
            FROM
                przedmioty
            WHERE
                nauczyciel = p.id_prac
        ) AS przedmioty_tab)
    FROM
        pracownicy p;
        
-- EX 21

SELECT
    *
FROM
    pracownicy_v;

SELECT
    p.nazwisko,
    p.etat,
    p.miejsce_pracy.nazwa
FROM
    pracownicy_v p;

SELECT
    p.nazwisko,
    p.ile_przedmiotow()
FROM
    pracownicy_v p;

SELECT
    *
FROM
    TABLE (
        SELECT
            przedmioty
        FROM
            pracownicy_v
        WHERE
            nazwisko = 'WEGLARZ'
    );

SELECT
    nazwisko,
    CURSOR (
        SELECT
            przedmioty
        FROM
            pracownicy_v
        WHERE
            id_prac = p.id_prac
    )
FROM
    pracownicy_v p;
    
-- EX 22

CREATE TABLE PISARZE (
 ID_PISARZA NUMBER PRIMARY KEY,
 NAZWISKO VARCHAR2(20),
 DATA_UR DATE );
 
CREATE TYPE PISARZ AS OBJECT (
 ID_PISARZA NUMBER,
 NAZWISKO VARCHAR2(20),
 DATA_UR DATE,
 MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER );
 
CREATE OR REPLACE VIEW PISARZE_V OF PISARZ
WITH OBJECT IDENTIFIER (ID_PISARZA)
AS SELECT ID_PISARZA, NAZWISKO, DATA_UR
FROM PISARZE;

CREATE TABLE KSIAZKI (
 ID_KSIAZKI NUMBER PRIMARY KEY,
 ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
 TYTUL VARCHAR2(50),
 DATA_WYDANIE DATE );
 
CREATE TYPE KSIAZKA AS OBJECT (
 ID_KSIAZKI NUMBER,
 AUTOR REF PISARZ,
 TYTUL VARCHAR2(50),
 DATA_WYDANIE DATE,
 MEMBER FUNCTION ILE_LAT RETURN NUMBER ); 
 
CREATE OR REPLACE VIEW KSIAZKI_V OF KSIAZKA
WITH OBJECT IDENTIFIER (ID_KSIAZKI)
AS SELECT ID_KSIAZKI, MAKE_REF(PISARZE_V, ID_PISARZA), TYTUL, DATA_WYDANIE
FROM
ksiazki;

CREATE OR REPLACE TYPE BODY pisarz AS
    MEMBER FUNCTION ile_ksiazek RETURN NUMBER IS
        result NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO result
        FROM
            ksiazki_v k
        WHERE
            k.autor.id_pisarza = id_pisarza;

        RETURN result;
    END ile_ksiazek;

END;

CREATE OR REPLACE TYPE BODY ksiazka AS
    MEMBER FUNCTION ile_lat RETURN NUMBER IS
    BEGIN
        RETURN extract(YEAR FROM current_date) - extract(YEAR FROM data_wydanie);
    END ile_lat;

END;

INSERT INTO pisarze VALUES (
    10,
    'SIENKIEWICZ',
    DATE '1880-01-01'
);

INSERT INTO pisarze VALUES (
    20,
    'PRUS',
    DATE '1890-04-12'
);

INSERT INTO pisarze VALUES (
    30,
    'ZEROMSKI',
    DATE '1899-09-11'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    10,
    10,
    'OGNIEM I MIECZEM',
    DATE '1990-01-05'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    20,
    10,
    'POTOP',
    DATE '1975-12-09'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    30,
    10,
    'PAN WOLODYJOWSKI',
    DATE '1987-02-15'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    40,
    20,
    'FARAON',
    DATE '1948-01-21'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    50,
    20,
    'LALKA',
    DATE '1994-08-01'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    60,
    30,
    'PRZEDWIOSNIE',
    DATE '1938-02-02'
);

SELECT
    k.tytul,
    k.autor.nazwisko,
    k.ile_lat()
FROM
    ksiazki_v k;

SELECT
    p.nazwisko,
    p.ile_ksiazek()
FROM
    pisarze_v p;
    
-- EX 23
CREATE TYPE auto AS OBJECT (
        marka          VARCHAR2(20),
        model          VARCHAR2(20),
        kilometry      NUMBER,
        data_produkcji DATE,
        cena           NUMBER(10, 2),
        MEMBER FUNCTION wartosc RETURN NUMBER
) NOT FINAL;

CREATE TYPE auto_osobowe UNDER auto (
        liczba_miejsc NUMBER,
        klimatyzacja  NUMBER(1, 0),
        OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE TYPE auto_ciezarowe UNDER auto (
        ladownosc NUMBER,
        OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek    NUMBER;
        wartosc NUMBER;
    BEGIN
        wiek := round(months_between(sysdate, data_produkcji) / 12);
        wartosc := cena - ( wiek * 0.1 * cena );
        IF ( wartosc < 0 ) THEN
            wartosc := 0;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE OR REPLACE TYPE BODY auto_osobowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := ( self AS auto ).wartosc();
        IF klimatyzacja = 1 THEN
            wartosc := wartosc + 0.5 * wartosc;
        END IF;

        RETURN wartosc;
    END wartosc;

END;

CREATE OR REPLACE TYPE BODY auto_ciezarowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := ( self AS auto ).wartosc();
        IF ladownosc > 10 THEN
            wartosc := wartosc * 2;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE TABLE auta OF auto;

CREATE TABLE auta_osobowe OF auto_osobowe;

CREATE TABLE auta_ciezarowe OF auto_ciezarowe;

INSERT INTO auta VALUES ( auto('FIAT', 'BRAVA', 60000, DATE '2020-11-30', 25000) );

INSERT INTO auta VALUES ( auto('FORD', 'MONDEO', 80000, DATE '2017-05-10', 45000) );

INSERT INTO auta VALUES ( auto('MAZDA', '323', 12000, DATE '2022-09-22', 52000) );

INSERT INTO auta VALUES ( auto_osobowe('FIAT_OSOBOWE', 'BRAVA', 60000, DATE '2020-11-30', 25000,
                                       5, 0) );

INSERT INTO auta VALUES ( auto_osobowe('FORD_OSOBOWE', 'MONDEO', 80000, DATE '2017-05-10', 45000,
                                       4, 1) );

INSERT INTO auta VALUES ( auto_ciezarowe('FIAT_CIEZAROWE', 'BRAVA', 60000, DATE '2020-11-30', 25000,
                                         8) );

INSERT INTO auta VALUES ( auto_ciezarowe('FORD_CIEZAROWE', 'MONDEO', 80000, DATE '2017-05-10', 45000,
                                         12) );

SELECT
    a.marka,
    a.wartosc()
FROM
    auta a;
