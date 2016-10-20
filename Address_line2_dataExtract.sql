IF OBJECT_ID('[dbo].[CountWords]') IS NOT NULL
   DROP FUNCTION [dbo].[CountWords];
GO
Create Function [dbo].[CountWords](@Temp Varchar(100))
Returns int
AS
BEGIN
    Declare @word_length int
	Set @word_length = len(@Temp) - len(REPLACE(@Temp,' ',''))
	Return @word_length + 1
End;
GO


IF OBJECT_ID('[dbo].[ReturnStringPart]') IS NOT NULL
   DROP FUNCTION [dbo].[ReturnStringPart];
GO
Create Function [dbo].[ReturnStringPart](@Temp Varchar(100),@part int)
Returns VarChar(100)
AS
Begin

	DECLARE @word varchar(100)
	DECLARE @word_count int = dbo.CountWords(@Temp)
	DECLARE @increment int = 0
	
	IF @word_count < @part
		RETURN NULL
	
    While @part > @increment
    BEGIN
		IF @word_count = @increment+1
			RETURN @TEMP
		set @word=SUBSTRING(@Temp, 1, charindex(' ',@Temp))
		set @Temp = LTRIM(Stuff(@Temp,1,LEN(@word), ''))
		set @increment=@increment + 1
	END
    RETURN @word
End;
GO


/** add flag column to track the extracted Address_line 2 **/ 
ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [address_line2_extracted_flag] bit NOT NULL default 0;


/** 3 word, with street suffix at word(3)**/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name=dbo.ReturnStringPart(Address_Line2,2),
	Address_Street_Suffix=(SELECT UPPER(T2.Abbreviation) 
			       FROM AD_Customer.dbo.Street_Suffix_list T2
			       WHERE dbo.ReturnStringPart(Address_Line2,3) = T2.Street_Suffix
			       ),
	address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 3
AND dbo.ReturnStringPart(Address_Line2,3) IN (SELECT Street_Suffix FROM AD_Customer.dbo.Street_Suffix_list);
GO


