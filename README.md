# sql-data-warehouse-project
Building a modern data warehouse with SQL Server, including ETL processes, data modeling and data analytics.

## This project involves:

Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.

ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.

Data Modeling: Developing fact and dimension tables optimized for analytical queries.

Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.


## Project Requirements 
The goal of this project phase is to establish a centralized repository that merges disparate data sources into a single, optimized data model designed for high-performance analytical queries using **SQL Server**. This layer serves as the initial landing zone to consolidate sales data from two distinct source systems (**ERP** and **CRM**), which are provided as CSV files. 

---
### Objective
To build robust, SQL-based analytics that transform raw data warehouse tables into actionable business insights.

### Key Insights Delivered
* **Customer Behavior:** Analyzing purchasing patterns, engagement, and customer segmentation.
* **Product Performance:** Identifying top-performing products, revenue drivers, and inventory trends.
* **Sales Trends:** Tracking revenue growth, seasonal fluctuations, and key performance indicators (KPIs).
---
## Architecture & Specifications

### 1. Data Sources (Ingestion)
We ingest raw data from two primary systems:
*   **ERP System:** Contains core transactional sales, product, and operational data.
*   **CRM System:** Contains customer profiles, interactions, and lead details.

### 2. Ingestion Strategy (Bronze Layer Rules)
*   **Schema Fidelity:** Data is loaded exactly as it appears in the source CSV files to ensure data lineage.
*   **Data Isolation:** All raw tables are isolated within a dedicated `bronze` schema in SQL Server.
*   **Dynamic Loading (Optional):** Ingestion processes utilize dynamic SQL scripts/parameters to allow flexible data loading without hardcoding file structures.

---

## 📂 Repository Structure

```text
📁 sql-data-warehouse-project
├── 📁 datasets
│   ├── 📁 source_crm
│   │   ├── 📄 cust_info.csv
│   │   ├── 📄 prd_info.csv
│   │   └── 📄 sales_details.csv
│   └── 📁 source_erp
│       ├── 📄 CUST_AZ12.csv
│       ├── 📄 LOC_A101.csv
│       └── 📄 PX_CAT_G1V2.csv
├── 📁 docs                          # System architecture and data modeling visuals
│   ├── 📄 data_architecture.png
│   ├── 📄 data_flow_diagram.png
│   ├── 📄 sales_Data_Mart(star schema).png
│   ├── 📄 table_stuctures_silver_layer.png
│   └── 📄 views_objects_golden_layer.drawio
├── 📁 scripts                       # Sequential pipeline deployment files
│   ├── 📄 1.init_database.sql       # Warehouse initialization & schema definitions
│   ├── 📄 2.ddl_bronze.sql          # Raw staging schema table structures
│   ├── 📄 3.load_bronze.sql         # Bulk extraction stored procedure orchestrator
│   ├── 📄 4.ddl_silver.sql          # Structured silver schema table structures
│   ├── 📄 5.load_silver.sql         # Cleansing, repair, and transformation engine
│   └── 📄 6.views_gold.sql          # Analytical dimensional model views
└── 📁 tests                         # Automated enterprise validation framework
    ├── 📄 data_quality_checks_silver.sql
    └── 📄 data_quality_checks_gold.sql
```

---

## Data Pipeline Deployment (Step-by-Step)
### Step 1: Warehouse & Schemas Initialization (1.init_database.sql)
Prepares a clean deployment environment. It drops any existing database instance securely by resetting active user connection allocations to prevent structural object locks, recreates the container, and builds the explicit schema boundaries:

```sql
ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DataWarehouse;
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
CREATE SCHEMA bronze; GO
CREATE SCHEMA silver; GO
CREATE SCHEMA gold;   GO
```

### Step 2: Bronze Schema Definitions (2.ddl_bronze.sql)
Defines the intake table skeletons without checking semantic typing or constraint restrictions. Fields are assigned broad NVARCHAR(50) allocations to prevent staging pipeline disruptions from raw file formatting variances.

Tables Created: crm_cust_info, crm_prd_info, crm_sales_details, erp_loc_a101, erp_cust_az12, erp_px_cat_g1v2.

### Step 3: Raw Data Bulk Loading (3.load_bronze.sql)
Compiles a Stored Procedure (bronze.load_bronze) automating file ingestion via SQL Server’s native **BULK INSERT**. It integrates target table truncation to avoid duplicated staging loads, handles error routing via **TRY...CATCH**, and captures metric execution runtimes using **DATEDIFF**.

```sql
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        TRUNCATE TABLE bronze.crm_cust_info; 
        BULK INSERT bronze.crm_cust_info
        FROM '...\datasets\source_crm\cust_info.csv' 
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    END TRY
    BEGIN CATCH ... END CATCH
END;
```

