USE master;
DROP DATABASE IF EXISTS HangPhanInl3;
CREATE DATABASE HangPhanInl3;
GO
USE HangPhanInl3;

CREATE TABLE Book
(
    BookId    INT IDENTITY (1,1) PRIMARY KEY,
    Title     VARCHAR(200) NOT NULL,
    Author    VARCHAR(100) NOT NULL,
    ISBN      VARCHAR(13)  NOT NULL,
    DeweyCode CHAR(3)      NOT NULL
        CHECK (DeweyCode BETWEEN '000' AND '999'),
);

CREATE TABLE BookCopy
(
    BookCopyId   INT IDENTITY (1,1) PRIMARY KEY,
    BookId       INT NOT NULL FOREIGN KEY REFERENCES Book (BookId),
    PurchaseDate DATE,
    Status       NVARCHAR(20) DEFAULT 'Available'
        CHECK (Status IN ('Available', 'Loaned', 'Overdue'))
);
CREATE TABLE Borrower
(
    BorrowerId INT IDENTITY (1, 1) PRIMARY KEY,
    Name       NVARCHAR(100) NOT NULL,
    Email      NVARCHAR(100) NOT NULL,
    CHECK (Email LIKE '%_@__%.__%'),
    Adress     NVARCHAR(100) NOT NULL,
    IsActive   BIT DEFAULT 1
);


CREATE TABLE Loan
(
    LoanId     INT IDENTITY (1,1) PRIMARY KEY,
    BorrowerId INT,
    FOREIGN KEY (BorrowerId)
        REFERENCES Borrower (BorrowerId),
    BookId     INT,
    FOREIGN KEY (BookId)
        REFERENCES Book (BookId),
    BookCopyId INT,
    FOREIGN KEY (BookCopyId)
        REFERENCES BookCopy (BookCopyId),
    LoanDate   DATE,
    DueDate    AS DATEADD(DAY, 14, LoanDate),
    ReturnDate DATE
);

-- 1. Insert into Book (Unique Titles)
INSERT INTO Book (Title, Author, ISBN, DeweyCode)
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', '813'),
       ('Clean Code', 'Robert C. Martin', '9780132350884', '005'),
       ('The Hobbit', 'J.R.R. Tolkien', '9780547928227', '823'),
       ('Sapiens', 'Yuval Noah Harari', '9780062316097', '909'),
       ('1984', 'George Orwell', '9780451524935', '823'),
       ('Database Systems', 'Abraham Silberschatz', '9780073523323', '005'),
       ('The Alchemist', 'Paulo Coelho', '9780062315007', '863'),
       ('Atomic Habits', 'James Clear', '9780735211291', '158'),
       ('Dune', 'Frank Herbert', '9780441172719', '813'),
       ('Educated', 'Tara Westover', '9780399590504', '920');

-- 2. Insert into BookCopy (20 copies total)
-- Some books have multiple copies to match your request
INSERT INTO BookCopy (BookId, PurchaseDate, Status)
VALUES (1, '2025-01-10', 'Available'),
       (1, '2025-01-12', 'Loaned'), -- Gatsby (2 copies)
       (2, '2025-02-01', 'Available'),
       (2, '2025-02-05', 'Overdue'), -- Clean Code (2 copies)
       (3, '2025-03-10', 'Available'),
       (3, '2025-03-10', 'Available'),
       (3, '2025-03-10', 'Available'), -- Hobbit (3 copies)
       (4, '2025-04-05', 'Loaned'),
       (4, '2025-04-06', 'Available'), -- Sapiens (2 copies)
       (5, '2025-01-20', 'Available'),
       (5, '2025-01-21', 'Available'), -- 1984 (2 copies)
       (6, '2026-01-10', 'Available'), -- Database (Never borrowed)
       (7, '2025-02-15', 'Available'), -- Alchemist
       (8, '2025-08-10', 'Available'), -- Atomic Habits
       (9, '2025-09-05', 'Available'), -- Dune
       (10, '2025-11-20', 'Available'),
       (10, '2025-11-21', 'Available'),
       (10, '2025-11-22', 'Available'),
       (10, '2025-11-23', 'Available'); -- Educated (4 copies)

-- 3. Insert into Borrower
INSERT INTO Borrower (Name, Email, Adress, IsActive)
VALUES ('Alice Johnson', 'alice.j@example.com', '123 Maple St', 1),
       ('Bob Smith', 'bob.s@example.com', '456 Oak Ave', 1),
       ('Charlie Brown', 'charlie.b@example.com', '789 Pine Rd', 1),
       ('Diana Prince', 'diana.p@example.com', '321 Amazon Ln', 1),
       ('Edward Norton', 'ed.n@example.com', '555 Ghost St', 1), -- Never borrowed
       ('Fiona Gallagher', 'fiona.g@example.com', '777 South Side', 0);

-- 4. Insert into Loan
-- Reference date for "Today": 2026-01-27
INSERT INTO Loan (BorrowerId, BookId, BookCopyId, LoanDate, ReturnDate)
VALUES
-- Alice: Borrowed 2 copies of Gatsby, returned one, still has one
(1, 1, 1, '2025-12-01', '2025-12-14'), -- Returned
(1, 1, 2, '2026-01-15', NULL),         -- Status: Loaned (Due 01-29)

-- Bob: Currently holding Sapiens
(2, 4, 8, '2026-01-20', NULL),         -- Status: Loaned (Due 02-03)

-- Charlie: One OVERDUE, one returned
(3, 2, 4, '2025-12-20', NULL),         -- Status: Overdue (Due was 2026-01-03)
(3, 5, 10, '2026-01-01', '2026-01-10'),-- Returned
-- Diana: Borrowed a book and returned it
(4, 3, 5, '2025-12-25', '2026-01-05'); -- Returned

