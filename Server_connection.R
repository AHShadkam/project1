library(RODBC)

pass <- scan("C:/Users/ashadka/Documents/password.txt")
channel <- odbcConnect("hof",uid="ashadka",pwd=pass)

qry1 <- "SELECT [Address_Line2] 
         FROM AD_Customer.dbo.NPJXTCN_GOLDEN
         WHERE LEN([Address_Line2]) != 0 "

p<-sqlQuery(channel,qry1)

odbcClose(channel)
