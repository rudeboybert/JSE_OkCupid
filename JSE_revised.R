## ----include=FALSE------------------------------------------------------------
library(knitr)
opts_chunk$set(
concordance=TRUE
)


## ----echo=FALSE, warning=FALSE, message=FALSE---------------------------------
# The following packages must be installed
library(xtable)
library(stringr)
library(dplyr)
library(ggplot2)
library(utils)

# Set rounding to 2 digits
options(digits=2)

# Diambiguate filter function
filter <- dplyr::filter


## ----include=FALSE------------------------------------------------------------
# This unzips the necessary .csv file the first time you run this code.
if(!file.exists("profiles_revised.csv")){
  unzip("profiles_revised.csv.zip")
}

## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
profiles_revised <- read.csv(file="profiles_revised.csv", header=TRUE,
                             stringsAsFactors=FALSE)
n <- nrow(profiles_revised)


## ----include=FALSE------------------------------------------------------------
# This unzips the necessary .csv file the first time you run this code.
if(!file.exists("essays_revised_and_shuffled.csv")){
  unzip("essays_revised_and_shuffled.csv.zip")
}

## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
essays_revised_and_shuffled <-
  read.csv(file="essays_revised_and_shuffled.csv", header=TRUE, stringsAsFactors=FALSE)


## ----cache=TRUE, warning=FALSE, message=FALSE, all_heights, fig.height=4, fig.width=6, fig.cap="Heights of all users.", fig.align='center'----
require(mosaic)
favstats(~height, data=profiles_revised)


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
require(dplyr)
profiles_revised.subset <- filter(profiles_revised, height>=55 & height <=80)


## ----cache=TRUE, warning=FALSE, message=FALSE, heights_by_sex, fig.height=7, fig.width=10, fig.cap="Histograms of user heights split by sex.", fig.align='center'----
histogram(~height | sex, width=1, layout=c(1,2), xlab="Height in inches",
          data=profiles_revised.subset)


## ----cache=TRUE, warning=FALSE, message=FALSE, sex_and_orientation, fig.height=4, fig.width=8, fig.cap="Distributions of sex and sexual orientation.", fig.align='center'----
par(mfrow=c(1, 2))
barplot(table(profiles_revised$sex)/n, xlab="sex", ylab="proportion")
barplot(table(profiles_revised$orientation)/n, xlab="orientation", ylab="proportion")


## ----cache=TRUE, warning=FALSE, message=FALSE, sex_by_orientation, fig.height=3.5, fig.width=4, fig.cap="Joint distribution of sex and sexual orientation.", fig.align='center'----
tally(orientation ~ sex, data=profiles_revised, format='proportion')
sex.by.orientation <- tally(~sex + orientation, data=profiles_revised)
sex.by.orientation
mosaicplot(sex.by.orientation, main="Sex vs Orientation", las=1)


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
set.seed(76)
sample(1:10)
set.seed(76)
sample(1:10)
set.seed(79)
sample(1:10)


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
profiles_revised <- filter(profiles_revised, height>=55 & height <=80)
set.seed(76)
profiles_revised <- sample_n(profiles_revised, 5995)


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
require(ggplot2)
profiles_revised <- mutate(profiles_revised, is.female = ifelse(sex=="f", 1, 0))
base.plot <- ggplot(data=profiles_revised, aes(x=height, y=is.female)) +
  scale_y_continuous(breaks=0:1) +
  theme(panel.grid.minor.y = element_blank()) +
  xlab("Height in inches") +
  ylab("Is female?")


## ----cache=TRUE, warning=FALSE, message=FALSE, is_female_vs_height, fig.height=3, fig.width=6, fig.cap="Female indicator vs height.", fig.align='center'----
base.plot + geom_point()


## ----cache=TRUE, warning=FALSE, message=FALSE, is_female_vs_height_jittered, fig.height=3, fig.width=6, fig.cap="Female indicator vs height (jittered).", fig.align='center'----
base.plot + geom_jitter(position = position_jitter(width = .2, height=.2))


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
linear.model <- lm(is.female ~ height, data=profiles_revised)
msummary(linear.model)
b1 <- coef(linear.model)
b1


## ----cache=TRUE, warning=FALSE, message=FALSE---------------------------------
logistic.model <- glm(is.female ~ height, family=binomial, data=profiles_revised)
msummary(logistic.model)
b2 <- coefficients(logistic.model)
b2


## ----cache=TRUE, warning=FALSE, message=FALSE, is_female_vs_height_logistic_vs_linear, fig.height=3, fig.width=6, fig.cap="Predicted linear (red) and logistic (blue) regression curves.", fig.align='center'----
inverse.logit <- function(x, b){
  linear.equation <- b[1] + b[2]*x
  1/(1+exp(-linear.equation))
}
base.plot + geom_jitter(position = position_jitter(width = .2, height=.2)) +
  geom_abline(intercept=b1[1], slope=b1[2], col="red", size=2) +
  stat_function(fun = inverse.logit, args=list(b=b2), color="blue", size=2)


## ----cache=TRUE, warning=FALSE, message=FALSE, fitted_values, fig.height=3.5, fig.width=5, fig.cap="Fitted probabilities of being female and decision threshold (in red).", fig.align='center'----
profiles_revised$p.hat <- fitted(logistic.model)
ggplot(data=profiles_revised, aes(x=p.hat)) +
  geom_histogram(binwidth=0.1) +
  xlab(expression(hat(p))) +
  ylab("Frequency") +
  xlim(c(0,1)) +
  geom_vline(xintercept=0.5, col="red", size=1.2)
profiles_revised <- mutate(profiles_revised, predicted.female = p.hat >= 0.5)
tally(~is.female + predicted.female, data=profiles_revised)


## ----cache=TRUE, echo=FALSE, warning=FALSE, message=FALSE---------------------
# Compute misclassification error rate
perf.table <- table(truth=profiles_revised$is.female, prediction=profiles_revised$predicted.female)
misclass.error <- 1 - sum(diag(perf.table))/sum(perf.table)


## ----echo=TRUE, eval=FALSE, warning=FALSE, message=FALSE----------------------
## library(knitr)
## purl(input="JSE.Rnw", output="JSE.R", quiet=TRUE)

