## Set working directory
setwd("C:/Users/Marin/OneDrive/Development/SDMhr")

## Loading required libraries
library("ggplot2")
library("reshape2")
library("gridExtra")

## Loading data 
load("data/data.Rda")

## Adjusting names of variables and removing "extra" variables
colnames(data) <- c("gid", "pres_abs", "radiushr", "ecolvar", "statistic", "value")
data[,4][data[5] != 'percent'] <- paste(data[,4][data[5] != 'percent'], "_", data[,5][data[5] != 'percent'], sep="")
data$statistic <- NULL

## Change pres_abs and radiushr columns to factors
data$pres_abs <- as.factor(data$pres_abs)
data$radiushr <- as.factor(data$radiushr)

## Casting from tidy to wide data format
data <- dcast(data,gid+pres_abs+radiushr~ecolvar, value.var="value")

## Conducting Mann-Whitney test to calculate difference in mean between occurences for
## all variables and for each home range separately
resultMW <- sapply(split(dataw,dataw$radiushr), function(x) {
        wTest <- wilcox.test(x[,28] ~ x[,2], exact = FALSE, rm.na=TRUE)[[3]]
}) ## still need to iterate throuh all variables

plot(cbind(radiushr=names(resultMW), MW =(as.numeric(resultMW))), cex=0.7, type='l')
abline(h=0.05)

