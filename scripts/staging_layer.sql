IF DB_ID('ChatbotAnalytics') IS NULL
BEGIN
    EXEC('CREATE DATABASE ChatbotAnalytics;');
END
GO

USE ChatbotAnalytics;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg AUTHORIZATION dbo;');
END
GO


USE ChatbotAnalytics;
GO

/* Drop staging tables (optional for dev) */
IF OBJECT_ID('stg.translated_feedback','U') IS NOT NULL DROP TABLE stg.translated_feedback;
IF OBJECT_ID('stg.conversation_feedback','U') IS NOT NULL DROP TABLE stg.conversation_feedback;
IF OBJECT_ID('stg.message_nlp','U') IS NOT NULL DROP TABLE stg.message_nlp;
IF OBJECT_ID('stg.message','U') IS NOT NULL DROP TABLE stg.message;
IF OBJECT_ID('stg.chatbot_conversation','U') IS NOT NULL DROP TABLE stg.chatbot_conversation;
IF OBJECT_ID('stg.user_id_mapping','U') IS NOT NULL DROP TABLE stg.user_id_mapping;
IF OBJECT_ID('stg.website_user','U') IS NOT NULL DROP TABLE stg.website_user;
IF OBJECT_ID('stg.chatbot_user','U') IS NOT NULL DROP TABLE stg.chatbot_user;
IF OBJECT_ID('stg.website','U') IS NOT NULL DROP TABLE stg.website;
IF OBJECT_ID('stg.language','U') IS NOT NULL DROP TABLE stg.language;
GO

CREATE TABLE stg.language (
    language_id   INT          NOT NULL,
    language      VARCHAR(50)  NOT NULL,
    active_flag   BIT          NOT NULL,
    active_start  DATETIME2(3) NOT NULL,
    active_end    DATETIME2(3) NULL,
    created_at    DATETIME2(3) NOT NULL,
    updated_at    DATETIME2(3) NOT NULL,
    created_by    VARCHAR(50)  NOT NULL,
    updated_by    VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_stg_language PRIMARY KEY (language_id)
);
GO

CREATE TABLE stg.website (
    website_id    BIGINT        NOT NULL,
    website_name  VARCHAR(100)  NOT NULL,
    domain        VARCHAR(500)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    active_flag   BIT           NOT NULL,
    active_from   DATETIME2(3)  NOT NULL,
    created_at    DATETIME2(3)  NOT NULL,
    updated_at    DATETIME2(3)  NOT NULL,
    created_by    VARCHAR(50)   NOT NULL,
    updated_by    VARCHAR(50)   NOT NULL,
    active_end    DATETIME2(3)  NULL,
    CONSTRAINT PK_stg_website PRIMARY KEY (website_id)
);
GO

CREATE TABLE stg.chatbot_user (
    chatbot_user_id  BIGINT       NOT NULL,
    website_id       BIGINT       NOT NULL,
    anonymous_id     VARCHAR(36)  NOT NULL,
    ip_address       VARBINARY(32) NOT NULL,
    first_active_at  DATETIME2(3) NOT NULL,
    last_active_at   DATETIME2(3) NOT NULL,
    created_at       DATETIME2(3) NOT NULL,
    updated_at       DATETIME2(3) NOT NULL,
    created_by       VARCHAR(50)  NOT NULL,
    updated_by       VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_stg_chatbot_user PRIMARY KEY (chatbot_user_id)
);
GO

CREATE TABLE stg.website_user (
    website_user_id     BIGINT        NOT NULL,
    website_id          BIGINT        NOT NULL,
    preferred_language  INT           NULL,
    hashed_phone        VARCHAR(128)  NOT NULL,
    hash_version        VARCHAR(50)   NOT NULL,
    active_flag         BIT           NOT NULL,
    active_from         DATETIME2(3)  NOT NULL,
    active_end          DATETIME2(3)  NOT NULL,
    created_at          DATETIME2(3)  NOT NULL,
    updated_at          DATETIME2(3)  NOT NULL,
    created_by          VARCHAR(50)   NOT NULL,
    updated_by          VARCHAR(50)   NOT NULL,
    CONSTRAINT PK_stg_website_user PRIMARY KEY (website_user_id)
);
GO

