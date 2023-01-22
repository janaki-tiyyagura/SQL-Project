SELECT DISTINCT market FROM dim_customer
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

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

SELECT segment, COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

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

SELECT dim_product.product_code, product, manufacturing_cost
FROM dim_product 
JOIN fact_manufacturing_cost 
ON dim_product.product_code = fact_manufacturing_cost.product_code
WHERE manufacturing_cost = (SELECT min(manufacturing_cost) FROM fact_manufacturing_cost) OR 
manufacturing_cost = (SELECT max(manufacturing_cost) FROM fact_manufacturing_cost);


SELECT dim_customer.customer_code, customer, ROUND(AVG(pre_invoice_discount_pct)*100,2) AS average_discount_percentage FROM dim_customer
JOIN fact_pre_invoice_deductions
ON dim_customer.customer_code = fact_pre_invoice_deductions.customer_code
WHERE market = 'India' AND fiscal_year=2021
GROUP BY customer_code, customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

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