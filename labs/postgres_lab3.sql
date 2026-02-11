DO
$$
BEGIN
  /* Ascending loops. */
  FOR i IN 1..10 LOOP
    RAISE NOTICE '[%]', i;
  END LOOP;

  /* Descending loop. */
  FOR i IN REVERSE 1..10 LOOP
    RAISE NOTICE '[%]', i;
  END LOOP;
END;
$$;

/* In pgAdmin I cannot get the proper results for the reverse loop */