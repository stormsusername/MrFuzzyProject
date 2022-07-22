-- new table to find minimum pageview id with session id

CREATE TEMPORARY TABLE land_id
SELECT
website_session_id,
MIN(website_pageview_id) AS minpv_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- using previous table to create new table
-- finding the nnumber of sessions on landing page

CREATE TEMPORARY TABLE land_ses_view
SELECT
website_pageviews.pageview_url AS entry_page,
land_id.website_session_id AS ses_on_lander
FROM land_id
LEFT JOIN website_pageviews
ON land_id.minpv_id = website_pageviews.website_pageview_id
WHERE webiste_pageviews.pageview_url = '/home';

-- use previous table to create another temporary table to find the total bounced sessions
-- sessions where there are only one pageview id

CREATE TEMPORARY TABLE bounced_ses
SELECT
land_ses_view.ses_on_lander,
land_ses_view.entry_page,
COUNT(website_pageviews.website_pageview_id) AS pages_viewed
FROM land_ses_view
LEFT JOIN website_pageviews
ON land_ses_view.ses_on_lander = website_pageviews.website_session_id
GROUP BY land_ses_view.ses_on_lander, land_ses_view.entry_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- if session was not bounced, bounced session id will return as null
-- this table combines the last two to display the sessions on the lander and the ones that bounced after landing

SELECT
land_ses_view.entry_page,
land_ses_view.ses_on_lander,
bounced_ses.ses_on_lander AS bounced_ses_id
FROM land_ses_view
LEFT JOIN bounced_ses
ON bounced_ses.ses_on_lander = land_ses_view.ses_on_lander
ORDER BY
land_ses_view.ses_on_lander;

-- next table will count the bounced and total sessions

SELECT
COUNT(DISTINCT land_ses_view.ses_on_lander) as total_land_ses,
COUNT(DISTINCT bounced_ses.ses_on_lander) AS total_bounced_ses,
COUNT(DISTINCT bounced_ses.ses_on_lander)/COUNT(DISTINCT land_ses_view.ses_on_lander) AS b_rate
FROM land_ses_view
LEFT JOIN bounced_ses
ON bounced_ses.ses_on_lander = land_ses_view.ses_on_lander
GROUP BY land_ses_view.entry_page
ORDER BY
land_ses_view.ses_on_lander
;


