# NIVEL 1: ENTORNO E INGESTA HÍBRIDA (CODE-FIRST)
# EJERCICIO 1: CREAR DATASET sprint3_silver con codigo SQL:
CREATE SCHEMA IF NOT EXISTS sprint3_silver
OPTIONS (location='EU');

# EJERCICIO 2: CREACIÓN DE TABLAS CON CREATE OR REPLACE EXTERNAL TABLE:

# TRANSACTIONS_RAW
CREATE OR REPLACE EXTERNAL TABLE `sprint3_bronze.transactions_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
  field_delimiter = ';'
);

# EJERCICIO 4: ARQUITECTURA Y RENDIMIENTO. MATERIALIZACIÓN DE DATOS (ASISTIDO POR IA).
CREATE OR REPLACE TABLE `sprint3-analytics-noelcarrion.sprint3_bronze.transactions_raw_native` AS
SELECT
  *
FROM
  `sprint3-analytics-noelcarrion.sprint3_bronze.transactions_raw`;

SELECT id
FROM `sprint3_bronze.transactions_raw`
LIMIT 10;

SELECT id
FROM `sprint3_bronze.transactions_raw_native`
LIMIT 10;

# EJERCICIO 5: ADAPTACIÓN DE SINTAXI (REPORTING)
# El campo timestamp ya era formato timestamp. Solo he tenido que obtener la fecha (y no fecha+hora) para poder filtrar por los 5 dias.
SELECT date(timestamp) AS fecha, round(sum(amount),2) AS total_ingresos
FROM sprint3_bronze.transactions_raw_native
WHERE EXTRACT(YEAR FROM date(timestamp)) = 2021
GROUP BY date(timestamp)
ORDER BY 2 DESC
LIMIT 5;

# EJERCICIO 6: CONSULTAS COMPLEJAS
# Llista el nom, país i data de les transaccions realitzades per empreses que van fer operacions entre 100 i 200 euros en alguna d'aquestes dates: 29-04-2015, 20-07-2018 o 13-03-2024.
SELECT c.company_name, c.country, date(t.timestamp) AS fecha
FROM `sprint3_bronze.transactions_raw_native` as t
JOIN `sprint3-analytics-noelcarrion.sprint3_bronze.companies_raw` as c
ON t.business_id = c.company_id
WHERE t.amount BETWEEN 100 AND 200
AND date(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY company_name, fecha;

# NIVEL 2: LIMPIEZA Y TRANSFORMACION (ETL)
# EJERCICIO 1: LIMPIEZA DE PRODUCTOS (DATA QUALITY)

# Crear products_clean en sprint3_silver.
# Estandarización de nombres (id → product_id; product_name → name)
# Limpieza de ID: En warehouse eliminar el prefijo “WH-” y cambiarlo a entero (INT64)
# Garantia de precio: price FLOAT64 (ya lo era)
# Otras columnas: weight conservarlo

CREATE OR REPLACE TABLE `sprint3_silver.products_clean` AS 
SELECT 
id AS products_id,
product_name AS name,
price, # Ya tiene formato FLOAT
colour,
weight,
SAFE_CAST(REPLACE(warehouse_id, "WH-", "") AS INT64) AS warehouse_id, # No es posible cambiar de tipo de dato con un ALTER TABLE. El SAFE_CAST guarda el valor como un INT64 una vez reemplazado "WH-".
category,
brand,
cost,
launch_date,
FROM `sprint3-analytics-noelcarrion.sprint3_bronze.products_raw`;

# EJERCICIO 2: CREACIÓN DE TRANSACCIONES LIMPIA (CAPA SILVER)

# Estandarización de nombres: id → transaction_id
# Robustez de imports: SAFE_CAST en amount. Si falla que sea 0 (con IFNULL)
# Fechas reales: conviernte timestamp (string) a timestap real (ya viene con ese tipo de dato)
# Coordenadas: lat y longitude FLOAT64 (SAFE_CAST)
# Desglose de productos: transforma la cadena de texto “product_id” en un ARRAY de enteros

CREATE OR REPLACE TABLE sprint3_silver.transaction_clean AS 
SELECT
id AS transaction_id,
card_id,
business_id,
timestamp, # Ya tiene formato TIMESTAMP
SAFE_CAST(amount AS FLOAT64) AS amount, # Ya tiene formato FLOAT y no tiene nulos Tampoco tienen signo de monedas 
declined,
ARRAY(
  SELECT SAFE_CAST(x AS INT64)
  FROM UNNEST(
    SPLIT(product_ids, ',')) AS x) AS array_product_ids,
user_id,
lat,
longitude
FROM `sprint3_bronze.transactions_raw_native`;

# EJERCICIO 3: UNIFICACIÓN DE USUARIOS (UNION)

# Crear users_combined en sprint3_silver a partir de european_users y american_users.
# Añadir una columna indicando la región original (europa o america)
# Renombrar columna: id → user_id
    
CREATE OR REPLACE TABLE sprint3_silver.users_combined AS (
SELECT *,
CASE
WHEN TRUE THEN 'europa'
END AS region
FROM `sprint3_bronze.european_users_raw`
UNION ALL
SELECT *,
CASE
WHEN TRUE THEN 'america'
END AS region
FROM `sprint3_bronze.american_users_raw`);

ALTER TABLE sprint3_silver.users_combined RENAME COLUMN id TO user_id;

# EJERCICIO 4: MATERIALIZACIÓN DE COMPAÑIAS Y TARJETAS DE CREDITO

# Importar los CSV de companies y credit_cards
# companies_clean y credit_cards_clean (NATIVA)
# Renombrar campo id si es necesario.
# tabla credit_cards

ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_0 TO company_id;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_1 TO company_name;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_2 TO phone;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_3 TO email;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_4 TO country;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_5 TO website;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_6 TO merchan_category;
ALTER TABLE sprint3_silver.companies_clean RENAME COLUMN string_field_7 TO merchan_price_position;

ALTER TABLE sprint3_silver.credit_cards_clean RENAME COLUMN id TO card_id;

# NIVEL 3: PRESENTACIÓN DE DATOS Y CREACIÓN DE VISTAS
# EJERCICIO 1: LA VISTA DE MARQUETING (LÒGICA DE NEGOCIOS)

# Crea una vista sprint3_gold.v_marketing_kpis que muestre:
# Nombre de la compaía, telefono y pais (origen: companies_clean)
# Meda de compra (avg(amount)) de transactions_clean.
# Clasificación de cliente (lógica):
# - Si la media de compra es superior a 260€ es "Premium"
# - Si es igual o inferior es "Standard"

CREATE OR REPLACE VIEW sprint3_gold.v_marketing_kpis AS (
SELECT c.company_name, c.phone, c.country, round(avg(t.amount),2) as media_compra,
  CASE
    WHEN avg(t.amount) > 260 THEN "Premium"
    ELSE "Standard"
  END AS client_tier
  FROM sprint3_silver.companies_clean AS c
  JOIN `sprint3_silver.transaction_clean` AS t
  ON c.company_id = t.business_id
  WHERE t.declined = 0 # Se contempla una compra como una transaccion NO rechazada.
  GROUP BY c.company_name,  c.phone, c.country);

SELECT *
FROM sprint3_gold.v_marketing_kpis
ORDER BY client_tier, media_compra DESC;

# EJERCICIO 2: RANQUING DE PRODUCTOS (LA POTENCIA DE LOS ARRAYS)
# Crea "sprint3_gold.product_sales_ranking" que tenga el inventario completo de productos y nº veces se han vendido.
# Requisitos:
# Detalle del producto: incluir product_id, name, price y color (tabla products_clean)
# Metrica de negocio: columna nueva "total_sold" que cuente nº veces que aparece el prodcuto en transacciones
# Integridad: Han de aparecer todos los productos, incluidos los que no se han vendido"

CREATE OR REPLACE TABLE sprint3_gold.product_sales_ranking AS

WITH n_ventas AS (
  SELECT
  product_id,
  COUNT(*) AS total_sold
  FROM sprint3_silver.transaction_clean t
  JOIN UNNEST(t.array_product_ids) AS product_id
  WHERE t.declined = 0
  GROUP BY product_id
)

SELECT
p.products_id,
p.name,
p.price,
p.colour,
v.total_sold
FROM sprint3_silver.products_clean p
LEFT JOIN n_ventas v
ON p.products_id = v.product_id;


