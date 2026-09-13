--  Data Cleaning

SELECT *
FROM ecommerce_sales;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove Any Columns or Rows

CREATE TABLE ecommerce_sales_staging
LIKE ecommerce_sales;

SELECT *
FROM ecommerce_sales_staging;

INSERT ecommerce_sales_staging
SELECT *
FROM ecommerce_sales;

-- 1. Remove Duplicates
WITH duplicate_cte AS
(
SELECT  *,
		ROW_NUMBER() OVER(
			PARTITION BY ID, Order_ID
			ORDER BY ID) Row_Num
FROM ecommerce_sales_staging
)
SELECT *
FROM duplicate_cte 
WHERE Row_Num > 1;

WITH duplicate_cte AS
(
SELECT  *,
		ROW_NUMBER() OVER(
			PARTITION BY ID, Order_ID
			ORDER BY ID) Row_Num
FROM ecommerce_sales_staging
)
SELECT * FROM ecommerce_sales_staging
WHERE ID IN (
	SELECT ID
	FROM duplicate_cte 
	WHERE Row_Num > 1
);

CREATE TABLE `ecommerce_sales_staging2` (
  `ID` int DEFAULT NULL,
  `Customer_Name` text,
  `Order_ID` text,
  `Order_Date` text,
  `Product` text,
  `Category` text,
  `Quantity` int DEFAULT NULL,
  `Price` text,
  `Payment_Method` text,
  `Status` text,
  `Total` text,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM ecommerce_sales_staging2;

INSERT INTO ecommerce_sales_staging2
SELECT  *,
		ROW_NUMBER() OVER(
			PARTITION BY ID, Order_ID
			ORDER BY ID) AS Row_Num
FROM ecommerce_sales_staging;

DELETE
FROM ecommerce_sales_staging2
WHERE Row_Num > 1;

-- 2. Standardize the Data
-- 'Electronics' 
SELECT DISTINCT(Category)
FROM ecommerce_sales_staging2
ORDER BY 1;

SELECT *
FROM ecommerce_sales_staging2
WHERE Category = 'electronic'
OR Category = 'Electronics';

UPDATE ecommerce_sales_staging2
SET Category = 'Electronics'
WHERE Category = 'electronic'
OR Category = 'Electronics';

SELECT Product, Category,
	   COUNT(*) 
FROM ecommerce_sales_staging2
GROUP BY Product, Category
ORDER BY Product, Category;

SELECT  DISTINCT(Category),
		LENGTH(Category)
FROM ecommerce_sales_staging2;
-- nan
SELECT Category, ''
FROM ecommerce_sales_staging2
WHERE Category = 'nan';

UPDATE ecommerce_sales_staging2
SET Category = ''
WHERE Category = 'nan';

-- Column Price
SELECT DISTINCT(Price)
FROM ecommerce_sales_staging2
ORDER BY 1 DESC;

SELECT price, 400
FROM ecommerce_sales_staging2
WHERE Price = 'four hundred';

UPDATE ecommerce_sales_staging2
SET price = 400 
WHERE Price = 'four hundred';

SELECT price, ''
FROM ecommerce_sales_staging2
WHERE Price = 'abd';

UPDATE ecommerce_sales_staging2
SET price = '' 
WHERE Price = 'abd';

SELECT *
FROM ecommerce_sales_staging2;

-- Change data type of columns: Order_Date, 
SELECT Order_Date, STR_TO_DATE(Order_Date, '%m/%d/%Y')
FROM ecommerce_sales_staging2
ORDER BY 2;

SELECT Order_Date, '1/5/2023' 
FROM ecommerce_sales_staging2
WHERE Order_Date = 'Jan 5 2023';

UPDATE ecommerce_sales_staging2
SET Order_Date = '1/5/2023' 
WHERE Order_Date = 'Jan 5 2023';

UPDATE ecommerce_sales_staging2
SET Order_Date = STR_TO_DATE(Order_Date, '%m/%d/%Y');

ALTER TABLE ecommerce_sales_staging2
MODIFY COLUMN Order_Date DATE;

-- 3. Null values or blank values
SELECT *
FROM ecommerce_sales_staging2
WHERE Category IS NULL 
OR Category = '';

UPDATE ecommerce_sales_staging2
SET  Category = NULL 
WHERE Category = '';

SELECT DISTINCT
t1.Product, 
t2.Product, 
t1.Category, t2.Category
FROM ecommerce_sales_staging2 t1
JOIN ecommerce_sales_staging2 t2
	ON t1.Product = t2.Product
WHERE t1.Category IS NULL 
AND t2.Category IS NOT NULL 
;

SELECT Product, Category, 
		COUNT(*)
FROM ecommerce_sales_staging2
WHERE Product = 'Vacuum'
GROUP BY Product, Category;

SELECT Product, Category 
FROM ecommerce_sales_staging2 
WHERE Product = 'Vacuum' 
AND Category = 'Electronics';

UPDATE ecommerce_sales_staging2
SET  Category = 'Home'
WHERE Product = 'Vacuum' 
AND Category = 'Electronics';

SELECT *
FROM ecommerce_sales_staging2
WHERE Product = 'Vacuum';

UPDATE ecommerce_sales_staging2 t1
JOIN ecommerce_sales_staging2 t2
	ON t1.Product = t2.Product
SET t1.Category = t2.Category
WHERE t1.Category IS NULL 
AND t2.Category IS NOT NULL ;


SELECT *
FROM ecommerce_sales_staging2;

-- Clean: Quantity, Price, Total
SELECT DISTINCT Quantity
FROM ecommerce_sales_staging2
ORDER BY 1;

SELECT *
FROM ecommerce_sales_staging2
WHERE Quantity < 0;

SELECT
    Quantity,
    Price,
    Total,
    CASE
        WHEN Quantity < 0 THEN 'Return'
        WHEN Quantity = 0 THEN 'Zero Quantity'
        ELSE 'Sale'
    END AS Transaction_Type
FROM ecommerce_sales_staging2
ORDER BY 1;

ALTER TABLE ecommerce_sales_staging2
ADD COLUMN Transaction_Type VARCHAR(20);

UPDATE ecommerce_sales_staging2
SET Transaction_Type = 
	CASE
        WHEN Quantity < 0 THEN 'Return'
        WHEN Quantity = 0 THEN 'Zero Quantity'
        ELSE 'Sale'
    END;

SELECT DISTINCT Price
FROM ecommerce_sales_staging2
ORDER BY 1;

SELECT Price, 300	
FROM ecommerce_sales_staging2
WHERE Price LIKE '%$';

UPDATE ecommerce_sales_staging2
SET Price = 300 
WHERE Price LIKE '%$';

SELECT Quantity, Price, Total
FROM ecommerce_sales_staging2;

SELECT *
FROM ecommerce_sales_staging2
WHERE Price = ''
AND Total = '';

DELETE 
FROM ecommerce_sales_staging2
WHERE Price = ''
AND Total = '';

SELECT DISTINCT Price, ABS(Price)
FROM ecommerce_sales_staging2
ORDER BY 1;

UPDATE ecommerce_sales_staging2
SET Price = ABS(Price);

ALTER TABLE ecommerce_sales_staging2
MODIFY COLUMN Price DECIMAL(10,2);

SELECT DISTINCT Total
FROM ecommerce_sales_staging2
ORDER BY 1;

SELECT *, 
Quantity * Price
FROM ecommerce_sales_staging2
WHERE Total = '';

UPDATE ecommerce_sales_staging2
SET Total = Quantity * Price
WHERE Total = '';

SELECT *, ABS(Total)
FROM ecommerce_sales_staging2
WHERE Total < 0 
AND Quantity > 0;

UPDATE ecommerce_sales_staging2
SET Total = ABS(Total)
WHERE Total < 0 
AND Quantity > 0;

ALTER TABLE ecommerce_sales_staging2
MODIFY COLUMN Total DECIMAL(12,2);

-- 4. Remove Any Columns or Rows
SELECT *
FROM ecommerce_sales_staging2;

ALTER TABLE ecommerce_sales_staging2
DROP COLUMN Row_Num;

