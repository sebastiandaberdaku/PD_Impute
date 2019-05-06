# PD_Impute
Interpolation and K-Nearest Neighbours Combined Imputation for Longitudinal ICU Laboratory Data

./code/PD_Impute_interp+knn_test.R <- source this file to run the imputation on the TEST set data with with linear interpolation first and then the KNN algorithm
./code/mean.values.train.na.RData <- this file contains the mean values of each of the 13 analytes in the training dataset
./code/MIC.train.na.RData <- this file contains the Maximal information coefficient among the 13 analytes of the training dataset
./code/import.patient.data.R <- contains the import.patient.data function that reads the patient data do impute from .csv files and saves it as a .Rdata for fast loading. The related object is then passed as parameter to the imputation functions
./code/impute.knn.R <- contains the impute.knn function that performs the KNN-based imputation
./code/interpolate.R <- contains the interpolate function that performs linear interpolation
./code/interp.impute.R <- contains the interp.impute function that performs the interpolation-based imputation
./code/export.patient.data.R <- contains the export.patient.data function that export the imputed patient data to .csv files
