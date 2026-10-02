-- 1. Mostra el nom dels hospitals i los pacients extranjers que hi ha a la localitat de Toledo.
select h.nombre as nombre_hospital, p.nombre as nombre_paciente
from hospitales.hospitales as h
join hospitales.pacientes as p on h.hospital_id = p.hospital_id
where p.nacionalidad = 'extranjera'
and h.localidad = 'Toledo';

-- 2. Mostra el nom dels hospitals i la quantitat d'especialitats que hi ha als hospitals de la consulta anterior.
select h.nombre_hospital, count(e.especialidad) as q_especialidades
from 
	(select h.hospital_id, h.nombre as nombre_hospital, p.nombre as nombre_paciente
	from hospitales.hospitales as h
	join hospitales.pacientes as p on h.hospital_id = p.hospital_id
	where p.nacionalidad = 'extranjera'
	and h.localidad = 'Toledo') as h
join hospitales.especialidades as e on h.hospital_id = e.hospital_id
group by h.nombre_hospital;

-- 3. Mostra el nom de l’hospital i les especialitats que té l’hospital amb identificador 105.
select h.nombre, e.especialidad
from hospitales.hospitales as h
join hospitales.especialidades as e on h.hospital_id = e.hospital_id
where h.hospital_id = 105;

-- 4. Digues quants hospitals tenen dades a la taula "hospitales", però no tenen dades a la taula de "pacientes".
select count(distinct(h.nombre)) as n_hospitales
from hospitales.hospitales as h
left join hospitales.pacientes as p on h.hospital_id = p.hospital_id
where p.hospital_id is null;

-- 5. Mostra el nom de l'hospital que té menys especialitats fixes.
select h.nombre, h.hospital_id, count(e.fija) as total_especialitats_fixes
from hospitales.hospitales as h
join hospitales.especialidades as e on h.hospital_id = e.hospital_id
where e.fija = 'S'
group by h.nombre, h.hospital_id
order by 3 asc
limit 1;

-- Solució dinàmica usant subqueries
SELECT h.nombre, COUNT(*) AS num_especialidades
FROM hospitales h INNER JOIN especialidades e ON h.hospital_id = e.hospital_id
where e.fija = "S"
GROUP BY h.nombre
HAVING COUNT(*)
= (
		select count(*)
		from especialidades e 
		where e.fija = "S"
		group by e.hospital_id
		order by count(*)
		limit 1
		);
-- 6. Mostra el nom i el nombre total de visites de l'hospital amb identificador 45.
select h.nombre, sum(p.numero_visitas) as total_visites
from hospitales as h
join pacientes as p on h.hospital_id = p.hospital_id
where h.hospital_id = 45
group by h.nombre;

-- 7. Mostra el nom de l'hospital, el nom dels seus pacients estrangers i el nombre de visites, així com les especialitats que NO són fixes. Totes aquestes dades de l'hospital amb identificador 45.
select h.nombre as nombre_hospital, p.nombre as nombre_paciente, sum(p.numero_visitas) as total_visitas, count(e.especialidad) as total_especialidades_no_fijas
from hospitales as h
join pacientes as p on h.hospital_id = p.hospital_id
join especialidades as e on h.hospital_id = e.hospital_id
where p.nacionalidad = 'extranjera'
and e.fija = 'N'
and h.hospital_id = 45
group by h.nombre, p.nombre;

-- 8. Suma el "numero_visitas" de la consulta anterior (a mà) i compara-la amb el "numero_visitas" de la consulta núm. 6. Són iguals? Què està passant?
