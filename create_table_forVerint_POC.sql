IF OBJECT_ID('[AD_Customer].[dbo].[VERINT_POC_SAMPLE_GOLDEN]','U') IS NOT NULL DROP TABLE [AD_Customer].[dbo].[VERINT_POC_SAMPLE_GOLDEN];
GO
     
CREATE TABLE [AD_Customer].[dbo].[VERINT_POC_SAMPLE_GOLDEN]
(
      Cust_no int NOT NULL,
      Assoc_Ind_Rec int,
      Assoc_HH_Rec int,
      Name_prefix varchar(4),
      Name_last varchar(30),
      Name_first varchar(30),
      Name_suffix varchar(4),
      Address_number varchar(10),
      Address_Street_Prefix varchar(2),
      Address_Street_Name varchar(30),
      Address_Street_Suffix varchar(4),
      Address_Street_Modifier varchar(2),
      Address_BoxNubmer varchar(10),
      Address_UnitNumber varchar(6),
      Address_Line2 varchar(30),
      Address_City varchar(30),
      Address_State varchar(2),
      Address_ZIP_1 varchar(6),
      Address_ZIP_2   varchar(6),
      Email_Primary varchar(50),
      Email_Secondary varchar(50),
      Phone_Primary varchar(10),
      Phone_Secondary varchar(10)
);
GO 

with my_100K AS
(
select T2.Cust_no,T2.Assoc_HH_Rec_2
from [AD_Customer].[dbo].[100K_RANDOM_GOLDEN_CUST_NO] AS T1
	inner join AD_Customer.dbo.NPJXTCN_GOLDEN AS T2 
	ON T1.cust_no=T2.Cust_no
)


INSERT INTO [AD_Customer].[dbo].[VERINT_POC_SAMPLE_GOLDEN]
(
      Cust_no
    ,Assoc_Ind_Rec
    ,Assoc_HH_Rec
    ,Name_prefix
    ,Name_last
    ,Name_first
    ,Name_suffix
    ,Address_number
      ,Address_Street_Prefix
      ,Address_Street_Name
      ,Address_Street_Suffix
      ,Address_Street_Modifier
      ,Address_BoxNubmer
      ,Address_UnitNumber
      ,Address_Line2
      ,Address_City
      ,Address_State
      ,Address_ZIP_1
      ,Address_ZIP_2
      ,Email_Primary
--    ,Email_Secondary
      ,Phone_Primary
--    ,Phone_Secondary
)
select 
       TT2.[Cust_no]
      ,TT2.[Assoc_Ind_Rec_1] AS Assoc_Ind_Rec
      ,TT2.[Assoc_HH_Rec_2] AS Assoc_HH_Rec
      ,TT2.[Name_prefix]
      ,TT2.[Name_last]
      ,TT2.[Name_first]
      ,TT2.[Name_suffix]
      ,TT2.[Address_number]
      ,TT2.[Address_Street_Prefix]
      ,TT2.[Address_Street_Name]
      ,TT2.[Address_Street_Suffix]
      ,TT2.[Address_Street_Modifier]
      ,TT2.[Address_BoxNubmer]
      ,TT2.[Address_UnitNumber]
      ,case when TT2.[address_line2_extracted_flag]=1 then '' else TT2.[Address_Line2] end AS Address_Line2
      ,TT2.[Address_City]
      ,TT2.[Address_State]
      ,TT2.[Address_ZIP_1]
      ,TT2.[Address_ZIP_2]
      ,TT2.[Email_Primary]
      ,TT2.[Phone_Primary]
from (select distinct Assoc_HH_Rec_2 from my_100K) AS TT1
inner join AD_Customer.dbo.NPJXTCN_GOLDEN AS TT2
ON TT1.Assoc_HH_Rec_2=TT2.Assoc_HH_Rec_2;
