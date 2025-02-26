/* Retrieve a report containing the following information: customer_id, order_id, product_id, product_group, sub_category, category. These orders must meet the following conditions:
- Incurred in January 2017
- product_group is not 'payment' */

SELECT customer_id, order_id, product_id, product_group, sub_category, category
FROM payment_history_17 AS his
LEFT JOIN product AS pro
    ON his.product_id = pro.product_number
WHERE MONTH(transaction_date) = 1 AND product_group != 'payment' 

-----------------------------------------------------------------------------------------------------------------------------
/* Retrieve a report that includes the following information: customer_id, order_id, product_id, product_group, category, payment name. These orders must meet the following conditions:
- Occurred between January and June 2017
- Have a category type of shopping
- Paid via Bank Account */

SELECT customer_id, order_id, product_id, product_group, category, [name]
FROM payment_history_17 AS his
LEFT JOIN product AS pro
    ON his.product_id = pro.product_number
LEFT JOIN paying_method AS met 
    ON his.payment_id = met.method_id
WHERE MONTH(transaction_date) < 7 
    AND category = 'Shopping'
    AND [name] = 'banking account'

-----------------------------------------------------------------------------------------------------------------------------
/* In 2017, what is the number of orders and the proportion of each product category in each product_group? (Only count successful orders) */

WITH table_group AS (
    SELECT product_group, category,
        COUNT(distinct order_id) AS number_orders
    FROM payment_history_17 AS his
    LEFT JOIN product AS pro
        ON his.product_id = pro.product_number
    LEFT JOIN table_message AS mess 
        ON his.message_id = mess.message_id
    WHERE [description] = 'success'
    GROUP BY product_group, category
)
SELECT *,
    SUM (number_orders) OVER (PARTITION BY product_group) AS total_orders,
    FORMAT(CAST(number_orders AS FLOAT)/SUM(number_orders) OVER (PARTITION BY product_group),'p') AS ratio
FROM table_group

-----------------------------------------------------------------------------------------------------------------------------
/* Please indicate in 2017, how many orders did each customer buy, how many product categories, how many sub_categories, and how much did they pay? (Only count successful orders with product_group "payment")
From the above results, please indicate how many customers have a total amount greater than the average amount of all customers? */

WITH table_count AS ( 
    SELECT customer_id,
        COUNT(distinct order_id) AS number_orders,
        COUNT(distinct category) AS number_categories,
        COUNT(distinct sub_category) AS number_sub_categories,
        SUM(CAST(final_price AS BIGINT)) AS total_payment
    FROM payment_history_17 AS his
    LEFT JOIN product AS pro
        ON his.product_id = pro.product_number
    LEFT JOIN table_message AS mess 
        ON his.message_id = mess.message_id
    WHERE [description] = 'success' AND product_group = 'payment'
    GROUP BY customer_id
)
, table_avg AS (
    SELECT *,
    AVG(total_payment) OVER () as avg_payment
    FROM table_count
)
SELECT COUNT(customer_id)
FROM table_avg
WHERE total_payment > avg_payment

-----------------------------------------------------------------------------------------------------------------------------
/* Assuming you are a product manager for billing products (category = 'Billing'), how many orders were successfully completed and how many orders were unsuccessful each month in 2017? */

WITH table_join AS (
    SELECT order_id, transaction_date,
        CASE WHEN [description] != 'success' THEN 'failure' ELSE 'success' END AS [status]
    FROM payment_history_17 AS his
    LEFT JOIN product AS pro
        ON his.product_id = pro.product_number
    LEFT JOIN table_message AS mess 
        ON his.message_id = mess.message_id
    WHERE category = 'Billing'
)
    SELECT MONTH(transaction_date) AS [month], [status],
        COUNT(order_id) AS number_orders
    FROM table_join
    GROUP BY MONTH(transaction_date), [status]
ORDER BY [month], [status]

-----------------------------------------------------------------------------------------------------------------------------
/* In 2017 and 2018, find out the TOP 3 months (in each year) with the most unsuccessful payment orders? */

