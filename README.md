
# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `Lib_Man_System`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.
![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `Lib_man_System`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

```sql

-- creating required table
create table books
(
isbn varchar(20) PRIMARY KEY,
book_title varchar(55),
category varchar(20),
rental_price float,
status varchar(10),
author varchar(55),
publisher varchar(35)
)

create table branch
(
branch_id varchar(10) PRIMARY KEY,
manager_id varchar(10),
branch_address varchar(30),
contact_no varchar(20)
)

create table employees
(
emp_id varchar(10) PRIMARY KEY,
emp_name varchar(35),
position varchar(20),
salary int,
branch_id varchar(10)------FK
)

create table issued_status
(
issued_id varchar(10) PRIMARY KEY,
issued_member_id varchar(10),-------FK
issued_book_name varchar(55),
issued_date date,
issued_book_isbn varchar(25),------FK
issued_emp_id varchar(10)-------FK
)

create table members
(
member_id varchar(10) PRIMARY KEY,
member_name varchar(25),
member_address varchar(45),
reg_date date
)

create table return_status
(
return_id varchar(10) PRIMARY KEY,
issued_id varchar(10), ------FK
return_book_name varchar(50),
return_date date,
return_book_isbn varchar(20)-------FK
)

--ADDING FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT FK_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id)

ALTER TABLE issued_status
ADD CONSTRAINT FK_isbn
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)


ALTER TABLE issued_status
ADD CONSTRAINT FK_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id)

ALTER TABLE employees
ADD CONSTRAINT FK_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id)

ALTER TABLE return_status
ADD CONSTRAINT FK_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id)
```

```sql
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM members
```

--Project Task
--Data Analysis 

--CRUD Operation

**Q1. Create a New Book Record** 
--"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 
--'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
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
```

**Q2: Update an Existing Member's Address**

```sql
update members
set member_address = '555 Maplewood st'
where member_id = 'C109'

select * from members
```

**Q3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
DELETE FROM issued_status
where issued_id = 'IS121'

select * from issued_status
```

**Q4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * 
from 
	employees
where 
	emp_id = 'E101'
```

**Q5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.
```sql
select 
	issued_emp_id,
	count(*) as no_of_Issued_books
from 
	issued_status
group by 
	issued_emp_id
having
	count(*) >1
```

-- ### 3. CTAS (Create Table As Select)

**Q6: Create Summary Tables**: Used CTAS to generate new tables based on query results **
-- each book and total book_issued_cnt
```sql
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
```

-- ### 4. Data Analysis & Findings

--7. **Retrieve All Books in a Specific Category:**
```sql
select 
	book_title
from 
	books
where 
	category = 'Classic'

```

**8: Find Total Rental Income by Category:**

```sql
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
```

Q9. **List Members Who Registered in the Last 240 Days**:
```sql
select
	member_id,
	member_name,
	reg_date
from
	members
where 
	reg_date >= dateadd(day,-240,GETDATE())
```

**Q10: List Employees with Their Branch Manager's Name and their branch details**:
```sql
select 
	*
from 
	branch as a
join
	employees as e1
on 
	a.branch_id = e1.branch_id
```

**Q11. Create a Table of Books with Rental Price Above a Certain Threshold.**
```sql
select * into
	RentalPriceAboveThreshold
from 
	books
where 
	rental_price >4
```

**Q12: Retrieve the List of Books Not Yet Return.**
```sql
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
```
### Advanced SQL Operations

**Q13: Identify Members with Overdue Books**
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's name, book title, issue date, and days overdue.*/

```sql
select
	b.member_name,
	c.book_title,
	a.issued_date,
	datediff(day,a.issued_date,GETDATE()) as days_overdue
from 
	issued_status as a
Join
	members as b
on 
	a.issued_member_id = b.member_id
Join
	books as c
on
	c.isbn = a.issued_book_isbn
Left Join 
	return_status as d
on 
	d.issued_id = a.issued_id
where 
	datediff(day,a.issued_date,GETDATE()) > 30

```

**Q14: Update Book Status on Return**
--Write a query to update the status of books in the books table to "available" when 
--they are returned (based on entries in the return_status table).*/

```sql
--checking the book availabilty
select * from books
--isbn = 978-0-307-58837-1 is not available
select * from issued_status
where issued_book_isbn = '978-0-7432-7357-1'
-- having issued_id = IS135
select * from return_status
--book not return since issued_id is not mentioned


create procedure change_return_status
	@p_return_id varchar(10), --creating input parameter
	@p_issued_id varchar(10),
	@p_book_quality varchar(20)
as

Begin
	declare 
		@v_isbn varchar(25), --declaring input variable
		@v_title varchar(55)

--inserting values into table
	Insert into
		return_status(return_id,issued_id,return_date,book_quality)
	Values
		(@p_return_id,@p_issued_id,GETDATE(),@p_book_quality)

--saving output into declared variable and using in update query
	select 
		@v_isbn = issued_book_isbn,
		@v_title = issued_book_name
	from 
		issued_status
	where 
		issued_id = @p_issued_id
--update books table using saved variable
	update books
	set status = 'yes'
	where isbn = @v_isbn

	print'Thank you for returning the book :' + @v_title
End

exec change_return_status 'RS138','IS135','Good'
exec change_return_status 'RS148','IS136','Good'

```

**Task 15: Branch Performance Report**
--Create a query that generates a performance report for each branch, showing the number of books issued, 
--the number of books returned, and the total revenue generated from book rentals.*/

```sql
select  
	b.branch_id ,
	b.manager_id,
	count(i.issued_id) as IssuedBooks,
	count(r.return_id) as ReturnedBooks,
	sum(bk.rental_price) as totalRevenue
into 
	branch_report
from 
	issued_status as i
join
	employees as e
on 
	i.issued_emp_id = e.emp_id
join
	branch as b
on 
	b.branch_id = e.branch_id
left join
	return_status as r
on 
	r.issued_id = i.issued_id
join 
	books as bk
on
	bk.isbn = i.issued_book_isbn
group by 
	b.branch_id ,
	b.manager_id

select * from branch_report
```

**Task 16: CTAS: Create a Table of Active Members**
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
--containing members who have issued at least one book in the last 2 months.*/

```sql
select *
Into 
	ActiveMembers
from 
	members
where 
	member_id in
(
select 
	distinct issued_member_id
from	
	issued_status as i
where 
	DATEDIFF(day,issued_date,getdate()) <= 60
)

select * from ActiveMembers
```

**Q17: Find Employees with the Most Book Issues Processed**
--Write a query to find the top 3 employees who have processed the most book issues. 
--Display the employee name, number of books processed, and their branch.*/

```sql
select 
	e.emp_name,
	count(i.issued_id) as BooksIssued
from 
	issued_status as i
join
	employees as e
on 
	i.issued_emp_id = e.emp_id
join 
	branch as b
on	
	e.branch_id = b.branch_id
group by 
	e.emp_name
```

**Q18: Stored Procedure**
--Objective: Create a stored procedure to manage the status of books in a library system.
--Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    /*If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/

```sql
create procedure Library_system
@issued_id varchar(20),  --inout parameters
@issued_member_id varchar(20),
@issued_book_isbn varchar(20),
@issued_emp_id varchar(20)
as
Begin
	declare 
		@Sstatus varchar(10) --declaring variable to store value
	   
select
	@Sstatus = status
from 
	books
where 
	isbn = @issued_book_isbn

if @Sstatus = 'yes'
	begin
	--table is inserted with new row if status is yes
		Insert into
			issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		Values
			(@issued_id,@issued_member_id,GETDATE(),@issued_book_isbn,@issued_emp_id)
--after updating status is changed to no
		update books
		set status = 'no'
		where isbn = @issued_book_isbn
	
		print 'Book issued to :'+ @issued_id	
		print 'Book isbn:'+ @issued_book_isbn
	end
else
	begin
	--if status is already no else block will be executed
		print 'The book is not available'
	end
End

EXEC Library_System 'IS155','C108','978-0-06-025492-6','E104'
--Again checking to check its avaialabilty, an unavailabilty message will appear
EXEC Library_System 'IS155','C108','978-0-06-025492-6','E104'

SELECT * FROM books
select * from issued_status
```

**Q19: Identify Members Issuing High-Risk Books**
--Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
--Display the member name, book title, and the number of times they've issued damaged books.*/ 

```sql
select	
	c.member_name,
	a.book_title,
	d.book_quality,
	b.issued_id,
	count(b.issued_id) as Total_count
from
	books as a
join 
	issued_status as b
on
	a.isbn = b.issued_book_isbn
join
	members as c
on
	b.issued_member_id = c.member_id
join
	return_status as d
on 
	d.issued_id = b.issued_id
where 
	d.book_quality = 'damaged'
group by
	c.member_name,
	a.book_title,
	d.book_quality,
	b.issued_id
```

**Q.20: Create Table As Select (CTAS)**

/*Description: Write query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines*/

```sql
Select 
	a.member_id,
	count(*) as Total_count,
	DATEDIFF(day,b.issued_date,GETDATE()) as days_overdue,
	(DATEDIFF(day,b.issued_date,GETDATE()) - 300) * 0.5 as total_fine
from 
	members as a
Join
	issued_status as b
on 
	a.member_id = b.issued_member_id
Join
	return_status as c
on
	c.issued_id = b.issued_id
Join
	books as d
on
	d.isbn = b.issued_book_isbn
group by
	a.member_id,
	b.issued_date
having
	DATEDIFF(day,b.issued_date,GETDATE()) > 300

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   https://github.com/Arman0106/Library_Management_SQL
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Mohd Arman 
This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis.

Github - https://github.com/Arman0106

LinkedIn - www.linkedin.com/in/arman-mansuri-0a731a173
