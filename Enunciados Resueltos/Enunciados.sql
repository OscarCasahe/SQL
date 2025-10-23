

--1. Crea el esquema de la BBDD.


-- Ejecución del archivo "BBDD/bbdd.sql"



--2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’.

SELECT *
FROM film f 
WHERE f.rating = 'R';

--3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

SELECT *
FROM actor a 
WHERE a.actor_id between 30 AND 40;


--4. Obtén las películas cuyo idioma coincide con el idioma original.

-- ATENCIÓN!! En esta consulta se han modificado los resultados de la bbdd manualmente
-- para obtener al menos un resultado puesto que no había ningún valor que coincidiese

SELECT *
FROM film f 
WHERE f.language_id = f.original_language_id;


--5. Ordena las películas por duración de forma ascendente.

SELECT f.title, f.description, f.length 
FROM film f 
ORDER BY f.length asc;


--6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.

SELECT a.first_name AS "Nombre", a.last_name AS "Apellido" 
FROM actor a 
WHERE a.last_name = 'ALLEN';


--7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” y muestra la clasificación junto con el recuento.

SELECT f.rating AS "Clasificación", COUNT(f.rating) AS "Total"
FROM film f 
GROUP BY f.rating;


--8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.

SELECT f.title AS "Título", f.rating AS "Clasificación", f.length AS "Duración"
FROM film f 
WHERE f.rating = 'PG-13' OR f.length > 180;


--9. Encuentra la variabilidad de lo que costaría reemplazar las películas.


SELECT VARIANCE(f.replacement_cost) AS "Varianza"
FROM film f;


--10. Encuentra la mayor y menor duración de una película de nuestra BBDD.

SELECT MAX(f.length) AS "Mayor_Duración", MIN(f.length) AS "Menor_Duración"
FROM film f; 


--11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

SELECT *
FROM rental r 
ORDER BY r.rental_date desc
LIMIT 1 OFFSET 2;


--12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC17’ ni ‘G’ en cuanto a su clasificación.

SELECT f.title
FROM film f
WHERE f.rating <> 'NC-17' AND f.rating <> 'G';


--13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT f.rating AS "Clasificación", ROUND(AVG(f.length),2) AS "Duración"
FROM film f 
GROUP BY f.rating ;


--14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.

SELECT f.title 
FROM film f 
WHERE f.length > 180;


--15. ¿Cuánto dinero ha generado en total la empresa?

SELECT CONCAT(SUM(p.amount), '€') AS "Ingresos_Totales"
FROM payment p ;


--16. Muestra los 10 clientes con mayor valor de id.

SELECT c.customer_id, c.first_name AS nombre, c.last_name AS apellido
FROM customer c 
ORDER BY c.customer_id DESC
LIMIT 10;

--17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’.

SELECT a.actor_id, a.first_name AS "Nombre", a.last_name AS "Apellido"
FROM film f 
join film_actor fa ON f.film_id = fa.film_id 
join actor a ON fa.actor_id = a.actor_id 
WHERE f.title = 'EGG IGBY';



--18. Selecciona todos los nombres de las películas únicos.

SELECT DISTINC(f.title)
FROM film f; 


--19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.

SELECT f.title   
FROM film f 
INNER JOIN film_category fc ON f.film_id  = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id 
WHERE f.length > 180 AND c."name" = 'Comedy';


--20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos y muestra el nombre de la categoría junto con el promedio de duración.

SELECT c."name", ROUND(AVG(f.length),2)
FROM category c 
INNER JOIN film_category fc ON fc.category_id = c.category_id 
INNER JOIN film f ON f.film_id  = fc.film_id 
GROUP BY c."name"
HAVING AVG(f.length) > 110; 

--21. ¿Cuál es la media de duración del alquiler de las películas?

SELECT AVG(f.rental_duration)
FROM film f ;


--22. Crea una columna con el nombre y apellidos de todos los actores y actrices.