WITH table_group AS (
    SELECT YEAR(transaction_date) AS [year], MONTH(transaction_date) AS [month],
        COUNT(order_id) AS number_orders
    FROM (SELECT * FROM payment_history_17 UNION SELECT * FROM payment_history_18) AS his
    LEFT JOIN table_message AS mess
        ON his.message_id = mess.message_id
    WHERE [description] != 'success'
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
, table_rank AS (
    SELECT *,
        RANK() OVER (PARTITION BY [year] ORDER BY number_orders DESC) AS rank 
    FROM table_group
)
SELECT * 
FROM table_rank
WHERE rank <= 3

-----------------------------------------------------------------------------------------------------------------------------
/* To be able to track the business situation on a daily basis, create a detailed report calculating the total number of orders (successful) by month, quarter, year as suggested below:
(Only calculate data for 2017 and product group (product_group) is "top-up account") */ 

WITH table_group AS (
    SELECT [quarter], MONTH(transaction_date) AS [month],
        COUNT(order_id) AS number_orders_month
    FROM (
        SELECT transaction_date, order_id, 
            DATEPART(quarter, transaction_date) AS [quarter]
        FROM payment_history_17 AS his
        LEFT JOIN product AS pro
            ON his.product_id = pro.product_number
        LEFT JOIN table_message AS mess
            ON his.message_id = mess.message_id
        WHERE product_group = 'top-up account' AND [description] = 'success'
    ) AS table_join
    GROUP BY [quarter], MONTH(transaction_date)
)
SELECT *,
    SUM(number_orders_month) OVER (PARTITION BY [quarter]) as number_orders_quarter,
    SUM(number_orders_month) OVER () as number_orders_year
FROM table_group

-----------------------------------------------------------------------------------------------------------------------------
/* How many days is the gap between the first and second orders for each customer? (Only 2017 data and "top-up account" product_group are calculated) */

WITH table_row AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS rank
    FROM (
        SELECT customer_id, order_id, transaction_date  
        FROM payment_history_17 AS his
        LEFT JOIN product AS pro
            ON his.product_id = pro.product_number
        LEFT JOIN table_message AS mess
            ON his.message_id = mess.message_id
        WHERE product_group = 'top-up account' AND [description] = 'success'
    ) AS table_join
)
SELECT customer_id, transaction_date,
    LAG(transaction_date, 1) OVER (PARTITION BY customer_id ORDER BY rank) AS first_time, 
    DATEDIFF(day, LAG(transaction_date, 1) OVER (PARTITION BY customer_id ORDER BY rank), transaction_date) AS distance
FROM table_row
WHERE rank < 3

-----------------------------------------------------------------------------------------------------------------------------
/* Tell me the trend of the number of successful payment transactions with promotion (promotion_trans) on a monthly basis and account for how much of the total number of successful payment transactions (promotion_rate)? */

SELECT MONTH(transaction_date) AS [month],
    COUNT(order_id) AS number_trans,
    COUNT(CASE WHEN promotion_id != '0' THEN order_id END) AS promotion_trans,
    FORMAT(COUNT(CASE WHEN promotion_id != '0' THEN order_id END)/CAST(COUNT(order_id) AS FLOAT), 'p') AS promotion_rate
FROM payment_history_17 AS his
LEFT JOIN table_message AS mess
    ON his.message_id = mess.message_id
WHERE [description] = 'success'
GROUP BY MONTH(transaction_date) 

--------------------------------------------------------------------------------------------------------------------------------
/* Out of the total number of successful paying customer enjoy the promotion, how many % of customer have incurred any other successful payment orders that are not promotional orders? */

WITH table_lag AS (
    SELECT *,
        LAG([status], 1) OVER (PARTITION BY customer_id ORDER BY rank) AS previous_status
    FROM (
        SELECT customer_id, promotion_id, transaction_date,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS rank,
            CASE WHEN promotion_id = '0' THEN 'normal' ELSE 'promotion' END AS [status]
        FROM payment_history_17 AS his
        LEFT JOIN table_message AS mess
            ON his.message_id = mess.message_id
        WHERE [description] = 'success'
    ) AS table_row
)
SELECT 
    COUNT(distinct CASE WHEN [status] = 'promotion' THEN customer_id END) AS total_cus_promotion,
    COUNT(distinct CASE WHEN [status] = 'normal' AND previous_status = 'promotion' THEN customer_id END) AS convert_cus,
    COUNT(distinct CASE WHEN [status] = 'normal' AND previous_status = 'promotion' THEN customer_id END)/CAST(COUNT(distinct CASE WHEN [status] = 'promotion' THEN customer_id END) AS FLOAT) AS convert_rate
