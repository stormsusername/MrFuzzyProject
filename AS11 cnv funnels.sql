USE mavenfuzzyfactory;

DROP TABLE clickthrough;


CREATE TEMPORARY TABLE clickthrough
SELECT
website_session_id,
COUNT(DISTINCT CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE NULL END) AS landing_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/products' THEN 1 ELSE NULL END) AS products_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END) AS fuzzy_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END) AS cart_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END) AS shipping_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/billing' THEN 1 ELSE NULL END) AS billing_click,
COUNT(DISTINCT CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END) AS thanks_click
FROM
(SELECT website_pageviews.website_session_id,
website_sessions.created_at,
website_pageviews.pageview_url
FROM website_pageviews
LEFT JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_pageviews.created_at < '2012-09-05'
AND website_pageviews.created_at > '2012-08-05') AS t1
GROUP BY website_session_id
;

-- nested from statement
SELECT website_pageviews.website_session_id,
website_sessions.created_at,
website_pageviews.pageview_url
FROM website_pageviews
LEFT JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_pageviews.created_at < '2012-09-05'
AND website_pageviews.created_at > '2012-08-05';

-- count of all click throughs

SELECT
COUNT(DISTINCT website_session_id) AS total_sessions,
-- COUNT(CASE WHEN landing_click = 1 THEN website_session_id ELSE NULL END) AS land_count,
COUNT(CASE WHEN products_click = 1 THEN website_session_id ELSE NULL END) AS products_count,
COUNT(CASE WHEN fuzzy_click = 1 THEN website_session_id ELSE NULL END) AS fuzzy_count,
COUNT(CASE WHEN cart_click = 1 THEN website_session_id ELSE NULL END) AS cart_count,
COUNT(CASE WHEN shipping_click = 1 THEN website_session_id ELSE NULL END) AS shipping_count,
COUNT(CASE WHEN billing_click = 1 THEN website_session_id ELSE NULL END) AS billing_count,
COUNT(CASE WHEN thanks_click = 1 THEN website_session_id ELSE NULL END) AS thanks_count
FROM clickthrough;

-- clickthrough rates

SELECT
COUNT(DISTINCT website_session_id) AS total_sessions,
-- COUNT(CASE WHEN landing_click = 1 THEN 1 ELSE NULL END)/COUNT(DISTINCT website_session_id) AS land_rate,
COUNT(DISTINCT CASE WHEN products_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS products_rate,
COUNT(DISTINCT CASE WHEN fuzzy_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN products_click = 1 THEN website_session_id ELSE NULL END) AS fuzzy_rate,
COUNT(DISTINCT CASE WHEN cart_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN fuzzy_click = 1 THEN website_session_id ELSE NULL END) AS cart_rate,
COUNT(DISTINCT CASE WHEN shipping_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_click = 1 THEN website_session_id ELSE NULL END) AS shipping_rate,
COUNT(DISTINCT CASE WHEN billing_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_click = 1 THEN website_session_id ELSE NULL END) AS billing_rate,
COUNT(DISTINCT CASE WHEN thanks_click = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_click = 1 THEN website_session_id ELSE NULL END) AS thanks_rate
FROM clickthrough;