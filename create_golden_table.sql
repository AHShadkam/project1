IF OBJECT_ID('[AD_Customer].[dbo].[NPJXTCN_GOLDEN]','U') IS NOT NULL DROP TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN];
GO
     
CREATE TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
(
      Cust_no int,
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
      Address_ZIP_1 varchar(6),
      Address_ZIP_2   varchar(6),
      Email_Primary varchar(50),
 --     Email_Secondary varchar(50),
      Email_Ins_ts varchar(10),
      Phone_Primary varchar(10),
      Phone_Secondary varchar(10)
);
GO 
 
 
 
INSERT INTO [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
(
      Cust_no
--    Assoc_Ind_Rec,
--    Assoc_HH_Rec,
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
      ,Address_ZIP_1
      ,Address_ZIP_2
      ,Email_Primary
--    ,Email_Secondary
      ,Email_Crt_ts
      ,Phone_Primary
--    ,Phone_Secondary
)
SELECT  [cn_cust_key]
        ,[cn_name_pref]
        ,[cn_name_last]
        ,[cn_name_1st]
        ,[cn_name_suff]
        ,[cn_house_rte_no]
        ,[cn_street_pfx]
        ,[cn_street_nme]
        ,[cn_street_sfx]
        ,[cn_street_sfx_md]
        ,[cn_box_no]
        ,[cn_unit_no]
        ,[cn_addr_line_2]
        ,[cn_zip_pc]
        ,[cn_zip_sector_seg]
        ,[CUS_EML_AD]
        ,[CRT_TS]
        ,[cn_tel_no]
FROM  [AD_Customer].[dbo].[NPJXTCN_RAO] ;
