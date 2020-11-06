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
(REFERRER STRING, REFERRED STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE CLICKSTREAM_HOTEL_CALIFORNIA
SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='Hotel_California'
ORDER BY OCCURENCES DESC;

SELECT * FROM CLICKSTREAM_HOTEL_CALIFORNIA
LIMIT 10;

-- +----------------------------------------+----------------------------------------+------------------------------------------+
-- | clickstream_hotel_california.referrer  | clickstream_hotel_california.referred  | clickstream_hotel_california.occurences  |
-- +----------------------------------------+----------------------------------------+------------------------------------------+
-- | Hotel_California                       | Hotel_California_(Eagles_album)        | 2222                                     |
-- | Hotel_California                       | Don_Henley                             | 1537                                     |
-- | Hotel_California                       | Don_Felder                             | 1519                                     |
-- | Hotel_California                       | Eagles_(band)                          | 1335                                     |
-- | Hotel_California                       | Glenn_Frey                             | 1021                                     |
-- | Hotel_California                       | Joe_Walsh                              | 683                                      |
-- | Hotel_California                       | Loree_Rodkin                           | 434                                      |
-- | Hotel_California                       | Coda_(music)                           | 357                                      |
-- | Hotel_California                       | The_Magus_(novel)                      | 344                                      |
-- | Hotel_California                       | Julia_Phillips                         | 306                                      |
-- +----------------------------------------+----------------------------------------+------------------------------------------+

--Hotel_California -> Hotel_California_(Eagles_album) 

CREATE TABLE HOTEL_CALIFORNIA_ONE_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_ONE_DEEP
SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='Hotel_California_(Eagles_album)'
ORDER BY OCCURENCES DESC;

SELECT * FROM HOTEL_CALIFORNIA_ONE_DEEP
WHERE REFERRER='Hotel_California_(Eagles_album)'
LIMIT 10;

-- +-------------------------------------+-------------------------------------+---------------------------------------+
-- | hotel_california_one_deep.referrer  | hotel_california_one_deep.referred  | hotel_california_one_deep.occurences  |
-- +-------------------------------------+-------------------------------------+---------------------------------------+
-- | Hotel_California_(Eagles_album)     | The_Long_Run_(album)                | 2127                                  |
-- | Hotel_California_(Eagles_album)     | Hotel_California                    | 2010                                  |
-- | Hotel_California_(Eagles_album)     | Their_Greatest_Hits_(1971–1975)     | 897                                   |
-- | Hotel_California_(Eagles_album)     | Eagles_(band)                       | 801                                   |
-- | Hotel_California_(Eagles_album)     | The_Beverly_Hills_Hotel             | 490                                   |
-- | Hotel_California_(Eagles_album)     | Randy_Meisner                       | 445                                   |
-- | Hotel_California_(Eagles_album)     | New_Kid_in_Town                     | 433                                   |
-- | Hotel_California_(Eagles_album)     | Life_in_the_Fast_Lane               | 415                                   |
-- | Hotel_California_(Eagles_album)     | The_Last_Resort_(Eagles_song)       | 400                                   |
-- | Hotel_California_(Eagles_album)     | Don_Felder                          | 383                                   |
-- +-------------------------------------+-------------------------------------+---------------------------------------+

--Hotel_California -> Hotel_California_(Eagles_album) -> The_Long_Run_(album) 


CREATE TABLE HOTEL_CALIFORNIA_TWO_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_TWO_DEEP
SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='The_Long_Run_(album)'
ORDER BY OCCURENCES DESC;

SELECT * FROM HOTEL_CALIFORNIA_TWO_DEEP
LIMIT 10;

-- +-------------------------------------+-------------------------------------+---------------------------------------+
-- | hotel_california_two_deep.referrer  | hotel_california_two_deep.referred  | hotel_california_two_deep.occurences  |
-- +-------------------------------------+-------------------------------------+---------------------------------------+
-- | The_Long_Run_(album)                | Eagles_Live                         | 1322                                  |
-- | The_Long_Run_(album)                | Hotel_California_(Eagles_album)     | 654                                   |
-- | The_Long_Run_(album)                | I_Can't_Tell_You_Why                | 470                                   |
-- | The_Long_Run_(album)                | Heartache_Tonight                   | 327                                   |
-- | The_Long_Run_(album)                | Timothy_B._Schmit                   | 319                                   |
-- | The_Long_Run_(album)                | The_Long_Run_(song)                 | 319                                   |
-- | The_Long_Run_(album)                | Eagles_(band)                       | 309                                   |
-- | The_Long_Run_(album)                | In_the_City_(Joe_Walsh_song)        | 297                                   |
-- | The_Long_Run_(album)                | Don_Felder                          | 285                                   |
-- | The_Long_Run_(album)                | Long_Road_Out_of_Eden               | 168                                   |
-- +-------------------------------------+-------------------------------------+---------------------------------------+

--Hotel_California -> Hotel_California_(Eagles_album) -> The_Long_Run_(album) -> Eagles_Live 

CREATE TABLE HOTEL_CALIFORNIA_THREE_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_THREE_DEEP
SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='Eagles_Live'
ORDER BY OCCURENCES DESC;

SELECT * FROM HOTEL_CALIFORNIA_THREE_DEEP
LIMIT 10;

-- +---------------------------------------+---------------------------------------+-----------------------------------------+
-- | hotel_california_three_deep.referrer  | hotel_california_three_deep.referred  | hotel_california_three_deep.occurences  |
-- +---------------------------------------+---------------------------------------+-----------------------------------------+
-- | Eagles_Live                           | Eagles_Greatest_Hits,_Vol._2          | 1136                                    |
-- | Eagles_Live                           | The_Long_Run_(album)                  | 223                                     |
-- | Eagles_Live                           | Seven_Bridges_Road                    | 127                                     |
-- | Eagles_Live                           | Eagles_(band)                         | 95                                      |
-- | Eagles_Live                           | Life's_Been_Good                      | 47                                      |
-- | Eagles_Live                           | All_Night_Long_(Joe_Walsh_song)       | 36                                      |
-- | Eagles_Live                           | Randy_Meisner                         | 29                                      |
-- | Eagles_Live                           | Steve_Young_(musician)                | 29                                      |
-- | Eagles_Live                           | Joe_Walsh                             | 28                                      |
-- | Eagles_Live                           | Hell_Freezes_Over                     | 26                                      |
-- +---------------------------------------+---------------------------------------+-----------------------------------------+

--Hotel_California -> Hotel_California_(Eagles_album) -> The_Long_Run_(album) -> Eagles_Live -> Eagles_Greatest_Hits,_Vol._2

CREATE TABLE HOTEL_CALIFORNIA_FOUR_DEEP
(REFERRER STRING, REFERRED STRING, OCCURENCES INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\t";

INSERT INTO TABLE HOTEL_CALIFORNIA_FOUR_DEEP
SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='Eagles_Greatest_Hits,_Vol._2'
ORDER BY OCCURENCES DESC;

SELECT * FROM HOTEL_CALIFORNIA_FOUR_DEEP
LIMIT 10;

-- +--------------------------------------+--------------------------------------+----------------------------------------+
-- | hotel_california_four_deep.referrer  | hotel_california_four_deep.referred  | hotel_california_four_deep.occurences  |
-- +--------------------------------------+--------------------------------------+----------------------------------------+
-- | Eagles_Greatest_Hits,_Vol._2         | The_Very_Best_of_the_Eagles          | 996                                    |
-- | Eagles_Greatest_Hits,_Vol._2         | Eagles_Live                          | 186                                    |
-- | Eagles_Greatest_Hits,_Vol._2         | Their_Greatest_Hits_(1971–1975)      | 42                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | Eagles_(band)                        | 36                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | One_of_These_Nights                  | 25                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | Seven_Bridges_Road                   | 24                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | Hotel_California_(Eagles_album)      | 20                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | Glenn_Frey                           | 18                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | Don_Henley                           | 17                                     |
-- | Eagles_Greatest_Hits,_Vol._2         | The_Long_Run_(album)                 | 17                                     |
-- +--------------------------------------+--------------------------------------+----------------------------------------+

--Hotel_California -> Hotel_California_(Eagles_album) -> The_Long_Run_(album) -> Eagles_Live -> Eagles_Greatest_Hits,_Vol._2 -> The_Very_Best_of_the_Eagles

SELECT REFERRER, REFERRED, OCCURENCES FROM CLICKSTREAM
WHERE REFERRER='The_Very_Best_of_the_Eagles'
ORDER BY OCCURENCES DESC
LIMIT 10;

-- +------------------------------+----------------------------------+-------------+
-- |           referrer           |             referred             | occurences  |
-- +------------------------------+----------------------------------+-------------+
-- | The_Very_Best_of_the_Eagles  | Hell_Freezes_Over                | 892         |
-- | The_Very_Best_of_the_Eagles  | Eagles_Greatest_Hits,_Vol._2     | 153         |
-- | The_Very_Best_of_the_Eagles  | The_Very_Best_Of_(Eagles_album)  | 43          |
-- | The_Very_Best_of_the_Eagles  | Eagles_(band)                    | 21          |
-- | The_Very_Best_of_the_Eagles  | Desperado_(Eagles_album)         | 21          |
-- +------------------------------+----------------------------------+-------------+

--Hotel_California -> Hotel_California_(Eagles_album) -> The_Long_Run_(album) -> Eagles_Live -> Eagles_Greatest_Hits,_Vol._2 -> The_Very_Best_of_the_Eagles -> Hell_Freezes_Over