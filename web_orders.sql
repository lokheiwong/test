WITH raw as (
SELECT 
  DATE
, CASE WHEN COUNTRY_CODE IS NULL THEN 'Unknown' ELSE COUNTRY_CODE END AS COUNTRY_CODE
, REGEXP_REPLACE(wo.CAMPAIGN_ID, '(\.0+)$', '') AS CAMPAIGN_ID
, TOTAL_SPEND_EUR
, NB_OF_SESSIONS
, NB_OF_SIGNUPS
, NB_OF_ORDERS
, CASE 
  WHEN NB_OF_POSLITE_ITEMS_ORDERED > NB_OF_ORDERS THEN 0 ELSE NB_POSLITE_ITEMS_DISPATCHED 
  END AS NB_OF_POSLITE_ITEMS_ORDERED
, CASE 
  WHEN NB_POSLITE_ITEMS_DISPATCHED > NB_OF_POSLITE_ITEMS_ORDERED OR NB_POSLITE_ITEMS_DISPATCHED > NB_OF_ORDERS THEN 0 ELSE NB_POSLITE_ITEMS_DISPATCHED 
  END AS NB_POSLITE_ITEMS_DISPATCHED
FROM sumup.web_orders wo
)
SELECT
  DATE
, COUNTRY_CODE
, CAMPAIGN_ID
, sum(TOTAL_SPEND_EUR) TOTAL_SPEND_EUR
, sum(NB_OF_SESSIONS) NB_OF_SESSIONS
, sum(NB_OF_SIGNUPS) NB_OF_SIGNUPS
, sum(NB_OF_ORDERS) NB_OF_ORDERS
, sum(NB_OF_POSLITE_ITEMS_ORDERED) NB_OF_POSLITE_ITEMS_ORDERED
, sum(NB_POSLITE_ITEMS_DISPATCHED) NB_POSLITE_ITEMS_DISPATCHED
, sum(TOTAL_SPEND_EUR)/ sum(NB_OF_SESSIONS) cp_session
, sum(TOTAL_SPEND_EUR)/ sum(NB_OF_SIGNUPS) cp_signup
, sum(TOTAL_SPEND_EUR)/ sum(NB_OF_ORDERS) cp_order
, sum(TOTAL_SPEND_EUR)/ sum(NB_OF_POSLITE_ITEMS_ORDERED) cp_poslite_ordered
, sum(TOTAL_SPEND_EUR)/ sum(NB_POSLITE_ITEMS_DISPATCHED) cp_poslite_dispatched
FROM raw
where CAMPAIGN_ID != ''
group by 1, 2, 3
