WITH per_session AS (
    SELECT
        s.session_id,
        s.website_id,
        s.ip_address,
        s.session_start_at AS session_starttstamp,
        (s.user_message_count + s.bot_message_count) AS total_messages,
        CASE
            WHEN s.session_end_at IS NULL THEN NULL
            ELSE DATEDIFF(SECOND, s.session_start_at, s.session_end_at)
        END AS session_duration_seconds,
        CASE
            WHEN (s.user_message_count + s.bot_message_count) < 3 THEN 1
            WHEN s.session_end_at IS NOT NULL
                 AND DATEDIFF(SECOND, s.session_start_at, s.session_end_at) < 60 THEN 1
            ELSE 0
        END AS is_short_conversation
    FROM dbo.chatbot_session s
    WHERE
        s.traffic_type = 'prod'
        AND s.session_start_at IS NOT NULL
)
SELECT
    p.website_id,
    COUNT(*) AS total_sessions,
    SUM(p.is_short_conversation) AS short_sessions,
    CAST(SUM(p.is_short_conversation) AS FLOAT) / NULLIF(COUNT(*), 0) AS pct_short_sessions
FROM per_session p
GROUP BY p.website_id
ORDER BY pct_short_sessions DESC, total_sessions DESC;
