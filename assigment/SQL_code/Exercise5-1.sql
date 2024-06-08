/* Exercise5-1
 * a.Find all employees in the database who do not
 *   work for First Bank. (Assumes that an employee
 *   may work for zero or more than one companies.)
 */
/*
-- 驗證程式
SELECT *
FROM works, employee
WHERE works.employee_name = employee.employee_name;
*/
-- SELECT DISTINCT employee_name
-- FROM employee
-- WHERE employee_name
-- IN (SELECT employee_name
-- 		FROM works
-- 		WHERE company_name='First Bank');


-- 為了滿足螢光筆部分的題意，加入一筆新的資料。
-- INSERT INTO works (employee_name, company_name, salary) VALUES
-- ('Karen Wright', 'First Bank', 20642);

-- a.                            !!!!!!!
-- SELECT DISTINCT employee_name
-- FROM employee
-- WHERE employee_name
-- NOT IN (SELECT employee_name
-- 		FROM works
-- 		WHERE company_name='First Bank');




/* Exercise5-1  b.
 * b.Find all employees who earn more than the average
 *   salary of all employees of their companies. (Assumes
 *   that each employee works for at most one company.)
 */ 
-- 
-- 為了滿足螢光筆部分的題意，刪除剛剛加入的新資料。
-- DELETE FROM works
-- WHERE employee_name = 'Karen Wright' AND company_name = 'First Bank';


-- 驗證程式
/*
CREATE VIEW employee_salary AS
	(SELECT company_name, AVG(salary)
	 FROM works
	 GROUP BY company_name)

SELECT *
FROM employee_salary
NATURAL JOIN works;
*/

-- SELECT employee_name, company_name, salary
-- FROM works as w1
-- WHERE salary > (SELECT AVG(salary)
-- 			   FROM works as w2
-- 			   WHERE w1.company_name = w2.company_name);

