
---
title: "Response Rate Meta-analysis"
author: "Mohamed"
date: "22/01/2019"
output:
   html_document: 
     df_print: tibble
     fig_caption: yes
     fig_height: 6
     rd_
     fig_width: 10
     number_sections: yes
     theme: cosmo
     toc: yes
     toc_depth: 2
     toc_float: yes
editor_options: 
  chunk_output_type: console
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Get data into R
Here we will install and run all the relelvant packages as well upload our data.

## Install dependencies

```{r packages & data, message=FALSE, warning=TRUE, paged.print=TRUE}

# Install dependencces 
library(prettydoc)
library(readxl)
library(meta)
library(metafor)
library(dplyr)
```

## Load the data into R

```{r}

# Import the data
RR_data <- readxl::read_xlsx("Data/RR_data_3.xlsx")

# Inspect the data
str(RR_data)
```


## Label some of the categorical data

```{r}

# make lables for the incentive levels
RR_data$incentives <- factor(RR_data$incentives,
levels = c("Yes", "No"),
labels = c("With Incentives", "Without Incentives"))

 # make labels for the reminder levels
RR_data$reminder <- factor(RR_data$reminder, 
levels = c("Yes", "No"),
labels = c("Reminded", "Not Reminded"))

# make labels for random aissginment levels
RR_data$rand_assign <- factor(RR_data$rand_assign,
levels = c("Yes", "No"),
labels = c("Randomly Assigned", "Not Randomly Assigned"))

```




# Random Effects Models 

Here we will create effect size and sample variance for the model. After that we will input these variables into the model.


## make effect size variable

```{r forest}
# effect size 
yi <-  RR_data$rr_diff
# sample varience 
vi <- RR_data$rr_var

```

## Build Random effects model using the metagen function


```{r}
# RE Model
RE_model<-metagen(yi,
              vi,
              label.e = "Paper Survey",
              label.c = "Digital Survey",
              data=RR_data,
              studlab=paste(study),
              comb.fixed = F,
              comb.random = TRUE,
              hakn = TRUE,
              prediction=F,
              sm="SMD")
```

## Forest Plot

We will now produce a forest plot using our RE model and then look at the statistical output of RE Model

```{r}

# forest plot 

forest(RE_model,
       xlim = c(-20,50),
       rightlabs = c("RR difference","95% CI"),
       leftlabs = c("Author(s) and Year "),
       just.addcols.left = "left",
       rightcols=c("effect", "ci"),
       pooled.totals = T,
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
       calcwidth.hetstat = T,
       col.diamond = "blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(RE_model)

```

Our model gives an overall weighted response rate difference of 12.30% (95% CI, 4.80 to 19.80), between paper and online surveys. However, the heterogeneity of the studies included was very significant with a Q score of 17,397 (I2 = 100%; p = 0.00). This substantial heterogeneity warrants further investigation.

# Between-study Heterogeneity

To detect influential studies that may be pushing the effect of our analysis into one direction. We applied Viechtbauer and Cheung’s (2010) method for detecting statistical outliers. This involved categorising studies whose confidence interval did not overlap with the overall effect confidence interval as outliers (Viechtbauer and Cheung, 2010). 

## Detecting outliers

In order to do this we must create an R package that aids us in spotting these outliers based on there confidence interval 

```{r}

# Make a function to aid detection outliers
spot.outliers.random<-function(data){
  data<-data
  Author<-data$studlab
  lowerci<-data$lower
  upperci<-data$upper
  m.outliers<-data.frame(Author,lowerci,upperci)
  te.lower<-data$lower.random
  te.upper<-data$upper.random
  dplyr::filter(m.outliers,upperci < te.lower)
  dplyr::filter(m.outliers,lowerci > te.upper)
}

# apply outlier function to our RE model 
spot.outliers.random(data=RE_model)

```

