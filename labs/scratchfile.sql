BEGIN
dbms_output.put_line('['||Goodbye||']');
END;
/

BEGIN
    :bind_variable := 'Hello Krypton.';
    dbms_output.put_line('['||:bind_variable||']');
END;
/

DECLARE
    lv_input VARCHAR2(30);
BEGIN   
    lv_input := :bind_variable;
    dbms_output.put_line('['||lv_input||']');
END;
/

BEGIN
    dbms_output.put_line('['||&input||']');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
/
--Enter value for input:

DECLARE
    lv_sample NUMBER;
BEGIN
    dbms_output.put_line('Value is ['||lv_sample||']');
END;
/
-- Value is []

DECLARE 
    lv_input VARCHAR2(10) := '&input';
BEGIN
    dbms_output.put_line('['||lv_input||']');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
/
-- cant use larger data lines

DECLARE
    lv_input VARCHAR2(10);
BEGIN
    lv_input := '&input';
    dbms_output.put_line('['||lv_input||']');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
/
-- ORA-06502: PL/SQL: numeric or value error: character string buffer too small

CREATE OR REPLACE FUNCTION hello_function
RETURN VARCHAR2
IS
BEGIN
    RETURN 'Hello World!';
END hello_function;
/

CREATE OR REPLACE PROCEDURE hello_procedure IS
    BEGIN
        dbms_output.put_line('Hello World!');
        END hello_procedure;
/

DECLARE
    lv_boolean  BOOLEAN;
    lv_number   NUMBER;
BEGIN
    IF NVL(lv_boolean,FALSE) THEN
        dbms_output.put_line('Prints when the variable is true.');
    ELSIF NVL((lv_number < 10),FALSE) THEN
        dbms_output.put_line('Prints when the expression is true');
    ELSE
        dbms_output.put_line('Prints when variables are null values.');
    END IF;
END;
/

DECLARE
    lv_selector VARCHAR2(20);
BEGIN
    lv_selector := '&input';
    CASE lv_selector
        WHEN 'Apple' THEN
            dbms_output.put_line('Is it a honey crisp apple?');
        WHEN 'Orange' THEN
            dbms_output.put_line('Is this a navel orange?');
        ELSE  
            dbms_output.put_line('It''s a ['||lv_selector||']?');
    END CASE;
END;
/

BEGIN
    CASE
        WHEN (1 <> 1) THEN
            dbms_output.put_line('Impossible!');
        WHEN (3 > 2) THEN
            dbms_output.put_line('A valid range comparison.');
        ELSE
            dbms_output.put_line('Never reached.');
    END CASE;
END;
/

-- FOR Loop Statements

BEGIN
    FOR i IN 0..9 Loop
        dbms_output.put_line('['||i||']['||TO_CHAR(i+1)||']');
    END LOOP;
END;
/

BEGIN
    FOR i IN (SELECT item_title FROM item) LOOP 
        dbms_output.put_line(i.item_title);
    END LOOP;
END;
/

DECLARE
    lv_search_string VARCHAR2(60);
    CURSOR c(cv_search VARCHAR2) IS
        SELECT  item_title
        FROM    item
        WHERE   REGEXP_LIKE(item_title,'^'||cv_search||'*+');
BEGIN
    FOR i IN c ('&input') LOOP
        dbms_output.put_line(i.item_title);
    END LOOP;
END;
/


DECLARE
    /* Declare a list of numbers. */
    TYPE list IS TABLE OF NUMBER;

    /* Declare a local variable of the type. */
    lv_list LIST := list(33,34,35,36,37,38,39);

    /* Declare an integer. */
    iterator INTEGER;
