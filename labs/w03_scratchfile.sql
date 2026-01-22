SET SERVEROUTPUT ON

-- Guard-on-Entry Loop

LOOP
 [counter_management_statements]
 IF NOT entry_condition THEN
 EXIT;
 END IF;
 repeating_statements
END LOOP;

-- Guard-on-Exit Loop

LOOP
 repeating_statements
 [counter_management_
statements]
 IF exit_condition THEN
 EXIT;
 END IF;
END LOOP;

DECLARE 
    lv_counter NUMBER := 1;
BEGIN
    LOOP
    -- increment-by-one logic
    lv_counter := lv_counter + 1;
    -- Entry guard with a sentinel value of 3.
    IF NOT lv_counter < 3 THEN
        EXIT;
    END IF;
        -- Repeatable statements.
        dbms_output.put_line('Iteration ['||lv_counter||']');
    END LOOP;
END;
/

DECLARE
    lv_counter NUMBER := 1;
BEGIN
    LOOP
        dbms_output.put_line('Iteration ['||lv_counter||']');

        lv_counter := lv_counter + 1;
        EXIT WHEN lv_counter > 4;
    END LOOP;
END;

-- Guard-on-exit Loop

DECLARE
    lv_counter NUMBER := 1;
BEGIN
    LOOP
        -- Run once and for all and then for qualified iterations
        dbms_output.put_line('Iteration ['||lv_counter||']');
        -- Increment-by-one logic at least once. 
        lv_counter := lv_counter + 1;
        -- Exit guard, with a static sentinel value of 3.
        EXIT WHEN NOT lv_counter < 3;
    END LOOP;
END;
/
/*  Iteration [1]
    Iteration [2]

PL/SQL procedure successfully completed. */

-- Create a SQL collection before creating the procedure.
-- The following creates an Attribute Data Type (ADT)

CREATE OR REPLACE
    TYPE elf_table IS TABLE OF VARCHAR2(30);
/
-- Type created.

CREATE OR REPLACE PROCEDURE ascending
    ( pv_index      NUMBER
    , pv_sentinel   NUMBER
    , pv_elves      ELF_TABLE ) IS

    -- Declare local index and sentinel variables
    lv_counter      NUMBER;
    lv_sentinel     NUMBER;

    -- Declare an empty list, which has a size of zero.
    lv_elves        ELF_TABLE := elf_table();
BEGIN
    /* Assign the starting index value. */
    lv_counter := NVL(pv_index,0);

    /* Check whether incoming list has elements. */
    IF pv_elves IS NOT EMPTY THEN
        /* Size the sentinel and assign the list to a local clone. */
        lv_sentinel := NVL(pv_sentinel,pv_elves.COUNT);
        lv_elves := pv_elves;
    ELSE
        /* Size the sentinel value. */
        lv_sentinel := 1;
    END IF;

    /* Loop through the list of variables. */
    LOOP
        /* Increment the index counter. */
        lv_counter := lv_counter +1;

        -- Exit condition.
        EXIT WHEN lv_counter > lv_sentinel;

        -- Repeating Statements.
        IF lv_elves.COUNT > 0 THEN
            dbms_output.put_line (
                '['||lv_counter||']['||lv_elves(lv_counter)||']');
        END IF;
    
    END LOOP;
END;
/

EXECUTE ascending(null,null,elf_table('Celeborn','Galadriel','Legolas'));


-- Skipping Iterations

DECLARE 
    lv_counter NUMBER := 0;
BEGIN   
    LOOP
        -- Index counter logic
        lv_counter := lv_counter + 1;

        -- Guard on entry statement
        EXIT WHEN lv_counter > 5;

        -- Repeatable statement for a continue on odd numbers.
        IF MOD(lv_counter,2) = 0 THEN
            CONTINUE;
        ELSE
            dbms_output.put_line('Index ['||lv_counter||'].');
        END IF;
    END LOOP;
END;
/


-- Range FOR Loop Statements

BEGIN
    FOR i IN REVERSE 1..3 LOOP
        dbms_output.put_line('Iteration ['||i||']');
    END LOOP;
END;
/

/*
WHILE { TRUE | NOT FALSE | { condition | condition | ... } } LOOP
    repeating_statements
    [ counter_management_statements ]
END LOOP;
*/

DECLARE
    lv_counter NUMBER := 1;
