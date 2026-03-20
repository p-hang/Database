USE mysql;
DROP DATABASE IF EXISTS dbHangPhan;

CREATE DATABASE dbHangPhan;
USE dbHangPhan;
CREATE TABLE tblCustomer
(
    fldCustomerNo   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fldCustomerName VARCHAR(40) NOT NULL,
    fldAddress      VARCHAR(100),
    fldPostCode     VARCHAR(10),
    fldCity         VARCHAR(100),
    fldDiscount     DECIMAL(2, 2) UNSIGNED
);

CREATE TABLE tblArticle
(
    fldArticleNo   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fldArticleName VARCHAR(30) NOT NULL UNIQUE,
    fldStock       INT UNSIGNED DEFAULT 0,
    fldOrderPoint  INT UNSIGNED DEFAULT 0,
    fldPrice       DECIMAL(10, 2) NOT NULL CHECK (fldPrice >= 0)
);

CREATE TABLE tblCustomerOrder
(
    fldOrderNumber  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fldCustomerNo   INT UNSIGNED,
    fldDeliveryDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    fldOrderDate    DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (fldCustomerNo)
        REFERENCES tblCustomer (fldCustomerNo),
        CHECK (fldDeliveryDate >= fldOrderDate)
);

CREATE TABLE tblOrdList
(
    fldOrderNumber INT UNSIGNED,
    fldArticleNo   INT UNSIGNED,
    fldTotal       INT UNSIGNED CHECK (fldTotal > 0),
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
       ('Ford Mustang', 1, 1, 610000.00),  -- NOT SOLD
       ('Toyota RAV4', 7, 2, 250000.00),   -- NOT SOLD
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


INSERT INTO tblArticle (fldArticleName, fldStock, fldOrderPoint, fldPrice)
VALUES ('Servicepaket Premium', 20, 5, 1999.00);

INSERT INTO tblCustomer (fldCustomerName, fldAddress, fldPostCode, fldCity, fldDiscount)
VALUES ('Jonas Pettersson', 'Storgatan 12', '58220', 'Linköping', 0.10),
       ('Maria Larsson', 'Fjärilsgatan 9', '42144', 'Göteborg', 0.05);

INSERT INTO tblCustomerOrder (fldCustomerNo, fldDeliveryDate, fldOrderDate)
VALUES (6, '2025-02-10', '2025-02-01'),
       (7, '2025-02-15', '2025-02-05'),
       (8, '2025-02-20', '2025-02-10');

INSERT INTO tblOrdList (fldOrderNumber, fldArticleNo, fldTotal)
VALUES (5, 9, 3);

-- ORDER 6: Kunden som har köpt flera produkter.
INSERT INTO tblOrdList (fldOrderNumber, fldArticleNo, fldTotal)
VALUES (6, 1, 1), -- Volvo XC90
       (6, 3, 2), -- Audi Q5
       (6, 9, 1); -- Servicepaket Premium

-- ORDER 7: Kunden som har köpt 1 produkt.
INSERT INTO tblOrdList (fldOrderNumber, fldArticleNo, fldTotal)
VALUES (7, 2, 1);
-- Tesla Model X

-- Kunder har flera beställningar.
INSERT INTO tblCustomerOrder (fldCustomerNo, fldDeliveryDate, fldOrderDate)
VALUES (1, '2025-04-20', '2025-04-15'),
       (2, '2025-05-15', '2025-05-10'),
       (4, '2025-08-10', '2025-08-01');

-- 4. Hur många olika artiklar har vi?
SELECT DISTINCT COUNT(fldArticleNo)
FROM tblArticle;

-- 5. Hur många är beställda av artikel 9?
SELECT SUM(fldTotal)
FROM tblOrdList
WHERE fldArticleNo = 9;

-- 6. Hur många kundorder skall levereras under kommande februari?
SELECT COUNT(fldCustomerNo), MONTH(fldDeliveryDate) AS deliveryMonth
FROM tblCustomerOrder
WHERE MONTH(fldDeliveryDate) = 02
GROUP BY deliveryMonth;

-- 7. Hur många kunder har vi inom varje rabattnivå?
SELECT COUNT(*), fldDiscount
FROM tblCustomer
GROUP BY fldDiscount;

-- 8. Vilka ordernr innehåller fler än en sorts artikel?
SELECT fldOrderNumber
FROM tblOrdList
GROUP BY fldOrderNumber
HAVING COUNT(DISTINCT fldArticleNo) > 1;

-- 9. Visa artikelnamn och totalt antal beställda per artikel.
SELECT a.fldArticleName, SUM(ol.fldTotal)
FROM tblArticle AS a
         JOIN tblOrdList AS ol
              ON a.fldArticleNo = ol.fldArticleNo
GROUP BY ol.fldArticleNo
ORDER BY SUM(ol.fldTotal);

-- 10. Vilka kunder har en enda order?
SELECT c.fldCustomerName
FROM tblCustomer AS c
         JOIN tblCustomerOrder AS co
              ON c.fldCustomerNo = co.fldCustomerNo
GROUP BY c.fldCustomerName
HAVING COUNT(co.fldOrderNumber) = 1;

-- 11. Vilka artiklar är beställda? Visa namn.
SELECT DISTINCT a.fldArticleName
FROM tblArticle AS a
         JOIN tblOrdList AS ol ON a.fldArticleNo = ol.fldArticleNo;

-- 12. Visa namn på artiklar som inte har blivit beställda. Visa namn.
SELECT a.fldArticleName
FROM tblArticle AS a
         LEFT OUTER JOIN tblOrdList AS ol
                         ON a.fldArticleNo = ol.fldArticleNo
WHERE ol.fldTotal IS NULL;
