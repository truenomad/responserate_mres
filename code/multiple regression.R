
# Import the data

RR_data <- read.csv("Data/RR_dataIII.csv")

# sort factors out
levels(RR_data$random_assignment) <- c(0,1)
levels(RR_data$incentives) <- c(0,1)
levels(RR_data$reminder) <- c(0,1)
RR_data$reg_score <-  as.factor(RR_data$reg_score)



# check structure out 

str(RR_data)

## Multiple Linear Regression 

rs <-  lm(weighted_rr_diff ~ reg_score, data=RR_data)

ra <- lm(weighted_rr_diff ~ random_assignment, data=RR_data)
i <- lm(weighted_rr_diff ~ incentives, data=RR_data)
r <- lm(weighted_rr_diff ~ reminder, data=RR_data)

summary(rs) 

summary(ra) 
summary(i)
summary(r) 
# show results


# Capture results 
capture.output(summary(ra), summary(i), summary(r), file = "results.txt")

capture.output(summary(ra), summary(i), summary(r), file = "results.txt")

capture.output(summary(rs), file = "combined.txt")
if 




12 = rr







