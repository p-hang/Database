const database = 'HangPhan';
use("HangPhan");
db.book.insertMany([
    {
        "_id": 1,
        "title": "Clean Code",
        "author": "Robert C. Martin",
        "isbn": "9780132350884",
        "purchaseDate": "2018-11-20",
        "copies": [
            { "copyId": 1, "status": "Loaned" },
            { "copyId": 2, "status": "Loaned" },
            { "copyId": 3, "status": "Available" },
            { "copyId": 4, "status": "Available" }
        ]
    },
    {
        "_id": 2,
        "title": "Clean Code",
        "author": "Robert C. Martin",
        "isbn": "9780137081073",
        "purchaseDate": "2020-05-01",
        "copies": [
            { "copyId": 1, "status": "Loaned" },
            { "copyId": 2, "status": "Available" },
            { "copyId": 3, "status": "Available" }
        ]
    },
    {
        "_id": 3,
        "title": "Design Patterns",
        "author": "Erich Gamma",
        "isbn": "9780201633610",
        "purchaseDate": "2017-03-15",
        "copies": [
            { "copyId": 1, "status": "Loaned" },
            { "copyId": 2, "status": "Loaned" },
            { "copyId": 3, "status": "Loaned" },
            { "copyId": 4, "status": "Available" }
        ]
    },
])

db.customer.insertMany([
    {
        "_id": 1,
        "name": "Anna Svensson",
        "email": "anna.svensson@example.se",
        "address": "Amiralitetsgatan 29 B lgh 1202, 414 62 Göteborg",
        "loans": [
            {
                "bookId": 1,
                "copyId": 2,
                "loanDate": "2026-02-01",
                "dueDate": "2026-02-15"
            },
            {
                "bookId": 3,
                "copyId": 2,
                "loanDate": "2026-02-03",
                "dueDate": "2026-02-17"
            }
        ]
    },
    {
        "_id": 2,
        "name": "Erik Johansson",
        "email": "erik.johansson@example.se",
        "address": "Kungsgatan 45 A lgh 803, 111 35 Stockholm",
        "loans": [
            {
                "bookId": 3,
                "copyId": 1,
                "loanDate": "2026-02-05",
                "dueDate": "2026-02-19"
            }
        ]
    },
    {
        "_id": 3,
        "name": "Karin Larsson",
        "email": "karin.larsson@example.se",
        "address": "Södra Förstadsgatan 12 B lgh 204, 211 43 Malmö",
        "loans": [
            {
                "bookId": 2,
                "copyId": 1,
                "loanDate": "2026-02-07",
                "dueDate": "2026-02-21"
            },
            {
                "bookId": 3,
                "copyId": 3,
                "loanDate": "2026-02-08",
                "dueDate": "2026-02-22"
            }
        ]
    },
    {
        "_id": 4,
        "name": "Lars Nilsson",
        "email": "lars.nilsson@example.se",
        "address": "Vaksalagatan 16 C lgh 502, 753 32 Uppsala",
        "loans": []
    },
    {
        "_id": 5,
        "name": "Sofia Eriksson",
        "email": "sofia.eriksson@example.se",
        "address": "Drottninggatan 88 A lgh 12, 111 36 Stockholm",
        "loans": [
            {
                "bookId": 1,
                "copyId": 1,
                "loanDate": "2026-02-12",
                "dueDate": "2026-02-26"
            }
        ]
    },
])

// 1. Låna ut en bok id 2, copyId 2 till en person id 2.
db.book.updateOne(
    {
        _id: 2,
        "copies.copyId": 2
    },
    {
        $set: {
            "copies.$.status": "Loaned"
        }
    });
var loanDatum = new Date();
var dueDatum = new Date();
dueDatum.setDate(loanDatum.getDate() + 14);
db.customer.updateOne(
    { _id: 2 },
    {
        $push: {
            loans: {
                bookId: 2,
                copyId: 2,
                loanDate: loanDatum,
                dueDate: dueDatum
            }
        }
    }
)

// 2. Lämna tillbaka boken id 3, copyId 3 från personen id 3.
db.book.updateOne(
    {
        _id: 3,
        "copies.copyId": 3
    },
    {
        $set: {
            "copies.$.status": "Available"
        }
    }
)

db.customer.updateOne(
    {
        _id: 3
    },
    {
        $pull: {
            loans: {
                bookId: 3,
                copyId: 3
            }
        }
    }
)

//3. Se vilka böcker personId 1 har lånat och när de skall vara tillbaka.
db.customer.find(
    {
        _id: 1
    },
    {
        name: 1, loans: 1, _id: 0
    }
)

//4. Lägga till en ny bok.
db.book.insertOne({
    _id: 4,
    title: "Refactoring",
    author: "Martin Fowler",
    isbn: "9780201485677",
    purchaseDate: "2021-07-15",
    copies: [
        { copyId: 1, status: "Available" }
    ]
});

//5. Ta bort bok id 1 copyId  3.
db.book.updateOne(
    { _id: 1 },
    { $pull: { copies: { copyId: 3 } } }
);

//6. Räkna hur många (fysiska) böcker vi har givet en viss titel och författare.
db.book.aggregate([
    {
        $match: {
            title: "Clean Code",
            author: "Robert C. Martin"
        }
    },
    {
        $group: {
            _id: "$title",
            totalCopies: { $sum: { $size: "$copies" } }
        }
    }
])