-- 1. Mostra quants exemplars de cada pel·lícula tenim a l’inventari. (0.5p)
select film_id, count(film_id) total_film
from sakila.inventory
group by film_id
order by film_id;

-- 2. Mostra el nom de l’actor/actriu i la quantitat de pel·lícules en les que ha participat. 
-- Només volem mostrar aquells actors/actrius que han participat a 35 pel·lícules o més. (1p)
select first_name, last_name, count(film_id) as q_films
from actor 
join film_actor on actor.actor_id = film_actor.actor_id
group by actor.actor_id
order by first_name, last_name;

-- 3. Mostra el nom de les pel·lícules que contenen la paraula “LOVE” al
-- seu títol i que són de la categoria “Classics” o “Sci-Fi”. (1,25p)
select film.title, category.name
from film
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
where film.title like "%LOVE%"
and (category.name = "Classics" or category.name = "Sci-Fi");

-- 4. Troba les pel·lícules que d’acció que no existeixen a l’inventari. (1,5p)
select film.film_id, title, category.name
from film 
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
left join inventory on film.film_id = inventory.film_id
where inventory.film_id is null
and category.name = "Action";

-- 5. Quina botiga té un inventari més gran de pel·lícules de comèdia i esports? (1,5p)
select store.store_id, count(inventory.film_id) as total_films
from store
join inventory on store.store_id = inventory.store_id
join film on inventory.film_id = film.film_id
join film_category on film.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
where category.name = "Comedy" or category.name = "Sports"
group by store.store_id
order by total_films desc
limit 1;

-- 6. Mostra el nom dels actors i actrius que han fet la pel·lícula de Drama més curta. (1,25p)
select first_name, last_name
from actor
join film_actor on actor.actor_id = film_actor.actor_id
join
	(select film.film_id, title, length, category.name
	from film
	join film_category on film.film_id = film_category.film_id
	join category on film_category.category_id = category.category_id
	where category.name = "Drama"
	order by length asc
	limit 1) as length_film on film_actor.film_id = length_film.film_id;

-- 7. Mostra les categories de les pel·lícules que compleixen el següent: la
-- mitja de “rental rate” de la categoria és menor a la mitja de “rental
-- rate” general de totes les pel·lícules. Per tot aquest càlcul, no has
-- d’incloure les pel·lícules amb un “rental rate” menor a 1. (1,5p)
select category_avg.name, category_avg.media_rental_rate
from
	(select category.name, avg(rental_rate) as media_rental_rate
	from film
	join film_category on film.film_id = film_category.film_id
	join category on film_category.category_id = category.category_id
	where rental_rate > 1
	group by category.name) as category_avg
where category_avg.media_rental_rate > 
	(select avg(rental_rate) 
	from film
	where rental_rate > 1);

-- 8. Mostra el nom de la pel·lícula i la quantitat d’actors/actrius de la
-- pel·lícula que més (actors i actrius) tingui de cada categoria. Si hi ha
-- empat de dos o més pel·lícules de la mateixa categoria en la seva
-- quantitat d’actors/actrius, les has de mostrar totes. (1.5p)
select resum.name, resum.title, resum.q_actor
from
	(select category.name, film.title, count(film_actor.actor_id) as q_actor
	from film
	join film_actor on film.film_id = film_actor.film_id
	join film_category on film.film_id = film_category.film_id
	join category on film_category.category_id = category.category_id
	group by category.name, film.title) as resum
join 
	(select resum3.name, max(resum3.q_actor) as max_actor
	from
		(select category.name, film.title, count(film_actor.actor_id) as q_actor
		from film
		join film_actor on film.film_id = film_actor.film_id
		join film_category on film.film_id = film_category.film_id
		join category on film_category.category_id = category.category_id
		group by category.name, film.title) as resum3
		group by resum3.name
	) as resum2
on resum.name = resum2.name
and resum.q_actor = resum2.max_actor;