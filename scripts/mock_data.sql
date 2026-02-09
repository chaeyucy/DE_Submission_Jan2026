-- Languages
INSERT INTO dbo.language(language_id, language, active_flag, active_start, active_end)
VALUES
 (1, 'English', 1, '2025-01-01', NULL),
 (2, 'Chinese', 1, '2025-01-01', NULL),
 (3, 'Malay',   1, '2025-01-01', NULL);

-- Websites
INSERT INTO dbo.website(website_id, website_name, domain, category, active_flag, active_from, active_end)
VALUES
 (1001, 'Site A', 'https://site-a.example', 'Retail', 1, '2025-01-01', NULL),
 (1002, 'Site B', 'https://site-b.example', 'Support', 1, '2025-01-01', NULL);

-- Chatbot users (4 users across 2 websites)
INSERT INTO dbo.chatbot_user(chatbot_user_id, website_id, anonymous_id, first_active_at, last_active_at)
VALUES
 (2001, 1001, 'a3c1d2e3-1111-2222-3333-444455556666', '2026-02-01T09:00:00', '2026-02-06T10:00:00'),
 (2002, 1001, 'b4d2e3f4-1111-2222-3333-444455556666', '2026-02-03T11:00:00', '2026-02-06T12:00:00'),
 (2003, 1002, 'c5e3f4a5-1111-2222-3333-444455556666', '2026-02-04T08:30:00', '2026-02-06T09:30:00'),
 (2004, 1002, 'd6f4a5b6-1111-2222-3333-444455556666', '2026-02-05T15:00:00', '2026-02-06T16:00:00');

-- Website users
INSERT INTO dbo.website_user(website_user_id, website_id, preferred_language, hashed_phone, hash_version, active_flag, active_from, active_end)
VALUES
 (3001, 1001, 1, 'sha256:9f86d081884c7d659a2feaa0c55ad015...', 'v1', 1, '2025-01-01', '2099-12-31'),
 (3002, 1002, 2, 'sha256:2d711642b726b04401627ca9fbac32f5...', 'v1', 1, '2025-01-01', '2099-12-31');

-- 5 Conversations with fixed GUIDs
DECLARE @c1 UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
DECLARE @c2 UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
DECLARE @c3 UNIQUEIDENTIFIER = '33333333-3333-3333-3333-333333333333';
DECLARE @c4 UNIQUEIDENTIFIER = '44444444-4444-4444-4444-444444444444';
DECLARE @c5 UNIQUEIDENTIFIER = '55555555-5555-5555-5555-555555555555';

INSERT INTO dbo.chatbot_conversation(
    conversation_id, website_id, chatbot_user_id,
    entry_page_url, entry_page_type, channel, os, browser, device_type,
    primary_intent, intent_confidence, status, started_at, ended_at
)
VALUES
 (@c1, 1001, 2001, N'https://site-a.example/home', 'Homepage', 'Web', 'Windows 11', 'Google Chrome', 'PC',
  'Order Status', 0.91, 'ended', '2026-02-06T09:10:00', '2026-02-06T09:15:30'),
 (@c2, 1001, 2001, N'https://site-a.example/faq', 'Q&A', 'Web', 'Windows 11', 'Google Chrome', 'PC',
  'Return Policy', 0.83, 'ended', '2026-02-06T10:20:00', '2026-02-06T10:29:10'),
 (@c3, 1001, 2002, N'https://site-a.example/product/123', 'Product', 'Web', 'Mac OS X', 'MS Edge', 'PC',
  NULL, NULL, 'abandoned', '2026-02-06T12:05:00', NULL),
 (@c4, 1002, 2003, N'https://site-b.example/support', 'Support', 'Web', 'Android', 'Google Chrome', 'Mobile',
  'Account Login', 0.77, 'ended', '2026-02-06T09:05:00', '2026-02-06T09:12:40'),
 (@c5, 1002, 2004, N'https://site-b.example/support/billing', 'Support', 'Web', 'iOS', 'Safari', 'Mobile',
  'Billing Issue', 0.88, 'error', '2026-02-06T16:10:00', '2026-02-06T16:11:00');

