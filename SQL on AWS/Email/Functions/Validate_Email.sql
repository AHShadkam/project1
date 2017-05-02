USE [CustomerID]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_ValidateEmail]    Script Date: 05/02/2017 11:25:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[udf_ValidateEmail] (@email varChar(255))
---Clarence Rao
---4/26/2017
RETURNS bit
AS
begin
return
(
select 
	Case 
		When @email is null or                	--NULL Email is invalid
			charindex(' ', @email) 	<> 0  or		--Check for space
			substring(@email,1,1) = '@' or  --check for @ as leading character
			CHARINDEX('@',@email) = 0  or   --check for existance of @ sign
			@email like '%@%@%' then 0       -- check for 2 @ signs
		Else 1
	END
)
end
