

/****************************************** DATA CLEANING FOR crm_cust_info TABLE ********************************************/
						
                        /****************** START ********************/


-- CHECK FOR DUPLICATES AND NULL ID'S
SELECT
cst_id,
COUNT(*)
FROM crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- NO DUPLICATES BASED ON PK('cst_id')
SELECT
*
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS FLAG_LAST
	FROM crm_cust_info
    WHERE cst_id IS NOT NULL
) t 
WHERE FLAG_LAST != 1;

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	cst_firstname,
	cst_lastname 
    -- cst_marital_status, cst_gndr have no whitespaces
FROM crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname); 

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT 
DISTINCT cst_gndr
FROM crm_cust_info;

SELECT 
DISTINCT cst_marital_status
FROM crm_cust_info;


-- ALTER DATE COLUMN TO DATE TYPE
ALTER TABLE crm_cust_info
MODIFY COLUMN cst_create_date DATE;


-- CREATE TEMPPORARY TABLE AND INSERT CLEANED DATA INTO IT
CREATE TEMPORARY TABLE cleaned_cust_data(
-- MAIN QUERY AFTER CLEANING CUSTOMER DATA
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE 'n/a'
		END AS cst_marital_status,
		CASE
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS FLAG_LAST
		FROM crm_cust_info
		WHERE cst_id IS NOT NULL
	) t 
	WHERE FLAG_LAST = 1
);

-- TRUNCATE THE MAIN CUSTOMER INFO DATA
TRUNCATE TABLE crm_cust_info;

-- NOW INSERT THE TEMPORARY CLEANED DATA INTO MAIN CUSTOMER TABLE
INSERT INTO crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
SELECT * FROM cleaned_cust_data;

-- NOW DROP TEMPORARY TABLE
DROP TABLE IF EXISTS cleaned_cust_data;

									/****************** END ********************/

/****************************************** DATA CLEANING FOR crm_prd_info TABLE ********************************************/
									
                                    /****************** START ********************/
-- CHECK FOR DUPLICATES AND NULL ID'S
SELECT
	prd_id,
	COUNT(*) AS DuplicatesValues
FROM crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	prd_nm
FROM crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- CHECK NULL VALUES OR NEGATIVE NUMBERS
SELECT
*
FROM crm_prd_info
WHERE prd_cost < 0 
OR prd_cost IS NULL;

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT 
	DISTINCT prd_line
FROM crm_prd_info;

-- CHECK FOR INVALID DATE ORDERS
SELECT
*
FROM crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ALTER DATE COLUMN TO DATE TYPE
ALTER TABLE crm_prd_info
MODIFY COLUMN prd_start_dt DATE,
MODIFY COLUMN prd_end_dt DATE;


-- CREATE TEMPPORARY TABLE AND INSERT CLEANED DATA INTO IT
CREATE TEMPORARY TABLE cleaned_prd_data(
    -- MAIN QUERY AFTER CLEANING PRODUCT DATA
	SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		TRIM(SUBSTRING(prd_key, 7, LENGTH(prd_key))) AS prd_key,
		prd_nm,
		COALESCE(prd_cost, 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS prd_end_dt
	FROM crm_prd_info
);

-- TRUNCATE THE MAIN PRODUCT INFO DATA
TRUNCATE TABLE crm_prd_info;

-- NOW INSERT THE TEMPORARY CLEANED DATA INTO MAIN CUSTOMER TABLE
INSERT INTO crm_prd_info
SELECT * FROM cleaned_prd_data;

-- NOW DROP TEMPORARY TABLE
DROP TABLE IF EXISTS cleaned_prd_data;

											/****************** END ********************/


/****************************************** DATA CLEANING FOR crm_sales_details TABLE ********************************************/

											/****************** START ********************/

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	sls_prd_key
FROM crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key);

-- CHECK FOR INVALID DATE ORDERS
SELECT
*
FROM crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- CHECK FOR DATA CONSISTENCY: BETWEEN SALES, QUANTITY AND SALE PRICE
-- SALES = QUANTITY * PRICE
-- SALES, QUANTITY AND PRICE SHOULD NOT BE ZERO OR NULLS
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

-- CREATE TEMPPORARY TABLE AND INSERT CLEANED DATA INTO IT
CREATE TEMPORARY TABLE cleaned_sales_data(
	-- MAIN QUERY AFTER CLEANING SALES DATA
	SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE
			WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
		END AS sls_order_dt,
		CASE
			WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
		END AS sls_ship_dt,
		CASE
			WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
		END AS sls_due_dt,
		CASE
			WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) 
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE
			WHEN sls_price <= 0 OR sls_price IS NULL 
				THEN ROUND(sls_sales / NULLIF(sls_quantity,0))
			ELSE sls_price
		END AS sls_price
	FROM crm_sales_details
);

-- TRUNCATE THE MAIN SALES DATA
TRUNCATE TABLE crm_sales_details;

-- CONVERT THE DATA TYPE FOR DATE COLUMNS INTO DATE FROM INT
ALTER TABLE crm_sales_details
MODIFY COLUMN sls_order_dt DATE,
MODIFY COLUMN sls_ship_dt DATE,
MODIFY COLUMN sls_due_dt DATE;

-- NOW INSERT THE TEMPORARY CLEANED DATA INTO MAIN SALES TABLE
INSERT INTO crm_sales_details
SELECT * FROM cleaned_sales_data;

-- NOW DROP TEMPORARY TABLE IF EXISTS
DROP TABLE IF EXISTS cleaned_prd_data;

										/****************** END ********************/