-- Task 1
SELECT
MONTH(website_sessions.created_at) AS months,
COUNT(website_sessions.website_session_id) AS total_sessions,
COUNT(orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at);

-- Task 2

-- gsearch list table
DROP TABLE gsearch;
CREATE TEMPORARY TABLE gsearch
SELECT
MONTH(website_sessions.created_at) AS months,
website_sessions.website_session_id AS sessions_id,
orders.order_id AS ordering_id,
utm_campaign AS campaign
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
;

-- final output
SELECT
months,
COUNT(DISTINCT CASE WHEN campaign = 'nonbrand' THEN sessions_id ELSE NULL END) AS nonbrand_count,
COUNT(DISTINCT CASE WHEN campaign = 'nonbrand' THEN ordering_id ELSE NULL END) AS nonbrand_order,
COUNT(DISTINCT CASE WHEN campaign = 'brand' THEN sessions_id ELSE NULL END) AS brand_count,
COUNT(DISTINCT CASE WHEN campaign = 'brand' THEN ordering_id ELSE NULL END) AS brand_order
FROM gsearch
GROUP BY months;

-- task 3
DROP TABLE nonbrand_gsearch;
CREATE TEMPORARY TABLE nonbrand_gsearch
SELECT
MONTH(website_sessions.created_at) AS months,
website_sessions.website_session_id AS sessions_id,
orders.order_id AS ordering_id,
utm_campaign AS campaign,
device_type AS device
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';

-- final output
SELECT
months,
COUNT(DISTINCT CASE WHEN device = 'desktop' THEN sessions_id ELSE NULL END) AS desktop_count,
COUNT(DISTINCT CASE WHEN device = 'desktop' THEN ordering_id ELSE NULL END) AS desktop_order,
COUNT(DISTINCT CASE WHEN device = 'mobile' THEN sessions_id ELSE NULL END) AS mobile_count,
COUNT(DISTINCT CASE WHEN device = 'mobile' THEN ordering_id ELSE NULL END) AS mobile_order
FROM nonbrand_gsearch
GROUP BY months;

-- task 4
-- find sources
SELECT
utm_source,
COUNT(website_session_id)
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY utm_source;

-- final output
SELECT
MONTH(created_at),
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_traf,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS g_perc,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_traf,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS b_perc,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_traf,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)AS o_perc,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_traf,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)AS d_perc
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY MONTH(created_at);

-- task 5

SELECT
MONTH(website_sessions.created_at) AS months,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS cnv
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY MONTH(website_sessions.created_at);

-- task 6
-- teachers answer
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-07-28'
AND website_pageviews.website_pageview_id >= 23504
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
GROUP by website_pageviews.website_session_id;

CREATE TEMPORARY TABLE non_brand_test
SELECT 
first_test_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

create temporary table nonbrand_orders
select
non_brand_test.website_session_id,
non_brand_test.landing_page,
orders.order_id
FROM non_brand_test
LEFT JOIN orders
ON orders.website_session_id = non_brand_test.website_session_id;

SELECT
landing_page,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(DISTINCT order_id) as orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) as cnv
from nonbrand_orders
GROUP BY landing_page;

SELECT
MAX(website_sessions.website_session_id) as most_recent
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27';

-- 17145
SELECT
COUNT(website_session_id) as sessions_since_test
from website_sessions
where created_at < '2012-11-27'
and website_session_id > 17145
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand';

-- multiply last output result by differnce in conversion to get estimate of new monthly orders



-- my answer
DROP TABLE before_orders_id;
CREATE TEMPORARY TABLE before_orders_id
SELECT
orders.website_session_id,
orders.price_usd
FROM orders
LEFT JOIN website_sessions
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-07-28' 
AND website_sessions.created_at > '2012-06-19'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand';


DROP TABLE before_land_id;
-- CREATE TEMPORARY TABLE before_land_id
SELECT
website_session_id,
MIN(website_pageview_id) AS minpv_id
FROM website_pageviews
WHERE created_at < '2012-07-28'
AND created_at > '2012-06-19'
GROUP BY website_session_id;


