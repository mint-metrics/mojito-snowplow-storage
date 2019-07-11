DROP TABLE IF EXISTS mojito.mintmetrics_conversions_usercookie;
CREATE TABLE mojito.mintmetrics_conversions_usercookie DISTKEY (subject) 
SORTKEY (goal, conversion_time)
AS (
    SELECT

        domain_userid AS subject,

        -- This is the value for the goal
        CASE 
            WHEN event = 'struct' THEN
                se_category || ' ' || se_action
            WHEN event = 'page_view' THEN
                'page_view ' || page_urlpath
            WHEN event = 'transaction' THEN
                'purchase'
        END AS goal,

        -- This is used for revenue reporting
        tr_total AS revenue,
        
        -- Aggregate over the first event id (in case your Snowplow pipeline is generating duplicates)
        Min(derived_tstamp) AS conversion_time

    FROM
        mintmetrics.events

    WHERE
        domain_userid IS NOT NULL
        and event in ('page_view', 'struct', 'transaction')

    GROUP BY
        -- We group by the transaction ID or event ID to ensure we're not double-counting events
        1, 2, 3, nvl(tr_orderid, event_id)

    ORDER BY
        conversion_time
);

GRANT SELECT ON mojito.mintmetrics_conversions_usercookie TO mojito_reports;

