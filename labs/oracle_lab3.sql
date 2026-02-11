SET SERVEROUTPUT ON SIZE UNLIMITED

BEGIN
    -- Ascending Loop
    FOR i IN 1..10 LOOP
        dbms_output.put_line('[' || i || ']');
    END LOOP;

    -- Descending Loop
    FOR i IN REVERSE 1..10 LOOP
        dbms_output.put_line('[' || i || ']');
    END LOOP;
END;
/