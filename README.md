
# End-to-End Airbnb Data Engineering Pipeline
[![dbt Core](https://img.shields.io/badge/dbt--core-v1.8+-orange.svg?logo=dbt&logoColor=white)](https://docs.getdbt.com/)
[![Snowflake Data Cloud](https://img.shields.io/badge/Snowflake-Data%20Cloud-blue.svg?logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![AWS S3](https://img.shields.io/badge/AWS-S3%20Data%20Lake-FF9900.svg?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/s3/)

An enterprise-grade, end-to-end data transformation pipeline built using a modern data stack (MDC). This project architectures a robust ELT (Extract, Load, Transform) framework implementing a **Medallion Architecture (Bronze → Silver → Gold)** to process multi-source Airbnb datasets. Raw operational files are ingested from cloud object storage into a centralized data warehouse, transformed idempotently using modular dimensional modeling, and tracked via Type-2 Slowly Changing Dimensions (SCD).

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

```

1. **Extraction & Ingestion:** Raw CSV transactional records are stored in an **AWS S3** bucket acting as a centralized Data Lake.
2. **Bronze Layer (Landing & Schema Definition):** **Snowflake File Formats** and **External Stages** securely abstract data endpoints, allowing native metadata-driven ingestion into the raw schema without hardcoding cloud paths.
3. **Silver Layer (Cleaning & Historic Tracking):** **dbt Core** acts as the transformation broker. SQL views apply cleaning, standardization, type casting, and constraint enforcement. Critical entities utilize **dbt Snapshots** to compute Type 2 Slowly Changing Dimensions (SCD Type 2) to maintain a complete history of historical state changes.
4. **Gold Layer (Analytical Optimization):** Cleaned entities are materialized as physical tables optimized for analytical queries following **Kimball Dimensional Modeling (Star Schema)** consisting of performance-tuned Fact and Dimension structures.

---

## 🛠️ Tech Stack & Core Competencies

* **Cloud Storage & Data Lake:** AWS S3 (IAM Roles, Object Storage Bucket Architecture)
* **Cloud Data Warehouse:** Snowflake (Compute/Storage Decoupling, Virtual Warehouses, RBAC, File Formats, External Stages, Copy Commands)
* **Data Transformation Layer:** dbt Core CLI (SQL Models, Jinja Templating, Macros, Materialization Strategies)
* **Data Quality Assurance:** dbt Data Test Engine (Schema validation, Unique/Not Null constraints, Custom Singular testing thresholds)
* **Data Architecture Principles:** Medallion Layering, Kimball Dimensional Modeling, SCD Type 2 (Time-variant histories), Idempotency

---

## 📁 Repository Structure

This repository focuses strictly on the modular dbt transformation layer. Python orchestration logic or virtual runtime setups (`.venv/`) remain fully decoupled from production SQL models to maintain standard data engineering repository boundaries.

```text
aws_dbt_snowflake_project/
├── analyses/
├── macros/                  # Custom re-usable Jinja code snippets
│   └── logging_macros.sql
├── models/                  # Medallion layer transformations
│   ├── staging/             # SILVER: Cleaning, validation, and type casting
│   │   ├── src_listings.sql
│   │   ├── src_reviews.sql
│   │   └── src_hosts.sql
│   └── marts/               # GOLD: Optimized Fact and Dimension structures
│       ├── dim_listings_cleansed.sql
│       ├── dim_hosts_cleansed.sql
│       └── fct_reviews.sql
├── snapshots/               # SCD Type 2 tracking configurations
│   └── scd_listings.sql
├── tests/                   # Business-logic validation rules
│   └── consistency_check.sql
├── .gitignore               # Blocks tracking profile credentials (profiles.yml)
├── dbt_project.yml          # Global dbt environment orchestration configuration
└── README.md

```

---

## ⚡ Data Engineering Design Implementations

### 1. Robust Security Protocols

Authentication mechanics avoid credential hardcoding. The `profiles.yml` environment connection configuration is completely decoupled from the project root and managed within local user runtimes. Project repositories explicitly implement local `.gitignore` layers to enforce strict secrets security during code deployment.

### 2. Kimball Dimensional Modeling (Star Schema)

Data at the analytical interface (Gold Layer) is structurally optimized for immediate business intelligence consumption. Business entities are organized into clean dimensional topologies:

* **`fct_reviews`**: Partitioned transactional facts storing metrics, composite foreign keys, and degenerate granular details.
* **`dim_listings_cleansed`** & **`dim_hosts_cleansed`**: Master descriptive references facilitating lightning-fast data exploration slice-and-dice mechanisms.

### 3. Dynamic Jinja Templates & Macro Utilities

To eliminate boilerplate redundant SQL code across models, custom **Jinja Macros** handle repetitive system logic dynamically. Parameterized dbt setups allow schemas to resolve dynamically depending on target environments (`dev` vs `prod`).

### 4. Advanced Time-Variant Histories via SCD Type 2

To manage operational changes safely over time (e.g., changes in listing prices or host verification status), **dbt Snapshots** are deployed. They generate surrogate validity ranges using internal state detection columns (`dbt_valid_from`, `dbt_valid_to`), preserving an auditable trail of business historical states.

```sql
{% snapshot scd_listings %}
{{
   config(
       target_schema='snapshots',
       unique_key='id',
       strategy='check',
       check_cols=['price', 'room_type', 'minimum_nights']
   )
}}
select * from {{ source('airbnb', 'listings') }}
{% endsnapshot %}

```

---

## 🧪 Data Quality & Contract Testing

Data pipelines prioritize correctness and structural alignment via programmatic test suites executed before deployment:

* **Out-of-the-Box Generic Validation:** Every core table key undergoes strict data asset integrity testing via continuous validation criteria tracking: `unique`, `not_null`, and relational referential check rules (`relationships`).
* **Custom Singular Threshold Logic:** Dedicated business rules are written using custom queries located inside the `/tests` directory.
* **Alert Severity Calibration:** Operational test parameters leverage built-in exception controls, demoting generic outliers into non-breaking execution `warning` conditions while retaining hard blocks for critical table keys.

```bash
# Run the end-to-end data validation test suite
dbt test

```

---

## 🚀 How to Run Locally

### Prerequisites

* Python 3.10+ installed locally
* Account access on **Snowflake Data Cloud**
* Read permissions for an **AWS S3** bucket location

### Setup Configuration

1. Clone this pipeline repository and navigate into the transformation root directory:
```bash
git clone [https://github.com/dannycky/airbnb.git](https://github.com/dannycky/airbnb.git)
cd airbnb/aws_dbt_snowflake_project

```


2. Install the necessary transformation engine requirements:
```bash
pip install dbt-snowflake

```


3. Configure your local runtime profile (`~/.dbt/profiles.yml`) to securely map database engine targets:
```yaml
aws_dbt_snowflake_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: [your_snowflake_account_locator]
      user: [your_username]
      password: [your_password]
      role: [your_rbac_role]
      warehouse: [your_virtual_warehouse]
      database: [your_target_database]
      schema: [your_dev_schema]

```


4. Validate infrastructure handshakes and initiate active compile sequences:
```bash
dbt debug
dbt seed
dbt run

```



---

## 🎯 Key Learning Outcomes & Professional Growth

Building this pipeline from scratch provided deep hands-on experience in:

* **Database Optimization:** Managing cloud compute warehouses efficiently by configuring virtual cluster sizes and controlling data indexing via file layouts.
* **Modern Development Workflows:** Writing modular SQL inside independent feature branches and merging them into `main` using Git best practices.
* **Production Engineering Mindset:** Designing defensive data transformation layers that handle unexpected changes smoothly and alert teams using robust testing before breaking analytics downstream.

---

💡 **Developed by Danny YIP** * 🎓 Student at Hong Kong University of Science and Technology (HKUST)

* 💼 Aspiring Data Engineer / Business Intelligence Intern
* 📧 [dannyckyah@gmail.com](mailto:dannyckyiaph@gmail.com)
* 🌐 [Connect with me on LinkedIn](www.linkedin.com/in/danny-yip-1ba767264)

