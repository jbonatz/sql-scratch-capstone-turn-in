{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf400
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 WITH months as\
(SELECT \
 '2017-01-01' as first_day,\
'2017-01-31' as last_day\
	UNION\
 SELECT\
 '2017-02-01' as first_day,\
 '2017-02-28' as last_day\
 UNION\
 SELECT '2017-03-01' as first_day,\
 '2017-03-31' as last_day\
),\
\
cross_join as \
(SELECT *\
 FROM subscriptions \
 CROSS JOIN months),\
\
status as \
(SELECT id, first_day as month,\
 	CASE\
 		WHEN segment = 87 AND \
 		(subscription_start < first_day) AND\
		 (subscription_end > first_day OR\
 		 subscription_end IS NULL)\
	 THEN 1\
 	ELSE 0\
 	END as is_active_87,\
 	CASE \
 		WHEN segment = 30 and\
 		(subscription_start < first_day) AND\
 		(subscription_end > first_day OR\
  		subscription_end IS NULL)\
 	THEN 1\
 	ELSE 0 \
 	END as is_active_30,\
 	CASE\
 		WHEN segment = 87 AND \
 		subscription_end BETWEEN first_day AND\
  		last_day\
 	THEN 1\
 	ELSE 0\
 END as is_canceled_87,\
 CASE\
 WHEN segment = 30 AND \
 subscription_end BETWEEN first_day AND\
 last_day\
 THEN 1\
 ELSE 0\
 END as is_canceled_30\
 FROM cross_join\
),\
\
status_aggregate as\
(SELECT month, sum(is_active_87) as sum_active_87, sum(is_active_30) as sum_active_30, sum(is_canceled_87) as sum_canceled_87, sum(is_canceled_30) as sum_canceled_30\
 FROM status\
 GROUP BY month)\
 \
 SELECT month, 1.0*sum(sum_canceled_87)/sum(sum_active_87) as 'segment 87 churn rate', 1.0*sum(sum_canceled_30)/sum(sum_active_30) as 'segment 30 churn rate'\
 FROM status_aggregate\
 GROUP BY month;\
\
\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\'97\
\
\'97overall churn trend\
\
with months as\
(select \
 '2017-01-01' as first_day,\
'2017-01-31' as last_day\
	union\
 select\
 '2017-02-01' as first_day,\
 '2017-02-28' as last_day\
 union\
 select '2017-03-01' as first_day,\
 '2017-03-31' as last_day\
),\
\
cross_join as \
(select *\
 from subscriptions \
 cross join months),\
\
status as \
(select id, segment, first_day as month,\
 	case \
 		when \
 		(subscription_start < first_day) and\
		 (subscription_end > first_day or\
 		 subscription_end IS NULL)\
	 THEN 1\
 	ELSE 0\
 	end as active_users,\
 	case\
 		when subscription_end between first_day and last_day\
 	THEN 1\
 	ELSE 0\
 end as canceled_users\
 from cross_join\
),\
\
status_aggregate as\
(select month, sum(active_users) as sum_active_users, sum(canceled_users) as sum_canceled_users \
 from status\
 group by month)\
 \
 select month, 1.0*sum(sum_canceled_users)/sum(sum_active_users) as 'overall_churn_rate'\
 from status_aggregate\
 where segment = 87\
 group by month;}