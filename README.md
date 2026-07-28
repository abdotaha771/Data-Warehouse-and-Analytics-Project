# 🏢 Enterprise Data Warehouse & Analytics Project (SQL Server)

![SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server-red?style=for-the-badge&logo=microsoftsqlserver)
![Data Warehouse](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-blue?style=for-the-badge)
![Data Modeling](https://img.shields.io/badge/Data%20Model-Star%20Schema-gold?style=for-the-badge)

Welcome to the **Enterprise Data Warehouse and Business Intelligence Project** repository. This project demonstrates an end-to-end data engineering lifecycle: ingesting raw CSV data from disparate source systems (CRM and ERP), cleaning and transforming data via Stored Procedures, modeling data using a **Star Schema (Medallion Architecture)**, and producing business-ready analytical reports.

---

## 📐 1. System Data Architecture

The project adopts the **Medallion Architecture** pattern, structured into three progressive layers to process and elevate data quality:

+------------------+      +-----------------------------------------------------------+      +-------------------+|   Source Data    |      |                      Data Warehouse                       |      |      Serving      ||                  |      |  +---------------+    +---------------+    +-----------+  |      |                   ||  - CRM CSV Files |--->--|--| Bronze Layer  |->--| Silver Layer  |->--|Gold Layer |--|-->---| - BI & Reporting  ||  - ERP CSV Files |      |  | (Raw Data)    |    | (Cleaned)     |    | (Ready)   |  |      | - Machine Learning|+------------------+      |  +---------------+    +---------------+    +-----------+  |      +-------------------++-----------------------------------------------------------+
### 🏛️ Medallion Layers Detailed Summary

| Layer | Object Type | Loading Strategy | Transformation Logic | Data Model |
| :--- | :--- | :--- | :--- | :--- |
| **Bronze** | Physical Tables | Batch Processing / Full Load (`TRUNCATE & INSERT` via `BULK INSERT`) | None (Raw CSV ingestion as-is) | None (Flat Tables) |
| **Silver** | Physical Tables | Batch Processing / Full Load (`TRUNCATE & INSERT` via Stored Procedures) | Data Cleaning, Standardisation, Normalisation, Deduplication, Derived Columns, Enrichment | None (Cleansed Staging) |
| **Gold** | Views | No Physical Storage Load (Virtual Views) | Data Integration, Business Logic Aggregations, Surrogate Key generation | **Star Schema** (Fact & Dimensions) |

---

## 🔀 2. Data Flow & Integration Pipeline

### 🔄 Data Flow Across Layers
Data moves sequentially through the layers, ensuring maximum data integrity and quality enforcement before analytical queries run.

1. **ERP & CRM Datasets** $\rightarrow$ Loaded into **Bronze Layer** (`bronze.crm_*`, `bronze.erp_*`).
2. **Bronze Tables** $\rightarrow$ Cleansed and standardized into **Silver Layer** (`silver.crm_*`, `silver.erp_*`).
3. **Silver Tables** $\rightarrow$ Modeled into **Gold Dimensions & Facts** (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`).

### 🔗 Source Data Integration Strategy
- **Customer Integration**: Primary CRM Customer Records (`cust_info`) joined with ERP Location (`loc_a101`) and Demographic data (`cust_az12`) via unique ID mapping (`cst_key` / `cid`).
- **Product Integration**: Primary CRM Product Records (`prd_info`) joined with ERP Product Category hierarchy (`px_cat_g1v2`) using category key mapping.

---

## 🌟 3. Gold Layer Data Model (Star Schema)

The analytical Gold Layer is structured as a **Star Schema**, optimized for fast aggregation and business performance reporting:

                       +------------------------+
                       |   gold.dim_customers   |
                       +------------------------+
                       | PK  customer_key       |
                       |     customer_id        |
                       |     customer_number    |
                       |     first_name         |
                       |     last_name          |
                       |     country            |
                       |     marital_status     |
                       |     gender             |
                       |     birth_date         |
                       |     create_date        |
                       +------------------------+
                                   |
                                   | 1
                                   |
                                   | N
                      +--------------------------+
                      |     gold.fact_sales      |
                      +--------------------------+
                      | FK  order_number         |
                      | FK  product_key          |
                      | FK  customer_key         |
                      |     order_date           |
                      |     shipping_date        |
                      |     due_date             |
                      |     sales_amount         |
                      |     quantity             |
                      |     price                |
                      +--------------------------+
                                   |
                                   | N
                                   |
                                   | 1
                       +------------------------+
                       |   gold.dim_products    |
                       +------------------------+
                       | PK  product_key        |
                       |     product_id         |
                       |     product_number     |
                       |     product_name       |
                       |     category_id        |
                       |     category           |
                       |     subcategory        |
                       |     maintenance        |
                       |     cost               |
                       |     product_line       |
                       |     start_date         |
                       +------------------------+

---

## 📁 4. Repository Directory Structure

```text
├── scripts/
│   ├── 01_init_database.sql          -- Database and Schemas (Bronze, Silver, Gold) Creation
│   ├── 02_ddl_bronze.sql             -- Bronze Layer DDL Statements
│   ├── 03_load_bronze.sql            -- Stored Procedure to BULK INSERT CSVs into Bronze
│   ├── 04_ddl_silver.sql             -- Silver Layer DDL Statements
│   ├── 05_load_silver.sql            -- Stored Procedure for ETL (Cleaning & Transforming)
│   ├── 06_ddl_gold.sql               -- Gold Layer Views (Star Schema)
│   ├── 07_gold_reports.sql           -- Business Intelligence Views (Customer & Product Reports)
│   ├── 08_data_quality_checks.sql    -- Data Cleansing & Quality Assurance Queries
│   └── 09_analytics_exploration.sql  -- Business Analytics & Change Over Time Queries
├── docs/
│   ├── Architecture.png              -- High-Level Data Architecture Diagram
│   ├── Data_Flow.png                 -- Data Flow Diagram
│   ├── Data_Integration.png          -- CRM & ERP Entity Mapping Diagram
│   └── Star_Schema_Model.png         -- Data Model Diagram
└── README.md                         -- Project Documentation
🛠️ 5. Key ETL & Transformation HighlightsDeduplication: Applied ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) to pick the latest valid customer record.Handling Missing / Null Values: Standardized strings with TRIM() and mapped missing values (NULL, empty strings) to 'n/a'.Data Normalization: Normalized gender flags ('M', 'Male', 'F', 'Female') and marital statuses into unified clean values.Data Consistency Checks: Verified pricing equations ($Sales = Quantity \times Price$) and filtered out corrupted negative values or invalid future date ranges.SCD Handling (Type 1/Type 2 logic): Implemented historical date range calculations using LEAD() functions for product validity windows (prd_start_dt, prd_end_dt).🚀 6. How to Run the ProjectPrerequisitesMicrosoft SQL Server (2019+ recommended)SQL Server Management Studio (SSMS) or Azure Data StudioExecution StepsInitialize Database: Run 01_init_database.sql to build the Data_Warehouse DB and schemas.Create & Load Bronze Layer: Execute 02_ddl_bronze.sql, update file paths in 03_load_bronze.sql, and run EXEC bronze.load_bronze;.Create & Load Silver Layer: Execute 04_ddl_silver.sql and run EXEC silver.load_silver;.Build Gold Layer: Execute 06_ddl_gold.sql to create analytical views.Run Reports & Quality Checks: Execute scripts 07_gold_reports.sql and 08_data_quality_checks.sql.📊 7. Analytics & Business Reports IncludedThe repository contains pre-built Gold Reports for decision-makers:Product Report (gold.report_products): Evaluates revenue performance, product lifespan, order frequency, recency, and segments items into High-Performer, Mid-Range, or Low-Performer.Customer Report (gold.report_customers): Segments customers into VIP, Regular, or New based on spending and lifespan, while tracking Age Groups, Recency, Average Order Value (AOV), and Monthly Spend.👨‍💻 Author: Abdelrahman Taha📧 Contact / Portfolio: GitHub Profile | LinkedIn Profile
