TRUNCATE TABLE crm_cust_info;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_crm\\cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
SET
cst_id = NULLIF(cst_id, ''),
cst_key = NULLIF(cst_key, ''),
cst_firstname = NULLIF(cst_firstname, ''),
cst_lastname = NULLIF(cst_lastname, ''),
cst_marital_status = NULLIF(cst_marital_status, ''),
cst_gndr = NULLIF(cst_gndr, ''),
cst_create_date = NULLIF(cst_create_date, '');

TRUNCATE TABLE crm_prd_info;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_crm\\prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(prd_id, prd_key, prd_nm, @prd_cost, @prd_line, prd_start_dt, @prd_end_dt)
SET 
	prd_cost = NULLIF(@prd_cost,''),
    prd_line = NULLIF(@prd_line,''),
    prd_end_dt = NULLIF(@prd_end_dt,'');

TRUNCATE TABLE crm_sales_details;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_crm\\sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, @sls_sales, sls_quantity, @sls_price)
SET
	sls_sales = NULLIF(@sls_sales, ''),
	sls_price = NULLIF(@sls_price, '')
;

TRUNCATE TABLE erp_cust_az12;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_erp\\CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cid, bdate, @gen)
SET
	gen = NULLIF(@gen, '');


TRUNCATE TABLE erp_loc_a101;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_erp\\LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cid, @cntry)
SET
	cntry = NULLIF(@cntry, '');

TRUNCATE TABLE erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'C:\\Users\\welcome\\Desktop\\SQL_DATA_ANALYTICS_PROJECT\\sql-data-warehouse-project\\datasets\\source_erp\\PX_CAT_G1V2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
