-- q1: Identify quarterly total sessions and orders

select
yr,
qt,
count(sid) as sessions,
count(oid) as orders
from
(select
website_sessions.website_session_id as sid,
order_id as oid,
website_sessions.created_at as created,
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qt
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2015-03-20') as q
group by 1,2;

-- q2: Identify quarterly session to order conversion, revenue per order and revenue per session

select
yr,
qt,
count(oid)/count(sid) as ordercnv,
sum(price)/count(oid) as rpo,
sum(price)/count(sid) as rps
from
(select
website_sessions.website_session_id as sid,
order_id as oid,
website_sessions.created_at as created,
year(website_sessions.created_at) as yr,
price_usd as price,
quarter(website_sessions.created_at) as qt
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2015-03-20') as q
group by 1,2;

-- q3 : Identify sessions and where the traffic came from

select
yr,
qt,
count(distinct case when channeltype = 'gnonbrand' then oid else null end) as gnonbrand,
count(distinct case when channeltype = 'bnonbrand' then oid else null end) as bnonbrand,
count(distinct case when channeltype = 'brand' then oid else null end) as brand,
count(distinct case when channeltype = 'organic' then oid else null end) as organic,
count(distinct case when channeltype = 'direct' then oid else null end) as direct
from
(select
orders.created_at,
year(orders.created_at) as yr,
quarter(orders.created_at) as qt,
website_sessions.website_session_id as sid,
order_id as oid,
case when utm_source is null and utm_campaign is null and http_referer is null then 'direct'
	when utm_campaign = 'nonbrand' and utm_source = 'gsearch' then 'gnonbrand'
	when utm_campaign = 'nonbrand' and utm_source = 'bsearch' then 'bnonbrand'
	when utm_campaign = 'brand' then 'brand' 
	when utm_source is null and utm_campaign is null and http_referer is not null then 'organic'
else null end as channeltype
from website_sessions
right join orders
on orders.website_session_id = website_sessions.website_session_id
where orders.created_at < '2015-03-20') as q
group by 1,2;

-- q4: Find the session to order conversion and traffic source


select
yr,
qt,
count(distinct case when channeltype = 'gnonbrand' then oid else null end)/count(distinct case when channeltype = 'gnonbrand' then sid else null end) as gnonbrand,
count(distinct case when channeltype = 'bnonbrand' then oid else null end)/count(distinct case when channeltype = 'bnonbrand' then sid else null end) as bnonbrand,
count(distinct case when channeltype = 'brand' then oid else null end)/count(distinct case when channeltype = 'brand' then sid else null end) as brand,
count(distinct case when channeltype = 'organic' then oid else null end)/count(distinct case when channeltype = 'organic' then sid else null end) as organic,
count(distinct case when channeltype = 'direct' then oid else null end)/count(distinct case when channeltype = 'direct' then sid else null end) as direct
from
(select
website_sessions.created_at,
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qt,
website_sessions.website_session_id as sid,
order_id as oid,
case when utm_source is null and utm_campaign is null and http_referer is null then 'direct'
	when utm_campaign = 'nonbrand' and utm_source = 'gsearch' then 'gnonbrand'
	when utm_campaign = 'nonbrand' and utm_source = 'bsearch' then 'bnonbrand'
	when utm_campaign = 'brand' then 'brand' 
	when utm_source is null and utm_campaign is null and http_referer is not null then 'organic'
else null end as channeltype
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2015-03-20') as q
group by 1,2;

-- q5: Track the sales of the four different products with total revenue and sales

select
yr,
mo,
sum(price) as totalrev,
count(oid) as totalsales,
sum(case when pid = 1 then price else null end) as p1rev,
sum(case when pid = 1 then price else null end)-sum(case when pid = 1 then cost else null end) as p1mar,
sum(case when pid = 2 then price else null end) as p2rev,
sum(case when pid = 2 then price else null end)-sum(case when pid = 2 then cost else null end) as p2mar,
sum(case when pid = 3 then price else null end) as p3rev,
sum(case when pid = 3 then price else null end)-sum(case when pid = 3 then cost else null end) as p3mar,
sum(case when pid = 4 then price else null end) as p4rev,
sum(case when pid = 4 then price else null end)-sum(case when pid = 4 then cost else null end) as p4mar
from
(select
created_at,
year(created_at) as yr,
month(created_at) as mo,
order_item_id as oiid,
order_id as oid,
price_usd as price,
cogs_usd as cost,
product_id as pid
from order_items
where created_at < '2015-03-20') as m
group by 1,2;

-- q6: Identify the clickthrough rate of all products from products page as well as the session to order conversion from that page

drop table minpcv;
-- create temporary table minpcv
select
pageview_url,
website_pageview_id,
website_session_id,
created_at as created
from website_pageviews
where created_at < '2015-03-20'
and pageview_url = '/products';


-- create temporary table nxtpv
select
nxtpvid,
sid,
pageview_url as nxtpage
from
(select
min(website_pageviews.website_pageview_id) as nxtpvid,
website_pageviews.website_session_id as sid
from website_pageviews
join minpcv
on website_pageviews.website_session_id = minpcv.website_session_id
and website_pageviews.website_pageview_id > minpcv.website_pageview_id
where created_at < '2015-03-20'
group by 2) as pv
join website_pageviews
on website_pageviews.website_session_id = pv.sid
and nxtpvid = website_pageview_id;


select
year(created) as yr,
month(created) as mon,
count(distinct minpcv.website_pageview_id) as psessions,
count(distinct nxtpv.nxtpvid)/count(distinct minpcv.website_pageview_id) as ctr,
count(distinct order_id)/count(distinct minpcv.website_pageview_id) as ordercv
from minpcv
left join nxtpv
on minpcv.website_session_id = nxtpv.sid
left join orders
on orders.website_session_id = minpcv.website_session_id
group by 1,2;

-- q7: Identify which product cross sold the most and with what product


drop table pp;
create temporary table pp
select
order_id,
primary_product_id,
created_at as orderedat
from orders
where created_at > '2014-12-06';

select
pp.*,
order_items.product_id as csid
from pp
left join order_items
on order_items.order_id = pp.order_id
and order_items.is_primary_item = 0
;


select
primary_product_id,
count(distinct order_id) as orders,
count(distinct case when csid = 1 then order_id else null end) as soldp1,
count(distinct case when csid = 2 then order_id else null end) as soldp2,
count(distinct case when csid = 3 then order_id else null end) as soldp3,
count(distinct case when csid = 4 then order_id else null end) as soldp4,
count(distinct case when csid = 1 then order_id else null end)/count(distinct order_id) as xp1,
count(distinct case when csid = 2 then order_id else null end)/count(distinct order_id) as xp2,
count(distinct case when csid = 3 then order_id else null end)/count(distinct order_id) as xp3,
count(distinct case when csid = 4 then order_id else null end)/count(distinct order_id) as xp4
from
(select
pp.*,
order_items.product_id as csid
from pp
left join order_items
on order_items.order_id = pp.order_id
and order_items.is_primary_item = 0
order by 3 desc) as pc
group by 1;