SELECT CONCAT(a.first_name, ' ',a.last_name ) AS "Full Name"
FROM actor a; 


--23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.


WITH FechasFormateadas AS (
	SELECT SUBSTRING(r.rental_date::text FROM 1 FOR 10) AS fecha 	--obtenemos únicamente la fecha para poder agrupar
	FROM rental r 
	ORDER BY r.rental_date asc
)
SELECT ff.fecha AS "Día", COUNT(ff.fecha) AS "Total de Alquileres"  --mostramos la fecha formateada y el COUNT para sacar el número de rentals
FROM FechasFormateadas ff 											--usamos nuestro CTE
GROUP BY ff.fecha 													--agrupamos por fecha para poder sacar el COUNT
ORDER BY ff.fecha asc; 												--ordenamos por fecha


--24. Encuentra las películas con una duración superior al promedio.

SELECT *
FROM film f 
WHERE f.length > (
	SELECT AVG(f2.length) 
	FROM film f2
);


--25. Averigua el número de alquileres registrados por mes.


WITH Meses AS (
	SELECT extract(month FROM r.rental_date) AS mes --obtenemos el mes de cada rental
	FROM rental r 
	ORDER BY r.rental_date asc
)
SELECT m.mes, COUNT(m.mes) AS "Total Alquileres" 	--mostramos el mes y el COUNT para sacar el número de rentals por mes
FROM Meses m 										--usamos nuestro CTE
GROUP BY m.mes 										-- Agrupamos por mes
ORDER BY m.mes; 									-- Ordenamos por mes



--26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

SELECT AVG(p.amount) AS "Promedio", STDDEV(p.amount) AS "Desviación Estandar", VARIANCE(p.amount) AS "Varianza"
FROM payment p ;


--27. ¿Qué películas se alquilan por encima del precio medio?

SELECT DISTINC f.title, p.amount  						-- Hacemos SELECT DISTINC para asegurarnos de que no se repite ningún valor
FROM film f 
INNER JOIN inventory i ON f.film_id = i.film_id 
INNER JOIN rental r ON i.inventory_id = r.inventory_id 
INNER JOIN payment p ON r.rental_id  = p.rental_id
WHERE p.amount > ( 										--Nos aseguramos de que los resultados tengan el precio mayor al precio medio
	SELECT AVG(p.amount)
	FROM payment p 
);


--28. Muestra el id de los actores que hayan participado en más de 40 películas.

SELECT fa.actor_id  							
FROM film_actor fa 
GROUP BY fa.actor_id 
HAVING COUNT(fa.actor_id) > 40;



--29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.

SELECT i.film_id AS "ID Película", COUNT(i.film_id) AS "Inventario"
FROM inventory i 
INNER JOIN film f ON i.film_id = f.film_id 
GROUP BY i.film_id ;


--30. Obtener los actores y el número de películas en las que ha actuado.

SELECT a.actor_id AS "ID Actor" , CONCAT(a.first_name, ' ', a.last_name ) AS "Nombre Completo", COUNT(a.actor_id) AS "Total Apariciones"
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id 
GROUP BY a.actor_id, a.first_name, a.last_name ;


--31. Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.

SELECT f.title AS "Película", CONCAT(a.first_name, ' ', a.last_name ) AS "Nombre Completo Actor"
FROM film f 
LEFT JOIN film_actor fa ON f.film_id = fa.film_id 
INNER JOIN actor a ON fa.actor_id = a.actor_id 
ORDER BY f.title;


--32. Obtener todos los actores y mostrar las películas en las que han actuado, incluso si algunos actores no han actuado en ninguna película.

SELECT CONCAT(a.first_name, ' ', a.last_name ) AS "Nombre Completo Actor", f.title AS "Película"
FROM actor a 
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id 
INNER JOIN film f ON fa.film_id = f.film_id 
ORDER BY a.actor_id 


--33. Obtener todas las películas que tenemos y todos los registros de alquiler.

SELECT f.*, r.*
FROM film f 
full join inventory i ON i.film_id = f.film_id 
full join rental r  ON r.inventory_id = i.inventory_id;


--34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

SELECT CONCAT(c.first_name, ' ', c.last_name ) AS "Full Name", CONCAT(SUM(p.amount), '€') AS "Total"
FROM customer c 
INNER JOIN rental r ON r.customer_id = c.customer_id 
INNER JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY c.customer_id 
ORDER BY COUNT(p.amount) desc
LIMIT 5;


--35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.

SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name ) AS "Nombre Completo Actor"
FROM actor a 
WHERE a.first_name = 'JOHNNY';


--36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.

SELECT a.first_name  AS "Nombre", a.last_name AS "Apellido"
FROM actor a 


--37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

SELECT MAX(a.actor_id), MIN(a.actor_id)
FROM actor a 


--38. Cuenta cuántos actores hay en la tabla “actor”.

SELECT COUNT(a.actor_id)
FROM actor a;


--39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.

SELECT a.*
FROM actor a 
ORDER BY a.last_name asc;


--40. Selecciona las primeras 5 películas de la tabla “film”.

SELECT *
FROM film m 
LIMIT 5;


--41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?

SELECT a.first_name , COUNT(a.first_name) AS "Repeticiones"
FROM actor a 
GROUP BY a.first_name
ORDER BY COUNT(a.first_name) desc; 


--42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.

SELECT r.*, c.first_name AS "Nombre Cliente"
FROM  rental r 
INNER JOIN customer c  ON r.customer_id = c.customer_id;


--43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.

SELECT r.*, c.first_name AS "Nombre Cliente"
FROM  rental r 
RIGHT JOIN customer c  ON r.customer_id = c.customer_id;


--44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación.

/*RESPUESTA:
 * 
 *Esta consulta no aporta ningún valor porque debido a que con el cross origin combinamos cada row de una tabla con todas las rows de 
 *la tabla con la que se relaciona, se están combinando películas que poseen una sola categoría con datos de categorías que no tienen nada que 
 *ver, dando como resultado un cúmulo de datos sin sentido que no nos lleva a ninguna conclusión.*/

SELECT *
FROM film f
CROSS JOIN film_category fc 
CROSS JOIN category c ;


--45. Encuentra los actores que han participado en películas de la categoría 'Action'.

SELECT a.*
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
INNER JOIN film f ON fa.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE f.film_id in (											-- Obtenemos sólo las películas de Acción y a raíz de ello los actores de estas películas
	SELECT fc2.film_id 
	FROM film_category fc2 
	INNER JOIN category c2 ON fc2.category_id = c2.category_id
	WHERE c2."name" = 'Action'
);


--46. Encuentra todos los actores que no han participado en películas.

SELECT a.*
FROM  actor a 
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id 
WHERE fa.film_id is null;


--47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.

SELECT a.first_name AS "Nombre", COUNT(a.actor_id) AS "Total Actuaciones"
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
GROUP BY a.actor_id,a.first_name ;


--48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores y el número de películas en las que han participado.

CREATE VIEW actor_num_peliculas as
SELECT a.first_name AS "Nombre", COUNT(a.actor_id) AS "Total Actuaciones"
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
GROUP BY a.actor_id;

SELECT *
FROM actor_num_peliculas;

--49. Calcula el número total de alquileres realizados por cada cliente.

SELECT r.customer_id, COUNT(r.customer_id)
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id ;


--50. Calcula la duración total de las películas en la categoría 'Action'.

	SELECT SUM(f.length) AS "Duración Total"
	FROM film f 
	INNER JOIN film_category fc ON f.film_id = fc.film_id 
	INNER JOIN category c ON fc.category_id = c.category_id
	WHERE c."name" = 'Action';


--51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.

WITH cliente_rentas_temporal AS (
	SELECT r.customer_id, COUNT(r.customer_id)
	FROM rental r
	INNER JOIN customer c ON r.customer_id = c.customer_id
	GROUP BY r.customer_id 
)
SELECT *
FROM cliente_rentas_temporal;

