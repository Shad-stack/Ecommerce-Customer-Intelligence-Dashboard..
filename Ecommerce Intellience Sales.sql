create database Ecommerce_db;
use Ecommerce_db;
show  tables;

#1. Overall Business KPIs
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    AVG(sales) AS average_order_value
FROM ecommerce_sales;



#2. Region - wise performance
SELECT
    region,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM ecommerce_sales
GROUP BY region
ORDER BY total_sales DESC;


#3. Category performance
select
      category,
      round(sum(sales), 2) as total_sales,
      round(sum(profit), 2) as total_profit
      from ecommerce_sales
      group by category
      order by total_sales desc;
      
      
      
      #4. Most profitable products
      select 
            product_name,
            round(sum(sales), 2) as total_sales,
            round(sum(profit), 2) as total_profit
            from ecommerce_sales
            group by product_name
            order by total_profit desc
            limit 10;
            
            
            
            
            
            #5. Loss making product
            select 
                   product_name,
            round(sum(sales), 2) as total_sales,
            round(sum(profit), 2) as total_profit
            from ecommerce_sales
            group by product_name
            having sum(profit) <0
            order by total_profit ;
            
         
     
     # Rename table
            ALTER TABLE ecommerce_sales
RENAME COLUMN `ï»¿order_id` TO `order_id`;
            
  describe ecommerce_sales;  
  
  
  
  
  #6. customer spending
  select
        customer_id,
        count(distinct order_id) as total_orders,
        round(sum(sales), 2) as total_spent
        from ecommerce_sales
        group by customer_id
        order by total_spent
        limit 10;
  
            
            
       
# 7. Customer segmentation using CASE
select
      customer_id,
      round(sum(sales), 2) as total_spent,
      CASE
          when sum(sales) >= 50000 then 'High Value '
          when sum(sales) >= 25000 then 'Medium Value'
          else 'Low Value'
		end as customer_value
	from ecommerce_sales
    group by customer_id;
          
          
     
          
 # 8. Monthly sales & Profit
 SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    round(SUM(sales), 2) AS monthly_sales,
    round(sum(profit), 2) as monthly_profit
FROM ecommerce_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
         
          
         
# Modify order_date

alter table ecommerce_sales
modify column order_date date;

alter table ecommerce_sales
modify column ship_date date;




# 9. Payment method analysis
select
      payment_method,
      count(distinct order_id) as total_order,
      round(sum(sales), 2) as total_sales
	from ecommerce_sales
	group by payment_method
    order by total_sales desc;
    
    
    
    
    # 10. Customer spending above average
    SELECT
    customer_id,
    SUM(sales) AS total_spent
FROM ecommerce_sales
GROUP BY customer_id
HAVING SUM(sales) >
(
    SELECT AVG(customer_total)
    FROM
    (
        SELECT
            customer_id,
            SUM(sales) AS customer_total
        FROM ecommerce_sales
        GROUP BY customer_id
    ) AS customer_sales
)
ORDER BY total_spent DESC;




# 11. CTC ------ Top customers
WITH CustomerSales AS (
    SELECT
        customer_id,
        round(SUM(sales), 2) AS total_sales
    FROM ecommerce_sales
    GROUP BY customer_id
)

SELECT *
FROM CustomerSales
ORDER BY total_sales DESC
LIMIT 10;
      
      
      
      
      
 # 12. Customer ranking 
 SELECT
    customer_id,
    SUM(sales) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(sales) DESC
    ) AS customer_rank
FROM ecommerce_sales
GROUP BY customer_id;





# 13. Top product within each ech category 
    # CTC + ROW NUMBER()
    
    
WITH ProductSales AS (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales
    FROM ecommerce_sales
    GROUP BY category, product_name
),

RankedProducts AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_sales DESC
        ) AS rn
    FROM ProductSales
)

SELECT *
FROM RankedProducts
WHERE rn <= 3;





# 14. MoM Sales Growth
WITH MonthlySales AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        round(SUM(sales), 2) AS total_sales
    FROM ecommerce_sales
    GROUP BY YEAR(order_date), MONTH(order_date)
),

PreviousMonth AS (
    SELECT
        *,
        LAG(total_sales) OVER (
            ORDER BY year, month
        ) AS previous_month_sales
    FROM MonthlySales
)

SELECT
    year,
    month,
    total_sales,
    previous_month_sales,
    ROUND(
        (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct
FROM PreviousMonth;






# 15. Customer intelligence
       # New vs Returning vs Loyal
select
      customer_segment,
      count(distinct customer_id) as customers,
      round(sum(sales), 2) as total_sales
      from ecommerce_sales
      group by customer_segment
      order by total_sales desc;
      
      
      
      
# 16. Repeat purchase rate
WITH CustomerOrders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM ecommerce_sales
    GROUP BY customer_id
)

SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS repeat_purchase_rate
FROM CustomerOrders;
      
      
      
      
      
# 17. Customer lifetime sales
SELECT
    customer_id,
    MIN(order_date) AS first_purchase,
    MAX(order_date) AS last_purchase,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS lifetime_sales
FROM ecommerce_sales
GROUP BY customer_id
ORDER BY lifetime_sales DESC;





# 18. Customer RFM base
SELECT
    customer_id,
    DATEDIFF(
        (SELECT MAX(order_date) FROM Ecommerce_Sales),
        MAX(order_date)
    ) AS recency,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(sales) AS monetary
FROM ecommerce_sales
GROUP BY customer_id;










    
    
    
# 20. Deivery performance
select
	delivery_status,
    COUNT(DISTINCT order_id) AS total_orders,
    AVG(delivery_days) AS avg_delivery_days,
    AVG(customer_rating) AS avg_rating
FROM ecommerce_sales
GROUP BY delivery_status
ORDER BY total_orders DESC;

