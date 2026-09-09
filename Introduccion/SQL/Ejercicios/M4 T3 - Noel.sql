-- 1)Quin és el nom de l'empleat (o dels empleats) i la seva posició, amb el mínim any de contractació?
select nombre, posicion, año_contratacion
from empleados
where año_contratacion = 
(select min(año_contratacion)
from empleados);

-- 2) Mostra el nom de la categoria i el nom del llibre (o llibres), dels llibres amb l'any de publicació més recent de cada categoria.
select cat.nombre, cat.categoria_id, lib.titulo, lib.año_publicacion
from categorias as cat
join libros as lib on cat.categoria_id = lib.categoria_id
join 
(select categoria_id, max(año_publicacion) as año_publicacion
from libros
group by categoria_id) as sub 
on lib.año_publicacion = sub.año_publicacion and cat.categoria_id = sub.categoria_id;

-- 3) Mostra els llibres que tenen més còpies que la mitjana del nombre de còpies dels llibres de la seva categoria.
select titulo, categorias.nombre, cantidad_copias
from libros
join categorias on libros.categoria_id = categorias.categoria_id
join 
	(select avg(cantidad_copias) media_copias, categoria_id
	from libros
	group by categoria_id) as media
on media.categoria_id = categorias.categoria_id
where libros.cantidad_copias > media.media_copias
order by libros.titulo;

-- 4) quin és el nom del llibre i del seu autor, del llibre que té un import més gran en multes
-- (comptant la suma de totes les multes de cada llibre)?
select lib.titulo, au.nombre, sum(multas.importe) as multa_total
from multas
join prestamos as pres on multas.prestamo_id = pres.prestamo_id
join libros as lib on pres.libro_id = lib.libro_id
join autores as au on lib.autor_id = au.autor_id
group by lib.titulo, au.nombre
order by multa_total desc
limit 1;

select s_multas.titulo, au.nombre
from autores as au
join
	(select lib.titulo, lib.autor_id, sum(multas.importe) as multa_total
	from multas
	join prestamos as pres on multas.prestamo_id = pres.prestamo_id
	join libros as lib on pres.libro_id = lib.libro_id
	group by lib.titulo, lib.autor_id) as s_multas
on au.autor_id = s_multas.autor_id
group by s_multas.titulo, au.nombre, s_multas.multa_total
order by s_multas.multa_total desc
limit 1;

select lib.titulo, lib.autor_id, sum(multas.importe) as multa_total
	from multas
	join prestamos as pres on multas.prestamo_id = pres.prestamo_id
	join libros as lib on pres.libro_id = lib.libro_id
	group by lib.titulo, lib.autor_id;

