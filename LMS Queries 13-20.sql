SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM members

/*### Advanced SQL Operations

Q13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.*/

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


/*Q14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when 
they are returned (based on entries in the return_status table).*/

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

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

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

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.*/


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

/*Q17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

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

/*Q18: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/

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
SELECT * FROM return_status

/*Q19: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/ 

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


/*Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 300 days. 
	The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines*/
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


SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM members