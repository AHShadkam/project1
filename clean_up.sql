/*** user defined Functions ***/
/******************************/

/* function removes digits from string */
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



/* function removes some special characters from string  */
IF OBJECT_ID('[dbo].[RemoveSpecialCharacters]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveSpecialCharacters];
GO
Create Function [dbo].[RemoveSpecialCharacters](@Temp VarChar(100))
Returns VarChar(100)
AS
Begin

    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%[/\.+*;:@_,?#=}{-]%'
    /** hyphen, caret and ] are tricky
        hyphen should be always after [ or before ]  **/
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End;
GO



/* function removes all leading hyphens from string */
IF OBJECT_ID('[dbo].[RemoveLeadingHyphens]') IS NOT NULL
   DROP FUNCTION [dbo].[RemoveLeadingHyphens];
GO
Create Function [dbo].[RemoveLeadingHyphens](@Temp VarChar(100))
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
GO

/*** End of functions ***/
/************************/



/** clean up leading space **/
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_prefix] = LTRIM(RTRIM([Name_prefix]))
                                               ,[Name_last] = LTRIM(RTRIM([Name_last]))
                                               ,[Name_first] = LTRIM(RTRIM([Name_first]))
                                               ,[Name_suffix] = LTRIM(RTRIM([Name_suffix]))
                                               ,[Address_number] = LTRIM(RTRIM([Address_number]))
                                               ,[Address_Street_Prefix]=LTRIM(RTRIM([Address_Street_Prefix]))
                                               ,[Address_street_name]=LTRIM(RTRIM([Address_street_name]))
                                               ,[Address_street_suffix]=LTRIM(RTRIM([Address_street_suffix]))
                                               ,[Address_street_modifier]=LTRIM(RTRIM([Address_street_modifier]))
                                               ,[Address_BoxNubmer]=LTRIM(RTRIM([Address_BoxNubmer]))
                                               ,[Address_unitnumber]=LTRIM(RTRIM([Address_unitnumber]))
                                               ,[Address_Line2]=LTRIM(RTRIM([Address_Line2]))
					       ,[Address_zip_1]=LTRIM(RTRIM([Address_zip_1]))
					       ,[Address_zip_2]=LTRIM(RTRIM([Address_zip_2]))
					       ,[Email_Primary]=LTRIM(RTRIM([Email_Primary]))
		                               ,[Email_Secondary]=LTRIM(RTRIM([Email_Secondary]))
					       ,[Phone_Primary]=LTRIM(RTRIM([Phone_Primary]))
					       ,[Phone_Secondary]=LTRIM(RTRIM([Phone_Secondary]));

/** clean Name_last from digits and special characters **/
/** clean Name_first from digits  **/
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_last] = dbo.RemoveSpecialCharacters([Name_last]);
GO
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_last] = dbo.RemoveDigitCharacters([Name_last]);
GO
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_first] = dbo.RemoveDigitCharacters([Name_first]);
GO

/** clean leading hyphen in Address_line2 **/
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Address_Line2] = dbo.RemoveLeadingHyphens([Address_Line2])
WHERE [Address_Line2] LIKE '[-]%';
GO



          
