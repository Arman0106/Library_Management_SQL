
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


