Library management system in mongodb.

I created two collections of book and customer. 
The book collection uses embedded documents for copies to manage physical
book instances and their status.
The customer collection also uses an embedded document for loans to keep track
of active rentals.

1. First, update books with copies status to be Loaned.
Use $set to change only the copies-status field from available to loaned,
without affecting any other fields.
    Then, set the variable loanDatum to today, dueDatum is today date + 14 days.
    After updating the book status, the process is ended by updating the customer 
 profile to record the transaction. 
 Use $push operator to add a new loan document into the loans array.

2. First, update copies in book status to be Available.
    Use $set to change only the copies-status field from available to loaned,
without affecting any other fields.
    Then, remove the loan from the customer's loans array.
    Use the $pull operator to efficiently remove the corresponding loan record
    from the customer's loans array, ensuring the database only reflects active loans.

3. First find a person with a specific id in the customer collection, then show the name and the loans
document without loans id.

4. Insert a new book with a copies only.

5. Update on the collection book, delete a copies of the book using the $pull operator.

6. Use the Aggregation Pipeline to calculate the total number of physical copies based on
book title and author:
    $match: Filters out all documents with the title "Clean Code" and author "Robert C. Martin". 
    This is important because a work can have multiple versions (ISBNs).
    $group: Groups the filtered documents by book title.
    TotalCopies: Uses a combination of two operators:
        $size: Counts the number of elements in the copies array for each document.
        $sum: Sums all $size values ​​together to get the total number of physical copies
        currently in the entire library.