
# Import the data
library(readr)

RR_data <- read.csv("Data/RR_dataIIv.csv")


library(metafor)

### decrease margins so the full space is used


par(mar=c(4,4,1,2))

# weighted effect size
yi <-  RR_data$weighted_rr_diff
# weighted sample varience 
vi <- RR_data$rr_var_weighted

### fit random-effects model (use slab argument to define study labels)
rem <- rma(yi, vi, data=RR_data, measure="RD",
           slab=paste(author, year, sep=", "), method="REML")


## set up forest plot 


forest(rem, xlim=c(-10, 8),
       xlab="Weighted Response Rate Difference", mlab="", psize=1)


### add column headings to the plot

text(-10.0, 17.6, "Author(s) and Year", cex=1.0, font=2, pos=4)
text(8.1, 17.6, "Response Rate Difference [95% CI]", font=2, cex=1.0, pos=2)

### add text with Q-value, dfs, p-value, and I^2 statistic
text(-10.0, -0.8, pos=4, cex=0.90, bquote(paste("RE Model for All Studies (Q = ",
                                               .(formatC(rem$QE, digits=2, format="f")), ", df = ", .(rem$k - rem$p),
                                               ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                               .(formatC(rem$I2, digits=1, format="f")), "%)")))








