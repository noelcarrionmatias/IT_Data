------------------
-- distinc
------------------
select distinc col_1
from tabla;

------------------
-- limit
------------------
select *
from tabla
limit number;

------------------
-- join (full, inner, left, right)
------------------
select a.*, b.*
from tabla1 as a
full, inner, left, right join tabla2 as b 
on a.id = b.id;

------------------
-- union / union all
------------------
SELECT column_name(s) FROM table1
UNION
SELECT column_name(s) FROM table2;

-- UNION -> junta por columna sin duplicados
-- UNION ALL -> junta por columna CON duplicados

-- Ejemplo
-- union (11 filas nens + 11 filas nenes = 21 filas) (hay un repetido en nens)
SELECT * 
FROM nens
UNION 
SELECT * 
FROM nenes;
-- union all (11 filas nens + 11 filas nenes = 21 filas) (copia el repetido en nens)
select *
from nens
union all
select *
from nenes;

-- Tambien con condiciones
SELECT City, Country FROM Customers
WHERE Country='Germany'
UNION
SELECT City, Country FROM Suppliers
WHERE Country='Germany'
ORDER BY City;

------------------
-- sum/max/min/avg
------------------
select sum/max/min/avg(col_1)
from tabla;

------------------
-- Having
------------------
select country, count(customer_id) as number_customer
from tabla
group by country
having count(customer_id) > 5;

------------------
-- CASE
------------------
SELECT ProductName, Price,
CASE
  WHEN Price < 20 THEN 'Low Cost'
  WHEN Price BETWEEN 20 AND 50 THEN 'Medium Cost'
  ELSE 'High Cost'
END AS PriceCategory
FROM Products;