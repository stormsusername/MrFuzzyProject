USE mavenfuzzyfactory;

SELECT 
	COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS CNV
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-04-14' AND website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand';
	

    