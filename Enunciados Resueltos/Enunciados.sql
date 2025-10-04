

--1. Crea el esquema de la BBDD.


-- Ejecución del archivo "BBDD/bbdd.sql"



--2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’.

select *
from film f 
where f.rating = 'R';

--3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

select *
from actor a 
where a.actor_id between 30 and 40;


--4. Obtén las películas cuyo idioma coincide con el idioma original.

-- ATENCIÓN!! En esta consulta se han modificado los resultados de la bbdd manualmente
-- para obtener al menos un resultado puesto que no había ningún valor que coincidiese

select *
from film f 
where f.language_id = f.original_language_id;


--5. Ordena las películas por duración de forma ascendente.

select f.title, f.description, f.length 
from film f 
order by f.length asc;


--6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.

select a.first_name as "Nombre", a.last_name as "Apellido" 
from actor a 
where a.last_name = 'ALLEN';


--7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” y muestra la clasificación junto con el recuento.

select f.rating as "Clasificación", count(f.rating) as "Total"
from film f 
group by f.rating;


--8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.

select f.title as "Título", f.rating as "Clasificación", f.length as "Duración"
from film f 
where f.rating = 'PG-13' and f.length > 180;


--9. Encuentra la variabilidad de lo que costaría reemplazar las películas.


select VARIANCE(f.replacement_cost) as "Varianza"
from film f;


--10. Encuentra la mayor y menor duración de una película de nuestra BBDD.

select MAX(f.length) as "Mayor_Duración", MIN(f.length) as "Menor_Duración"
from film f; 


--11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

select *
from rental r 
order by r.rental_date desc
limit 1 OFFSET 2;


--12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC17’ ni ‘G’ en cuanto a su clasificación.

SELECT f.title
FROM film f
WHERE f.rating <> 'NC-17' or f.rating <> 'G';


--13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

select f.rating as "Clasificación", round(AVG(f.length),2) as "Duración"
from film f 
group by f.rating ;


--14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.

select f.title 
from film f 
where f.length > 180;


--15. ¿Cuánto dinero ha generado en total la empresa?

select concat(sum(p.amount), '€') as "Ingresos_Totales"
from payment p ;


--16. Muestra los 10 clientes con mayor valor de id.

select c.customer_id, c.first_name as nombre, c.last_name as apellido
from customer c 
order by c.customer_id asc
limit 10;

--17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’.

select a.actor_id, a.first_name as "Nombre", a.last_name as "Apellido"
from film f 
join film_actor fa on f.film_id = fa.film_id 
join actor a on fa.actor_id = a.actor_id 
where f.title = 'EGG IGBY';



--18. Selecciona todos los nombres de las películas únicos.

select distinct(f.title)
from film f; 


--19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.

select f.title   
from film f 
inner join film_category fc on f.film_id  = fc.film_id 
inner join category c on fc.category_id = c.category_id 
where f.length > 180 and c."name" = 'Comedy';


--20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos y muestra el nombre de la categoría junto con el promedio de duración.

select c."name", round(avg(f.length),2)
from category c 
inner join film_category fc on fc.category_id = c.category_id 
inner join film f on f.film_id  = fc.film_id 
group by c."name"
having avg(f.length) > 110; 

--21. ¿Cuál es la media de duración del alquiler de las películas?

select avg(f.rental_duration)
from film f ;


--22. Crea una columna con el nombre y apellidos de todos los actores y actrices.

select concat(a.first_name, ' ',a.last_name ) as "Full Name"
from actor a; 


--23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.


with FechasFormateadas as (
	select SUBSTRING(r.rental_date::text FROM 1 FOR 10) as fecha 	--obtenemos únicamente la fecha para poder agrupar
	from rental r 
	order by r.rental_date asc
)
select ff.fecha as "Día", count(ff.fecha) as "Total de Alquileres"  --mostramos la fecha formateada y el count para sacar el número de rentals
from FechasFormateadas ff 											--usamos nuestro CTE
group by ff.fecha 													--agrupamos por fecha para poder sacar el count
order by ff.fecha asc; 												--ordenamos por fecha


--24. Encuentra las películas con una duración superior al promedio.

select *
from film f 
where f.length > (
	select avg(f2.length) 
	from film f2
);


--25. Averigua el número de alquileres registrados por mes.


with Meses as (
	select extract(month from r.rental_date) as mes --obtenemos el mes de cada rental
	from rental r 
	order by r.rental_date asc
)
select m.mes, count(m.mes) as "Total Alquileres" 	--mostramos el mes y el count para sacar el número de rentals por mes
from Meses m 										--usamos nuestro CTE
group by m.mes 										-- Agrupamos por mes
order by m.mes; 									-- Ordenamos por mes



--26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

select avg(p.amount) as "Promedio", stddev(p.amount) as "Desviación Estandar", variance(p.amount) as "Varianza"
from payment p ;


--27. ¿Qué películas se alquilan por encima del precio medio?

