
WITH pre_lag AS (
    SELECT
        s.session_id,
        s.ip_address,
        s.session_start_at AS session_starttstamp,
        LAG(s.session_end_at) OVER (PARTITION BY s.ip_address ORDER BY s.session_start_at) AS prev_session_endtstamp
    FROM dbo.chatbot_session s
    WHERE
        s.traffic_type = 'prod' AND s.ip_address IS NOT NULL
)
SELECT
    session_id,
    ip_address,
    session_starttstamp,
    prev_session_endtstamp,
    CASE
        WHEN prev_session_endtstamp IS NULL THEN NULL
        ELSE DATEDIFF(SECOND, prev_session_endtstamp, session_starttstamp)
    END AS idle_time
FROM pre_lag
ORDER BY ip_address, session_starttstamp;