-- Messages
-- Convention: role=user/bot, content_type=text, language_id varies
INSERT INTO dbo.message(message_id, conversation_id, message_sequence, sent_at, role, content_type, content_raw, content_translated, language_id, response_latency_ms)
VALUES
 -- c1 (English)
 (400001, @c1, 1, '2026-02-06T09:10:05', 'user', 'text', N'Where is my order #A123?', NULL, 1, NULL),
 (400002, @c1, 2, '2026-02-06T09:10:06', 'bot',  'text', N'Let me check that for you. What is your email?', NULL, 1, 850),
 (400003, @c1, 3, '2026-02-06T09:10:30', 'user', 'text', N'me@example.com', NULL, 1, NULL),
 (400004, @c1, 4, '2026-02-06T09:10:31', 'bot',  'text', N'Your order A123 is out for delivery today.', NULL, 1, 920),

 -- c2 (Chinese, English translation available)
 (400010, @c2, 1, '2026-02-06T10:20:10', 'user', 'text', N'你们的退货政策是什么？', N'What is your return policy?', 2, NULL),
 (400011, @c2, 2, '2026-02-06T10:20:11', 'bot',  'text', N'我们支持7天无理由退货。需要我发链接吗？', N'We support 7-day returns. Want the link?', 2, 780),

 -- c3 (English, abandoned)
 (400020, @c3, 1, '2026-02-06T12:05:05', 'user', 'text', N'Is this item back in stock?', NULL, 1, NULL),
 (400021, @c3, 2, '2026-02-06T12:05:06', 'bot',  'text', N'I can help—what is your preferred size?', NULL, 1, 650),

 -- c4 (Malay)
 (400030, @c4, 1, '2026-02-06T09:05:10', 'user', 'text', N'Saya tidak boleh log masuk ke akaun saya.', N'I cannot log into my account.', 3, NULL),
 (400031, @c4, 2, '2026-02-06T09:05:11', 'bot',  'text', N'Boleh saya tahu mesej ralat yang dipaparkan?', N'What error message do you see?', 3, 540),

 -- c5 (English, error scenario)
 (400040, @c5, 1, '2026-02-06T16:10:10', 'user', 'text', N'I was charged twice this month.', NULL, 1, NULL),
 (400041, @c5, 2, '2026-02-06T16:10:11', 'bot',  'text', N'Sorry—something went wrong retrieving billing data.', NULL, 1, 1200);

-- Message NLP
INSERT INTO dbo.message_nlp(message_id, nlp_version, processed_at, processor, status, error_code, error_detail, sentiment_score, intent, intent_confidence, entities)
VALUES
 (400001, 'intent-v1', '2026-02-06T09:10:08', 'nlp_job', 'success', NULL, NULL, 0.05, 'Order Status', 0.92,
  N'[{ "type":"order_id", "value":"A123", "confidence":0.95 }]'),
 (400010, 'intent-v1', '2026-02-06T10:20:13', 'nlp_job', 'success', NULL, NULL, 0.00, 'Return Policy', 0.84,
  N'[]'),
 (400030, 'intent-v1', '2026-02-06T09:05:14', 'nlp_job', 'success', NULL, NULL, -0.35, 'Account Login', 0.79,
  N'[]'),
 (400040, 'intent-v1', '2026-02-06T16:10:15', 'nlp_job', 'partial', 'BILLING_LOOKUP_FAIL', 'Tool unavailable', -0.60, 'Billing Issue', 0.72,
  N'[]'),
 (400040, 'intent-v2', '2026-02-06T16:10:20', 'nlp_job', 'success', NULL, NULL, -0.55, 'Billing Dispute', 0.86,
  N'[]');

-- Feedback (3 conversations have feedback)
INSERT INTO dbo.conversation_feedback(feedback_id, conversation_id, rating_score, feedback_raw, language_id, created_at)
VALUES
 (500001, @c1, 5, N'Quick and helpful.', 1, '2026-02-06T09:16:00'),
 (500002, @c2, 4, N'回答很清楚。', 2, '2026-02-06T10:30:00'),
 (500003, @c5, 1, N'It failed when I needed it most.', 1, '2026-02-06T16:12:00');

-- Translated feedback (versioned)
INSERT INTO dbo.translated_feedback(feedback_id, translation_version, translated_feedback, translated_at, status, error_code)
VALUES
 (500002, 'mt-v1', N'The answer was very clear.', '2026-02-06T10:31:00', 'success', NULL);

-- User mapping: user logs into a website account midstream (example: chatbot_user 2003 links to website_user 3002)
INSERT INTO dbo.user_id_mapping(chatbot_user_id, website_user_id, linked_at, unlinked_at)
VALUES
 (2003, 3002, '2026-02-06T09:06:00', NULL);

PRINT 'Initialization complete.';
GO
