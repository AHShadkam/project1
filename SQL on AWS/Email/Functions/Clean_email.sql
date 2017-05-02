USE [CustomerID]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_CleanEmail]    Script Date: 05/02/2017 11:17:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Function [dbo].[udf_CleanEmail](@email VarChar(100))
-- Amir Shadkam
-- 4/28/2017
Returns VarChar(100)
AS
Begin
	IF @email like '% %'  -- Remove Space in string
		SET @email=Replace(@email,' ','');
	IF @email like '%[.]@%'	OR @email like '%@[^(A-Z0-9)]%' -- Remove some special characters around @
	BEGIN
		SET @email=Replace(@email,'.@','@')
		SET @email=Replace(@email,'@.','@')
		SET @email=Replace(@email,'@_','@')
		SET @email=Replace(@email,'@-','@')
		SET @email=Replace(@email,'@%','@')
		SET @email=Replace(@email,'@@','@')
	END;	
	IF @email like '%[^(A-Z0-9)]' -- Remove special character from string tail
		SET @email=SUBSTRING(@email,1,LEN(@email)-1);
	Return @email
End
