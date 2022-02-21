CREATE VIEW Sales.vStatePercentSales
AS
	WITH StateCountryTotals AS 
	(
	SELECT
		SP.StateProvinceCode AS 'StateID'
	,	SUM(SOH.TotalDue) OVER (PARTITION BY SP.StateProvinceCode) AS 'StateTotal'
	,	SUM(SOH.TotalDue) OVER (PARTITION BY SP.CountryRegionCode) AS 'CountryTotal'

	FROM Sales.SalesOrderHeader AS SOH

	JOIN Person.Address AS A
		ON SOH.ShipToAddressID = A.AddressID

	JOIN Person.StateProvince AS SP
		ON A.StateProvinceID = SP.StateProvinceID

	WHERE SP.CountryRegionCode = 'US'
	)
	SELECT DISTINCT
		StateCountryTotals.StateID
	,	FORMAT(StateCountryTotals.StateTotal, 'C2') AS 'StateTotal'
	,	FORMAT(StateCountryTotals.CountryTotal, 'C2') AS 'CountryTotal'
	,	(StateCountryTotals.StateTotal / StateCountryTotals.CountryTotal * 100) AS 'StatePercent'
	FROM StateCountryTotals
;
