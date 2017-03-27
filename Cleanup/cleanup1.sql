
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

select top 1000 cn_name_1st,stuff(cn_name_1st,1,4,'')
FROM [CustomerID].[NPJ].NPJXTCN with (NOLOCK)
where cn_name_1st like 'MR.%'

select top 1000 cn_name_1st,stuff(cn_name_1st,1,4,'')
FROM [CustomerID].[NPJ].NPJXTCN with (NOLOCK)
where cn_name_1st like 'MS.%'

select top 1000 cn_name_1st,stuff(cn_name_1st,1,5,'')
FROM [CustomerID].[NPJ].NPJXTCN with (NOLOCK)
where cn_name_1st like 'MRS.%'


