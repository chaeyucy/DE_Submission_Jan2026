/* =========================================================
   - Creates DB + tables (gold layer)
   - Inserts synthetic sample data:
       * 2 websites
       * 3 languages
       * 4 chatbot users
       * 2 website users
       * 5 conversations
       * messages + message_nlp
       * feedback + translated_feedback
       * user_id_mapping
   ========================================================= */

-- Create DB if not exists
IF DB_ID('ChatbotAnalytics') IS NULL
BEGIN
    EXEC('CREATE DATABASE ChatbotAnalytics;');
END
GO

USE ChatbotAnalytics;
GO

/* =========================
   Drop tables
   ========================= */
IF OBJECT_ID('dbo.translated_feedback','U') IS NOT NULL DROP TABLE dbo.translated_feedback;
IF OBJECT_ID('dbo.conversation_feedback','U') IS NOT NULL DROP TABLE dbo.conversation_feedback;
IF OBJECT_ID('dbo.message_nlp','U') IS NOT NULL DROP TABLE dbo.message_nlp;
IF OBJECT_ID('dbo.message','U') IS NOT NULL DROP TABLE dbo.message;
IF OBJECT_ID('dbo.chatbot_conversation','U') IS NOT NULL DROP TABLE dbo.chatbot_conversation;
IF OBJECT_ID('dbo.user_id_mapping','U') IS NOT NULL DROP TABLE dbo.user_id_mapping;
IF OBJECT_ID('dbo.website_user','U') IS NOT NULL DROP TABLE dbo.website_user;
IF OBJECT_ID('dbo.chatbot_user','U') IS NOT NULL DROP TABLE dbo.chatbot_user;
IF OBJECT_ID('dbo.website','U') IS NOT NULL DROP TABLE dbo.website;
IF OBJECT_ID('dbo.language','U') IS NOT NULL DROP TABLE dbo.language;
GO

/* =========================
   Create dimension tables
   ========================= */

CREATE TABLE dbo.language (
    language_id   INT          NOT NULL CONSTRAINT PK_language PRIMARY KEY,
    language      VARCHAR(50)  NOT NULL,
    active_flag   BIT          NOT NULL,
    active_start  DATETIME2(3) NOT NULL,
    active_end    DATETIME2(3) NULL
);
GO

CREATE TABLE dbo.website (
    website_id    BIGINT        NOT NULL CONSTRAINT PK_website PRIMARY KEY,
    website_name  VARCHAR(100)  NOT NULL,
    domain        VARCHAR(500)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    active_flag   BIT           NOT NULL,
    active_from   DATETIME2(3)  NOT NULL,
    active_end    DATETIME2(3)  NULL
);
GO

/* =========================
   Create user tables
   ========================= */

CREATE TABLE dbo.chatbot_user (
    chatbot_user_id  BIGINT       NOT NULL CONSTRAINT PK_chatbot_user PRIMARY KEY,
    website_id       BIGINT       NOT NULL,
    anonymous_id     VARCHAR(36)  NOT NULL,
	ip_address       VARBINARY(32) NOT NULL,
    first_active_at  DATETIME2(3) NOT NULL,
    last_active_at   DATETIME2(3) NOT NULL,
    CONSTRAINT FK_chatbot_user_website FOREIGN KEY (website_id) REFERENCES dbo.website(website_id),
    CONSTRAINT UQ_chatbot_user_website_anonymous UNIQUE (website_id, anonymous_id)
);
GO

CREATE TABLE dbo.website_user (
    website_user_id     BIGINT        NOT NULL CONSTRAINT PK_website_user PRIMARY KEY,
    website_id          BIGINT        NOT NULL,
    preferred_language  INT           NULL,
    hashed_phone        VARCHAR(128)  NOT NULL,
    hash_version        VARCHAR(50)   NOT NULL,
    active_flag         BIT           NOT NULL,
    active_from         DATETIME2(3)  NOT NULL,
    active_end          DATETIME2(3)  NOT NULL,
    CONSTRAINT FK_website_user_website FOREIGN KEY (website_id) REFERENCES dbo.website(website_id),
    CONSTRAINT FK_website_user_language FOREIGN KEY (preferred_language) REFERENCES dbo.language(language_id)
);
GO

CREATE TABLE dbo.user_id_mapping (
    chatbot_user_id  BIGINT       NOT NULL,
    website_user_id  BIGINT       NOT NULL,
    linked_at        DATETIME2(3) NOT NULL,
    unlinked_at      DATETIME2(3) NULL,
    CONSTRAINT PK_user_id_mapping PRIMARY KEY (chatbot_user_id, website_user_id, linked_at),
    CONSTRAINT FK_user_id_mapping_chatbot_user FOREIGN KEY (chatbot_user_id) REFERENCES dbo.chatbot_user(chatbot_user_id),
    CONSTRAINT FK_user_id_mapping_website_user FOREIGN KEY (website_user_id) REFERENCES dbo.website_user(website_user_id),
    CONSTRAINT CK_user_id_mapping_unlink_ge_link CHECK (unlinked_at IS NULL OR unlinked_at >= linked_at)
);
GO

CREATE UNIQUE INDEX UX_user_id_mapping_active
ON dbo.user_id_mapping(chatbot_user_id)
WHERE unlinked_at IS NULL;
GO

/* =========================
   Create conversation + message
   ========================= */

