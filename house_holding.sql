WITH HH AS(
SELECT
  Cust_no
  ,MIN(Cust_no) OVER (PARTITION BY Name_last+ Address_number+ Address_Zip_1) AS HH_ID
  ,Name_last+Address_number+Address_Zip_1 AS combination
FROM [AD_Customer].[dbo].NPJXTCN_GOLDEN
WHERE LEN(Name_last)!=0
AND LEN(Address_number)!=0 
AND LEN(Address_ZIP_1) !=0
)

UPDATE T1
SET Assoc_HH_Rec = HH.HH_ID
FROM AD_Customer.dbo.NPJXTCN_GOLDEN AS T1
INNER JOIN HH ON T1.Cust_no=HH.Cust_no;
GO

/** populate the remaining householding rows with their customer_number **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec = Cust_no
WHERE Assoc_HH_Rec IS NULL;
