rm(list=ls())

# automatically install the required packages if needed
list.of.packages <- c("tictoc", "minerva", "foreach", "doMC")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {install.packages(new.packages)}

library(minerva)
library(foreach)
library(doMC)
library(tictoc)

# setup parallel backend to use many processors
n.cores <- detectCores()
registerDoMC(n.cores)  # set the number of CPU cores to use

###################
# Read train csv and append them in a large matrix with a row for each patient visit
id_field = "subID"
time_field ="CHARTTIME"
feature.list <- c("PCL", "PK", "PLCO2", "PNA", "HCT", "HGB", "MCV", "PLT", "WBC", "RDW", "PBUN", "PCRE", "PGLU")
features <- c(id_field, time_field, feature.list)

patient.data.file <- "./code/test.na.RData"
patient.data.folder <- "./data/test_with_missing/"
output.folder <- "./data/test_imputed_interp+KNN_K3"
K = 3

if (file.exists(patient.data.file)) {
  load(patient.data.file)
} else {
  source("./code/import.patient.data.R")
  patient.data <- import.patient.data(patient.data.folder, features)
  save(list = c("patient.data"), file=patient.data.file)
}

###################
# Load MIC on train.na
mic.file <-"./code/MIC.train.na.RData"
load(mic.file)

####################
# Load the mean value for each feature on all the train.na and use it if all the visits have that feature==NA
mean.values.file <-"./code/mean.values.train.na.RData"
load(mean.values.file)

tic()
###################
# Subsets of features for the imputation methods 
feature.knn <- c("PCL", "PK", "PNA", "HCT", "HGB", "PGLU")
feature.interp <- setdiff(feature.list, feature.knn)

###################
# Imputation with linear interpolation for a subset of features
source("./code/interpolate.R")
source("./code/interp.impute.R")
patient.data.imputed.interp <- interp.impute(patient.data, feature.interp, mean.values.train.na)

###################
# Imputation with knn on the iterpolated data, for the remaining features
source("./code/impute.knn.R")
patient.data.imputed.interp.knn <- impute.knn(patient.data.imputed.interp, id_field, feature.list, feature.knn, K, MIC, mean.values.train.na)

toc()
###################
# Write to csv the imputed subjects
source("./code/export.patient.data.R")
export.patient.data(patient.data.imputed.interp.knn, id_field, output.folder)

