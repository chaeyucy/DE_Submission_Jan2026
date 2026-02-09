/* ============================================================
UPSERT (UPDATE existing or INSERT new) from staging layer into gold layer
============================================================ */

USE ChatbotAnalytics;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

/* =========================
          language
   ========================= */
-- UPDATE existing
UPDATE tgt
SET
    tgt.[language]     = src.[language],
    tgt.active_flag    = src.active_flag,
    tgt.active_start   = src.active_start,
    tgt.active_end     = src.active_end,
    tgt.updated_at     = src.updated_at,
    tgt.updated_by     = src.updated_by
FROM dbo.[language] tgt
JOIN stg.[language] src
  ON src.language_id = tgt.language_id;

-- INSERT new
INSERT INTO dbo.[language] (
    language_id, [language], active_flag, active_start, active_end,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.language_id, src.[language], src.active_flag, src.active_start, src.active_end,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.[language] src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.[language] tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.language_id = src.language_id
);


/* =========================
          website
   ========================= */

UPDATE tgt
SET
    tgt.website_name = src.website_name,
    tgt.domain       = src.domain,
    tgt.category     = src.category,
    tgt.active_flag  = src.active_flag,
    tgt.active_from  = src.active_from,
    tgt.active_end   = src.active_end,
    tgt.updated_at   = src.updated_at,
    tgt.updated_by   = src.updated_by
FROM dbo.website tgt
JOIN stg.website src
  ON src.website_id = tgt.website_id;

INSERT INTO dbo.website (
    website_id, website_name, domain, category,
    active_flag, active_from, created_at, updated_at, created_by, updated_by, active_end
)
SELECT
    src.website_id, src.website_name, src.domain, src.category,
    src.active_flag, src.active_from, src.created_at, src.updated_at, src.created_by, src.updated_by, src.active_end
FROM stg.website src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.website tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.website_id = src.website_id
);


/* =========================
       chatbot_user
   ========================= */

UPDATE tgt
SET
    tgt.website_id      = src.website_id,
    tgt.anonymous_id    = src.anonymous_id,
    tgt.ip_address      = src.ip_address,
    tgt.first_active_at = src.first_active_at,
    tgt.last_active_at  = src.last_active_at,
    tgt.updated_at      = src.updated_at,
    tgt.updated_by      = src.updated_by
FROM dbo.chatbot_user tgt
JOIN stg.chatbot_user src
  ON src.chatbot_user_id = tgt.chatbot_user_id;

INSERT INTO dbo.chatbot_user (
    chatbot_user_id, website_id, anonymous_id, ip_address,
    first_active_at, last_active_at,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.chatbot_user_id, src.website_id, src.anonymous_id, src.ip_address,
    src.first_active_at, src.last_active_at,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.chatbot_user src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.chatbot_user tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.chatbot_user_id = src.chatbot_user_id
);


/* =========================
        website_user
   ========================= */

UPDATE tgt
SET
    tgt.website_id         = src.website_id,
    tgt.preferred_language = src.preferred_language,
    tgt.hashed_phone       = src.hashed_phone,
    tgt.hash_version       = src.hash_version,
    tgt.active_flag        = src.active_flag,
    tgt.active_from        = src.active_from,
    tgt.active_end         = src.active_end,
    tgt.updated_at         = src.updated_at,
    tgt.updated_by         = src.updated_by
FROM dbo.website_user tgt
JOIN stg.website_user src
  ON src.website_user_id = tgt.website_user_id;

INSERT INTO dbo.website_user (
    website_user_id, website_id, preferred_language,
    hashed_phone, hash_version,
    active_flag, active_from, active_end,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.website_user_id, src.website_id, src.preferred_language,
    src.hashed_phone, src.hash_version,
    src.active_flag, src.active_from, src.active_end,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.website_user src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.website_user tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.website_user_id = src.website_user_id
);


/* =========================
       user_id_mapping 
   =========================
   - UPDATE existing row (mostly audit/unlinked_at)
   - INSERT new row if missing
*/

UPDATE tgt
SET
    tgt.unlinked_at = src.unlinked_at,
    tgt.updated_at  = src.updated_at,
    tgt.updated_by  = src.updated_by
FROM dbo.user_id_mapping tgt
JOIN stg.user_id_mapping src
  ON src.chatbot_user_id = tgt.chatbot_user_id
 AND src.website_user_id = tgt.website_user_id
 AND src.linked_at       = tgt.linked_at;

INSERT INTO dbo.user_id_mapping (
    chatbot_user_id, website_user_id, linked_at, unlinked_at,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.chatbot_user_id, src.website_user_id, src.linked_at, src.unlinked_at,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.user_id_mapping src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.user_id_mapping tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.chatbot_user_id = src.chatbot_user_id
      AND tgt.website_user_id = src.website_user_id
      AND tgt.linked_at       = src.linked_at
);


/* =========================
      chatbot_conversation
   ========================= */

UPDATE tgt
SET
    tgt.website_id        = src.website_id,
    tgt.chatbot_user_id   = src.chatbot_user_id,
    tgt.entry_page_url    = src.entry_page_url,
    tgt.entry_page_type   = src.entry_page_type,
    tgt.channel           = src.channel,
    tgt.os                = src.os,
    tgt.browser           = src.browser,
    tgt.device_type       = src.device_type,
    tgt.primary_intent    = src.primary_intent,
    tgt.intent_confidence = src.intent_confidence,
    tgt.status            = src.status,
    tgt.started_at        = src.started_at,
    tgt.ended_at          = src.ended_at,
    tgt.updated_at        = src.updated_at,
    tgt.updated_by        = src.updated_by
