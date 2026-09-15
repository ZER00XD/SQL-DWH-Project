# Data Warehouse & Analytics Project 🚀

A modern end-to-end data warehousing and analytics solution following industry best practices in data engineering and BI.

> 🎓 **Credit & Learning Source:** Developed based on the tutorial and guidance by **Eng. Baraa Khatib Salkini** ([Data with Baraa YouTube Channel](https://www.youtube.com/watch?v=SSKVgrwhzus)).

---

## 🏗️ Data Architecture

This project implements a **Medallion Architecture** using **SQL Server** for storage and transformations, flowing from raw sources to consumption layers:

![Data Architecture]<img width="1391" height="581" alt="Screenshot 2026-09-08 171245" src="https://github.com/user-attachments/assets/b2f3814a-533f-4b1e-b0b4-455367985818" />



### Architectural Layers
* **Data Sources**: CSV files from **CRM** and **ERP** systems.
* **Bronze Layer (Raw Data)**:
  * **Load Method**: Full load / Batch processing (Truncate & Insert).
  * **Data Model**: As-is source data without transformations.
* **Silver Layer (Cleansed Data)**:
  * **Transformation**: Data cleaning, standardization, normalization, derived columns, and enrichment.
  * **Load Method**: Full load batch processing (Truncate & Insert).
* **Gold Layer (Business-Ready Data)**:
  * **Implementation**: Database **Views** (No physical load).
  * **Transformation**: Data integration, aggregation, and applied business logic.
  * **Data Models**: Star Schema, flat tables, and aggregated tables.
* **Consume Layer**: Serves business intelligence reporting, direct SQL queries, and Machine Learning workflows.

---

## 🎯 Objectives & Scope

* **Data Engineering**: Build ETL pipelines in SQL Server to ingest CSV sources, clean data quality issues, and build an integrated dimensional model.
* **Analytics & BI**: Author optimized SQL queries to analyze customer behavior, product performance, and sales trends.

---

## 🛠️ Resources & Documentation

* **[Notion Project Documentation](https://app.notion.com/p/Data-Warehouse-Project-3d43b2bde6d680cda11de0b5cade7261)** — Detailed project roadmap, phases, and task breakdowns.
* **[Tutorial Video](https://www.youtube.com/watch?v=SSKVgrwhzus)** — *SQL Full Course* by Eng. Baraa.
* **Tools Used**: SQL Server Express, SSMS, Draw.io, Git, Notion.

---
***text
## 📂 Project Structure
SQL-DWH-Project/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp/
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
│
├── docs/
│   ├── data_catalog.md
│   ├── data_architecture.drawio
│   └── naming_conventions.md
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   │
│   └── gold/
│       └── ddl_gold.sql
│
├── tests/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── LICENSE
└── README.md
***
## 📜 License

This project is licensed under the MIT License.

The MIT License is a permissive open-source license that allows others to use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software, provided that the original copyright and license notice are included.
