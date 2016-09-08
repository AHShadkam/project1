/***
CheckPhoneValidity function checks the phone number validity 
based on the following rules:
- Be all digits
- Have 10 character
- The right 7 digits don’t be the same thing (like 2017777777)
- The format should be NXX-NXX-XXXX, where N should be [2-9].
**/

IF OBJECT_ID('[dbo].[CheckPhoneValidity]') IS NOT NULL
   DROP FUNCTION [dbo].[CheckPhoneValidity];
GO
Create Function [dbo].[CheckPhoneValidity](@Temp VarChar(10))
Returns BIT
AS
Begin
	Declare @valid as BIT
	
	IF ISNUMERIC(@Temp)=1 AND LEN(@Temp)=10 AND 
	LEN(REPLACE(RIGHT(@Temp,7),RIGHT(@Temp,1),'')) !=0 AND
	SUBSTRING(@Temp,1,1) NOT IN ('0','1') AND
	SUBSTRING(@Temp,4,1) NOT IN ('0','1')	
		Set @valid = 1;
	Else
		Set @valid=0;

    Return @valid
End;
GO

Update AD_Customer.dbo.NPJXTCN_GOLDEN SET Phone_Primary=''
WHERE dbo.CheckPhoneValidity(Phone_Primary)=0
