/*
Date Created : 2023/07/15 12:25AM
Myprojects: DS_Store_Canniballisation_Consumer_Flow Analysis
Author: Giorgi(Gigi) Oniani
Github:/GigiOniani
Project Detail: 
This project's main idea is to create advanced analytics report in Power BI Desktop regarding Store Canniballisation rate and Customer Flow between given stores. 
In this SQL script I am introducing and assigning customer's "most frequently visited store" variable to each customer and generating data,that will give us possibility 
to build PBI Dashboard on Flow map and gain some insights aswell. I have divided this SQL script into 4 steps, each step has it's own explanation and details.
Lets get Started!
*/

--===================================================================================================================
/*---Step 1---
Step Detail: 
Overview data and check each customer distribution into different branches/kiosks */
--===================================================================================================================

SELECT 
TRS.[Consumer ID],
TRS.[Store ID],
SUM(TRS.[Check Count] ) AS 'Orders'

FROM DS_Canniballisation.dbo.['TRANSACTIONAL DATA$'] AS TRS

GROUP BY
TRS.[Consumer ID],
TRS.[Store ID]

ORDER BY TRS.[Consumer ID ], [Orders] DESC

--===================================================================================================================
/*---Step 2---
Step Detail: 
In this step, I am introducing and Assigning "Most Frequently Visited" Store to Each distinct Customer and generating view in DS_Canniballisation Data Warehouse*/
--===================================================================================================================

ALTER VIEW DS_Customer_MFS AS

WITH CTE AS (
	SELECT 
	TRS.[Consumer ID ],
	TRS.[Store ID],
	SUM(TRS.[Check Count]) as 'CheckNum',
	SUM(TRS.[Sales]) as 'Sale'
	
	FROM DS_Canniballisation.dbo.['TRANSACTIONAL DATA$'] AS TRS

	WHERE TRS.[Consumer ID ] IS NOT NULL 
	GROUP BY
	TRS.[Consumer ID ],
	TRS.[Store ID]

)

,CTERank AS (

	SELECT 
		CTE.[Consumer ID],
		CTE.[Store ID],
		CTE.CheckNum,
		CTE.Sale,
		RANK() OVER (PARTITION BY CTE.[Consumer ID] ORDER BY CTE.[CheckNum] DESC ,CTE.[Sale] DESC ) AS 'Ranking'

	FROM CTE

)

SELECT 
CTERank.[Consumer ID],
CTERank.[Store ID],
CTERank.CheckNum,
CTERank.Sale,
CTERank.Ranking

FROM CTERank

WHERE CTERank.Ranking = 1

--===================================================================================================================
/*Step 3
Step Detail:
Lets review and explain this Step, Since we assigned most frequently visited branch/kiosk to each customer, now we can 
calculate what number of loyal customers are making payments into same(MF Store) or another branch/kiosks, to be more clear, 
for example customers whose most frequently visited store ID is = 1, they have made 2460 and 4727 visit to Store ID = 2 and Store ID = 5, respectively. 
This step will help us to gather information about customer visit distribution.

P.S Since We have 7 DISTINCT branch/kiosks in given data, we will have 49 possible Combinations of store cross-sections made by customers */
--===================================================================================================================

SELECT
TRS.[Store ID],
MFS.[Store ID] as 'Most Frequent Store ID',
SUM(TRS.[Check Count] ) AS 'Total Orders'

FROM DS_Canniballisation.dbo.['TRANSACTIONAL DATA$'] AS TRS

LEFT JOIN DS_Canniballisation.dbo.DS_Customer_MFS AS MFS ON MFS.[Consumer ID] = TRS.[Consumer ID ]

GROUP BY
TRS.[Store ID],
MFS.[Store ID]

ORDER BY
TRS.[Store ID] ASC

----===================================================================================================================
/*Step 4
Step Detail:
Since we gathered all essential information,  In this final step, I will create SQL View to export ready data into 
Power BI Desktop to build dashboard and make further analytics  */
----===================================================================================================================

CREATE VIEW DS_gigi_Cannibalisation_Rate AS 

SELECT
TRS.[Store ID],
MFS.[Store ID] as 'Most Frequent Store ID',
SUM(TRS.[Check Count] ) AS 'Total Orders'


FROM DS_Canniballisation.dbo.['TRANSACTIONAL DATA$'] AS TRS
LEFT JOIN DS_Canniballisation.dbo.DS_Customer_MFS AS MFS ON MFS.[Consumer ID] = TRS.[Consumer ID ]

GROUP BY
TRS.[Store ID],
MFS.[Store ID]
