-- the ultimate function to clean last name and first name using other functions

USE [CustomerID];
GO

IF OBJECT_ID('[dbo].[Removeunwantedstring]') IS NOT NULL
   DROP FUNCTION [dbo].[Removeunwantedstring];
GO

CREATE  Function [dbo].[Removeunwantedstring](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin
	
	Set @Temp = LTRIM(RTRIM(replace(replace(replace(
		dbo.RemoveTrailingNonAlphabet(dbo.RemoveLeadingNonAlphabet(
		replace(replace(replace(dbo.RemoveDigitCharacters(dbo.RemoveSpecialCharacters(
		@Temp)),'MR.',''),'MS.',''),'MRS.',''))),' ','<>'),'><',''),'<>',' ')))
						
	Return @Temp
End;
