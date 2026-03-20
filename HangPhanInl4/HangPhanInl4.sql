USE master;
DROP DATABASE IF EXISTS [HangPhanInl4];
GO

CREATE DATABASE [HangPhanInl4]
--     COLLATE Finnish_Swedish_100_CS_AI_SC_UTF8;
GO

-- Create tables

USE [HangPhanInl4];

CREATE TABLE Borrower
(
    borrower_id INT IDENTITY (1,1) PRIMARY KEY,
    full_name   VARCHAR(60) NOT NULL,
    email       VARCHAR(70) NOT NULL
);
GO

CREATE TABLE BookEdition
(
    isbn   CHAR(13) PRIMARY KEY,
    title  VARCHAR(80),
    author VARCHAR(60) NOT NULL
);

CREATE TABLE Book
(
    book_id       INT IDENTITY (1,1) PRIMARY KEY,
    isbn          CHAR(13) NOT NULL FOREIGN KEY REFERENCES BookEdition (isbn),
    purchase_date DATE     NOT NULL
);
GO

-- Insert entry here to lend someone a book, delete from here to return

CREATE TABLE BorrowedBook
(
    book_id     INT  NOT NULL FOREIGN KEY REFERENCES Book (book_id),
    borrower_id INT  NOT NULL FOREIGN KEY REFERENCES Borrower (borrower_id),
    return_date DATE NOT NULL,
    PRIMARY KEY (book_id)
);
GO

-- Insert test data

INSERT INTO Borrower
VALUES ('Nisse Hult', 'nisse@bossnniss.com'),
       ('Lena Lamm', 'lena@lamm.com');

INSERT INTO BookEdition
VALUES ('9781509302000', 'T-SQL Fundamentals', 'Itzik Ben-Gan'),
       ('9789129697285', 'Här kommer Pippi Långstrump', 'Astrid Lindgren'),
       ('9789177423379', 'Den gamle och havet', 'Ernest Hemingway');

INSERT INTO Book
VALUES ('9781509302000', '2018-01-23'),
       ('9781509302000', '2019-04-12'),
       ('9789129697285', '2014-05-02'),
       ('9789129697285', '2015-08-12'),
       ('9789129697285', '2019-04-22'),
       ('9789177423379', '2011-12-21'),
       ('9789177423379', '2011-12-21');

INSERT INTO BorrowedBook
VALUES (2, 1, '2021-05-12'),
       (4, 2, '2021-05-02'),
       (1, 2, '2021-03-17'),
       (3, 2, '2021-03-20');
GO

-- 1. Försenade böcker
CREATE VIEW Overdue AS
SELECT bb.book_id, be.title, be.author, br.full_name, br.email, bb.return_date
FROM BorrowedBook AS bb
         JOIN Book AS b ON bb.book_id = b.book_id
         JOIN BookEdition AS be ON b.isbn = be.isbn
         JOIN Borrower br on bb.borrower_id = br.borrower_id
WHERE return_date < CAST(GETDATE() AS DATE);
GO

-- 2. Rensa gamla böcker

CREATE PROCEDURE removeOldBooks
AS
BEGIN
    SET NOCOUNT ON;
    -- Find then delete the books that were purchased more than nine years ago.
    DELETE
    FROM Book
    WHERE DATEDIFF(YEAR, purchase_date, getdate()) > 9
      AND book_id NOT IN (SELECT book_id FROM BorrowedBook);
    -- Delete bookEditions that do not have isbn in Book anymore.
    DELETE
    FROM BookEdition
    WHERE isbn NOT IN (SELECT isbn FROM Book)
END;
GO

-- 3. Statistik över utlåning
ALTER TABLE BookEdition
    ADD loanCount INT NOT NULL DEFAULT 0;
GO
DROP PROCEDURE IF EXISTS lendBook;
GO
CREATE PROCEDURE lendBook @book_id INT,
                          @borrower_id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Check if the book is already borrowed
    IF EXISTS(SELECT 1 FROM BorrowedBook WHERE book_id = @book_id)
        BEGIN
            PRINT 'Book is already borrowed';
            RETURN;
        END
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO BorrowedBook (book_id, borrower_id, return_date)
        -- return date is the day 30 days from the date the book is loaned.
        VALUES (@book_id, @borrower_id, DATEADD(DAY, 30, GETDATE()));
        -- Increase loanCount for the book edition through isbn
        UPDATE BookEdition
        SET loanCount = loanCount + 1
        FROM BookEdition AS be
        JOIN Book AS b ON be.isbn = b.isbn
        WHERE b.book_id = @book_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
    END CATCH
END;
GO
-- View showing books that have loaned over 5 times.
CREATE VIEW ToPurchase
AS
SELECT TOP 5 be.isbn, be.title, be.loanCount, be.author, b.purchase_date ,  COUNT(b.book_id) AS coppies
FROM BookEdition AS be
        JOIN Book AS b
              ON be.isbn = b.isbn
GROUP BY be.isbn, be.title, be.author, be.loanCount, b.purchase_date
HAVING COUNT(b.book_id) < 3
ORDER BY be.loanCount DESC;