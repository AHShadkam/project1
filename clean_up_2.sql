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

IF OBJECT_ID('[dbo].[RemoveLeadTrailDash]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveLeadTrailDash];
GO
Create Function [dbo].[RemoveLeadTrailDash](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin

   IF LEFT(@Temp,1)= '-'
		SET @Temp=Stuff(@Temp,1, 1, '')
   IF RIGHT(@Temp,1)='-'
		SET @Temp=Stuff(@Temp,LEN(@TEMP),1, '')
		
    Return @Temp
End;
GO


IF OBJECT_ID('[dbo].[RemoveLeadTrailComma]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveLeadTrailComma];
GO
Create Function [dbo].[RemoveLeadTrailComma](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin

    IF LEFT(@Temp,1)= ','
	SET @Temp=Stuff(@Temp,1, 1, '')
    IF RIGHT(@Temp,1)=','
	SET @Temp=Stuff(@Temp,LEN(@TEMP),1, '')
		
    Return @Temp
End;
GO

update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] 
set [Address_Street_Name] = dbo.RemoveNumberSign([Address_Street_Name])
WHERE [Address_Street_Name] LIKE '%#%';
GO

update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] 
SET [Address_Street_Name] = dbo.RemoveLeadTrailDash([Address_Street_Name])
WHERE [Address_Street_Name] LIKE '%-%';
GO

update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] 
SET [Address_Street_Name] = dbo.RemoveLeadTrailComma([Address_Street_Name])
WHERE [Address_Street_Name] LIKE '%,%';
GO
