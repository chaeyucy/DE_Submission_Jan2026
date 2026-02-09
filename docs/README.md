## Task 1 gold layer data model 
- data model design for gold layer tables with rationals and relationships

## Task 1 upsert from staging layer
- scripts/
- │   ├── staging.sql                 # DDL creating staging layer to accommodate data before arriving at gold layer with light constraints but basic integrity enforcement.
- │   └── upsert_from_stag_to_gold.sql     # **upsert logic** that inserts new records from staging layer to gold layer, while update records at gold layer if existing. (Assume there are other **metadata, log, partition tables** to accomodate bad data.)

## Task 2 Metrics
- The 3 success Metrics I proposed

## Task 2 additional entities
- Additional aggregated chatbot session table design with other supporting tables for **3 success Metrics**
