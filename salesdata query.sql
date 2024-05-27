-- Looking through the data to figure out what I am looking for:

select *
from salesdata;

-- Finding total sales for each product category:
-- They have an equal amount of products in category
select count(product_category) as TotalInCategory, product_category,sum(total_revenue) as TotalRevenue
from salesdata
group by product_category;

-- Average sales amount per item in each category:
select product_category, round(average_revenue::numeric, 2) as Avg_Revenue
from (
select product_category, (avg(total_revenue)) as average_revenue
from salesdata
group by product_category
order by average_revenue asc);

-- Lowest Avg Sales
select product_category, min(average_revenue) as lowest_sales from(
select product_category, round(avg(total_revenue)::numeric, 2) as average_revenue
from salesdata
group by product_category)
group by product_category
order by lowest_sales asc;

-- Highest Avg Sales
select product_category, max(average_revenue) as highest_sales from(
select product_category, round(avg(total_revenue)::numeric, 2) as average_revenue
from salesdata
group by product_category)
group by product_category
order by highest_sales desc;

-- Sales per region
select region, round(TotalRegion_Revenue::numeric, 2)
from(
select region, sum(total_revenue) as TotalRegion_Revenue
from salesdata
group by region)
order by TotalRegion_Revenue asc;

-- Creating a temp table
"""create temporary table AvgRev_ByRegion (region varchar, TotalRegion_Revenue numeric);

insert into AvgRev_ByRegion
select region, round(TotalRegion_Revenue::numeric, 2)
from(
select region, sum(total_revenue) as TotalRegion_Revenue
from salesdata
group by region);""";

-- Total sales for each payment method

select payment_method, round(sum(total_revenue::numeric), 2) as total_revenue
from salesdata
group by payment_method
order by total_revenue asc;

-- Avg Sales Transaction per pay method

select round(((total_revenue_cc::numeric / sum_all_revenue::numeric)*100),2) as Credit_Card_Avg_Transaction_Percent
from(
select sum(total_revenue) as sum_all_revenue from salesdata) as total_units_revenue
cross join(
select sum(total_revenue) as total_revenue_cc
from salesdata
where payment_method = 'Credit Card'
) as total_revenue_cc;

select round(((total_revenue_dc::numeric / sum_all_revenue::numeric)*100),2) as Debit_Card_Avg_Transaction_Percent
from(
select sum(total_revenue) as sum_all_revenue from salesdata) as total_units_revenue
cross join(
select sum(total_revenue) as total_revenue_dc
from salesdata
where payment_method = 'Debit Card'
) as total_revenue_dc;

select round(((total_revenue_paypal::numeric / sum_all_revenue::numeric)*100),2) as paypal_Avg_Transaction_Percent
from(
select sum(total_revenue) as sum_all_revenue from salesdata) as total_units_revenue
cross join(
select sum(total_revenue) as total_revenue_paypal
from salesdata
where payment_method = 'PayPal'
) as total_revenue_cc;

-- total sales amount per day
select date, total_revenue
from salesdata;


-- Products by total sales amount / total revenue that item brung in
select product_name, total_revenue
from salesdata
order by total_revenue desc
limit 10;

-- lowest by total sales amount
select product_name, total_revenue
from salesdata
order by total_revenue asc
limit 10;

-- Identifying repeat transactions for specific items to identify potential customer loyalty through those items
select product_name, units_sold, total_revenue
from salesdata
order by units_sold desc;
-- Identifying repeat transactions for specific items to identify potential customer loyalty through those items (By Region)
select region, product_name, units_sold,total_revenue
from salesdata
order by region, units_sold desc;




