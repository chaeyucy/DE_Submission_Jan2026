WITH avg_duration_by_ip AS (
    SELECT
        s.ip_address,
        AVG(CAST(DATEDIFF(SECOND, s.session_start_at, s.session_end_at) AS FLOAT)) AS avg_duration_seconds,
        COUNT(*) AS session_count
    FROM dbo.chatbot_session s
    WHERE
        s.traffic_type = 'prod'
        AND s.session_end_at IS NOT NULL
        AND s.ip_address IS NOT NULL
    GROUP BY
        s.ip_address
)
SELECT
    ip_address,
    avg_duration_seconds,
    avg_duration_seconds / 60.0 AS avg_duration_minutes,
    session_count
FROM avg_duration_by_ip
WHERE avg_duration_seconds > 900
ORDER BY avg_duration_seconds DESC;