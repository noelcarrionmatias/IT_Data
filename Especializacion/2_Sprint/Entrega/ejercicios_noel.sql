------------------------------------------------
--- NIVEL 1
------------------------------------------------
USE transactions;

-------------------------------------------------
-- EJERCICIOS 2
-------------------------------------------------

--- Llistat dels països que estan generant vendes.
SELECT distinct(c.country) as "paises_vendas"
FROM company as c
JOIN transaction as t on c.id = t.company_id
WHERE t.amount > 0
GROUP BY c.country
ORDER BY c.country;

--- Des de quants països es generen les vendes.
SELECT count(distinct(c.country)) as "n_paises"
FROM company as c
JOIN transaction as t on c.id = t.company_id
WHERE t.amount > 0
ORDER BY c.country;

--- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name, avg(amount) as "media_ventas"
FROM company as c
JOIN transaction as t on c.id = t.company_id
WHERE t.amount > 0
GROUP BY c.company_name
ORDER BY media_ventas desc;

-------------------------------------------------
--- EJERCICIOS 3
--- Utilitzant només subconsultes (sense utilitzar JOIN):
-------------------------------------------------

--- Mostra totes les transaccions realitzades per empreses dAlemanya.
select subq1.*
from (
	SELECT t.*, c.country
	FROM company as c,
    transaction as t
    WHERE c.id = t.company_id) as subq1
WHERE country = "Germany";

--- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT distinct(c.company_name) as "company_name"
FROM company as c,
transaction as t
WHERE c.id = t.company_id
and t.amount > 
	(SELECT avg(t.amount)
	FROM transaction as t);
    
--- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat daquestes empreses.
SELECT distinct(c.company_name), c.id
FROM company as c,
transaction as t
WHERE c.id <> t.company_id;

-------------------------------------------------
--- EJERCICIOS 4
--- La teva tasca és dissenyar i crear una taula anomenada credit_card que emmagatzemi detalls crucials sobre les targetes de crèdit. 
--- La nova taula ha de ser capaç didentificar de manera única cada targeta i 
--- establir una relació adequada amb les altres dues taules (transaction i company). 

--- Després de crear la taula serà necessari que ingressis la informació del document denominat dades_introduir_credict. 
--- Recorda mostrar el diagrama i realitzar una breu descripció daquest.:
-------------------------------------------------
DROP TABLE IF EXISTS credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    expiring_date VARCHAR(15));
    
--- SUBIR DATOS A CREDIT CARD ANTES DE ACTUALIZAR EL TIPO DE DATO

SET SQL_SAFE_UPDATES = 0; --- quitar la protección para modificar el campo expiring_date a formato fecha
UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE id IS NOT NULL;

ALTER TABLE credit_card
MODIFY COLUMN expiring_date DATE;
SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE transaction ADD CONSTRAINT transaction_idfk FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-------------------------------------------------
--- EJERCICIOS 6
--- En la taula transaction ingressa una nova transacció amb la següent informació:
-------------------------------------------------
INSERT INTO transactions.company (id, company_name, phone, email, country, website)
VALUES ('b-9999', "Test Empresa", "123456789", "test_empresa@test.com", "España", "test_empresa.com");
INSERT INTO transactions.credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', 'XX0000000000000000000000', '0000000000000000', '0123', '123', '2026-09-08');
INSERT INTO transactions.transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, null, 111.11, 0);  
SELECT *
FROM transactions.transaction
WHERE company_id = 'b-9999';

-------------------------------------------------
--- Exercici 7
--- Des de recursos humans et sol·liciten eliminar la columna pan de la taula credit_card. Recorda mostrar el canvi realitzat.
-------------------------------------------------
SELECT *
FROM credit_card
LIMIT 10;
ALTER TABLE credit_card DROP COLUMN pan;
SELECT *
FROM credit_card
LIMIT 10;

-------------------------------------------------
--- Exercici 8
--- Descarrega els arxius CSV que trobaràs a lapartat de recursos:
--- american_users.csv
--- european_users.csv
--- companies.csv
--- credit_cards.csv
--- transactions.csv
--- Estudials i dissenya una base de dades amb un esquema destrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
--- La taula de products.csv lutilitzarem més endavant.
-------------------------------------------------
--- USAR OTRO ESQUEMA
CREATE SCHEMA IF NOT EXISTS business_analitycs;
USE business_analitycs;
--- Modificar la conexión para poder cargar datos csv (subida bloqueada)
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = ON;

