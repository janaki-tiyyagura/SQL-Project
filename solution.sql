-- 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

SELECT DISTINCT market FROM dim_customer
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

+-------------+
| market      |
+-------------+
| India       |
| Indonesia   |
| Japan       |
| Philiphines |
| South Korea |
| Australia   |
| Newzealand  |
| Bangladesh  |
+-------------+


-- 2. What is the percentage of unique product increase in 2021 vs. 2020?

WITH unique_product_count_in_2020 AS
(
SELECT COUNT(DISTINCT dim_product.product_code) AS unique_product_count_2020 FROM dim_product
JOIN fact_sales_monthly
ON dim_product.product_code = fact_sales_monthly.product_code
WHERE fiscal_year=2020
),
unique_product_count_in_2021 AS
(
SELECT  COUNT(DISTINCT dim_product.product_code) AS unique_product_count_2021 FROM dim_product
JOIN fact_sales_monthly
ON dim_product.product_code = fact_sales_monthly.product_code
WHERE fiscal_year=2021
)
SELECT  unique_product_count_2020 ,  unique_product_count_2021 ,
ROUND((unique_product_count_2021 - unique_product_count_2020) /(unique_product_count_2020) * 100 ,2) AS percentage_of_difference
FROM unique_product_count_in_2020
JOIN unique_product_count_in_2021;

+---------------------------+---------------------------+--------------------------+
| unique_product_count_2020 | unique_product_count_2021 | percentage_of_difference |
+---------------------------+---------------------------+--------------------------+
|                       245 |                       334 |                    36.33 |
+---------------------------+---------------------------+--------------------------+

-- 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.

SELECT segment, COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

+-------------+---------------+
| segment     | product_count |
+-------------+---------------+
| Notebook    |           129 |
| Accessories |           116 |
| Peripherals |            84 |
| Desktop     |            32 |
| Storage     |            27 |
| Networking  |             9 |
+-------------+---------------+

-- 4. Which segment had the most increase in unique products in 2021 vs 2020?

WITH product_count_in_2020 AS
(
SELECT segment, COUNT(DISTINCT dim_product.product_code) AS product_count_2020 FROM dim_product
JOIN fact_sales_monthly
ON dim_product.product_code = fact_sales_monthly.product_code
WHERE fiscal_year=2020
GROUP BY segment
),
product_count_in_2021 AS
(
SELECT segment, COUNT(DISTINCT dim_product.product_code) AS product_count_2021 FROM dim_product
JOIN fact_sales_monthly
ON dim_product.product_code = fact_sales_monthly.product_code
WHERE fiscal_year=2021
GROUP BY segment
)
SELECT product_count_in_2020.segment, product_count_2020 ,  product_count_2021 ,
product_count_2021 - product_count_2020 AS difference
FROM product_count_in_2020
JOIN product_count_in_2021
ON product_count_in_2020.segment = product_count_in_2021.segment
ORDER BY difference DESC;


+-------------+--------------------+--------------------+------------+
| segment     | product_count_2020 | product_count_2021 | difference |
+-------------+--------------------+--------------------+------------+
| Accessories |                 69 |                103 |         34 |
| Notebook    |                 92 |                108 |         16 |
| Peripherals |                 59 |                 75 |         16 |
| Desktop     |                  7 |                 22 |         15 |
| Storage     |                 12 |                 17 |          5 |
| Networking  |                  6 |                  9 |          3 |
+-------------+--------------------+--------------------+------------+

-- 5. Get the products that have the highest and lowest manufacturing costs.

SELECT dim_product.product_code, product, manufacturing_cost
FROM dim_product 
JOIN fact_manufacturing_cost 
ON dim_product.product_code = fact_manufacturing_cost.product_code
WHERE manufacturing_cost = (SELECT min(manufacturing_cost) FROM fact_manufacturing_cost) OR 
manufacturing_cost = (SELECT max(manufacturing_cost) FROM fact_manufacturing_cost);

+--------------+-----------------------+--------------------+
| product_code | product               | manufacturing_cost |
+--------------+-----------------------+--------------------+
| A2118150101  | AQ Master wired x1 Ms |             0.8920 |
| A6120110206  | AQ HOME Allin1 Gen 2  |           240.5364 |
+--------------+-----------------------+--------------------+

--6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.

SELECT dim_customer.customer_code, customer, ROUND(AVG(pre_invoice_discount_pct)*100,2) AS average_discount_percentage FROM dim_customer
JOIN fact_pre_invoice_deductions
ON dim_customer.customer_code = fact_pre_invoice_deductions.customer_code
WHERE market = 'India' AND fiscal_year=2021
GROUP BY customer_code, customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

+---------------+----------+-----------------------------+
| customer_code | customer | average_discount_percentage |
+---------------+----------+-----------------------------+
|      90002009 | Flipkart |                       30.83 |
|      90002006 | Viveks   |                       30.38 |
|      90002003 | Ezone    |                       30.28 |
|      90002002 | Croma    |                       30.25 |
|      90002016 | Amazon   |                       29.33 |
+---------------+----------+-----------------------------+

--7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month . This analysis helps to get an idea of low and high-performing months and take strategic decisions.

