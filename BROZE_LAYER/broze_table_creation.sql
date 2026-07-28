/*==========================================================
    ECOMMERCE SQL PRACTICE DATABASE
    Microsoft SQL Server Complete Script
==========================================================*/

--==========================================================
-- CREATE DATABASE
--==========================================================


IF DB_ID('EcommerceDB') IS NULL
BEGIN
    CREATE DATABASE EcommerceDB;
END
GO

USE EcommerceDB;
GO

/*==========================================================
DROP TABLES (Optional)
==========================================================*/

DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS shippers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS categories;
GO

/*==========================================================
1. CATEGORIES
==========================================================*/
DROP TABLE IF EXISTS categories;
GO

CREATE TABLE categories
(
    category_id INT,
    category_name VARCHAR(100),
    department VARCHAR(100),
    gst_percent INT,
);

GO

/*==========================================================
2. SUPPLIERS
==========================================================*/

DROP TABLE IF EXISTS suppliers;
GO

CREATE TABLE suppliers
(
    supplier_id                INT                 NOT NULL,
    supplier_name              VARCHAR(150)        NULL,
    contact_person             VARCHAR(100)        NULL,
    email                      VARCHAR(150)        NULL,
    phone                      VARCHAR(20)         NULL,
    city                       VARCHAR(100)        NULL,
    state                      VARCHAR(100)        NULL,
    country                    VARCHAR(100)        NULL,
    gst_number                 VARCHAR(20)         NULL,
    supplier_type              VARCHAR(50)         NULL,
    payment_terms              VARCHAR(50)         NULL,
    established_year           SMALLINT            NULL,
    years_of_business          INT                 NULL,
    supplier_rating            DECIMAL(3,2)        NULL,
    total_products             INT                 NULL,
    international_supplier     VARCHAR(5)          NULL,
    average_delivery_days      INT                 NULL,
    annual_business            DECIMAL(18,2)       NULL,
    website                    VARCHAR(255)        NULL,
    is_active                  VARCHAR(5)          NULL
);

GO
GO

/*==========================================================
3. CUSTOMERS
==========================================================*/
DROP TABLE IF EXISTS customers;
GO

CREATE TABLE customers
(
    customer_id           INT                NOT NULL,
    first_name            VARCHAR(100)       NULL,
    last_name             VARCHAR(100)       NULL,
    gender                VARCHAR(20)        NULL,
    age                   INT                NULL,
    email                 VARCHAR(150)       NULL,
    phone                 VARCHAR(20)        NULL,
    city                  VARCHAR(100)       NULL,
    state                 VARCHAR(100)       NULL,
    registration_date     DATE               NULL,
    customer_segment      VARCHAR(50)        NULL,
    credit_score          INT                NULL,
    total_orders          INT                NULL,
    lifetime_value        DECIMAL(18,2)      NULL,
    is_active             VARCHAR(5)         NULL,
    preferred_payment     VARCHAR(50)        NULL,
    marital_status        VARCHAR(20)        NULL,
    occupation            VARCHAR(100)       NULL,
    annual_income         DECIMAL(18,2)      NULL,
    pincode               VARCHAR(10)        NULL
);
GO


/*==========================================================
4. EMPLOYEES
==========================================================*/
DROP TABLE IF EXISTS employees;
GO

CREATE TABLE employees
(
    employee_id            INT                 NOT NULL,
    first_name             VARCHAR(100)        NULL,
    last_name              VARCHAR(100)        NULL,
    gender                 VARCHAR(20)         NULL,
    age                    INT                 NULL,
    department             VARCHAR(100)        NULL,
    designation            VARCHAR(100)        NULL,
    salary                 DECIMAL(12,2)       NULL,
    bonus                  DECIMAL(12,2)       NULL,
    experience_years       INT                 NULL,
    manager_id             VARCHAR(20)         NULL,
    city                   VARCHAR(100)        NULL,
    state                  VARCHAR(100)        NULL,
    email                  VARCHAR(150)        NULL,
    phone                  VARCHAR(20)         NULL,
    joining_date           DATE                NULL,
    shift                  VARCHAR(30)         NULL,
    employment_type        VARCHAR(30)         NULL,
    is_active              VARCHAR(5)          NULL,
    performance_rating     DECIMAL(3,2)        NULL
);
GO
/*==========================================================
5. SHIPPERS
==========================================================*/
DROP TABLE IF EXISTS shippers;
GO

CREATE TABLE shippers
(
    shipper_id                  INT                 NOT NULL,
    company_name                VARCHAR(150)        NULL,
    shipping_mode               VARCHAR(50)         NULL,
    contact_person              VARCHAR(100)        NULL,
    email                       VARCHAR(150)        NULL,
    phone                       VARCHAR(20)         NULL,
    city                        VARCHAR(100)        NULL,
    state                       VARCHAR(100)        NULL,
    country                     VARCHAR(100)        NULL,
    established_year            SMALLINT            NULL,
    company_rating              DECIMAL(3,2)        NULL,
    average_delivery_days       INT                 NULL,
    shipping_charge             DECIMAL(10,2)       NULL,
    total_orders_handled        INT                 NULL,
    international_shipping      VARCHAR(5)          NULL,
    support_availability        VARCHAR(50)         NULL,
    transport_mode              VARCHAR(50)         NULL,
    cod_available               VARCHAR(5)          NULL,
    website                     VARCHAR(255)        NULL,
    status                      VARCHAR(20)         NULL
);
GO

/*==========================================================
6. PRODUCTS
==========================================================*/
DROP TABLE IF EXISTS products;
GO

