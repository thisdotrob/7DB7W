CREATE TABLE countries (
  country_code char(2) PRIMARY KEY,
  country_name text unique
);

INSERT INTO countries
VALUES ('us','United States'),('mx','Mexico'),('au','Australia'),
       ('gb','United Kingdom'),('de','Germany'),('ll','Loompaland');

/*INSERT INTO countries (country_code, country_name)
VALUES ('gb','United Kingdom');
ERROR:  duplicate key value violates unique constraint "countries_pkey" */

SELECT *
FROM countries;

DELETE FROM countries
WHERE country_code = 'll';

CREATE TABLE cities (
  name text NOT NULL,
  postal_code varchar(9) CHECK (postal_code <> ''),
  country_code char(2) REFERENCES countries,
  PRIMARY KEY (country_code, postal_code)
);

/*INSERT INTO cities
VALUES ('Toronto','M4C1B5','ca');
ERROR:  insert or update on table "cities" violates foreign key constraint "cities_country_code_fkey"
DETAIL:  Key (country_code)=(ca) is not present in table "countries".*/

INSERT INTO cities
VALUES ('Portland','87200','us');

UPDATE cities
SET postal_code = '97206'
WHERE name = 'Portland';

SELECT cities.*, country_name
FROM cities INNER JOIN countries
ON cities.country_code = countries.country_code;

CREATE TABLE venues (
  venue_id SERIAL PRIMARY KEY,
  name varchar(255),
  street_address text,
  type varchar(7) CHECK ( type in ('public','private') ) DEFAULT 'public',
  postal_code varchar(9),
  country_code char(2),
  FOREIGN KEY (country_code, postal_code) REFERENCES cities (country_code, postal_code) MATCH FULL
);

INSERT INTO venues (name, postal_code, country_code)
VALUES ('Crystal Ballroom','97206','us');

SELECT venue_id, v.name, c.name
FROM venues v INNER JOIN cities c
ON v.postal_code = c.postal_code AND v.country_code = c.country_code;

INSERT INTO venues (name, postal_code, country_code)
VALUES ('Voodoo Doughnut','97206','us') RETURNING venue_id;

CREATE TABLE events (
  event_id SERIAL PRIMARY KEY,
  title text,
  starts timestamp,
  ends timestamp,
  venue_id integer REFERENCES venues
);

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Fight Club', '2018-02-15 17:30:00', '2018-02-15 19:30:00', 2),
       ('April Fools Day', '2018-04-01 00:00:00', '2018-04-01 23:59:00', null),
       ('Christmas Day', '2018-12-25 19:30:00', '2018-12-25 23:59:00', null);

-- only events with venues
SELECT e.title, v.name
FROM events e INNER JOIN venues v
ON e.venue_id = v.venue_id;
--   title    |      name       
--------------+-----------------
-- Fight Club | Voodoo Doughnut
--(1 row)

-- all events and matching venues
SELECT e.title, v.name
FROM events e LEFT OUTER JOIN venues v
ON e.venue_id = v.venue_id;
--      title      |      name       
-------------------+-----------------
-- Fight Club      | Voodoo Doughnut
-- April Fools Day | 
-- Christmas Day   | 
--(3 rows)

-- all venues and matching events
SELECT e.title, v.name
FROM events e RIGHT OUTER JOIN venues v
ON e.venue_id = v.venue_id;
--   title    |       name       
--------------+------------------
-- Fight Club | Voodoo Doughnut
--            | Crystal Ballroom
--(2 rows)

-- all venues and all events
SELECT e.title, v.name
FROM events e FULL JOIN venues v
ON e.venue_id = v.venue_id;
--      title      |       name       
-------------------+------------------
-- Fight Club      | Voodoo Doughnut
-- April Fools Day | 
-- Christmas Day   | 
--                 | Crystal Ballroom
--(4 rows)

-- create hash index
CREATE INDEX events_title
ON events USING hash (title);

-- create b-tree index on start date
CREATE INDEX events_starts
ON events USING btree (starts);

-- find all events on or after April 1
SELECT *
FROM events
WHERE starts >= '2018-04-01';
-- event_id |      title      |       starts        |        ends         | venue_id 
------------+-----------------+---------------------+---------------------+----------
--        2 | April Fools Day | 2018-04-01 00:00:00 | 2018-04-01 23:59:00 |         
--        3 | Christmas Day   | 2018-12-25 19:30:00 | 2018-12-25 23:59:00 |         
--(2 rows)

SELECT x.country_name
FROM events e LEFT JOIN (SELECT c.country_name, v.venue_id FROM venues v JOIN countries c ON v.country_code = c.country_code) x
ON e.venue_id = x.venue_id
WHERE e.title = 'Fight Club';

ALTER TABLE venues
ADD COLUMN active Boolean DEFAULT TRUE;
