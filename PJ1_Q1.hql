CREATE DATABASE PAGEVIEWS_DB;

USE PAGEVIEWS_DB;

--Load all data from files into single table
CREATE TABLE PAGEVIEWS
    (PROJECT STRING, PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-000000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-010000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-020000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-030000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-040000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-050000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-060000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-070000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-080000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-090000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-100000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-110000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-120000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-130000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-140000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-150000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-160000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-170000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-180000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-190000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-200000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-210000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-220000' INTO TABLE PAGEVIEWS;
LOAD DATA LOCAL INPATH '/home/kyle/pageviews_data/pageviews-20201020-230000' INTO TABLE PAGEVIEWS;

--Get all the en pages
CREATE TABLE PAGEVIEWS_EN
    (PAGE_NAME STRING, PAGE_VIEWS INT, PAGE_SIZE INT)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ' ';

INSERT INTO TABLE PAGEVIEWS_EN
    SELECT PAGE_NAME, PAGE_VIEWS, PAGE_SIZE FROM PAGEVIEWS
    WHERE PROJECT='en';

--Get page with most views:
SELECT PAGE_NAME, SUM(PAGE_VIEWS) TOTAL
    FROM PAGEVIEWS_EN
    GROUP BY PAGE_NAME
    ORDER BY TOTAL DESC
    LIMIT 100;

-- +----------------------------------------------------+----------+
-- |----------TOP 10 MOST VIEWED ENGLISH PAGES FOR OCT 20----------|
-- +----------------------------------------------------+----------+
-- |                     page_name                      |  total   |
-- +----------------------------------------------------+----------+
-- | Main_Page                                          | 2726387  |
-- | Special:Search                                     | 910309   |
-- | Bible                                              | 148726   |
-- | -                                                  | 124890   |
-- | Jeffrey_Toobin                                     | 116724   |
-- | Microsoft_Office                                   | 71825    |
-- | Deaths_in_2020                                     | 62082    |
-- | F5_Networks                                        | 61049    |
-- | Robert_Redford                                     | 56808    |
-- | Jeff_Bridges                                       | 48696    |
-- +----------------------------------------------------+----------+