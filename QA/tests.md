# Name & Phone Householding 
the big problem is that sometimes same Individual has multiple house-holds.  
In order to find these account use the following query:
```sql
select  T1.*
FROM [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T1
INNER JOIN [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR] AS T2
ON T1.Assoc_Ind_Rec_1 = T2.Assoc_Ind_Rec_1 
WHERE T1.Assoc_HH_Rec_1 != T2.Assoc_HH_Rec_1
```

# Name & Phone Individual
sometimes the Name+phone Individual consolidation can't gather all the accounts belonging to the same individual in on round of householding.
The following query helps us to find the affected accounts.
```sql
With my_data2 AS
(
Select 
Cust_no,
Assoc_Ind_Rec,
Assoc_Ind_Rec_1,
Assoc_HH_Rec,
MIN(Assoc_Ind_Rec_1) OVER (PARTITION BY Name_last +'^'+Name_first + Phone_Primary) AS phone_Ind,
Name_last,
Name_first,
Address_number,
Address_Street_Name,
Address_City,
Address_ZIP_1,
Phone_Primary
From [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
Where 
LEN(Name_last) > 1
AND LEN(Name_first) !=0
AND LEN(Phone_Primary) !=0	
)

Select *
from my_data2
Where phone_Ind != Assoc_Ind_Rec_1
ORDER BY Name_last
```
