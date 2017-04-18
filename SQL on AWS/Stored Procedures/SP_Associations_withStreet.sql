USE [CustomerID]
GO
/****** Object:  StoredProcedure [dbo].[SP_Associations]    Script Date: 04/18/2017 09:29:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
	CREATE PROCEDURE [dbo].[SP_Associations]
	
	AS
	BEGIN
	       Declare @start_time VARCHAR(50) 
	       SET @start_time = 'Start Time = ' +CONVERT(VARCHAR, Getdate(),120)
	
	
	-- house holding Name + Address --    
	;WITH HH AS(
	SELECT
	  Cust_no
	  ,MIN(Cust_no) OVER (PARTITION BY Name_last+'^'+Address_number+'^' +Address_Street_Name+'^' +Address_Zip_1) AS HH_ID
	FROM [CustomerID].[dbo].[GR_MIT_AB]
	WHERE LEN(Name_last) > 1
	AND LEN(Address_number)!=0 
	AND LEN(Address_Street_Name)!=0
	AND LEN(Address_ZIP_1) !=0
	)
	
	UPDATE T1
	SET Assoc_HH_Rec = HH.HH_ID
	FROM [CustomerID].[dbo].[GR_MIT_AB]AS T1
	INNER JOIN HH ON T1.Cust_no=HH.Cust_no
	
	UPDATE [CustomerID].[dbo].[GR_MIT_AB]
	SET Assoc_HH_Rec = Cust_no
	WHERE Assoc_HH_Rec IS NULL
	
	-- Individual Name + Address
	;WITH IND AS(
	SELECT
	  Cust_no,
	  MIN(Cust_no) OVER (PARTITION BY Name_last+'^'+Name_first+'^'+Address_number+'^'+Address_Street_Name+'^' +Address_Zip_1) AS IND_ID
	FROM [CustomerID].[dbo].[GR_MIT_AB]
	WHERE LEN(Name_last) > 1
	AND LEN(Name_first)!=0
	AND LEN(Address_number)!=0
	AND LEN(Address_Street_Name)!=0
	AND LEN(Address_ZIP_1) !=0
	)
	
	UPDATE T1
	SET Assoc_Ind_Rec = IND.IND_ID
	FROM [CustomerID].[dbo].[GR_MIT_AB]AS T1
	INNER JOIN IND ON T1.Cust_no=IND.Cust_no
	
	UPDATE [CustomerID].[dbo].[GR_MIT_AB]
	SET Assoc_Ind_Rec = Cust_no
	WHERE Assoc_Ind_Rec IS NULL
	
	-- Individual Name + phone
	;With my_data2 AS
	(
	Select 
	Cust_no,
	Assoc_Ind_Rec,
	Assoc_HH_Rec,
	MIN(Assoc_Ind_Rec) OVER (PARTITION BY Name_last+'^'+Name_first+'^'+Phone_Primary) AS phone_Ind,
	Name_last,
	Name_first,
	Address_number,
	Address_Street_Name,
	Address_City,
	Address_ZIP_1,
	Phone_Primary
	From [CustomerID].[dbo].[GR_MIT_AB]
	Where 
	LEN(Name_last) > 1
	AND LEN(Name_first) !=0
	AND LEN(Phone_Primary) !=0 
	)
	
	Update T2
	SET T2.Assoc_Ind_Rec_1=my_data2_distinct.phone_Ind
	from [CustomerID].[dbo].[GR_MIT_AB]AS T2
	INNER Join (Select distinct Assoc_Ind_Rec, phone_Ind from my_data2 where Assoc_Ind_Rec != phone_Ind) AS my_data2_distinct 
	ON T2.Assoc_Ind_Rec=my_data2_distinct.Assoc_Ind_Rec
	
	UPDATE [CustomerID].[dbo].[GR_MIT_AB]
	SET Assoc_Ind_Rec_1 = Assoc_Ind_Rec
	WHERE Assoc_Ind_Rec_1 IS NULL
	
	-- optimize Individual1 consolidation  --
	-----------------------------------------
	
	DECLARE @Iter2 INT;
	SET @Iter2 = 0;
	
	-- Ind1 is optimized if @rowcount2 = 0
	DECLARE @rowcount2 INT;
	SET @rowcount2=(
	SELECT count(mm.Cust_no)
	FROM
	(
	Select 
	Cust_no,
	Assoc_Ind_Rec_1,
	MIN(Assoc_Ind_Rec_1) OVER (PARTITION BY Name_last+'^'+Name_first+'^'+Phone_Primary) AS phone_Ind,
	Name_last,
	Name_first,
	Phone_Primary
	From [CustomerID].[dbo].[GR_MIT_AB]
	Where 
	LEN(Name_last) > 1
	AND LEN(Name_first) !=0
	AND LEN(Phone_Primary) !=0 
	) AS mm
	Where phone_Ind != Assoc_Ind_Rec_1  
	);
	
	WHILE @rowcount2 !=0
	       BEGIN
	              IF OBJECT_ID('tempdb.dbo.#Cust_last_first_name') IS NOT NULL
	                   DROP TABLE #Cust_last_first_name;
	                -- create a temp table with all last+first names that are not consolidated well yet.                              
	              CREATE TABLE #Cust_last_first_name 
	              (Cust_no_tmp INT
	              ,Name_last_tmp varchar(30)
	              ,Name_first_tmp varchar(30)
	              ,Phone_Primary_tmp varchar(10)
	              ,Assoc_Ind_tmp INT
	              ,Assoc_Ind_new_tmp INT NULL
	              );
	               
	              INSERT INTO #Cust_last_first_name
	              (
	              Cust_no_tmp
	              ,Name_last_tmp
	              ,Name_first_tmp
	              ,Phone_Primary_tmp
	              ,Assoc_Ind_tmp
	              )
	              SELECT         
	              T1.Cust_no
	              ,T1.Name_last
	              ,T1.Name_first
	              ,T1.Phone_primary
	              ,T1.Assoc_Ind_Rec_1
	              FROM [CustomerID].[dbo].[GR_MIT_AB] AS T1
	              INNER JOIN  
	              (
	                     SELECT Distinct Name_last,Name_first
	                     FROM
	                     (
	                           Select 
	                           Cust_no,
	                           Assoc_Ind_Rec_1,
	                           MIN(Assoc_Ind_Rec_1) OVER (PARTITION BY Name_last+'^'+Name_first+'^'+Phone_Primary) AS phone_Ind,
	                           Name_last,
	                           Name_first,
	                           Phone_Primary
	                           From [CustomerID].[dbo].[GR_MIT_AB]
	                           Where 
	                           LEN(Name_last) > 1
	                           AND LEN(Name_first) !=0
	                           AND LEN(Phone_Primary) !=0 
	                           ) AS mm
	                     WHERE phone_Ind != Assoc_Ind_Rec_1
	              ) AS T2 
	              ON T1.Name_last = T2.Name_last AND T1.Name_first = T2.Name_first;
	
	              With my_data AS
	              (
	              Select 
	              Cust_no_tmp,
	              Assoc_Ind_tmp,
	              MIN(Assoc_Ind_tmp) OVER (PARTITION BY Name_last_tmp+'^'+Name_first_tmp+'^'+ Phone_Primary_tmp) AS phone_Ind,
	              Name_last_tmp,
	              Name_first_tmp,
	              Phone_Primary_tmp
	              From #Cust_last_first_name
	              Where 
	              LEN(Name_last_tmp) > 1
	              AND LEN(Name_first_tmp) !=0
	              AND LEN(Phone_Primary_tmp) !=0    
	              )
	
	              Update T2
	              SET T2.Assoc_Ind_new_tmp=my_data_distinct.phone_Ind
	              from #Cust_last_first_name AS T2
	              INNER Join (Select distinct Assoc_Ind_tmp, phone_Ind from my_data where Assoc_Ind_tmp != phone_Ind) AS my_data_distinct 
	              ON T2.Assoc_Ind_tmp=my_data_distinct.Assoc_Ind_tmp;
	
	              UPDATE [CustomerID].[dbo].[GR_MIT_AB]
	              SET Assoc_Ind_Rec_1 = Assoc_Ind_Rec
	              WHERE Assoc_Ind_Rec_1 IS NULL
	              -- now update the golden table Ind1 using the non-null part of the temp table
	              UPDATE T2 
	              SET T2.Assoc_Ind_Rec_1 = T1.Assoc_Ind_new_tmp
	              FROM #Cust_last_first_name AS T1
	              INNER JOIN [CustomerID].[dbo].[GR_MIT_AB] AS T2
	              ON T1.Cust_no_tmp = T2.Cust_no
	              WHERE T1.Assoc_Ind_new_tmp IS NOT NULL;
	              -- add a counter to track how many temp tamp is being made and limit them to eliminate infinite loop 
	              SET @Iter2 = @Iter2 + 1;
	              IF @Iter2 > 30
	                     BEGIN
	                       PRINT 'Break! It took more than 30 loops for Ind1';
	                       BREAK;
	                     END;   
	              PRINT 'loop counter'+ CONVERT(varchar(3),@Iter2);
	              DROP TABLE #Cust_last_first_name;
	              -- renew the while condition
	              SET @rowcount2=(
	              SELECT count(mm.Cust_no)
	              FROM
	              (
	              Select 
	              Cust_no,
	              Assoc_Ind_Rec_1,
	              MIN(Assoc_Ind_Rec_1) OVER (PARTITION BY Name_last+'^'+ Name_first+'^'+ Phone_Primary) AS phone_Ind,
	              Name_last,
	              Name_first,
	              Phone_Primary
	              From [CustomerID].[dbo].[GR_MIT_AB]
	              Where 
	              LEN(Name_last) > 1
	              AND LEN(Name_first) !=0
	              AND LEN(Phone_Primary) !=0 
	              ) AS mm
	              Where phone_Ind != Assoc_Ind_Rec_1  
	              );
	
	       END;
	
	-- House holding Name + phone
	
	;With my_data1 AS
	(
	Select 
	Cust_no,
	Assoc_Ind_Rec,
	Assoc_HH_Rec,
	MIN(Assoc_HH_Rec) OVER (PARTITION BY Name_last+'^'+ Name_first+'^'+ Phone_Primary) AS phone_HH,
	Name_last,
	Name_first,
	Address_number,
	Address_Street_Name,
	Address_City,
	Address_ZIP_1,
	Phone_Primary
	From [CustomerID].[dbo].[GR_MIT_AB]      
	Where 
	LEN(Name_last) > 1
	AND LEN(Name_first) !=0
	AND LEN(Phone_Primary) !=0 
	)
	
	Update T2
	SET Assoc_HH_Rec_1=my_data1_distinct.phone_HH
	from [CustomerID].[dbo].[GR_MIT_AB]AS T2
	INNER Join (Select distinct Assoc_HH_Rec,phone_HH from my_data1 where Assoc_HH_Rec != phone_HH) AS my_data1_distinct 
	ON T2.Assoc_HH_Rec=my_data1_distinct.Assoc_HH_Rec
	
	UPDATE [CustomerID].[dbo].[GR_MIT_AB]
	SET Assoc_HH_Rec_1 = Assoc_HH_Rec
	WHERE Assoc_HH_Rec_1 IS NULL;
	
	
	-- Fix HouseHolding until there is no individual in 2 Households --
	-------------------------------------------------------------------
	DECLARE @Iter INT
	SET @Iter = 0
	
	DECLARE @rowcount INT;
	SET @rowcount=(select count(T1.Cust_no)
	                           From [CustomerID].[dbo].[GR_MIT_AB] AS T1
	                           Inner Join [CustomerID].[dbo].[GR_MIT_AB] AS T2
	                           ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
	                           Where T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1
	                           );     
	
	WHILE @rowcount !=0
	       BEGIN
	              IF OBJECT_ID('tempdb.dbo.#Cust_last_name') IS NOT NULL
	        DROP TABLE #Cust_last_name;
	        -- create a temp table with all last names that are not consolidated well yet.                              
	              CREATE TABLE #Cust_last_name 
	              (Cust_no_tmp INT
	              ,Name_last_tmp varchar(30)
	              ,Name_first_tmp varchar(30)
	              ,Phone_Primary_tmp varchar(10)
	              ,Assoc_HH_tmp INT
	              ,Assoc_Ind_tmp INT
	              ,Assoc_HH_new_tmp INT NULL
	              );
	               
	              INSERT INTO #Cust_last_name
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
	              FROM [CustomerID].[dbo].[GR_MIT_AB]
	              WHERE Name_last IN (SELECT DISTINCT T1.Name_last
	                                                From [CustomerID].[dbo].[GR_MIT_AB] AS T1
	                                                Inner Join [CustomerID].[dbo].[GR_MIT_AB] AS T2
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
	              ,MIN(Assoc_HH_tmp) OVER (PARTITION BY Name_last_tmp+'^'+ Name_first_tmp+'^'+ Phone_Primary_tmp) AS phone_HH
	              From #Cust_last_name 
	              Where 
	              LEN(Name_last_tmp) > 1
	              AND LEN(Name_first_tmp) !=0
	              AND LEN(Phone_Primary_tmp) !=0    
	              ) 
	              Update T2
	              SET Assoc_HH_new_tmp=my_data_distinct.phone_HH
	              FROM #Cust_last_name AS T2
	              INNER Join (Select distinct Assoc_HH_tmp, phone_HH from my_data where Assoc_HH_tmp != phone_HH) AS my_data_distinct 
	              ON T2.Assoc_HH_tmp=my_data_distinct.Assoc_HH_tmp;
	                     
	       -- now update the golden table householding using the non-null part of the temp table
	              UPDATE T2 
	              SET T2.Assoc_HH_Rec_1 = T1.Assoc_HH_new_tmp
	              FROM #Cust_last_name AS T1
	              INNER JOIN [CustomerID].[dbo].[GR_MIT_AB] AS T2
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
	              DROP TABLE #Cust_last_name;  
	              
	-- renew the while condition             
	              SET @rowcount=(select count(T1.Cust_no)
	              From [CustomerID].[dbo].[GR_MIT_AB] AS T1
	              Inner Join [CustomerID].[dbo].[GR_MIT_AB] AS T2
	              ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
	              Where T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1
	           );
	                         
	       END;   -- END WHILE
	
	END
