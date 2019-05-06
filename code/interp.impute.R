interp.impute <- function(patient.data.matrix, features.to.impute, mean.values) {
  
  subject.list = unique(patient.data.matrix[, id_field])
  n.subjects <- length(subject.list) # number of subjects
  
  imputed.patient.data.matrix <- foreach (ii = 1:n.subjects, .combine=rbind) %dopar% {
    subj <- subject.list[ii]
    current.subject <- patient.data.matrix[which(patient.data.matrix[, id_field] == subj), ]
    n.visits <- dim(current.subject)[1]
    
    for (f in features.to.impute) {
      curr.subj.values <- current.subject[, f]
      curr.subj.visits <- current.subject[, time_field]
      if (any(is.na(curr.subj.values))) {
        if(sum(!is.na(curr.subj.values)) == 0){
          current.subject[, f][which(is.na(curr.subj.values))] <- mean.values[f] # impute with the mean on train.na
        } else {
          current.subject[, f] <- interpolate(curr.subj.visits, curr.subj.values)
        }
      }
    }
    current.subject
  }
  return(imputed.patient.data.matrix)
}