CREATE TABLE dbo.chatbot_conversation (
    conversation_id    UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_chatbot_conversation PRIMARY KEY,
    website_id         BIGINT           NOT NULL,
    chatbot_user_id    BIGINT           NOT NULL,
    entry_page_url     NVARCHAR(MAX)    NOT NULL,
    entry_page_type    VARCHAR(50)      NULL,
    channel            VARCHAR(10)      NOT NULL,
    os                 VARCHAR(50)      NOT NULL,
    browser            VARCHAR(50)      NOT NULL,
    device_type        VARCHAR(10)      NOT NULL,
    primary_intent     VARCHAR(500)     NULL,
    intent_confidence  FLOAT            NULL,
    status             VARCHAR(10)      NOT NULL,
    started_at         DATETIME2(3)     NOT NULL,
    ended_at           DATETIME2(3)     NULL,
    CONSTRAINT FK_chatbot_conversation_website FOREIGN KEY (website_id) REFERENCES dbo.website(website_id),
    CONSTRAINT FK_chatbot_conversation_chatbot_user FOREIGN KEY (chatbot_user_id) REFERENCES dbo.chatbot_user(chatbot_user_id)
);
GO

CREATE INDEX IX_conversation_user_time
ON dbo.chatbot_conversation(chatbot_user_id, started_at DESC);
GO

CREATE INDEX IX_conversation_website_status_time
ON dbo.chatbot_conversation(website_id, status, started_at DESC);
GO

CREATE TABLE dbo.message (
    message_id           BIGINT          NOT NULL CONSTRAINT PK_message PRIMARY KEY,
    conversation_id      UNIQUEIDENTIFIER NOT NULL,
    message_sequence     INT             NOT NULL,
    sent_at              DATETIME2(3)    NOT NULL,
    role                 VARCHAR(5)      NOT NULL,   -- bot/user
    content_type         VARCHAR(10)     NOT NULL,   -- text/image
    content_raw          NVARCHAR(MAX)   NOT NULL,
    content_translated   NVARCHAR(MAX)   NULL,
    language_id          INT             NOT NULL,
    response_latency_ms  INT             NULL,
    CONSTRAINT FK_message_conversation FOREIGN KEY (conversation_id) REFERENCES dbo.chatbot_conversation(conversation_id),
    CONSTRAINT FK_message_language FOREIGN KEY (language_id) REFERENCES dbo.language(language_id),
    CONSTRAINT UQ_message_conversation_sequence UNIQUE (conversation_id, message_sequence)
);
GO

CREATE INDEX IX_message_conversation_time
ON dbo.message(conversation_id, sent_at);
GO

/* =========================
   Create message_nlp
   ========================= */

CREATE TABLE dbo.message_nlp (
    message_id         BIGINT        NOT NULL,
    nlp_version        VARCHAR(50)   NOT NULL,
    processed_at       DATETIME2(3)  NOT NULL,
    processor          VARCHAR(50)   NOT NULL,
    status             VARCHAR(20)   NOT NULL,
    error_code         VARCHAR(50)   NULL,
    error_detail       VARCHAR(500)  NULL,
    sentiment_score    FLOAT         NULL,
    intent             VARCHAR(100)  NULL,
    intent_confidence  FLOAT         NULL,
    entities           NVARCHAR(MAX) NULL,
    CONSTRAINT PK_message_nlp PRIMARY KEY (message_id, nlp_version),
    CONSTRAINT FK_message_nlp_message FOREIGN KEY (message_id) REFERENCES dbo.message(message_id),
    CONSTRAINT CK_message_nlp_entities_json CHECK (entities IS NULL OR ISJSON(entities) = 1)
);
GO

CREATE INDEX IX_message_nlp_version_time
ON dbo.message_nlp(nlp_version, processed_at DESC);
GO

/* =========================
   Create feedback tables
   ========================= */

CREATE TABLE dbo.conversation_feedback (
    feedback_id      BIGINT           NOT NULL CONSTRAINT PK_conversation_feedback PRIMARY KEY,
    conversation_id  UNIQUEIDENTIFIER NOT NULL,
    rating_score     TINYINT          NOT NULL,
    feedback_raw     NVARCHAR(MAX)    NULL,
    language_id      INT              NULL,
    created_at       DATETIME2(3)     NOT NULL,
    CONSTRAINT FK_feedback_conversation FOREIGN KEY (conversation_id) REFERENCES dbo.chatbot_conversation(conversation_id),
    CONSTRAINT FK_feedback_language FOREIGN KEY (language_id) REFERENCES dbo.language(language_id),
    CONSTRAINT UQ_feedback_conversation UNIQUE (conversation_id),
    CONSTRAINT CK_feedback_language_when_text CHECK (feedback_raw IS NULL OR language_id IS NOT NULL)
);
GO

CREATE TABLE dbo.translated_feedback (
    feedback_id           BIGINT         NOT NULL,
    translation_version   VARCHAR(50)    NOT NULL,
    translated_feedback   NVARCHAR(MAX)  NOT NULL,
    translated_at         DATETIME2(3)   NOT NULL,
    status                VARCHAR(20)    NOT NULL,
    error_code            VARCHAR(50)    NULL,
    CONSTRAINT PK_translated_feedback PRIMARY KEY (feedback_id, translation_version),
    CONSTRAINT FK_translated_feedback_feedback FOREIGN KEY (feedback_id) REFERENCES dbo.conversation_feedback(feedback_id)
);
GO

