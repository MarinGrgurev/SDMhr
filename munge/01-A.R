# Data preprocessing script.
## Adjusting the variable class and names
### Changing the name for 3rd, 5th and 6th column
setnames(data, colnames(data)[c(3,5,6)], c("radiushr", "statistic", "value"))

### Renaming all but lcov values to include word statistic in name
data[statistic != "percent", ecolvar := paste(data[statistic != "percent", ecolvar], "_", data[statistic != "percent", statistic], sep = "")]

### Remove "statistic" column as we don't need it any more
data[,statistic := NULL]

### Change pres_abs and radiushr columns to factors
data[,pres_abs := as.factor(pres_abs)]
data[,radiushr := as.factor(radiushr)]
