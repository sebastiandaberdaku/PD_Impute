export.patient.data <- function(patient.data.matrix, id_field, output.folder) {
  subject.list = unique(patient.data.matrix[, id_field])
  n.subjects <- length(subject.list) # number of subjects
  
  if (!dir.exists(output.folder)) {dir.create(output.folder)}
  
  f <- foreach (ii = 1:n.subjects) %dopar% {
    subj <- subject.list[ii]
    current.subject <- patient.data.matrix[which(patient.data.matrix[, id_field] == subj), colnames(patient.data.matrix) != id_field]
    
    f_out = sprintf('%s/%d.csv', output.folder, subj) # path to csv file for subject i
    write.csv(current.subject, f_out, quote = F, row.names = F) # save imputed subject
  }
}
