SELECT
MIN(created_at),
MIN(website_pageview_id)
FROM mavenfuzzyfactory.website_pageviews
WHERE pageview_url = '/lander-1' AND created_at IS NOT NULL;
-- 2012-06-19 00:35:54
-- 23504
DROP TABLE test_land_id;
CREATE TEMPORARY TABLE test_land_id
SELECT
website_pageviews.website_session_id,
MIN(website_pageview_id) AS minpv_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28' 
AND website_pageviews.website_pageview_id > '23504'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

DROP TABLE test_land_ses_view;
CREATE TEMPORARY TABLE test_land_ses_view
SELECT
website_pageviews.pageview_url AS entry_page,
test_land_id.website_session_id AS ses_on_lander
FROM test_land_id
LEFT JOIN website_pageviews
ON test_land_id.minpv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/home' OR website_pageviews.pageview_url = '/lander-1';

DROP TABLE test_bounced_ses;
CREATE TEMPORARY TABLE test_bounced_ses
SELECT
test_land_ses_view.ses_on_lander,
test_land_ses_view.entry_page,
COUNT(website_pageviews.website_pageview_id) AS pages_viewed
FROM test_land_ses_view
LEFT JOIN website_pageviews
ON test_land_ses_view.ses_on_lander = website_pageviews.website_session_id
GROUP BY test_land_ses_view.ses_on_lander, test_land_ses_view.entry_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

SELECT
test_land_ses_view.entry_page,
COUNT(DISTINCT test_land_ses_view.ses_on_lander) as total_land_ses,
COUNT(DISTINCT test_bounced_ses.ses_on_lander) AS total_bounced_ses,
COUNT(DISTINCT test_bounced_ses.ses_on_lander)/COUNT(DISTINCT test_land_ses_view.ses_on_lander) AS b_rate
FROM test_land_ses_view
LEFT JOIN test_bounced_ses
ON test_bounced_ses.ses_on_lander = test_land_ses_view.ses_on_lander
GROUP BY test_land_ses_view.entry_page
ORDER BY
test_land_ses_view.ses_on_lander
;