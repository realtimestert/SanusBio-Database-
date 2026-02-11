
CREATE TABLE sal_emp (
	name			text,
	pay_by_quarter	integer[],
	schedule		text[][]
);

CREATE TABLE tictactoe (
	squares		integer[3][3]
);

INSERT INTO sal_emp
	VALUES ('Bill',
	'{10000, 10000, 10000, 10000}',
	'{{"meeting", "lunch"}, {"training", "presentation"}}');

INSERT INTO sal_emp
	VALUES ('Carol',
	'{20000, 25000, 25000, 25000}',
	'{{"breakfast", "consulting"}, {"meeting", "lunch"}}');

SELECT * FROM sal_emp;

SELECT name FROM sal_emp WHERE pay_by_quarter[1] <> pay_by_quarter[2];
-- Carol

SELECT pay_by_quarter[3] FROM sal_emp;

SELECT schedule[1:2][1:1] FROM sal_emp WHERE name = 'Bill';

SELECT schedule[1:2][2] FROM sal_emp WHERE name = 'Bill';

SELECT schedule[:2][2:] FROM sal_emp WHERE name = 'Bill';

SELECT schedule[:][1:1] FROM sal_emp WHERE name = 'Bill';

SELECT array_dims(schedule) FROM sal_emp WHERE name = 'Carol';

SELECT array_upper(schedule, 1) FROM sal_emp WHERE name = 'Carol';

SELECT array_length(schedule, 1) FROM sal_emp WHERE name = 'Carol';

SELECT cardinality(schedule) FROM sal_emp WHERE name = 'Carol';

UPDATE sal_emp SET pay_by_quarter = '{25000, 25000, 27000, 27000}'
	WHERE name = 'Carol';

UPDATE sal_emp SET pay_by_quarter[4] = 15000
	WHERE name = 'Bill';

SELECT ARRAY[1,2] || ARRAY[3,4];
-- ?column?

SELECT ARRAY[5,6] || ARRAY[[1,2],[3,4]];

SELECT array_dims(1 || '[0:1]={2,3}'::int[]);

SELECT array_dims(ARRAY[1,2] || 3);

SELECT array_dims(ARRAY[1,2] || ARRAY[3,4,5]);

SELECT array_dims(ARRAY[[1,2],[3,4]] || ARRAY[[5,6],[7,8],[9,0]]);

SELECT array_dims(ARRAY[1,2] || ARRAY[[3,4],[5,6]]); -- concatenation

SELECT array_cat(ARRAY[1,2], ARRAY[3,4]);

SELECT array_cat(ARRAY[[1,2],[3,4]], ARRAY[5,6]);

SELECT ARRAY[1, 2] || '{3, 4}';

SELECT * FROM sal_emp WHERE pay_by_quarter[1] = 10000 OR
                            pay_by_quarter[2] = 10000 OR
                            pay_by_quarter[3] = 10000 OR
                            pay_by_quarter[4] = 10000;

SELECT * FROM sal_emp WHERE 10000 = ANY (pay_by_quarter);

SELECT * FROM
   (SELECT pay_by_quarter,
           generate_subscripts(pay_by_quarter, 1) AS s
      FROM sal_emp) AS foo
 WHERE pay_by_quarter[s] = 10000;

 SELECT * FROM sal_emp WHERE pay_by_quarter && ARRAY[10000];

 SELECT array_position(ARRAY['sun','mon','tue','wed','thu','fri','sat'], 'tue');

 SELECT array_positions(ARRAY[1, 4, 3, 1, 3, 4, 2, 1], 3);
 -- array_positions {3,5}

SELECT f1[1][-2][3] AS e1, f1[1][-1][5] AS e2
 FROM (SELECT '[1:1][-2:-1][3:5]={{{1,2,3},{4,5,6}}}'::int[] AS f1) AS ss;
 

DROP TABLE IF EXISTS demo;

CREATE TABLE demo
( demo_id		serial
, demo_number	integer[5]
, demo_string varchar(5)[7]);

INSERT INTO demo
(demo_number, demo_string)
VALUES
( array[1,2,3,4,5]
, array['One','Two','Three','Four','Five','Six','Seven']);

SELECT 	unnest(demo_number) AS numbers
,		unnest(demo_string) AS strings
FROM demo;

DROP TYPE IF EXISTS player;

CREATE TYPE player AS
( player_no			integer
, player_name		varchar(24)
, player_position	varchar(14)
, ab				integer
, r					integer
, h					integer
, bb				integer
, rbi				integer );



-- Nested Tables
DROP TABLE IF EXISTS world_series;

