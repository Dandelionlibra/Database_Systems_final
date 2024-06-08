/* Exercise5-4
 * a.Find the company that has the smallest payroll.
 */

-- SELECT company_name, SUM(salary) AS total_salary
-- FROM works
-- GROUP BY company_name
-- ORDER BY total_salary DESC

-----------------------------------------------------
SELECT company_name, SUM(salary)
FROM works
GROUP BY company_name
HAVING SUM(salary) <= ALL(SELECT SUM(salary)
						 FROM works
						 GROUP BY company_name);
-----------------------------------------------------

/*b.Find those companies whose employees earn a higher salary,
 *  on average, than the average salary at First bank.
 */
---------------------------------------------------------
SELECT company_name, AVG(salary)
FROM works
GROUP BY company_name
HAVING AVG(salary)>(SELECT AVG(salary)
					FROM works
				   	WHERE company_name = 'First Bank');
---------------------------------------------------------

-- SELECT company_name, AVG(salary) AS avg_salary
-- FROM works
-- GROUP BY company_name
-- ORDER BY avg_salary DESC




