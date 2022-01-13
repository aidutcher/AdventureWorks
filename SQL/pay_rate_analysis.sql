--Examining pay rate and length of employment.
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
Grouping by job title.

Nothing too surprising. Engineer, Senior, Manager, and C-Suite roles pay more.

We can more closely examine variability within job titles with the HAVING clause.
Most have 0 range, but Production Technicians have next lowest range at 3.00.
Senior Tool Designer has highest range at 21.23.
*/
SELECT 
	Employee.JobTitle
,	ROUND(MIN(Pay.Rate),2) AS 'LowestRate'
,	ROUND(MAX(Pay.Rate),2) AS 'HighestRate'
,	ROUND(AVG(Pay.Rate),2) AS 'Avg Rate'
,	ROUND((MAX(Pay.Rate) - MIN(Pay.Rate)),2) AS 'Range'
FROM HumanResources.Employee Employee
LEFT JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
GROUP BY Employee.JobTitle
--HAVING MAX(Pay.Rate) - MIN(Pay.Rate) <> 0
ORDER BY AVG(Pay.Rate);

-- Grouping by gender.
SELECT 
	Employee.Gender
,	COUNT(Employee.Gender) AS 'Count'
,	ROUND(MIN(Pay.Rate),2) AS 'LowestRate'
,	ROUND(MAX(Pay.Rate),2) AS 'HighestRate'
,	ROUND(AVG(Pay.Rate),2) AS 'Avg Rate'
,	ROUND((MAX(Pay.Rate) - MIN(Pay.Rate)),2) AS 'Range'
FROM HumanResources.Employee Employee
LEFT JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
GROUP BY Employee.Gender
--HAVING MAX(Pay.Rate) - MIN(Pay.Rate) <> 0
ORDER BY AVG(Pay.Rate);
/*
We find that women have a higher LowestRate, a higher AvgRate, and a lower range.
Women also account for just 28% of the work force.

Gender	Count	LowestRate	HighestRate		AvgRate		Range
M		228		6.50		125.50			17.0025		119.00
F		88		9.00		63.4615			19.7182		54.4615
*/

--Checking number of men and women with each job title.
SELECT 
	Employee.JobTitle
,	SUM(CASE WHEN Employee.Gender = 'M' THEN 1 ELSE 0 END) AS 'M'
,	SUM(CASE WHEN Employee.Gender = 'F' THEN 1 ELSE 0 END) AS 'F'
FROM HumanResources.Employee Employee
GROUP BY Employee.JobTitle;
/*
Most roles have more men than women, which makes sense considering that women are 28% percent of the workforce.  

JobTitle									M	F
Accountant									1	1
Accounts Manager							1	0
Accounts Payable Specialist					1	1
Accounts Receivable Specialist				1	2
Application Specialist						2	2
Assistant to the Chief Financial Officer	1	0
Benefits Specialist							0	1
Buyer										7	2
Chief Executive Officer						1	0
Chief Financial Officer						0	1
Control Specialist							2	0
Database Administrator						2	0
Design Engineer								1	2
Document Control Assistant					1	1
Document Control Manager					1	0
Engineering Manager							1	0
European Sales Manager						0	1
Facilities Administrative Assistant			1	0
Facilities Manager							1	0
Finance Manager								0	1
Human Resources Administrative Assistant	2	0
Human Resources Manager						0	1
Information Services Manager				0	1
Janitor										2	2
Maintenance Supervisor						1	0
Marketing Assistant							1	2
Marketing Manager							1	0
Marketing Specialist						3	2
Master Scheduler							1	0
Network Administrator						2	0
Network Manager								0	1
North American Sales Manager				1	0
Pacific Sales Manager						1	0
Production Control Manager					1	0
Production Supervisor - WC10				3	0
Production Supervisor - WC20				2	1
Production Supervisor - WC30				2	1
Production Supervisor - WC40				2	1
Production Supervisor - WC45				2	1
Production Supervisor - WC50				3	0
Production Supervisor - WC60				1	2
Production Technician - WC10				9	8
Production Technician - WC20				16	6
Production Technician - WC30				20	5
Production Technician - WC40				23	3
Production Technician - WC45				10	5
Production Technician - WC50				19	7
Production Technician - WC60				20	6
Purchasing Assistant						1	1
Purchasing Manager							0	1
Quality Assurance Manager					1	0
Quality Assurance Supervisor				1	0
Quality Assurance Technician				4	0
Recruiter									2	0
Research and Development Engineer			0	2
Research and Development Manager			2	0
Sales Representative						8	6
Scheduling Assistant						4	0
Senior Design Engineer						1	0
Senior Tool Designer						2	0
Shipping and Receiving Clerk				2	0
Shipping and Receiving Supervisor			1	0
Stocker										1	2
Tool Designer								1	1
Vice President of Engineering				0	1
Vice President of Production				1	0
Vice President of Sales						1	0
*/

--How many men and women are there with titles that include specific keywords?
SELECT 
	CASE
		WHEN Employee.JobTitle LIKE '%Technician' THEN 'Technician'
		WHEN Employee.JobTitle LIKE '%Engineer' THEN 'Engineer'
		WHEN Employee.JobTitle LIKE '%Administrator' THEN 'Administrator'
		WHEN Employee.JobTitle LIKE '%Assistant' THEN 'Assistant'
		WHEN Employee.JobTitle LIKE '%Manager' THEN 'Manager'
		WHEN Employee.JobTitle LIKE '%Supervisor' THEN 'Supervisor'
		WHEN Employee.JobTitle LIKE '%Specialist' THEN 'Specialist'
		WHEN Employee.JobTitle LIKE '%Officer' THEN 'Officer'
		WHEN Employee.JobTitle LIKE '%President' THEN 'President'
		ELSE 'Other'
	END AS 'Title'
