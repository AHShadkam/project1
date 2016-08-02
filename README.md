# POC UID project

**Database:** HOFDVXHIBSQL1  --> AD_Customer  
**Table:** [dbo].[NPJXTCN_STG]  

## File Description
create_golden_table.sql  

clean_up.sql

consolidate.sql  

find_duplication.sql

server_connection.R  

* * *  
## procedure  
**Step 1:**  
create the golden table (use the create_golden_table.sqlfile)  
* convert email addresses to Upper case
* convert Email insertion time TYPE from varchar to date  

**Step 2:**  
clean up data (use clean_up.sql file)  
* trim the leading and end spaces (All data)
* remove some special characters (Name_last)
* remove digits (Name_last)  
* remove leading hyphens (Address_line2)  

**step3:**  
consolidate emails and populate the email_secondary column.  