SELECT 
MONTHNAME(date) as Month, 
YEAR(date) as Year, 
SUM(gross_price*sold_quantity) AS Gross_sales_Amount
FROM fact_sales_monthly
JOIN fact_gross_price 
ON fact_sales_monthly.product_code = fact_gross_price.product_code
JOIN dim_customer
ON dim_customer.customer_code = fact_sales_monthly.customer_code
WHERE customer = 'Atliq Exclusive'
GROUP BY Month, Year
ORDER BY Year;

+-----------+------+--------------------+
| Month     | Year | Gross_sales_Amount |
+-----------+------+--------------------+
| September | 2019 |       9092670.3392 |
| October   | 2019 |      10378637.5961 |
| November  | 2019 |      15231894.9669 |
| December  | 2019 |       9755795.0577 |
| January   | 2020 |       9584951.9393 |
| February  | 2020 |       8083995.5479 |
| March     | 2020 |        766976.4531 |
| April     | 2020 |        800071.9543 |
| May       | 2020 |       1586964.4768 |
| June      | 2020 |       3429736.5712 |
| July      | 2020 |       5151815.4020 |
| August    | 2020 |       5638281.8287 |
| September | 2020 |      19530271.3028 |
| October   | 2020 |      21016218.2095 |
| November  | 2020 |      32247289.7946 |
| December  | 2020 |      20409063.1769 |
| January   | 2021 |      19570701.7102 |
| February  | 2021 |      15986603.8883 |
| March     | 2021 |      19149624.9239 |
| April     | 2021 |      11483530.3032 |
| May       | 2021 |      19204309.4095 |
| June      | 2021 |      15457579.6626 |
| July      | 2021 |      19044968.8164 |
| August    | 2021 |      11324548.3409 |
+-----------+------+--------------------+

--8. In which quarter of 2020, got the maximum total_sold_quantity?

SELECT 
CASE WHEN MONTH(date) IN(9,10,11) THEN 'Q1'
	 WHEN MONTH(date) IN(12,1,2) THEN 'Q2'
     WHEN MONTH(date) IN(3,4,5) THEN 'Q3'
     WHEN MONTH(date) IN(6,7,8) THEN 'Q4'
END AS quarter,
SUM(sold_quantity) AS total_sold_quantity FROM fact_sales_monthly
WHERE fiscal_year= 2020
GROUP BY quarter
ORDER BY total_sold_quantity DESC;

+---------+---------------------+
| quarter | total_sold_quantity |
+---------+---------------------+
| Q1      |             7005619 |
| Q2      |             6649642 |
| Q4      |             5042541 |
| Q3      |             2075087 |
+---------+---------------------+

--9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?

WITH CTE AS
(
SELECT channel,SUM(gross_price*sold_quantity) AS gross_sales FROM fact_sales_monthly
JOIN fact_gross_price
ON fact_sales_monthly.product_code = fact_gross_price.product_code
JOIN dim_customer
ON fact_sales_monthly.customer_code = dim_customer.customer_code
WHERE fact_sales_monthly.fiscal_year = 2021 
GROUP BY channel
ORDER BY gross_sales DESC
)
SELECT channel, 
ROUND(gross_sales/1000000,2) AS gross_sales_mln, 
ROUND(gross_sales/(SELECT SUM(gross_sales) FROM CTE)*100,2) AS percentage_of_contribution 
FROM CTE;

+-------------+-----------------+----------------------------+
| channel     | gross_sales_mln | percentage_of_contribution |
+-------------+-----------------+----------------------------+
| Retailer    |         1924.17 |                      73.22 |
| Direct      |          406.69 |                      15.47 |
| Distributor |          297.18 |                      11.31 |
+-------------+-----------------+----------------------------+

-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?

WITH CTE AS 
(
SELECT division, dim_product.product_code, product, SUM(sold_quantity) AS total_sold_quantity,
RANK() OVER(PARTITION BY division ORDER BY SUM(sold_quantity)  DESC)  AS rank_order FROM dim_product
JOIN fact_sales_monthly
ON dim_product.product_code = fact_sales_monthly.product_code
WHERE fiscal_year = 2021
GROUP BY division, dim_product.product_code,product
)
SELECT * FROM CTE 
WHERE rank_order <=3;

+----------+--------------+---------------------+---------------------+------------+
| division | product_code | product             | total_sold_quantity | rank_order |
+----------+--------------+---------------------+---------------------+------------+
| N & S    | A6720160103  | AQ Pen Drive 2 IN 1 |              701373 |          1 |
| N & S    | A6818160202  | AQ Pen Drive DRC    |              688003 |          2 |
| N & S    | A6819160203  | AQ Pen Drive DRC    |              676245 |          3 |
| P & A    | A2319150302  | AQ Gamers Ms        |              428498 |          1 |
| P & A    | A2520150501  | AQ Maxima Ms        |              419865 |          2 |
| P & A    | A2520150504  | AQ Maxima Ms        |              419471 |          3 |
| PC       | A4218110202  | AQ Digit            |               17434 |          1 |
| PC       | A4319110306  | AQ Velocity         |               17280 |          2 |
| PC       | A4218110208  | AQ Digit            |               17275 |          3 |
+----------+--------------+---------------------+---------------------+------------+