CREATE TABLE world_series
( world_series_id	serial
, team				varchar(24)
, players			player[30]
, game_no			integer
, year				integer );

INSERT INTO world_series
( team
, players
, game_no
, year )
VALUES
('San Francisco Giants'
, array[(24,'Willie Mayes','Center Fielder',5,0,1,0,0)::player
	,(5,'Tom Haller','Catcher',4,1,2,0,2)::player]
, 4
, 1962 );

UPDATE world_series
SET    players = (SELECT array_append(players,(7,'Henry Kuenn','Right Fielder',3,0,0,1,0)::player) FROM world_series)
WHERE  team = 'San Francisco Giants'
AND    year = 1962
AND    game_no = 4;

SELECT unnest(players) AS player_list
FROM   world_series
WHERE  team = 'San Francisco Giants'
AND    year = 1962
AND    game_no = 4;

WITH list AS
 (SELECT unnest(players) AS row_result
  FROM   world_series
  WHERE  team = 'San Francisco Giants'
  AND    year = 1962
  AND    game_no = 4)
SELECT  (row_result).player_name
,       (row_result).player_no
,       (row_result).player_position
FROM     list;

WITH list AS
	(SELECT unnest(players) AS row_result
	 FROM	world_series
	 WHERE	team = 'San Francisco Giants'
	 AND 	year = 1962
	 AND	game_no = 4)
SELECT	(row_result).player_name
,		(row_result).player_no
,		(row_result).player_position
FROM	list;

/* 
 player_name  | player_no | player_position
--------------+-----------+-----------------
 Willie Mayes |        24 | Center Fielder
 Tom Haller   |         5 | Catcher
 Henry Kuenn  |         7 | Right Fielder
(3 rows)
*/

WITH list AS
 (SELECT game_no AS game
  ,      year
  ,      unnest(players) AS row_result
  FROM   world_series
  WHERE  team = 'San Francisco Giants'
  AND    year = 1962
  AND    game_no = 4)
SELECT   game
,        year 
,       (row_result).player_name
,       (row_result).player_no
,       (row_result).player_position
FROM     list;

DO
$$
DECLARE
	/* An array of integers */
	list int[] = array[1,2,3,4,5];
	/* Define a local variable for array members. */
	i	int;
BEGIN	
	/* Loop through the integers. */
	FOREACH i IN ARRAY list LOOP
		RAISE NOTICE '[%]', i;
	END LOOP;
END;
$$;

DO
$$
DECLARE
	/* An array of integers */
	list int[] = array[1,2,3,4,5];
BEGIN
	/* Loop through the integers */
	FOR i IN 1..CARDINALITY(list) LOOP
		RAISE NOTICE '[%]', list[i];
	END LOOP;
END;
$$;


-------------
-- Tutorial 3
-------------

CREATE TYPE full_name AS
( first_name	VARCHAR(20)
, middle_name	VARCHAR(20)
, last_name		VARCHAR(20));

DO
$$
DECLARE
	-- An array of full_name records.
	list full_name[]=
		array[('Harry','James','Potter')
               ,('Ginevra','Molly','Potter')
               ,('James','Sirius','Potter')
               ,('Albus','Severus','Potter')
               ,('Lily','Luna','Potter')];
BEGIN
	-- Loop through the integers
	FOR i IN 1..CARDINALITY(list) LOOP
		RAISE NOTICE '%, % %', list[i].last_name, list[i].first_name, list[i].middle_name;
	END LOOP;
END;
$$;

/*
NOTICE:  Potter, Harry James
NOTICE:  Potter, Ginevra Molly
NOTICE:  Potter, James Sirius
NOTICE:  Potter, Albus Severus
NOTICE:  Potter, Lily Luna
DO
*/

------------------
-- Tutorial 4 ----
------------------


DO
$$
DECLARE
  /* Declare an array of integers with a subordinate array of integers. */
  list  int[][] = array[array[1,2,3,4]
                       ,array[1,2,3,4]
                       ,array[1,2,3,4]
                       ,array[1,2,3,4]
                       ,array[1,2,3,4]];
  row   varchar(20) = '';
BEGIN
  /* Loop through the first dimension of integers. */
  <>
  FOR i IN 1..ARRAY_LENGTH(list,1) LOOP
    row = '';
    /* Loop through the second dimension of integers. */
    <>
    FOR j IN 1..ARRAY_LENGTH(list,2) LOOP
      IF LENGTH(row) = 0 THEN
        row = row || list[i][j];
      ELSE
        row = row || ',' || list[i][j];
      END IF;
    END LOOP;
    /* Exit outer loop. */
    RAISE NOTICE 'Row [%][%]', i, row;
  END LOOP;
END;
$$;
