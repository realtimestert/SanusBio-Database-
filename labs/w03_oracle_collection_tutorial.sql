CREATE OR REPLACE
    TYPE sql_table IS TABLE OF VARCHAR2(20);
/

SELECT      column_value AS "Dúnedain"
FROM        TABLE(sql_table('Aragron','Faramir','Boromir'))
ORDER BY 1;

CREATE OR REPLACE FUNCTION add_element
    ( pv_table SQL_TABLE 
    , pv_element VARCHAR2 ) RETURN SQL_TABLE IS

        lv_table    SQL_TABLE