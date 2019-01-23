

# Import the data
library(readr)

RR_data <- read.csv("Data/RR_dataIIv_all.csv")

par(mar=c(4,4,1,2))

# weighted effect size
yi <-  RR_data$rr_diff
# weighted sample varience 
vi <- RR_data$rr_var

### fit random-effects model (use slab argument to define study labels)
rem <- rma(yi, vi, data=RR_data,  measure="RD",
           slab=paste(author, year, sep=", "), method="REML")


### set up forest plot (with 2x2 table counts added; rows argument is used
### to specify exactly in which rows the outcomes will be plotted)


as.factor(RR_data$type)

par("usr") # Check where the coordinates are

forest(rem, xlim=c(-100, 100), ylim=c(-1, 24), cex=0.9, font=1,
       order=order(RR_data$type), rows=c(20:20, 1:17),
       xlab="Response Rate Difference", mlab="", psize=1)


### add text with Q-value, dfs, p-value, and I^2 statistic
text(-100, -1.0, pos=4, cex=0.8, bquote(paste("RE Model for All Studies (Q = ",
                                               .(formatC(rem$QE, digits=2, format="f")), ", df = ", .(rem$k - rem$p),
                                               ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                               .(formatC(rem$I2, digits=1, format="f")), "%)")))


### set font expansion factor (as in forest() above) and use bold italic
### font and save original settings in object 'op'

op <- par(cex=0.9, font=4)


### add text for the subgroups
text(-100, c(21, 18), pos=4, c("Paper Vs SMS",
                               "Paper Vs Web"))

# Get dashed line on
segments(coef(rem), 0, coef(rem), rem$k, lty="dashed") 

### switch to bold font
par(font=2)

text(-100, 22.5, "Author(s) and Year", cex=1, font=2, pos=4)
text(75, 22.5, "Response Rate Difference [95% CI]", font=2, cex=1.0)

