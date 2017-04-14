-- function RemoveLeadingNonAlphbet
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
	Set @KeepValues = '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'
	While PatIndex(@KeepValues, @Temp) > 0
    		Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '') 
	Return @Temp
End;
GO
