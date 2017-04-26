# NPJ_Address

```sql
CREATE Function [dbo].[caret_place](@Temp VarChar(100),@caret_number int)
Returns int
AS
Begin 
	Declare @iter INT =1
	Declare @caret_place int = 0
	
	While @iter < @caret_number
	Begin
    	Set @caret_place = CHARINDEX('^',@Temp,@caret_place+1)
    	SET @iter = @iter+1
    End;
	Return @caret_place
End;
```

## Read the street name from npj address

```sql
SUBSTRING(NPJ_Address,dbo.caret_place(NPJ_Address,3)+1,dbo.caret_place(NPJ_Address,4)-dbo.caret_place(NPJ_Address,3)-1) AS NPJ_street_name
```
