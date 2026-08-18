/*-- bronze_sales
CREATE TABLE bronze_sales (
	STORE VARCHAR(20),
	SALE_DATE TIMESTAMP,
	WEEKNUMBER INT,
	DIVISION VARCHAR(100),
	DEPARTMENT VARCHAR(50),
	SUB_DEPT VARCHAR(100),
	FAMILY VARCHAR(100),
	SUB_FAMILY VARCHAR(100),
	ARTICLE_CODE VARCHAR(8),
	DESCRIPTION VARCHAR(500),
	QUANTITY FLOAT,
	TURNOVER FLOAT,
	VAT FLOAT,
	COST_VALUE FLOAT,
	MARGIN_VALUE FLOAT,
	SOURCE_FILE VARCHAR(50)
)
SELECT * FROM bronze_sales LIMIT 5

-- silver_sales -------------------------------------------------------------------------------
CREATE TABLE silver_sales ( 
	store VARCHAR(20)
	sale_date TIMESTAMP
	weeknumber INT,
	article_code VARCHAR(8),
	quantity FLOAT,
	turnover FLOAT,
	vat FLOAT,
	cost_value FLOAT,
	margin_value FLOAT
)

-- dim_items -------------------------------------------------------------------------------
CREATE TABLE dim_items AS (
SELECT division, department, sub_dept, "family", sub_family, article_code, description
FROM (
	SELECT division, department, sub_dept, "family", sub_family, article_code, description,
		ROW_NUMBER() OVER (PARTITION BY article_code ORDER BY COUNT(*) DESC) as rn
	FROM bronze_sales
	GROUP BY division, department, sub_dept, "family", sub_family, article_code, description
) as rn_table
WHERE rn = 1
)

-- bronze_region
CREATE TABLE bronze_region (
	STORE VARCHAR(20),
	STORE_CODE VARCHAR(3),
	STORE_NAME VARCHAR(50),
	BU_FORMAT VARCHAR(10),
	REGION_7 VARCHAR(20),
	REGION_5 VARCHAR(20),
	REGION_3 VARCHAR(20)
)

-- bronze_weekend
CREATE TABLE bronze_weekend (
	campaign VARCHAR(20),
	goldcode VARCHAR(8),
	region VARCHAR(20),
	"begin" TIMESTAMP,
	"end" TIMESTAMP
)

-- bronze_catalog
CREATE TABLE bronze_catalog (
	campaign VARCHAR(20),
	goldcode VARCHAR(8),
	region VARCHAR(20),
	"begin" TIMESTAMP,
	"end" TIMESTAMP,
	last_year VARCHAR(20)
)

-- bronze_fair
CREATE TABLE bronze_fair (
	campaign VARCHAR(200),
	goldcode VARCHAR(8),
	region VARCHAR(20),
	"level" VARCHAR(20),
	"begin" TIMESTAMP,
	"end" TIMESTAMP
)

-- bronze_others
CREATE TABLE bronze_others (
	campaign VARCHAR(200),
	goldcode VARCHAR(8),
	region VARCHAR(20),
	"level" VARCHAR(20),
	"begin" TIMESTAMP,
	"end" TIMESTAMP
)

-- silver_weekend
CREATE TABLE silver_weekend AS (
	select r.*, w.campaign, w.goldcode, w.begin, w.end
	from bronze_weekend w
	left join bronze_region r
	on w.region = r.region_3
)

-- gold_weekend
CREATE TABLE gold_weekend AS (
	select campaign,
		goldcode,
		wk.store,
		wk.region_3,
		wk.region_5,
		wk.region_7,
		s.sale_date,
		s.quantity,
		s.turnover,
		s.vat,
		s.margin_value
	from silver_sales s
	right join silver_weekend wk
	on s.article_code = wk.goldcode
		and s.store = wk.store
		and s.sale_date between wk.begin and wk.end
	where campaign is not null
)

-- silver_catalog
CREATE TABLE silver_catalog AS (
	select r.*, c.campaign, c.goldcode, c.begin, c.end, c.last_year
	from bronze_catalog c
	left join bronze_region r
	on c.region = r.region_5
)

-- gold_catalog ----------------------------------------------------------------------
CREATE TABLE gold_catalog AS (
	select campaign,
		goldcode,
		ct.store,
		ct.region_3,
		ct.region_5,
		ct.region_7,
		s.sale_date,
		s.quantity,
		s.turnover,
		s.vat,
		s.margin_value,
		ct.last_year
	from silver_catalog ct
	left join silver_sales s
	on s.article_code = ct.goldcode
		and s.store = ct.store
		and s.sale_date between ct.begin and ct.end
	where campaign is not null
)

-- silver_fair
CREATE TABLE silver_fair AS (
	-- Store
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_fair f
	left join bronze_region r
	on f.region = r.store_code
	where f.level ='Store'
	union all
	-- Region 3
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_fair f
	left join bronze_region r
	on f.region = r.region_3
	where f.level ='Region 3'
	union all
	-- Region 5
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_fair f
	left join bronze_region r
	on f.region = r.region_5
	where f.level ='Region 5'
	union all
	-- Region 7
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_fair f
	left join bronze_region r
	on f.region = r.region_7
	where f.level ='Region 7'
)

-- gold_fair ------------------------------------------------------------------------------------
CREATE TABLE gold_fair AS (
	select campaign,
		goldcode,
		fa.store,
		fa.region_3,
		fa.region_5,
		fa.region_7,
		s.sale_date,
		s.quantity,
		s.turnover,
		s.vat,
		s.margin_value
	from silver_fair fa
	left join silver_sales s
	on s.article_code = fa.goldcode
		and s.store = fa.store
		and s.sale_date between fa.begin and fa.end
	where campaign is not null
)

-- silver_others
CREATE TABLE silver_others AS (
	-- Store
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_others f
	left join bronze_region r
	on f.region = r.store_code
	where f.level ='Store'
	union all
	-- Region 3
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_others f
	left join bronze_region r
	on f.region = r.region_3
	where f.level ='Region 3'
	union all
	-- Region 5
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_others f
	left join bronze_region r
	on f.region = r.region_5
	where f.level ='Region 5'
	union all
	-- Region 7
	select r.*, f.campaign, f.goldcode, f.begin, f.end
	from bronze_others f
	left join bronze_region r
	on f.region = r.region_7
	where f.level ='Region 7'
)

-- gold_others ------------------------------------------------------------------------------------
CREATE TABLE gold_others AS (
	select campaign,
		goldcode,
		o.store,
		o.region_3,
		o.region_5,
		o.region_7,
		s.sale_date,
		s.quantity,
		s.turnover,
		s.vat,
		s.margin_value
	from silver_others o
	left join silver_sales s
	on s.article_code = o.goldcode
		and s.store = o.store
		and s.sale_date between o.begin and o.end
	where campaign is not null
)

-- temp_silver_sales ---------------------------------------------------------------
CREATE TABLE temp_silver_sales (
    store VARCHAR(20),
    sale_date TIMESTAMP,
    weeknumber INT,
    article_code VARCHAR(8),
    quantity FLOAT,
    turnover FLOAT,
    vat FLOAT,
    cost_value FLOAT,
    margin_value FLOAT
);
*/
-- silver_weekend ------------------------------------------------------
ALTER TABLE silver_weekend
ADD CONSTRAINT uq_silver_weekend
UNIQUE (store, campaign, goldcode, "begin", "end")

