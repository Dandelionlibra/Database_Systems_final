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

-- SELECT DISTINCT employee_name
-- FROM employee
-- WHERE employee_name
-- IN (SELECT employee_name
-- 		FROM works
-- 		WHERE company_name='First Bank');
*/

-- 為了滿足螢光筆部分的題意，加入一筆新的資料。
-- INSERT INTO works (employee_name, company_name, salary) VALUES
-- ('Karen Wright', 'First Bank', 20642);

-- a.
SELECT DISTINCT employee_name
FROM employee
WHERE employee_name
NOT IN (SELECT employee_name
		FROM works
		WHERE company_name='First Bank');
