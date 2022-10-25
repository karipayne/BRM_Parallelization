library(dplyr)
library(lattice)
library(ggplot2)
library(MASS)
library(tidyr)
library(zoo)
library(lme4)
library(effects)
library(brms)
library(tidybayes)
library(modelr)
library(gridExtra)
library(bayesplot)
library(hexbin)
library(foreach)
library(doParallel)
# Libraries copied from another analysis file. Some are not needed in this file, but
# will be later when I add this code back in elsewhere.

myd<- read.csv("allMCBRD.csv", na.strings="NA", stringsAsFactors = T)
euc <- myd$Euc_Distance_VA

# Recoding zeroes to half of the smallest other value (minimum)
# This is to run a censored regression later.
euc.min <- min(euc[which(euc != 0)])
euc.transform <- ifelse(euc == 0, (euc.min/2), euc)
sort(unique(euc.transform))[1:15] # this shows that the minimum has been correctly adjusted. It's just that R is rounding weirdly for other functions
euc.min.trans <- euc.min/2
euc.min.trans
myd$euctrans <- euc.transform

# Set up censoring
myd$censored = ifelse(myd$euctrans==euc.min.trans, -1, 0) #lowercase Censored for running the model
myd$Censored.graph = ifelse(myd$euctrans==euc.min.trans, "Yes", "No") #uppercase Censored.graph for graphing later

myd$TRIAL_blurCondition.c <- (myd$TRIAL_blurCondition - 0.3) # centering predictor by mean value
myd$TRIAL_windowCondition.c <- (myd$TRIAL_windowCondition - 3) # centering predictor by mean value

# Set priors

priors2 = c(prior("student_t(3, -1, 4)", class = "Intercept"),
            prior("student_t(3, 0, 3)", class = "sd"),
            prior("lkj(2)", class = "cor"),
            prior("student_t(3, 0, 3)", class = "b")
            #prior("student_t(3, 0, .1)", class = "sd", coef = "c.day", group="ID"),
            #prior_string("student_t(3, 0, 0.5)", class = "b", coef = paste("GROUP", 1:4, sep="")),
            #prior_string("student_t(3,-.2, .1)", class = "b", coef = "c.day"),
            #prior_string("student_t(3, 0, 0.1)", class = "b", coef = paste("c.day:GROUP", 1:4, sep=""))
)

# Run the model
b3.2c <-brm(euctrans| cens(censored)~ TRIAL_blurCondition.c * TRIAL_windowCondition.c + (TRIAL_blurCondition.c * TRIAL_windowCondition.c|TRIAL_VideoName) + (TRIAL_blurCondition.c * TRIAL_windowCondition.c|participant), family=Gamma(link="log"),
           data=myd, init="0", iter=20000, chains = 4, cores = 4, backend = "cmdstanr", threads = 10, warmup = 1500,
           prior = priors2, save_pars=save_pars(all=TRUE)) #control = list(adapt_delta = 0.95))

# Save the model
saveRDS(b3.2c, "models/b3.2c_BEOCAT.rds")
