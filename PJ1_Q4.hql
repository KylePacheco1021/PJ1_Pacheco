--Some notes:
--Most popular internet usage times are from 7pm-9pm
--US TIMEZONES:
--EDT -> UTC: 23, 00, 01
--CDT -> UTC: 00, 01, 02
--MDT -> UTC: 01, 02, 03
--PDT -> UTC: 02, 03, 04
--UK TIMEZONES:
--UTC 19, 20, 21
--AUS TIMEZONES:
--AEDT -> UTC: 08, 09, 10
--AWST -> UTC: 11, 12, 13
--90% of US population has broadband internet -> 298.38 mil use internet in US
--96% of UK population has broadband internet -> 63.984 mil use internet in UK
--88% of AUS population has broadband internet -> 21.9912 mil use internet in AUS -> Approximately 91% of those people live on either east coast or west coast -> 20.012 mil use internet in these timezones


CREATE DATABASE Q4_DB;

USE Q4_DB;

--Creating tables for each area

CREATE TABLE US_PAGEVIEWS
(PREFIX STRING, PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/kyle/popular_us_times/' INTO TABLE US_PAGEVIEWS;

CREATE TABLE UK_PAGEVIEWS
(PREFIX STRING, PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/kyle/popular_uk_times/' INTO TABLE UK_PAGEVIEWS;

CREATE TABLE AUS_PAGEVIEWS
(PREFIX STRING, PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/kyle/popular_aus_times/' INTO TABLE AUS_PAGEVIEWS;

--Consolidate and filter each table

CREATE TABLE US_PAGEVIEWS_CONSOLIDATED
(PAGE_NAME STRING, PAGE_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO US_PAGEVIEWS_CONSOLIDATED
SELECT PAGE_NAME, SUM(PAGE_VIEWS) FROM US_PAGEVIEWS
WHERE PREFIX='en'
GROUP BY PAGE_NAME;

CREATE TABLE UK_PAGEVIEWS_CONSOLIDATED
(PAGE_NAME STRING, PAGE_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO UK_PAGEVIEWS_CONSOLIDATED
SELECT PAGE_NAME, SUM(PAGE_VIEWS) FROM UK_PAGEVIEWS
WHERE PREFIX='en'
GROUP BY PAGE_NAME;

CREATE TABLE AUS_PAGEVIEWS_CONSOLIDATED
(PAGE_NAME STRING, PAGE_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO AUS_PAGEVIEWS_CONSOLIDATED
SELECT PAGE_NAME, SUM(PAGE_VIEWS) FROM AUS_PAGEVIEWS
WHERE PREFIX='en'
GROUP BY PAGE_NAME;

--Normalize tables per mil population

CREATE TABLE US_PAGEVIEWS_NORMALIZED
(PAGE_NAME STRING, PAGE_VIEWS_PER_MIL FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO US_PAGEVIEWS_NORMALIZED
SELECT PAGE_NAME, CAST(PAGE_VIEWS AS FLOAT)/(2.0*298.38) AS PAGE_VIEWS_PER_MIL FROM US_PAGEVIEWS_CONSOLIDATED
ORDER BY PAGE_VIEWS_PER_MIL DESC;

CREATE TABLE UK_PAGEVIEWS_NORMALIZED
(PAGE_NAME STRING, PAGE_VIEWS_PER_MILS FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO UK_PAGEVIEWS_NORMALIZED
SELECT PAGE_NAME, CAST(PAGE_VIEWS AS FLOAT)/63.984 AS PAGE_VIEWS_PER_MIL FROM UK_PAGEVIEWS_CONSOLIDATED
ORDER BY PAGE_VIEWS_PER_MIL DESC;

CREATE TABLE AUS_PAGEVIEWS_NORMALIZED
(PAGE_NAME STRING, PAGE_VIEWS_PER_MIL FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO AUS_PAGEVIEWS_NORMALIZED
SELECT PAGE_NAME, CAST(PAGE_VIEWS AS FLOAT)/(2.0*20.012) AS PAGE_VIEWS_PER_MIL FROM AUS_PAGEVIEWS_CONSOLIDATED
ORDER BY PAGE_VIEWS_PER_MIL DESC;

--Claim 1: Taskmaster (TV Series) is more popular in the UK than in the US

--Before normalizing:
-- +--------------------------------------+---------------------------------------+
-- | us_pageviews_consolidated.page_name  | us_pageviews_consolidated.page_views  |
-- +--------------------------------------+---------------------------------------+
-- | Taskmaster_(TV_series)               | 11916                                 |
-- +--------------------------------------+---------------------------------------+

-- +--------------------------------------+---------------------------------------+
-- | uk_pageviews_consolidated.page_name  | uk_pageviews_consolidated.page_views  |
-- +--------------------------------------+---------------------------------------+
-- | Taskmaster_(TV_series)               | 9198                                  |
-- +--------------------------------------+---------------------------------------+

SELECT * FROM US_PAGEVIEWS_NORMALIZED
WHERE PAGE_NAME='Taskmaster_(TV_series)';

-- +------------------------------------+---------------------------------------------+
-- | us_pageviews_normalized.page_name  | us_pageviews_normalized.page_views_per_mil  |
-- +------------------------------------+---------------------------------------------+
-- | Taskmaster_(TV_series)             | 19.967827                                   |
-- +------------------------------------+---------------------------------------------+

SELECT * FROM UK_PAGEVIEWS_NORMALIZED
WHERE PAGE_NAME='Taskmaster_(TV_series)';

-- +------------------------------------+----------------------------------------------+
-- | uk_pageviews_normalized.page_name  | uk_pageviews_normalized.page_views_per_mils  |
-- +------------------------------------+----------------------------------------------+
-- | Taskmaster_(TV_series)             | 143.75468                                    |
-- +------------------------------------+----------------------------------------------+

--Claim 2: Marmite is more popular in AUS than in US

--Before normalizing:
-- +--------------------------------------+---------------------------------------+
-- | us_pageviews_consolidated.page_name  | us_pageviews_consolidated.page_views  |
-- +--------------------------------------+---------------------------------------+
-- | Marmite                              | 3552                                  |
-- +--------------------------------------+---------------------------------------+

-- +---------------------------------------+----------------------------------------+
-- | aus_pageviews_consolidated.page_name  | aus_pageviews_consolidated.page_views  |
-- +---------------------------------------+----------------------------------------+
-- | Marmite                               | 3858                                   |
-- +---------------------------------------+----------------------------------------+


SELECT * FROM US_PAGEVIEWS_NORMALIZED
WHERE PAGE_NAME='Marmite';

-- +------------------------------------+---------------------------------------------+
-- | us_pageviews_normalized.page_name  | us_pageviews_normalized.page_views_per_mil  |
-- +------------------------------------+---------------------------------------------+
-- | Marmite                            | 5.952142                                    |
-- +------------------------------------+---------------------------------------------+

SELECT * FROM AUS_PAGEVIEWS_NORMALIZED
WHERE PAGE_NAME='Marmite';

-- +-------------------------------------+----------------------------------------------+
-- | aus_pageviews_normalized.page_name  | aus_pageviews_normalized.page_views_per_mil  |
-- +-------------------------------------+----------------------------------------------+
-- | Marmite                             | 96.392166                                    |
-- +-------------------------------------+----------------------------------------------+