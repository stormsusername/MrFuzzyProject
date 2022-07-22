-- The way I solved it, same answer
-- CREATE TEMPORARY TABLE pageview_sess
SELECT
pageview_url AS pages,
website_session_id AS id
FROM website_pageviews
WHERE created_at < '2012-11-10'
AND created_at >= '2012-09-10'
ORDER BY created_at
;

-- CREATE TEMPORARY TABLE bill_v
SELECT
pages,
id
FROM pageview_sess
WHERE pages IN ('/billing','/billing-2');

-- CREATE TEMPORARY TABLE thank_id
SELECT
pages,
id
FROM pageview_sess
WHERE pages = '/thank-you-for-your-order';

SELECT 
bill_v.pages,
COUNT(bill_v.id) AS sessions,
COUNT(thank_id.id) AS orders,
COUNT(thank_id.id)/COUNT(bill_v.id) AS click_r
FROM bill_v
LEFT JOIN thank_id
ON thank_id.id = bill_v.id
GROUP BY bill_v.pages;

-- the way the teacher solved it, same answer

SELECT
MIN(website_pageviews.website_pageiew_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url ='/billing-2';

SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2');

SELECT
billing_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS rate
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2'))
AS billing_sessions
GROUP BY billing_version_seen;