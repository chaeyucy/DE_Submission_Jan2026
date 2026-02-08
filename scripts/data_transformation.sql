-- Example: rebuild sessions (truncate + insert). For incremental loads, use MERGE.
TRUNCATE TABLE dbo.chatbot_session;
GO

WITH msg_base AS (
    SELECT
        m.conversation_id,
        SUM(CASE WHEN m.role = 'user' THEN 1 ELSE 0 END) AS user_message_count,
        SUM(CASE WHEN m.role = 'bot'  THEN 1 ELSE 0 END) AS bot_message_count,
        MIN(CASE WHEN m.role = 'user' THEN m.sent_at END) AS first_user_at,
        MIN(CASE WHEN m.role = 'bot'  THEN m.sent_at END) AS first_bot_at,
        MIN(m.sent_at) AS min_sent_at,
        MAX(m.sent_at) AS max_sent_at
    FROM dbo.[message] m
    GROUP BY m.conversation_id
),

latency_stats AS (
    SELECT DISTINCT
        m.conversation_id,
        AVG(CASE WHEN m.role='bot' AND m.response_latency_ms IS NOT NULL THEN CAST(m.response_latency_ms AS FLOAT) END)
            OVER (PARTITION BY m.conversation_id) AS bot_latency_avg_ms,
        CAST(
            PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY CASE WHEN m.role='bot' THEN m.response_latency_ms END)
            OVER (PARTITION BY m.conversation_id)
            AS INT
        ) AS bot_latency_p95_ms,
        CAST(
            PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY CASE WHEN m.role='bot' THEN m.response_latency_ms END)
            OVER (PARTITION BY m.conversation_id)
            AS INT
        ) AS bot_latency_p99_ms
    FROM dbo.[message] m
    WHERE m.role='bot' AND m.response_latency_ms IS NOT NULL
),

label_counts AS (
    SELECT
        m.conversation_id,
        SUM(CASE WHEN lbl.reply_type='fallback' THEN 1 ELSE 0 END) AS bot_fallback_count,
        SUM(CASE WHEN lbl.reply_type='error'    THEN 1 ELSE 0 END) AS bot_error_count
    FROM dbo.[message] m
    LEFT JOIN dbo.message_bot_label lbl
        ON lbl.message_id = m.message_id
    WHERE m.role='bot'
    GROUP BY m.conversation_id
),

fb AS (
    SELECT
        cf.conversation_id,
        1 AS has_feedback,
        cf.rating_score,
        cf.language_id AS feedback_language_id,
        cf.created_at  AS feedback_created_at
    FROM dbo.conversation_feedback cf
)

INSERT INTO dbo.chatbot_session (
    conversation_id, 
	website_id, 
	chatbot_user_id,
    session_start_at, 
	session_end_at, 
	duration_second,
    status, 
	traffic_type,
    escalated_to_agent, 
	escalated_at, 
	escalation_channel,
    has_feedback, 
	rating_score, 
    user_message_count, 
	bot_message_count,
    bot_fallback_count, 
	bot_error_count,
    bot_latency_avg_ms, 
	bot_latency_p95_ms, 
	bot_latency_p99_ms,
    first_bot_response_ms
)
SELECT
    c.conversation_id,
    c.website_id,
    c.chatbot_user_id,
    c.started_at AS session_start_at,
    COALESCE(c.ended_at, mb.max_sent_at) AS session_end_at,
    CASE
        WHEN COALESCE(c.ended_at, mb.max_sent_at) IS NULL THEN NULL
        ELSE DATEDIFF(SECOND, c.started_at, COALESCE(c.ended_at, mb.max_sent_at))
    END AS duration_seconds,
    c.status,
    'prod' AS traffic_type, 

    CAST(0 AS BIT) AS escalated_to_agent,
    NULL AS escalated_at,
    NULL AS escalation_channel,

    COALESCE(fb.has_feedback, 0) AS has_feedback,
    fb.rating_score,

    COALESCE(mb.user_message_count, 0),
    COALESCE(mb.bot_message_count, 0),

    COALESCE(lc.bot_fallback_count, 0),
    COALESCE(lc.bot_error_count, 0),

    ls2.bot_latency_avg_ms,
    ls2.bot_latency_p95_ms,
    ls2.bot_latency_p99_ms,

    CASE
        WHEN mb.first_user_at IS NULL OR mb.first_bot_at IS NULL THEN NULL
        ELSE DATEDIFF(MILLISECOND, mb.first_user_at, mb.first_bot_at)
    END AS first_bot_response_ms
FROM dbo.chatbot_conversation c
LEFT JOIN msg_base mb ON mb.conversation_id = c.conversation_id
LEFT JOIN lang_stats ls ON ls.conversation_id = c.conversation_id
LEFT JOIN latency_stats ls2 ON ls2.conversation_id = c.conversation_id
LEFT JOIN label_counts lc ON lc.conversation_id = c.conversation_id
LEFT JOIN fb ON fb.conversation_id = c.conversation_id;
GO