-- 1. Låna ut en specifik bok till en viss person.
CREATE UNIQUE INDEX idx_Borrower_Email ON Borrower (Email);
GO
-- Need to check available account first, check book available, then check out the book, update the status.
-- Create an object that can be reused.
CREATE PROCEDURE sp_CheckoutBook @Email NVARCHAR(100),
                                 @BookCopyId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BorrowerId INT;
    DECLARE @BookStatus NVARCHAR(20);

    --Check email
    SELECT @BorrowerId = BorrowerId FROM Borrower WHERE Email = @Email;
    IF @BorrowerId IS NULL
        BEGIN
            PRINT 'Please register first.'
            RETURN;
        END
    -- Check available book
    SELECT @BookStatus = Status FROM BookCopy WHERE BookCopyId = @BookCopyId;
    IF @BookStatus IS NULL
        BEGIN
            PRINT 'Book not found.'
            RETURN;
        END
    IF @BookStatus <> 'Available'
        BEGIN
            PRINT 'This book is unavailable.'
            RETURN;
        END

    -- Process to Loan
    SET XACT_ABORT ON;
    BEGIN TRAN;
    INSERT INTO Loan (BorrowerId, BookCopyId, LoanDate, ReturnDate)
    VALUES (@BorrowerId, @BookCopyId, GETDATE(), NULL);

    UPDATE BookCopy
    SET Status = 'Loaned'
    WHERE BookCopyId = @BookCopyId;
    COMMIT TRAN;
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
END;
GO
EXEC sp_CheckoutBook 'diana.p@example.com', 19;
GO

---------------------------------------------------------

-- 2. Lämna tillbaka en specifik bok (från en viss person).

-- Check borrower with email first, then check the returnDate is null or not.
-- Return book and have to update status of the book, the returnDate.
CREATE PROCEDURE sp_ReturnBook @Email NVARCHAR(100),
                               @BookCopyId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BorrowerId INT;
    DECLARE @LoanId INT;
    SELECT @BorrowerId = BorrowerId FROM Borrower WHERE Email = @Email;
    IF @BorrowerId IS NULL
        BEGIN
            PRINT 'You are not a member.'
            RETURN;
        END

    SELECT @LoanId = LoanId
    FROM Loan
    WHERE BorrowerId = @BorrowerId
      AND BookCopyId = @BookCopyId
      AND ReturnDate IS NULL;
    IF @LoanId IS NULL
        BEGIN
            PRINT 'You do not have any book to return.'
            RETURN;
        END

    SET XACT_ABORT ON;
    BEGIN TRAN;
    UPDATE Loan
    SET ReturnDate = GETDATE()
    WHERE LoanId = @LoanId;

    UPDATE BookCopy
    SET Status = 'Available'
    WHERE BookCopyId = @BookCopyId;
    COMMIT TRAN;
    ROLLBACK TRAN;
END;
GO
SELECT *
FROM Loan;
SELECT *
FROM BookCopy;
EXEC sp_ReturnBook 'alice.j@example.com', 3;
GO
--------------------------------------------------------------------

-- 3. Se vilka böcker en viss person har lånat och när de skall vara tillbaka.
CREATE VIEW v_ActiveLoans AS
SELECT br.Name,
       br.Email,
       b.Title,
       l.DueDate,
       CASE
           WHEN GETDATE() > l.DueDate THEN 'Overdue'
           ELSE
               'Loaned'
           END AS Status
FROM Borrower AS br
         JOIN Loan AS l
              ON br.BorrowerId = l.BorrowerId
         JOIN Book AS b ON l.BookId = b.BookId
WHERE l.ReturnDate IS NULL;
GO
SELECT *
FROM v_ActiveLoans
WHERE Email = 'alice.j@example.com';
GO

-- 4. Se vilka böcker som är försenade och vem som har lånat dem.
SELECT b.Title, br.Name
FROM Loan AS l
         JOIN Book AS b ON l.BookId = b.BookId
         JOIN Borrower AS br ON l.BorrowerId = br.BorrowerId
WHERE DueDate < GETDATE()
  AND l.ReturnDate IS NULL;
GO

-- 5. Hitta alla böcker av en viss författare.
CREATE INDEX idx_Book_Author
    ON Book (Author);
SELECT Title
FROM Book
WHERE Author = 'Tara Westover';
GO
----------------------------------------------------
-- 6. Lägga till en ny bok.
--  Because I have a CopyBook, the book added can only be ready for Loan when the BookCopy was updated too.
INSERT INTO Book (Title, Author, ISBN, DeweyCode)
VALUES ('Ancient Manuscripts', 'John Smith', '9781234567890', '013');
DECLARE @BookId INT = SCOPE_IDENTITY(); -- Get the newest BookId to fill in the BookCopyId
INSERT INTO BookCopy(BookId, PurchaseDate, Status)
VALUES (@BookId, GETDATE(), 'Available');
GO

-- 7. Ta bort en befintlig bok.
-- Delete BookId from Loan first
DELETE
FROM Loan
WHERE BookId = 1;
-- Then delete all BookCopy
DELETE
FROM BookCopy
WHERE BookId = 1;
-- The last one delete Book
DELETE
FROM Book
WHERE BookId = 1;
GO

-- 8. Hitta alla böcker som är äldre än ett visst inköpsdatum och inte utlånade.
SELECT b.Title, bc.PurchaseDate
FROM Book AS b
         JOIN BookCopy bc on b.BookId = bc.BookId
WHERE bc.PurchaseDate < '2025-01-25'
  AND bc.Status = 'Available';
GO