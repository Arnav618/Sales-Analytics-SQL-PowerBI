
# Power BI Dashboard

## Overview

Interactive Business Intelligence dashboard developed in Power BI on top of a custom SQL-based Star Schema.

The dashboard transforms transactional sales data into actionable insights across profitability, customer behavior, product performance, regional trends, and business growth.

---

## Dashboard Pages

| Page                | Description                                              |
| ------------------- | -------------------------------------------------------- |
| Executive Overview  | High-level KPIs, sales trends, and profitability metrics |
| Product Analysis    | Category, sub-category, and product performance analysis |
| Customer Analysis   | Customer segmentation and top customer insights          |
| Geographic Analysis | Regional and state-level performance comparison          |

---

## Business Questions Answered

* How is the business performing overall?
* Which categories and products generate the highest profit?
* Which subcategories consistently lose money?
* How do discounts impact profitability?
* Which customer segments are most valuable?
* Which customers contribute the highest profit?
* Which regions perform best and worst?
* How has the business grown over time?
* What seasonal trends exist in sales and profit?

---

## Key Features

* Interactive slicers and filters
* Dynamic KPI cards
* Profitability analysis
* Customer segmentation
* Product performance tracking
* Geographic performance analysis
* Year-over-Year trend analysis
* Month-over-Month trend analysis
* Discount impact analysis
* Dynamic business insight generation

---

## Data Model

The dashboard is built using a Star Schema designed in MySQL.

### Fact Table

* Sales

### Dimension Tables

* Customers
* Products
* Orders
* Date (Power BI DAX Date Table)

### Relationships

* Customers → Sales (1:M)
* Products → Sales (1:M)
* Orders → Sales (1:M)
* Date → Orders/Sales (Time Intelligence)

---

## DAX & Business Logic

The dashboard uses DAX for:

* KPI calculations
* Time intelligence
* Dynamic rankings
* Automated business insights
* Context-aware filtering

Detailed DAX measures are documented in:

```text
dax_measures.md
```

Key concepts demonstrated:

* CALCULATE
* DATEADD
* VAR
* TOPN
* FILTER
* ADDCOLUMNS
* SUMMARIZE
* CONCATENATEX
* DIVIDE
* Dynamic Text Generation

---

## Tools & Technologies

* Power BI Desktop
* DAX
* Power Query
* MySQL
* Star Schema Modeling

---

## How to Open

1. Download `Superstore_Dashboard.pbix`
2. Open using Power BI Desktop
3. Reconnect to your local MySQL database if required
4. Refresh the data model

---

## Project Objective

The goal of this dashboard is to convert raw transactional data into business insights that support decision-making around:

* Product profitability
* Discount strategy
* Customer value
* Regional performance
* Revenue growth
* Operational efficiency
