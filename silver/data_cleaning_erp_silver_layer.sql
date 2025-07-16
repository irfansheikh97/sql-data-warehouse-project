/****************************************** DATA CLEANING FOR erp_cust_az12 TABLE ********************************************/
						
                        /****************** START ********************/


-- CHECK FOR DUPLICATES AND NULL ID'S
SELECT
	cid,
	COUNT(*)
FROM erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- CHECK FOR INCORRECT cid IN TABLE
SELECT
	cid
FROM erp_cust_az12
WHERE cid LIKE 'NAS%';

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	cid,
    gen
FROM erp_cust_az12
WHERE cid != TRIM(cid)
OR gen != TRIM(gen); 

-- CHECK FOR INVALID DATES
SELECT
	bdate
FROM erp_cust_az12
WHERE bdate > CURDATE();

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT 
DISTINCT gen 
FROM erp_cust_az12;


-- CREATE TEMPPORARY TABLE AND INSERT CLEANED DATA INTO IT
CREATE TEMPORARY TABLE cleaned_erp_cust_data(
-- MAIN QUERY AFTER CLEANING CUSTOMER DATA
	SELECT
		CASE 
			WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE TRIM(cid)
		END AS cid,
        CASE 
			WHEN bdate > curdate() THEN NULL
            ELSE bdate
		END AS bdate,
        CASE
			WHEN UPPER(TRIM(gen)) IN('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
		END AS gen
    FROM erp_cust_az12
);

-- TRUNCATE THE MAIN CUSTOMER INFO DATA
TRUNCATE TABLE erp_cust_az12;

-- NOW INSERT THE TEMPORARY CLEANED DATA INTO MAIN ERP CUSTOMER TABLE
INSERT INTO erp_cust_az12
SELECT * FROM cleaned_erp_cust_data;

-- NOW DROP TEMPORARY TABLE
DROP TABLE IF EXISTS cleaned_erp_cust_data;

									/****************** END ********************/

/****************************************** DATA CLEANING FOR erp_loc_a101 TABLE ********************************************/
									
                                    /****************** START ********************/
-- CHECK FOR DUPLICATES AND NULL ID'S
SELECT
	cid,
	COUNT(*) AS DuplicatesValues
FROM erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- CHECK FOR INCORRECT cid IN TABLE
SELECT
	cid
FROM erp_loc_a101
WHERE cid LIKE '%-%';

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	cid,
    cntry
FROM erp_loc_a101
WHERE cid != TRIM(cid)
OR cntry != TRIM(cntry); 

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT 
DISTINCT cntry
FROM erp_loc_a101;


-- CREATE TEMPPORARY TABLE AND INSERT CLEANED DATA INTO IT
CREATE TEMPORARY TABLE cleaned_erp_loc_data(
    -- MAIN QUERY AFTER CLEANING PRODUCT DATA
	SELECT
        CASE
			WHEN TRIM(cid) LIKE '%-%' THEN REPLACE(cid, '-', '')
            ELSE TRIM(cid)
		END AS cid,
        CASE
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
		END AS cntry
	FROM erp_loc_a101
);

-- TRUNCATE THE MAIN PRODUCT INFO DATA
TRUNCATE TABLE erp_loc_a101;

-- NOW INSERT THE TEMPORARY CLEANED DATA INTO MAIN ERP LOCATION TABLE
INSERT INTO erp_loc_a101
SELECT * FROM cleaned_erp_loc_data;

-- NOW DROP TEMPORARY TABLE
DROP TABLE IF EXISTS cleaned_erp_loc_data;

											/****************** END ********************/


/****************************************** DATA CLEANING FOR erp_px_cat_g1v2 TABLE ********************************************/

											/****************** START ********************/

-- CHECK FOR UNWANTED SPACE FOR STRING VALUES
SELECT 
	id,
    COUNT(*) AS DuplicatesValues
FROM erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

-- CHECK FOR NULL VALUES IN COLUMNS
SELECT 
*
FROM erp_px_cat_g1v2 
WHERE id IS NULL
OR cat IS NULL
OR subcat IS NULL
OR maintenance IS NULL;

-- CHECK UNWANTED WHITESPACES IN STRING COLUMNS
SELECT
	cat,
	subcat,
	maintenance
FROM erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);


-- DATE IS ALREADY IN CLEANED FORMAT SO NO NEED TO CREATE TEMPORARY TABLE AND INSERT OPERATIONS

										/****************** END ********************/