SET SERVEROUTPUT ON

VARIABLE whom VARCHAR2(50)

/* After you declare a variable in SQL*Plus, write an anonymous block that 
uses an if-statement to determine whether the :whom variable is null or not. 
When it is null you print "Hello World!" and when it is not null, you print 
"Hello <someOne>!". */

BEGIN
    IF :whom IS NULL THEN
        dbms_output.put_line('Hello World!');
    ELSE
        dbms_output.put_line('Hello ' || :whom || '!');
    END IF;
END;
/

/* Assign a value to the :whom session bind variable in a PL/SQL anonymous block, 
like this: */

BEGIN
    :whom := 'Gideon';
END;
/