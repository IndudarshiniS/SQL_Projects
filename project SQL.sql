CREATE DATABASE library_analysis;
USE library_analysis;

CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress VARCHAR(255),
    publisher_PublisherPhone VARCHAR(20)
);

CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);

CREATE TABLE tbl_book_authors (
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);

CREATE TABLE tbl_book_copies (
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID)
);

CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress VARCHAR(255),
    borrower_BorrowerPhone VARCHAR(20)
);

CREATE TABLE tbl_book_loans (
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(CardNo)
);

CREATE TABLE tbl_library_branch (
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress VARCHAR(255)
);

/* How many copies of the book titled "The Lost Tribe" are 
owned by the library branch whose name is "Sharpstown"? */

SELECT SUM(bc.book_copies_No_Of_Copies) AS TotalCopies
FROM tbl_book b
JOIN tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.BranchID
WHERE b.book_Title = 'The Lost Tribe' AND lb.library_branch_BranchName = 'Sharpstown';

/* How many copies of the book titled "The Lost Tribe" 
are owned by each library branch? */

SELECT lb.library_branch_BranchName, SUM(bc.book_copies_No_Of_Copies) AS TotalCopies
FROM tbl_book b
JOIN tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.BranchID
WHERE b.book_Title = 'The Lost Tribe'
GROUP BY lb.library_branch_BranchName;

/* Retrieve the names of all borrowers 
who do not have any books checked out. */

SELECT b.borrower_BorrowerName
FROM tbl_borrower b
LEFT JOIN tbl_book_loans bl ON b.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;

/* For each book that is loaned out from the "Sharpstown" 
branch and whose DueDate is 2/3/18, retrieve the book title, 
the borrower's name, and the borrower's address. */

SELECT 
    b.book_Title,
    br.borrower_BorrowerName,
    br.borrower_BorrowerAddress
FROM 
    tbl_book b
JOIN 
    tbl_book_loans bl ON b.book_BookID = bl.book_loans_BookID
JOIN 
    tbl_borrower br ON bl.book_loans_CardNo = br.borrower_CardNo
JOIN 
    tbl_library_branch lb ON bl.book_loans_BranchID = lb.BranchID
WHERE 
    lb.library_branch_BranchName = 'Sharpstown' 
    AND bl.book_loans_DueDate = '2018-02-03';
    
 /*  For each library branch, retrieve the branch name and 
 the total number of books loaned out from that branch. */
 
    
SELECT 
    lb.library_branch_BranchName,
    COUNT(bl.book_loans_BookID) AS TotalBooksLoaned
FROM 
    tbl_library_branch lb
LEFT JOIN 
    tbl_book_loans bl ON lb.BranchID = bl.book_loans_BranchID
GROUP BY 
    lb.library_branch_BranchName;
    
/* Retrieve the names, addresses, and number of books 
checked out for all borrowers who have more than five books
 checked out. */
    
SELECT 
    br.borrower_BorrowerName,
    br.borrower_BorrowerAddress,
    COUNT(bl.book_loans_BookID) AS NumberOfBooksCheckedOut
FROM 
    tbl_borrower br
JOIN 
    tbl_book_loans bl ON br.borrower_CardNo = bl.book_loans_CardNo
GROUP BY 
    br.borrower_CardNo, br.borrower_BorrowerName, br.borrower_BorrowerAddress
HAVING 
    COUNT(bl.book_loans_BookID) > 5;
    
/* For each book authored by "Stephen King", retrieve the title and the number of 
copies owned by the library branch whose name is "Central". */
    
SELECT 
    b.book_Title,
    bc.book_copies_No_Of_Copies
FROM 
    tbl_book b
JOIN 
    tbl_book_authors ba ON b.book_BookID = ba.book_authors_BookID
JOIN 
    tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN 
    tbl_library_branch lb ON bc.book_copies_BranchID = lb.BranchID
WHERE 
    ba.book_authors_AuthorName = 'Stephen King' 
    AND lb.library_branch_BranchName = 'Central';
    


