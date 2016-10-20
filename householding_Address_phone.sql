ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [Assoc_HH_Rec_2] INT NULL;
GO


With my_data AS
(
SELECT Phone_Primary,
    Count(DISTINCT HH_updated) AS CountOfHH
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
Where LEN(Phone_Primary) !=0 
GROUP BY [Phone_Primary]
HAVING (((Count(DISTINCT [HH_updated]))>1)) AND (((Count(DISTINCT [HH_updated]))<10))
),

my_data2 AS
(
Select 
T1.Cust_no,
T1.Assoc_Ind_Rec,
T1.Assoc_HH_Rec,
T1.Ind_updated,
T1.HH_updated,
MIN(HH_updated) OVER (PARTITION BY T1.Address_number + T1.Address_ZIP_1 + T1.Phone_Primary) AS phone_HH2,
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
LEN(Address_number) != 0 
AND LEN(Address_ZIP_1) !=0
)


Update T2
SET T2.Assoc_HH_Rec_2=my_data2_distinct.phone_HH2 
from AD_Customer.dbo.NPJXTCN_GOLDEN AS T2
INNER Join (Select distinct Assoc_HH_Rec_1, phone_HH2 from my_data2 ) AS my_data2_distinct 
ON T2.Assoc_HH_Rec_1=my_data2_distinct.HH_updated
Where my_data2_distinct.phone_HH2 is not null;


UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_2 = Assoc_HH_Rec_1
WHERE Assoc_HH_Rec_2 IS NULL;
