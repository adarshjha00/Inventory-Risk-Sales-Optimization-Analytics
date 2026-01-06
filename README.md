# 📦 Inventory Management & Sales Analytics Project (SQL)

An **end-to-end SQL analytics project** focused on inventory optimization, sales performance, customer behavior, and warehouse risk assessment. This project demonstrates **data cleaning, preparation, and advanced analytical querying** using real-world business problem statements.

---

## 🚀 Project Overview

Businesses often face challenges such as:
* Overstocked or understocked products
* Inefficient reorder levels
* Slow-moving inventory tying up capital
* Lack of visibility into customer buying behavior
* Warehouse-level demand vs inventory mismatch

This project addresses these challenges by leveraging **SQL** to generate actionable insights across inventory, orders, customers, products, warehouses, and categories.

---
## 🛠️ Tools & Technologies

* **SQL (MySQL)**
* Concepts Used:
  * Case & Join
  * Data Cleaning & Standardization
  * Common Table Expressions (CTEs)
  * Window Functions (`LAG`)
  * Subquery
  * Aggregations (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`)
  * Conditional Logic (`CASE`)
  * NULL Handling (`COALESCE`)
  
---

## 🧱 Database Schema

The project uses the following tables:

* `Products` – Product master data (price, category, reorder level)
* `Inventory` – Stock levels across warehouses
* `Order_Details` – Order transactions and quantities
* `Customers` – Customer details
* `Warehouses` – Warehouse information
* `Categories` – Product categories

---

## 🧹 Data Cleaning & Preparation

Key data preparation steps include:

* Standardized ID columns across tables (`VARCHAR`)
* Converted price fields to `DECIMAL(10,2)`
* Normalized order date formats to `DATE`
* Handled missing values in customer contact data
* Validated data quality (negative stock, invalid prices, quantities)
* Email domain profiling for data validation

---

## 📊 Analytical Problem Statements Covered

### 🔹 Inventory Analysis

* Products below reorder level
* Out-of-stock products by warehouse
* Total inventory per product (across warehouses)
* Overstocked products with low demand
* Products never ordered but stocked
* Products where ordered quantity exceeded available stock
* Products frequently triggering reorder alerts
* Product with highest inventory value

### 🔹 Sales & Revenue Analysis

* Total revenue per product
* Top 5 best-selling products
* Bottom 5 slow-moving products
* Revenue contribution by product category
* Slow-moving categories with high inventory cost

### 🔹 Customer Analytics

* Top 10 customers by total order value
* Customer segmentation: One-Time vs Repeat buyers
* Average order value per customer
* Customers placing frequent bulk orders

### 🔹 Time-Based & Trend Analysis

* Average time gap between consecutive orders per product
* Month with peak order volume

### 🔹 Warehouse Analysis

* Total inventory stored per warehouse
* Warehouses with high demand but low inventory (Risk Number)

---

## 📈 Key Business Insights

* Identified products requiring immediate restocking based on reorder levels
* Detected overstocked items tying up inventory cost
* Highlighted slow-moving products and categories for optimization
* Segmented customers to support targeted marketing strategies
* Assessed warehouse risk using demand vs inventory gap

---

## 🧠 Advanced SQL Techniques Highlighted

* **CTEs** for modular and readable queries
* **Window Functions** to analyze order patterns over time
* **CASE statements** for business-rule-driven insights
* **LEFT JOIN + COALESCE** for safe handling of missing data

---

## 📂 Project Structure

```
Inventory-Management-Analytics/
│
├── SQL_Scripts.sql

├── README.md
 
└── Documentation 

---

## 🎯 Use Case

* **Resume Project** for Data Analyst / Business Analyst roles
* **SQL Interview Showcase** demonstrating real-world problem solving
* **Portfolio Project** for GitHub

---

## ✅ Conclusion

This project showcases the ability to:

* Translate business problems into SQL queries
* Perform structured data cleaning and validation
* Apply advanced SQL concepts for meaningful insights
* Deliver analysis that supports data-driven decision making

---

⭐ *If you find this project useful, feel free to star the repository!*
