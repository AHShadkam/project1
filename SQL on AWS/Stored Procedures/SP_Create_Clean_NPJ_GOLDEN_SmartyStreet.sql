USE [CustomerID]
GO
/****** Object:  StoredProcedure [dbo].[SP_Create_CLEAN_NPJ_GOLDEN]    Script Date: 04/19/2017 19:11:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
	
	
	ALTER PROCEDURE [dbo].[SP_Create_CLEAN_NPJ_GOLDEN]
	
	AS
	
	  DECLARE @lastTime datetime,
	          @ElapsedTime int
	
	
	  BEGIN TRY
	
	    BEGIN TRANSACTION [Tran1]
	
	--IF OBJECT_ID('[CustomerID].[dbo].[GR_MIT_AB]','U') IS NOT NULL DROP TABLE [CustomerID].[dbo].[GR_MIT_AB];
	--GO
	     
	
	
	INSERT INTO [CustomerID].[dbo].[GR_MIT_C]
	(
	      Cust_no
	     ,Name_prefix
	     ,Name_last
	     ,Name_first
	     ,Name_suffix
	     ,NPJ_Address
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
		  ,SmartyStreet_Property_Type
		  ,SmartyStreet_Definition
	)
	
	SELECT
	
	[cn_cust_key] AS cust_no,
	LTRIM(RTRIM([cn_name_pref])) AS Name_prefix,
	dbo.Removeunwantedstring([cn_name_last]) AS Name_last,
	dbo.Removeunwantedstring([cn_name_1st]) AS Name_first,
	LTRIM(RTRIM([cn_name_suff])) AS Name_suffix,
	LTRIM(RTRIM([cn_house_rte_no]))+'^'+LTRIM(RTRIM([cn_street_pfx]))+'^'+LTRIM(RTRIM([cn_street_nme]))+
	'^'+ LTRIM(RTRIM([cn_street_sfx]))+'^'+LTRIM(RTRIM([cn_street_sfx_md]))+'^'+LTRIM(RTRIM([cn_town]))+
	'^'+ LTRIM(RTRIM([cn_st_prov]))+'^'+LTRIM(RTRIM([cn_zip_pc]))+'^'+LTRIM(RTRIM([cn_zip_sector_seg]))
	AS NPJ_Address,
	LTRIM(RTRIM([SmartyStreet_StreetNumber])) AS Address_number,
	LTRIM(RTRIM([SmartyStreet_Street_Prefix])) AS Address_Street_Prefix,
	LTRIM(RTRIM([SmartyStreet_StreetName])) AS Address_Street_Name,
	LTRIM(RTRIM([SmartyStreet_Street_Suffix])) AS Address_Street_Suffix,
--	LTRIM(RTRIM([SmartyStreet_Street_Suffix_Modifier])) AS Address_Street_Modifier,
-- it is recommanded to read street_suffix_modifier from smartystreet, if available
    LTRIM(RTRIM([cn_street_sfx_md])) AS Address_Street_Modifier,
	LTRIM(RTRIM([cn_box_no])) AS Address_BoxNubmer,
	LTRIM(RTRIM([cn_unit_no])) AS Address_UnitNumber,
	CASE
	  WHEN [cn_addr_line_2] LIKE '[-]%' THEN dbo.RemoveLeadingHyphens(LTRIM(RTRIM([cn_addr_line_2])))
	  ELSE LTRIM(RTRIM([cn_addr_line_2]))
	END AS Address_Line2,
	LTRIM(RTRIM([SmartyStreet_City])) AS Address_City,
	LTRIM(RTRIM([SmartyStreet_State])) AS Address_State,
	LTRIM(RTRIM([SmartyStreet_ZipCode])) AS Address_ZIP_1,
	LTRIM(RTRIM([SmartyStreet_PlusFour])) AS Address_ZIP_2,
	CONVERT(date, [cn_date_effect]) AS CN_date_effect,
	CONVERT(date, [lst_nm_chg_dt]) AS CN_last_name_chg_dt,
	CONVERT(date, [purge_dt]) AS CN_purge_dt,
	CASE
	  WHEN dbo.CheckPhoneValidity([cn_tel_no]) = 0 THEN ''
	  ELSE LTRIM(RTRIM([cn_tel_no]))
	END AS Phone_Primary,
	LTRIM(RTRIM([SmartyStreet_Property_Type])) AS SmartyStreet_Property_Type ,
	LTRIM(RTRIM([SmartyStreet_Definition])) AS SmartyStreet_Definition
	FROM dbo.NPJXTCN_MIT_C       -- This table name should be same as golden trivial table
	
	
	    COMMIT TRANSACTION [Tran1]
	
	  END TRY
	  BEGIN CATCH
	    ROLLBACK TRANSACTION [Tran1]
	  END CATCH
