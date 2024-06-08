CREATE TABLE employee (
	employee_name varchar(255) PRIMARY KEY,
-- 	employee_name varchar(255) UNIQUE NOT NULL, -- 與上行同義
	street varchar(255),
	city varchar(255)
);

CREATE TABLE company (
	company_name varchar(255) UNIQUE PRIMARY KEY,
	city varchar(255)
);

CREATE TABLE works (
	employee_name varchar(255) references employee(employee_name),
	company_name varchar(255) references company(company_name),
	-- salary integer DEFAULT 0 CHECK (salary >= 0),
	-- CONSTRAINT positive_salary 命名錯誤，使錯誤發生時，知道是哪個錯誤發生了
	salary integer DEFAULT 0 CONSTRAINT positive_salary CHECK (salary >= 0),
	
	PRIMARY KEY(employee_name, company_name)
);

CREATE TABLE manages (
	employee_name varchar(255) references employee(employee_name),
	manager_name varchar(255) references employee(employee_name),
	PRIMARY KEY(employee_name)
);


