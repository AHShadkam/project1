With my_emails AS 
(
	SELECT [CUS_NO]
	  ,ROW_NUMBER() OVER (PARTITION BY [CUS_NO] ORDER BY [CRT_TS] DESC) AS RN
      ,[CUS_EML_AD]
      ,dbo.udf_CleanEmail([CUS_EML_AD]) AS Cleaned_email
      ,[CRT_TS]
	FROM [CustomerID].[dbo].[NPJXTCE]
	Where dbo.udf_ValidateEmail(dbo.udf_CleanEmail([CUS_EML_AD])) = 1
) 

UPDATE T1
SET T1.Email_Primary = UPPER(T2.Cleaned_email)
	, T1.Email_Ins_ts = T2.CRT_TS
FROM CustomerID.dbo.GOLDEN_RECORD_MIT AS T1
INNER JOIN my_emails AS T2
ON T1.Cust_no=T2.CUS_NO 
WHERE T2.RN =1;
GO
With my_emails AS 
(
	SELECT [CUS_NO]
	  ,ROW_NUMBER() OVER (PARTITION BY [CUS_NO] ORDER BY [CRT_TS] DESC) AS RN
      ,[CUS_EML_AD]
      ,dbo.udf_CleanEmail([CUS_EML_AD]) AS Cleaned_email
      ,[CRT_TS]
	FROM [CustomerID].[dbo].[NPJXTCE]
	Where dbo.udf_ValidateEmail(dbo.udf_CleanEmail([CUS_EML_AD])) = 1
) 

UPDATE T1
SET T1.Email_Secondary = UPPER(T2.Cleaned_email)
FROM CustomerID.dbo.GOLDEN_RECORD_MIT AS T1
INNER JOIN my_emails AS T2
ON T1.Cust_no=T2.CUS_NO 
WHERE T2.RN =2
AND UPPER(T1.Email_Primary) != UPPER(T2.Cleaned_email);
