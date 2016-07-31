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
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_prefix] = LTRIM([Name_prefix])
                                               ,[Name_last] = LTRIM([Name_last])
                                               ,[Name_first] = LTRIM([Name_first])
                                               ,[Name_suffix] = LTRIM([Name_suffix])
                                               ,[Address_number] = LTRIM([Address_number])
                                               ,[Address_Street_Prefix]=LTRIM([Address_Street_Prefix])
                                               ,[Address_street_name]=LTRIM([Address_street_name])
                                               ,[Address_street_suffix]=LTRIM([Address_street_suffix])
                                               ,[Address_street_modifier]=LTRIM([Address_street_modifier])
                                               ,[Address_BoxNubmer]=LTRIM([Address_BoxNubmer])
                                               ,[Address_unitnumber]=LTRIM([Address_unitnumber])
                                               ,[Address_Line2]=LTRIM([Address_Line2])
					       ,[Address_zip_1]=LTRIM([Address_zip_1])
					       ,[Address_zip_2]=LTRIM([Address_zip_2])
					       ,[Email_Primary]=LTRIM([Email_Primary])
		                               ,[Email_Secondary]=LTRIM([Email_Secondary])
					       ,[Phone_Primary]=LTRIM([Phone_Primary])
					       ,[Phone_Secondary]=LTRIM([Phone_Secondary]);

/** clean Name_last from digits and special characters **/
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_last] = dbo.RemoveSpecialCharacters([Name_last]);
GO
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Name_last] = dbo.RemoveDigitCharacters([Name_last]);
GO

/** clean leading hyphen in Address_line2 **/
update [AD_Customer].[dbo].[NPJXTCN_GOLDEN] set [Address_Line2] = dbo.RemoveLeadingHyphens([Address_Line2])
WHERE [Address_Line2] LIKE '[-]%';
GO



          
