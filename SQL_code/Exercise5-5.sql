/* Exercise5-5
 * a.Modify the database so that the employee Emily Davis now lives in Taipei.
 * b.Give all employees of First Bank a 10 percent raise.
 * c.Give all managers of First Bank a 10 percent raise.
 * d.Delete all tuples in the works relation for employees of Land Bank.
 */

-- a.
--  SELECT employee_name, city
--  FROM employee
--  WHERE employee_name = 'Emily Davis'
-----------------------------
UPDATE employee
SET city = 'Taipei'
WHERE employee_name = 'Emily Davis'
-----------------------------

--b.
--  SELECT *
--  FROM works
--  WHERE company_name = 'First Bank'
----------------------------------
UPDATE works
SET salary = salary*1.1
WHERE company_name = 'First Bank'
----------------------------------
-- UPDATE works
/*SET salary = 32324
 WHERE employee_name = 'John Doe'
 WHERE employee_name = 'Jane Smith'
 WHERE employee_name = 'Richard Perez'*/

--c.
-- SELECT *
-- FROM works
-- WHERE employee_name in (SELECT manager_name
-- 					   FROM manages) AND company_name = 'First Bank'
----------------------------------------------------------------
UPDATE works
SET salary = salary*1.1
WHERE employee_name in (SELECT manager_name
					   	FROM manages) AND company_name = 'First Bank';
----------------------------------------------------------------


--d.
-- SELECT *
-- FROM works
-- WHERE company_name = 'Land Bank';
------------------------------------------------
DELETE FROM works
WHERE company_name = 'Land Bank';
------------------------------------------------