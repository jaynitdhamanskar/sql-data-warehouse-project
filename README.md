# Data Warehouse Project

## Overview

Designed and implemented an end-to-end data warehouse and analytics solution using SQL Server and Power BI.

The project follows Medallion Architecture (Bronze → Silver → Gold) to transform raw ERP and CRM datasets into analytics-ready business models and interactive dashboards.

The solution includes:
- SQL-based ETL pipelines
- Data cleansing and transformation
- Star schema modeling
- KPI reporting and business analytics
- Interactive Power BI dashboards

---

## Project Highlights

- Built a complete Bronze, Silver, and Gold layer architecture
- Integrated ERP and CRM datasets into SQL Server
- Processed business data containing:
  - $29.36M total sales
  - 28K orders
  - 18K customers
- Developed 3 analytical dashboards covering:
  - Executive reporting
  - Customer analytics
  - Product performance
- Implemented customer segmentation, recency analysis, and KPI reporting using advanced SQL

---

# Architecture

The project follows Medallion Architecture for scalable data processing and analytics.

![Architecture](docs/architecture_drawio.png)

---

# Technology Stack

| Layer | Technology |
|---|---|
| Data Storage | SQL Server |
| ETL & Transformation | SQL |
| Data Modeling | Star Schema |
| Visualization | Power BI |
| Documentation | Draw.io |
| Version Control | Git & GitHub |

---

# Data Architecture

## Bronze Layer

Raw ERP and CRM datasets are ingested into SQL Server without transformations.

Responsibilities:
- Raw data ingestion
- Source preservation
- Initial storage

---

## Silver Layer

The Silver layer performs cleansing, standardization, and transformation.

Transformations include:
- Null handling
- Duplicate removal
- Standardization
- Data type correction
- Business rule validation

---

## Gold Layer

The Gold layer contains analytics-ready business models optimized for reporting and dashboarding.

Implemented models include:
- Fact tables
- Dimension tables
- Reporting views
- KPI aggregations

---

# Data Model

The Gold layer follows a Star Schema design optimized for analytical reporting and Power BI dashboarding.

The model includes:
- Fact Sales table
- Product dimension
- Customer dimension
- Date dimension
- Centralized DAX measures table

![Data Model]([docs/data_model.png](https://github.com/jaynitdhamanskar/sql-data-warehouse-project/blob/main/docs/data_model.png))

---

# Dashboard & Analytics

Power BI dashboards were developed on top of the Gold layer to provide insights across sales, customers, and products.

## Executive Overview

Key metrics and sales performance analysis including:
- Total Sales
- Total Orders
- Revenue Trends
- Category Contribution
- Country-wise Revenue

![Executive Overview](https://github.com/jaynitdhamanskar/sql-data-warehouse-project/blob/main/docs/overview.png)

---

## Customer Insights

Customer behavior and segmentation analysis including:
- Customer Segmentation
- Recency Analysis
- Age Group Distribution
- Average Monthly Spend

![Customer Insights](https://github.com/jaynitdhamanskar/sql-data-warehouse-project/blob/main/docs/customer_insights.png)

---

## Product Performance

Product-level sales and revenue analysis including:
- Top Products by Revenue
- Price Segment Analysis
- Revenue Contribution
- Product Performance Quadrant

![Product Performance](https://github.com/jaynitdhamanskar/sql-data-warehouse-project/blob/main/docs/product_performance.png)

---

# Repository Structure

```text
data-warehouse-project/

├── datasets/
├── docs/
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── tests/
├── dashboard/
└── README.md
```

---

# Data Pipeline Flow

1. Extract ERP and CRM datasets
2. Load raw data into Bronze layer
3. Clean and transform data in Silver layer
4. Build analytical models in Gold layer
5. Create reporting views
6. Connect Power BI to Gold layer
7. Generate business dashboards and insights

---

# SQL Concepts Used

- Common Table Expressions (CTEs)
- Window Functions
- Aggregations
- Stored Procedures
- Views
- Ranking Functions
- Date Functions
- KPI Calculations

---

# Business Insights Delivered

- Revenue trends across time and geography
- Customer segmentation and retention analysis
- Product performance analytics
- Revenue contribution by category
- Customer recency and engagement analysis

---