--- Crear las tablas:
DROP TABLE IF EXISTS american_users;
CREATE TABLE IF NOT EXISTS american_users (
id INT, 
name VARCHAR(50),
surname VARCHAR(50),
phone VARCHAR(50), 
email VARCHAR(50),
birth_date VARCHAR(25),
country VARCHAR(25),
city VARCHAR(25),
postal_code VARCHAR(25),
address VARCHAR(50),
signup_date DATE,
user_segment VARCHAR(50),
income_band VARCHAR(25));

--- Cargar la primera tabla (americans_user.csv):
LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__american_users.csv"
INTO TABLE american_users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

--- Comprobación
SELECT *
FROM american_users;

--- Resto de tablas y su carga
--- european_users
DROP TABLE IF EXISTS european_users;
CREATE TABLE IF NOT EXISTS european_users (
id INT, 
name VARCHAR(50),
surname VARCHAR(50),
phone VARCHAR(50), 
email VARCHAR(50),
birth_date VARCHAR(25),
country VARCHAR(25),
city VARCHAR(25),
postal_code VARCHAR(25),
address VARCHAR(50),
signup_date DATE,
user_segment VARCHAR(50),
income_band VARCHAR(25));

LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__european_users.csv"
INTO TABLE european_users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM european_users;

DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users AS 
SELECT * FROM american_users
UNION
SELECT * FROM european_users;

DROP TABLE IF EXISTS american_users;
DROP TABLE IF EXISTS european_users;


SET SQL_SAFE_UPDATES = 0; --- quitar la protección para modificar el campo expiring_date a formato fecha
UPDATE users
SET birth_date = DATE_FORMAT(
    STR_TO_DATE(birth_date, '%b %d, %Y'),
    '%Y-%m-%d')
WHERE id IS NOT NULL;

ALTER TABLE users
MODIFY COLUMN birth_date DATE;
SET FOREIGN_KEY_CHECKS = 1;

--- companies
DROP TABLE IF EXISTS companies;
CREATE TABLE IF NOT EXISTS companies (
company_id VARCHAR(6),
company_name VARCHAR(50),
phone VARCHAR(25),
email VARCHAR(50),
country VARCHAR(25),
website VARCHAR(50),
merchant_category VARCHAR(25),
merchant_price_position VARCHAR(25));

LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__companies.csv"
INTO TABLE companies 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM companies;

--- credit_cards
DROP TABLE IF EXISTS credit_cards;
CREATE TABLE IF NOT EXISTS credit_cards (
id VARCHAR(8),
user_id INT,
iban VARCHAR(50),
pan VARCHAR(255),
pin INT,
cvv INT,
track1 VARCHAR(100),
track2 VARCHAR(100),
expiring_date VARCHAR(25),
card_type VARCHAR(25),
card_renewal_flag BOOLEAN);

LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

SET SQL_SAFE_UPDATES = 0; --- quitar la protección para modificar el campo expiring_date a formato fecha
UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE id IS NOT NULL;

ALTER TABLE credit_cards
MODIFY COLUMN expiring_date DATE;
SET FOREIGN_KEY_CHECKS = 1;

SELECT *
FROM credit_cards;

--- transactions
DROP TABLE IF EXISTS transactions;
CREATE TABLE IF NOT EXISTS transactions (
id VARCHAR(255),
card_id VARCHAR(8),
company_id VARCHAR(6),
timestamp TIMESTAMP,
amount DECIMAL(10, 2),
declined BOOLEAN,
product_ids VARCHAR(25),
user_id INT,
lat FLOAT,
longitude FLOAT,
discount_amount DECIMAL(10, 2),
tax_amount DECIMAL(10, 2),
shipping_amount DECIMAL(10, 2),
channel VARCHAR(25),
campaign_id VARCHAR(25),
device_type VARCHAR(25),
is_international BOOLEAN,
decline_reason VARCHAR(25) NULL,
distance_km DECIMAL(10, 2));

LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT *
FROM transactions;

