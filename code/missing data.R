
library(readr)

RR_data_1 <- read.csv("Data/RR_dataIIv.csv")

RR_data_1 <- RR_data_1[-c(2,5,6,7,9),]

RR_data_1


par(mar=c(4,4,1,2))

yii <-  RR_data_1$weighted_miss_diff
# weighted sample varience 
vii <- RR_data_1$rr_var_weighted


### fit random-effects model (use slab argument to define study labels)
rem <- rma(yii, vii, data=RR_data_1, weighted=TRUE, measure="RD",
           slab=paste(author, year, sep=", "), method="REML")


## set up forest plot 

forest(rem, xlim=c(-4, 4),
       ilab.xpos=c(5,-3), cex=1.1, ylim=c(-1,7),
       xlab="Missing Data Difference", mlab="", psize=1)



### add column headings to the plot

text(-4,                5.35, "Author(s) and Year", cex = 1.1, font=2,  pos=4)
text(4.0,               5.35, "Missing Data Difference [95% CI]", cex = 1.1, font=2, pos=2)


### add text with Q-value, dfs, p-value, and I^2 statistic
text(-4, -0.8, pos=4, cex=1.1, bquote(paste("RE Model for All Studies",
                                            ", df = ", .(rem$k - rem$p),
                                            ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                            .(formatC(rem$I2, digits=1, format="f")), "%)")))



