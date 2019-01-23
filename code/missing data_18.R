
library(readr)
library(metafor)

RR_data_1 <- read.csv("Data/RR_dataIIv_all.csv")


# drop all the studies with NA misisng data
RR_data_1 <- RR_data_1[complete.cases(RR_data_1[ , "miss_diff"]),]


RR_data_1


par(mar=c(4,4,1,2))

yi <-  RR_data_1$miss_diff
# weighted sample varience 
vi <- RR_data_1$Miss_var


### fit random-effects model (use slab argument to define study labels)
rems <- rma(yi, vi, data=RR_data_1, measure="RD",
           slab=paste(author, year, sep=", "), method="REML")



## set up forest plot 

forest(rems, xlim = c(-130, 150),
       xlab="Missing Data Difference", mlab="", psize=1)

par("usr")

### add column headings to the plot

text(-130,                7.35, "Author(s) and Year", cex = 1, font=2,  pos=4)
text(150,               7.35, "Missing Data Difference [95% CI]", cex = 1, font=2, pos=2)


### add text with Q-value, dfs, p-value, and I^2 statistic
text(-130, -0.8, pos=4, cex=0.75, bquote(paste("RE Model for All Studies (Q = ",
                                             .(formatC(rem$QE, digits=2, format="f")), ", df = ", .(rem$k - rem$p),
                                             ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                             .(formatC(rem$I2, digits=1, format="f")), "%)")))



