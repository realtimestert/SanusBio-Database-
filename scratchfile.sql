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