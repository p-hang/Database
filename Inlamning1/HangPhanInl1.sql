USE mysql;
DROP DATABASE IF EXISTS dbHangPhan;

CREATE DATABASE dbHangPhan;
USE dbHangPhan;
CREATE TABLE tblCustomer
(
    fldCustomerNo   INT AUTO_INCREMENT PRIMARY KEY,
    fldCustomerName VARCHAR(40),
    fldAddress      VARCHAR(100),
    fldPostCode     VARCHAR(10),
    fldCity         VARCHAR(100),
    fldDiscount     DECIMAL(2, 2) UNSIGNED
);

CREATE TABLE tblArticle
(
    fldArticleNo   INT AUTO_INCREMENT PRIMARY KEY,
    fldArticleName VARCHAR(30),
    fldStock       INT,
    fldOrderPoint  INT,
    fldPrice       DECIMAL(10, 2)
);

CREATE TABLE tblCustomerOrder
(
    fldOrderNumber  INT AUTO_INCREMENT PRIMARY KEY,
    fldCustomerNo   INT,
    fldDeliveryDate DATE,
    fldOrderDate    DATE,
    FOREIGN KEY (fldCustomerNo)
        REFERENCES tblCustomer (fldCustomerNo)
);

CREATE TABLE tblOrdList
(
    fldOrderNumber INT,
    fldArticleNo   INT,
    fldTotal       INT,
    PRIMARY KEY (fldOrderNumber, fldArticleNo),
    FOREIGN KEY (fldOrderNumber)
        REFERENCES tblCustomerOrder (fldOrderNumber),
    FOREIGN KEY (fldArticleNo)
        REFERENCES tblArticle (fldArticleNo)
);

INSERT INTO tblCustomer (fldCustomerName, fldAddress, fldPostCode, fldCity, fldDiscount)
VALUES ('Erik Andersson', 'Majorsgatan 10', '41333', 'Göteborg', 0.05),
       ('Anna Lindgren', 'Avenyn 22', '41136', 'Göteborg', 0.20),
       ('Lars Björk', 'Kungsgatan 5', '11143', 'Stockholm', 0.3),
       ('Karin Gustafsson', 'S:t Jörgens 3', '42254', 'Göteborg', 0.1),
       ('Olof Karlsson', 'Vasaparken 8', '11321', 'Stockholm', 0.18),
       ('Maja Svensson', 'Norra Hamngatan 1', '41106', 'Göteborg', 0.25);

INSERT INTO tblArticle (fldArticleName, fldStock, fldOrderPoint, fldPrice)
VALUES ('Volvo XC90', 4, 1, 520000.00),
       ('Tesla Model X', 2, 1, 850000.00),
       ('Audi Q5', 3, 1, 430000.00),
       ('BMW 520D', 5, 2, 340000.00),
       ('Mercedes E220', 6, 2, 370000.00), -- NOT SOLD
       ('Ford Mustang', 1, 1, 610000.00), -- NOT SOLD
       ('Toyota RAV4', 7, 2, 250000.00),  -- NOT SOLD
       ('Volkswagen Tiguan', 3, 1, 280000.00);

INSERT INTO tblCustomerOrder (fldCustomerNo, fldDeliveryDate, fldOrderDate)
VALUES (1, '2025-04-10', '2025-04-02'),
       (2, '2025-05-02', '2025-04-26'),
       (3, '2025-06-18', '2025-06-01'),
       (5, '2025-07-30', '2025-07-20');

INSERT INTO tblOrdList (fldOrderNumber, fldArticleNo, fldTotal)
VALUES (1, 1, 1),
       (1, 4, 1),
       (2, 2, 1),
       (3, 3, 2),
       (4, 8, 1);


-- 1. Vilka kunder bor i Göteborg?
SELECT fldCustomerNo, fldCustomerName
FROM tblCustomer
WHERE fldCity = ('Göteborg');

-- 2. Vilka artikar har blivit sålda? Visa minst artikelnummer.
SELECT DISTINCT fldArticleNo
FROM tblArticle
WHERE fldArticleNo IN (SELECT fldArticleNo FROM tblOrdList);



-- 3. Vilka kunder har mer än 20% rabatt? Visa minst namn och kundnummer.
SELECT fldCustomerNo, fldCustomerName
FROM tblCustomer
WHERE fldDiscount > 0.2;

SELECT VERSION()