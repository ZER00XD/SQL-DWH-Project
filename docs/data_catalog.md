# Gold Layer — Data Catalog

## 1. gold.dim_customers — Customer Dimension

Contains one record for each customer and provides descriptive information about customers.

| Column          | Business Name         | Description                                                                                                       | Example       |
| --------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------- |
| customer_key    | Customer Key          | Unique identifier generated for each customer in the Gold Layer. Used to connect customers to sales transactions. | 1             |
| customer_id     | Customer ID           | Original unique identifier of the customer from the CRM system.                                                   | 11000         |
| customer_number | Customer Number       | Business reference number used to identify the customer across source systems.                                    | AW-00011000   |
| first_name      | First Name            | Customer's first name.                                                                                            | John          |
| last_name       | Last Name             | Customer's last name.                                                                                             | Smith         |
| country         | Country               | Country where the customer is located.                                                                            | United States |
| marital_status  | Marital Status        | Customer's marital status.                                                                                        | Married       |
| gender          | Gender                | Customer's gender. CRM information is preferred; ERP information is used when CRM does not provide a valid value. | Male          |
| birthdate       | Birth Date            | Customer's date of birth.                                                                                         | 1985-06-12    |
| create_date     | Customer Created Date | Date when the customer was originally created in the CRM system.                                                  | 2010-05-15    |

**Business Use:**
Used to understand who the customers are and analyze sales by customer characteristics such as country, gender, marital status, and age.

---

## 2. gold.dim_products — Product Dimension

Contains the current version of each product and its related category information.

| Column         | Business Name  | Description                                                                                                     | Example      |
| -------------- | -------------- | --------------------------------------------------------------------------------------------------------------- | ------------ |
| product_key    | Product Key    | Unique identifier generated for each product in the Gold Layer. Used to connect products to sales transactions. | 101          |
| product_id     | Product ID     | Original product identifier from the CRM system.                                                                | 101          |
| product_number | Product Number | Business reference number used to identify the product.                                                         | BK-R19B-58   |
| product_name   | Product Name   | Name or description of the product.                                                                             | Road-150 Red |
| category_id    | Category ID    | Identifier of the product category.                                                                             | 1            |
| category       | Category       | Main category to which the product belongs.                                                                     | Bikes        |
| subcategory    | Subcategory    | More specific classification within the product category.                                                       | Road Bikes   |
| maintenance    | Maintenance    | Indicates whether the product category requires maintenance.                                                    | Yes          |
| cost           | Product Cost   | Cost associated with producing or acquiring the product.                                                        | 500          |
| product_line   | Product Line   | Business classification of the product.                                                                         | Mountain     |
| start_date     | Start Date     | Date from which the current product version became active.                                                      | 2020-01-01   |

**Business Use:**
Used to analyze what products are being sold, including sales by product, category, subcategory, and product line.

**Note:**
Historical product versions are excluded using `prd_end_dt IS NULL`, so users see the current active version of each product.

---

## 3. gold.fact_sales — Sales Fact

Contains sales transactions and connects customers and products to their sales activity.

| Column        | Business Name | Description                                                                         | Example    |
| ------------- | ------------- | ----------------------------------------------------------------------------------- | ---------- |
| order_number  | Order Number  | Business reference number identifying the sales order.                              | SO43659    |
| product_key   | Product Key   | Key identifying the product associated with the sale. Links to `gold.dim_products`. | 101        |
| customer_key  | Customer Key  | Key identifying the customer who made the purchase. Links to `gold.dim_customers`.  | 25         |
| order_date    | Order Date    | Date when the customer placed the order.                                            | 2020-06-15 |
| shipping_date | Shipping Date | Date when the order was shipped to the customer.                                    | 2020-06-17 |
| due_date      | Due Date      | Expected or required delivery date for the order.                                   | 2020-06-20 |
| sales_amount  | Sales Amount  | Total sales value of the transaction.                                               | 2500       |
| quantity      | Quantity Sold | Number of units of the product purchased.                                           | 3          |
| price         | Unit Price    | Price charged for one unit of the product.                                          | 833.33     |

**Business Use:**
Used to analyze sales performance, revenue, quantities sold, customer purchasing behavior, product performance, and order fulfillment.

---

## Relationships Between the Gold Tables

The Gold Layer follows a Star Schema structure:

gold.dim_customers
|
| customer_key
|
v
gold.fact_sales
^
|
| product_key
|
gold.dim_products

### Business Meaning

* `gold.dim_customers` → Who bought?
* `gold.dim_products` → What did they buy?
* `gold.fact_sales` → What was sold, when, and for how much?

### Example Business Question

"How much revenue did male customers from Egypt generate from Bikes in 2020?"

The `fact_sales` table provides the sales amounts, while the customer and product dimensions provide the descriptive information needed to filter and analyze the sales.
