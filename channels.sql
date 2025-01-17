WITH RankedRows AS (
SELECT 
  CAMPAIGN_ID
, REPLACE(CAMPAIGN_NAME, ' ', '') AS CAMPAIGN_NAME
, REPLACE(CAMPAIGN_PERIOD_BUDGET_CATEGORY, ' ', '') AS CAMPAIGN_PERIOD_BUDGET_CATEGORY
, REPLACE(CHANNEL_3, ' ', '') AS CHANNEL_3
, REPLACE(CHANNEL_4, ' ', '') AS CHANNEL_4
, REPLACE(CHANNEL_5, ' ', '') AS CHANNEL_5
, ROW_NUMBER() OVER (
  PARTITION BY CAMPAIGN_ID, REPLACE(CAMPAIGN_NAME, ' ', ''), REPLACE(CHANNEL_3, ' ', ''),
  REPLACE(CHANNEL_4, ' ', ''), REPLACE(CHANNEL_5, ' ', '')
  ORDER BY CASE WHEN REPLACE(CAMPAIGN_PERIOD_BUDGET_CATEGORY, ' ', '') = 'unknown' THEN 1 ELSE 0 END
  ) AS rn
FROM sumup.channels
)

SELECT
  CAMPAIGN_ID
, CAMPAIGN_NAME
, case 
  when CAMPAIGN_ID = '20991759296' then 'abs' 
  when CAMPAIGN_PERIOD_BUDGET_CATEGORY = '' then 'unknown' 
  else CAMPAIGN_PERIOD_BUDGET_CATEGORY end CAMPAIGN_PERIOD_BUDGET_CATEGORY
, CHANNEL_3
, CHANNEL_4
, CHANNEL_5
FROM RankedRows
WHERE rn = 1 and CAMPAIGN_NAME != ''
