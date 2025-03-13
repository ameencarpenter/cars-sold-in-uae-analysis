-- select the desired database.
use uae_cars;

-- create a copy to not miss the original data.
DROP TABLE IF EXISTS cars;
CREATE TABLE cars LIKE drivearabia_all_uae;
INSERT INTO cars SELECT * FROM drivearabia_all_uae;

-- review column names.
SHOW COLUMNS FROM cars;

ALTER TABLE cars
	DROP COLUMN Link,
    DROP COLUMN `Body Type`,
    DROP COLUMN `Additional Type`,
    DROP COLUMN Weight,
    DROP COLUMN `Gear box`,
    DROP COLUMN `Power (hp)`,
    DROP COLUMN `Torque (Nm)`,
    DROP COLUMN `Fuel Econ (L/100km)`,
    DROP COLUMN `Fuel Econ (km/L)`,
    DROP COLUMN `Performance 0-100 kph (sec)`,
    DROP COLUMN `Sale Country`;

-- change column names to follow best practices for naming conventions.
ALTER TABLE cars 
	RENAME COLUMN `Approx Cost` to approx_cost,
    RENAME COLUMN `Origin Country` to origin_country,
    RENAME COLUMN `Sale Country` to sale_country,
    RENAME COLUMN `Manufacturer` to manufacturer,
    RENAME COLUMN `Brand` to brand,
    RENAME COLUMN `Model Year` to model_year,
    RENAME COLUMN `top speed (kph)` to top_speed_kph;
-- -------------------------------------------average cost----------------------------------------------------------------------------

-- add working column to not miss the original one
ALTER TABLE cars ADD COLUMN average_cost VARCHAR(255);
UPDATE cars SET average_cost = approx_cost;
-- remove the "AED" at first.
UPDATE cars SET average_cost = replace(average_cost, 'AED', '');
-- remove the "(" and everything that follows.
UPDATE cars SET average_cost = SUBSTRING_INDEX(average_cost, '(', 1);
-- remove any spaces.
UPDATE cars SET average_cost = replace(average_cost, ' ', '');

-- remove commas so we can convert numbers to integers.
update cars set average_cost = replace(average_cost, ',', '');

delete from cars where average_cost in ('NotSoldinUAE','NotSoldinUAE.', 'NotSold', 'ComingSoon', 'NotSoldHere');

UPDATE cars	SET average_cost = "78900-80000" where average_cost = "GAC78900-80000";

UPDATE cars SET average_cost = "99900-99900" where average_cost = "99900";

-- make sure all values are formatted correctly. should shouldn't match any row.
SELECT distinct(average_cost) FROM cars WHERE average_cost NOT REGEXP '^[0-9]+-[0-9]+$';

ALTER TABLE cars ADD COLUMN average_cost_int INT;

update cars set average_cost_int = (cast(substring_index(average_cost, '-', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(average_cost, '-', -1) AS unsigned)) / 2 ;

ALTER TABLE cars DROP COLUMN approx_cost, DROP COLUMN average_cost, RENAME COLUMN average_cost_int TO average_cost;

-- -------------------------------------------origing country----------------------------------------------------------------------------------------------------------------------
-- remove extra speces.
update cars set origin_country = TRIM(origin_country);

-- standardize the united states name because an entry has a dot at the end.
update cars set origin_country = "United States" where origin_country = "United States.";

-- Origin Country is "2020". I googled the manufacturer and brand to find out the origin country. turns out it's united states
update cars set origin_country = "United States" where manufacturer = "Cadillac" and brand = "ct5-v";

-- -----------------------------------------------------------model year--------------------------------------------------------------------------------------------------
-- make sure all values are integers.
SELECT model_year FROM cars WHERE model_year NOT REGEXP '^[0-9]+$';
-- change it to integer column.
ALTER TABLE cars MODIFY COLUMN model_year INT;
--  ---------------------------------------------------------speed ---------------------------------------------------------------------------
-- remove edge spaces
update cars set top_speed_kph = trim(top_speed_kph);
-- remove tabs
update cars set top_speed_kph = replace(top_speed_kph, '\t', '');
-- remove new lines
update cars set top_speed_kph = replace(top_speed_kph, '\n', '');
-- remove returns
update cars set top_speed_kph = replace(top_speed_kph, '\r', '');
-- remove stars
update cars set top_speed_kph = replace(top_speed_kph, '*', '');
-- specific case
update cars set top_speed_kph = "220" where top_speed_kph = "220.22";
-- make all numbers in the same format.
update cars set top_speed_kph = concat(top_speed_kph, "-", top_speed_kph) where top_speed_kph regexp '^[0-9]+$';
-- this should return nothing;
select distinct(top_speed_kph) from cars where top_speed_kph not regexp '^[0-9]+-[0-9]+$' order by top_speed_kph;

ALTER TABLE cars ADD COLUMN top_speed_kph_int INT;

update cars set top_speed_kph_int = (cast(substring_index(top_speed_kph, '-', 1) AS UNSIGNED) + CAST(SUBSTRING_INDEX(top_speed_kph, '-', -1) AS unsigned)) / 2 ;

ALTER TABLE cars DROP COLUMN top_speed_kph, RENAME COLUMN top_speed_kph_int TO top_speed_kph;
-- -------------------------------------------------------------------analysis-----------------------------------------------
-- top 10 most expensive cars
select concat(manufacturer, " ", brand, " - ", model_year) as car, format(average_cost, 0) as price from cars order by average_cost desc limit 10;

-- top 10 cheapest cars
select concat(manufacturer, " ", brand, " - ", model_year) as car, format(average_cost, 0) as price from cars order by average_cost asc limit 10;

-- top 10 fastest cars
select * from cars order by top_speed_kph desc limit 10;

-- average car per company
select manufacturer,  format(avg(average_cost),0) as average_price from cars group by manufacturer order by avg(average_cost);

-- total sold for each country
select origin_country, format(sum(average_cost),0) from cars group by origin_country order by sum(average_cost) desc;

-- # of cars sold per manufacturer
select manufacturer, format(count(manufacturer),0) from cars group by manufacturer order by count(manufacturer) desc limit 10;

select * from cars;
