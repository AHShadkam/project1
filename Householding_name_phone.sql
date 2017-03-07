/** use name(last + first) + phone for householding **/


ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [Assoc_HH_Rec_1] INT NULL;
GO

With my_data AS
(
SELECT Phone_Primary,
    Count(DISTINCT Assoc_HH_Rec) AS CountOfHH
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
Where LEN(Phone_Primary) !=0 
GROUP BY [Phone_Primary]
HAVING (((Count(DISTINCT [Assoc_HH_Rec]))>1)) AND (((Count(DISTINCT [Assoc_HH_Rec]))<10))
),

my_data2 AS
(
Select 
T1.Cust_no,
T1.Assoc_Ind_Rec,
T1.Assoc_HH_Rec,
MIN(T1.Assoc_HH_Rec) OVER (PARTITION BY T1.Name_last + T1.Name_first + T1.Phone_Primary) AS phone_HH,
T1.Name_last,
T1.Name_first,
T1.Address_number,
T1.Address_Street_Name,
T1.Address_City,
T1.Address_ZIP_1,
T1.Phone_Primary
From AD_Customer.dbo.NPJXTCN_GOLDEN AS T1 
	INNER JOIN my_data ON T1.Phone_Primary=my_data.Phone_Primary
Where 
--T1.Phone_Primary='8567674844' 
--AND 
LEN(Name_last) > 1
AND LEN(Name_first) !=0
)

Update T2
SET Assoc_HH_Rec_1=my_data2_distinct.phone_HH
from AD_Customer.dbo.NPJXTCN_GOLDEN AS T2
--INNER Join (Select distinct Assoc_HH_Rec, phone_HH from my_data2 ) AS my_data2_distinct 
INNER Join (Select distinct g.Assoc_HH_Rec, g.phone_HH, COUNT(*) over (PARTITION by g.phone_HH) as count from my_data2 as g) AS my_data2_distinct 
ON T2.Assoc_HH_Rec=my_data2_distinct.Assoc_HH_Rec
Where phone_HH is not null
And my_data2_distinct.count >1;
GO

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_1 = Assoc_HH_Rec
WHERE Assoc_HH_Rec_1 IS NULL;
