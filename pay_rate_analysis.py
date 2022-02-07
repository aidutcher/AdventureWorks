# -*- coding: utf-8 -*-

"""
Writes the results of the pay_rate_analysis SQL queries to CSV files 
for use in Tableau/Power BI
"""

import pyodbc
import pandas as pd

server = 'servername' 
database = 'dbname' 
username = 'username'
password = 'password' 
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';TRUSTED_CONNECTION=yes')
cursor = cnxn.cursor()

def write_avg_pay_by_yrs_employed():
    sql = """WITH PayRate AS ( 
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
    GROUP BY PayRate.YearsEmployed;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\avg_pay_by_yrs_employed')

def write_pay_rate_by_job_title_per_employee():
    sql = """SELECT 
        	Person.FirstName + ' ' + Person.LastName AS 'Name'
            ,	Employee.JobTitle
            ,	Pay.Rate
            FROM HumanResources.Employee Employee
            LEFT JOIN Person.Person Person ON Employee.BusinessEntityID = Person.BusinessEntityID 
            LEFT JOIN HumanResources.EmployeePayHistory Pay ON Person.BusinessEntityID = Pay.BusinessEntityID
            ORDER BY Pay.Rate DESC;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\pay_rate_by_job_title_per_employee')
    
def write_pay_rate_by_job_title_grouped():
    sql = """SELECT 
            	Employee.JobTitle
            ,	ROUND(MIN(Pay.Rate),2) AS 'LowestRate'
            ,	ROUND(MAX(Pay.Rate),2) AS 'HighestRate'
            ,	ROUND(AVG(Pay.Rate),2) AS 'Avg Rate'
            ,	ROUND((MAX(Pay.Rate) - MIN(Pay.Rate)),2) AS 'Range'
            FROM HumanResources.Employee Employee
            LEFT JOIN HumanResources.EmployeePayHistory Pay ON Employee.BusinessEntityID = Pay.BusinessEntityID
            GROUP BY Employee.JobTitle
            --HAVING MAX(Pay.Rate) - MIN(Pay.Rate) <> 0
            ORDER BY AVG(Pay.Rate);"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\pay_rate_by_job_title_grouped')

def write_pay_rate_by_gender_grouped():
    sql = """SELECT 
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
            ORDER BY AVG(Pay.Rate);"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\pay_rate_by_gender_grouped')

def write_count_gender_with_each_title():
    sql = """SELECT 
            	Employee.JobTitle
            ,	SUM(CASE WHEN Employee.Gender = 'M' THEN 1 ELSE 0 END) AS 'M'
            ,	SUM(CASE WHEN Employee.Gender = 'F' THEN 1 ELSE 0 END) AS 'F'
            FROM HumanResources.Employee Employee
            GROUP BY Employee.JobTitle;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\count_gender_with_each_title')

def write_count_gender_with_title_keyword():
    sql = """SELECT 
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
            	END;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\count_gender_with_title_keyword')

def write_pay_by_gender_per_title_keyword():
    sql = """SELECT 
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
            	END;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\pay_by_gender_per_title_keyword')

def write_pay_by_pay_type():
    sql = """SELECT 
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
            	END;"""
    df = pd.read_sql(sql,cnxn)
    df.to_csv(r'C:\Users\aidut\projects\AdventureWorks\CSV\pay_by_pay_type')


write_avg_pay_by_yrs_employed()
write_pay_rate_by_job_title_per_employee()
write_pay_rate_by_job_title_grouped()
write_pay_rate_by_gender_grouped()
write_count_gender_with_each_title()
write_count_gender_with_title_keyword()
write_pay_by_gender_per_title_keyword()
write_pay_by_pay_type()
