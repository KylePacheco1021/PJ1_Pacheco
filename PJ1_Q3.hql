--Some preliminary stuff
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE CLICKSTREAM
(referrer STRING, referred STRING, type STRING, occurences INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

LOAD DATA LOCAL INPATH '/home/kyle/clickstream_data/clickstream-enwiki-2020-09.tsv' INTO TABLE CLICKSTREAM;

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
------------------------------------------------------------------------------------------------------------------------
--Meat of Q3 begins here

CREATE TABLE CLICKSTREAM_HOTEL_CALIFORNIA
(REFERRER STRING, REFERRED STRING, OCCURENCES INT, TOTAL_VIEWS INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE CLICKSTREAM_HOTEL_CALIFORNIA
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER='Hotel_California';

SELECT * FROM CLICKSTREAM_HOTEL_CALIFORNIA
ORDER BY PERCENTAGE DESC
LIMIT 10;

-- +----------------------------------------+----------------------------------------+------------------------------------------+-------------------------------------------+------------------------------------------+
-- | clickstream_hotel_california.referrer  | clickstream_hotel_california.referred  | clickstream_hotel_california.occurences  | clickstream_hotel_california.total_views  | clickstream_hotel_california.percentage  |
-- +----------------------------------------+----------------------------------------+------------------------------------------+-------------------------------------------+------------------------------------------+
-- | Hotel_California                       | Hotel_California_(disambiguation)      | 190                                      | 248                                       | 76.6129                                  |
-- | Hotel_California                       | Loree_Rodkin                           | 434                                      | 3238                                      | 13.403336                                |
-- | Hotel_California                       | Desperado                              | 177                                      | 1718                                      | 10.302677                                |
-- | Hotel_California                       | Hotel_California_(Eagles_album)        | 2222                                     | 26030                                     | 8.536304                                 |
-- | Hotel_California                       | Julia_Phillips                         | 306                                      | 4075                                      | 7.5092025                                |
-- | Hotel_California                       | Life_in_the_Fast_Lane                  | 286                                      | 3861                                      | 7.4074073                                |
-- | Hotel_California                       | Camarillo_State_Mental_Hospital        | 127                                      | 2440                                      | 5.204918                                 |
-- | Hotel_California                       | The_Magus_(film)                       | 101                                      | 1990                                      | 5.075377                                 |
-- | Hotel_California                       | The_Magus_(novel)                      | 344                                      | 8295                                      | 4.1470766                                |
-- | Hotel_California                       | Long_Road_Out_of_Eden_Tour             | 30                                       | 732                                       | 4.0983605                                |
-- +----------------------------------------+----------------------------------------+------------------------------------------+-------------------------------------------+------------------------------------------+


--Hotel_California -> Hotel_California_(disambiguation) (76.61%)

CREATE TABLE HOTEL_CALIFORNIA_ONE_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT, TOTAL_VIEWS INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_ONE_DEEP
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER='Hotel_California_(disambiguation)';

SELECT * FROM HOTEL_CALIFORNIA_ONE_DEEP
ORDER BY PERCENTAGE DESC
LIMIT 10;

-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+
-- | hotel_california_one_deep.referrer  | hotel_california_one_deep.referred  | hotel_california_one_deep.occurences  | hotel_california_one_deep.total_views  | hotel_california_one_deep.percentage  |
-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+
-- | Hotel_California_(disambiguation)   | Hotel_Californian                   | 27                                    | 37                                     | 72.97298                              |
-- | Hotel_California_(disambiguation)   | Hotel_California_(2008_film)        | 23                                    | 536                                    | 4.2910447                             |
-- | Hotel_California_(disambiguation)   | Todos_Santos,_Baja_California_Sur   | 19                                    | 1495                                   | 1.270903                              |
-- | Hotel_California_(disambiguation)   | Filter_bubble                       | 33                                    | 13274                                  | 0.2486063                             |
-- | Hotel_California_(disambiguation)   | Hotel_California_(Eagles_album)     | 25                                    | 26030                                  | 0.09604303                            |
-- | Hotel_California_(disambiguation)   | Hotel_California                    | 17                                    | 59922                                  | 0.028370215                           |
-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+

--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_Californian (55.90%)
--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) (3.06%)

CREATE TABLE HOTEL_CALIFORNIA_TWO_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT, TOTAL_VIEWS INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_TWO_DEEP
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER LIKE 'Hotel_Californian';

SELECT * FROM HOTEL_CALIFORNIA_TWO_DEEP
ORDER BY PERCENTAGE DESC
LIMIT 10;

--After visiting Hotel_Californian, 0 probability to continue so we check next most probable chain.

INSERT INTO TABLE HOTEL_CALIFORNIA_TWO_DEEP
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER='Hotel_California_(2008_film)';

-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+
-- | hotel_california_two_deep.referrer  | hotel_california_two_deep.referred  | hotel_california_two_deep.occurences  | hotel_california_two_deep.total_views  | hotel_california_two_deep.percentage  |
-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+
-- | Hotel_California_(2008_film)        | Erik_Palladino                      | 31                                    | 11169                                  | 0.27755395                            |
-- | Hotel_California_(2008_film)        | Tyson_Beckford                      | 20                                    | 16762                                  | 0.1193175                             |
-- | Hotel_California_(2008_film)        | Tatyana_Ali                         | 26                                    | 109385                                 | 0.023769256                           |
-- +-------------------------------------+-------------------------------------+---------------------------------------+----------------------------------------+---------------------------------------+

--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) -> Erik_Palladino
--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) -> Tyson_Beckford
--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) -> Tatyana_Ali

