SELECT 
  DATE
, case when COUNTRY_CODE = '' then 'unknown' else COUNTRY_CODE end COUNTRY_CODE
, REGEXP_REPLACE(CAMPAIGN_ID, '(\.0+)$', '') AS CAMPAIGN_ID
, replace(CAMPAIGN_NAME, ' ', '') CAMPAIGN_NAME
, replace(PRODUCT, ' ', '') PRODUCT
, replace(CHANNEL_3, ' ', '') CHANNEL_3
, replace(CHANNEL_4, ' ', '') CHANNEL_4
, replace(CHANNEL_5, ' ', '') CHANNEL_5
, TOTAL_IMPRESSIONS
, TOTAL_CLICKS
, TOTAL_SPEND
, CASE WHEN TOTAL_LEADS > TOTAL_CLICKS THEN 0 ELSE TOTAL_LEADS END AS TOTAL_LEADS
, CASE WHEN TOTAL_FAKE_LEADS > TOTAL_LEADS THEN 0 ELSE TOTAL_FAKE_LEADS END AS TOTAL_FAKE_LEADS
, CASE WHEN TOTAL_SQLS > (TOTAL_CLICKS-TOTAL_FAKE_LEADS) or TOTAL_LEADS = 0 THEN 0  ELSE TOTAL_SQLS END AS TOTAL_SQLS
, CASE WHEN TOTAL_MEETING_DONE > TOTAL_SQLS or TOTAL_LEADS = 0 THEN 0  ELSE TOTAL_MEETING_DONE END AS TOTAL_MEETING_DONE
, CASE WHEN TOTAL_SIGNED_LEADS > TOTAL_MEETING_DONE or TOTAL_LEADS = 0 THEN 0  ELSE TOTAL_SIGNED_LEADS END AS TOTAL_SIGNED_LEADS
, CASE WHEN TOTAL_POS_LITE_DEALS > TOTAL_SIGNED_LEADS or TOTAL_LEADS = 0 THEN 0  ELSE TOTAL_POS_LITE_DEALS END AS TOTAL_POS_LITE_DEALS
FROM sumup.leads_funnels 
where 
TOTAL_IMPRESSIONS != 100000000
and TOTAL_CLICKS != 100000000
and CAMPAIGN_ID != '' 
and CAMPAIGN_NAME != '' 
