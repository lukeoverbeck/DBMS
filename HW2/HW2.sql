-- #1: Average price of foods at each restaurant

-- Selects names of restaurants and the average food price
-- Joins restaurants with serves and serves with foods
-- Groups according to restaurant name
select restaurants.name, avg(foods.price)
from restaurants
join serves using (restID)
join foods using (foodID)
group by restaurants.name;

-- #2: Maximum food price at each restaurant

-- Selects names of restaurants and the maximum food price
-- Joins restaurants with serves and serves with foods
-- Groups according to restaurant name
select restaurants.name, max(foods.price)
from restaurants
join serves using (restID)
join foods using (foodID)
group by restaurants.name;

-- #3: Count of different food types served at each restaurant
-- Selects names of restaurants and the number of foods served at each restaurant
-- Joins restaurants with serves and serves with foods
-- Groups according to restaurant name
select restaurants.name, count(foods.type)
from restaurants
join serves using (restID)
join foods using (foodID)
group by restaurants.name;

-- #4: Average price of foods served by each chef

-- Selects names of chefs and the average food price
-- Joins all the tables together
-- Groups according to chef and restaurant name (only one chef per restaurant)
-- Displayed in order from highest average price to lowest average price
select chefs.name, avg(foods.price)
from chefs
join works using (chefID)
join restaurants using (restID)
join serves using (restID)
join foods using (foodID)
group by chefs.name;

-- #5: Find the restaurant with the highest average food price

-- Selects names of restaurants the average food price
-- Joins all restaurants with serves and serves with foods
-- Groups according to restaurant name
-- Displays only the restaurant(s) with the highest average food price, using a subquery
select restaurants.name, avg(foods.price)
from restaurants
join serves using (restID)
join foods using (foodID)
group by restaurants.name
having (avg(foods.price)) >= all
	(select avg(foods.price)
    from restaurants
	join serves on restaurants.restID = serves.restID
	join foods on serves.foodID = foods.foodID
    group by restaurants.name);
