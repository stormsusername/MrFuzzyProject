CREATE TEMPORARY TABLE land_id
SELECT
website_session_id,
MIN(website_pageview_id) AS minpv_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT
website_pageviews.pageview_url AS entry_page,
COUNT(DISTINCT land_id.website_session_id) AS ses_on_lander
FROM land_id
LEFT JOIN website_pageviews
ON land_id.minpv_id = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url