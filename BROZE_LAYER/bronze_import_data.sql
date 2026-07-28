/*

Import CSVs in this order:

1. categories
2. suppliers
3. customers
4. employees
5. shippers
6. products
7. orders
8. order_items
9. payments
10. returns

After cleaning duplicate and invalid records,
add PRIMARY KEY and FOREIGN KEY constraints.

==========================================================*/

USE EcommerceDB;
GO

---------------------------------------------------------
-- 1. CATEGORIES
---------------------------------------------------------

BULK INSERT categories
FROM 'D:\ecoomerce_sales\python_code\categories.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 2. SUPPLIERS
---------------------------------------------------------

BULK INSERT suppliers
FROM 'D:\ecoomerce_sales\python_code\suppliers.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 3. CUSTOMERS
---------------------------------------------------------

BULK INSERT customers
FROM 'D:\ecoomerce_sales\python_code\customers.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 4. EMPLOYEES
---------------------------------------------------------

BULK INSERT employees
FROM 'D:\ecoomerce_sales\python_code\employees.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 5. SHIPPERS
---------------------------------------------------------

BULK INSERT shippers
FROM 'D:\ecoomerce_sales\python_code\shippers.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


---------------------------------------------------------
-- 6. PRODUCTS
---------------------------------------------------------

BULK INSERT products
FROM 'D:\ecoomerce_sales\python_code\products.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 7. ORDERS
---------------------------------------------------------

BULK INSERT orders
FROM 'D:\ecoomerce_sales\python_code\orders.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 8. ORDER_ITEMS
---------------------------------------------------------

BULK INSERT order_items
FROM 'D:\ecoomerce_sales\python_code\order_items.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


---------------------------------------------------------
-- 9. PAYMENTS
---------------------------------------------------------

BULK INSERT payments
FROM 'D:\ecoomerce_sales\python_code\payments.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

---------------------------------------------------------
-- 10. RETURNS
---------------------------------------------------------

BULK INSERT returns
FROM 'D:\ecoomerce_sales\python_code\returns.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

PRINT '========================================';
PRINT 'All CSV files imported successfully.';
PRINT '========================================';
GO