/** 4 word, with street suffix at word(4)  and street_prefix at word(2) **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Prefix=(CASE WHEN dbo.ReturnStringPart(Address_Line2,2) IN ('e','e.','east') THEN 'E' 
				    WHEN dbo.ReturnStringPart(Address_Line2,2) IN ('w','w.','west') THEN 'W'
			            WHEN dbo.ReturnStringPart(Address_Line2,2) IN	('n','n.','no.','north') THEN 'N'
				    WHEN dbo.ReturnStringPart(Address_Line2,2) IN	('s','s.','so.','south') THEN 'S'
				END),
	Address_Street_Name=dbo.ReturnStringPart(Address_Line2,3),
	Address_Street_Suffix=(SELECT UPPER(T2.Abbreviation) 
				FROM AD_Customer.dbo.Street_Suffix_list T2
				WHERE dbo.ReturnStringPart(Address_Line2,4) = T2.Street_Suffix
				),
	address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,4) IN (SELECT Street_Suffix FROM AD_Customer.dbo.Street_Suffix_list)
AND dbo.ReturnStringPart(Address_Line2,2) IN ('e','e.','east','w','w.','west','n','n.','no.','north','s','s.','so.','south');
GO


/** 4word, no street prefix **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name=CASE WHEN dbo.ReturnStringPart(Address_Line2,2) LIKE '%[0-9]%' THEN dbo.ReturnStringPart(Address_Line2,3)
				 WHEN dbo.ReturnStringPart(Address_Line2,2) LIKE '%[/:"#-]%' THEN dbo.ReturnStringPart(Address_Line2,3)
				 WHEN dbo.ReturnStringPart(Address_Line2,2) = 'APT' THEN ''
				 WHEN LEN(dbo.ReturnStringPart(Address_Line2,2)) < 2 THEN dbo.ReturnStringPart(Address_Line2,3)
				 ELSE dbo.ReturnStringPart(Address_Line2,2)+' '+dbo.ReturnStringPart(Address_Line2,3)
				 END,
	Address_Street_Suffix=(SELECT UPPER(T2.Abbreviation) 
				FROM AD_Customer.dbo.Street_Suffix_list T2
				WHERE dbo.ReturnStringPart(Address_Line2,4) = T2.Street_Suffix
				),
	address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,4) IN (SELECT Street_Suffix FROM AD_Customer.dbo.Street_Suffix_list)
AND dbo.ReturnStringPart(Address_Line2,2) NOT IN ('e','e.','east','w','w.','west','n','n.','no.','north','s','s.','so.','south');
GO


/** 5 words, street suffix (3), 'APT' (4) **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name=dbo.ReturnStringPart(Address_Line2,2),
	Address_Street_Suffix=(SELECT UPPER(T2.Abbreviation) 
	                        FROM AD_Customer.dbo.Street_Suffix_list T2
				WHERE dbo.ReturnStringPart(Address_Line2,3) = T2.Street_Suffix
				),
	Address_UnitNumber=dbo.ReturnStringPart(Address_Line2,5),
	address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 5
AND dbo.ReturnStringPart(Address_Line2,3) IN (SELECT Street_Suffix FROM AD_Customer.dbo.Street_Suffix_list)
AND dbo.ReturnStringPart(Address_Line2,4) IN ('APT','APT.');
GO


/** 3word highway **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
	   Address_number=dbo.ReturnStringPart(Address_Line2,1),
	   Address_Street_Name='HIGHWAY'+' '+dbo.ReturnStringPart(Address_Line2,3),
	   address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 3
AND dbo.ReturnStringPart(Address_Line2,2) IN ('HWY','HIGHWAY');
GO


/** 4word highway 'US','USA','STATE' **/
/** remember to clean # at the end from Street_name **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN 
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name=CASE WHEN dbo.ReturnStringPart(Address_Line2,2) IN ('US','USA') THEN 'US HIGHWAY'+' '+dbo.ReturnStringPart(Address_Line2,4)
			         WHEN dbo.ReturnStringPart(Address_Line2,2) = 'STATE' THEN 'STATE HIGHWAY'+' '+dbo.ReturnStringPart(Address_Line2,4)
		                 END,
	address_line2_extracted_flag = 1
WHERE LEN(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,3) IN ('HWY','HIGHWAY')
AND dbo.ReturnStringPart(Address_Line2,2) IN ('US','STATE');
GO


/** 4word, highway with Modifier (4) **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
       Address_number=dbo.ReturnStringPart(Address_Line2,1),
	   Address_Street_Name='HIGHWAY'+' '+dbo.ReturnStringPart(Address_Line2,3),
	   Address_Street_Modifier=CASE WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east') THEN 'E' 
		                        WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('w','w.','west') THEN 'W'
		                        WHEN dbo.ReturnStringPart(Address_Line2,4) IN	('n','n.','no.','north') THEN 'N'
		                        WHEN dbo.ReturnStringPart(Address_Line2,4) IN	('s','s.','so.','south') THEN 'S'
		                   END,
       address_line2_extracted_flag = 1
WHERE LEN(Address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,2) IN ('HWY','HIGHWAY')
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,3)) = 1
AND dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east','w','w.','west','n','n.','no.','north','s','s.','so.','south');
GO



/** 3word Route **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
		Address_number=dbo.ReturnStringPart(Address_Line2,1),
		Address_Street_Name='ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,3),
		address_line2_extracted_flag = 1
WHERE len(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 3
AND dbo.ReturnStringPart(Address_Line2,2) IN ('RT','ROUTE');
GO


/** 4word ROUTE 'County','Rural','STATE' **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name=CASE WHEN dbo.ReturnStringPart(Address_Line2,2)='COUNTY' THEN 'COUNTY ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,4)
	                         WHEN dbo.ReturnStringPart(Address_Line2,2) ='STATE' THEN 'STATE ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,4)
	                         WHEN dbo.ReturnStringPart(Address_Line2,2) ='RURAL' THEN 'RURAL ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,4)		 
		            END,
	address_line2_extracted_flag = 1
WHERE LEN(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,4)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,3) IN ('RT','ROUTE')
AND dbo.ReturnStringPart(Address_Line2,2) IN ('COUNTY','STATE','RURAL');
GO


/** 4word, ROUTE with Modifier (4) **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name='ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,3),
	Address_Street_Modifier=CASE WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east') THEN 'E' 
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('w','w.','west') THEN 'W'
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('n','n.','no.','north') THEN 'N'
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('s','s.','so.','south') THEN 'S'
				END,
	address_line2_extracted_flag = 1
WHERE LEN(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,2) IN ('RT','ROUTE')
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,3)) = 1
AND dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east','w','w.','west','n','n.','no.','north','s','s.','so.','south');
GO


/** 4word, ROUTE with Modifier (4) **/
UPDATE AD_Customer.dbo.NPJXTCN_GOLDEN
SET
	Address_number=dbo.ReturnStringPart(Address_Line2,1),
	Address_Street_Name='ROUTE'+' '+dbo.ReturnStringPart(Address_Line2,3),
	Address_Street_Modifier=CASE WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east') THEN 'E' 
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN ('w','w.','west') THEN 'W'
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN	('n','n.','no.','north') THEN 'N'
				     WHEN dbo.ReturnStringPart(Address_Line2,4) IN	('s','s.','so.','south') THEN 'S'
				END,
	address_line2_extracted_flag = 1
WHERE LEN(address_line2) != 0
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,1)) = 1
AND dbo.CountWords(Address_Line2) = 4
AND dbo.ReturnStringPart(Address_Line2,2) IN ('RT','ROUTE')
AND ISNUMERIC(dbo.ReturnStringPart(Address_Line2,3)) = 1
AND dbo.ReturnStringPart(Address_Line2,4) IN ('e','e.','east','w','w.','west','n','n.','no.','north','s','s.','so.','south');
GO