INSERT INTO silver_weekend (
	store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
)
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_weekend w
LEFT JOIN bronze_region r
	ON w.region = r.region_3
ON CONFLICT (store, campaign, goldcode, "begin", "end")
DO NOTHING

-- silver_catalog ------------------------------------------------------
ALTER TABLE silver_catalog
ADD CONSTRAINT uq_silver_catalog
UNIQUE (store, campaign, goldcode, "begin", "end")

INSERT INTO silver_catalog (
	store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end", last_year
)
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end", last_year
FROM bronze_catalog c
LEFT JOIN bronze_region r
	ON c.region = r.region_5
ON CONFLICT (store, campaign, goldcode, "begin", "end")
DO NOTHING

-- silver_fair ------------------------------------------------------
ALTER TABLE silver_fair
ADD CONSTRAINT uq_silver_fair
UNIQUE (store, campaign, goldcode, "begin", "end")

INSERT INTO silver_fair (
	store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
)
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_fair f
LEFT JOIN bronze_region r
	ON f.region = r.store_code
WHERE f.level = 'Store'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_fair f
LEFT JOIN bronze_region r
	ON f.region = r.region_3
WHERE f.level = 'Region 3'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_fair f
LEFT JOIN bronze_region r
	ON f.region = r.region_5
WHERE f.level = 'Region 5'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_fair f
LEFT JOIN bronze_region r
	ON f.region = r.region_7
WHERE f.level = 'Region 7'
ON CONFLICT (store, campaign, goldcode, "begin", "end")
DO NOTHING

-- silver_others ------------------------------------------------------
ALTER TABLE silver_others
ADD CONSTRAINT uq_silver_others
UNIQUE (store, campaign, goldcode, "begin", "end")