FROM table_lag

-----------------------------------------------------------------------------------------------------------------------------
/* COHORT ANALYSIS 
As you know that 'Electric bill' is the most popular product in the Billing group. You want to evaluate the quality of user acquisition in 2017 by the retention metric. */

DECLARE @query NVARCHAR(MAX), @column_list NVARCHAR (MAX)
SELECT @column_list =  STRING_AGG('[' + CAST(month_n AS VARCHAR) + ']', ', ') WITHIN GROUP (ORDER BY month_n ASC)
FROM (
    SELECT
        distinct MONTH(transaction_date) - MIN(MONTH(transaction_date)) OVER (PARTITION BY customer_id) AS month_n
    FROM (
        SELECT customer_id, order_id, transaction_date
        FROM payment_history_17 AS his
        LEFT JOIN product AS pro
            ON his.product_id = pro.product_number
        LEFT JOIN table_message AS mess
            ON his.message_id = mess.message_id
        WHERE sub_category = 'Electricity' AND [description] = 'success'
    ) AS table_join
) AS tmp_table
SET @query = 
    'WITH table_month AS (    
        SELECT *,
            MIN(MONTH(transaction_date)) OVER (PARTITION BY customer_id) AS first_month,
            MONTH(transaction_date) - MIN(MONTH(transaction_date)) OVER (PARTITION BY customer_id) AS month_n
        FROM (
            SELECT customer_id, order_id, transaction_date
            FROM payment_history_17 AS his
            LEFT JOIN product AS pro
                ON his.product_id = pro.product_number
            LEFT JOIN table_message AS mess
                ON his.message_id = mess.message_id
            WHERE sub_category = ''Electricity'' AND [description] = ''success''
        ) AS table_join
    )
    , table_source AS (
        SELECT first_month, month_n,
            COUNT(distinct customer_id) AS number_customers,
            MAX(COUNT(distinct customer_id)) OVER (PARTITION BY first_month) AS original_customers
        FROM table_month
        GROUP BY first_month, month_n
    )
    SELECT first_month, original_customers,
        '+ @column_list +'
    FROM table_source
    PIVOT (
        SUM(number_customers) 
        FOR month_n IN ('+ @column_list +')
    ) AS pivot_table
    ORDER BY first_month ASC'
EXEC (@query)

-----------------------------------------------------------------------------------------------------------------------------
/* In 2017, the MKT team launched many promotional campaigns for customers but did not limit the number of uses/person. You need to evaluate how the number of promotions/person is distributed? Is there a phenomenon of 1 group participating too many times and creating a lot of costs? */

WITH table_group AS (
    SELECT customer_id, 
        COUNT(order_id) AS number_orders,
        SUM(discount_price) AS cost 
    FROM (
        SELECT customer_id, order_id, promotion_id, discount_price
        FROM payment_history_17 AS his 
        LEFT JOIN table_message AS mess
            ON his.message_id = mess.message_id
        WHERE [description] = 'success' AND promotion_id != '0'
    ) AS table_join
    GROUP BY customer_id
)
, table_pct AS (
    SELECT *,
        ROUND(PERCENT_RANK() OVER (ORDER BY number_orders DESC)*100, 0) AS top_rank
    FROM table_group
)
, table_count AS (
    SELECT top_rank,
        MIN(number_orders) AS min_orders,
        COUNT(distinct customer_id) AS number_customers,
        SUM(cost) AS total_cost
    FROM table_pct
    GROUP BY top_rank
)
    SELECT CONCAT('TOP ', top_rank, '%') AS [top_n_%],
        min_orders, total_cost,
        CAST(total_cost AS FLOAT)/number_customers AS cost_per_customer,
        SUM(number_customers) OVER (ORDER BY top_rank) AS accumulate_customers,
        SUM(total_cost) OVER (ORDER BY top_rank) AS accumulate_cost,
        CAST(SUM(total_cost) OVER (ORDER BY top_rank) AS FLOAT)/SUM(number_customers) OVER (ORDER BY top_rank) AS accumulate_cost_per_customer
    FROM table_count