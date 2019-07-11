DROP TABLE IF EXISTS mojito.exposures_usercookie;
CREATE TABLE mojito.exposures_usercookie
DISTKEY(subject)
SORTKEY(client_id, wave_id, exposure_time)
AS (
  WITH exposures as (
    SELECT
      domain_userid AS subject,
      app_id as client_id,
      recipe as recipe_name,
      x.wave_id,
      -- Aggregate by the first exposure timestamp
      min(derived_tstamp) AS exposure_time
    FROM atomic.events e
    INNER JOIN atomic.io_mintmetrics_mojito_mojito_exposure_1 x
      ON e.event_id = x.root_id AND e.collector_tstamp = x.root_tstamp
    WHERE e.event_name = 'mojito_exposure'
      AND e.event_version = '1-0-0'
      -- Handle cases where the unit is not set
      AND e.domain_userid IS NOT NULL
      -- Internal traffic & bot exclusion
      AND NOT (
        case 
          when app_id = 'mintmetrics' then user_ipaddress in (
            SELECT ip_address FROM mintmetrics.ip_exclusions UNION SELECT user_ipaddress FROM snowplow_intermediary.bot_ipaddress_exclusion_1
          )
        end
      )
    GROUP BY 1, 2, 3, 4
  ),

  -- Filter users who may be a part of both experiments (e.g. due to cookie churn)
  dupes as (
    select subject, wave_id, client_id
    from exposures
    group by 1, 2, 3
    having count(recipe_name) = 1
  )

  select x.* 
  from exposures x
  inner join dupes d                  
    on x.subject = d.subject 
      and x.wave_id = d.wave_id 
      and x.client_id = d.client_id
  order by client_id, wave_id, exposure_time
);
