-- 1) Mostra la quantitat de pacients que hi ha a la taula "pacientes".
select count(paciente_id) as 'Total pacientes'
from hospitales.pacientes;

-- 2) Mostra la quantitat de pacients que té cada "hospital_id" de la taula "pacientes".
select h.nombre, p.hospital_id, count(distinct(paciente_id)) as 'Total pacientes por hospital'
from hospitales.pacientes as p
left join hospitales.hospitales as h
on p.hospital_id = h.hospital_id
group by p.hospital_id;

-- 3) Mostra el "numero_dias_ingreso" màxim de cada "hospital_id" de la taula "pacientes".
select p.hospital_id , max(numero_dias_ingreso) as 'Máximo días de ingreso por paciente'
from hospitales.pacientes as p
group by p.hospital_id;

-- 4) Mostra el "indice_satisfaccion" mig de cada comunitat autònoma i província de la taula "hospitals".
select comunidad_autonoma, round(avg(indice_satisfaccion),2) as 'Indice de satisfacción media'
from hospitales.hospitales
where indice_satisfaccion is not null
group by comunidad_autonoma;

select provincia, round(avg(indice_satisfaccion),2) as 'Indice de satisfacción media'
from hospitales.hospitales
where indice_satisfaccion is not null
group by provincia;

-- 5) Mostra el "num_camas" total de cada comunitat autònoma.
select comunidad_autonoma, sum(num_camas) as 'Total camas'
from hospitales.hospitales
group by comunidad_autonoma;

-- 6) Mostra el "porcentaje_ocupacion" més petit de cada província de cada comunitat autònoma.
select comunidad_autonoma, provincia, min(porcentaje_ocupacion) as 'Minimo en porcentaje de ocupación'
from hospitales.hospitales
group by provincia, comunidad_autonoma;

-- 7) Mostra quantes províncies i localitats té cada comunitat autònoma.
select comunidad_autonoma, count(distinct(provincia)) as 'Número de provincias', count(distinct(localidad)) as 'Número de localidades'
from hospitales.hospitales
group by comunidad_autonoma;

-- 8) Mostra les comunitats autònomes que tenen menys de 5 hospitals.
select comunidad_autonoma, count(hospital_id) as 'Nombre de hospitales'
from hospitales.hospitales
group by comunidad_autonoma
having count(hospital_id) < 5;

-- 9) Mostra la quantitat d'hospitals per "especialidad" i per "fija". És a dir, quants hospitals tenen una especialitat en funció de si és fixa o no.
select count(distinct(hospital_id)) as 'Número de hospitales con especialidad fija'
from hospitales.especialidades
where fija = 'S';


