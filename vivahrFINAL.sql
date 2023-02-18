

CREATE SCHEMA vivahr;
USE vivahr;

# Creating the final tables for the vivahr database with constraints. 

CREATE TABLE region (
	region_id INT (11) AUTO_INCREMENT PRIMARY KEY,
	region_name VARCHAR (25) DEFAULT NULL
);
#_______________________________________________________________________________________________________________


CREATE TABLE countries (
	country_id CHAR (2) PRIMARY KEY,
	country_name VARCHAR (40) DEFAULT NULL,
	region_id INT (11) NOT NULL,
    CONSTRAINT region_id_fk FOREIGN KEY (region_id) REFERENCES region (region_id) ON DELETE CASCADE ON UPDATE CASCADE 
);

#_______________________________________________________________________________________________________________


CREATE TABLE location (
	location_id INT PRIMARY KEY,
	street_address VARCHAR (40) DEFAULT NULL,
	postal_code VARCHAR (12) DEFAULT NULL,
	city VARCHAR (30) NOT NULL,
	state_province VARCHAR (25) DEFAULT NULL,
	country_id CHAR (2) NOT NULL,
	CONSTRAINT countries_id_fk FOREIGN KEY (country_id) REFERENCES countries (country_id) ON DELETE CASCADE ON UPDATE CASCADE 
);

#_______________________________________________________________________________________________________________

CREATE TABLE department (
	department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR (50),
    UNIQUE KEY department_name (department_name)
);

#_______________________________________________________________________________________________________________


CREATE TABLE job (
	job_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    job_title VARCHAR (50) NOT NULL,
    min_salary DOUBLE(7,2) NOT NULL,
    max_salary DOUBLE(7,2) NOT NULL,
    department_name  VARCHAR (50) NOT NULL,
    reports_to VARCHAR (50),
	CONSTRAINT department_name_fk FOREIGN KEY (department_name) REFERENCES department (department_name) ON DELETE CASCADE ON UPDATE CASCADE
);

#_______________________________________________________________________________________________________________


