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

-- 4.Mostra la quantitat d'usuaris que no han realitzat cap préstec.
select a.usuario_id as 'quantitat usuarios sense préstec'
from usuarios as a
left join prestamos as b
	on a.usuario_id = b.usuario_id
where b.usuario_id is NULL;

-- COMPROBAR
SELECT *
FROM prestamos
WHERE USUARIO_ID = 43;

-- 5.Mostra el nom dels 3 usuaris que han fet més préstecs.
select a.usuario_id, b.nombre, count(a.libro_id) as 'numero de prestamos'
from prestamos as a
inner join usuarios as b
	on a.usuario_id = b.usuario_id
group by a.usuario_id, b.nombre
order by 3 desc
limit 3;

-- 6.Mostra el nom i l'ID dels usuaris estrangers i que han hagut de pagar una multa per retard en la devolució del préstec superior a 10 euros.
select a.nombre, a.usuario_id, a.nacionalidad, sum(b.dias_retraso) as 'total dias retraso'
from usuarios as a
right join prestamos as b
	on a.usuario_id = b.usuario_id
where a.nacionalidad = 'extranjera'
and b.dias_retraso > 0
group by a.usuario_id;

-- comprobar 
select *
from prestamos
where usuario_id = 5;
select *
from usuarios
where usuario_id = 5;
-- 7.Mostra l'autor nascut després de 1980 que ha generat més préstecs en usuaris espanyols. A més, només s'han de comptabilitzar els préstecs finalitzats (ok o amb retard).
-- 8.Quina és la categoria de llibres que més demanen en préstec les persones que tenen targeta de fidelitat?