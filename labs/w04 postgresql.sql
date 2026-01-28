/* Declarations 
*/

CREATE OR REPLACE FUNCTION somefunc() RETURNS integer AS $$
<< outerblock >>
DECLARE
	quantity integer := 30;
BEGIN
	RAISE NOTICE 'Quantity here is %', quantity; -- Prints 30
	quantity := 50;
	--
    -- Create a subblock
    --
	DECLARE
		quantity integer := 80;
	BEGIN
		RAISE NOTICE 'Quantity here is %', quantity; -- Prints 80
		RAISE NOTICE 'Outer quantity here is %', outerblock.quantity; -- Prints 50
	END;

	RAISE NOTICE 'Quantity here is %', quantity; -- Prints 50

	RETURN quantity;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE OR REPLACE FUNCTION sales_tax(subtotal real) RETURNS real AS $$
BEGIN
	RETURN subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE OR REPLACE FUNCTION sum_n_product(x int, y int, OUT sum int, OUT prod int) AS $$
BEGIN
	sum := x + y;
	prod := x * y;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE PROCEDURE sm_n_product(x int, y int, OUT sum int, OUT prod int) AS $$
BEGIN
	sum := x + y;
	prod := x * y;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE FUNCTION extended_sales(p_itemno int)
RETURNS TABLE(quantity int, total numeric) AS $$
BEGIN
	RETURN QUERY SELECT s.quantity, s.quantity * s.price FROM sales AS s
				WHERE s.itemno = p_itemno;
END;
$$ LANGUAGE plpgsql;

--------------

CREATE FUNCTION add_three_values(v1 anyelement, v2 anyelement, v3 anyelement)
RETURNS anyelement AS $$
DECLARE
	result ALIAS FOR $0;
BEGIN
	result := v1 + v2 + v3;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT somefunc();

SELECT sales_tax(59.38);

SELECT * FROM sum_n_product(2, 4);

CALL sm_n_product(2, 4, NULL, NULL);

SELECT add_three_values(1, 2, 4.7);


/* Basic Statements */

