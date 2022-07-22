SELECT
MIN(DATE(created_at)) AS weekstart,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS gsearch,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS bsearch
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
GROUP BY WEEK(created_at);