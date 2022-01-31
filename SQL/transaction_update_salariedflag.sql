DROP TABLE IF EXISTS #TempHumanResourcesEmployee;

SELECT *
INTO #TempHumanResourcesEmployee
FROM HumanResources.Employee;

BEGIN TRANSACTION; 

DECLARE @NewSalary TABLE (Id BIGINT)
INSERT INTO @NewSalary(Id) VALUES (4),(11),(12),(13)

UPDATE #TempHumanResourcesEmployee
	SET SalariedFlag = 1
	WHERE BusinessEntityID IN (SELECT * FROM @NewSalary);

SELECT 
	BusinessEntityID
,	SalariedFlag 
FROM 
	#TempHumanResourcesEmployee;

ROLLBACK TRANSACTION;

SELECT 
	BusinessEntityID
,	SalariedFlag 
FROM 
	#TempHumanResourcesEmployee;