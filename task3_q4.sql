DECLARE @LocalDate date = '2026-01-22';
DECLARE @Tz sysname = N'Singapore Standard Time';

DECLARE @DayStartLocal datetime2(0) = CAST(@LocalDate AS datetime2(0));
DECLARE @DayEndLocal   datetime2(0) = DATEADD(day, 1, @DayStartLocal);

DECLARE @DayStartUtc datetime2(3) =
    CONVERT(datetime2(3), (@DayStartLocal AT TIME ZONE @Tz) AT TIME ZONE 'UTC');

DECLARE @DayEndUtc datetime2(3) =
    CONVERT(datetime2(3), (@DayEndLocal AT TIME ZONE @Tz) AT TIME ZONE 'UTC');

;WITH Hours (n, hour_bucket_local) AS
(
    SELECT 0, @DayStartLocal
    UNION ALL
    SELECT n + 1, DATEADD(hour, 1, hour_bucket_local)
    FROM Hours
    WHERE n < 23
),
SessionsLocal AS
(
    SELECT
        s.session_id,
        (s.session_start_at AT TIME ZONE 'UTC' AT TIME ZONE @Tz) AS start_local,
        (COALESCE(s.session_end_at, SYSUTCDATETIME()) AT TIME ZONE 'UTC' AT TIME ZONE @Tz) AS end_local
    FROM dbo.chatbot_session s
    WHERE
        s.session_start_at < @DayEndUtc
        AND COALESCE(s.session_end_at, SYSUTCDATETIME()) >= @DayStartUtc
)
SELECT
    h.hour_bucket_local,
    SUM(CASE
            WHEN sl.start_local >= (h.hour_bucket_local AT TIME ZONE @Tz)
             AND sl.start_local <  (DATEADD(hour, 1, h.hour_bucket_local) AT TIME ZONE @Tz)
            THEN 1 ELSE 0
        END) AS sessions_started,
    SUM(CASE
            WHEN sl.start_local <  (DATEADD(hour, 1, h.hour_bucket_local) AT TIME ZONE @Tz)
             AND sl.end_local   >  (h.hour_bucket_local AT TIME ZONE @Tz)
            THEN 1 ELSE 0
        END) AS sessions_active
FROM Hours h
LEFT JOIN SessionsLocal sl
    ON sl.start_local < (DATEADD(hour, 1, h.hour_bucket_local) AT TIME ZONE @Tz)
   AND sl.end_local   > (h.hour_bucket_local AT TIME ZONE @Tz)
GROUP BY h.hour_bucket_local
ORDER BY h.hour_bucket_local
OPTION (MAXRECURSION 24);
