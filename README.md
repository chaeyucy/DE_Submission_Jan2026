# Chatbot Analytics for DE_Submission_Jan2026 (SQL Server)
A lightweight SQL Server project for storing and analyzing website-embedded chatbot conversations, along with success metrics signals (latency, fallback/error, escalation, feedback, retention) and analysis queries (idle time, peak concurrency, short conversations).

This repo includes:
- A **Docker Compose YAML File** to run SQL Server locally
- **init script** and **mock_data** that create the schema and insert synthetic sample data 
- Reference tables to support success-metric analysis, including a **chatbot_session table** and optional labeling/signal tables
- SQL queries for user-behavior analysis (long sessions, idle time, short conversations, peak concurrency)

---

## Architecture overview

### Layers

This project designs “gold layer” schema suitable for analytics and KPI computation:

- **Gold Layer**: analytics-ready tables with PK/FK/constraints and indexes  
  - `chatbot_conversation`, `message`, `message_nlp`
  - `conversation_feedback`, `translated_feedback`
  - `chatbot_user`, `website_user`, `user_id_mapping`
  - master tables: `website`, `language`

Optionally, you can implement a simple pipeline:
- **Staging (stg)**: ingestion tables that are typically lighter on constraints and allow duplicates/late arrivals
- **Gold (dbo)**: built from staging via `INSERT...SELECT` / upsert logic

### Session analytics hub

To support “success criteria” metrics efficiently, we introduced an aggregated session table:
- `chatbot_session`: 1 row per conversation/session with rollups (duration, message counts, latency rollups, escalation flags, feedback summary, traffic type)

Supporting tables:
- `message_bot_label`
- `session_escalation` event history

---

## Schema summary

### Core conversation tables
- `dbo.chatbot_conversation`  
  Stores conversation start/end and environment metadata (website, channel, browser, etc.)

- `dbo.message`  
  Stores per-message content and timing (`response_latency_ms` on bot rows)

- `dbo.message_nlp`  
  Stores NLP outputs per message **per NLP version** (intent/sentiment/entities)

### Feedback tables
- `dbo.conversation_feedback`  
  1 row per conversation (rating + optional free-text feedback)

- `dbo.translated_feedback`  
  Versioned translations of feedback, enabling re-translation over time

### Identity tables
- `dbo.chatbot_user`  
  Browser-profile identity per website (cookie/localStorage anonymous id)

- `dbo.website_user`  
  Logged-in website account

- `dbo.user_id_mapping`  
  Temporal mapping between chatbot_user and website_user (supports late login during chat)

### Reference tables
- `dbo.website`
- `dbo.language`

### Analytics/session tables (recommended)
- `dbo.chatbot_session`  
  Aggregated per-conversation metrics and flags used in KPIs:
  - duration, message counts
  - latency rollups (avg/p95/p99, first bot response)
  - fallback/error counts
  - escalation flags
  - feedback summary
  - `traffic_type` for filtering prod vs test/bot/internal

---

## Getting started

### Tools
- Docker Desktop
- SSMS

## Run Below Command via PowerShell as Admin:
docker compose up

Docker will:
- start SQL Server 2022 (Developer)
- run scripts/init_db.sql once to create the schema

## Connect to local DB using below connection strings
Host: localhost
Port: 1433
User: sa
Password: P@ssw0rd!
Database: ChatbotAnalytics

## Run scripts/mock_data.sql to insert sample data

## Run scripts/Task2_chatbot_session_DDL.sql to create aggregated session table and other supporting tables

## Run scripts/data_transformation.sql to load aggregated data into [chatbot_session]

## Run sql query in analysis/task3_qx.sql to perform user-behavior analysis
