/*
Examining pay rate and length of employment.
We find that newer employees make significantly more on average than older employees.

YearsEmployed	Avg Rate
9				31.4182
10				29.3329
11				26.9966
12				15.1051
13				17.3973
14				17.5099
15				29.0128
16				12.45
*/
WITH PayRate AS (
SELECT
	Person.BusinessEntityID
,	Person.FirstName + ' ' + Person.LastName AS 'Name'
,	Employee.HireDate
,	DATEDIFF(year,Employee.HireDate,GETDATE()) AS 'YearsEmployed'
-- Some employees appear with mulitple rates, we'll use the highest rate
,	MAX(Pay.Rate) AS 'Rate'
,	Pay.PayFrequency
FROM HumanResources.Employee Employee
LEFT JOIN Person.Person Person ON Employee.BusinessEntityID = Person.BusinessEntityID 
LEFT JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
GROUP BY 
	Person.BusinessEntityID
,	Person.FirstName + ' ' + Person.LastName
,	Employee.HireDate
,	DATEDIFF(year,Employee.HireDate,GETDATE())
,	Pay.PayFrequency
)
SELECT 
	PayRate.YearsEmployed
,	AVG(PayRate.Rate) AS 'Avg Rate'
FROM PayRate
GROUP BY PayRate.YearsEmployed;

/*
Examining pay rate and job title.
The lowest paid employees are Production Technicians at 6.50.
The highest paid is the Chief Executive Officer at 125.50 (19.31x the lowest rate).

*/
SELECT 
	Person.FirstName + ' ' + Person.LastName AS 'Name'
,	Employee.JobTitle
,	Pay.Rate
FROM HumanResources.Employee Employee
LEFT JOIN Person.Person Person ON Employee.BusinessEntityID = Person.BusinessEntityID 
LEFT JOIN HumanResources.EmployeePayHistory Pay ON Person.BusinessEntityID = Pay.BusinessEntityID
ORDER BY Pay.Rate DESC;

/*
Grouping by job description.

Nothing too surprising. Engineer, Senior, Manager, and C-Suite roles pay more.

We can more closely examine variability within job titles with the HAVING clause.
Most have 0 range, but Production Technicians have next lowest range at 3.00.
Senior Tool Designer has highest range at 21.23.
*/
SELECT 
	Employee.JobTitle
,	MIN(Pay.Rate) AS 'LowestRate'
,	MAX(Pay.Rate) AS 'HighestRate'
,	AVG(Pay.Rate) AS 'Avg Rate'
,	MAX(Pay.Rate) - MIN(Pay.Rate) AS 'Range'
FROM HumanResources.Employee Employee
LEFT JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
GROUP BY Employee.JobTitle
--HAVING MAX(Pay.Rate) - MIN(Pay.Rate) <> 0
ORDER BY AVG(Pay.Rate);
