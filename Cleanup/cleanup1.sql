--The First_name and Last_name cleanup has 5 steps:
--1. Remove MR. , MRS. , MS.
--2. Remove leading non-alphabets
--3. Remove Trailing non-alphabets
--4. Remove digits 
--5. Remove special characters except "&", "'", "."

--Functions --
--------------

USE [CustomerID];
GO
-- Function dbo.RemoveLeadingNonAlphabet --
IF OBJECT_ID('[dbo].[RemoveLeadingNonAlphabet]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveLeadingNonAlphabet];
GO
Create Function [dbo].[RemoveLeadingNonAlphabet](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '[^A-Z]%'
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
GO

-- Function dbo.RemoveTrailingNonAlphabet
IF OBJECT_ID('[dbo].[RemoveTrailingNonAlphabet]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveTrailingNonAlphabet];
GO
Create Function [dbo].[RemoveTrailingNonAlphabet](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '%[^A-Z]'
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
GO

-- Function dbo.RemoveDigitCharacters --
IF OBJECT_ID('[dbo].[RemoveDigitCharacters]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveDigitCharacters];
GO
Create Function [dbo].[RemoveDigitCharacters](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin 
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '%[0-9]%'
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
GO

-- Function dbo.RemoveSpecialCharacters execpt for ampersad,single quote, Dot
IF OBJECT_ID('[dbo].[RemoveSpecialCharacters]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveSpecialCharacters];
GO
Create Function [dbo].[RemoveSpecialCharacters](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin 
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '%[/\+*;:)(@_,?#=}{]%'
	/** hyphen, caret and ] are tricky
    	hyphen should be always after [ or before ]  **/
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
GO

-- main body --
---------------

-- 1) First name:

-- 1.1) Remove MR. , MRS. , MS. from first-name 

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET [Name_first] = stuff([Name_first],1,4,'')
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
where [Name_first] like 'MR.%'
OR [Name_first] like 'MS.%';
GO

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET [Name_first] = stuff([Name_first],1,5,'')
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
where [Name_first] like 'MRS.%';
GO

-- 1.2) Remove leading non-alphabets from first-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveLeadingNonAlphabet([Name_first])
WHERE [Name_first] LIKE '[^A-Z]%';
GO
-- 1.3) Remove trailing non-alphabets from first-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveTrailingNonAlphabet([Name_first])
WHERE [Name_first] LIKE '%[^A-Z]';
GO

-- 1.4) Remove digits from first-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveDigitCharacters([Name_first])
WHERE [Name_first] LIKE '%[0-9]%';
GO

-- 1.5) Remove special characters except &'. from first-name
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.RemoveSpecialCharacters([Name_first])
WHERE [Name_first] LIKE '%[/\+*;:)(@_,?#=}{]%';
GO


-- 2) First name:

-- 2.1) Remove MR. , MRS. , MS. from last-name 

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET [Name_last] = stuff([Name_last],1,4,'')
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
where [Name_last] like 'MR.%'
OR [Name_last] like 'MS.%';
GO

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
SET [Name_last] = stuff([Name_last],1,5,'')
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
where [Name_last] like 'MRS.%';
GO

-- 2.2) Remove leading non-alphabets from last-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_last] = dbo.dbo.RemoveLeadingNonAlphabet([Name_last])
WHERE [Name_last] LIKE '[^A-Z]%';
GO
-- 2.3) Remove trailing non-alphabets from last-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_last] = dbo.dbo.RemoveTrailingNonAlphabet([Name_last])
WHERE [Name_last] LIKE '%[^A-Z]';
GO

-- 2.4) Remove digits from last-name 
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_last] = dbo.dbo.RemoveDigitCharacters([Name_last])
WHERE [Name_last] LIKE '%[0-9]%';
GO

-- 2.5) Remove special characters except &'. from last-name
UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_last] = dbo.RemoveSpecialCharacters([Name_last])
WHERE [Name_last] LIKE '%[/\+*;:)(@_,?#=}{]%';
GO
