-- Function dbo.RemoveTrailingNonAlphabet

USE [CustomerID];
GO

IF OBJECT_ID('[dbo].[RemoveTrailingNonAlphabet]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveTrailingNonAlphabet];
GO
Create Function [dbo].[RemoveTrailingNonAlphabet](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin
	Declare @KeepValues as varchar(50)
	Set @KeepValues = '%[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]'
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
