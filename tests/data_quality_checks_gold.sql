/*
===============================================================================
Quality Checks: Analytical Model Validation & Integrity Suite
===============================================================================

Script Purpose:
    This validation suite conducts definitive quality audits to certify the 
    structural integrity, relational health, and analytical readiness of the 
    'Gold' data tier. The script executes the following compliance checks:
    
    - Key Uniqueness: Verifies that all Surrogate Keys across dimension tables 
      maintain absolute uniqueness with zero duplicates.
    - Referential Integrity: Audits the relational alignment between foreign keys 
      in the Fact table and their corresponding primary keys in Dimension tables.
    - Schema Validation: Evaluates the logical relationships within the Star Schema 
      to guarantee flawless execution of business intelligence and analytical queries.

Execution & Operational Notes:
    - Run these diagnostic audits immediately after populating the Star Schema models.
    - Any failure or discrepancy in referential integrity indicates an upstream ETL flaw 
      that must be isolated and resolved prior to publishing dashboards or reporting views.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
