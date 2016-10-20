/** populating the  Assoc_Ind_Rec column **/

WITH IND AS(
SELECT
  Cust_no,
  MIN(Cust_no) OVER (PARTITION BY Name_last+ Name_first + Address_number+ Address_Zip_1) AS IND_ID,
  Name_last+ Name_first +Address_number+Address_Zip_1 AS combination
FROM [AD_Customer].[dbo].NPJXTCN_GOLDEN
WHERE LEN(Name_last)!=0
AND LEN(Name_first)!=0
AND LEN(Address_number)!=0
AND LEN(Address_ZIP_1) !=0
)

UPDATE T1
SET Assoc_Ind_Rec = IND.IND_ID
FROM AD_Customer.dbo.NPJXTCN_GOLDEN AS T1
INNER JOIN IND ON T1.Cust_no=IND.Cust_no;
GO
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_Ind_Rec = Cust_no
WHERE Assoc_Ind_Rec IS NULL;
