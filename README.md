# POC UID project

## Data Source
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
* convert {Email insertion time, cn_date_effect, lst_nm_chg_dt, purge_dt} TYPE from varchar to date  

**Step 2:**  
clean up data (use clean_up.sql file)  
* trim the leading and end spaces (All data)
* remove some special characters (Name_last)
* remove digits (Name_last)  
* remove leading hyphens (Address_line2)  

**Step 3:**  
consolidate emails and populate the email_secondary column.  
populate secondary emails (use populate_secondary_email.sql file)
remove the Customer Number duplication
* create auxiliary column [RowNumber]
* for accounts having email, partition by Cust_no Order by Email_Ins_ts and save the email insertion order in RowNumer column.
* insert the second latest email into Email_secondary
* Delete the rows which have RowNumber>1 (removes Cust_no duplication)
* Delete the RowNumber column  

**Step 4:**   
Extract Address_Line2 data and populate the corresponding address fields.  
1- Create a table for Street_suffixes and thier abbreviations. (create_street_suffix_table.sql)  
2- Extract Address_Line2 data. (Address_line2_dataExtract.sql)  

**Step 5:**  
Remove the # sign from Address_street_name.
Remove leading and trailing hyphen sign from Address_street_name.
Remove leading and trailing comma from Address_street_name.
(clean_up_2.sql)

**Step 6**
* HouseHolding: populate Assoc_HH_Rec (house_holding.sql)
* Individual duplicate association (individual_duplicate.sql)

**Step 7**
* phone validation: delete invalid phone numbers (phone_number_validation.sql)

**Step 8**
* phone consolidation - IND: use name.first and name.last + phone to consolidate individuals.(Ind_name_phone.sql)  
it adds "Assoc_Ind_Rec_1" column.
* phone consolidation - HH: use name.first and name.last + phone to consolidate Households.(householding_name_phone.sql)  
it adds "Assoc_HH_Rec_1" column.

**Step 9**
* phone consolidation - HH: Address + phone to consolidate households.(householding_address_phone.sql)  
it adds "Assoc_HH_Rec_2" column.

 **At this stage we gave the data to others**







 












