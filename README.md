# SumpUp Take Home Test

## Q1 - Which are the main KPIs the mission lead should track to be able to answer his business question? How are you going to build these metrics? What are the different steps we shouldtrack? 

 * ROI of web orders and leads from marketing campaign
   * web orders: `sum(spend) / sum(NB_POSLITE_ITEMS_DISPATCHED)`
   * leads funnel: `sum(spend) / sum(TOTAL_POS_LITE_DEALS)`
 * Marketing Performence
   * CTR of web orders and leads from marketing campaign `sum(clicks) / sum(impressions)`
   * CPC of web orders and leads from marketing campaign `sum(spend) / sum(clicks)`
   * CPM of web orders and leads from marketing campaign `sum(spend) / sum(impressions)`
 * Funnels conversion rate - Each steps to an order of the product should be tracked in order to identify conversion rate in the steps, it helps to identify main bottle neck in the sales process, in web orders and leads funnels. 
  * web orders funnel
    * 1st funnel: `sum(NB_OF_POSLITE_ITEMS_ORDERED) / sum(NB_OF_ORDERS)` *100
    * 2nd funnel: `sum(NB_POSLITE_ITEMS_DISPATCHED) / sum(NB_OF_POSLITE_ITEMS_ORDERED)` *100
  * leads funnel
    * 1st funnel: `sum(TOTAL_FAKE_LEADS) / sum(TOTAL_LEADS)` *100
    * 2nd funnel: `sum(TOTAL_SQLS) / (sum(TOTAL_LEADS) - sum(TOTAL_FAKE_LEADS))` *100
    * 3rd funnel: `sum(TOTAL_MEETING_DONE) / sum(TOTAL_SQLS)` *100
    * 4th funnel: `sum(TOTAL_SIGNED_LEADS) / sum(TOTAL_MEETING_DONE)` *100
    * 5th funnel: `sum(TOTAL_POS_LITE_DEALS) / sum(TOTAL_SIGNED_LEADS)` *100


## In order to enable self-service analytics, the data team has to create data marts to enhance usage and to leverage data-driven insights. 

### Q2 - Create a staging tables for the provided source data. A staging table is a clean-up table following best SQL standards and conventions 
### Q3 - Based on these staging tables, create one or multiple tables to build a mart enabling dashboarding and self service. 

* Data Frame `channels`
```
CREATE TABLE `channels` (
  `CAMPAIGN_ID` text,
  `CAMPAIGN_NAME` text,
  `CAMPAIGN_PERIOD_BUDGET_CATEGORY` text,
  `CHANNEL_3` text,
  `CHANNEL_4` text,
  `CHANNEL_5` text
)
```
  * Remove blank space in `CAMPAIGN_NAME`, `CAMPAIGN_PERIOD_BUDGET_CATEGORY`, `CHANNEL_3`, `CHANNEL_4`, `CHANNEL_5`
  * Replace `unknown` in col `CAMPAIGN_PERIOD_BUDGET_CATEGORY`, if `CAMPAIGN_ID` has duplicates, and all other columns have the same value
  * Row Count: 120 (raw) vs 61 (after cleaning)
  * Distinct `CAMPAIGN_ID`: 61
  * ? Naming convention for campaign setup
```
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

```
* Data Frame `web_order`
  * Resolve blanks and formatting issues in column `campaign_id`
  * Remove rows with empty `CAMPAIGN_ID` and `CAMPAIGN_NAME`
  * Replace rows with empty `COUNTRY_CODE` with `unknown`
  * Row Count: 3825 (raw) vs 3777 (after cleaning)
 
```
CREATE TABLE `web_orders` (
  `DATE` datetime DEFAULT NULL,
  `COUNTRY_CODE` text,
  `CAMPAIGN_ID` text,
  `TOTAL_SPEND_EUR` double DEFAULT NULL,
  `NB_OF_SESSIONS` int DEFAULT NULL,
  `NB_OF_SIGNUPS` int DEFAULT NULL,
  `NB_OF_ORDERS` int DEFAULT NULL,
  `NB_OF_POSLITE_ITEMS_ORDERED` int DEFAULT NULL,
  `NB_POSLITE_ITEMS_DISPATCHED` int DEFAULT NULL
) 
```

```
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

```

* Data Frame `leads_funnels`
  * Resolve blanks and formatting issues in column `campaign_id`
  * Remove rows with empty `CAMPAIGN_ID` 
  * Replace rows with empty `COUNTRY_CODE` with `unknown`
  * Replace `TOTAL_LEADS`, `TOTAL_FAKE_LEADS`, `TOTAL_SQLS`, `TOTAL_MEETING_DONE`, `TOTAL_SIGNED_LEADS`, `TOTAL_POS_LITE_DEALS`  with `0`, when `TOTAL_LEADS` > `TOTAL_CLICKS`, as it looks like an invalid case
  * Remove rows where `TOTAL_IMPRESSIONS` and `TOTAL_CLICKS` = `100000000`
  * Row Count: 3381 (raw) vs 3359 (after cleaning)
 
```
CREATE TABLE `leads_funnels` (
  `DATE` datetime DEFAULT NULL,
  `CURRENCY` text,
  `COUNTRY_CODE` text,
  `CAMPAIGN_ID` text,
  `CAMPAIGN_NAME` text,
  `PRODUCT` text,
  `CHANNEL_3` text,
  `CHANNEL_4` text,
  `CHANNEL_5` text,
  `TOTAL_IMPRESSIONS` int DEFAULT NULL,
  `TOTAL_CLICKS` bigint DEFAULT NULL,
  `TOTAL_SPEND` int DEFAULT NULL,
  `TOTAL_LEADS` int DEFAULT NULL,
  `TOTAL_FAKE_LEADS` int DEFAULT NULL,
  `TOTAL_SQLS` int DEFAULT NULL,
  `TOTAL_MEETING_DONE` bigint DEFAULT NULL,
  `TOTAL_SIGNED_LEADS` int DEFAULT NULL,
  `TOTAL_POS_LITE_DEALS` int DEFAULT NULL
) 
```

```
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
```

### Q4 - Design a one-page dashboard that will help the Mission Lead to monitor the team performance based on the data model you designed above. It’d be best if you can build graphs from the existing data. But if you do not have time, then a drawing, assuming it is clear and readable, works too. Please take the time to explain your methodology and the choices you made. 

One-page dashboard
* Filters
  * Date Range
  * Marketing Campaigns
    * Sub-channels 3/4/5
  * Country Code
  * Product
* Scorce cards on top shows high level overview of marketing campaigns' performance and total number of POS lite orders. There could be a dognut charts/ small tables shows the % marketing and orders metrics by the 2 pathways (web order and leads) when hovering on the score cards
* The second part of the dashboard
  * Left side
    * Details of marketing campaigns performance of web order (top) and leads (bottom) in a table
      * Identify top marketing campaigns
      * Ideas: If a certain campaign is clciked, then the funnel analysis on the right would only show numbers of the selected campaigns
  * Right side
    * Details of sales funnels analysis of web order (top) and leads (bottom)
      * Funnel chart shows the numbers/ performance in each steps
      * Table shows % conversion rate between each steps 

![IMG-7436](https://github.com/user-attachments/assets/445eb14c-2d0b-4a2f-9e4e-2860ae526877)
