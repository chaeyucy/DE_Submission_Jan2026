USE ChatbotAnalytics;
GO

-- Languages
INSERT INTO dbo.language(language_id, language, active_flag, active_start, active_end, created_at, updated_at, created_by, updated_by)
VALUES
 (1, 'English', 1, '2025-01-01', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (2, 'Chinese', 1, '2025-01-01', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (3, 'Malay',   1, '2025-01-01', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- Websites
INSERT INTO dbo.website(website_id, website_name, domain, category, active_flag, active_from, active_end, created_at, updated_at, created_by, updated_by)
VALUES
 (1001, 'Site A', 'https://site-a.example', 'Retail', 1, '2025-01-01', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (1002, 'Site B', 'https://site-b.example', 'Support', 1, '2025-01-01', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- Chatbot users (4 users across 2 websites)
INSERT INTO dbo.chatbot_user(chatbot_user_id, website_id, anonymous_id, ip_address, first_active_at, last_active_at, created_at, updated_at, created_by, updated_by)
VALUES
 (2001, 1001, 'a3c1d2e3-1111-2222-3333-444455556666', convert(varbinary(32), '0xC0A80101'), '2026-02-01T09:00:00', '2026-02-06T10:00:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (2002, 1001, 'b4d2e3f4-1111-2222-3333-444455556666', convert(varbinary(32), '0x0A000001'), '2026-02-03T11:00:00', '2026-02-06T12:00:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (2003, 1002, 'c5e3f4a5-1111-2222-3333-444455556666', convert(varbinary(32), '0x08080808'), '2026-02-04T08:30:00', '2026-02-06T09:30:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (2004, 1002, 'd6f4a5b6-1111-2222-3333-444455556666', convert(varbinary(32), '0x04040404'), '2026-02-05T15:00:00', '2026-02-06T16:00:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- Website users
INSERT INTO dbo.website_user(website_user_id, website_id, preferred_language, hashed_phone, hash_version, active_flag, active_from, active_end, created_at, updated_at, created_by, updated_by)
VALUES
 (3001, 1001, 1, 'sha256:9f86d081884c7d659a2feaa0c55ad015...', 'v1', 1, '2025-01-01', '2099-12-31', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (3002, 1002, 2, 'sha256:2d711642b726b04401627ca9fbac32f5...', 'v1', 1, '2025-01-01', '2099-12-31', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- 5 Conversations with fixed GUIDs
DECLARE @c1 UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
DECLARE @c2 UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';
DECLARE @c3 UNIQUEIDENTIFIER = '33333333-3333-3333-3333-333333333333';
DECLARE @c4 UNIQUEIDENTIFIER = '44444444-4444-4444-4444-444444444444';
DECLARE @c5 UNIQUEIDENTIFIER = '55555555-5555-5555-5555-555555555555';
DECLARE @c6 UNIQUEIDENTIFIER  = '66666666-6666-6666-6666-666666666666';
DECLARE @c7 UNIQUEIDENTIFIER  = '77777777-7777-7777-7777-777777777777';
DECLARE @c8 UNIQUEIDENTIFIER  = '88888888-8888-8888-8888-888888888888';
DECLARE @c9 UNIQUEIDENTIFIER  = '99999999-9999-9999-9999-999999999999';
DECLARE @c10 UNIQUEIDENTIFIER = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
DECLARE @c11 UNIQUEIDENTIFIER = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
DECLARE @c12 UNIQUEIDENTIFIER = 'cccccccc-cccc-cccc-cccc-cccccccccccc';

INSERT INTO dbo.chatbot_conversation(
    conversation_id, website_id, chatbot_user_id,
    entry_page_url, entry_page_type, channel, os, browser, device_type,
    primary_intent, intent_confidence, status, started_at, ended_at, created_at, updated_at, created_by, updated_by
)
VALUES
 (@c1, 1001, 2001, N'https://site-a.example/home', 'Homepage', 'Web', 'Windows 11', 'Google Chrome', 'PC',
  'Order Status', 0.91, 'ended', '2026-02-06T09:10:00', '2026-02-06T09:15:30', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (@c2, 1001, 2001, N'https://site-a.example/faq', 'Q&A', 'Web', 'Windows 11', 'Google Chrome', 'PC',
  'Return Policy', 0.83, 'ended', '2026-02-06T10:20:00', '2026-02-06T10:29:10', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (@c3, 1001, 2002, N'https://site-a.example/product/123', 'Product', 'Web', 'Mac OS X', 'MS Edge', 'PC',
  NULL, NULL, 'abandoned', '2026-02-06T12:05:00', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (@c4, 1002, 2003, N'https://site-b.example/support', 'Support', 'Web', 'Android', 'Google Chrome', 'Mobile',
  'Account Login', 0.77, 'ended', '2026-02-06T09:05:00', '2026-02-06T09:12:40', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (@c5, 1002, 2004, N'https://site-b.example/support/billing', 'Support', 'Web', 'iOS', 'Safari', 'Mobile',
  'Billing Issue', 0.88, 'error', '2026-02-06T16:10:00', '2026-02-06T16:11:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
  (@c6,  1001, 2001, N'https://site-a.example/support/order', 'Support', 'Web', 'Windows 11', 'Google Chrome', 'PC',
 'Order Status', 0.90, 'ended', '2026-01-22T01:05:00', '2026-01-22T01:27:30', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 22m30s
(@c7,  1001, 2001, N'https://site-a.example/support/returns', 'Support', 'Web', 'Windows 11', 'Google Chrome', 'PC',
 'Return Policy', 0.82, 'ended', '2026-01-22T02:10:00', '2026-01-22T02:30:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 20m
(@c8,  1001, 2001, N'https://site-a.example/support/account', 'Support', 'Web', 'Windows 11', 'Google Chrome', 'PC',
 'Account Login', 0.76, 'ended', '2026-01-22T04:00:00', '2026-01-22T04:18:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 18m
(@c9,  1002, 2003, N'https://site-b.example/support', 'Support', 'Web', 'Android', 'Google Chrome', 'Mobile',
 NULL, NULL, 'ended', '2026-01-22T01:40:00', '2026-01-22T01:40:40', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 40s
(@c10, 1002, 2004, N'https://site-b.example/support/billing', 'Support', 'Web', 'iOS', 'Safari', 'Mobile',
 'Billing Issue', 0.88, 'ended', '2026-01-22T01:45:00', '2026-01-22T01:45:20', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 20s
(@c11, 1002, 2003, N'https://site-b.example/support', 'Support', 'Web', 'Android', 'Google Chrome', 'Mobile',
 'Account Login', 0.80, 'ended', '2026-01-22T03:15:00', '2026-01-22T03:55:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'), -- 40m
(@c12, 1001, 2002, N'https://site-a.example/faq', 'Q&A', 'Web', 'Mac OS X', 'MS Edge', 'PC',
 'Return Policy', 0.85, 'ended', '2026-01-22T03:35:00', '2026-01-22T04:05:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'); 

-- Messages
-- Convention: role=user/bot, content_type=text, language_id varies
INSERT INTO dbo.message(message_id, conversation_id, message_sequence, sent_at, role, content_type, content_raw, content_translated, language_id, response_latency_ms, created_at, updated_at, created_by, updated_by)
VALUES
 -- c1 (English)
 (400001, @c1, 1, '2026-02-06T09:10:05', 'user', 'text', N'Where is my order #A123?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400002, @c1, 2, '2026-02-06T09:10:06', 'bot',  'text', N'Let me check that for you. What is your email?', NULL, 1, 850, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400003, @c1, 3, '2026-02-06T09:10:30', 'user', 'text', N'me@example.com', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400004, @c1, 4, '2026-02-06T09:10:31', 'bot',  'text', N'Your order A123 is out for delivery today.', NULL, 1, 920, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

 -- c2 (Chinese, English translation available)
 (400010, @c2, 1, '2026-02-06T10:20:10', 'user', 'text', N'你们的退货政策是什么？', N'What is your return policy?', 2, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400011, @c2, 2, '2026-02-06T10:20:11', 'bot',  'text', N'我们支持7天无理由退货。需要我发链接吗？', N'We support 7-day returns. Want the link?', 2, 780, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

 -- c3 (English, abandoned)
 (400020, @c3, 1, '2026-02-06T12:05:05', 'user', 'text', N'Is this item back in stock?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400021, @c3, 2, '2026-02-06T12:05:06', 'bot',  'text', N'I can help—what is your preferred size?', NULL, 1, 650, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

 -- c4 (Malay)
 (400030, @c4, 1, '2026-02-06T09:05:10', 'user', 'text', N'Saya tidak boleh log masuk ke akaun saya.', N'I cannot log into my account.', 3, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400031, @c4, 2, '2026-02-06T09:05:11', 'bot',  'text', N'Boleh saya tahu mesej ralat yang dipaparkan?', N'What error message do you see?', 3, 540, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

 -- c5 (English, error scenario)
 (400040, @c5, 1, '2026-02-06T16:10:10', 'user', 'text', N'I was charged twice this month.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400041, @c5, 2, '2026-02-06T16:10:11', 'bot',  'text', N'Sorry—something went wrong retrieving billing data.', NULL, 1, 1200, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

 (400100, @c6, 1, '2026-01-22T01:05:05', 'user', 'text', N'Can you check my order status?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400101, @c6, 2, '2026-01-22T01:05:06', 'bot',  'text', N'Sure. Please share your order number.', NULL, 1, 900, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400102, @c6, 3, '2026-01-22T01:06:00', 'user', 'text', N'A567', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400103, @c6, 4, '2026-01-22T01:06:01', 'bot',  'text', N'Checking…', NULL, 1, 1200, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400104, @c6, 5, '2026-01-22T01:20:00', 'bot',  'text', N'It is pending pickup. Anything else?', NULL, 1, 1100, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c7 (long)
(400110, @c7, 1, '2026-01-22T02:10:10', 'user', 'text', N'How do returns work?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400111, @c7, 2, '2026-01-22T02:10:11', 'bot',  'text', N'Returns are accepted within 7 days.', NULL, 1, 700, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400112, @c7, 3, '2026-01-22T02:25:00', 'user', 'text', N'What if the item is opened?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400113, @c7, 4, '2026-01-22T02:25:01', 'bot',  'text', N'Opened items may be subject to inspection.', NULL, 1, 850, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c8 (long)
(400120, @c8, 1, '2026-01-22T04:00:10', 'user', 'text', N'I can’t log in.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400121, @c8, 2, '2026-01-22T04:00:11', 'bot',  'text', N'What error do you see?', NULL, 1, 650, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400122, @c8, 3, '2026-01-22T04:10:00', 'user', 'text', N'Invalid password.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400123, @c8, 4, '2026-01-22T04:10:01', 'bot',  'text', N'Try resetting your password.', NULL, 1, 900, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c9 (short)
(400130, @c9, 1, '2026-01-22T01:40:05', 'user', 'text', N'Hello?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400131, @c9, 2, '2026-01-22T01:40:06', 'bot',  'text', N'I don’t understand.', NULL, 1, 300, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c10 (short)
(400140, @c10, 1, '2026-01-22T01:45:05', 'user', 'text', N'I was charged twice.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400141, @c10, 2, '2026-01-22T01:45:06', 'bot',  'text', N'Sorry—something went wrong.', NULL, 1, 400, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c11 (overlap)
(400150, @c11, 1, '2026-01-22T03:15:10', 'user', 'text', N'Cannot login.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400151, @c11, 2, '2026-01-22T03:15:11', 'bot',  'text', N'Let’s troubleshoot—what error?', NULL, 1, 600, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400152, @c11, 3, '2026-01-22T03:40:00', 'user', 'text', N'Account locked.', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400153, @c11, 4, '2026-01-22T03:40:01', 'bot',  'text', N'Please wait 15 minutes and retry.', NULL, 1, 800, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),

-- c12 (overlap, different website)
(400160, @c12, 1, '2026-01-22T03:35:10', 'user', 'text', N'Return policy?', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400161, @c12, 2, '2026-01-22T03:35:11', 'bot',  'text', N'Return within 7 days with receipt.', NULL, 1, 650, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400162, @c12, 3, '2026-01-22T03:59:00', 'user', 'text', N'Thank you', NULL, 1, NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
(400163, @c12, 4, '2026-01-22T03:59:01', 'bot',  'text', N'Glad to help!', NULL, 1, 300, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');


-- Message NLP
INSERT INTO dbo.message_nlp(message_id, nlp_version, processed_at, processor, status, error_code, error_detail, sentiment_score, intent, intent_confidence, entities, created_at, updated_at, created_by, updated_by)
VALUES
 (400001, 'intent-v1', '2026-02-06T09:10:08', 'nlp_job', 'success', NULL, NULL, 0.05, 'Order Status', 0.92,
  N'[{ "type":"order_id", "value":"A123", "confidence":0.95 }]', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400010, 'intent-v1', '2026-02-06T10:20:13', 'nlp_job', 'success', NULL, NULL, 0.00, 'Return Policy', 0.84,
  N'[]', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400030, 'intent-v1', '2026-02-06T09:05:14', 'nlp_job', 'success', NULL, NULL, -0.35, 'Account Login', 0.79,
  N'[]', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400040, 'intent-v1', '2026-02-06T16:10:15', 'nlp_job', 'partial', 'BILLING_LOOKUP_FAIL', 'Tool unavailable', -0.60, 'Billing Issue', 0.72,
  N'[]', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (400040, 'intent-v2', '2026-02-06T16:10:20', 'nlp_job', 'success', NULL, NULL, -0.55, 'Billing Dispute', 0.86,
  N'[]', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- Feedback (3 conversations have feedback)
INSERT INTO dbo.conversation_feedback(feedback_id, conversation_id, rating_score, feedback_raw, language_id, feedback_at, created_at, updated_at, created_by, updated_by)
VALUES
 (500001, @c1, 5, N'Quick and helpful.', 1, '2026-02-06T09:16:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (500002, @c2, 4, N'回答很清楚。', 2, '2026-02-06T10:30:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (500003, @c5, 1, N'It failed when I needed it most.', 1, '2026-02-06T16:12:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW'),
 (500004, @c12, 5, N'Quick and helpful.', 1, '2026-02-06T09:16:00', '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- Translated feedback (versioned)
INSERT INTO dbo.translated_feedback(feedback_id, translation_version, translated_feedback, translated_at, status, error_code, created_at, updated_at, created_by, updated_by)
VALUES
 (500002, 'mt-v1', N'The answer was very clear.', '2026-02-06T10:31:00', 'success', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

-- User mapping: user logs into a website account midstream (example: chatbot_user 2003 links to website_user 3002)
INSERT INTO dbo.user_id_mapping(chatbot_user_id, website_user_id, linked_at, unlinked_at, created_at, updated_at, created_by, updated_by)
VALUES
 (2003, 3002, '2026-02-06T09:06:00', NULL, '2026-02-09T10:15:35', '2026-02-09T10:15:35', 'CW', 'CW');

PRINT 'Initialization complete.';
GO
