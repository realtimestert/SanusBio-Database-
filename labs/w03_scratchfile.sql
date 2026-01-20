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
    lv_counter := NVL(pv_index,1);

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
