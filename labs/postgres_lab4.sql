CREATE OR REPLACE
  FUNCTION npv
  ( future_value  decimal
  , periods       integer
  , interest      decimal )
  RETURNS decimal AS
  $$
  DECLARE
    /* Declare a result variable. */
    lv_result decimal;
  BEGIN
    /* Calculate the result and round it to the nearest penny and assign it to a local variable. */
    lv_result := ROUND(
		future_value / POWER(1 + interest, periods),
		2
	);
	
    /* Return the calculated result. */
    RETURN lv_result;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

DO
$$
DECLARE
  /* Declare inputs by data type. */
  lv_future_value decimal := 100.58;
  lv_periods      integer := 2;
  lv_interest     decimal := 0.09;

  /* Result variable. */
  lv_result       decimal;
BEGIN
  /* Call function and assign value. */
  lv_result := npv(lv_future_value, lv_periods, lv_interest);
  
  /* Display value. */
  RAISE NOTICE 'Net Present Value is %', lv_result;
END;
$$;