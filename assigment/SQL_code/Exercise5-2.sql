/* Exercise5-2
 * a.Find all employees in the database who earn
 *   more than each employee of Land Bank.
 */

CREATE VIEW EX5_2 AS
--------------------------------------------------
SELECT employee_name
FROM works
WHERE salary > ALL (SELECT salary
					FROM works
					WHERE company_name='Land Bank')
---------------------------------------------------
-- SELECT *
-- FROM works
-- WHERE company_name='Land Bank';
-- Michael Johnson 32896
-- James Garcia    17236


-- SELECT employee_name, salary
-- FROM works
-- WHERE employee_name NOT IN (SELECT employee_name FROM EX5_2)


/* b.Find the company that has the most employees */

-- SELECT company_name, COUNT(employee_name)
-- FROM works
-- GROUP BY company_name;

----------------------------------------------------
SELECT company_name
FROM works
GROUP BY company_name
HAVING COUNT (DISTINCT employee_name) >= ALL (SELECT COUNT(employee_name)
											 FROM works
											 GROUP BY company_name);
-----------------------------------------------------

