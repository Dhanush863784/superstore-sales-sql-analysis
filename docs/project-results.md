# Project Results

## Database Summary

| Metric | Result |
|---|---:|
| Total Orders | 5,111 |
| Total Customers | 801 |
| Total Products | 1,862 |
| Total Sales | $2,326,534.21 |
| Total Profit | $292,716.33 |
| Total Quantity | 38,654 |

## SQL Analysis

The project includes analysis of:

- Sales and profit by product category
- Sales and profit by region
- Top 10 products by sales
- Product ranking using RANK()
- Monthly sales comparison using LAG()
- Regional sales reports using a stored procedure

## Data Quality Validation

Foreign-key validation checks were performed between:

- Orders and Customers
- Orders and Locations
- OrderDetails and Orders
- OrderDetails and Products

All validation checks returned zero missing relationships.

## Performance Optimization

Indexes were created on frequently joined columns.

Execution plans and query statistics were analyzed to evaluate performance.

The tested customer sales query showed approximately **13% lower elapsed execution time** after indexing.
