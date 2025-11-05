#1 What is the average length of films in each category? List the results in alphabetic order of categories.
select category.name as category_name, avg(length) as avg_length
from film
join film_category using (film_id)
join category using (category_id)
group by category_name
order by category_name;

#2 Which categories have the longest and shortest average film lengths?
with category_avg as (
	select category.name as category_name, avg(length) as avg_length
    from film
    join film_category using (film_id)
    join category using (category_id)
    group by category_name
)
select *
from category_avg
where avg_length = (select max(avg_length) from category_avg)
	or avg_length = (select min(avg_length) from category_avg)
order by category_name;

#3 Which customers have rented action but not comedy or classic movies?
select first_name, last_name
from customer
join rental using (customer_id)
join inventory using (inventory_id)
join film using (film_id)
join film_category using (film_id)
join category using (category_id)
where category.name = 'Action'
except
select first_name, last_name
from customer
join rental using (customer_id)
join inventory using (inventory_id)
join film using (film_id)
join film_category using (film_id)
join category using (category_id)
where category.name = 'Comedy' or category.name = 'Classics';

# OR

select first_name, last_name
from customer
join rental using (customer_id)
join inventory using (inventory_id)
join film using (film_id)
join film_category using (film_id)
join category using (category_id)
group by first_name, last_name
having sum(category.name = 'Action') > 0
	and sum(category.name = 'Comedy') = 0
    and sum(category.name = 'Classics') = 0;
    
#4 Which actor has appeared in the most English-language movies?
with actor_total as (
	select first_name, last_name, sum(language.name = 'English') as sum_eng
    from actor
    join film_actor using (actor_id)
    join film using (film_id)
    join language using (language_id)
    group by first_name, last_name
)
select *
from actor_total
where sum_eng = (select max(sum_eng) from actor_total);

#5 How many distinct movies were rented for exactly 10 days from the store where Mike works?
select count(distinct(title))
from film
join inventory using (film_id)
join rental using (inventory_id)
join staff using (staff_id)
where datediff(rental.return_date, rental.rental_date) = 10
	and staff.first_name = 'Mike';
    
#6 Alphabetically list actors who appeared in the movie with the largest cast of actors.
with largest_film as (
	select film_id
    from film_actor
    group by film_id
    having count(actor_id) >= all (
		select count(actor_id)
        from film_actor
        group by film_id
	)
)
select actor.first_name, actor.last_name, film.title
from actor
join film_actor using (actor_id)
join largest_film using (film_id)
join film using (film_id)
order by actor.first_name, actor.last_name;
