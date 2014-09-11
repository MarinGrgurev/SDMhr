setwd("c://Users/Marin/OneDrive/Development/SDMhr/")
## Mann whitney to calculate difference in mean between occurences (both presence and 
## absence) and all measured variables for each home range separately
mwSplit <- split(dataw,dataw$radiushr)
wTest <- sapply(mwSplit, function(x) {
        wTest <- wilcox.test(x[,28] ~ x[,2], exact = FALSE, rm.na=TRUE)[[3]]
}) ## still need to iterate throuh all variables

plot(cbind(radiushr=names(wTest), MW =(as.numeric(wTest))),cex=0.7)
abline(h=0.05)

## Kruskalwallis to calculate change in means between different home ranges but only 
## for presence data
kwSplit <- split(dataKruskal[dataKruskal[2]==1,], dataKruskal[3][dataKruskal[2]==1,])
kwTest <- sapply(kwSplit, function(x) {
        kwTest <- kruskal.test(x[,4])
})

plot(cbind(radiushr=names(wTest), MW =(as.numeric(wTest))))

##podatke organizirati tako sto su varijable grupe od home rangea a umejsto radius hr pisem 
##koje ekoloske varijable imam

kwSplit3 <- split(data[-c(1,2)][data[2]==1,],data[4][data[2]==1,])
system.time(replicate(100, kruskal.test(kwSplit[[2]][4:170])))
system.time(replicate(100, kruskal.test(kwSplit2[[2]][,5], kwSplit2[[2]][,3])))
system.time(replicate(100, kruskal.test(kwSplit3[[2]][,3], kwSplit3[[2]][,1])))
system.time