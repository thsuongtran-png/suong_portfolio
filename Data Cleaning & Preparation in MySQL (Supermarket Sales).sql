-- Data Supermarket Sales Cleaning

SELECT *
FROM supermarket_sales;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove Any Columns or Rows

CREATE TABLE supermarket_sales_staging
LIKE supermarket_sales;

SELECT *
FROM supermarket_sales_staging;

INSERT supermarket_sales_staging
SELECT *
FROM supermarket_sales;

-- Remove Duplicates

SELECT 
*, 
ROW_NUMBER() OVER(PARTITION BY invoice_id) row_num
FROM supermarket_sales;


CREATE TABLE `supermarket_sales_staging2` (
  `invoice_id` text,
  `branch` text,
  `city` text,
  `customer_type` text,
  `gender_customer` text,
  `product_line` text,
  `unit_cost` double DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `5pct_markup` double DEFAULT NULL,
  `revenue` double DEFAULT NULL,
  `date` text,
  `time` text,
  `payment_method` text,
  `cogs` double DEFAULT NULL,
  `gm_pct` double DEFAULT NULL,
  `gross_income` double DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM supermarket_sales_staging2;

INSERT INTO supermarket_sales_staging2
SELECT 
*, 
ROW_NUMBER() OVER(PARTITION BY invoice_id) row_num
FROM supermarket_sales;



DELETE
FROM supermarket_sales_staging2
WHERE row_num > 1;

SELECT *
FROM supermarket_sales_staging2;

-- Standardize the Data

SELECT 
	`date`, STR_TO_DATE(`date`, '%m/%d/%Y'),
    `time`, STR_TO_DATE(time, '%H:%i')
FROM supermarket_sales_staging2; 

UPDATE supermarket_sales_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'),
	`time` = STR_TO_DATE(time, '%H:%i');

ALTER TABLE supermarket_sales_staging2
MODIFY COLUMN `date` DATE,
MODIFY COLUMN `time` TIME;

-- Null values or blank values

-- Remove Any Columns or Rows

ALTER TABLE supermarket_sales_staging2
DROP COLUMN row_num;


SELECT *
FROM supermarket_sales_staging2;