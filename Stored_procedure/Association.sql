USE [CustomerID]
GO
/****** Object:  StoredProcedure [dbo].[Amir_Assoc_speed_test]    Script Date: 04/06/2017 13:23:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Shadkam,Amir>
-- Create date: <March,14,2017>
-- Description:	<This procedure does the Associations needed for golden records, no cleaning is included here.>
-- =============================================
ALTER PROCEDURE [dbo].[Amir_Assoc_speed_test]

AS
BEGIN
	Declare @start_time VARCHAR(50) 
	SET @start_time = 'Start Time = ' +CONVERT(VARCHAR, Getdate(),120)

-- Clean start and trail spaces from Address_number --
update [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
set [Address_number] = LTRIM(RTRIM([Address_number]))
where [address_line2_extracted_flag] = 1


-- house holding Name + Address --    
;WITH HH AS(
SELECT
  Cust_no
  ,MIN(Cust_no) OVER (PARTITION BY Name_last+ Address_number+ Address_Zip_1) AS HH_ID
  ,Name_last+Address_number+Address_Zip_1 AS combination
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
WHERE LEN(Name_last)!=0
AND LEN(Address_number)!=0 
AND LEN(Address_ZIP_1) !=0
)

UPDATE T1
SET Assoc_HH_Rec = HH.HH_ID
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]AS T1
INNER JOIN HH ON T1.Cust_no=HH.Cust_no

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET Assoc_HH_Rec = Cust_no
WHERE Assoc_HH_Rec IS NULL
 
-- Individual Name + Address
;WITH IND AS(
SELECT
  Cust_no,
  MIN(Cust_no) OVER (PARTITION BY Name_last+'^'+Name_first + Address_number+ Address_Zip_1) AS IND_ID,
  Name_last+ Name_first +Address_number+Address_Zip_1 AS combination
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
WHERE LEN(Name_last)!=0
AND LEN(Name_first)!=0
AND LEN(Address_number)!=0
AND LEN(Address_ZIP_1) !=0
)

UPDATE T1
SET Assoc_Ind_Rec = IND.IND_ID
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]AS T1
INNER JOIN IND ON T1.Cust_no=IND.Cust_no

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET Assoc_Ind_Rec = Cust_no
WHERE Assoc_Ind_Rec IS NULL

-- Individual Name + phone
;With my_data2 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_HH_Rec,
MIN(Assoc_Ind_Rec) OVER (PARTITION BY Name_last +'^'+Name_first + Phone_Primary) AS phone_Ind,
Name_last,
Name_first,
Address_number,
Address_Street_Name,
Address_City,
Address_ZIP_1,
Phone_Primary
From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
Where 
LEN(Name_last) > 1
AND LEN(Name_first) !=0
AND LEN(Phone_Primary) !=0	
)

Update T2
SET T2.Assoc_Ind_Rec_1=my_data2_distinct.phone_Ind
from [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]AS T2
INNER Join (Select distinct Assoc_Ind_Rec, phone_Ind from my_data2 where Assoc_Ind_Rec != phone_Ind) AS my_data2_distinct 
ON T2.Assoc_Ind_Rec=my_data2_distinct.Assoc_Ind_Rec

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET Assoc_Ind_Rec_1 = Assoc_Ind_Rec
WHERE Assoc_Ind_Rec_1 IS NULL


-- House holding Name + phone

;With my_data1 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_HH_Rec,
MIN(Assoc_HH_Rec) OVER (PARTITION BY Name_last +'^'+ Name_first + Phone_Primary) AS phone_HH,
Name_last,
Name_first,
Address_number,
Address_Street_Name,
Address_City,
Address_ZIP_1,
Phone_Primary
From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]	
Where 
LEN(Name_last) > 1
AND LEN(Name_first) !=0
AND LEN(Phone_Primary) !=0	
)

Update T2
SET Assoc_HH_Rec_1=my_data1_distinct.phone_HH
from [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]AS T2
INNER Join (Select distinct Assoc_HH_Rec,phone_HH from my_data1 where Assoc_HH_Rec != phone_HH) AS my_data1_distinct 
ON T2.Assoc_HH_Rec=my_data1_distinct.Assoc_HH_Rec

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET Assoc_HH_Rec_1 = Assoc_HH_Rec
WHERE Assoc_HH_Rec_1 IS NULL;


-- Fix HouseHolding until there is no individual in 2 Households --
-------------------------------------------------------------------
DECLARE @Iter INT
SET @Iter = 0

DECLARE @rowcount INT;
SET @rowcount=(select count(T1.Cust_no)
				From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T1
				Inner Join [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T2
				ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
				Where T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1
				);	

WHILE @rowcount !=0
	BEGIN
		IF OBJECT_ID('tempdb.dbo.#Cust_last_name_1') IS NOT NULL
        DROP TABLE #Cust_last_name_1;
        -- create a temp table with all last names that are not consolidated well yet.                              
		CREATE TABLE #Cust_last_name_1 
		(Cust_no_tmp INT
		,Name_last_tmp varchar(30)
		,Name_first_tmp varchar(30)
		,Phone_Primary_tmp varchar(10)
		,Assoc_HH_tmp INT
		,Assoc_Ind_tmp INT
		,Assoc_HH_new_tmp INT NULL
		);
	        
		INSERT INTO #Cust_last_name_1 
		(
		 Cust_no_tmp
		,Name_last_tmp
		,Name_first_tmp
		,Phone_Primary_tmp
		,Assoc_HH_tmp
		,Assoc_Ind_tmp
		)
		SELECT         
		 Cust_no
		,Name_last
		,Name_first
		,Phone_primary
		,Assoc_HH_Rec_1
		,Assoc_Ind_Rec_1
		FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
		WHERE Name_last IN (SELECT DISTINCT T1.Name_last
							From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T1
							Inner Join [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T2
							ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
							WHERE T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1);

		PRINT 'temp table created '+CONVERT(varchar(3),@Iter);
	
		With my_data AS
		(
		Select 
		 Cust_no_tmp
		,Name_last_tmp
		,Name_first_tmp
		,Phone_Primary_tmp
		,Assoc_HH_tmp
		,Assoc_Ind_tmp
		,MIN(Assoc_HH_tmp) OVER (PARTITION BY Name_last_tmp +'^' +Name_first_tmp + Phone_Primary_tmp) AS phone_HH
		From #Cust_last_name_1	
		Where 
		LEN(Name_last_tmp) > 1
		AND LEN(Name_first_tmp) !=0
		AND LEN(Phone_Primary_tmp) !=0	
		) 
		Update T2
		SET Assoc_HH_new_tmp=my_data_distinct.phone_HH
		FROM #Cust_last_name_1 AS T2
		INNER Join (Select distinct Assoc_HH_tmp, phone_HH from my_data where Assoc_HH_tmp != phone_HH) AS my_data_distinct 
		ON T2.Assoc_HH_tmp=my_data_distinct.Assoc_HH_tmp;
			
	-- now update the golden table householding using the non-null part of the temp table
		UPDATE T2 
		SET T2.Assoc_HH_Rec_1 = T1.Assoc_HH_new_tmp
		FROM #Cust_last_name_1 AS T1
		INNER JOIN [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T2
		ON T1.Cust_no_tmp = T2.Cust_no
		WHERE T1.Assoc_HH_new_tmp IS NOT NULL;

-- add a counter to track how many temp tamp is being made and limit them to eliminate infinite loop 
		SET @Iter = @Iter + 1;
		IF @Iter > 30
			BEGIN
			  PRINT 'Break! It took more than 30 loops for HH1';
			  BREAK;
			END;	
		PRINT 'loop counter'+ CONVERT(varchar(3),@Iter);
		DROP TABLE #Cust_last_name_1;  
		
-- renew the while condition		
		SET @rowcount=(select count(T1.Cust_no)
		From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T1
		Inner Join [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T2
		ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
		Where T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1
	    );
		           
	END;

END
