# Data Warehouse & Analytics Project 🚀

A modern end-to-end data warehousing and analytics solution following industry best practices in **data engineering, data quality, dimensional modeling, and BI**.

> 🎓 **Credit & Learning Source:** Developed based on the tutorial and guidance by **Eng. Baraa Khatib Salkini** ([Data with Baraa YouTube Channel](https://www.youtube.com/watch?v=SSKVgrwhzus)).

---

## 🏗️ Data Architecture

This project implements a **Medallion Architecture** using **SQL Server** for storage and transformations, flowing from raw source systems to business-ready data and analytics.

![Data Architecture](https://github.com/user-attachments/assets/b2f3814a-533f-4b1e-b0b4-455367985818)

### Architectural Layers

* **Data Sources**

  * CSV files from **CRM** and **ERP** systems.
  * Represent the original source data used by the data warehouse.

* **Bronze Layer — Raw Data**

  * **Load Method:** Full load / Batch processing.
  * **Process:** Truncate and Insert.
  * **Data Model:** Source data is stored as-is with minimal transformation.
  * **Purpose:** Preserve the raw source data for further processing.

* **Silver Layer — Cleansed Data**

  * **Transformation:** Data cleaning, standardization, normalization, derived columns, and enrichment.
  * **Load Method:** Full load / Batch processing.
  * **Process:** Truncate and Insert.
  * **Purpose:** Produce reliable and standardized data for downstream modeling.

* **Gold Layer — Business-Ready Data**

  * **Implementation:** SQL Views.
  * **Transformation:** Data integration, business logic, and dimensional modeling.
  * **Data Model:** Star Schema.
  * **Main Objects:**

    * `gold.dim_customers`
    * `gold.dim_products`
    * `gold.fact_sales`
  * **Purpose:** Provide business-ready data for reporting, analytics, and decision-making.

* **Consume Layer**

  * Provides access to the Gold Layer for:

    * Business Intelligence reporting.
    * Direct SQL analysis.
    * Data exploration.
    * Machine Learning workflows.

---

## 🎯 Objectives & Scope

### Data Engineering

* Build an end-to-end data warehouse using SQL Server.
* Develop ETL pipelines to ingest CRM and ERP CSV files.
* Implement Bronze, Silver, and Gold data layers.
* Apply data cleansing and standardization techniques.
* Integrate data from multiple source systems.
* Build a dimensional model using a Star Schema.
* Implement data quality checks and validation processes.

### Analytics & BI

* Analyze customer behavior and demographics.
* Analyze product performance.
* Analyze sales trends and revenue.
* Enable business users to query business-ready data.
* Provide a reliable foundation for BI dashboards and analytical workflows.

---

## ⭐ Gold Layer Data Model

The Gold Layer follows a **Star Schema** consisting of dimension and fact views.

```text
                    ┌─────────────────────┐
                    │   dim_customers     │
                    │                     │
                    │   customer_key      │
                    │   customer_id       │
                    │   customer_number   │
                    │   first_name        │
                    │   last_name         │
                    │   country           │
                    │   gender            │
                    └──────────┬──────────┘
                               │
                               │ customer_key
                               │
                               ▼
                    ┌─────────────────────┐
                    │     fact_sales      │
                    │                     │
                    │   order_number      │
                    │   product_key       │
                    │   customer_key      │
                    │   order_date        │
                    │   sales_amount      │
                    │   quantity          │
                    │   price             │
                    └──────────┬──────────┘
                               │
                               │ product_key
                               │
                               ▼
                    ┌─────────────────────┐
                    │    dim_products     │
                    │                     │
                    │   product_key       │
                    │   product_id        │
                    │   product_number    │
                    │   product_name      │
                    │   category          │
                    │   subcategory       │
                    │   cost              │
                    └─────────────────────┘
```

### Gold Views

| View                 | Purpose                                                                 |
| -------------------- | ----------------------------------------------------------------------- |
| `gold.dim_customers` | Provides descriptive customer information for customer-level analysis.  |
| `gold.dim_products`  | Provides current product and category information for product analysis. |
| `gold.fact_sales`    | Contains sales transactions used for sales and revenue analysis.        |

---

## 🔍 Data Quality & Validation

The project includes validation scripts to ensure data reliability throughout the warehouse.

Data quality checks include:

* Null and duplicate primary key detection.
* Duplicate record detection.
* Data consistency checks.
* Validation of standardized values.
* Verification of relationships between tables.
* Validation of current product records.
* Checks for unexpected or invalid values.

---

## 🛠️ Technologies & Tools

* **SQL Server Express** — Database and data warehouse platform.
* **SQL Server Management Studio (SSMS)** — Database development and management.
* **SQL** — Data transformation, ETL, validation, and analytics.
* **Draw.io** — Data architecture and database modeling diagrams.
* **Git & GitHub** — Version control and project management.
* **Notion** — Project planning and documentation.

---

## 📂 Project Structure

```text
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
```

### Folder Description

| Folder            | Description                                                                                  |
| ----------------- | -------------------------------------------------------------------------------------------- |
| `datasets/`       | Contains the raw CRM and ERP CSV source files used by the data warehouse.                    |
| `docs/`           | Contains project documentation, architecture diagrams, data catalog, and naming conventions. |
| `scripts/`        | Contains SQL scripts for building and loading the Bronze, Silver, and Gold layers.           |
| `scripts/bronze/` | Scripts for creating Bronze tables and loading raw source data.                              |
| `scripts/silver/` | Scripts for creating Silver tables and applying data cleansing and standardization.          |
| `scripts/gold/`   | Scripts for creating business-ready Gold Layer views and dimensional models.                 |
| `tests/`          | Contains data quality and validation scripts for the different warehouse layers.             |
| `LICENSE`         | Contains the project's MIT License.                                                          |
| `README.md`       | Main project documentation, architecture, objectives, tools, and project structure.          |

---

## 📚 Resources & Documentation

* **[Notion Project Documentation](https://app.notion.com/p/Data-Warehouse-Project-3d43b2bde6d680cda11de0b5cade7261)** — Detailed project roadmap, phases, and task breakdowns.
* **[Tutorial Video](https://www.youtube.com/watch?v=SSKVgrwhzus)** — *SQL Full Course* by Eng. Baraa.
* **[GitHub Repository](https://github.com/ZER00XD/SQL-DWH-Project)** — Source code, SQL scripts, datasets, documentation, and tests.

---

## 🎓 Learning Source & Credit

This project was developed as a learning project based on the concepts, workflow, and guidance provided by **Eng. Baraa Khatib Salkini** through the **Data with Baraa** YouTube channel.

The project was implemented and adapted as part of my own learning process in **Data Engineering, SQL, Data Warehousing, ETL, and Analytics**.

You can find the original tutorial here:

**Data with Baraa — SQL Full Course:**
https://www.youtube.com/watch?v=SSKVgrwhzus

---

## 📜 License

This project is licensed under the **MIT License**.

The MIT License is a permissive open-source license that allows others to use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software, provided that the original copyright and license notice are included.

See the [LICENSE](LICENSE) file for the complete license text.

---

## 👨‍💻 Author

**Monzer Mahmoud**

Data Science Student | Aspiring Data Engineer

Interested in:

* Data Engineering
* Data Warehousing
* ETL Pipelines
* SQL
* Big Data
* Data Analytics
* Machine Learning

---

⭐ If you find this project useful, feel free to **star the repository**!
