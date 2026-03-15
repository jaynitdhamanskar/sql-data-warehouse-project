# SQL Data Warehouse and Analytics Project

Welcome to the **SQL Data Warehouse and Analytics Project** repository! 🚀
This project demonstrates how to design and build a **modern data warehouse using SQL Server**, implementing ETL pipelines and preparing business-ready data for analytics.

The project follows industry best practices in **data engineering, data modeling, and analytics** and is designed as a **portfolio project to demonstrate real-world data warehouse development**.

---

# 🏗️ Data Architecture

The project follows the **Medallion Architecture**, consisting of Bronze, Silver, and Gold layers.

![image](docs/architecture_drawio.png)

### Bronze Layer

* Stores **raw data** from source systems.
* Data is loaded directly from **CSV files** into SQL Server tables.
* No transformations are applied.

### Silver Layer

* Performs **data cleansing and transformation**.
* Standardizes formats and removes inconsistencies.
* Prepares data for analytical modeling.

### Gold Layer

* Contains **analytics-ready datasets**.
* Data is modeled into **Fact and Dimension tables (Star Schema)**.
* Optimized for reporting and BI tools.

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---

## 🛠️ Tools:

- **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting your SQL database.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Notion](https://www.notion.com/templates/sql-data-warehouse-project):** Get the Project Template from Notion
- **[Notion Project Steps](https://thankful-pangolin-2ca.notion.site/SQL-Data-Warehouse-Project-16ed041640ef80489667cfe2f380b269?pvs=4):** Access to All Project Phases and Tasks.

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

---

# 📂 Repository Structure

```
data-warehouse-project/

│
├── datasets/                         # Raw datasets (ERP & CRM source data)
│
├── docs/                             # Documentation and architecture diagrams
│   ├── architecture.drawio
│   ├── data_catalog.md
│   ├── data_flow_diagram.drawio
│   ├── data_models.drawio
│   ├── naming_conventions.md
│
├── scripts/                          # SQL scripts for ETL pipelines
│   ├── bronze/                       # Raw data ingestion scripts
│   ├── silver/                       # Data cleaning and transformation
│   ├── gold/                         # Analytical data models
│
├── tests/                            # Data quality tests
│
├── LICENSE                           # License file
└── README.md                         # Project documentation
```

---

# 🛡️ License

This project is licensed under the **MIT License**.
You are free to use, modify, and distribute this project with proper attribution.

---

# 👨‍💻 Author

**Jaynit Dhamanskar**

This project was created as a **portfolio project to demonstrate practical data engineering and SQL data warehousing skills.**

If you found this project helpful or interesting, feel free to ⭐ star the repository.
