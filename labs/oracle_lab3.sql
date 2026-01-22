SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    lv_counter NUMBER := 1;
BEGIN
    -- Ascending Loop
    WHILE (lv_counter < 11) LOOP
        dbms_output.put_line('['||lv_counter||']');
        lv_counter := lv_counter + 1;
        EXIT WHEN lv_counter = 11;
    END LOOP;

    -- Descending Loop
    lv_counter := 10;
    LOOP
        dbms_output.put_line('['||lv_counter||']');
        lv_counter := lv_counter -1;
        EXIT WHEN lv_counter = 0;
    END LOOP;
END;
/