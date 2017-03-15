-- create stored procedure that includes all the Association (HH & Ind) in one run --
-------------------------------------------------------------------------------------

USE [AD_Customer]
GO
/****** Object:  StoredProcedure [dbo].[Amir_Assoc-speed-test]    Script Date: 03/14/2017 15:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shadkam,Amir>
-- Create date: <March,14,2017>
-- Description:	<This procedure does the Associations needed for golden records, no cleaning is included here.>
-- =============================================
ALTER PROCEDURE [dbo].[Amir_Assoc-speed-test]

AS
BEGIN
	Declare @start_time VARCHAR(50) 
	SET @start_time = 'Start Time = ' +CONVERT(VARCHAR, Getdate(),120)

-- create the Association columns
ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
	ADD  [Assoc_Ind_Rec] INT NULL,
	     [Assoc_Ind_Rec_1] INT NULL,
             [Assoc_HH_Rec] INT NULL,
             [Assoc_HH_Rec_1] INT NULL,
             [Assoc_HH_Rec_2] INT NULL
     
 
 
-- house holding Name + Address --    
;WITH HH AS(
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
INNER JOIN HH ON T1.Cust_no=HH.Cust_no

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec = Cust_no
WHERE Assoc_HH_Rec IS NULL
 
-- Individual Name + Address
;WITH IND AS(
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
INNER JOIN IND ON T1.Cust_no=IND.Cust_no

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_Ind_Rec = Cust_no
WHERE Assoc_Ind_Rec IS NULL

-- House holding Name + phone

;With my_data2 AS
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
ON T2.Assoc_HH_Rec=my_data2_distinct.Assoc_HH_Rec

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_1 = Assoc_HH_Rec
WHERE Assoc_HH_Rec_1 IS NULL

-- Individual Name + phone
;With my_data2 AS
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
ON T2.Assoc_Ind_Rec=my_data2_distinct.Assoc_Ind_Rec

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_Ind_Rec_1 = Assoc_Ind_Rec
WHERE Assoc_Ind_Rec_1 IS NULL

-- House holding Address + phone
;With my_data2 AS
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
ON T2.Assoc_HH_Rec_1=my_data2_distinct.Assoc_HH_Rec_1

UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Assoc_HH_Rec_2 = Assoc_HH_Rec_1
WHERE Assoc_HH_Rec_2 IS NULL
    
    print @start_time
	print 'Finish Time = ' + CONVERT(VARCHAR, Getdate(),120)
END
