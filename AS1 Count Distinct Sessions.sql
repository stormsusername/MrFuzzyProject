-- This code counts the number of distinct sessions based off source, campaign and domain and groups the results

USE mavenfuzzyfactory;

SELECT
	utm_source,
	utm_campaign,
	http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY
	utm_source,
	utm_campaign,
	http_referer
ORDER BY sessions DESC;
