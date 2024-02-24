
DROP DATABASE IF EXISTS ToysGroup;

CREATE DATABASE ToysGroup;

-- Selezione del database appena creato
USE ToysGroup;

-- Creazione della tabella Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

-- Creazione della tabella Product
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Creazione della tabella Region
CREATE TABLE Region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(255) NOT NULL
);

-- Creazione della tabella State
CREATE TABLE State (
    state_id INT PRIMARY KEY,
    state_name VARCHAR(255) NOT NULL,
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES Region(region_id)
);

-- Creazione della tabella Sales
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    region_id INT,
    state_id INT, -- Nuova colonna aggiunta
    sale_date DATE,
    other_sale_details DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (region_id) REFERENCES Region(region_id),
    FOREIGN KEY (state_id) REFERENCES State(state_id) -- Nuova chiave esterna
);

-- Inserimento dei dati di esempio

-- Category
INSERT INTO Category (category_id, category_name) VALUES
(1, 'Toys'),
(2, 'Board Games'),
(3, 'Educational Toys'),
(4, 'Outdoor Games'),
(5, 'Building Blocks'),
(6, 'Sports Equipment');

-- Product
INSERT INTO Product (product_id, product_name, category_id) VALUES
(101, 'Action Figure', 1),
(102, 'Puzzle Game', 2),
(103, 'Stuffed Animal', 1),
(104, 'Science Kit', 3),
(105, 'Frisbee', 4),
(106, 'Dollhouse', 1),
(107, 'LEGO Set', 5),
(108, 'Basketball', 6),
(109, 'Remote Control Car', 1);

-- Region
INSERT INTO Region (region_id, region_name) VALUES
(501, 'WestEurope'),
(502, 'SouthEurope'),
(503, 'NorthAmerica'),
(504, 'Asia'),
(505, 'Oceania'),
(506, 'Africa');

-- State
INSERT INTO State (state_id, state_name, region_id) VALUES
(201, 'France', 501),
(202, 'Germany', 501),
(203, 'Italy', 502),
(204, 'Greece', 502),
(205, 'United States', 503),
(206, 'Canada', 503),
(207, 'Japan', 504),
(208, 'China', 504),
(209, 'Australia', 505),
(210, 'South Africa', 506);

-- Sales
INSERT INTO Sales (sale_id, product_id, region_id, state_id, sale_date, other_sale_details) VALUES
(301, 101, 501, 201, '2022-02-23', 25.99),
(302, 103, 502, 202, '2022-02-24', 19.95),
(303, 102, 501, 201, '2022-02-25', 34.50),
(304, 105, 504, 204, '2023-02-26', 15.75),
(305, 106, 502, 202, '2023-02-27', 29.99),
(306, 107, 506, 206, '2023-02-28', 49.99),
(307, 108, 505, 209, '2024-02-29', 39.95),
(308, 109, 502, 202, '2024-03-01', 22.50),
(309, 101, 501, 201, '2024-03-02', 18.99),
(310, 105, 502, 202, '2024-03-03', 27.50);

-- Verificare che i campi definiti come PK siano univoci
SELECT 
'Product' AS table_name, 
COUNT(*) AS num_rows, 
COUNT(DISTINCT product_id) AS unique_ids
FROM Product;

SELECT 
'Region' AS table_name, 
COUNT(*) AS num_rows, 
COUNT(DISTINCT region_id) AS unique_ids
FROM Region;

SELECT 
'State' AS table_name, 
COUNT(*) AS num_rows, 
COUNT(DISTINCT state_id) AS unique_ids
FROM State;

SELECT 
'Category' AS table_name, 
COUNT(*) AS num_rows, 
COUNT(DISTINCT category_id) AS unique_ids
FROM Category;


SELECT 
'Sales' AS table_name, 
COUNT(*) AS num_rows, 
COUNT(DISTINCT sale_id) AS unique_ids
FROM Sales;

-- Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno
SELECT
    P.product_id,
    P.product_name,
    YEAR(S.sale_date) AS sales_year,
    SUM(S.other_sale_details) AS total_revenue
FROM
    Product P
JOIN
    Sales S ON P.product_id = S.product_id
GROUP BY
    P.product_id, YEAR(S.sale_date);
    
-- Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente
SELECT
    St.state_id,
    St.state_name,
    YEAR(S.sale_date) AS sales_year,
    SUM(S.other_sale_details) AS total_revenue
FROM
    Sales S
JOIN
    Region R ON S.region_id = R.region_id
JOIN
    State St ON S.region_id = St.region_id
GROUP BY
    St.state_id, YEAR(S.sale_date)
ORDER BY
    YEAR(S.sale_date) ASC, total_revenue DESC;
    
-- Qual è la categoria di articoli maggiormente richiesta dal mercato? 
SELECT
    C.category_id,
    C.category_name,
    COUNT(*) AS total_sales_count
FROM
    Category C
JOIN
    Product P ON C.category_id = P.category_id
JOIN
    Sales S ON P.product_id = S.product_id
GROUP BY
    C.category_id
ORDER BY
    total_sales_count DESC
LIMIT 1;

-- Quali sono, se ci sono, i prodotti invenduti? Proponi due approcci risolutivi differenti. 
-- Approccio 1
SELECT
    P.product_id,
    P.product_name
FROM
    Product P
LEFT JOIN
    Sales S ON P.product_id = S.product_id
GROUP BY
    P.product_id
HAVING
    COUNT(S.sale_id) = 0;

-- Approccio 2
SELECT
    P.product_id,
    P.product_name
FROM
    Product P
WHERE
    NOT EXISTS (
        SELECT *
        FROM Sales S
        WHERE P.product_id = S.product_id
    );
    
-- Esporre l’elenco dei prodotti con la rispettiva ultima data di vendita (la data di vendita più recente)
    SELECT
    P.product_id,
    P.product_name,
    MAX(S.sale_date) AS last_sale_date
FROM
    Product P
LEFT JOIN
    Sales S ON P.product_id = S.product_id
GROUP BY
    P.product_id
    ORDER BY
    last_sale_date IS NULL, last_sale_date DESC;
    
ALTER TABLE Sales
ADD COLUMN state_id INT,
ADD FOREIGN KEY (state_id) REFERENCES State(state_id);

UPDATE Sales
SET state_id = (
    SELECT state_id
    FROM Region
    WHERE Sales.region_id = Region.region_id
    );
    
-- Esporre l’elenco delle transazioni indicando nel result set il codice documento, la data, il nome del prodotto, la categoria del prodotto, il nome dello stato, il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati più di 180 giorni dalla data vendita o meno (>180 -> True, <= 180 -> False)   
SELECT
    S.sale_id AS codice_documento,
    S.sale_date AS data,
    P.product_name AS nome_prodotto,
    C.category_name AS categoria_prodotto,
    St.state_name AS nome_stato,
    R.region_name AS nome_regione,
    CASE WHEN DATEDIFF(NOW(), S.sale_date) > 180 THEN 'True' ELSE 'False' END AS oltre_180_giorni
FROM
    Sales S
JOIN
    Product P ON S.product_id = P.product_id
JOIN
    Category C ON P.category_id = C.category_id
JOIN
    Region R ON S.region_id = R.region_id
JOIN
    State St ON S.state_id = St.state_id;