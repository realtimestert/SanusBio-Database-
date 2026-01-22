DO
$$
DECLARE
  lv_counter INTEGER := 1;
BEGIN
  /* Ascending loops. */
  WHILE lv_counter < 11 LOOP
    RAISE NOTICE '[%]', lv_counter;
    lv_counter = lv_counter + 1;
  END LOOP;

  /* Descending loop. */
  lv_counter := 10;
  WHILE lv_counter > 0 LOOP
    RASIE NOTICE '[%]', lv_counter;
    lv_counter := lv_counter - 1;
  END LOOP;
END;
$$;