BEGIN
    /* Convert a dense index to a sparse index, which means
    you must iterate across the list like a linked list. */
    lv_list.DELETE(3);

    /* Initiate the iterator as the first index. */
    iterator := lv_list.FIRST;

    /* Check for the met condition. */
    WHILE (iterator < 6) LOOP
        /* Print index and list value. */
        dbms_output.put_line('Index '||CHR(38)||' Value ['||iterator||
                                ']['||lv_list(iterator)||']');

        /* Assign the iterator next value. */
        iterator := lv_list.NEXT(iterator);
    END LOOP;
END;
/


DECLARE
    /* Declare a list of numbers. */
    TYPE list IS TABLE OF NUMBER;

    /* Declare a local variable of the type. */
    lv_list  LIST := list(33,34,35,36,37,38,39);

    /* Declare an iterator. */
    iterator    INTEGER;
BEGIN  
    /* Initiate the iterator as the first index. */
    iterator := lv_list.FIRST;

    /* Loop when the iterator is less than or equal to 7. */
    WHILE (iterator <= 7) LOOP
        IF MOD(iterator,2) = 0 THEN
            /* Increment the index. */
            iterator := lv_list.NEXT(iterator);

            /* Skip further action on even index numbers. */
            CONTINUE;
        ELSE
            /* Print Odd iterator or index values. */
            dbms_output.put_line('Odd number indexes['||lv_list(iterator)||']');

            /* Increment the index. */
            iterator := lv_list.NEXT(iterator);
        END IF;
    END LOOP;
END;
/

DECLARE
    /* Declare a list of numbers. */
    TYPE list IS TABLE OF NUMBER;

    /* Declare a local variable of the type. */
    lv_list  LIST := list(33,34,35,36,37,38,39);

    /* Declare an iterator. */
    iterator    INTEGER;
BEGIN  
    /* Initiate the iterator as the first index. */
    iterator := lv_list.FIRST;

    WHILE (iterator <= 7) LOOP
        IF MOD(iterator,2) = 1 THEN
            /* Print the odd number message. */
            dbms_output.put_line('Odd number indexes['||lv_list(iterator)||']');

            /* Skip further action on even index numbers. */
            GOTO skippy;
        ELSE
            /* Skip further action on even index numbers. */
            GOTO skippy;
        END IF;

        /* GOTO place holder. */
        << skippy >>
        iterator := lv_list.NEXT(iterator);
    END LOOP;
END;
/

DECLARE
    /* Declare a list of numbers. */
    TYPE list IS TABLE OF NUMBER;

    /* Declare a local variable of the type. */
    lv_list LIST := list(33,34,35,36,37,38,39);

    /* Declare an iterator. */
    iterator INTEGER;
BEGIN
    /* Initiate the iterator as the first index. */
    iterator := lv_list.FIRST;

    WHILE (iterator <= 7) LOOP
        IF MOD(iterator,2) = 1 THEN
            /* Print the odd number message. */
            dbms_output.put_line('Odd number indexes['||lv_list(iterator)||']');
        END IF;

        /* GOTO place holder. */
        iterator := lv_list.NEXT(iterator);
    END LOOP;
END;
/

/* Simple Loop Statement */

BEGIN
    UPDATE  system_user
    SET     last_update_date = SYSDATE;
    IF SQL%FOUND THEN
        dbms_output.put_line('Updated ['||SQL%ROWCOUNT||']');
    ELSE
        dbms_output.put_line('Nothing updated!');
    END IF;
END;
/

DECLARE
    lv_id       item.item_id%TYPE;
    lv_title    VARCHAR2(60);
    CURSOR c    IS
        SELECT  item_id, item_title
        FROM    item;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO lv_id, lv_title;
                EXIT WHEN c%NOTFOUND;
                dbms_output.put_line('Title ['||lv_title||']');
    END LOOP;
    CLOSE c;
END;
/

SELECT      i.item_title
FROM        item i 
FETCH FIRST 1 ROWS ONLY;

SELECT
    d.name AS database_name,
    i.instance_name,
    i.host_name
FROM v$database d
CROSS JOIN v$instance i;
/
