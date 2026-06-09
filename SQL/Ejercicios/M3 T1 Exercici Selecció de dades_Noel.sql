-- 1.Mostra totes les dades de la taula "pacientes".
select *
from pacientes;

-- 2.Mostra el "nombre", "comunidad_autonoma", "provincia" i "localidad" de la taula "hospitales".
select nombre, comunidad_autonoma, provincia, localidad
from hospitales;

-- 3.Mostra els noms dels hospitals i el seu "presupuesto_anual_millones" ordenats pel seu "indice_satisfaccion" de major a menor.
select nombre, presupuesto_anual_millones
from hospitales
order by indice_satisfaccion desc;

-- 4.Mostra el top10 dels hospitals de la consulta anterior.
select nombre, presupuesto_anual_millones
from hospitales
order by indice_satisfaccion desc
limit 10;
 
-- 5.Mostra quines són les "provincia" úniques que hi ha a la taula "hospitales".
select distinct provincia
from hospitales;

-- 6.Mostra totes les especialitats mèdiques que hi ha.
select distinct especialidad
from especialidades;