CREATE TABLE products
(
    product_id             INT                 NOT NULL,
    category_id            INT                 NULL,
    supplier_id            INT                 NULL,
    sku                    VARCHAR(50)         NULL,
    product_name           VARCHAR(200)        NULL,
    brand                  VARCHAR(100)        NULL,
    cost_price             DECIMAL(10,2)       NULL,
    selling_price          DECIMAL(10,2)       NULL,
    discount_percent       DECIMAL(5,2)        NULL,
    gst_percent            DECIMAL(5,2)        NULL,
    stock_quantity         INT                 NULL,
    reorder_level          INT                 NULL,
    rating                 DECIMAL(3,2)        NULL,
    launch_date            DATE                NULL,
    warranty_months        INT                 NULL,
    color                  VARCHAR(50)         NULL,
    unit                   VARCHAR(20)         NULL,
    status                 VARCHAR(20)         NULL,
    inventory_value        DECIMAL(18,2)       NULL,
    returnable             VARCHAR(5)          NULL
);
GO

/*==========================================================
7. ORDERS
==========================================================*/
DROP TABLE IF EXISTS orders;
GO

CREATE TABLE orders
(
    order_id              INT                 NOT NULL,
    customer_id           INT                 NULL,
    employee_id           INT                 NULL,
    shipper_id            INT                 NULL,
    order_date            DATE                NULL,
    ship_date             DATE                NULL,
    expected_delivery     DATE                NULL,
    actual_delivery       DATE                NULL,
    order_status          VARCHAR(30)         NULL,
    payment_status        VARCHAR(30)         NULL,
    payment_method        VARCHAR(50)         NULL,
    shipping_cost         DECIMAL(10,2)       NULL,
    coupon_code           VARCHAR(50)         NULL,
    discount_percent      DECIMAL(5,2)        NULL,
    order_amount          DECIMAL(18,2)       NULL,
    customer_rating       INT                 NULL,
    gift_order            VARCHAR(5)          NULL,
    order_source          VARCHAR(30)         NULL,
    order_time_slot       VARCHAR(30)         NULL,
    delivery_city         VARCHAR(100)        NULL
);
GO


/*==========================================================
8. ORDER_ITEMS
==========================================================*/
DROP TABLE IF EXISTS order_items;
GO

CREATE TABLE order_items
(
    order_item_id         INT                 NOT NULL,
    order_id              INT                 NULL,
    product_id            INT                 NULL,
    quantity              INT                 NULL,
    cost_price            DECIMAL(10,2)       NULL,
    unit_price            DECIMAL(10,2)       NULL,
    discount_percent      DECIMAL(5,2)        NULL,
    discount_amount       DECIMAL(10,2)       NULL,
    gst_percent           DECIMAL(5,2)        NULL,
    gst_amount            DECIMAL(10,2)       NULL,
    total_amount          DECIMAL(18,2)       NULL,
    profit                DECIMAL(18,2)       NULL,
    returnable            VARCHAR(5)          NULL,
    shipping_type         VARCHAR(50)         NULL,
    warehouse             VARCHAR(100)        NULL,
    sales_region          VARCHAR(100)        NULL,
    sales_channel         VARCHAR(50)         NULL,
    gift_wrap             VARCHAR(5)          NULL,
    warranty_months       INT                 NULL,
    item_status           VARCHAR(30)         NULL
);
GO


/*==========================================================
9. PAYMENTS
==========================================================*/
DROP TABLE IF EXISTS payments;
GO

CREATE TABLE payments
(
    payment_id             INT                 NOT NULL,
    order_id               INT                 NULL,
    payment_date           DATE                NULL,
    payment_method         VARCHAR(50)         NULL,
    payment_status         VARCHAR(30)         NULL,
    amount_paid            DECIMAL(18,2)       NULL,
    transaction_id         VARCHAR(100)        NULL,
    bank_name              VARCHAR(100)        NULL,
    gateway_status         VARCHAR(30)         NULL,
    payment_platform       VARCHAR(50)         NULL,
    card_type              VARCHAR(30)         NULL,
    emi_used               VARCHAR(5)          NULL,
    processing_fee         DECIMAL(10,2)       NULL,
    transaction_type       VARCHAR(30)         NULL,
    payment_time_slot      VARCHAR(30)         NULL,
    cashback_received      VARCHAR(10)         NULL,
    settlement_status      VARCHAR(30)         NULL,
    payment_city           VARCHAR(100)        NULL,
    fraud_flag             VARCHAR(5)          NULL,
    retry_count            INT                 NULL
);
GO

/*==========================================================
10. RETURNS
==========================================================*/
DROP TABLE IF EXISTS returns;
GO

CREATE TABLE returns
(
    return_id              INT                 NOT NULL,
    order_id               INT                 NULL,
    customer_id            INT                 NULL,
    return_date            DATE                NULL,
    return_reason          VARCHAR(100)        NULL,
    refund_amount          DECIMAL(18,2)       NULL,
    refund_status          VARCHAR(30)         NULL,
    inspection_status      VARCHAR(30)         NULL,
    return_mode            VARCHAR(50)         NULL,
    warehouse              VARCHAR(100)        NULL,
    product_condition      VARCHAR(50)         NULL,
    resolution             VARCHAR(50)         NULL,
    exchange_requested     VARCHAR(5)          NULL,
    processing_days        INT                 NULL,
    refund_method          VARCHAR(50)         NULL,
    customer_feedback      VARCHAR(255)        NULL,
    region                 VARCHAR(100)        NULL,
    case_status            VARCHAR(30)         NULL,
    pickup_completed       VARCHAR(5)          NULL,
    ticket_status          VARCHAR(30)         NULL
);
GO


/*==========================================================
DATABASE CREATED SUCCESSFULLY
==========================================================

NEXT STEP

