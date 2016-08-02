/** add RowNumber Column
    it helps to erase the duplicate customer numbers **/ 
ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
ADD [RowNumber] INT NULL;
GO

/** populate the RowNumber**/
/** rowNumber is just for the rows containing email address
    it shows the most resent inserted email partitioned by customer number **/
WITH AUS AS(
SELECT [Cust_no] 
      ,[Email_Primary]
      ,[Email_Ins_ts]
      ,ROW_NUMBER() OVER (PARTITION BY [Cust_no] ORDER BY [Email_Ins_ts] DESC) AS rn
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
WHERE len([Email_Primary]) != 0
--ORDER BY [Cust_no]
)
--DELETE FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
UPDATE t1
SET [RowNumber] = t2.rn
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN] AS t1
    INNER JOIN
    AUS AS t2
    ON (t1.Cust_no=t2.Cust_no AND t1.Email_Ins_ts=t2.Email_Ins_ts);
GO


WITH AUS AS(
SELECT [Cust_no] 
      ,[Email_Primary]
      ,[Email_Ins_ts]
      ,ROW_NUMBER() OVER (PARTITION BY [Cust_no] ORDER BY [Email_Ins_ts] DESC) AS rn
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
WHERE len([Email_Primary]) != 0
--ORDER BY [Cust_no]
)
--DELETE FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
UPDATE t1
SET [Email_Secondary] = t3.[Email_Primary]
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN] AS t1
    INNER JOIN
    AUS AS t2
    ON (t1.Cust_no=t2.Cust_no AND t1.Email_Ins_ts=t2.Email_Ins_ts)
	INNER JOIN AUS AS t3
	ON (t2.Cust_no=t3.Cust_no AND t2.rn=1 AND t3.rn=2);
GO



/** delete the rows with rownumber > 1 **/
/** we have already saved the emails in rownumber=2 in secondary email column with rownumber=1 **/
DELETE 
FROM [AD_Customer].[dbo].[NPJXTCN_GOLDEN] 
WHERE RowNumber > 1;
GO


/** delete RowNumber column **/
ALTER TABLE [AD_Customer].[dbo].[NPJXTCN_GOLDEN]
DROP COLUMN [RowNumber];
GO






