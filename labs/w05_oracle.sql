SET SERVEROUTPUT ON SIZE UNLIMITED

CREATE OR REPLACE
    TYPE sql_varray IS VARRAY(3) OF VARCHAR2(20);
/

SELECT
column_value AS "Three Stooges"
FROM
TABLE(sql_varray('Moe','Larry','Curly'))
ORDER BY 1;

DECLARE
    /* Declare a collection variable with a constructor call. */
    lv_stooges SQL_VARRAY := sql_varray('Moe','Larry');
BEGIN
    /* Print the number and limit of elements. */
    dbms_output.put_line(
        'Count ['||lv_stooges.COUNT||'] ' ||
        'Limit ['||lv_stooges.LIMIT||'] '
    );

    /* Extend space and assign to the new index. */
    lv_stooges.EXTEND;

    /* Print the number and limit of elements. */
    dbms_output.put_line(
        'Count ['||lv_stooges.COUNT||'] '||
        'Limit ['||lv_stooges.LIMIT||']'
    );

    /* Assign a new value. */
    lv_collection(lv_stooges.COUNT) := 'Curly';

    /* Iterate across the collection to the total number of elements. */
    FOR i IN 1..lv_stooges.COUNT LOOP
        dbms_output.put_line(lv_stooges(i));
    END LOOP;
END;
/

CREATE OR REPLACE
    TYPE sql_table IS TABLE OF VARCHAR2(20);
/

SELECT      column_value AS "Dunedain"
FROM        TABLE(sql_varray('Aragron','Faramir','Boromir'))
ORDER BY 1;

CREATE OR REPLACE FUNCTION add_element
( pv_table       SQL_TABLE
, pv_element     VARCHAR2 ) RETURN SQL_TABLE IS

    /* Declare a local table collection. */
    lv_table    SQL_TABLE := sql_table();
BEGIN

    /* Check for an initialized collection parameter. */
    IF pv_table.EXISTS(1) THEN -- A suboptimal comparison
        lv_table := pv_table;
    END IF;

    /* Check for a not null element before adding it. */
    IF pv_element IS NOT NULL THEN
        /* Extend space and add an element. */
        lv_table.EXTEND;
        lv_table(lv_table.COUNT) := pv_element;
    END IF;

    /* Return the table collection with its new member. */
    RETURN lv_table;
END;
/

-- No table yet

UPDATE TABLE    (SELECT e.home_address
                FROM    employee e
                WHERE   e.employee_id=1) e
SET     e.street_address = add_an_element(e.street_address, 'Suite 622')
,       e.city = 'Oakland'
WHERE   e.address_id = 1;

SELECT      column_value AS "Dunedain"
FROM        TABLE(add_element(sql_table('Faramir','Boromir'),'Aragron'))
ORDER BY 1;

DECLARE
    /* Declare a meaning-laden variable name and exclude the
    lv_ preface from the variable name. */

    current INTEGER

    /* Declare a local table collection. */
    lv_table    SQL_TABLE := sql_table('Aragron','Faramir','Boromir');
BEGIN
    /* Remove the lead element of a table collection. */
    lv_table.DELETE(1);

    /* Set the starting point. */
    current := lv_table.FIRST;

    /* Check pseudo index value less than last index value. */
    WHILE (current <= lv_table.LAST) LOOP
        /* Print current value. */
        dbms_output.put_line(
            'Index ['||current||']['||lv_table(current)||']'
        );
        current := lv_table.NEXT(current);
    END LOOP;
END;
/

CREATE OR REPLACE PACKAGE type_library IS
    /* Define a local table collection. */
    TYPE plsql_table IS TABLE OF VARCHAR2(20);
END;
/

CREATE OR REPLACE
    TYPE prominent_object IS OBJECT 
    ( name      VARCHAR2(20)
    , age       VARCHAR2(10));
/

CREATE OR REPLACE
    TYPE people_object IS OBJECT 
    ( race      VARCHAR2(10)
    , exemplar  PROMINENT_OBJECT);
/

CREATE OR REPLACE
    TYPE people_table IS TABLE OF people_object;
/

SELECT o.race, n.name, n.age
FROM    TABLE(
            people_table(
                people_object(
                    'Men'
                    , prominent_object('Aragorn','3rd Age'))
            , people_object(
                'Elf'
                , prominent_object('Legolas','3rd Age'))
            )) o CROSS JOIN
        TABLE(
            SELECT CAST(COLLECT(exemplar) AS prominent_table)
            FROM dual) n;

-- This worked
DECLARE
    /* Declare a table collection. */
    lv_tolkien_table    PEOPLE_TABLE := people_table(
                            people_object('Men'
                            , prominent_object('Aragorn','3rd Age'))
                        , people_object('Elf',
                        prominent_object('Legolas','3rd Age')));
BEGIN
    /* Add a new record to collection. */
    lv_tolkien_table.EXTEND;
    lv_tolkien_table(lv_tolkien_table.COUNT) :=
        people_object('Dwarf'
                        , prominent_object('Gimli','3rd Age'));
    /* Read and print values in table collection. */
    FOR i IN lv_tolkien_table.FIRST..lv_tolkien_table.LAST LOOP
        dbms_output.put_line(
            lv_tolkien_table(i).race||': '||lv_tolkien_table(i).exemplar.name);
        END LOOP;
    END;
/

