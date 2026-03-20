Jag gjorde hela uppgiften med bara en fil som heter HangPhanInl4.sql.
I första frågan:
För att bara böcker som har lånat och inte lämnat till backa finns i borrowedBook
Då hämta jag bara böcker som har returnDate < nu tiden i BorrowedBook tabellen.

I andra frågan:
Steg 1:
Hämta böcker som har köpt över 9 år from Book tabell och ta bort de böcker som har hittat.
Steg 2:
Letar efter böcker via isbn och ta bort de böcker som har isbn kvar i bookEdition
men finns inte i Book tabell.

I tredje frågan:
Steg 1:
Ändra BookEdition tabell, lägga till loanCount column för att öka count varje gång när boken
som har book insert into loan table.
Steg 2:
Check if book id finns redan i Borrowed tabell.
Steg 3:
Skapa procedure lendBook med parameter @book_id och @borrowed_id med save transaction.
Insert en ny book till Borrowed table med @book_id och @borrower_id.
Steg 4:
Uppdatera BookEdition i loanCount, öka loanCount med book_id samma med @book_id ska låna.
Uppdatera BookEdition i loanCount, öka loanCount med book_id samma med @book_id ska låna.
Steg 5:
Skapa ett vy som count(book_id), tagit to 5 av count inom count(book_id) < 3.
