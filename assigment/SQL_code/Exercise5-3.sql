/* Exercise5-3
 * Find all companies located in every city in where Land Bank is located.
 */
 ----------------------------------------------
SELECT company_name , city
FROM company as c1
WHERE city in(SELECT city
			 FROM company
			 WHERE company_name = 'Land Bank');
------------------------------------------------

-- SELECT city, COUNT(company_name)
-- FROM company
-- GROUP BY city