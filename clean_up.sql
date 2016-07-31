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

