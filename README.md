# End-to-End Airbnb Data Engineering Pipeline
[![dbt Core](https://img.shields.io/badge/dbt--core-v1.8+-orange.svg?logo=dbt&logoColor=white)](https://docs.getdbt.com/)
[![Snowflake Data Cloud](https://img.shields.io/badge/Snowflake-Data%20Cloud-blue.svg?logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![AWS S3](https://img.shields.io/badge/AWS-S3%20Data%20Lake-FF9900.svg?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/s3/)

An enterprise-grade, end-to-end data transformation pipeline built using a modern data stack (MDC). This project architectures an ELT (Extract, Load, Transform) framework implementing a **Medallion Architecture (Bronze → Silver → Gold)** to process multi-source Airbnb datasets. Raw operational files are ingested from object storage into a cloud data warehouse, transformed idempotently using modular dimensional modeling, and tracked via Type-2 Slowly Changing Dimensions (SCD).

---

## 🏗️ Architecture & Data Flow

The project layout decouples storage, compute, and transformation layers to maximize processing efficiency and eliminate operational bottlenecks:

```text
 ┌──────────────┐      ┌─────────────────────────────────────────────────────────────────┐
 │   DATA LAKE  │      │                     SNOWFLAKE DATA CLOUD                        │
 │              │      │                                                                 │
 │   AWS S3     │ ───> │  BRONZE LAYER   ───────>  SILVER LAYER   ───────>  GOLD LAYER     │
 │  (Raw CSVs)  │      │ (External Stages)       (Staging Models)       (Marts / OLAP)   │
 └──────────────┘      │ (File Formats)          (SCD Type 2)           (Fact/Dim Tables)│
                       └─────────────────────────────────────────────────────────────────┘
                                                       ▲
                                                       │  (Orchestration & Transforms)
                                               ┌───────────────┐
                                               │   dbt CORE    │
                                               │ (Models, SQL) │
                                               └───────────────┘
