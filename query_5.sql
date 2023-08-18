-- Does 80% of the sales come from 20% of the companies?

select * from store_orders

with all_sales_per_product as (
select Product_ID, sum(sales) as sales_per_product
from store_orders
group by Product_ID)
, cte as (
select *, 
sum(sales_per_product) over(order by sales_per_product desc rows between unbounded preceding and 0 preceding) as cumulative_total, 
(sum(sales_per_product) over()) * 0.8 as eighty_percent_of_all_sales
from all_sales_per_product)
, cte2 as (
select *, 
case when cumulative_total < eighty_percent_of_all_sales then cumulative_total else null end as less_than_eight_percent
from cte)
, num_of_all_companies as (
select count(distinct Product_ID) as num_company from store_orders)

select count(Product_ID) * 1.0 / max(num_company) * 100
from cte2, num_of_all_companies
where less_than_eight_percent is not null --nearly 80% of the sales comes from 20% of all companies.