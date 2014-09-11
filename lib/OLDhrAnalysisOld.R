# Set working directory
setwd("C:/Users/Marin/OneDrive/Development/SDMhr")

# Loading required libraries
library("ggplot2", lib.loc="C:/Users/Marin/Documents/R/win-library/3.1")
library("reshape2", lib.loc="C:/Users/Marin/Documents/R/win-library/3.1")
library("gridExtra", lib.loc="C:/Users/Marin/Documents/R/win-library/3.1")

# Loading data 
load("data/data.Rda")

# Preparing data df and adjusting names of variables
#data$ecolvar <- substr(data$ecolvar, 1, nchar(data$ecolvar)-2)
colnames(data) <- c("gid", "pres_abs", "radiushr", "ecolvar", "statistic", "value")
data$ecolvar[which(data$statistic != 'percent')] <- paste(data$ecolvar[which(data$statistic != 'percent')], "_", data$statistic[which(data$statistic != 'percent')], sep="")
#data$ecolvar[which(data$statistic == 'percent')] <- paste('lcov_', data$ecolvar[which(data$statistic == 'percent')], sep="")

# Removing "statistic" column
data$statistic <- NULL

# Change pres_abs column to factors
data$pres_abs <- as.factor(data$pres_abs)
data$radiushr <- as.factor(data$radiushr)

# Preparing long and wide data formats
# Casting to wide data format
dataw <- dcast(data,gid+pres_abs+radiushr~ecolvar, value.var="value")
head(dataw)

# Preparing long data format (melting)
datal <- melt(dataw, id.vars=c("gid", "pres_abs", "radiushr"), na.rm=TRUE, variable.name = "ecolvar", value.name = "value" )
head(datal)

# Getting subsets from db dataframe
datapres <- data[which(data$pres_abs==1),]
dataabs <- data[which(data$pres_abs==0),]

# Getting summary of dataframe
summary(data)
str(data)

# Attach df
attach(data)

# Getting some visualisations
# Stem plot for pres&30&dem&median
stem(value[which(pres_abs==1 & radiushr==150 & ecolvar=='dem' & statistic=='median')])

# Setting some variables
buf <- 120
var <- 'dem_median'

# Histogram
p1<-ggplot(data[which(ecolvar==var & radiushr==buf),], aes(x=value, fill=pres_abs)) +
    geom_histogram(alpha=0.5) +
    geom_density(aes(y=50*..count..),alpha=0.5) +
    scale_fill_discrete(name="",breaks=c(1,0),labels=c("presence","absence")) +
    scale_x_continuous(name="elevation (m)\n") +
    ggtitle("Histogram for elevation at home range radius = 150\n") +
    theme_bw(base_size = 12, base_family = "Helvetica") +
    theme(legend.position=c(0.9, 0.75))

# Boxplot
# Comparing ecological variables and presence/absence
p2<-ggplot(data[which(ecolvar=='dem_median' & radiushr==150),]) +
    geom_boxplot(aes(x=pres_abs,y=value,fill=pres_abs),alpha=0.5,outlier.size = 1) +
    guides(fill=FALSE) +
    scale_x_discrete(name="", breaks=c("0", "1"), labels=c("absence", "presence")) +
    scale_y_continuous(name="elevation (m)\n") +
    ggtitle("Boxplot for elevation at home range radius = 150\n") +
    theme_bw(base_size = 12, base_family = "Helvetica")

# QQ plot
p3<-ggplot(data=data[which(ecolvar=='dem_median' & radiushr==150 & pres_abs==1),], aes(sample = value[which(ecolvar=='dem_median' & radiushr==150 & pres_abs==1)])) + 
    stat_qq(alpha=1) + 
    geom_abline(aes(intercept = mean(value[which(ecolvar=='dem_median' & radiushr==150 & pres_abs==1)]), slope = sd(value[which(ecolvar=='dem_median' & radiushr==150 & pres_abs==1)]))) +
    ggtitle("QQ plot for elevation at home range radius = 150\n") +
    theme_bw()

# Comparing ecological variables and home range radius
p4<-ggplot(data[which(ecolvar=='dem_median' & pres_abs==1),]) +
    geom_boxplot(aes(x=as.factor(radiushr),y=value),alpha=0.5,outlier.size = 1) +
    scale_x_discrete(name="home range radius (m)") +
    scale_y_continuous(name="ecological variable") +
    ggtitle("Comparison boxplots for all home ranges radius\n") +
    theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
    theme_bw()


# Puting all the graphs on one page
# grid.arrange(p1,p2,p3,p4,ncol=2,main="home range radius = 150 m\n")
grid.newpage()
pushViewport(viewport(layout = grid.layout(2, 3)))
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
print(p1, vp = vplayout(1, 1))  # key is to define vplayout
print(p2, vp = vplayout(1, 2))
print(p3, vp = vplayout(1, 3))
print(p4, vp = vplayout(2, 1:3))

# Prepare plot matrix  **not finished**
newdata <- subset(data, radiushr==150 & statistic=='median' & pres_abs==0) 
ggplot(newdata, aes(newdata$value[which(newdata$ecolvar=='dem')], newdata$value[which(newdata$ecolvar=='slope')])) + 
        geom_smooth(method = "lm") + 
        geom_point() +
        theme_bw(base_size = 12, base_family = "Helvetica")
       
# Preparing HOF models
emb_hor <- HOF(dataw$pres_abs[which(dataw$radiushr==900)],dataw$dah_median[which(dataw$radiushr==900)])
plot(emb_hor, onlybest = FALSE)

# Preparing for Mann/Whitney test

wilcox.test(data$value[which(ecolvar=='dem_median' & radiushr==30 & pres_abs==1)],data$value[which(ecolvar=='dem_median' & radiushr==210 & pres_abs==1)])

