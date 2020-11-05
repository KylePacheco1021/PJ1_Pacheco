CREATE TABLE RAW_REVISIONS (WIKI_DB STRING, 
EVENT_ENTITY STRING,
EVENT_TYPE STRING,
EVENT_TIMESTAMP STRING,
EVENT_COMMENT STRING,
EVENT_USER_ID BIGINT,
EVENT_USER_TEXT_HISTORICAL STRING,
EVENT_USER_TEXT STRING,
EVENT_USER_BLOCKS_HISTORICAL STRING,
EVENT_USER_BLOCKS ARRAY<STRING>,
EVENT_USER_GROUPS_HISTORICAL ARRAY<STRING>,
EVENT_USER_GROUPS ARRAY<STRING>,
event_user_is_bot_by_historical ARRAY<STRING>,
event_user_is_bot_by ARRAY<STRING>,
event_user_is_created_by_self BOOLEAN,
event_user_is_created_by_system BOOLEAN,
event_user_is_created_by_peer BOOLEAN,
event_user_is_anonymous BOOLEAN,
event_user_registration_timestamp STRING,
event_user_creation_timestamp STRING,
event_user_first_edit_timestamp STRING,
event_user_revision_count BIGINT,
event_user_seconds_since_previous_revision BIGINT,
page_id BIGINT,
page_title_historical STRING,
page_title STRING,
page_namespace_historical INT,
page_namespace_is_content_historical BOOLEAN,
page_namespace INT,
page_namespace_is_content BOOLEAN,
page_is_redirect BOOLEAN,
page_is_deleted BOOLEAN,
page_creation_timestamp STRING,
page_first_edit_timestamp STRING,
page_revision_count BIGINT,
page_seconds_since_previous_revision BIGINT,
user_id BIGINT,
user_text_historical STRING,
user_text STRING,
user_blocks_historical ARRAY<STRING>,
user_blocks ARRAY<STRING>,
user_groups_historical ARRAY<STRING>,
user_groups ARRAY<String>,
user_is_bot_by_historical ARRAY<STRING>,
user_is_bot_by Array<STRING>,
user_is_created_by_self BOOLEAN,
user_is_created_by_system boolean,
user_is_created_by_peer BOOLEAN,
user_is_anonymous boolean,
user_registration_timestamp String,
user_creation_timestamp STRING,
user_first_edit_timestamp STRING,
revision_id bigint,
revision_parent_id bigint,
revision_minor_edit boolean,
revision_deleted_parts Array<String>,
revision_deleted_parts_are_suppressed boolean,
revision_text_bytes bigint,
revision_text_bytes_diff bigint,
revision_text_sha1 string,
revision_content_model string,
revision_content_format string,
revision_is_deleted_by_page_deletion boolean,
revision_deleted_by_page_deletion_timestamp string,
revision_is_identity_reverted boolean,
revision_first_identity_reverting_revision_id bigint,
revision_seconds_to_identity_revert bigint,
revision_is_identity_revert boolean,
revision_is_from_before_page_creation boolean,
revision_tags Array<string>)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';

LOAD DATA LOCAL INPATH '/home/kyle/revisions_data/2020-09.enwiki.2020-09.tsv.bz2' INTO TABLE RAW_REVISIONS;

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
SELECT PAGE_NAME, TOTAL_VIEWS FROM PAGEVIEWS_EN
GROUP BY PAGE_NAME;

CREATE TABLE PAGEVIEWS_CONSOLIDATED_SORTED
(PAGE_NAME STRING, TOTAL_VIEWS INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO PAGEVIEWS_CONSOLIDATED_SORTED
SELECT PAGE_NAME, TOTAL_VIEWS FROM PAGEVIEWS_CONSOLIDATED
ORDER BY TOTAL_VIEWS DESC;

CREATE TABLE REVISIONS_AND_PAGEVIEWS_MERGED
(PAGE_NAME STRING, TOTAL_VIEWS INT, revision_seconds_to_identity_revert bigint)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO REVISIONS_AND_PAGEVIEWS_MERGED
SELECT RAW_REVISIONS.page_title, PAGEVIEWS_CONSOLIDATED_SORTED.TOTAL_VIEWS, RAW_REVISIONS.revision_seconds_to_identity_revert FROM RAW_REVISIONS
INNER JOIN PAGEVIEWS_CONSOLIDATED_SORTED
ON PAGEVIEWS_CONSOLIDATED_SORTED.PAGE_NAME=RAW_REVISIONS.page_title;

--Get average time it takes to revert a revision in seconds (need revision_seconds_to_identity_revert>0, otherwise average is negative):

SELECT AVG(revision_seconds_to_identity_revert) FROM RAW_REVISIONS
WHERE revision_seconds_to_identity_revert>0;

--81687.76 seconds

--Get average pageviews in september for enwiki

SELECT AVG(TOTAL_VIEWS) FROM REVISIONS_AND_PAGEVIEWS_MERGED
WHERE revision_seconds_to_identity_revert IS NOT NULL AND revision_seconds_to_identity_revert>0;

--38499.08 average pageviews in September 2020

--Can do math to get # of views on a vandalized page before reverting
--81687.76*(1/3600)*(1/24)*(1/30)*38499.08 = 1213.31 views on average


--What if I don't include filter on revision_seconds_to_identity_revert for average page views?
--Average page views for september: 44597.68
--81687.76*(1/3600)*(1/24)*(1/30)*44597.68 = 1405.51 views on average
--Probably shouldn't consider this result





