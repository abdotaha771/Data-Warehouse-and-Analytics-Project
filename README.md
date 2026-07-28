# 🏢 Enterprise Data Warehouse & Analytics Project (SQL Server)

![SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server-red?style=for-the-badge&logo=microsoftsqlserver)
![Data Warehouse](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-blue?style=for-the-badge)
![Data Modeling](https://img.shields.io/badge/Data%20Model-Star%20Schema-gold?style=for-the-badge)

Welcome to the **Enterprise Data Warehouse and Business Intelligence Project** repository. This project demonstrates an end-to-end data engineering lifecycle: ingesting raw CSV data from disparate source systems (CRM and ERP), cleaning and transforming data via Stored Procedures, modeling data using a **Star Schema (Medallion Architecture)**, and producing business-ready analytical reports.

---

## 📐 1. System Data Architecture

The project adopts the **Medallion Architecture** pattern, structured into three progressive layers to process and elevate data quality:

![Data Architecture](docs/Data%20Architecture.png)

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

```text
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
                          |     order_number         |
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
```
## 📁 4. Repository Directory Structure

```text
├── datasets/
│   ├── source_crm/                   -- Raw CSV files for CRM data
│   └── source_erp/                   -- Raw CSV files for ERP data
├── docs/
│   ├── Data Architecture.png         -- High-Level Data Architecture Diagram
│   ├── data flow.png                 -- Data Flow Diagram
│   ├── Data Integration.png          -- CRM & ERP Entity Mapping Diagram
│   └── *.drawio                      -- Editable diagram files
├── scripts/
│   ├── init_database.sql             -- Database and Schemas (Bronze, Silver, Gold) Creation
│   ├── Bronze/                       -- Bronze Layer DDL and Load Procedures
│   ├── Silver/                       -- Silver Layer DDL and ETL Procedures
│   ├── Gold/                         -- Gold Layer Views (Star Schema)
│   ├── reports/                      -- Business Intelligence Views (Customer & Product Reports)
│   └── analysis/                     -- Business Analytics & Change Over Time Queries
├── test Silver & gold/
│   ├── quality checks silver.sql     -- Data Cleansing & Quality Assurance Queries for Silver
│   └── quality checks gold.sql       -- Integrity Validation Queries for Gold
└── README.md                         -- Project Documentation
```
🛠️ 5. Key ETL & Transformation Highlights

    - Deduplication: Applied ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) to pick the latest valid customer record.
    
    - Handling Missing / Null Values: Standardized strings with TRIM() and mapped missing values (NULL, empty strings) to 'n/a'.
    
    - Data Normalization: Normalized gender flags ('M', 'Male', 'F', 'Female') and marital statuses into unified clean values.
    
    - Data Consistency Checks: Verified pricing equations (Sales = Quantity * Price) and filtered out corrupted negative values or invalid future date ranges.
    
    - SCD Handling (Type 1/Type 2 logic): Implemented historical date range calculations using LEAD() functions for product validity windows (prd_start_dt, prd_end_dt).

🚀 6. How to Run the Project

    Prerequisites
    
      - Microsoft SQL Server (2019+ recommended)
    
      - SQL Server Management Studio (SSMS) or Azure Data Studio
    
    Execution Steps
    
      - Initialize Database: Run scripts/init_database.sql to build the Data_Warehouse DB and schemas.
      
      - Create & Load Bronze Layer: Execute scripts inside scripts/Bronze/ to define tables and load CSVs, then run EXEC bronze.load_bronze;.
      
      - Create & Load Silver Layer: Execute scripts inside scripts/Silver/ for DDL and ETL transformations, then run EXEC silver.load_silver;.
      
      - Build Gold Layer: Execute scripts inside scripts/Gold/ to create the analytical Star Schema views.
      
      - Generate Reports: Execute scripts inside scripts/reports/ to set up business intelligence reporting views.
      
      - Run Quality Checks: Use the files in test Silver & gold/ to validate the integrity of your data model.

📊 7. Analytics & Business Reports Included

The repository contains pre-built Gold Reports for decision-makers:

    - Product Report (gold.report_products): Evaluates revenue performance, product lifespan, order frequency, recency, and segments items into High-Performer, Mid-Range, or Low-Performer.
    
    - Customer Report (gold.report_customers): Segments customers into VIP, Regular, or New based on spending and lifespan, while tracking Age Groups, Recency, Average Order Value (AOV), and Monthly Spend.

👨‍💻 Author: Abdelrahman Taha

📧 Contact / Portfolio: GitHub Profile | LinkedIn Profile