Based on our outlier function, four studies stand out greatly as their lower-bound CI is greater than the upper bound CI of our pooled effect size. These studies are Mlikotic et al, 2016, Palmen et al, 2015, Le et al, 2018 and Kallmen et al, 2011.

## Influence analysis

To analyse the individual impact on heterogeneity, each study was removed from the meta-analysis one at a time, and the individual influence on I2 was estimated. In addition, to this a diagnostic plot called Baujat plot (ref) inspecting overall heterogeneity was conducted. Baujat plot assess the contribution of each study by overall heterogeneity as measured by Cochran’s Q, and its influence on the pooled effect size on the vertical axis.


```{r}

# make an influence function 

influence.analysis<-function(data, method.tau, hakn){
  
  influence.data<-data
  TE<-data$TE
  seTE<-data$seTE
  method.tau<-method.tau
  hakn<-hakn
  
  if(hakn == TRUE){
    res <- rma(yi=TE, sei=seTE, measure="ZCOR", 
               data=influence.data, 
               method = paste(method.tau),
               test="knha")
    res
    inf <- influence(res)
    influence.data<-metainf(data)
    influence.data$I2<-format(round(influence.data$I2,2),nsmall=2)
    plot(inf)
    baujat(data,  yscale=10, xmin=10, ymin=1,
       pos=2, xlim=c(-1500, 4200), cex.studlab = 0.8)
    forest(influence.data,
           sortvar=I2,
           rightcols = c("TE","ci","I2"),
           smlab = "Sorted by I-squared")
    forest(influence.data,
           sortvar=TE,
           rightcols = c("TE","ci","I2"),
           smlab = "Sorted by Effect size")
    
  } else {
    
    res <- rma(yi=TE, sei=seTE, measure="ZCOR", 
               data=influence.data, 
               method = paste(method.tau))
    res
    inf <- influence(res)
    influence.data<-metainf(data)
    influence.data$I2<-format(round(influence.data$I2,2),nsmall=2)
    plot(inf,  yscale=10, xmin=10, ymin=1,
       pos=2, xlim=c(1500, 4200), cex.studlab = 0.8)
    baujat(data, pch = 10)
    forest(influence.data,
           sortvar=I2,
           rightcols = c("TE","ci","I2"),
           smlab = "Sorted by I-squared")
    forest(influence.data,
           sortvar=TE,
           rightcols = c("TE","ci","I2"),
           smlab = "Sorted by Effect size")
  }}  

influence.analysis(data=RE_model,method.tau = "SJ", hakn = TRUE)

```

Based on our Baujat and influential analysis, five studies appear to stand out greatly, four of which we already have come across in our initial outlier analysis. 

Mlikotic et al, 2016, 
Sinclair et al, 2012
Palmen et al, 2015, 
Le et al, 2018 and 
Kallmen et al, 2011.


## Sensitivity analysis

We will now conduct a sensitivity analysis in which the five identified outlier studies are excluded.


```{r}

# remove outliers

RE.model.outliers<-update.meta(RE_model,
                           subset = -c(2,3,4,9,15))


# re-run forest plot 

forest(RE.model.outliers,
       xlim = c(-20,60),
       rightlabs = c("RR difference","95% CI"),
       leftlabs = c("Author(s) and Year "),
       just.addcols.left = "left",
       rightcols=c("effect", "ci"),
       pooled.totals = T,
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
       calcwidth.hetstat = T,
       col.diamond = "blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(RE.model.outliers)


```

Subsequent to the removal of the five outlier studies, the Q score of went down to 239.85 (I2 = 95%; p = 0.0001). That is a drastic drop from the previous Q score which was 17, 397. This further confirms that the outliers were considerably adding to the studies heterogeneity. 

In addition to this, the new updated model has an effect size of 5.9% and a 95% confidence interval between 3.77 and 5.31; this confidence interval is much narrower than the confidence interval of the previous interval, suggesting that the previous studies were inflating the effect size.

