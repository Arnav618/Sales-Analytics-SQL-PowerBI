
# SQL Scripts

This folder contains all SQL scripts used to build the Superstore Sales Analysis project, from raw data investigation through business insight generation.

## Execution Order

Run the scripts in the following order:

| File                      | Purpose                                                  |
| ------------------------- | -------------------------------------------------------- |
| 01_schema_exploration.sql | Data profiling, quality checks, and issue identification |
| 02_data_model_design.sql  | Star schema design and table creation                    |
| 03_data_cleaning.sql      | Data transformation, loading, and validation             |
| 04_business_analysis.sql  | Business insight and profitability analysis              |

## Prerequisites

* MySQL 8.0+
* Superstore dataset loaded into `raw_sales`
* Dataset source: Kaggle Superstore Dataset

## SQL Skills Demonstrated

* Data Profiling & Validation
* Star Schema Modeling
* Surrogate Key Design
* Joins & Aggregations
* Common Table Expressions (CTEs)
* Window Functions (`LAG`, `DENSE_RANK`, `PARTITION BY`)
* Profitability Analysis
* Trend Analysis
* Customer & Product Segmentation

## Business Objectives

The SQL layer was designed to:

* Build a clean analytical data model
* Resolve product identifier inconsistencies
* Preserve valid transaction-level records
* Generate actionable business insights
* Support Power BI reporting and dashboard development
