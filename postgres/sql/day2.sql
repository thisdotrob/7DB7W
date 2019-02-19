INSERT INTO cities (name,postal_code,country_code)
  VALUES ('Caversham','RG67JJ','gb');

INSERT INTO venues (name,street_address,postal_code,country_code)
  VALUES ('My Place','11 Some Road','RG67JJ','gb');

INSERT INTO events (title, starts, ends, venue_id)
  VALUES ('Wedding','2018-02-26 21:00:00','2018-02-26 23:00:00', (
      SELECT venue_id
      FROM venues
      WHERE name = 'Voodoo Doughnut'
    )
  ),
  ('Dinner with Mum','2018-02-26 18:00:00','2018-02-26 20:30:00', (
      SELECT venue_id
      FROM venues
      WHERE name = 'My Place'
    )
  ),
  ('Valentine''s day','2018-02-14 00:00:00','2018-02-14 23:59:00',null);

-- use aggregate query to show count of events containing 'Day':
SELECT count(title)
FROM events
WHERE title LIKE '%Day%';
-- count
---------
--     2
--(1 row)

-- get first start time, last end time of all events at the Voodoo Doughnut:
SELECT min(starts), max(ends)
FROM events
WHERE venue_id = (
  SELECT venue_id
  FROM venues
  WHERE name = 'Voodoo Doughnut'
);
--         min         |         max
-----------------------+---------------------
-- 2018-02-15 17:30:00 | 2018-02-26 23:00:00
--(1 row)

-- count all events at each venue:
SELECT venue_id, count(*)
FROM events
GROUP BY venue_id;
-- venue_id | count
------------+-------
--          |     3
--        3 |     1
--        2 |     2
--(3 rows)

SELECT venue_id, count(*)
FROM events
GROUP BY venue_id
HAVING count(*) > 1 AND venue_id IS NOT NULL;
-- venue_id | count
------------+-------
--        2 |     2
--(1 row)

SELECT venue_id FROM events GROUP BY venue_id;
-- venue_id
------------
--
--        3
--        2
--(3 rows)

-- can also be written as:
SELECT DISTINCT venue_id FROM events;

-- window functions are like GROUP BY queries (they let you run aggregate
-- functions) but don't require every single field to be grouped to a single row.

-- this errors because we have selected the title column without grouping
-- by it:
--SELECT title, venue_id, count(*)
--FROM events
--GROUP BY venue_id;
--psql:/sql/day2.sql:82: ERROR:  column "events.title" must appear in the GROUP BY clause or be used in an aggregate function
--LINE 1: SELECT title, venue_id, count(*)

-- window function version:
SELECT title, venue_id, count(*)
OVER (PARTITION BY venue_id)
FROM events
ORDER BY venue_id;
--      title      | venue_id | count
-------------------+----------+-------
-- Fight Club      |        2 |     2
-- Wedding         |        2 |     2
-- Dinner with Mum |        3 |     1
-- April Fools Day |          |     3
-- Christmas Day   |          |     3
-- Valentine's day |          |     3
--(6 rows)

SELECT title, count(*)
OVER (PARTITION BY venue_id) FROM events;
--      title      | count
-------------------+-------
-- Fight Club      |     2
-- Wedding         |     2
-- Dinner with Mum |     1
-- April Fools Day |     3
-- Christmas Day   |     3
-- Valentine's day |     3
--(6 rows)

-- Transactions
-- Commands are implicitly wrapped in a transaction in postgres.
-- Are the way postgres guarantees consistency.
-- If transaction fails part way through commands, they are all rolled back.
-- Postgres transactions follow ACID compliance (atomic, consistent, independent,
--     durable).
-- Manual transactions are useful when modifying two tables you don't want out of
-- sync, e.g. debiting from one account & crediting in another.

BEGIN TRANSACTION;
  DELETE FROM events;
SELECT * FROM events;
ROLLBACK;
SELECT * FROM events;

-- SQL alone sometimes allow us to achieve everything we need to - more code needed.
-- Can run this code in Postgres or on application side. If using postgres, do so
-- using 'stored procedures'.

-- Can give huge performance advantages, but archiectural costs can be high (binding
-- application code to the DB). 'No logic in the database' maxim started mainly as
-- a response to vendor lock in problems in 90's.

-- This is a stored procedure that will create a venue if doesn't exist already when
-- inserting a new event, returning a boolean to indicate whether a new venue was
-- needed.
CREATE OR REPLACE FUNCTION add_event(
  title text,
  starts timestamp,
  ends timestamp,
  venue text,
  postal varchar(9),
  country char(2))
RETURNS boolean AS $$
DECLARE
  did_insert boolean := false;
  found_count integer;
  the_venue_id integer;
BEGIN
  SELECT venue_id INTO the_venue_id
  FROM venues v
  WHERE v.postal_code=postal AND v.country_code=country AND v.name ILIKE venue
  LIMIT 1;

  IF the_venue_id IS NULL THEN
    RAISE NOTICE 'Venue not found, will create';
    INSERT INTO venues (name, postal_code, country_code)
    VALUES (venue, postal, country)
    RETURNING venue_id INTO the_venue_id;

    did_insert := true;
  ELSE
    RAISE NOTICE 'Venue found %', the_venue_id;
  END IF;

  INSERT INTO events (title, starts, ends, venue_id)
  VALUES (title, starts, ends, the_venue_id);

  RETURN did_insert;
END;
$$ LANGUAGE plpgsql;

SELECT add_event('House Party', '2019-05-03 23:00',
  '2019-05-04 02:00', 'Run''s House', '97206', 'us');

SELECT add_event('House Party 2', '2019-05-10 23:00',
  '2019-05-11 02:00', 'Run''s House', '97206', 'us');

-- table to record changes to events
CREATE TABLE logs (
  event_id integer,
  old_title varchar(255),
  old_starts timestamp,
  old_ends timestamp,
  logged_at timestamp DEFAULT current_timestamp
);

-- function to insert old data into the log
CREATE OR REPLACE FUNCTION log_event() RETURNS trigger AS $$
DECLARE
BEGIN
  INSERT INTO logs (event_id, old_title, old_starts, old_ends)
  VALUES (OLD.event_id, OLD.title, OLD.starts, OLD.ends);
  RAISE NOTICE 'Someone just changed event #%', OLD.event_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger to log changes after any row is updated
CREATE TRIGGER log_events
  AFTER UPDATE ON events
  FOR EACH ROW EXECUTE PROCEDURE log_event();

UPDATE events
SET ends='2019-05-04 01:00:00'
WHERE title='House Party';