# Subgroup analysis

Now we want to know study specfic features and effects on our meta-analysis. In order to do this we will do subgroup analysis.

## Type of surveys

Analysis looking at whether the type of study comparisons has impact on the effect size

```{r}
# build a REM for between-subgroup-differences in random assignments
type.subgroup<-update.meta(RE.model.outliers, 
                             byvar = RR_data$type, 
                             comb.random = TRUE, 
                             comb.fixed = FALSE)

# forest plot of sub-group RE Model

forest(type.subgroup,
       xlim = c(-20,30),
       rightlabs = c("RR difference","95% CI"),
       leftlabs = c("Author(s) and Year "),
       just.addcols.left = "left",
       rightcols=c("effect", "ci"),
       pooled.totals = T,
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
       fs.test.subgroup = 3,
       calcwidth.hetstat = T,
       calcwidth.tests = T,
       col.diamond = " dark blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(type.subgroup)


```





Our surveys have various different features. One othe features 


## Random assignment


```{r}

# build a REM for between-subgroup-differences in random assignments
rand.subgroup<-update.meta(RE.model.outliers, 
                             byvar=rand_assign, 
                             comb.random = TRUE, 
                             comb.fixed = FALSE)

RR_data$rand_assign

# forest plot of sub-group RE Model

forest(rand.subgroup,
       xlim = c(-20,30),
       rightlabs = c("RR difference","95% CI"),
       leftlabs = c("Author(s) and Year "),
       just.addcols.left = "left",
       rightcols=c("effect", "ci"),
       pooled.totals = T,
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
       calcwidth.hetstat = T,
        calcwidth.tests = T,
       col.diamond = "blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(rand.subgroup)

```




## Incentives


```{r}

# build a REM for between-subgroup-differences in random assignments
incent.subgroup<-update.meta(RE.model.outliers, 
                             byvar=incentives, 
                             comb.random = TRUE, 
                             comb.fixed = FALSE)

# forest plot of sub-group RE Model

forest(incent.subgroup,
       xlim = c(-20,30),
      rightlabs = c("RR difference","95% CI"),
       leftlabs = c("Author(s) and Year "),
       just.addcols.left = "left",
       rightcols=c("effect", "ci"),
       pooled.totals = T,
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
      calcwidth.hetstat = T,
       col.diamond = "blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(incent.subgroup)

```



## Reminder

```{r}

# build a REM for between-subgroup-differences in random assignments
remin.subgroup<-update.meta(RE.model.outliers, 
                             byvar=reminder,
                           bylab =  c("With Incentives", "Without incentives"),
                             comb.random = TRUE, 
                             comb.fixed = FALSE)

# forest plot of sub-group RE Model

forest(remin.subgroup,
       xlim = c(-20,30),
       label.right="Favours Paper", col.label.right="dark red",
       label.left="Favours Digital", col.label.left="dark green",
       smlab = "",
       col.by = "black",
       text.random = "Overall effect",
       print.tau2 = FALSE,
       print.byvar =F,
       calcwidth.hetstat = T,
       col.diamond = "blue",
       col.diamond.lines = "black",
       digits.sd = 2,
       print.I2 = TRUE,
       print.Q = TRUE)

# RE Model ouput

summary(remin.subgroup)

```



## Year

Here will use metaregression to really see if publication year impacts our effect size

```{r}


year.metareg<-metareg(RE.model.outliers, year)
year.metareg

bubble(year.metareg,
       ylim = c(-20, 20),
       xlim = c(1998, 2020),
       
       xlab = "Publication Year",
       col.line = "blue",
       studlab = F)

```


# Publication bias

## Funnel plot 

Here will see if our results are impacted by publication

```{r}

funnel(RE.model.outliers, xlab="Hedges' g", studlab = T)


```

We can see that some studies appear to fall outside of teh funnel, implying that there is a high likelyhood of publication bias within our pool of studies.

