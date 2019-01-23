
# Import the data
library(readr)

RR_data <- read.csv("Data/RR_dataIII.csv")


library(metafor)

### decrease margins so the full space is used

RR_data <- RR_data[-c(4),]


par(mar=c(4,4,1,2))



# weighted effect size
yi <-  RR_data$weighted_rr_diff 
# weighted sample varience 
vi <- RR_data$rr_var_weighted

### fit random-effects model (use slab argument to define study labels)
rem <- rma(yi, vi, data=RR_data, measure="RD",
           slab=paste(author, year, sep=", "), method="REML")

forest(rem, xlim=c(-12, 4), at=log(c(0.15, 0.5, 5.0, 10.0)),
       ilab.xpos=c(-10,-3), cex=1.0, ylim=c(-1,13.8), 
       xlab="Weighted Response Rate Difference", mlab="", psize=1)

### add column headings to the plot

text(-12,                12.2, "Author(s) and Year", cex=0.95, font=2, pos=4)
text(11.2,                  12.2, "Weighted Response Rate difference [95% CI]", font=2, cex=1.0, pos=2)


### add text with Q-value, dfs, p-value, and I^2 statistic
text(-12, -0.5, pos=4, cex=0.90, bquote(paste("RE  Model for All Studies",
                                              ", df = ", .(rem$k - rem$p),
                                              ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                              .(formatC(rem$I2, digits=1, format="f")), "%)")))
