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

## Repository Structure
```text
├── Scripts/
│   ├── 01_DDL_Bronze_Tables.sql       # Script to create the bronze schema and raw tables
│   └── 02_Bulk_Insert_Raw_Data.sql    # Script to load ERP and CRM CSV files into SQL Server
├── Data/                              # [Optional] Sample CSV source files (ERP/CRM)
└── README.md                          # Project documentation