### Step 4: Silver Schema Definitions (4.ddl_silver.sql)
Applies structural definitions over the staging tables. Datatypes are refined (e.g., changing raw integer timestamp sequences back into standard **DATE** formats) to provide analytical stability.

Data Lineage: Every entity is assigned a system metadata attribute (**dwh_create_date DATETIME2 DEFAULT GETDATE()**) to trace staging load history.

###  Step 5: Silver Cleansing & Transformations (5.load_silver.sql)
Abstracts the core data transformation mechanics inside the silver.load_silver Stored Procedure. 
Key operations include:
* **Deduplication**: Deploys  **ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)** window parsing to drop historical duplicate records.
  
* **String Normalization**: Cleans formatting errors using uniform **TRIM()** structures, wipes out extraneous prefix characters (such as removing NAS from keys), and standardizes inconsistent country terms (e.g., US/USA -> United States).
  
* **SCD Type 2 Modeling Foundations**: Uses an analytical  **LEAD()** window function to generate valid historical window timestamps (prd_end_dt) based on upcoming updates.
  
* **Self-Healing Data Calculations**: Recomputes mathematically distorted metric entries **(sls_quantity * ABS(sls_price))** on the fly if the source system values are broken or negative.

###  Step 6: Gold Dimensional Model Views (6.views_gold.sql)
Exposes an abstracted Star Schema matrix architecture via decoupled views. This ensures downstream visualization systems run calculations over indexed metadata layers without direct access to base table entities.

* **Surrogate Key Generation**: Applies chronological **ROW_NUMBER()** loops to assign sequential business keys (customer_key, product_key), decoupling dimensions from volatile source keys.

* **Cross-System Consolidation**: Links independent entities from the CRM and ERP branches with **LEFT JOIN** sequences, applying **COALESCE** statements to fill context data gaps (e.g., substituting missing CRM values with ERP demographic traits).

* **Current State Isolation**: Restricts dimension outputs using active criteria constraints (WHERE prd_end_dt IS NULL) to surface clean, valid records to report layers.

---

## Data Modeling Visualizations
🥈 **Silver Layer Operational Tables Schema**
This structural layout details our typed database entities, standardizing properties and attaching operational lineage tags across all tables.

🥇 **Gold Layer Business Intelligence Star Schema**
The enterprise presentation model decouples contextual descriptive entities (Dimensions) from raw transactional measures (Facts) for optimized multi-directional aggreg


---

🛡️ Data Quality Assurance & Testing Suite
The repository deploys an automated testing framework inside the tests/ folder to run structural validation checks immediately following processing cycles.

🥈 **1. Silver Verification Engine (data_quality_checks_silver.sql)**
Profiles dataset sanity right after staging pipeline runs conclude:
  
    Entity Integrity Constraints: Scans for primary attribute collisions or illegal null constraints.
    ```sql
    HAVING COUNT(*) > 1 OR cst_id IS NULL
    ```
    
    Format Defect Isolation: Verifies whitespace trimming by checking for string alignment mismatches.
    ```sql
    WHERE field != TRIM(field)
    ```
    
    Chronological Rule Checking: Catches range anomalies, ensuring that record end dates are never chronologically lower than their start dates.
    
    Financial Balance Verification: Validates row calculations against business arithmetic parameters to flag broken transactions.
    ```sql
    (WHERE sls_sales != sls_quantity * sls_price).
    ```

🥇 **2. Gold Analytical Model Validation (data_quality_checks_gold.sql)**
Certifies Star Schema structural health before reporting structures process visual reports:
  
  Surrogate Key Evaluation: Asserts absolute value uniqueness across surrogate dimensional structures.
  
  Referential Integrity Auditing: Runs join validations between the transactional facts file and outskirt dimensional entities. If an active transactional reference maps to an missing key sequence, the diagnostic test catches the orphan reference immediately.

    ```sql
    -- Automated Referential Integrity Join Assertion
    -- Expected Output: 0 rows returned (Zero anomalies detected)
    SELECT * FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    WHERE p.product_key IS NULL OR c.customer_key IS NULL;
    ```

---

## Execution Guide
### Prerequisites: Ensure SQL Server and SQL Server Management Studio (SSMS) are installed.

### Setup Warehouse Structure: Run script 1 to build the core base system and its storage schemas.

*Initialize Schema Structures: Deploy scripts 2 and 4 to populate table structures for the Bronze and Silver staging tiers.

*Compile Processing Logic: Run scripts 3 and 5 to save the automated orchestrator Stored Procedures.

*Execute Pipeline Processing: Run the pipeline components in sequence to clean and ingest local data files:

```sql
EXEC bronze.load_bronze;
EXEC silver.load_silver;
```

*Deploy Presentation Layers: Execute script 6 to compile the final Gold analytical schema views.

*Perform Compliance Diagnostics: Run the assertion suites in the tests/ path to verify data warehouse integrity.