,	SUM(CASE WHEN Employee.Gender = 'M' THEN 1 ELSE 0 END) AS 'M'
,	SUM(CASE WHEN Employee.Gender = 'F' THEN 1 ELSE 0 END) AS 'F'
FROM HumanResources.Employee Employee
GROUP BY 
	CASE
		WHEN Employee.JobTitle LIKE '%Technician' THEN 'Technician'
		WHEN Employee.JobTitle LIKE '%Engineer' THEN 'Engineer'
		WHEN Employee.JobTitle LIKE '%Administrator' THEN 'Administrator'
		WHEN Employee.JobTitle LIKE '%Assistant' THEN 'Assistant'
		WHEN Employee.JobTitle LIKE '%Manager' THEN 'Manager'
		WHEN Employee.JobTitle LIKE '%Supervisor' THEN 'Supervisor'
		WHEN Employee.JobTitle LIKE '%Specialist' THEN 'Specialist'
		WHEN Employee.JobTitle LIKE '%Officer' THEN 'Officer'
		WHEN Employee.JobTitle LIKE '%President' THEN 'President'
		ELSE 'Other'
	END;
/*
There are more men with every title except 'Engineer.'

Title			M	F
Administrator	4	0
Assistant		10	4
Engineer		2	4
Manager			11	6
Officer			2	1
Other			161	61
Specialist		9	8
Supervisor		3	0
Technician		4	0
*/

--How does the pay for men and women with each title compare?
SELECT 
	CASE
		WHEN Employee.JobTitle LIKE '%Technician' THEN 'Technician'
		WHEN Employee.JobTitle LIKE '%Engineer' THEN 'Engineer'
		WHEN Employee.JobTitle LIKE '%Administrator' THEN 'Administrator'
		WHEN Employee.JobTitle LIKE '%Assistant' THEN 'Assistant'
		WHEN Employee.JobTitle LIKE '%Manager' THEN 'Manager'
		WHEN Employee.JobTitle LIKE '%Supervisor' THEN 'Supervisor'
		WHEN Employee.JobTitle LIKE '%Specialist' THEN 'Specialist'
		WHEN Employee.JobTitle LIKE '%Officer' THEN 'Officer'
		WHEN Employee.JobTitle LIKE '%President' THEN 'President'
		ELSE 'Other'
	END AS 'Title'
,	SUM(CASE WHEN Employee.Gender = 'M' THEN 1 ELSE 0 END) AS 'M'
,	ROUND(AVG(CASE WHEN Employee.Gender = 'M' THEN Pay.Rate ELSE NULL END),2) AS 'AvgPayM'
,	SUM(CASE WHEN Employee.Gender = 'F' THEN 1 ELSE 0 END) AS 'F'
,	ROUND(AVG(CASE WHEN Employee.Gender = 'F' THEN Pay.Rate ELSE NULL END),2) AS 'AvgPayF'
FROM HumanResources.Employee Employee
JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
GROUP BY 
	CASE
		WHEN Employee.JobTitle LIKE '%Technician' THEN 'Technician'
		WHEN Employee.JobTitle LIKE '%Engineer' THEN 'Engineer'
		WHEN Employee.JobTitle LIKE '%Administrator' THEN 'Administrator'
		WHEN Employee.JobTitle LIKE '%Assistant' THEN 'Assistant'
		WHEN Employee.JobTitle LIKE '%Manager' THEN 'Manager'
		WHEN Employee.JobTitle LIKE '%Supervisor' THEN 'Supervisor'
		WHEN Employee.JobTitle LIKE '%Specialist' THEN 'Specialist'
		WHEN Employee.JobTitle LIKE '%Officer' THEN 'Officer'
		WHEN Employee.JobTitle LIKE '%President' THEN 'President'
		ELSE 'Other'
	END;
/*
Excluding nulls, men make more on average 3 out of 6 categories. 
Men who are Officers make substantially more on average than women, likely because of the CEO. 

Title			M		AvgPayM		F		AvgPayF
Administrator	4		35.46		0		NULL
Assistant		12		13.35		4		12.48
Engineer		2		34.38		4		36.78
Manager			13		34.82		8		33.88
Officer			2		69.48		3		49.24
Other			179		14.75		61		15.77
Specialist		9		18.86		8		19.66
Supervisor		3		20.43		0		NULL
Technician		4		10.58		0		NULL
*/

--How does pay for salaried compare to hourly?
SELECT 
	CASE
		WHEN Employee.SalariedFlag = 1 THEN 'Salaried'
		ELSE 'Hourly'
	END AS 'PayType'
,	COUNT(Employee.SalariedFlag) AS 'Count'
,	MIN(Pay.Rate) AS 'LowestRate'
,	ROUND(MAX(Pay.Rate),2) AS 'HighestRate'
,	ROUND(AVG(Pay.Rate),2) AS 'AvgRate'
,	ROUND((MAX(Pay.Rate) - MIN(Pay.Rate)),2) AS 'Range'
FROM HumanResources.Employee Employee
JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
-- WHERE Employee.JobTitle <> 'Chief Executive Officer'
GROUP BY
	CASE
		WHEN Employee.SalariedFlag = 1 THEN 'Salaried'
		ELSE 'Hourly'
	END;
/*
Salaried employees make almost 3x as much on average than hourly employees, even excluding the CEO.

PayType		Count	LowestRate		HighestRate		AvgRate		Range
Hourly		258		6.50			32.45			13.85		25.95
Salaried	58		9.86			125.50			35.15		115.64
*/