BEGIN
    WHILE (lv_counter < 3) LOOP
        dbms_output.put_line('Index ['||lv_counter||'].');
        lv_counter := lv_counter + 1;
    END LOOP;
END;
/


-- The ugly way

DECLARE
    /* Initialize one below the range */
    lv_counter NUMBER := 0;
BEGIN
    WHILE (lv_counter < 6) LOOP

    /* Must increment here to avoid an infinite loop when
        the logic for a CONTINUE statement is met. */
        lv_counter := lv_counter + 1;

    /* True for all even numbers - print only odd results. */
        IF MOD(lv_counter,2) = 0 THEN
            CONTINUE;
        ELSE
            dbms_output.put_line('Index ['||lv_counter||'].');
        END IF;
    END LOOP;
END;
/

DECLARE
    /* Initialize one below the range */
    lv_counter NUMBER := 0;
BEGIN
    WHILE (lv_counter < 6) LOOP
        /* Must increment here to avoid an infinite loop when
        the logic for a CONTINUE statement is met. */
        lv_counter := lv_counter + 1;

        /* Continue with an even number */
        CONTINUE WHEN MOD(lv_counter, 2) = 0;

        -- All printable statements
        dbms_output.put_line('Index ['||lv_counter||'].');
    END LOOP;
END;
/

-- GOTO statement for decrements

DECLARE
    lv_counter NUMBER := 6;
BEGIN
    WHILE (lv_counter > 0) LOOP
        -- True for all even numbers.
        IF MOD(lv_counter,2) = 0 THEN
            /* Must branch to the index counter logic to avoid
                an infinite loop. */
            GOTO decrement_index;
        ELSE    
            dbms_output.put_line('Index ['||lv_counter||'].');
        END IF;

        << decrement_index >>
        /* Decrement here for all iterations. */
        lv_counter := lv_counter -1;
    END LOOP;
END;
/

SET SERVEROUTPUT ON SIZE 1000000

DECLARE

  -- Declare a local record data type, with explicit data types
  -- (you could use %TYPE here too).
  TYPE title_type IS RECORD
  ( title     VARCHAR2(60)
  , subtitle  VARCHAR2(60)
  , rating    VARCHAR2(8));

  -- Declare a local variable of the local record structure data type.
  item_record TITLE_TYPE;

  -- Declare a static cursor.
  CURSOR c IS
    SELECT   i.item_title AS title
    ,        i.item_subtitle AS subtitle
    ,        i.item_rating AS rating
    FROM     item i;

BEGIN

  -- Open the cursor.
  OPEN c;

  -- Print a starting line.
  dbms_output.put_line('------------------------------------------------------------');

  -- Start the simple loop block.
  LOOP

    -- Fetch a row of the cursor and assign it to the local record structure variable.
    FETCH c
    INTO  item_record;

    -- Exit when there aren't any more records in the cursor. Without
    -- the EXIT, this would loop infinitely.
    EXIT WHEN c%NOTFOUND;

    -- Print the local variable elements to mimic MySQL \G equivalent.
    dbms_output.put_line('ITEM.ITEM_TITLE    ['||item_record.title||']');
    dbms_output.put_line('ITEM.ITEM_SUBTITLE ['||item_record.subtitle||']');
    dbms_output.put_line('ITEM.ITEM_RATING   ['||item_record.rating||']');

    -- Print an ending line.
   dbms_output.put_line('------------------------------------------------------------');

  END LOOP;

  -- Close the cursor and release the resources.
  CLOSE c;
END;
/

DECLARE

  -- Declare a static cursor.
  CURSOR c IS
    SELECT   i.item_title AS title
    ,        i.item_subtitle AS subtitle
    ,        i.item_rating AS rating
    FROM     item i;

BEGIN

  -- Print a starting line.
  dbms_output.put_line('------------------------------------------------------------');

  -- Start a cursor FOR loop block.
  FOR i IN c LOOP

    -- Print the local variable elements on a single line each to mimic MySQL \G equivalent.
    dbms_output.put_line('ITEM.ITEM_TITLE    ['||i.title||']');
    dbms_output.put_line('ITEM.ITEM_SUBTITLE ['||i.subtitle||']');
    dbms_output.put_line('ITEM.ITEM_RATING   ['||i.rating||']');

    -- Print an ending line.
   dbms_output.put_line('------------------------------------------------------------');

  END LOOP;
END;
/