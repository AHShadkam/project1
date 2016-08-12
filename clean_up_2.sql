IF OBJECT_ID('[dbo].[RemoveNumberSign]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveNumberSign];
GO
Create Function [dbo].[RemoveNumberSign](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin

    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%#%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End;
GO

update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Address_Street_Name] = dbo.RemoveNumberSign([Address_Street_Name]);
GO