select distinct f.title, p.amount  						-- Hacemos select distinct para asegurarnos de que no se repite ningún valor
from film f 
inner join inventory i on f.film_id = i.film_id 
inner join rental r on i.inventory_id = r.inventory_id 
inner join payment p on r.rental_id  = p.rental_id
where p.amount > ( 										--Nos aseguramos de que los resultados tengan el precio mayor al precio medio
	select avg(p.amount)
	from payment p 
);


--28. Muestra el id de los actores que hayan participado en más de 40 películas.

select fa.actor_id  							
from film_actor fa 
group by fa.actor_id 
having count(fa.actor_id) > 40;



--29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.

select i.film_id as "ID Película", count(i.film_id) as "Inventario"
from inventory i 
inner join film f on i.film_id = f.film_id 
group by i.film_id ;


--30. Obtener los actores y el número de películas en las que ha actuado.

select a.actor_id as "ID Actor" , concat(a.first_name, ' ', a.last_name ) as "Nombre Completo", count(a.actor_id) as "Total Apariciones"
from actor a 
inner join film_actor fa on a.actor_id = fa.actor_id 
group by a.actor_id, a.first_name, a.last_name ;


--31. Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.

select f.title as "Película", concat(a.first_name, ' ', a.last_name ) as "Nombre Completo Actor"
from film f 
left join film_actor fa on f.film_id = fa.film_id 
inner join actor a on fa.actor_id = a.actor_id 
order by f.title;


--32. Obtener todos los actores y mostrar las películas en las que han actuado, incluso si algunos actores no han actuado en ninguna película.

select concat(a.first_name, ' ', a.last_name ) as "Nombre Completo Actor", f.title as "Película"
from actor a 
left join film_actor fa on a.actor_id = fa.actor_id 
inner join film f on fa.film_id = f.film_id 
order by a.actor_id 


--33. Obtener todas las películas que tenemos y todos los registros de alquiler.

select f.*, r.*
from film f 
full join inventory i on i.film_id = f.film_id 
full join rental r  on r.inventory_id = i.inventory_id;


--34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

select concat(c.first_name, ' ', c.last_name ) as "Full Name", concat(count(p.amount), '€') as "Total"
from customer c 
inner join rental r on r.customer_id = c.customer_id 
inner join payment p on p.rental_id = r.rental_id 
group by c.customer_id 
order by count(p.amount) desc
limit 5;


--35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.

select a.actor_id, concat(a.first_name, ' ', a.last_name ) as "Nombre Completo Actor"
from actor a 
where a.first_name = 'JOHNNY';


--36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.

select a.first_name  as "Nombre", a.last_name as "Apellido";
from actor a 


--37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

select Max(a.actor_id), min(a.actor_id);
from actor a 


--38. Cuenta cuántos actores hay en la tabla “actor”.

select distinct count(a.actor_id)
from actor a;


--39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.

select a.*
from actor a 
order by a.last_name asc;


--40. Selecciona las primeras 5 películas de la tabla “film”.

select *
from film m 
limit 5;


--41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?

select a.first_name ,count(a.first_name )
from actor a 
group by a.first_name; 


--42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.

select r.*, c.first_name as "Nombre Cliente"
from  rental r 
inner join customer c  on r.customer_id = c.customer_id;


--43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.

select r.*, c.first_name as "Nombre Cliente"
from  rental r 
right join customer c  on r.customer_id = c.customer_id;


--44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación.

/*RESPUESTA:
 * 
 *Esta consulta no aporta ningún valor porque debido a que con el cross origin combinamos cada row de una tabla con todas las rows de 
 *la tabla con la que se relaciona, se están combinando películas que poseen una sola categoría con datos de categorías que no tienen nada que 
 *ver, dando como resultado un cúmulo de datos sin sentido que no nos lleva a ninguna conclusión.*/

select *
from film f
cross join film_category fc 
cross join category c ;


--45. Encuentra los actores que han participado en películas de la categoría 'Action'.

select a.*
from actor a
inner join film_actor fa on fa.actor_id = a.actor_id 
inner join film f on fa.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
where f.film_id in (											-- Obtenemos sólo las películas de Acción y a raíz de ello los actores de estas películas
	select fc2.film_id 
	from film_category fc2 
	inner join category c2 on fc2.category_id = c2.category_id
	where c2."name" = 'Action'
);


--46. Encuentra todos los actores que no han participado en películas.

select a.*
from  actor a 
left join film_actor fa on a.actor_id = fa.actor_id 
where fa.film_id is null;


--47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.

select a.first_name as "Nombre", count(a.actor_id) as "Total Actuaciones"
from actor a 
inner join film_actor fa on fa.actor_id = a.actor_id 
group by a.actor_id ;


--48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores y el número de películas en las que han participado.

create view actor_num_peliculas as
select a.first_name as "Nombre", count(a.actor_id) as "Total Actuaciones"
from actor a 
inner join film_actor fa on fa.actor_id = a.actor_id 
group by a.actor_id;

select *
from actor_num_peliculas;

--49. Calcula el número total de alquileres realizados por cada cliente.

