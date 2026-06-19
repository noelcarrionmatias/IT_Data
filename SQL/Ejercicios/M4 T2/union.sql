-- Paso 1: Crear base de datos
create database base_de_datos_para_UNION;

-- Paso 2: Usar la nueva base de datos
USE base_de_datos_para_UNION;

-- Paso 3: Crear las tablas
create table nens (
	nom VARCHAR(100),
    vegades int
    );
    
create table nenes (
	nom VARCHAR(100),
    vegades int
    );
    
-- Paso 4: Ejercicio M4 T2 
-- 2) Haz una "union" de las dos tablas.
SELECT * 
FROM nens
UNION 
SELECT * 
FROM nenes;
-- 3) Fes una "union all" de les mateixes taules i explica les diferències.
select *
from nens
union all
select *
from nenes;