INSERT INTO silver_others (
	store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
)
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_others o
LEFT JOIN bronze_region r
	ON o.region = r.store_code
WHERE o.level = 'Store'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_others o
LEFT JOIN bronze_region r
	ON o.region = r.region_3
WHERE o.level = 'Region 3'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_others o
LEFT JOIN bronze_region r
	ON o.region = r.region_5
WHERE o.level = 'Region 5'
UNION ALL
SELECT store, store_code, store_name, bu_format, region_7, region_5, region_3, campaign, goldcode, "begin", "end"
FROM bronze_others o
LEFT JOIN bronze_region r
	ON o.region = r.region_7
WHERE o.level = 'Region 7'
ON CONFLICT (store, campaign, goldcode, "begin", "end")
DO NOTHING

-- dim_items ----------------------------------------------------------------
ALTER TABLE dim_items
ADD CONSTRAINT uq_dim_items
UNIQUE (article_code)

INSERT INTO dim_items (
	division, department, sub_dept, "family", sub_family, article_code, description
)
SELECT division, department, sub_dept, "family", sub_family, article_code, description
FROM (
	SELECT division, department, sub_dept, "family", sub_family, article_code, description,
		ROW_NUMBER() OVER (PARTITION BY article_code ORDER BY COUNT(*) DESC) as rn
	FROM bronze_sales
	GROUP BY division, department, sub_dept, "family", sub_family, article_code, description
) as rn_table
WHERE rn = 1
ON CONFLICT (article_code)
DO NOTHING

-- gold_weekend ------------------------------------------------------
ALTER TABLE gold_weekend
ADD CONSTRAINT uq_gold_weekend
UNIQUE (campaign, goldcode, store, sale_date)

INSERT INTO gold_weekend (
	campaign, goldcode, store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value, LY_begin, LY_end
)
SELECT campaign, goldcode, wk.store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value
	wk."begin" - INTERVAL '364 days' AS "LY_begin",
    wk."end" - INTERVAL '364 days' AS "LY_end"
FROM silver_weekend wk
LEFT JOIN silver_sales s
ON s.article_code = wk.goldcode
	AND s.store = wk.store
	AND s.sale_date BETWEEN wk.begin AND wk.end
	WHERE campaign IS NOT NULL
ON CONFLICT (campaign, goldcode, store, sale_date)
DO NOTHING

-- gold_catalog -----------------------------------------------------------------
ALTER TABLE gold_catalog
ADD CONSTRAINT uq_gold_catalog
UNIQUE (campaign, goldcode, store, sale_date)

INSERT INTO gold_catalog (
	campaign, goldcode, store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value, last_year
)
SELECT campaign, goldcode, ct.store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value, last_year
FROM silver_catalog ct
LEFT JOIN silver_sales s
	ON s.article_code = ct.goldcode
	AND s.store = ct.store
	AND s.sale_date BETWEEN ct.begin AND ct.end
WHERE campaign IS NOT NULL
ON CONFLICT (campaign, goldcode, store, sale_date)
DO NOTHING

-- gold_fair -----------------------------------------------------------------
ALTER TABLE gold_fair
ADD CONSTRAINT uq_gold_fair
UNIQUE (campaign, goldcode, store, sale_date)

INSERT INTO gold_fair (
	campaign, goldcode, store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value, "LY_begin", "LY_end"
)
SELECT campaign, goldcode, fa.store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value,
	fa."begin" - INTERVAL '364 days' AS "LY_begin",
    fa."end" - INTERVAL '364 days' AS "LY_end"
FROM silver_fair fa
LEFT JOIN silver_sales s
ON s.article_code = fa.goldcode
	AND s.store = fa.store
	AND s.sale_date BETWEEN fa.begin AND fa.end
WHERE campaign IS NOT NULL
ON CONFLICT (campaign, goldcode, store, sale_date)
DO NOTHING

-- gold_others -----------------------------------------------------------------
ALTER TABLE gold_others
ADD CONSTRAINT uq_gold_others
UNIQUE (campaign, goldcode, store, sale_date)

INSERT INTO gold_others (
	campaign, goldcode, store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value
)
SELECT campaign, goldcode, o.store, region_3, region_5, region_7, sale_date, quantity, turnover, vat, margin_value
FROM silver_others o
LEFT JOIN silver_sales s
ON s.article_code = o.goldcode
	AND s.store = o.store
	AND s.sale_date BETWEEN o.begin AND o.end
WHERE campaign IS NOT NULL
ON CONFLICT (campaign, goldcode, store, sale_date)
DO NOTHING

-- END ---------------------------------------------------------------------------------------------------
