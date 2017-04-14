USE [CustomerID];
GO

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
