SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

--Solving Business problems Now

--Q1  Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', '6.00', 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Q2  Update an Existing Member's Address

UPDATE members
SET member_address = ' 45A Van Reyen st'
WHERE member_id = 'C118';

SELECT * FROM members
ORDER BY member_id ASC;

--Q3 Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

--  Q4 Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--  Q5 List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
       COUNT(issued_id) as total_issued_book
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1
ORDER BY issued_emp_id ASC;

--  Q6  Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt
as
SELECT 
b.isbn,
b.book_title,
COUNT(ist.issued_id) as no_of_books_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

-- Retrieve All Books in a Specific Category
SELECT *
FROM books
WHERE category = 'Classic';

-- Find Total Rental Income by Category:

SELECT category, 
SUM(rental_price),
COUNT(*)
FROM books
JOIN
issued_status
ON issued_book_isbn = isbn
GROUP BY 1;

-- Q9 List Members Who Registered in the Last 180 Days:

INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES
       ('C120', 'Saurabh', '45 VAN REYPEN St', '2025-02-10'),
       ('C121', 'Ankit', '2777 JFK blvd', '2025-01-06');

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Q10 List Employees with Their Branch Manager's Name and their branch details:

SELECT
e1.*,
b.manager_id,
e2.emp_name as manager
FROM employees as e1
JOIN
branch as b
on b.branch_id = e1.branch_id
JOIN
employees as e2
on b.manager_id = e2.emp_id

--Q11) Create a Table of Books with Rental Price Above a Certain Threshold:


CREATE TABLE books_price AS
SELECT * FROM books
WHERE rental_price > 7.00;

--Q12) Retrieve the List of Books Not Yet Returned

SELECT
DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
on
ist.issued_id = rs.issued_id
WHERE rs.return_id is NULL;

-- Some advanced tasks and their solutions

-- Q13 Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period).
-- Display the member's_id, member_name, book_title, issue_date, and days overdue.

SELECT 
    ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	--rs.return_date
	CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN
members as m
ON ist.issued_member_id = m.member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE
rs.return_date IS NULL 
AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

-- Q 14  Update Book Status on Return Write a query to update the status of books in the books table to "Yes"
--       when they are returned (based on entries in the return_status table).

CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10), 
    p_issued_id VARCHAR(10), 
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    -- Insert return record
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Get book details using issued_id
    SELECT issued_book_isbn, issued_book_name 
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Mark book as available
    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;

    -- Display confirmation message
    RAISE NOTICE 'Book returned: %', v_book_name;
END;
$$;

issued_id = IS135
isbn = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');
   
--Q15 Create a query that generates a performance report for each branch, showing the number of books issued,
--    the number of books returned, and the total revenue generated from book rentals.



CREATE TABLE branch_reports
AS
SELECT 
     b.branch_id,
	 b.manager_id,
	 COUNT(ist.issued_id) as number_book_issued,
	 COUNT(rs.return_id) as number_of_book_return,
	 SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
on e.branch_id = b.branch_id
 LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;







