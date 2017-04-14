USE [CustomerID];
GO

IF OBJECT_ID('[dbo].[RemoveLeadingHyphens]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveLeadingHyphens];
GO

ALTER Function [dbo].[RemoveLeadingHyphens](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin

    Declare @KeepValues as varchar(50)
    Set @KeepValues = '[-]%'
    /** hyphen, caret and ] are tricky
        hyphen should be always after [ or before ]  **/
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End;
