
# Import the data
library(readr)

RR_data <- read.csv("Data/RR_dataIII.csv")

RR_data <- RR_data[-c(2,4,6,11),]
library(metafor)

### decrease margins so the full space is used


par(mar=c(4,4,1,2))

# weighted effect size
yi <-  RR_data$weighted_rr_diff 
# weighted sample varience 
vi <- RR_data$rr_var_weighted

### fit random-effects model (use slab argument to define study labels)
rem <- rma(yi, vi, data=RR_data, measure="RD",
           slab=paste(author, year, sep=", "), method="FE")

## set up forest plot 

forest(rem, xlim=c(-5, 4), at=log(c(0.15, 0.5, 5.0, 10.0)),
       ilab.xpos=c(-10,-3), cex=0.95, ylim=c(-1,11),
       xlab="Weighted Response Rate Difference", mlab="", psize=1)

### add column headings to the plot

text(-5, 9.4, "Author(s) and Year", cex=0.95, font=2, pos=4)
text(4, 9.4, "Weighted Response Rate difference [95% CI]", font=2, cex=0.95, pos=2)

### add text with Q-value, dfs, p-value, and I^2 statistic
text(-5, -0.4, pos=4, cex=0.95, bquote(paste("FE Model for All Studies (Q = ",
                                            .(formatC(rem$QE, digits=2, format="f")), ", df = ", .(rem$k - rem$p),
                                            ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                            .(formatC(rem$I2, digits=1, format="f")), "%)")))







