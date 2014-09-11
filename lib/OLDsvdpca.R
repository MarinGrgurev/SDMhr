## SVD and PCA tests
dataTest <- data[data[,2]==1 & data[,3]==180,][c(4:13, 21:30)]

rownames(dataTest) <- NULL
dataHclust <-  hclust(dist(dataTest))
dataTestOrdered <- dataTest[dataHclust$order,]
par(mfrow=c(1,3),mar=rep(2, 4))
image(t(dataTestOrdered)[,nrow(dataTestOrdered):1])
plot(rowMeans(dataTestOrdered))
plot(colMeans(dataTestOrdered))

svdData <- svd(scale(dataTestOrdered))
par(mfrow=c(1,3),mar=rep(2, 4))
plot(svdData$u[,1])
plot(svdData$v[,1])
plot(svdData$d^2/sum(svdData$d^2))

pca1 <- prcomp(dataTest, scale=TRUE)
par(mfrow=c(1,1))
plot(pca1$rotation[,1],svdData$v[,1])
abline(c(0,1))

par(mfrow=c(1,4),mar=rep(2, 4))
plot(svdData$u[,1])
plot(svdData$u[,2])
plot(svdData$u[,3])
plot(svdData$u[,4])

