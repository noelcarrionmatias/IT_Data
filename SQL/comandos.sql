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