--- Utilitzant JOIN realitzaràs les següents consultes:
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










