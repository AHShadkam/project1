ALTER TABLE [CustomerID].[dbo].[NPJXTCN_GOLDEN]  
DROP COLUMN Assoc_Ind_Rec,Assoc_Ind_Rec_1,Assoc_HH_Rec,Assoc_HH_Rec_1,Assoc_HH_Rec_2

-- create the Association columns  

ALTER TABLE [CustomerID].[dbo].[NPJXTCN_GOLDEN]
	ADD  [Assoc_Ind_Rec] INT NULL,
	     [Assoc_Ind_Rec_1] INT NULL,
         [Assoc_HH_Rec] INT NULL,
         [Assoc_HH_Rec_1] INT NULL,
         [Assoc_HH_Rec_2] INT NULL 

Exec [CustomerID].[dbo].[Amir_Assoc_speed_test]
