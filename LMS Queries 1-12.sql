SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM members

--Project Task

--CRUD Operation

--Q1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 
--'Harper Lee', 'J.B. Lippincott & Co.')"

create table NewBooks
as
insert into 
	books(isbn,book_title,category,rental_price,status,author,publisher)
values
	('978-1-60129-456-2', 
	'To Kill a Mockingbird', 
	'Classic', 
	 6.00, 
	'yes',
	'Harper Lee',
	'J.B. Lippincott & Co.')
select * from books

--Q2: Update an Existing Member's Address

update members
set member_address = '555 Maplewood st'
where member_id = 'C109'

select * from members

--Q3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
where issued_id = 'IS121'

select * from issued_status

--Q4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * 
from 
	employees
where 
	emp_id = 'E101'

--Q5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select 
	issued_emp_id,
	count(*) as no_of_Issued_books
from 
	issued_status
group by 
	issued_emp_id
having
	count(*) >1

-- ### 3. CTAS (Create Table As Select)

--Q6: Create Summary Tables**: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt

select
	b.isbn,
	b.book_title,
	count(a.issued_id) as issued_count
into
	Issued_book
from
	issued_status as a
join 
	books as b
on
	a.issued_book_isbn = b.isbn
group by 
	b.isbn,b.book_title

select * from Issued_book

-- ### 4. Data Analysis & Findings

--7. **Retrieve All Books in a Specific Category:

select 
	book_title
from 
	books
where 
	category = 'Classic'

--8: Find Total Rental Income by Category:

select
	category,
	sum(rental_price) as Total_rent,
	count(*) as count
from
	books as a
Join
	issued_status as b
on
	a.isbn = b.issued_book_isbn
group by 
	a.category

--Q9. **List Members Who Registered in the Last 240 Days**:

select
	member_id,
	member_name,
	reg_date
from
	members
where 
	reg_date >= dateadd(day,-240,GETDATE())

--Q10: List Employees with Their Branch Manager's Name and their branch details**:

select 
	*
from 
	branch as a
join
	employees as e1
on 
	a.branch_id = e1.branch_id

--Q11. Create a Table of Books with Rental Price Above a Certain Threshold.

select * into
	RentalPriceAboveThreshold
from 
	books
where 
	rental_price >4

--Q12: Retrieve the List of Books Not Yet Return.

select 
	distinct i.issued_book_isbn,i.issued_book_name
from 
	issued_status as i
Left Join
	return_status as r
on
	i.issued_id = r.issued_id
where 
	r.return_id is NULL


