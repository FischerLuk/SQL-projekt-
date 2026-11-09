CREATE TABLE t_lukas_fischer_project_sql_primary_final AS		-- vytvoření první Tabulky
WITH payroll AS (
    SELECT
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name AS industry_name,
        AVG(cp.value) AS average_salary
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
        AND cp.calculation_code = 200
        AND cp.payroll_year BETWEEN 2006 AND 2018
    GROUP BY
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name),
prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from) AS price_year,
        cp.category_code,
        cpc.name AS food_name,
        cpc.price_value,
        cpc.price_unit,
        AVG(cp.value) AS average_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE cp.region_code IS NULL
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from),
        cp.category_code,
        cpc.name,
        cpc.price_value,
        cpc.price_unit)
SELECT
    p.payroll_year,
    p.industry_branch_code,
    p.industry_name,
    ROUND(p.average_salary::numeric, 2) AS average_salary,
    pr.category_code,
    pr.food_name,
    pr.price_value,
    pr.price_unit,
    ROUND(pr.average_price::numeric, 2) AS average_price
FROM payroll p
JOIN prices pr
    ON p.payroll_year = pr.price_year; 

																	-- Vytvoření Druhé Tabulky
CREATE TABLE t_lukas_fischer_project_SQL_secondary_final AS			
SELECT
    e.country,
    c.continent,
    c.region_in_world,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM economies e
JOIN countries c
    ON e.country = c.country
WHERE c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018;

																	-- Dotaz na úkol 1.
WITH salary_data AS (												
	SELECT DISTINCT
		payroll_year,
		industry_branch_code,
		industry_name,
		average_salary
	FROM t_lukas_fischer_project_sql_primary_final
	WHERE industry_branch_code IS NOT NULL),
salary_growth AS (
	SELECT
		payroll_year,
		industry_branch_code,
		industry_name,
		average_salary,
		LAG(average_salary) OVER (
			PARTITION BY industry_branch_code
			ORDER BY payroll_year
		) AS previous_salary
	FROM salary_data)
SELECT
	payroll_year,
	industry_branch_code,
	industry_name,
	previous_salary,
	average_salary,
	average_salary - previous_salary AS difference
FROM salary_growth
WHERE average_salary < previous_salary
ORDER BY
	industry_branch_code,
	payroll_year;
																	
																	
															-- Dotaz na úkol 2.					
WITH salary AS (
	SELECT DISTINCT
		payroll_year,
		average_salary
	FROM t_lukas_fischer_project_sql_primary_final
	WHERE industry_branch_code IS NULL
		AND payroll_year IN (2006, 2018)),
food_prices AS (
	SELECT DISTINCT
		payroll_year,
		food_name,
		average_price
	FROM t_lukas_fischer_project_sql_primary_final
	WHERE food_name IN (
		'Chléb konzumní kmínový',
		'Mléko polotučné pasterované')
		AND payroll_year IN (2006, 2018))
SELECT
	f.payroll_year,
	f.food_name,
	s.average_salary,
	f.average_price,
	ROUND(
		(s.average_salary / f.average_price)::numeric, 0) AS quantity_can_buy
FROM food_prices f
JOIN salary s
	ON f.payroll_year = s.payroll_year
ORDER BY
	f.food_name,
	f.payroll_year; 
															
								
															
															--Dotaz na úkol 3.
WITH food_prices AS (
	SELECT DISTINCT
		payroll_year,
		category_code,
		food_name,
		average_price
	FROM t_lukas_fischer_project_sql_primary_final),
price_growth AS (
	SELECT
		payroll_year,
		category_code,
		food_name,
		average_price,
		LAG(average_price) OVER (
			PARTITION BY category_code
			ORDER BY payroll_year
		) AS previous_price
	FROM food_prices)
SELECT
	category_code,
	food_name,
	ROUND(AVG((average_price - previous_price) / previous_price * 100)::numeric, 2) AS avg_annual_growth_percent
FROM price_growth
WHERE previous_price IS NOT NULL
GROUP BY
	category_code,
	food_name
ORDER BY avg_annual_growth_percent;

		
															-- Dotaz na úkol 4.
WITH salary_growth AS (
	SELECT DISTINCT
		payroll_year,
		average_salary
	FROM t_lukas_fischer_project_sql_primary_final
	WHERE industry_branch_code IS NULL),
salary_change AS (
	SELECT
		payroll_year,
		(average_salary - LAG(average_salary) OVER (ORDER BY payroll_year))/LAG(average_salary) OVER (ORDER BY payroll_year) * 100 AS salary_growth_percent
	FROM salary_growth),
price_data AS (
	SELECT DISTINCT
		payroll_year,
		food_name,
		average_price
	FROM t_lukas_fischer_project_sql_primary_final),
price_average AS (
	SELECT
		payroll_year,
		AVG(average_price) AS avg_price
	FROM price_data
	GROUP BY payroll_year),
price_change AS (
	SELECT
		payroll_year,
		(avg_price - LAG(avg_price) OVER (ORDER BY payroll_year))/LAG(avg_price) OVER (ORDER BY payroll_year) * 100 AS food_growth_percent
	FROM price_average)
SELECT
	p.payroll_year,
	ROUND(p.food_growth_percent::numeric,2) AS food_growth_percent,
	ROUND(s.salary_growth_percent::numeric,2) AS salary_growth_percent,
	ROUND((p.food_growth_percent - s.salary_growth_percent)::numeric, 2) AS difference
FROM price_change p
JOIN salary_change s
	ON p.payroll_year = s.payroll_year
WHERE p.food_growth_percent IS NOT NULL
ORDER BY payroll_year;




																--Dotaz na úkol 5.
WITH gdp_data AS (
	SELECT
		year,
		gdp
	FROM t_lukas_fischer_project_sql_secondary_final
	WHERE country = 'Czech Republic'),
gdp_growth AS (
	SELECT
		year,
		(gdp- LAG(gdp) OVER (ORDER BY year))/LAG(gdp) OVER (ORDER BY year) * 100 AS gdp_growth_percent
	FROM gdp_data),
salary_data AS (
	SELECT DISTINCT
		payroll_year,
		average_salary
	FROM t_lukas_fischer_project_sql_primary_final
	WHERE industry_branch_code IS NULL),
salary_growth AS (
	SELECT
		payroll_year,
		(average_salary - LAG(average_salary) OVER (ORDER BY payroll_year))/LAG(average_salary) OVER (ORDER BY payroll_year) * 100 AS salary_growth_percent
	FROM salary_data),
food_prices AS (
	SELECT DISTINCT
		payroll_year,
		food_name,
		average_price
	FROM t_lukas_fischer_project_sql_primary_final),
food_avg AS (
	SELECT
		payroll_year,
		AVG(average_price) AS avg_price
	FROM food_prices
	GROUP BY payroll_year),
food_growth AS (
	SELECT
		payroll_year,
		(avg_price - LAG(avg_price) OVER (ORDER BY payroll_year))/LAG(avg_price) OVER (ORDER BY payroll_year) * 100 AS food_growth_percent 
		FROM food_avg)
SELECT
	g.year,
	ROUND(g.gdp_growth_percent::numeric,2) AS gdp_growth,
	ROUND(s.salary_growth_percent::numeric,2) AS salary_growth,
	ROUND(f.food_growth_percent::numeric,2) AS food_growth
FROM gdp_growth g
JOIN salary_growth s
	ON g.year = s.payroll_year
JOIN food_growth f
	ON g.year = f.payroll_year
WHERE g.gdp_growth_percent IS NOT NULL
ORDER BY g.year;


																		