CREATE TABLE HOTEL_CALIFORNIA_THREE_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT, TOTAL_VIEWS INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_THREE_DEEP
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER='Erik_Palladino' OR CLICKSTREAM.REFERRER='Tyson_Beckford' OR CLICKSTREAM.REFERRER='Tatyana_Ali';

SELECT * FROM HOTEL_CALIFORNIA_THREE_DEEP
ORDER BY PERCENTAGE DESC
LIMIT 10;

-- +---------------------------------------+---------------------------------------+-----------------------------------------+------------------------------------------+-----------------------------------------+
-- | hotel_california_three_deep.referrer  | hotel_california_three_deep.referred  | hotel_california_three_deep.occurences  | hotel_california_three_deep.total_views  | hotel_california_three_deep.percentage  |
-- +---------------------------------------+---------------------------------------+-----------------------------------------+------------------------------------------+-----------------------------------------+
-- | Tatyana_Ali                           | Kiss_the_Sky_(Tatyana_Ali_album)      | 978                                     | 1518                                     | 64.42688                                |
-- | Tatyana_Ali                           | Everytime_(Tatyana_Ali_song)          | 81                                      | 127                                      | 63.779526                               |
-- | Tatyana_Ali                           | Afro-Panamanians                      | 1490                                    | 2589                                     | 57.551178                               |
-- | Tatyana_Ali                           | Dougla_people                         | 2062                                    | 5610                                     | 36.755795                               |
-- | Tatyana_Ali                           | Comeback_Dad                          | 83                                      | 334                                      | 24.8503                                 |
-- | Tyson_Beckford                        | Kings_of_the_Evening                  | 14                                      | 60                                       | 23.333334                               |
-- | Tatyana_Ali                           | Locker_13                             | 103                                     | 449                                      | 22.939867                               |
-- | Tatyana_Ali                           | Dear_Secret_Santa                     | 65                                      | 284                                      | 22.887323                               |
-- | Tatyana_Ali                           | The_Bellmores,_New_York               | 482                                     | 2116                                     | 22.778828                               |
-- | Tatyana_Ali                           | Nora's_Hair_Salon_2:_A_Cut_Above      | 85                                      | 374                                      | 22.727272                               |
-- +---------------------------------------+---------------------------------------+-----------------------------------------+------------------------------------------+-----------------------------------------+

--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) -> Tatyana_Ali -> Kiss_the_Sky_(Tatyana_Ali_album)

CREATE TABLE HOTEL_CALIFORNIA_FOUR_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT, TOTAL_VIEWS INT, PERCENTAGE FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_FOUR_DEEP
SELECT CLICKSTREAM.REFERRER, CLICKSTREAM.REFERRED, CLICKSTREAM.OCCURENCES, PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS, CAST(CLICKSTREAM.OCCURENCES AS DECIMAL)/CAST(PAGEVIEWS_CONSOLIDATED.TOTAL_VIEWS AS DECIMAL)*100 FROM CLICKSTREAM
INNER JOIN PAGEVIEWS_CONSOLIDATED
ON PAGEVIEWS_CONSOLIDATED.PAGE_NAME=CLICKSTREAM.REFERRED
WHERE CLICKSTREAM.REFERRER='Kiss_the_Sky_(Tatyana_Ali_album)';

SELECT * FROM HOTEL_CALIFORNIA_FOUR_DEEP
ORDER BY PERCENTAGE DESC
LIMIT 10;

-- +--------------------------------------+--------------------------------------+----------------------------------------+-----------------------------------------+----------------------------------------+
-- | hotel_california_four_deep.referrer  | hotel_california_four_deep.referred  | hotel_california_four_deep.occurences  | hotel_california_four_deep.total_views  | hotel_california_four_deep.percentage  |
-- +--------------------------------------+--------------------------------------+----------------------------------------+-----------------------------------------+----------------------------------------+
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Everytime_(Tatyana_Ali_song)         | 25                                     | 127                                     | 19.68504                               |
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Work_Group                           | 13                                     | 551                                     | 2.3593466                              |
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Chico_DeBarge                        | 10                                     | 5026                                    | 0.19896539                             |
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Tatyana_Ali                          | 66                                     | 109385                                  | 0.060337342                            |
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Michael_Jackson                      | 38                                     | 593974                                  | 0.006397586                            |
-- | Kiss_the_Sky_(Tatyana_Ali_album)     | Will_Smith                           | 30                                     | 480100                                  | 0.006248698                            |
-- +--------------------------------------+--------------------------------------+----------------------------------------+-----------------------------------------+----------------------------------------+

--Hotel_California -> Hotel_California_(disambiguation) -> Hotel_California_(2008_film) -> Tatyana_Ali -> Kiss_the_Sky_(Tatyana_Ali_album) -> Everytime_(Tatyana_Ali_song) 