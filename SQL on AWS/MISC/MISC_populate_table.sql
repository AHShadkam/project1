INSERT INTO [CustomerID].[dbo].[GR_MIT_MISC]
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
		,Assoc_Ind_Rec
		,Assoc_Ind_Rec_1
		,Assoc_HH_Rec
		,Assoc_HH_Rec_1	
	)
	
	SELECT
	
	[cn_cust_key] AS cust_no,
	LTRIM(RTRIM([cn_name_pref])) AS Name_prefix,
	dbo.Removeunwantedstring([cn_name_last]) AS Name_last,
	dbo.Removeunwantedstring([cn_name_1st]) AS Name_first,
	LTRIM(RTRIM([cn_name_suff])) AS Name_suffix,
	LTRIM(RTRIM([cn_house_rte_no]))   +'^'+LTRIM(RTRIM([cn_street_pfx]))  +'^'+LTRIM(RTRIM([cn_street_nme]))+
	'^'+ LTRIM(RTRIM([cn_street_sfx]))+'^'+LTRIM(RTRIM([cn_street_sfx_md]))+'^'+LTRIM(RTRIM([cn_town]))+
	'^'+ LTRIM(RTRIM([cn_st_prov]))   +'^'+LTRIM(RTRIM([cn_zip_pc]))      +'^'+LTRIM(RTRIM([cn_zip_sector_seg]))
	AS NPJ_Address,
	LTRIM(RTRIM([cn_house_rte_no])) AS Address_number,
	LTRIM(RTRIM([cn_street_pfx])) AS Address_Street_Prefix,
	LTRIM(RTRIM([cn_street_nme])) AS Address_Street_Name,
	LTRIM(RTRIM([cn_street_sfx])) AS Address_Street_Suffix,
--	LTRIM(RTRIM([SmartyStreet_Street_Suffix_Modifier])) AS Address_Street_Modifier,
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
	END AS Phone_Primary,
	[cn_cust_key] AS Assoc_Ind_Rec,
	[cn_cust_key] AS Assoc_Ind_Rec_1,
	[cn_cust_key] AS Assoc_HH_Rec,
	[cn_cust_key] AS Assoc_HH_Rec_1
	FROM CustomerID.dbo.NPJXTCN_MIT_MISC
