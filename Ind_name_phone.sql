/** consolidate individuals based on name+phone  **/

ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [Assoc_Ind_Rec_1] INT NULL;
GO


With my_data2 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_HH_Rec,
MIN(Assoc_Ind_Rec) OVER (PARTITION BY Name_last + Name_first + Phone_Primary) AS phone_Ind,
Name_last,
Name_first,
Address_number,
Address_Street_Name,
Address_City,
Address_ZIP_1,
Phone_Primary
From AD_Customer.dbo.NPJXTCN_GOLDEN 
Where 
LEN(Name_last) > 1
AND LEN(Name_first) !=0
AND LEN(Phone_Primary) !=0	
)


Update T2
SET T2.Assoc_Ind_Rec_1=my_data2_distinct.phone_Ind
from AD_Customer.dbo.NPJXTCN_GOLDEN AS T2
INNER Join (Select distinct Assoc_Ind_Rec, phone_Ind from my_data2 where Assoc_Ind_Rec != phone_Ind) AS my_data2_distinct 
ON T2.Assoc_Ind_Rec=my_data2_distinct.Assoc_Ind_Rec;
GO

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_Ind_Rec_1 = Assoc_Ind_Rec
WHERE Assoc_Ind_Rec_1 IS NULL;
