/** use name(last + first) + phone for householding **/


ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [Assoc_HH_Rec_1] INT NULL;
GO



With my_data2 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_HH_Rec,
MIN(Assoc_HH_Rec) OVER (PARTITION BY Name_last + Name_first + Phone_Primary) AS phone_HH,
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
SET Assoc_HH_Rec_1=my_data2_distinct.phone_HH
from AD_Customer.dbo.NPJXTCN_GOLDEN AS T2
INNER Join (Select distinct Assoc_HH_Rec,phone_HH from my_data2 where Assoc_HH_Rec != phone_HH) AS my_data2_distinct 
ON T2.Assoc_HH_Rec=my_data2_distinct.Assoc_HH_Rec;
GO

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_1 = Assoc_HH_Rec
WHERE Assoc_HH_Rec_1 IS NULL;
