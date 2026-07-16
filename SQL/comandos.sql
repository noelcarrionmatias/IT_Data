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

------------------
-- PARTITION BY
------------------
-- Calcula lo que le indiques a partir de la agrupación de la particion (partition by 'district')
select *
from (
    select city, district, neighborhood, ROUND(AVG(price_€/size_m2), 2) AS avg_price_m2,
        ROW_NUMBER() OVER (	
			PARTITION BY district
            ORDER BY AVG(price_€/size_m2) DESC
        ) AS rank_num
    FROM housing_data
    WHERE (district IS NOT NULL or city = 'sant adria de besos')
      AND neighborhood IS NOT NULL
    GROUP BY city, district, neighborhood
) t
WHERE rank_num <= 3
ORDER BY district, rank_num;


------------------
-- ROW_NUMBER() OVER ()
------------------
-- ROW_NUMBER() indica 1, 2, 3 según cuenta filas y OVER() indica sobre el qué tiene que contar
select *
from (
    select city, district, neighborhood, ROUND(AVG(price_€/size_m2), 2) AS avg_price_m2,
        ROW_NUMBER() OVER (	
			PARTITION BY district
            ORDER BY AVG(price_€/size_m2) DESC
        ) AS rank_num
    FROM housing_data
    WHERE (district IS NOT NULL or city = 'sant adria de besos')
      AND neighborhood IS NOT NULL
    GROUP BY city, district, neighborhood
) t
WHERE rank_num <= 3
ORDER BY district, rank_num;