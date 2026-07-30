-- 1.Mostra el nom del llibre i el nom de l'autor dels llibres que són d'abans del 1927.
select a.titulo, b.nombre, a.año_publicacion
from libros as a
inner join autores as b
	on a.autor_id = b.autor_id
where a.año_publicacion < 1927
order by a.titulo, a.año_publicacion;

-- 2.Sobre la pregunta anterior, quin és l'autor amb més llibres publicats abans de 1927?
select b.nombre, count(a.libro_id) as 'total de libros publicados'
from libros as a
inner join autores as b
	on a.autor_id = b.autor_id
where a.año_publicacion < 1927
group by b.nombre
order by 2 desc
limit 1;

-- 3.Mostra el nom dels llibres i la quantitat de vegades que han estat retornats amb retard. També s'ha de mostrar la mitjana dels dies de retard.
select a.titulo, count(b.libro_id) as 'cantidad prestamos con retraso', round(avg(dias_retraso),2) as 'media dias de retraso'
from libros as a
inner join prestamos as b
	on a.libro_id = b.libro_id
where b.dias_retraso > 0
group by a.titulo
order by 2 desc, 3 desc;

select count(prestamo_id), avg(dias_retraso)
from prestamos
where libro_id = 302;

-- 4.Mostra la quantitat d'usuaris que no han realitzat cap préstec.
select count(a.usuario_id) as 'quantitat usuarios sense préstec'
from usuarios as a
left join prestamos as b
	on a.usuario_id = b.usuario_id
where b.usuario_id is NULL;


-- 5.Mostra el nom dels 3 usuaris que han fet més préstecs.
select b.usuario_id, b.nombre, b.apellido, count(a.libro_id) as 'numero de prestamos'
from prestamos as a
inner join usuarios as b
	on a.usuario_id = b.usuario_id
group by a.usuario_id
order by 4 desc
limit 3;

-- 6.Mostra el nom i l'ID dels usuaris estrangers i que han hagut de pagar una multa per retard en la devolució del préstec superior a 10 euros.
select a.nombre, a.usuario_id
from usuarios as a
inner join prestamos as b
	on a.usuario_id = b.usuario_id
inner join multas as c
	on b.prestamo_id = c.prestamo_id
where a.nacionalidad = 'extranjera'
and importe > 10
and pagada = 1
group by a.usuario_id;


-- 7.Mostra l'autor nascut després de 1980 que ha generat més préstecs en usuaris espanyols. A més, només s'han de comptabilitzar els préstecs finalitzats (ok o amb retard).
select a.nombre, count(c.prestamo_id) as 'número de prestamos'
from 
autores as a
inner join libros as b
	on a.autor_id = b.autor_id
inner join prestamos as c
	on b.libro_id = c.libro_id
inner join usuarios as d
	on c.usuario_id = d.usuario_id
where a.año_nacimiento > 1980
	and d.nacionalidad = 'española'
	and c.estado_prestamo IN ('finalizado ok', 'finalizado con retraso')
    -- and c.estado_prestamo like '%finalizado%'
group by a.autor_id, a.nombre
order by 2 desc
limit 1;

-- 8.Quina és la categoria de llibres que més demanen en préstec les persones que tenen targeta de fidelitat?
select d.nombre, count(b.prestamo_id) as 'total prestamos'
from prestamos as b
inner join libros as a
	on b.libro_id = a.libro_id
inner join categorias as d
	on a.categoria_id = d.categoria_id
inner join usuarios as c
	on b.usuario_id = c.usuario_id
where c.tarjeta_fidelidad = 'Si'
group by d.categoria_id
order by 2 desc
limit 1;

