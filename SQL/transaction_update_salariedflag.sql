DROP TABLE IF EXISTS #TempHumanResourcesEmployee;

SELECT *
INTO #TempHumanResourcesEmployee
FROM HumanResources.Employee;

BEGIN TRANSACTION; 

DECLARE @NewSalary TABLE (Id BIGINT)
INSERT INTO @NewSalary(Id) VALUES (4),(11),(12),(13);

DECLARE @ChangeLog TABLE (
	EmpID INT NOT NULL
,	OldSalariedFlag INT
,	NewSalariedFlag INT);

UPDATE #TempHumanResourcesEmployee
SET SalariedFlag = 1
OUTPUT INSERTED.BusinessEntityID
,	DELETED.SalariedFlag
,	INSERTED.SalariedFlag
INTO @ChangeLog
WHERE BusinessEntityID IN (SELECT * FROM @NewSalary);

SELECT * 
FROM @ChangeLog

ROLLBACK TRANSACTION;
