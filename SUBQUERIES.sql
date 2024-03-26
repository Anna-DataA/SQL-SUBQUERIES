-- upload employees data from csv file; 

select * from employees;

-- create new table departments

create table departments
(dept_id int,
 department varchar(50) primary key, 
 location varchar(100)
);

insert into departments 
values(1,'IT', 'Toronto');

insert into departments 
values(2,'HR', 'Vancouver'), (3, 'FIN', 'Vancouver'),
(4, 'SALES','Montreal'),(5,'PURC','Calgary'),(6,'MARK','Toronto');


select * from departments;

-- Add foreign key to the employees table

ALTER TABLE employees
ADD FOREIGN KEY (department)
REFERENCES departments(department)
ON DELETE SET NULL;


-- 1. Find the employees who's salary is more than the avg salary earned by all emplpoyees

select round(avg(salary),0)
from employees;

select * from employees -- main quyery/ ounter query
where salary > (select round(avg(salary),0)
from employees); -- subquery/ inner query


-- 2. Scaler subquery ( only fetches 1 row & 1 column
-- always return 1 row and 1 collumn 

select * from employees e
join (select round(avg(salary),0) sal from employees) avg_sal
	on e.salary > avg_sal.sal;


select e.* from employees e
join (select round(avg(salary),0) sal from employees) avg_sal
	on e.salary > avg_sal.sal;
	
-- 3. Multiple Row subquery
-- 3.1 Subquery which returns miltiple rows and collumns
-- Find the employees who earned the highest salary in each department

select department, max(salary)
from employees
group by department;

select * from employees
where (department, salary) in (select department, max(salary)
from employees
group by department);

-- 3.2 Subquery which returns miltiple rows and 1 collumn
-- find department which do not have any employees

insert into departments
values(7,'COMPLIANCE','Saskatoon');

insert into departments
values(default,'ACOUNTING','Vancouver');

select * from departments 
where department not in
(select distinct department from employees);


-- Co-related subqueries
-- A subquery which is related to the outer query
-- Find the employees in each deparment who earn more than avg salary in that department

select avg(salary) from employees 
where  deparment = "specific_dept"

select * 
from employees e1
where salary > (select avg(salary) 
				from employees e2
				where  e2.department = e1.department);
				
--Find deparemnt which do not have any employees

select * 
from departments d
where not exists (select 1 from employees e where e.department = d.department);


-- Nested subquery
-- create new table for practice

create table sales 
(warehouse_id int,
 warehouse_name varchar(50), 
 product_name varchar(50),
 quantity int,
 price int);
 

insert into sales 
values 
(1,'Vancouver','Polo',100,15),
(2,'Calgary','Jacket',50,100),
(3,'Edmonton','Hjacket',100,150),
(1,'Vancouver','Fleece',80,45),
(1,'Vancouver','Activeware',300,39),
(4,'Richmond','Hoodies',115,55),
(5,'Vancouver','TEES',89,25),
(6,'Toronto','Parka',200,350),
(7,'Northvancouver','Polo',250,15),
(6,'Toronto','Fleece',100,45);


select * from sales;

-- Find the warehouse which has better sales than the avg sales across all stores
/* 1 find total sales for each warehouse*/

select warehouse_name, (sum(price) * sum(quantity)) as total_sales
from sales
group by warehouse_name; 

/* 2. find avg sales for all warehouse */

select avg(total_sales)
from (select warehouse_name, (sum(price) * sum(quantity)) as total_sales
from sales
group by warehouse_name) x ;

/* 3. compare 1 and 1 */

select *
	from (select warehouse_name, (sum(price) * sum(quantity)) as total_sales
	from sales
	group by warehouse_name) sales
join
	(select avg(total_sales) as sales
	from (select warehouse_name, (sum(price) * sum(quantity)) as total_sales
		from sales
		group by warehouse_name) x) avg_sales
on sales.total_sales > avg_sales.sales;

-- other solution:

with sales as 
	(select warehouse_name, (sum(price) * sum(quantity)) as total_sales
	from sales
	group by warehouse_name) 
select *
from sales
join
	(select avg(total_sales) as sales
	from sales x) avg_sales
	on sales.total_sales > avg_sales.sales;


-- Different Clause where subquery is allowed. ( select, from, where, having )

-- fetch all employees details and add remarks to these employees who earn more than avg salary

-- option 1: not recommended 

select * 
, (case when salary > (select avg(salary) from employees)
			then 'higher than avg'
	else null
	end)
as remarks 
from employees;

-- option2: recommended 

select * 
, (case when salary > avg_sal.sal
			then 'higher than avg'
	else null
	end)
as remarks 
from employees
cross join (select avg(salary) sal from employees) avg_sal;

-- HAVING CLAUSE 

-- Find the warehouse which has sold more units than avg units sold by all warehouses.

select * from sales; 

select warehouse_name, sum(quantity)
from sales
group by warehouse_name;

select avg(quantity) 
from sales;


select warehouse_name, sum(quantity)
from sales
group by warehouse_name
having sum(quantity) > (select avg(quantity) 
from sales);

-- SQL commands that allow subquery ( insert, update, delete )

-- Insert data to the employees history table. Make sure nnit insert duplicate records
 
create table employee_history
(emp_id  varchar(50) primary key,
emp_name varchar(20),
 dept_name varchar(20),
 salary int, 
 location  varchar(20));
 
insert into employee_history 
select e.employee_id, e.first_name, d.department, e.salary, d.location
from employees e 
join departments d on d.department = e.department
where not exists (select 1 from employee_history eh
				 where eh.emp_id = e.employee_id);
				 
select * from employee_history;

/*Give 10% increment to all employees in Vancouver  
location based on the maximun salary earned by an employee in each dept. 
Only consider employees in history table*/

update employees e 
set salary = (select max(salary) + (max(salary) * 0.1)
			from employee_history eh
			where eh.dept_name = e.department)
where e.department in (select department 
					  from departments 
					  where location = 'Vancouver')
and e.employee_id in (select emp_id from employee_history);

select * from employee_history;


--DELETE 
--delete all department which do not have any employees

delete from department 
where department in 

select department from departments d
where not exists (select 1 from employees e where e.department = d.department);


delete from department 
where department in (
select department from departments d
where not exists (select 1 from employees e where e.department = d.department));