--52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las películas que han sido alquiladas al menos 10 veces.

WITH peliculas_alquiladas AS (
	SELECT f.title  AS "Título Película"
	FROM film f 
	WHERE f.film_id in (
		SELECT i.film_id
		FROM film f 
		INNER JOIN inventory i ON f.film_id = i.film_id
		GROUP BY i.film_id 
		HAVING COUNT(i.film_id) > 10										 -- Resultados a hasta los 7 rentals 
	)
)
SELECT *
FROM peliculas_alquiladas;


--53. Encuentra el título de las películas que han sido alquiladas por el cliente con el nombre ‘Tammy Sanders’ y que 
--aún no se han devuelto. Ordena los resultados alfabéticamente por título de película.

SELECT f.title 
FROM customer c 
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE c.first_name = 'TAMMY' AND c.last_name = 'SANDERS' AND r.return_date is null;
  

--54. Encuentra los nombres de los actores que han actuado en al menos una película que pertenece a la categoría ‘Sci-Fi’.
-- Ordena los resultados alfabéticamente por apellido.

SELECT a.actor_id, a.first_name, a.last_name 
FROM category c 
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
WHERE c.name  = 'Sci-Fi'
ORDER BY a.last_name;



--55. Encuentra el nombre y apellido de los actores que han actuado en películas que se alquilaron después de que
-- la película ‘Spartacus Cheaper’ se alquilara por primera vez. Ordena los resultados alfabéticamente por apellido.

SELECT DISTINC a.actor_id , a.first_name , a.last_name 
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_date > (
    SELECT  r.rental_date  
    FROM rental r 
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    WHERE f.title = 'SPARTACUS CHEAPER'
    ORDER BY r.rental_date
    LIMIT 1
);



--56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.

SELECT DISTINC a.first_name, a.last_name 
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE a.actor_id not in (
	SELECT a.actor_id 
	FROM actor a 
	INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
	INNER JOIN film f ON fa.film_id = f.film_id
	INNER JOIN film_category fc ON f.film_id = fc.film_id
	INNER JOIN category c ON fc.category_id = c.category_id
	WHERE c."name" = 'Music'
);


--57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.

SELECT DISTINC f.title												
FROM film f 
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
WHERE EXTRACT(DAY FROM age(r.return_date , r.rental_date )) > 8
ORDER BY f.title;


--58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’.


SELECT f.title 
FROM film f 
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE c."name" = 'Animation';


--59. Encuentra los nombres de las películas que tienen la misma duración que la película con el título ‘Dancing Fever’. Ordena los resultados alfabéticamente por título de película.


SELECT f.title 
FROM film f
WHERE f.length in (
	SELECT f2.length 
	FROM film f2
	WHERE f2.title = 'DANCING FEVER'
)


--60. Encuentra los nombres de los clientes que han alquilado al menos 7 películas distintas. Ordena los resultados alfabéticamente por apellido.


SELECT c.first_name, COUNT(DISTINCT f.film_id) 
FROM customer c 
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id 
INNER JOIN film f ON i.film_id = f.film_id 
GROUP BY c.first_name
HAVING COUNT(c.customer_id) > 6 															-- Resultados visibles hasta las 2 películas distintas

 


--61. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.


SELECT c."name" AS "Categoría", COUNT(f.title) AS "Total"
FROM film f 
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY c."name" 
ORDER BY COUNT(f.title) desc


--62. Encuentra el número de películas por categoría estrenadas en 2006.

SELECT COUNT(f.film_id)
FROM film f 
WHERE f.release_year = 2006



--63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.


SELECT s.*, s2.*
FROM store s
CROSS JOIN staff s2 


--64. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y
-- apellido junto con la cantidad de películas alquiladas.

SELECT c.customer_id, c.first_name, c.last_name , COUNT(r.customer_id) AS "Total Alquileres"
FROM customer c 
LEFT JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id 





