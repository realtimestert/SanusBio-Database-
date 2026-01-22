SET SESSION "videodb.whom" = '';

DO
$$
BEGIN
  /* Print a session variable value or the default value. */
  IF current_setting('videodb.whom') IS NOT NULL THEN
    RAISE NOTICE '[%]', current_setting('videodb.whom');
  ELSE
    RAISE NOTICE '[%]','Hello World!';
  END IF;
END;
$$;

SET SESSION "videodb.whom" = 'Gideon';

DO
$$
BEGIN
  /* Print a session variable value or the default value. */
  IF current_setting('videodb.whom') IS NOT NULL THEN
    RAISE NOTICE '[%]', current_setting('videodb.whom');
  ELSE
    RAISE NOTICE '[%]','Hello World!';
  END IF;
END;
$$;

/* Declare a session variable. */
SET SESSION "videodb.whom" = '';

/* Test case when session bind variable is null. */
DO
$$
BEGIN
  /* Print a session variable value or the default value. */
  IF current_setting('videodb.whom') IS NOT NULL THEN
    RAISE NOTICE '[%]', current_setting('videodb.whom');
  ELSE
    RAISE NOTICE '[%]','Hello World!';
  END IF;
END;
$$;

/* Set the session bind variable with a value. */
SET SESSION <<<element>>>;


/* Test case when session bind variable is not null. */
DO
$$
BEGIN
  /* Print a session variable value or the default value. */
  IF current_setting('videodb.whom') IS NOT NULL THEN
    RAISE NOTICE '[%]', current_setting('videodb.whom');
  ELSE
    RAISE NOTICE '[%]','Hello World!';
  END IF;
END;
$$;