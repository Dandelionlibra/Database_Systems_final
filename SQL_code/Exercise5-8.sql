/* Consider the employee database.
 * Using SQL, define a view consisting of manager_name and the
 * average salary of all employees who work for that manager.
 */
CREATE VIEW employee_avg_salary AS
SELECT m.manager_name, AVG(w.salary)
FROM works as w
JOIN manages AS m ON w.employee_name = m.employee_name
GROUP BY m.manager_name

	
SELECT *
FROM employee_avg_salary
