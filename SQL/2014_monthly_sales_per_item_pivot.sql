/*
Returns a pivot table showing the total units sold in each month of 2014 for each ProductID
*/

SELECT 
	ProductID AS 'ProductID'
,	[1] AS 'Jan'
,	[2] AS 'Feb'
,	[3] AS 'Mar'
,	[4] AS 'Apr'
,	[5] AS 'May'
,	[6] AS 'Jun'
,	[7] AS 'Jul'
,	[8] AS 'Aug'
,	[9] AS 'Sep'
,	[10] AS 'Oct'
,	[11] AS 'Nov'
,	[12] AS 'Dec'

FROM 
(SELECT 
	SOD.ProductID AS 'ProductID'
,	SUM(SOD.OrderQty) AS 'OrderQty'
,	MONTH(SOH.ShipDate) AS 'ShipMonth'
FROM
	Sales.SalesOrderDetail AS SOD
JOIN 
	Sales.SalesOrderHeader AS SOH
	ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE 
	YEAR(SOH.ShipDate) = 2014
GROUP BY 
	SOD.ProductId
,	MONTH(SOH.ShipDate)
) Sales
PIVOT
(
SUM(OrderQty)
FOR ShipMonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS pvt 
ORDER BY pvt.ProductID;