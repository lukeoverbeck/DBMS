-- #1: List names and sellers of products that are no longer available (quantity=0)
select merchants.name, products.name
from merchants
join sell using (mid)
join products using (pid)
where quantity_available = 0;
-- Lists all products that are out of stock by joining merchants, sell, and products 
-- and filtering for quantity_available = 0

-- #2: List names and descriptions of products that are not sold.
select name, description
from products
except
select name, description
from products
join sell using (pid);

-- OR

select name, description
from products
left outer join sell using (pid)
where sell.pid is null;
-- Retrieves products with no record in sell by using a left outer join or except

-- #3: How many customers bought SATA drives but not any routers?
select count(*)
from (
	select distinct place.cid
	from place
	join orders using (oid)
	join contain using (oid)
	join products using (pid)
	where products.name = 'Hard Drive'
	and products.description like '%SATA%'
    except
    select distinct place.cid
	from place
	join orders using (oid)
	join contain using (oid)
	join products using (pid)
	where products.name = 'Router'
) as sata_no_router;
-- Counts distinct customers who bought SATA drives but never any routers by using except

-- #4: HP has a 20% sale on all its Networking products.
select products.name, sell.price as regular_price, sell.price * 0.8 as sale_price
from products
join sell using (pid)
join merchants using (mid)
where merchants.name = 'HP' and products.category = 'Networking';
-- Shows HP Networking products with a 20% discounted price by joining merchants, sell, and products 
-- and calculating sell.price * 0.8

-- #5: What did Uriel Whitney order (make sure to at least retrieve product names and prices).
select distinct products.name, merchants.name as seller, sell.price
from customers
join place using (cid)
join orders using (oid)
join contain using (oid)
join products using (pid)
join sell using (pid)
join merchants using (mid)
where customers.fullname = 'Uriel Whitney';
-- Lists all products ordered by Uriel Whitney with all their sellers and price 
-- by joining customers, place, orders, contain, products, sell, and merchants

-- #6: List the annual total sales for each company (sort the results along the company and the year attributes).
select merchants.name as company, year(place.order_date) as rev_year, sum(sell.price) as total_sales
from merchants
join sell using (mid)
join products using (pid)
join contain using (pid)
join orders using (oid)
join place using (oid)
group by company, rev_year
order by company, rev_year;
-- Computes annual total sales per merchant by summing sell.price for each customer order grouped by merchant and year

-- #7: Which company had the highest annual revenue and in what year?
select merchants.name as company, year(place.order_date) as rev_year, sum(sell.price)
from merchants
join sell using (mid)
join products using (pid)
join contain using (pid)
join orders using (oid)
join place using (oid)
group by company, rev_year
order by sum(sell.price) desc
limit 1;

-- OR

select merchants.name as company, year(place.order_date) as rev_year, sum(sell.price) as total_sales
from merchants
join sell using (mid)
join products using (pid)
join contain using (pid)
join orders using (oid)
join place using (oid)
group by company, rev_year
having total_sales >= all (
	select sum(sell.price)
	from merchants
	join sell using (mid)
	join products using (pid)
	join contain using (pid)
	join orders using (oid)
	join place using (oid)
    group by merchants.name, year(place.order_date)
);
-- Returns the merchant and year with the highest revenue by aggregating sales per merchant per year 
-- and ordering by total revenue descending or a having block

-- #8: On average, what was the cheapest shipping method used ever?
select shipping_method, avg(shipping_cost) as avg_cost
from orders
group by shipping_method
order by avg_cost
limit 1;

-- OR
select shipping_method, avg(shipping_cost) as avg_cost
from orders
group by shipping_method
having avg_cost <= all (
	select avg(shipping_cost)
    from orders
    group by shipping_method
);
-- Gives the shipping method with the lowest average cost by grouping orders by shipping_method and 
-- selecting the minimum of avg(shipping_cost) using order by or a having block

-- #9: What is the best sold ($) category for each company?
select merchants.name, category, sum(price) as total_sales
from contain
join products using (pid)
join sell using (pid)
join merchants using (mid)
group by merchants.name, products.category
having total_sales >= all (
	select sum(price)
    from contain
    join products using (pid)
    join sell using (pid)
    join merchants as merchants2 using (mid)
    where merchants2.name = merchants.name
    group by merchants.name, products.category
)
order by total_sales desc;
-- Determines each merchant’s top-grossing product category by summing sell.price per merchant per category 
-- and comparing each to all other categories of the same merchant

-- #10: For each company find out which customers have spent the most and the least amounts.
select merchants.name, customers.fullname, sum(shipping_cost) as total_shipping_cost, 
sum(price) as total_from_order, sum(shipping_cost) + sum(price) as total_cost
from customers
join place using (cid)
join orders using (oid)
join contain using (oid)
join products using (pid)
join sell using (pid)
join merchants using (mid)
group by merchants.name, customers.fullname
having total_from_order >= all (
	select sum(price)
	from customers
	join place using (cid)
	join orders using (oid)
	join contain using (oid)
	join products using (pid)
	join sell using (pid)
	join merchants as merchants2 using (mid)
    where merchants2.name = merchants.name
	group by merchants.name, customers.fullname
) or total_from_order <= all (
	select sum(price)
	from customers
	join place using (cid)
	join orders using (oid)
	join contain using (oid)
	join products using (pid)
	join sell using (pid)
	join merchants as merchants2 using (mid)
	where merchants2.name = merchants.name
	group by merchants.name, customers.fullname
);
-- Identifies the highest and lowest spending customers per merchant by summing their order totals and 
-- using two having blocks, one for max and one for min.