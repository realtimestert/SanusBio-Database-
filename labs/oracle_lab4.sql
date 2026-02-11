-- A sample adding function that takes two parameters and returns the sum.

/* Drop table unconditionally. */
DROP FUNCTION adding;

/* Create an adding function. */
CREATE OR REPLACE
  FUNCTION adding
  ( a NUMBER
  , b NUMBER ) RETURN NUMBER DETERMINISTIC IS
  BEGIN
    RETURN a + b;
  END;
/


-- Call the adding function
/* An anonymous block must declare the variables and call the function. */
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Declare the variables. */
  a  NUMBER := 2;
  b  NUMBER := 2;
BEGIN
  /* Call, round, and print the return value from the npv deterministic function. */
  dbms_output.put_line('The result ['||adding(a,b)||'].');
END;
/


CREATE OR REPLACE   
    FUNCTION npv
    ( future_value  NUMBER
    , periods       INTEGER
    , interest      NUMBER )
    RETURN NUMBER DETERMINISTIC IS
        lv_result NUMBER;
    BEGIN
        lv_result := future_value / POWER(1 + interest, periods);
        RETURN lv_result;
    END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE npv_result NUMBER;
BEGIN
  /* Call, round, and print the return value from the npv deterministic function. */
    SELECT npv(500, 12, 0.08) 
        INTO npv_result 
        FROM dual;

    dbms_output.put_line('npv = ' || ROUND(npv_result, 2)); 
    -- Rounding!@
END;
/