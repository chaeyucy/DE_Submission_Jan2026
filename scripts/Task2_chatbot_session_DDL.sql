-- To support fallback/error count in aggregated table
CREATE TABLE dbo.message_bot_label (
  message_id     BIGINT       NOT NULL,
  label_version  VARCHAR(50)  NOT NULL,
  labeled_at     DATETIME2(3) NOT NULL CONSTRAINT DF_msg_label DEFAULT SYSUTCDATETIME(),
  reply_type     VARCHAR(20)  NOT NULL,
  label_source   VARCHAR(20)  NOT NULL,
  is_current     BIT          NOT NULL CONSTRAINT DF_lbl_is_current DEFAULT 0,
  notes          VARCHAR(200) NULL,
  created_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  updated_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  created_by     VARCHAR(50)  NOT NULL default 'CW',
  updated_by     VARCHAR(50)  NOT NULL default 'CW',

  CONSTRAINT PK_message_bot_label PRIMARY KEY (message_id, label_version),
  CONSTRAINT FK_lbl_msg FOREIGN KEY (message_id) REFERENCES dbo.[message](message_id),
  CONSTRAINT CK_lbl_type CHECK (reply_type IN ('normal','fallback','error','handoff_prompt'))
);
GO

-- Ensure only one current label per message
CREATE UNIQUE INDEX UX_lbl_one_current_per_message
ON dbo.message_bot_label(message_id)
WHERE is_current = 1;
GO

-- One row per conversation with the key attributes and rollups needed for metric computation
IF OBJECT_ID('dbo.chatbot_session','U') IS NOT NULL DROP TABLE dbo.chatbot_session;
GO

CREATE TABLE dbo.chatbot_session (
    session_id                 UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),

    conversation_id            UNIQUEIDENTIFIER NOT NULL,
    website_id                 BIGINT           NOT NULL,
    chatbot_user_id            BIGINT           NOT NULL,

    session_start_at           DATETIME2(3)     NOT NULL,
    session_end_at             DATETIME2(3)     NULL,
    duration_seconds           INT              NULL,

    -- Conversation state
    status                     VARCHAR(10)      NOT NULL,  -- ended/abandoned/error/active etc.
    traffic_type               VARCHAR(10)      NOT NULL CONSTRAINT DF_chatbot_session_traffic DEFAULT 'prod', -- prod/test/bot/internal

    -- Metric 2: escalation
    escalated_to_agent         BIT              NOT NULL CONSTRAINT DF_chatbot_session_escalated DEFAULT 0,
    escalated_at               DATETIME2(3)     NULL,
    escalation_channel         VARCHAR(20)      NULL, -- live_chat/ticket/hotline/other

    -- Metric 3: feedback
    has_feedback               BIT              NOT NULL CONSTRAINT DF_chatbot_session_has_feedback DEFAULT 0,
    rating_score               TINYINT          NULL,

    -- Message counts -- Exclude “non-engaged” conversations
    user_message_count         INT              NOT NULL CONSTRAINT DF_chatbot_session_user_cnt DEFAULT 0,
    bot_message_count          INT              NOT NULL CONSTRAINT DF_chatbot_session_bot_cnt DEFAULT 0,

    -- Metric 1: fallback/error counts at session level
    bot_fallback_count         INT              NOT NULL CONSTRAINT DF_chatbot_session_fb_cnt DEFAULT 0,
    bot_error_count            INT              NOT NULL CONSTRAINT DF_chatbot_session_err_cnt DEFAULT 0,

    -- Metric 1: latency rollups at session level
    bot_latency_avg_ms         FLOAT            NULL,
    bot_latency_p95_ms         INT              NULL,
    bot_latency_p99_ms         INT              NULL,
    first_bot_response_ms      INT              NULL,

    -- bot/internal test/spam traffic detection
    ip_address                    VARBINARY(32)    NULL,

    created_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by     VARCHAR(50)  NOT NULL default 'CW',
    updated_by     VARCHAR(50)  NOT NULL default 'CW',

     CONSTRAINT PK_chatbot_session PRIMARY KEY(session_id),
	
	CONSTRAINT UQ_chatbot_session_conversation UNIQUE (conversation_id),

    CONSTRAINT FK_chatbot_session_conversation
        FOREIGN KEY (conversation_id) REFERENCES dbo.chatbot_conversation(conversation_id),

    CONSTRAINT FK_chatbot_session_website
        FOREIGN KEY (website_id) REFERENCES dbo.website(website_id),

    CONSTRAINT FK_chatbot_session_chatbot_user
        FOREIGN KEY (chatbot_user_id) REFERENCES dbo.chatbot_user(chatbot_user_id),

    CONSTRAINT CK_chatbot_session_escalation_time
        CHECK (escalated_to_agent = 0 OR escalated_at IS NOT NULL)
);
GO

-- Indexes
CREATE INDEX IX_chatbot_session_website_time
ON dbo.chatbot_session(website_id, session_start_at DESC);
GO

CREATE INDEX IX_chatbot_session_user_time
ON dbo.chatbot_session(chatbot_user_id, session_start_at DESC);
GO

CREATE INDEX IX_chatbot_session_status_time
ON dbo.chatbot_session(status, session_start_at DESC);
GO

CREATE INDEX IX_chatbot_session_escalated
ON dbo.chatbot_session(website_id, escalated_to_agent, session_start_at DESC);
GO

CREATE INDEX IX_chatbot_session_rating
ON dbo.chatbot_session(website_id, rating_score, session_start_at DESC);
GO

-- To keep track of historical escalations
IF OBJECT_ID('dbo.session_escalation','U') IS NOT NULL DROP TABLE dbo.session_escalation;
GO

CREATE TABLE dbo.session_escalation (
    escalation_id        BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_session_escalation PRIMARY KEY,
    session_id           UNIQUEIDENTIFIER NOT NULL,
    escalated_at         DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    escalation_channel   VARCHAR(20)      NOT NULL, -- live_chat/ticket/hotline/other
    escalation_reason    VARCHAR(100)     NULL,
	created_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by     VARCHAR(50)  NOT NULL default 'CW',
    updated_by     VARCHAR(50)  NOT NULL default 'CW',

    CONSTRAINT FK_session_escalation_session
        FOREIGN KEY (session_id) REFERENCES dbo.chatbot_session(session_id)
);
GO

CREATE INDEX IX_session_escalation_session_time
ON dbo.session_escalation(session_id, escalated_at DESC);
GO