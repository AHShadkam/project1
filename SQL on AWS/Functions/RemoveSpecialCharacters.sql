-- Remove special characters including ( ÿ ) except "&", "'", ".", "-", space 

USE [CustomerID];
GO

IF OBJECT_ID('[dbo].[RemoveSpecialCharacters]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveSpecialCharacters];
GO

CREATE Function [dbo].[RemoveSpecialCharacters](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin 
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '%[\^"%<>`~$%|!ÿ/\+*;:)(@_,?#=}{\[]%'
	/** hyphen, caret and ] are tricky
    	hyphen should be always after [ or before ]  **/
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
