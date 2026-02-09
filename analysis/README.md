## Assumption
1. One chatbot_session record represents one chatbot conversation (**1-1 relationship with [chatbot_conversation].conversation_id**).
2. “response_latency_ms” is defined as the total time elapsed between a user sending a message (input) and receiving the corresponding response (output) from the chatbot.
3. Messages are ordered by “message-sequence” and/or “sent_at”, and bot latency is measured via “response_latency_ms” stored on bot messages.
4. If “session_end_at” is NULL, the session is treated as “still active / incomplete”. For duration-based queries we exclude these rows or treat duration as NULL.
5. We assume a field like **“traffic_type”** exists in table [chatbot_session] (e.g., prod, test, bot, etc). All example metrics/queries filter “traffic_type” = ‘prod’ to **exclude non-production traffic**.

## Limitations

1. If bot message fallback/error labels are generated via rules or models, mislabeling will affect error/fallback rate metrics.
2. Queries treat sessions independently. If an IP opens multiple sessions concurrently(i.e., multiple tabs, etc.), “active sessions” and idle time calculations can be misleading.
3. Long-running sessions (e.g., user leaves tab open) can skew chatbot response average. Prefer percentiles (p95/p99) and/or cap extreme durations for reporting.
4. IP-based analysis can be noisy due to shared corporate IPs or rotating mobile networks.
