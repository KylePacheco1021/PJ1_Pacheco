CREATE DATABASE Q2_DB;

USE Q2_DB;

CREATE TABLE CLICKSTREAM
(referrer STRING, referred STRING, type STRING, occurences INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

LOAD DATA LOCAL INPATH '/home/kyle/clickstream_data/clickstream-enwiki-2020-09.tsv' INTO TABLE CLICKSTREAM;

CREATE TABLE CLICKSTREAM_LINK
(REFERRER STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE CLICKSTREAM_LINK
SELECT referrer, SUM(occurences) FROM CLICKSTREAM
WHERE type='link'
GROUP BY referrer;

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

CREATE TABLE CONSOLIDATED_ALL
(PAGE_NAME STRING, TOTAL_VIEWS INT, LINKS_CLICKED INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO CONSOLIDATED_ALL
SELECT PAGEVIEWS_CONSOLIDATED.PAGE_NAME, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CLICKSTREAM_LINK.OCCURENCES, CAST(CLICKSTREAM_LINK.OCCURENCES AS FLOAT)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS FLOAT) FROM CLICKSTREAM_LINK
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM_LINK.REFERRER;

SELECT * FROM CONSOLIDATED_ALL
WHERE TOTAL_VIEWS > 1000000
ORDER BY PERCENTAGE DESC
LIMIT 100;

--RESULTS:

-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |----------------------------------------------------------------------NO FILTER----------------------------------------------------------------------|
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |             consolidated_all.page_name             | consolidated_all.total_views  | consolidated_all.links_clicked  | consolidated_all.percentage  |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- | /r/                                                | 1                             | 64                              | 64.0                         |
-- | /\                                                 | 2                             | 56                              | 28.0                         |
-- | Health//Disco                                      | 8                             | 209                             | 26.125                       |
-- | Strange_haircuts_//_cardboard_guitars_//_and_computer_samples | 1                  | 26                              | 26.0                         |
-- | List_of_listed_buildings_in_Musselburgh,_East_Lothian | 28                         | 662                             | 23.642857                    |
-- | Flourish_//_Perish                                 | 1                             | 19                              | 19.0                         |
-- | Lost_Forever_//_Lost_Together                      | 29                            | 463                             | 15.965517                    |
-- | 2006_Chicago_Rush_season                           | 12                            | 185                             | 15.416667                    |
-- | Baeolidia_gracilis                                 | 8                             | 121                             | 15.125                       |
-- | Finally_//_Beautiful_Stranger                      | 19                            | 282                             | 14.842105                    |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+



-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |------------------------------------------------------------------TOTAL_VIEWS>10000------------------------------------------------------------------|
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |             consolidated_all.page_name             | consolidated_all.total_views  | consolidated_all.links_clicked  | consolidated_all.percentage  |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- | List_of_controversial_album_art                    | 11271                         | 47953                           | 4.254547                     |
-- | List_of_common_World_War_II_infantry_weapons       | 31097                         | 108981                          | 3.5045502                    |
-- | List_of_murdered_American_children                 | 20578                         | 71761                           | 3.487268                     |
-- | List_of_modern_armoured_fighting_vehicles          | 10350                         | 35893                           | 3.4679227                    |
-- | List_of_pornographic_performers_by_decade          | 135742                        | 467454                          | 3.4436946                    |
-- | List_of_infantry_weapons_of_World_War_I            | 21880                         | 74312                           | 3.3963437                    |
-- | List_of_military_aircraft_of_the_United_States     | 26326                         | 83378                           | 3.1671352                    |
-- | List_of_premodern_combat_weapons                   | 17731                         | 55700                           | 3.1413908                    |
-- | List_of_solved_missing_person_cases                | 14677                         | 46075                           | 3.1392655                    |
-- | Wunderwaffe                                        | 14412                         | 44363                           | 3.0781987                    |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+


-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |------------------------------------------------------------------TOTAL_VIEWS>100000-----------------------------------------------------------------|
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |             consolidated_all.page_name             | consolidated_all.total_views  | consolidated_all.links_clicked  | consolidated_all.percentage  |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- | List_of_pornographic_performers_by_decade          | 135742                        | 467454                          | 3.4436946                    |
-- | List_of_serial_killers_in_the_United_States        | 185479                        | 420780                          | 2.2686126                    |
-- | List_of_PlayStation_5_games                        | 100694                        | 163494                          | 1.6236718                    |
-- | Wayans_family                                      | 157934                        | 242476                          | 1.5352995                    |
-- | Hijackers_in_the_September_11_attacks              | 166387                        | 250949                          | 1.5082248                    |
-- | List_of_legendary_creatures_by_type                | 105926                        | 159170                          | 1.5026528                    |
-- | List_of_WWE_personnel                              | 212166                        | 318008                          | 1.498864                     |
-- | Everton_F.C.                                       | 335450                        | 497610                          | 1.4834104                    |
-- | List_of_Hindi_film_families                        | 154197                        | 219340                          | 1.422466                     |
-- | Vajiralongkorn                                     | 157137                        | 221220                          | 1.407816                     |
-- +----------------------------------------------------+-------------------------------+---------------------------------+------------------------------+




-- +---------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |--------------------------------------------------------------TOTAL_VIEWS>1000000-------------------------------------------------------------|
-- +---------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- |         consolidated_all.page_name          | consolidated_all.total_views  | consolidated_all.links_clicked  | consolidated_all.percentage  |
-- +---------------------------------------------+-------------------------------+---------------------------------+------------------------------+
-- | Dune_(2020_film)                            | 1278838                       | 1201459                         | 0.9394927                    |
-- | Cobra_Kai                                   | 2459988                       | 2241751                         | 0.91128534                   |
-- | COVID-19_pandemic_by_country_and_territory  | 1207880                       | 1093321                         | 0.90515697                   |
-- | Schitt's_Creek                              | 1493588                       | 1339942                         | 0.8971296                    |
-- | Elizabeth_II                                | 1065045                       | 922145                          | 0.86582726                   |
-- | Sarah_Paulson                               | 1252257                       | 987550                          | 0.78861606                   |
-- | Supreme_Court_of_the_United_States          | 1278921                       | 1002716                         | 0.78403276                   |
-- | 2016_United_States_presidential_election    | 1052232                       | 768124                          | 0.7299949                    |
-- | Enola_Holmes_(film)                         | 1980000                       | 1356311                         | 0.68500555                   |
-- | 2020_United_States_presidential_election    | 1150820                       | 749205                          | 0.6510184                    |
-- +---------------------------------------------+-------------------------------+---------------------------------+------------------------------+