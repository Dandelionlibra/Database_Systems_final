/* Exercise5-1  b.
 * b.Find all employees who earn more than the average
 *   salary of all employees of their companies. (Assumes
 *   that each employee works for at most one company.)
 */ 
-- 
-- 為了滿足螢光筆部分的題意，刪除剛剛加入的新資料。
DELETE FROM works
WHERE employee_name = 'Karen Wright' AND company_name = 'First Bank';


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

SELECT employee_name, company_name, salary
FROM works as w1
WHERE salary > (SELECT AVG(salary)
			   FROM works as w2
			   WHERE w1.company_name = w2.company_name);
