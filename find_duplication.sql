/****** 
Return all records from NPJXTCN_GOLDEN that have the Last Name match, Address Number match, 
Zip Code Match, First Name match   
******/
SELECT dX.[Cust_no]
      ,dX.[Assoc_Ind_Rec]
      ,dX.[Assoc_HH_Rec]
      ,dX.[Name_prefix]
      ,dX.[Name_last]
      ,dX.[Name_first]
      ,dX.[Name_suffix]
      ,dX.[Address_number]
      ,dX.[Address_Street_Prefix]
      ,dX.[Address_Street_Name]
      ,dX.[Address_Street_Suffix]
      ,dX.[Address_Street_Modifier]
      ,dX.[Address_BoxNubmer]
      ,dX.[Address_UnitNumber]
      ,dX.[Address_Line2]
      ,dX.[Address_ZIP_1]
      ,dX.[Address_ZIP_2]
      ,dX.[Email_Primary]
      ,dX.[Email_Secondary]
      ,dX.[Phone_Primary]
      ,dX.[Phone_Secondary]
      FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN] AS dX
		INNER JOIN (SELECT [Name_last],[Name_first],[Address_number],[Address_ZIP_1], COUNT(*) AS countOf
					FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
					GROUP BY [Name_last] ,[Name_first], [Address_number],[Address_ZIP_1]
					HAVING COUNT(*) > 1) AS dY
		ON (dX.[Name_last]=dY.[Name_last] 
		AND dX.[Name_first]=dY.[Name_first]
		AND dX.[Name_first]=dY.[Name_first]
		AND dX.[Address_number]=dY.[Address_number]
		AND dX.[Address_ZIP_1]=dY.[Address_ZIP_1])
ORDER BY dX.[Cust_no];
