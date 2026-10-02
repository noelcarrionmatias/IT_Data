# NIVEL 1: ENTORNO E INGESTA HIBRIDA (CODE-FIRST)
# EJERCICIO 1: CONSULTA SOBRE TABLA NO OPTIMIZADA (DIAGNOSTICO)

SELECT t.*, c.company_name
FROM sprint3_silver.transaction_clean as t
JOIN sprint3_silver.companies_clean as c
ON t.business_id = c.company_id
WHERE date(t.timestamp) = '2022-03-12'
AND c.country = 'Germany';

# EJERCICIO 2: REARQUITECTURA Y OPTIMIZACION DEL ALMACENAMIENTO (PARTITION Y CLUSTER)

# PASO 1:
CREATE OR REPLACE TABLE sprint3_silver.transactions_recent AS
SELECT * EXCEPT(timestamp), timestamp_sub(current_timestamp(), INTERVAL CAST(RAND() * 50 AS INT64) DAY) AS timestamp
FROM sprint3_silver.transaction_clean;

# PASO 2:
CREATE OR REPLACE TABLE sprint3_gold.fact_transactions_optimized
PARTITION BY
  DATE(timestamp)
CLUSTER BY
  business_id
AS (
SELECT *
FROM sprint3_silver.transactions_recent
);


# EJERCICIO 3: LA PRUEBA DE ALGODÓN (BENCHMARK)

SELECT *
FROM `sprint3_silver.transactions_recent`
WHERE DATE(timestamp) > CURRENT_DATE()-30;

SELECT *
FROM sprint3_gold.fact_transactions_optimized
WHERE DATE(timestamp) >= CURRENT_DATE()-30;

# EJERCICIO 4: SMART CACHING (Vistas Materializadas)

CREATE OR REPLACE MATERIALIZED VIEW sprint3_gold.mv_daily_sales AS (
SELECT date(timestamp) AS fecha, sum(amount) AS total_ingresos
FROM sprint3_silver.transaction_clean
WHERE declined = 0
GROUP BY fecha
);

SELECT *
FROM sprint3_gold.mv_daily_sales;


# NIVEL 2: SQL ANALITICO AVANZADO
# EJERCICIO 1: Perfilado de clientes VIP (metricas agregadas con CTEs)

WITH VIP_Stats AS (
  SELECT u.user_id, 
  round(sum(t.amount),2) as gasto_total,
  count(t.transaction_id) as n_transacciones,
  round(avg(t.amount), 2) as media_gasto,
  max(t.amount) as gasto_max
  FROM `sprint3_silver.users_combined` as u
  JOIN sprint3_silver.transaction_clean as t
  ON u.user_id = t.user_id
  WHERE declined = 0 
  GROUP BY u.user_id
  HAVING sum(t.amount) > 500)

SELECT
u.user_id, concat(u.name," ",u.surname) as nombre_completo, u.email, v.n_transacciones as num_compras, v.media_gasto, v.gasto_max, v.gasto_total
FROM `sprint3_silver.users_combined` as u
JOIN VIP_Stats as v
ON u.user_id = v.user_id
ORDER BY v.gasto_total DESC;


# EJERCICIO 2: Analisis de Tendencias (Windows Functions sobre Vistas)


SELECT 
mv.fecha,
mv.total_ingresos as ventas_hoy,
LAG(mv.total_ingresos) OVER (ORDER BY mv.fecha) as ventas_ayer,
ROUND((SAFE_DIVIDE(
  mv.total_ingresos - LAG(mv.total_ingresos, 1) OVER (ORDER BY mv.fecha), 
  ((mv.total_ingresos + LAG(mv.total_ingresos) OVER (ORDER BY mv.fecha))/2)
) * 100),2) AS diferencia_porcentual
FROM `sprint3_gold.mv_daily_sales` as mv
ORDER BY fecha ASC;

# EJERCICIO 3: Totales acumulados (Running totales sobre vistas)

SELECT
fecha,
total_ingresos,
ROUND(SUM(total_ingresos) OVER (
  PARTITION BY EXTRACT(YEAR FROM fecha) 
  ORDER BY fecha ASC
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
), 2) AS acumulado_anual
FROM `sprint3_gold.mv_daily_sales`;

# EJERCICIO 4: Fidelización y valor del cliente (Filtrado avanzado)

SELECT 
u.user_id, 
concat(u.name, " ", u.surname) as nombre_completo, 
u.email,
ROUND(AVG(t.amount) OVER (PARTITION BY u.user_id ORDER BY date(t.timestamp) ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2)as media_primeras_compras,
timestamp as fecha_3_compra,
amount as valor_3_compra
FROM sprint3_silver.users_combined as u
JOIN `sprint3_gold.fact_transactions_optimized` as t
ON u.user_id = t.user_id
WHERE t.declined = 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY date(t.timestamp) ASC) = 3;

# NIVEL 3: Analytics Engineering (Arrays & Automatización)
# EJERCICIO 1: Desanidamiento y aplanado de datos (Unnesting)

CREATE OR REPLACE TABLE sprint3_gold.dim_transactions_flat AS
WITH selection AS (
  SELECT transaction_id, timestamp, array_product_ids, amount
  FROM sprint3_silver.transaction_clean
)

SELECT s.transaction_id, s.timestamp, s.amount as total_ticket, product_id, p.name, p.price as product_price
FROM selection as s
CROSS JOIN UNNEST(s.array_product_ids) AS product_id
JOIN sprint3_silver.products_clean as p
ON product_id = p.products_id
ORDER By s.transaction_id;

# EJERCICIO 2: Ránquing de ventas (agregación simple)

SELECT name, count(*) as n_ventas
FROM `sprint3_gold.dim_transactions_flat`
GROUP BY name
ORDER BY n_ventas DESC
LIMIT 5;

# EJERCICIO 3: Automatización del Pipeline y Visualización

CREATE OR REPLACE FUNCTION sprint3_gold.calculate_tax(amount FLOAT64)
RETURNS FLOAT64 AS (amount * 1.21);

CREATE OR REPLACE TABLE sprint3_gold.dim_transactions_flat AS (
WITH selection AS (
  SELECT transaction_id, timestamp, array_product_ids, amount
  FROM sprint3_silver.transaction_clean
)

SELECT s.transaction_id, s.timestamp, s.amount as total_ticket, product_id, p.name, p.price as product_price, sprint3_gold.calculate_tax(p.price) as product_price_tax_inc
FROM selection as s
CROSS JOIN UNNEST(s.array_product_ids) AS product_id
JOIN sprint3_silver.products_clean as p
ON product_id = p.products_id
ORDER By s.transaction_id);
