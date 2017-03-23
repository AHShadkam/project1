```sql
ALTER TABLE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
DROP COLUMN Assoc_Ind_Rec,
Assoc_Ind_Rec_1,
Assoc_HH_Rec,
Assoc_HH_Rec_1,
Assoc_HH_Rec_2,
Assoc_HH_Rec_1_AUX1,
Assoc_HH_Rec_1_AUX2,
Assoc_HH_Rec_2_AUX1
```

-- create the Association columns  

```sql
ALTER TABLE [CustomerID].[dbo].[NPJXTCN_GOLDEN_NJ_AMIR]
ADD Assoc_Ind_Rec INT NULL,
Assoc_Ind_Rec_1 INT NULL,
Assoc_HH_Rec INT NULL,
Assoc_HH_Rec_1 INT NULL,
Assoc_HH_Rec_2 INT NULL,
Assoc_HH_Rec_1_AUX1 INT NULL,
Assoc_HH_Rec_1_AUX2 INT NULL,
Assoc_HH_Rec_2_AUX1 INT NULL 
```

-- Run Stroed procedure
```sql
Exec [CustomerID].[dbo].[Amir_Assoc_speed_test]
```