FROM dbo.chatbot_conversation tgt
JOIN stg.chatbot_conversation src
  ON src.conversation_id = tgt.conversation_id;

INSERT INTO dbo.chatbot_conversation (
    conversation_id, website_id, chatbot_user_id,
    entry_page_url, entry_page_type,
    channel, os, browser, device_type,
    primary_intent, intent_confidence, status,
    started_at, ended_at,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.conversation_id, src.website_id, src.chatbot_user_id,
    src.entry_page_url, src.entry_page_type,
    src.channel, src.os, src.browser, src.device_type,
    src.primary_intent, src.intent_confidence, src.status,
    src.started_at, src.ended_at,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.chatbot_conversation src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.chatbot_conversation tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.conversation_id = src.conversation_id
);


/* =========================
           message
   =========================
   
*/

UPDATE tgt
SET
    tgt.conversation_id     = src.conversation_id,
    tgt.message_sequence    = src.message_sequence,
    tgt.sent_at             = src.sent_at,
    tgt.role                = src.role,
    tgt.content_type        = src.content_type,
    tgt.content_raw         = src.content_raw,
    tgt.content_translated  = src.content_translated,
    tgt.language_id         = src.language_id,
    tgt.response_latency_ms = src.response_latency_ms,
    tgt.updated_at          = src.updated_at,
    tgt.updated_by          = src.updated_by
FROM dbo.[message] tgt
JOIN stg.[message] src
  ON src.message_id = tgt.message_id;

INSERT INTO dbo.[message] (
    message_id, conversation_id, message_sequence, sent_at,
    role, content_type, content_raw, content_translated,
    language_id, response_latency_ms,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.message_id, src.conversation_id, src.message_sequence, src.sent_at,
    src.role, src.content_type, src.content_raw, src.content_translated,
    src.language_id, src.response_latency_ms,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.[message] src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.[message] tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.message_id = src.message_id
);


/* =========================
         message_nlp
   ========================= */

UPDATE tgt
SET
    tgt.processed_at      = src.processed_at,
    tgt.processor         = src.processor,
    tgt.status            = src.status,
    tgt.error_code        = src.error_code,
    tgt.error_detail      = src.error_detail,
    tgt.sentiment_score   = src.sentiment_score,
    tgt.intent            = src.intent,
    tgt.intent_confidence = src.intent_confidence,
    tgt.entities          = src.entities,
    tgt.updated_at        = src.updated_at,
    tgt.updated_by        = src.updated_by
FROM dbo.message_nlp tgt
JOIN stg.message_nlp src
  ON src.message_id  = tgt.message_id
 AND src.nlp_version = tgt.nlp_version;

INSERT INTO dbo.message_nlp (
    message_id, nlp_version, processed_at, processor, status,
    error_code, error_detail,
    sentiment_score, intent, intent_confidence, entities,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.message_id, src.nlp_version, src.processed_at, src.processor, src.status,
    src.error_code, src.error_detail,
    src.sentiment_score, src.intent, src.intent_confidence, src.entities,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.message_nlp src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.message_nlp tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.message_id  = src.message_id
      AND tgt.nlp_version = src.nlp_version
);


/* =========================
     conversation_feedback
   =========================
   must not create a second feedback row for the same conversation.
*/

UPDATE tgt
SET
    tgt.conversation_id = src.conversation_id,
    tgt.rating_score    = src.rating_score,
    tgt.feedback_raw    = src.feedback_raw,
    tgt.language_id     = src.language_id,
    tgt.feedback_at     = src.feedback_at,
    tgt.updated_at      = src.updated_at,
    tgt.updated_by      = src.updated_by
FROM dbo.conversation_feedback tgt
JOIN stg.conversation_feedback src
  ON src.feedback_id = tgt.feedback_id;

INSERT INTO dbo.conversation_feedback (
    feedback_id, conversation_id, rating_score,
    feedback_raw, language_id, feedback_at,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.feedback_id, src.conversation_id, src.rating_score,
    src.feedback_raw, src.language_id, src.feedback_at,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.conversation_feedback src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.conversation_feedback tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.feedback_id = src.feedback_id
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.conversation_feedback tgt2 WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt2.conversation_id = src.conversation_id
);


/* =========================
      translated_feedback 
   ========================= */

UPDATE tgt
SET
    tgt.translated_feedback = src.translated_feedback,
    tgt.translated_at       = src.translated_at,
    tgt.status              = src.status,
    tgt.error_code          = src.error_code,
    tgt.updated_at          = src.updated_at,
    tgt.updated_by          = src.updated_by
FROM dbo.translated_feedback tgt
JOIN stg.translated_feedback src
  ON src.feedback_id = tgt.feedback_id
 AND src.translation_version = tgt.translation_version;

INSERT INTO dbo.translated_feedback (
    feedback_id, translation_version, translated_feedback,
    translated_at, status, error_code,
    created_at, updated_at, created_by, updated_by
)
SELECT
    src.feedback_id, src.translation_version, src.translated_feedback,
    src.translated_at, src.status, src.error_code,
    src.created_at, src.updated_at, src.created_by, src.updated_by
FROM stg.translated_feedback src
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.translated_feedback tgt WITH (UPDLOCK, HOLDLOCK)
    WHERE tgt.feedback_id = src.feedback_id
      AND tgt.translation_version = src.translation_version
);

COMMIT;
GO
