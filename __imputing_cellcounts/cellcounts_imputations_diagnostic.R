setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

# Impute missing data
# Q. What data should be included/excluded when doing an imputation?

# Diagnostic plots 

cellcounts_wide <- read.csv("./__merging_cellcounts/cellcounts_wide.csv")
library(naniar)
library(DataExplorer)
library(misty)
require(mice)
require(psych)
require(tidyverse)

vis_miss(cellcounts_wide)

data_trimmed <- cellcounts_wide[, which(colMeans(!is.na(cellcounts_wide)) > 0.35)]
vis_miss(data_trimmed)

# eliminate ratios which are redundant (Microglia ratio is not redundant so left in)
data_trimmed[ ,c("Cerebellum_N.p.mg","Cerebellum_O.p.N","Cerebellum_O.p.mg", "CerebralCortex_N.p.mg","CerebralCortex_O.p.N","CerebralCortex_O.p.mg","RoB_O.p.N","RoB_O.p.mg","OlfactoryBulb_O.p.N","OlfactoryBulb_N.p.mg","RoB_N.p.mg")] <- list(NULL)     
vis_miss(data_trimmed)

#check for any pattern in missing data or if missing at random (mar)
data_trimmed %>% 
  # for each existing column, add a logical column indicating presence of NA
  {mutate(., across(colnames(.) %>% {setNames(., paste0(.,"_na"))}, ~ as.integer(is.na(.x))))} %>%
  # generate plot of pairwise correlations
  DataExplorer::plot_correlation(type="continuous", cor_args=list(use="pairwise.complete.obs"))
# random enough with some low correlations (orange squares)

# Scale data before imputation
s <- as.data.frame(scale(log(data_trimmed[,-1] )))

# mcar test (missing completely at random test)
na.test(s)

#histograms
multi.hist(s[,sapply(s, is.numeric)], global = F)
multi.hist(s[,sapply(s, is.numeric)], global = F)

# Compare the plots for the different algorithms to determine which are the best ones
#Tried: pmm, midas.touch, cart, rf, norm, norm.predict, lasso.norm,lasso.select.norm
#cart and rf were OK

#impute 30 datasets with maximal iterations = 10 
pred = quickpred(s, minpuc = 0.3) #only use predictors with over 30% data
imp <- mice(s, 30, maxit = 10, setseed = 777, method = "rf")

#30 imputed datasets, after 10 iterations
save(imp, file = "imp30x10.RData")
load("./__imputing_cellcounts/imp30x10.Rdata")

#get the 1st dataset
set_1 = complete(imp, 1)

#plots to examine
plot(imp)
densityplot(imp)
stripplot(imp, pch = 20, cex = 1.2) #red dots are imputed, blue are already existing -- look at the overlap

# loop to extract all datasets X number
for(imputedsets in 1: length(imp$imp[[1]])) {
  #extract imputed sets in separate dfs
  assign(paste0("dataX",imputedsets), complete(imp, imputedsets))
}

# in mice you can work on all 30 at once
do.call(regression, imp)


# Perform regression on each imputed dataset
models <- with(imp, lm(y ~ x1 + x2))

# Pool the results
pooled_model <- pool(models)