CREATE TABLE stg.user_id_mapping (
    chatbot_user_id  BIGINT       NOT NULL,
    website_user_id  BIGINT       NOT NULL,
    linked_at        DATETIME2(3) NOT NULL,
    unlinked_at      DATETIME2(3) NULL,
    created_at       DATETIME2(3) NOT NULL,
    updated_at       DATETIME2(3) NOT NULL,
    created_by       VARCHAR(50)  NOT NULL,
    updated_by       VARCHAR(50)  NOT NULL
    
	CONSTRAINT PK_stg_user_id_mapping PRIMARY KEY (chatbot_user_id, website_user_id, linked_at)
);
GO

CREATE TABLE stg.chatbot_conversation (
    conversation_id    UNIQUEIDENTIFIER NOT NULL,
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
    created_at         DATETIME2(3)     NOT NULL,
    updated_at         DATETIME2(3)     NOT NULL,
    created_by         VARCHAR(50)      NOT NULL,
    updated_by         VARCHAR(50)      NOT NULL,
    CONSTRAINT PK_stg_chatbot_conversation PRIMARY KEY (conversation_id)
);
GO

CREATE TABLE stg.message (
    message_id           BIGINT          NOT NULL,
    conversation_id      UNIQUEIDENTIFIER NOT NULL,
    message_sequence     INT             NOT NULL,
    sent_at              DATETIME2(3)    NOT NULL,
    role                 VARCHAR(5)      NOT NULL,
    content_type         VARCHAR(10)     NOT NULL,
    content_raw          NVARCHAR(MAX)   NOT NULL,
    content_translated   NVARCHAR(MAX)   NULL,
    language_id          INT             NOT NULL,
    response_latency_ms  INT             NULL,
    created_at           DATETIME2(3)    NOT NULL,
    updated_at           DATETIME2(3)    NOT NULL,
    created_by           VARCHAR(50)     NOT NULL,
    updated_by           VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_stg_message PRIMARY KEY (message_id)
);
GO

CREATE TABLE stg.message_nlp (
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
    created_at         DATETIME2(3)  NOT NULL,
    updated_at         DATETIME2(3)  NOT NULL,
    created_by         VARCHAR(50)   NOT NULL,
    updated_by         VARCHAR(50)   NOT NULL
);
GO

CREATE TABLE stg.conversation_feedback (
    feedback_id      BIGINT           NOT NULL,
    conversation_id  UNIQUEIDENTIFIER NOT NULL,
    rating_score     TINYINT          NOT NULL,
    feedback_raw     NVARCHAR(MAX)    NULL,
    language_id      INT              NULL,
    feedback_at      DATETIME2(3)     NOT NULL,
    created_at       DATETIME2(3)     NOT NULL,
    updated_at       DATETIME2(3)     NOT NULL,
    created_by       VARCHAR(50)      NOT NULL,
    updated_by       VARCHAR(50)      NOT NULL,
    CONSTRAINT PK_stg_conversation_feedback PRIMARY KEY (feedback_id)
);
GO

CREATE TABLE stg.translated_feedback (
    feedback_id           BIGINT         NOT NULL,
    translation_version   VARCHAR(50)    NOT NULL,
    translated_feedback   NVARCHAR(MAX)  NOT NULL,
    translated_at         DATETIME2(3)   NOT NULL,
    status                VARCHAR(20)    NOT NULL,
    error_code            VARCHAR(50)    NULL,
    created_at            DATETIME2(3)   NOT NULL,
    updated_at            DATETIME2(3)   NOT NULL,
    created_by            VARCHAR(50)    NOT NULL,
    updated_by            VARCHAR(50)    NOT NULL
);
GO
