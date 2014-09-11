# Loading required libraries
library("RPostgreSQL")

# Establishing db connection and executing a query
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host="192.168.5.6",dbname="GISdb",user="postgres", password=getOption('pwd'))
data <- dbGetQuery(con," select emb_hor_hr.gid, pres_abs, buffer, ecolvar, statatrib, statatribvalue 
                        from emb_hor_hr, species
                        where emb_hor_hr.gid = species.gid")

# Save original file so that we don't need active connection any more
save(data, file="C:\\Users\\Marin\\OneDrive\\dev.Documents\\SDMhr\\data.Rda")
