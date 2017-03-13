ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [Assoc_HH_Rec_2] INT NULL;
GO


With my_data2 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_HH_Rec,
Assoc_Ind_Rec_1,
Assoc_HH_Rec_1,
MIN(Assoc_HH_Rec_1) OVER (PARTITION BY Address_number + Address_ZIP_1 + Phone_Primary) AS phone_HH2,
Name_last,
Name_first,
Address_number,
Address_Street_Name,
Address_City,
Address_ZIP_1,
Phone_Primary
From AD_Customer.dbo.NPJXTCN_GOLDEN
Where 
LEN(Address_number) != 0 
AND LEN(Address_ZIP_1) !=0
AND LEN(Phone_Primary) !=0
)


Update T2
SET T2.Assoc_HH_Rec_2=my_data2_distinct.phone_HH2 
from AD_Customer.dbo.NPJXTCN_GOLDEN AS T2
INNER Join (Select distinct Assoc_HH_Rec_1, phone_HH2 from my_data2 where Assoc_HH_Rec_1 != phone_HH2) AS my_data2_distinct
ON T2.Assoc_HH_Rec_1=my_data2_distinct.Assoc_HH_Rec_1;
GO

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_2 = Assoc_HH_Rec_1
WHERE Assoc_HH_Rec_2 IS NULL;
