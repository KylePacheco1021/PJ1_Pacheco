--What were the most popular lists on (english) wikipedia in September 2020?

CREATE TABLE PAGEVIEWS
(PROJECT STRING, PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/kyle/q2_data/' INTO TABLE PAGEVIEWS;

CREATE TABLE PAGEVIEWS_EN
(PAGE_NAME STRING, PAGE_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO TABLE PAGEVIEWS_EN
SELECT PAGE_NAME, PAGE_VIEWS FROM PAGEVIEWS
WHERE PROJECT='en' OR PROJECT='en.m';

CREATE TABLE PAGEVIEWS_CONSOLIDATED
(PAGE_NAME STRING, TOTAL_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO PAGEVIEWS_CONSOLIDATED
SELECT PAGE_NAME, SUM(PAGE_VIEWS) FROM PAGEVIEWS_EN
GROUP BY PAGE_NAME;

CREATE TABLE PAGEVIEWS_CONSOLIDATED_SORTED
(PAGE_NAME STRING, TOTAL_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO PAGEVIEWS_CONSOLIDATED_SORTED
SELECT PAGE_NAME, TOTAL_VIEWS FROM PAGEVIEWS_CONSOLIDATED
ORDER BY TOTAL_VIEWS DESC;

SELECT * FROM PAGEVIEWS_CONSOLIDATED_SORTED
WHERE PAGE_NAME LIKE 'List_of%'
LIMIT 10;

-- +----------------------------------------------------+--------------------------------------------+
-- |      pageviews_consolidated_sorted.page_name       | pageviews_consolidated_sorted.total_views  |
-- +----------------------------------------------------+--------------------------------------------+
-- | List_of_Marvel_Cinematic_Universe_films            | 852758                                     |
-- | List_of_presidents_of_the_United_States            | 756816                                     |
-- | List_of_James_Bond_films                           | 650084                                     |
-- | List_of_justices_of_the_Supreme_Court_of_the_United_States | 623624                             |
-- | List_of_The_Boys_characters                        | 574700                                     |
-- | List_of_NBA_champions                              | 572012                                     |
-- | List_of_The_Karate_Kid_characters                  | 499625                                     |
-- | List_of_Lucifer_episodes                           | 499311                                     |
-- | List_of_states_and_territories_of_the_United_States| 494342                                     |
-- | List_of_United_States_cities_by_population         | 425839                                     |
-- +----------------------------------------------------+--------------------------------------------+