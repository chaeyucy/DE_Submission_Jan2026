## init_db.sql                  
- Task 1 (step 1) : DDL for defining major gold layer tables

## mock_data.sql                
- Task 1 (step 2) : insert sample data into defined gold layer table

## staging_layer.sql            
- Task 1 : DDL for defining staging layer tables with light constraints but basic integrity enforcement.

## upsert_from_stag_to_gold.sql 
- Task 1 : **Basic upsert logic** from staging to gold layer tables with **assuming there are other metadata, logs (e.g., failure log), partition tables**

## data_transformation.sql      
- Task 2 : data processing scripts for summarizing into chatbot_session table

## chatbot_session_DDL
- Task 2 : DDL for defining aggregated chatbot session table for user behavior analysis