CREATE TABLE manager (
	manager_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT,
    job_title VARCHAR (50),
    full_name VARCHAR (50) NOT NULL,
    location_id INT (10) default null,
	CONSTRAINT job_id_fk FOREIGN KEY (job_id) REFERENCES job (job_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT location_id_fk FOREIGN KEY (location_id) REFERENCES location (location_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

#_______________________________________________________________________________________________________________

CREATE TABLE employee (
	employee_id INT PRIMARY KEY, 
    first_name VARCHAR (50),
    last_name VARCHAR (50),
    email VARCHAR (255),
    phone_number VARCHAR (50) DEFAULT NULL,
    job_id INT,
    salary DOUBLE(7,2) DEFAULT NULL,
    manager_id VARCHAR (50) DEFAULT NULL,
    department_id INT,
    hire_date DATE,
    reports_to VARCHAR (50) DEFAULT NULL,
    experience_at_VivaK INT DEFAULT NULL,
    last_performance_rating DOUBLE DEFAULT NULL,
    salary_after_increment DOUBLE DEFAULT NULL,
    annual_dependent_benefits DOUBLE DEFAULT NULL,
	CONSTRAINT fk_job_id FOREIGN KEY (job_id) REFERENCES job (job_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT department_id_fk FOREIGN KEY (department_id) REFERENCES department (department_id) ON DELETE CASCADE ON UPDATE CASCADE
);

#_______________________________________________________________________________________________________________

CREATE TABLE dependent (
	dependent_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR (50),
    last_name VARCHAR (50),
    relationship VARCHAR (50),
    employee_id INT
);

#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________

# Importing the data from the database that contains all the data after importing it 
# there using the import wizzard 

insert into vivahr.region (region_name) select (region_name) 
from vivahr_test.regions;

#select * from region;

insert into vivahr.countries (country_id, country_name, region_id) select country_id, country_name, region_id
from vivahr_test.countries;

#select * from countries;

insert into vivahr.location (location_id, street_address, postal_code, city, state_province, country_id) select location_id, street_address, postal_code, city, state_province, country_id
from vivahr_test.locations;

#select * from location;

insert into vivahr.department (department_id, department_name) select department_id, department_name
from vivahr_test.department;

#select * from department;

insert into vivahr.job (job_id, job_title, min_salary, max_salary, department_name, reports_to) select job_id, job_title, min_salary, max_salary, department_name, reports_to
from vivahr_test.orgstructure;

#select * from job;

insert into vivahr.manager (job_id, job_title, full_name, location_id)
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_1400
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_1500
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_1700
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_1800
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_2400
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_2500
UNION ALL 
SELECT job_id, job_title, `Full Name`, location_id
FROM vivahr_test.location_2700;


#select * from manager;

insert into vivahr.dependent (first_name, last_name, relationship, employee_id) select first_name, last_name, relationship, employee_id 
from vivahr_test.dependent;

insert into vivahr.employee (employee_id, first_name, last_name, email, phone_number, job_id, salary, manager_id, department_id, hire_date) select employee_id, first_name, last_name, email, phone_number, job_id, salary, manager_id, department_id, hire_date
from vivahr_test.employee;

#select * from employee;



#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________

ALTER TABLE employee # In order to fufill the requirement that all ID columns must be integer
DROP COLUMN manager_id;  # we dropped the manager_id column which is a TEXT

ALTER TABLE employee   #and added it back as  TINYINT,  which fufills the requiremnets
ADD COLUMN manager_id INT DEFAULT NULL;


#In order to create a relationship between th table dependent and employees, we need to make sure that the refrencing column 
#employee_id matches in both tables

#SELECT *         # here we select all the columns in Dependent 
#FROM dependent
#LEFT JOIN employee  # and using a left join we select all the records 
# ON employee.employee_id = dependent.employee_id  #in the dependent table
#WHERE employee.employee_id IS NULL;  #that do not have a matching employee_id  record with the employees table 


DELETE FROM dependent # then we delete this records from the database
WHERE employee_id NOT IN (
  SELECT employee_id
  FROM employee
);

#Now we can create the relationship between the tables dependent and employees without any issues.

ALTER TABLE dependent   #we altered the table dependent
	ADD CONSTRAINT dependentFK_employees  
        FOREIGN KEY (employee_id)   # we specified that the column employee_id is a foreign key from the table employees
        REFERENCES employee(employee_id)
        ON DELETE CASCADE  
        ON UPDATE CASCADE;
        
        
#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________
#_______________________________________________________________________________________________________________

# Tast 3

# changing the phone number and adding the area code depending on which city 

# Adding department_id column to the location table 
alter table location add column department_id INT AUTO_INCREMENT UNIQUE KEY;

#Updating the location and and employee table so the department_id column on both match 
update location
join employee on employee.department_id = location.department_id
set location.department_id = employee.department_id;

# Adding the column country_area to have the country id in the employee table through now the department_id 
alter table employee add column country_area VARCHAR(50) DEFAULT NULL;

update employee 
join location on employee.department_id = location.department_id
set employee.country_area = location.country_id;


#First I corrected the phone_number column with the right format
UPDATE employee SET phone_number = 
CONCAT(
    SUBSTR(REPLACE(REPLACE(phone_number, '.', ''), '-', ''), 1, 3),
    '-',
    SUBSTR(REPLACE(REPLACE(phone_number, '.', ''), '-', ''), 4, 3),
    '-',
    SUBSTR(REPLACE(REPLACE(phone_number, '.', ''), '-', ''), 7)
)
WHERE CHAR_LENGTH(REPLACE(REPLACE(phone_number, '.', ''), '-', '')) = 10 OR CHAR_LENGTH(REPLACE(REPLACE(phone_number, '.', ''), '-', '')) = 11;

# Now with the phone_number column with the correct format i concated the area code depending on the country area each employee is at.
update employee 
set phone_number = (case 
when country_area = 'US' THEN concat('+1-', phone_number)
when country_area = 'UK' THEN concat('+44-', phone_number)
when country_area = 'CA' THEN concat('+1-', phone_number)
when country_area = 'DE' then concat('+45-', phone_number)
end);


# now we can drop the country_area column 
alter table employee drop column country_area;

#_______________________________________________________________________________________________________________

# Task 3 --- Question 3 

# Filling in the reports_to column by joining the employee table and job table that has the reports_to column
update employee 
join job on employee.job_id = job.job_id
set employee.reports_to = job.reports_to
WHERE employee.reports_to IS NULL;

# treating the missing values in salary
UPDATE employee e
INNER JOIN (
  SELECT department_id, AVG(salary) AS avg_salary
  FROM employee
  WHERE salary > 0
  GROUP BY department_id
) s ON e.department_id = s.department_id
SET e.salary = s.avg_salary
WHERE e.salary = 0;


#_______________________________________________________________________________________________________________

# Task 4 

# Filling in the experience_at_VivaK with number of month from hire date to current date

# First i added the column todays date with null values to later fill with the current date
alter table employee add column todays_date DATE default null;

#Updating the todays date column with todays date
update employee
set todays_date = current_date
where todays_date IS NULL;

# Updating the experience_at_VivaK column by making the calculationg between hire_date column and todays_date column 
# and divided it by 30 to have the experience_at_VivaK be by how many months
update employee 
set experience_at_VivaK = DATEDIFF(todays_date, hire_date) / 30
where experience_at_VivaK IS NULL;

# Dropping todays_date column now that we dont need it
alter table employee drop column todays_date; 

#_______________________________________________________________________________________________________________

# Creating random numbers with 2 decimal places for last_performance_rating column

update employee 
set last_performance_rating = ROUND(RAND()*(1-0),2)
WHERE last_performance_rating IS NULL;

#_______________________________________________________________________________________________________________

# adding the rating_increment column
alter table employee add column rating_increment double DEFAULT NULL;

# filling the rating_increment column with the specifications given
update employee 
set rating_increment = (case 
WHEN last_performance_rating >= 0.9 Then 0.15
WHEN last_performance_rating >= 0.8 Then 0.12
WHEN last_performance_rating >= 0.7 Then 0.10
WHEN last_performance_rating >= 0.6 Then 0.08
WHEN last_performance_rating >= 0.5 Then 0.05
WHEN last_performance_rating < 0.5 Then 0.02
END)
WHERE rating_increment IS NULL;


# Creating the increment table to later multiply that with salary
alter table employee add column increment double default null; 

# Updating the increment column with the specification given and divided it experience_at_VivaK by 12 month to have the 
#Salary after increment by by how many years the persons been on the company and not months
update employee 
set increment = ROUND(1+(0.01 * (experience_at_VivaK/12))+rating_increment,2)
where increment IS NULL; 

# Updating the final salary_after_increment table 
update employee 
set salary_after_increment = ROUND(salary * increment, 2)
WHERE salary_after_increment IS NULL; 


# Now adding a cap for the salary for each employee so the salary_after_increment column doesnt go over the cap 
# adding the max salary cap to the salary_after_increment 
alter table employee add column max_salary FLOAT default null; 

update employee 
join job on employee.job_id = job.job_id
set employee.max_salary = job.max_salary
WHERE employee.max_salary IS NULL;

update employee 
set salary_after_increment = Case
WHEN salary_after_increment >  max_salary Then max_salary
else salary_after_increment
end; 


# Dropping the now unecessary columns 
alter table employee drop column max_salary;
alter table employee drop column increment;
alter table employee drop column rating_increment;
#_______________________________________________________________________________________________________________

# Task 4 --- Question 4 


# Updating the annual_dependent_benefits column with the right specifications 
update employee 
join dependent on employee.employee_id = dependent.employee_id
set annual_dependent_benefits = (case
WHEN job_id = 1 Then ROUND(0.2 * salary,2)
WHEN job_id = 2 Then ROUND(0.2 * salary,2)
WHEN job_id = 3 Then ROUND(0.2 * salary,2)
WHEN job_id = 4 Then ROUND(0.15 * salary,2)
WHEN job_id = 5 Then ROUND(0.15 * salary,2)
WHEN job_id = 6 Then ROUND(0.15 * salary,2)
WHEN job_id = 7 Then ROUND(0.15 * salary,2)
WHEN job_id = 8 Then ROUND(0.15 * salary,2)
WHEN job_id = 9 Then ROUND(0.15 * salary,2)
WHEN job_id = 10 Then ROUND(0.15 * salary,2)
WHEN job_id = 11 Then ROUND(0.15 * salary,2)
WHEN job_id = 12 Then ROUND(0.15 * salary,2)
WHEN job_id = 13 Then ROUND(0.15 * salary,2)
ELSE 0.05 * salary
END)
WHERE annual_dependent_benefits IS NULL;

#_______________________________________________________________________________________________________________


# changing all the email afer the @ with vivaK.com 
UPDATE employee SET email = REPLACE(email, SUBSTRING(email,INSTR(email,'@')+1),
'vivaK.com');



