

# get dependencies 

load(metafor)

# load data

RR_data <- read.csv("Data/RR_dataIII.csv")


RR_data


par(mar=c(4,4,1,2))

yii <-  RR_data$weighted_miss_diff
# weighted sample varience 
vii <- RR_data$rr_var_weighted


### fit random-effects model (use slab argument to define study labels)
rem <- rma(yii, vii, data=RR_data, weighted=TRUE, measure="RD",
           slab=paste(author, year, sep=", "), method="REML")


## set up forest plot 

forest(rem, xlim=c(-4, 4), at=log(c(0.3, 0.5, 0.7, 1.5)),
       ilab.xpos=c(-5,-3), cex=0.75, ylim=c(-1,8),
       xlab="Missing rate Difference", mlab="", psize=1)


### add column headings to the plotw

text(-4,                6.25, "Author(s) and Year", font=2,  pos=4)
text(4.0,               6.25, "Missing rate difference [95% CI]", font=2, pos=2)


### add text with Q-value, dfs, p-value, and I^2 statistic
text(-4, -0.5, pos=4, cex=0.75, bquote(paste("RE Model for All Studies (Q = ",
                                            .(formatC(rem$QE, digits=2, format="f")), ", df = ", .(rem$k - rem$p),
                                            ", p = ", .(formatC(rem$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                            .(formatC(rem$I2, digits=1, format="f")), "%)")))