select r.customer_id, count(r.customer_id)
from rental r
inner join customer c on r.customer_id = c.customer_id
group by r.customer_id ;


--50. Calcula la duración total de las películas en la categoría 'Action'.

	select sum(f.length) as "Duración Total"
	from film f 
	inner join film_category fc on f.film_id = fc.film_id 
	inner join category c on fc.category_id = c.category_id
	where c."name" = 'Action';


--51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.

with cliente_rentas_temporal as (
	select r.customer_id, count(r.customer_id)
	from rental r
	inner join customer c on r.customer_id = c.customer_id
	group by r.customer_id 
)
select *
from cliente_rentas_temporal;

--52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las películas que han sido alquiladas al menos 10 veces.

with peliculas_alquiladas as (
	select f.title  as "Título Película"
	from film f 
	where f.film_id in (
		select i.film_id
		from film f 
		inner join inventory i on f.film_id = i.film_id
		group by i.film_id 
		having count(i.film_id) > 10										 -- Resultados a hasta los 7 rentals 
	)
)
select *
from peliculas_alquiladas;


--53. Encuentra el título de las películas que han sido alquiladas por el cliente con el nombre ‘Tammy Sanders’ y que 
--aún no se han devuelto. Ordena los resultados alfabéticamente por título de película.

select f.title 
from customer c 
inner join rental r on c.customer_id = r.customer_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id
where c.first_name = 'TAMMY' and c.last_name = 'SANDERS' and r.return_date is null;
  

--54. Encuentra los nombres de los actores que han actuado en al menos una película que pertenece a la categoría ‘Sci-Fi’.
-- Ordena los resultados alfabéticamente por apellido.

select a.actor_id, a.first_name, a.last_name 
from category c 
inner join film_category fc on c.category_id = fc.category_id
inner join film f on fc.film_id = f.film_id
inner join film_actor fa on f.film_id = fa.film_id
inner join actor a on fa.actor_id = a.actor_id
where c.name  = 'Sci-Fi'
order by a.last_name;



--55. Encuentra el nombre y apellido de los actores que han actuado en películas que se alquilaron después de que
-- la película ‘Spartacus Cheaper’ se alquilara por primera vez. Ordena los resultados alfabéticamente por apellido.

select distinct a.actor_id , a.first_name , a.last_name 
from actor a 
inner join film_actor fa on a.actor_id = fa.actor_id
inner join film f on fa.film_id = f.film_id
inner join inventory i on f.film_id = i.film_id
inner join rental r on i.inventory_id = r.inventory_id
where r.rental_date > (
    SELECT  r.rental_date  
    FROM rental r 
    inner join inventory i on r.inventory_id = i.inventory_id
    inner join film f on i.film_id = f.film_id
    where f.title = 'SPARTACUS CHEAPER'
    order by r.rental_date
    limit 1
);



--56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.

select distinct a.first_name, a.last_name 
from actor a 
inner join film_actor fa on a.actor_id = fa.actor_id
inner join film f on fa.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
where a.actor_id not in (
	select a.actor_id 
	from actor a 
	inner join film_actor fa on a.actor_id = fa.actor_id
	inner join film f on fa.film_id = f.film_id
	inner join film_category fc on f.film_id = fc.film_id
	inner join category c on fc.category_id = c.category_id
	where c."name" = 'Music'
);


--57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.

select distinct f.title												
from film f 
inner join inventory i on f.film_id = i.film_id
inner join rental r on i.inventory_id = r.inventory_id
where EXTRACT(DAY FROM age(r.return_date , r.rental_date )) > 8
order by f.title;


--58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’.


select f.title 
from film f 
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
where c."name" = 'Animation'


--59. Encuentra los nombres de las películas que tienen la misma duración que la película con el título ‘Dancing Fever’. Ordena los resultados alfabéticamente por título de película.


select f.title 
from film f
where f.length in (
	select f2.length 
	from film f2
	where f2.title = 'DANCING FEVER'
)


--60. Encuentra los nombres de los clientes que han alquilado al menos 7 películas distintas. Ordena los resultados alfabéticamente por apellido.


select c.first_name
from customer c 
inner join rental r on c.customer_id = r.customer_id
inner join inventory i on r.inventory_id = i.inventory_id 
inner join film f on i.film_id = f.film_id 
group by f.title, c.first_name
having count(c.customer_id) > 6 															-- Resultados visibles hasta las 2 películas distintas

 


--61. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.


select c."name" as "Categoría", count(f.title) as "Total"
from film f 
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
group by c."name" 
order by count(f.title) desc


--62. Encuentra el número de películas por categoría estrenadas en 2006.

select count(f.film_id)
from film f 
where f.release_year = 2006



--63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.


select s.*, s2.*
from store s
cross join staff s2 


--64. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y
-- apellido junto con la cantidad de películas alquiladas.

select c.customer_id, c.first_name, c.last_name , count(r.customer_id) as "Total Alquileres"
from customer c 
left join rental r on c.customer_id = r.customer_id 
group by c.customer_id 





