# Superstore Sales Data Analysis using SQL Server

## Project Overview

This project analyzes Superstore sales data using Microsoft SQL Server.

The project demonstrates relational database design, data migration, SQL data analysis, stored procedures, and query performance optimization.

## Technologies Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL
- GitHub

## Database Design

The project uses a normalized relational database consisting of:

- Customers
- Products
- Orders
- OrderDetails
- Locations

## Key SQL Concepts

- Table creation and relationships
- Primary Keys and Foreign Keys
- Data migration and transformation
- INNER JOIN
- GROUP BY and aggregate functions
- CTEs
- Window Functions
- RANK()
- LAG()
- Stored Procedures
- Indexing
- Execution Plan Analysis
- Query Performance Optimization

## Analysis Performed

- Sales and profit analysis by category
- Sales and profit analysis by region
- Top 10 products by sales
- Product sales ranking
- Monthly sales comparison
- Regional sales reporting using a stored procedure

## Performance Optimization

Indexes were created on frequently joined columns and execution plans and query statistics were analyzed.

The tested query achieved approximately 13% lower elapsed execution time after indexing.

## Project Results

- Total Orders: 5,111
- Total Customers: 801
- Total Products: 1,862
- Total Sales: $2,326,534.21
- Total Profit: $292,716.33
- Total Quantity: 38,654