--- Relacion de tablas
--- PK:
ALTER TABLE users ADD CONSTRAINT pk_users_id PRIMARY KEY (id);
ALTER TABLE companies ADD CONSTRAINT pk_companies_id PRIMARY KEY (company_id); --- ERROR
ALTER TABLE credit_cards ADD CONSTRAINT pk_credit_cards_id PRIMARY KEY (id);
ALTER TABLE transactions ADD CONSTRAINT pk_transactions_id PRIMARY KEY (id);

--- FK:
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_cardid FOREIGN KEY (card_id) REFERENCES credit_cards(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_userid FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_companyid FOREIGN KEY (company_id) REFERENCES companies(company_id);

-------------------------------------------------
--- EJERCICIOS 9
--- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
-------------------------------------------------
SELECT u.*, subq.n_transactions
FROM users as u
INNER JOIN
	(SELECT user_id, count(id) as 'n_transactions'
	FROM transactions
	GROUP BY user_id) as subq
ON u.id = subq.user_id
WHERE subq.n_transactions > 80; 
-------------------------------------------------
--- EJERCICIOS 10
--- Mostra la mitjana d amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
-------------------------------------------------
SELECT cc.iban, avg(t.amount) as 'media_amount', count(t.id) as 'n_transactions', c.company_name
FROM credit_cards as cc
JOIN transactions as t
ON cc.id = t.card_id
JOIN companies as c
ON t.company_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;


------------------------------------------------
--- NIVEL 2
------------------------------------------------
-------------------------------------------------
--- EJERCICIOS 1
--- Identifica els cinc dies que es va generar la quantitat més gran d ingressos a l empresa per vendes. 
--- Mostra la data de cada transacció juntament amb el total de les vendes.
-------------------------------------------------
--- Hay que cambiar el formato de la columna timestamp de la tabla transactions para quitar la hora (solo nos interesa la fecha exacta). 
--- He optado por crear una columna fecha y otra hora para no perder información y poder filtrar mejor.
ALTER TABLE transactions ADD COLUMN fecha date;
UPDATE transactions
SET fecha = DATE(timestamp);
ALTER TABLE transactions ADD COLUMN hora time;
UPDATE transactions
SET hora = TIME(timestamp);
ALTER TABLE transactions DROP COLUMN timestamp;

--- También tener en cuenta el descuento (discount_amount). Las tasas (tax_amount) no se tendrían en cuenta al ser un impuesto que no se queda la empresa, sino el estado.
SELECT c.company_name, sub1.fecha, sub1.total_amount, sub1.puesto
FROM companies as c
JOIN
	(SELECT t.fecha, (sum(t.amount)-sum(t.discount_amount)) as 'total_amount', c.company_id,
	ROW_NUMBER() OVER (PARTITION BY c.company_name ORDER BY (sum(t.amount)-sum(t.discount_amount)) DESC) AS puesto
	FROM transactions as t
	JOIN companies as c
	ON t.company_id = c.company_id
	GROUP BY t.fecha,c.company_id
	ORDER BY c.company_id, puesto) as sub1
ON c.company_id = sub1.company_id
WHERE puesto <= 5
ORDER BY c.company_name, sub1.puesto;

-------------------------------------------------
--- EJERCICIO 2
--- Presenta el nom, telèfon, país, data i amount, d aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros
--- i en alguna daquestes dates: 29 d abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
--- Ordena els resultats de major a menor quantitat.
-------------------------------------------------
SELECT c.company_name, c.phone, c.country, t.fecha, t.amount
FROM companies as c
JOIN transactions as t
ON c.company_id = t.company_id
WHERE t.fecha IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

-------------------------------------------------
--- EJERCICIO 3
--- Necessitem optimitzar l assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
--- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
--- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si 
--- tenen igual o més de 400 transaccions o menys.
-------------------------------------------------
SELECT c.company_name,
CASE
	WHEN count(t.id) >= 400 THEN 'Igual o más de 400 transacciones'
    ELSE 'Menos de 400'
END as 'total_transactions'
FROM companies as c
JOIN transactions as t
ON c.company_id = t.company_id
GROUP BY c.company_name
ORDER BY c.company_name;

-------------------------------------------------
--- EJERCICIO 4
--- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
-------------------------------------------------
--- Compruebo cuantos valores tiene la tabla transactions (10000) antes del borrado para comprobar que se ha borrado correctamente. Después del borrado hay 9999.
SELECT count(*)
FROM transactions;
DELETE FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-------------------------------------------------
--- EJERCICIO 5
--- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
--- Sha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
--- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
--- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
--- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
-------------------------------------------------

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, avg(t.amount) as 'media_amount'
FROM companies as c
JOIN transactions as t
ON c.company_id = t.company_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

-------------------------------------------------
--- NIVEL 3
-------------------------------------------------
-------------------------------------------------
--- EJERCICIO 1
--- Crea una nova taula que reflecteixi l estat de les targetes de crèdit basat en si les tres últimes transaccions 
--- han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. 
--- Partint d’aquesta taula respon:
--- Quantes targetes estan actives?
-------------------------------------------------
--- Proceso en 3 pasos diferentes. 
--- 1 Obtener orden de transacciones por tarjeta; 2 Eliminar todo menos los 3 ultimos movimientos; 3 Asignar el campo según esten activas o inactivas
DROP TABLE IF EXISTS credit_cards_stat;
CREATE TABLE credit_cards_stat2
SELECT t.card_id, t.fecha, t.declined,
ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY fecha DESC) AS puesto
FROM transactions as t
JOIN companies as c
ON t.company_id = c.company_id;

