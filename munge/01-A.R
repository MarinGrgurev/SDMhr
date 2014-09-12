# Data preprocessing script.
## Adjusting the variable class and names
### Changing the name for 3rd, 5th and 6th column
setnames(data, colnames(data)[c(2,3,4,5,6)], c("pres.abs", "radius.hr", "ecol.var", "statistic", "value"))

### Renaming all but lcov values to include word statistic in name
data[statistic != "percent", ecol.var := paste(data[statistic != "percent", ecol.var], "_", data[statistic != "percent", statistic], sep = "")]

### Remove "statistic" column as we don't need it any more
data[,statistic := NULL]

### Change pres_abs and radiushr columns to factors
data[,pres.abs := as.factor(pres.abs)]
data[,radius.hr := as.factor(radius.hr)]

### Cache data
if(!file.exists("cache/data.RData")) {cache("data")}
