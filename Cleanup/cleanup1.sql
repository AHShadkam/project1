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
----------------------------------------
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


-- main body --

-- 1) First name:

-- 1.1) Remove MR. , MRS. , MS. from fist-name 

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


UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveLeadingNonAlphabet([Name_first])
WHERE [Name_first] LIKE '[^A-Z]%';
GO

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveTrailingNonAlphabet([Name_first])
WHERE [Name_first] LIKE '%[^A-Z]';
GO

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.dbo.RemoveDigitCharacters([Name_first])
WHERE [Name_first] LIKE '%[0-9]%';
GO

UPDATE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] 
SET [Name_first] = dbo.RemoveSpecialCharacters([Name_first])
WHERE [Name_first] LIKE '%[/\+*;:)(@_,?#=}{]%';
GO
