USE [CustomerID]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_Create_CLEAN_NPJ_GOLDEN]

AS

  DECLARE @lastTime datetime,
          @ElapsedTime int


  BEGIN TRY

    BEGIN TRANSACTION [Tran1]

--IF OBJECT_ID('[CustomerID].[dbo].[GR_MIT_AB]','U') IS NOT NULL DROP TABLE [CustomerID].[dbo].[GR_MIT_AB];
--GO
     
CREATE TABLE [CustomerID].[dbo].[GR_MIT_AB]
(
      Cust_no int NOT NULL,
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
      CN_date_effect date,
      CN_last_name_chg_dt date,
      CN_purge_dt date,
      Email_Primary varchar(50),
      Email_Secondary varchar(50),
      Email_Ins_ts datetime2,
      Phone_Primary varchar(10),
      Phone_Secondary varchar(10),
      Assoc_Ind_Rec int,
      Assoc_Ind_Rec_1 int,
      Assoc_HH_Rec int,
      Assoc_HH_Rec_1 int
);

INSERT INTO [CustomerID].[dbo].[GR_MIT_AB]
(
      Cust_no
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
     ,CN_date_effect 
     ,CN_last_name_chg_dt 
     ,CN_purge_dt
--     ,Email_Primary
--    ,Email_Secondary
--      ,Email_Ins_ts
      ,Phone_Primary
--    ,Phone_Secondary
)

SELECT

[cn_cust_key] AS cust_no,
LTRIM(RTRIM([cn_name_pref])) AS Name_prefix,
dbo.Removeunwantedstring([cn_name_last]) AS Name_last,
dbo.Removeunwantedstring([cn_name_1st]) AS Name_first,
LTRIM(RTRIM([cn_name_suff])) AS Name_suffix,
LTRIM(RTRIM([cn_house_rte_no])) AS Address_number,
LTRIM(RTRIM([cn_street_pfx])) AS Address_Street_Prefix,
LTRIM(RTRIM([cn_street_nme])) AS Address_Street_Name,
LTRIM(RTRIM([cn_street_sfx])) AS Address_Street_Suffix,
LTRIM(RTRIM([cn_street_sfx_md])) AS Address_Street_Modifier,
LTRIM(RTRIM([cn_box_no])) AS Address_BoxNubmer,
LTRIM(RTRIM([cn_unit_no])) AS Address_UnitNumber,
CASE
  WHEN [cn_addr_line_2] LIKE '[-]%' THEN dbo.RemoveLeadingHyphens(LTRIM(RTRIM([cn_addr_line_2])))
  ELSE LTRIM(RTRIM([cn_addr_line_2]))
END AS Address_Line2,
LTRIM(RTRIM([cn_town])) AS Address_City,
LTRIM(RTRIM([cn_st_prov])) AS Address_State,
LTRIM(RTRIM([cn_zip_pc])) AS Address_ZIP_1,
LTRIM(RTRIM([cn_zip_sector_seg])) AS Address_ZIP_2,
CONVERT(date, [cn_date_effect]) AS CN_date_effect,
CONVERT(date, [lst_nm_chg_dt]) AS CN_last_name_chg_dt,
CONVERT(date, [purge_dt]) AS CN_purge_dt,
CASE
  WHEN dbo.CheckPhoneValidity([cn_tel_no]) = 0 THEN ''
  ELSE LTRIM(RTRIM([cn_tel_no]))
END AS Phone_Primary
FROM dbo.NPJXTCN_MIT_AB        -- This table name should be same as golden trivial table


    COMMIT TRANSACTION [Tran1]

  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION [Tran1]
  END CATCH

--GO