DECLARE
    /* Declare a PL/SQL record. */
    TYPE tolkien_record IS RECORD 
    ( race          VARCHAR2(10)
    , name          VARCHAR2(20)
    , age           VARCHAR2(10));

    /* Declare a table of the record. */
    TYPE tolkien_plsql_table IS TABLE OF TOLKIEN_RECORD;

    /* Declare record and table collection variables. */
    lv_tolkien_record       TOLKIEN_RECORD;
    lv_tolkien_plsql_table  TOLKIEN_PLSQL_TABLE;

    /* Declare a table collection. */
    lv_tolkien_table    PEOPLE_TABLE := people_table(
                            people_object('Men'
                            , prominent_object('Aragorn','3rd Age'))
                        , people_object('Elf',
                        prominent_object('Legolas','3rd Age')));
BEGIN
    /* Single-row implicit subquery. */
    SELECT      o.race, n.name, n.age
    INTO        lv_tolkien_record
    FROM        TABLE(lv_tolkien_table) o CROSS JOIN
                TABLE(
                        SELECT CAST(COLLECT(exemplar) AS prominent_table)
                        FROM    dual) n 
    WHERE       ROWNUM < 2;

    dbms_output.put_line(
       '['||lv_tolkien_record.race||'] '|| 
       '['||lv_tolkien_record.name||'] '||
       '['||lv_tolkien_record.age ||']');
END;
/

-------------------------
-- Defining and Using Associative Arrays
-------------------------

DECLARE
    /* Define an associative array of a scalar data type. */
    TYPE suit_table IS TABLE OF VARCHAR2(7 CHAR)
        INDEX BY BINARY_INTEGER;

    /* Declare and attempt to construct an object. */
    lv_suit suit_table;
BEGIN
    /* Assign values to an ADT. */
    lv_suit(1) := 'Club';
    lv_suit(2) := 'Heart';
    lv_suit(3) := 'Diamond';
    lv_suit(4) := 'Spade';

    /* Loop through a densely populated indexed collection. */
    FOR i IN lv_suit.FIRST..lv_suit.LAST LOOP
        dbms_output.put_line(lv_suit(i));
    END LOOP;
END;
/

-- Key (or string) indexed associative arrays

DECLARE
    /* Variable name carries meaning. */
    current VARCHAR2(5);

    /* Define an associative array of a scalar data type. */
    TYPE card_table IS TABLE OF NUMBER
        INDEX BY VARCHAR2(5);
    
    /* Declare and attempt to construct an object. */
    lv_card CARD_TABLE;
BEGIN
    /* Assign values to an ADT. */
    lv_card('Ace') := 1;
    lv_card('Two') := 2;
    lv_card('Three') := 3;
    lv_card('Four') := 4;
    lv_card('Five') := 5;
    lv_card('Six') := 6;
    lv_card('Seven') := 7;
    lv_card('Eight') := 8;
    lv_card('Nine') := 9;
    lv_card('Ten') := 10;
    lv_card('Jack') := 11;
    lv_card('Queen') := 12;
    lv_card('King') := 13;

    /* Set the starting point. */
    current := lv_card.FIRST;

    /* Check pseudo index value less than last index value. */
    WHILE (current <= lv_card.LAST) LOOP
        /* Print current value. */
        dbms_output.put_line(
            'Values ['||current||']['||lv_card(current)||']');

        /* Shift the index to the next value. */
        current := lv_card.NEXT(current);
    END LOOP;
END;
/

CREATE OR REPLACE
    TYPE prominent_object IS OBJECT
    ( name      VARCHAR2(20)
    , age       VARCHAR2(10));
/

DECLARE
    /* Declare a local type of a SQL composite data type. */
    TYPE prominent_table IS TABLE OF prominent_object
        INDEX BY PLS_INTEGER;

    /* Declare a local variable of the collection data type. */
    lv_array    PROMINENT_TABLE;
BEGIN
    /* The initial element uses -100 as an index value. */
    lv_array(-100) := prominent_object('Bard the Bowman','3rd Age');

    /* Check whether there are any elements to retrieve. */
    IF lv_array.EXISTS(-100) THEN
        dbms_output.put_line(
          '['||lv_array(-100).name||']['||lv_array(-100).age||']');
    END IF;
END;
/

-----------------------------
-- Oracle Collection API ----
-----------------------------

-- pg 249

DECLARE
    /* Define the table collection. */
    TYPE empty_table IS TABLE OF prominent_object;
    /* Declare a table collection variable */
    lv_array    EMPTY_TABLE := empty_table(null);
BEGIN
    /* Check whether the element is allocated in memory. */
    IF lv_array.EXISTS(1) THEN
        dbms_output.put_line('Valid Collection.');
    ELSE 
        dbms_output.put_line('Invalid Collection');
    END IF;
END;
/

--------------------------
-- COUNT Method
--------------------------

DECLARE
    /* Define a table collection. */
    TYPE x_table IS TABLE OF INTEGER;

    /* Declare an initialized table collection. */
    lv_table NUMBER_TABLE := number_table(1,2,3,4,5);
BEGIN
    DBMS_OUTPUT.PUT_LINE('How many? ['||lv_table.COUNT||']');
END;
/

---------------------
-- DELETE Method
---------------------

DECLARE
    /* Declare variable with meaningful name. */
    current INTEGER;

    /* Define a table collection. */
    TYPE x_table IS TABLE OF VARCHAR2(6);

    /* Declare an initialized table collection. */
    lv_table X_TABLE := x_table('One','Two','Three','Four','Five');
BEGIN
    /* Remove one element with an index of 2. */
    lv_table.DELETE(2,2);

    /* Remove elements for an inclusive range of 4 to 5. */
    lv_table.DELETE(4,5);

    /* Set the starting index. */
    current := lv_table.FIRST;

    /* Read through index values in ascending order. */
    WHILE (current <= lv_table.LAST) LOOP
        dbms_output.put_line(
           'Index ['||current||'] Value ['||lv_table(current)||']');
        /* Shift index to next higher value. */
        current := lv_table.NEXT(current);
    END LOOP;
END;
/