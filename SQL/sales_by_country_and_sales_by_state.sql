-- Show total sales by Country/Region
-- US leads by far at almost $71 million, followed by Canada at about $18 million
SELECT
	SP.CountryRegionCode
,	FORMAT(SUM(SOH.TotalDue),'C2') AS 'Total'

FROM Sales.SalesOrderHeader AS SOH

JOIN Person.Address AS A
	ON SOH.ShipToAddressID = A.AddressID

JOIN Person.StateProvince AS SP
	ON A.StateProvinceID = SP.StateProvinceID

GROUP BY SP.CountryRegionCode

ORDER BY SUM(SOH.TotalDue) DESC;

-- Within the US, show sales by state
-- California leads with $17 mil, Maryland has only $2582.68
SELECT
	SP.StateProvinceCode
,	FORMAT(SUM(SOH.TotalDue),'C2') AS 'StateTotal'

FROM Sales.SalesOrderHeader AS SOH

JOIN Person.Address AS A
	ON SOH.ShipToAddressID = A.AddressID

JOIN Person.StateProvince AS SP
	ON A.StateProvinceID = SP.StateProvinceID

WHERE SP.CountryRegionCode = 'US'

GROUP BY SP.StateProvinceCode

ORDER BY SUM(SOH.TotalDue) DESC;