DELETE FROM credit_cards_stat2
WHERE puesto > 3;

CREATE TABLE credit_cards_stat
SELECT card_id,
CASE
	WHEN sum(declined)=3 THEN 'Inactiva'
	ELSE 'Activa'
END as stat
FROM credit_cards_stat2
GROUP BY card_id
ORDER BY card_id;

DROP TABLE IF EXISTS credit_cards_stat2;

--- Quantes targetes estan actives? 5000 No hay Inactivas 
SELECT count(card_id)
FROM credit_cards_stat
WHERE stat = 'Activa';

--- Proceso creado en 1 paso con subqueries
CREATE TABLE IF NOT EXISTS credit_card_stat
SELECT card_id,
CASE
	WHEN sum(declined)=3 THEN 'Inactiva'
	ELSE 'Activa'
END as stat
FROM 
	(SELECT t.card_id, t.fecha, t.declined,
	ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY fecha DESC) AS puesto
	FROM transactions as t
	JOIN companies as c
	ON t.company_id = c.company_id) as sub1
WHERE puesto < 3
GROUP BY card_id
ORDER BY card_id;

--- Quantes targetes estan actives? 5000 No hay Inactivas 
SELECT count(card_id)
FROM credit_cards_stat
WHERE stat = 'Activa';

-------------------------------------------------
-- EJERCICIO 2
-- Crea una taula amb la qual puguem unir les dades de larxiu de products.csv amb la base de dades creada 
-- (ja que fins ara no podíem fer-ho), tenint en compte que des de transaction tens product_ids. 
-- Genera la següent consulta:
-- Necessitem conèixer el nombre de vegades que sha venut cada producte.
-------------------------------------------------
-- transactions
DROP TABLE IF EXISTS productos;
CREATE TABLE IF NOT EXISTS productos (
id INT,
product_name VARCHAR(50),
price VARCHAR(15),
colour VARCHAR(15),
weight DECIMAL(10,1),
warehouse_id VARCHAR(8),
category VARCHAR(15),
brand VARCHAR(15),
cost VARCHAR(15),
launch_date DATE);

LOAD DATA LOCAL
INFILE "C:/Users/noel_/Documents/GitHub/IT_Data/Especializacion/2_Sprint/N1-Ex.8__products.csv"
INTO TABLE productos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

CREATE TABLE IF NOT EXISTS product_transaction
SELECT t.id as transaction_id, p.id as product_id, t.product_ids as transactions_products_ids, t.fecha
from productos as p
JOIN transactions as t
ON FIND_IN_SET(p.id, REPLACE(t.product_ids, ' ', '')) -- product_ids es un conjunto de ids por lo que no vale el p.id in t.product_ids
WHERE p.id = 52
ORDER BY product_ids, p.id;

--- SOLUCION FINAL
SELECT distinct(product_id) as product_id, count(product_id) as 'n_ventas'
FROM product_transaction
GROUP BY product_id
ORDER BY 2 DESC
