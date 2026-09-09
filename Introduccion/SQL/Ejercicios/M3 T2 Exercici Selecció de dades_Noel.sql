-- 1) Mostra totes les dades dels pacients que comencen per "Ad", de la taula "pacientes".
SELECT 
    *
FROM
    hospitales.pacientes
WHERE
    nombre LIKE 'ad%';

-- 2) De la consulta anterior, mostra les "edad" úniques.
SELECT DISTINCT
    edad,
    paciente_id,
    nombre,
    hospital_id,
    nacionalidad,
    numero_visitas,
    ingreso,
    numero_dias_ingreso
FROM
    hospitales.pacientes
WHERE
    nombre LIKE 'ad%';

-- 3) Mostra el "nombre", el camp "ingreso" i el "numero_dias_ingreso" dels pacients que tenen menys de 10 anys de "edad".
SELECT 
    nombre, ingreso, numero_dias_ingreso
FROM
    hospitales.pacientes
WHERE
    edad < 10

-- 4) Mostra els pacients dels "hospital_id" 3, 25, 78 i 155.
SELECT 
    *
FROM
    hospitales.pacientes
WHERE
    hospital_id IN (3 , 25, 78, 155);

-- 5) Mostra totes les dades dels hospitals que tenen entre 100 i 120 "num_camas".
SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    num_camas BETWEEN 100 AND 120;

-- 6) Mostra els noms dels hospitals que estan a Barcelona - Catalunya.
SELECT 
    nombre
FROM
    hospitales.hospitales
WHERE
    localidad = 'Barcelona';

SELECT 
    nombre
FROM
    hospitales.hospitales
WHERE
    provincia = 'Barcelona';

-- 7) Mostra els 3 hospitals amb més "indice_satisfaccion" del grup d'hospitals de Madrid i Andalusia.
SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    provincia = 'Madrid'
        OR comunidad_autonoma = 'Andalucia'
ORDER BY indice_satisfaccion DESC
LIMIT 3;

SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    comunidad_autonoma IN ('Comunidad de Madrid' , 'Andalucia')
ORDER BY indice_satisfaccion DESC
LIMIT 3;

SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    comunidad_autonoma = 'Comunidad de Madrid'
ORDER BY indice_satisfaccion DESC
LIMIT 3;

SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    comunidad_autonoma = 'Andalucia'
ORDER BY indice_satisfaccion DESC
LIMIT 3;

SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    provincia = 'Madrid'
ORDER BY indice_satisfaccion DESC
LIMIT 3;

-- 8) Mostra els hospitals que comencen per lletra "C" i terminen per lletra "a".
SELECT 
    *
FROM
    hospitales.hospitales
WHERE
    nombre LIKE 'C%' OR nombre LIKE '%a';

-- 9) Mostra les especialitats que són fixes.
SELECT 
    especialidad
FROM
    hospitales.especialidades
WHERE
    fija = 'S'
GROUP BY especialidad;