DROP TABLE before_land_ses_view;
CREATE TEMPORARY TABLE before_land_ses_view
SELECT
website_pageviews.pageview_url AS entry_page,
before_land_id.website_session_id AS ses_on_lander
FROM before_land_id
LEFT JOIN website_pageviews
ON before_land_id.minpv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/home' OR website_pageviews.pageview_url = '/lander-1'
;


DROP TABLE before_rev;
CREATE TEMPORARY TABLE before_rev_order
SELECT
ses_on_lander,
entry_page,
orders.order_id
FROM before_land_ses_view
LEFT JOIN orders
ON ses_on_lander = orders.website_session_id
;

SELECT
entry_page,
COUNT(DISTINCT ses_on_lander),
COUNT(DISTINCT order_id),
COUNT(DISTINCT order_id)/COUNT(DISTINCT ses_on_lander)
FROM before_rev_order
GROUP BY entry_page;

-- task 7
-- teachers answer
select
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.created_at < '2012-07-08'
and website_sessions.created_at > '2012-06-09'
ORDER BY
website_sessions.website_session_id

;
drop table hits;
CREAte temporary table hits
SELECT
website_session_id,
MAX(homepage) as home,
MAX(custom_lander) as land,
MAX(products_page) as p,
MAX(mrfuzzy_page) as m,
MAX(cart_page)as c,
MAX(shipping_page) as s,
MAX(billing_page) as b,
MAX(thankyou_page) as t
FROM(
select
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.created_at < '2012-07-08'
and website_sessions.created_at > '2012-06-09'
ORDER BY
website_sessions.website_session_id)
As pageview_level
group by website_session_id;

SELECT
CASE
WHEN home = 1 THEN 'home'
WHEN land = 1 THEN 'land'
ELSE 'check'
END AS seg,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(DISTINCT case when p = 1 then website_session_id else null end) as products,
COUNT(DISTINCT case when m = 1 then website_session_id else null end) as fuzzy,
COUNT(DISTINCT case when c = 1 then website_session_id else null end) as cart,
COUNT(DISTINCT case when s = 1 then website_session_id else null end) as shipping,
COUNT(DISTINCT case when b = 1 then website_session_id else null end) as billing,
COUNT(DISTINCT case when t = 1 then website_session_id else null end) as thankyou
FROM hits
GROUP BY 1;

SELECT
CASE
WHEN home = 1 THEN 'home'
WHEN land = 1 THEN 'land'
ELSE 'check'
END AS seg,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(DISTINCT case when p = 1 then website_session_id else null end)/COUNT(DISTINCT website_session_id) as products,
COUNT(DISTINCT case when m = 1 then website_session_id else null end)/COUNT(DISTINCT case when p = 1 then website_session_id else null end) as fuzzy,
COUNT(DISTINCT case when c = 1 then website_session_id else null end)/COUNT(DISTINCT case when m = 1 then website_session_id else null end) as cart,
COUNT(DISTINCT case when s = 1 then website_session_id else null end)/COUNT(DISTINCT case when c = 1 then website_session_id else null end) as shipping,
COUNT(DISTINCT case when b = 1 then website_session_id else null end)/COUNT(DISTINCT case when s = 1 then website_session_id else null end) as billing,
COUNT(DISTINCT case when t = 1 then website_session_id else null end)/COUNT(DISTINCT case when b = 1 then website_session_id else null end) as thankyou
FROM hits
GROUP BY 1;


-- my answer
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS lander_version_seen,
orders.order_id
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at < '2012-07-28'
AND website_pageviews.created_at > '2012-06-19'
AND website_pageviews.pageview_url IN ('/home', '/lander-1');

SELECT
lander_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS rate
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS lander_version_seen,
orders.order_id
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at < '2012-07-28'
AND website_pageviews.created_at > '2012-06-19'
AND website_pageviews.pageview_url IN ('/home', '/lander-1'))
AS landing_sessions
GROUP BY lander_version_seen;

-- task 8

SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2');

-- final output
SELECT
billing_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS rate,
SUM(price_usd),
SUM(price_usd)/COUNT(DISTINCT website_session_id) AS bps
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2'))
AS billing_sessions
GROUP BY billing_version_seen;

select
count(website_session_id) as billing_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
and created_at between '2012-10-27' and '2012-11-27';

-- find the difference in bps for the two pages then multipy by the pages hit this month
-- ~31-~22 = 9
-- 9 * 1193 = ~10737
