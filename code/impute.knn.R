impute.knn <- function(patient.data.matrix, id_field, feature.list, features.to.impute, K, MIC, mean.values) {
  
  subject.list = unique(patient.data.matrix[, id_field])
  n.subjects <- length(subject.list) # number of subjects
  
  pairwise.feature.weights <- MIC$MIC # extract the MIC matrix to be used as weights for the KNN distance metric

  imputed.patient.data.matrix <- foreach (ii = 1:n.subjects, .combine=rbind) %dopar% {
    subj <- subject.list[ii]
    current.subject <- patient.data.matrix[which(patient.data.matrix[, id_field] == subj), ]
    n.visits <- dim(current.subject)[1]
    
    # normalisation 
    current.subject.norm <- current.subject
    for(f in feature.list){
      min.r <- min(current.subject[, f], na.rm=T)
      max.r <- max(current.subject[, f], na.rm=T)
      if (min.r != max.r) {
        scale.r <- max.r - min.r
      } else { # if min.r == max.r and they are both 0, do nothing
        scale.r <- 1
      }
      current.subject.norm[, f] <- (current.subject.norm[, f] - min.r) / scale.r
    }
    
    imputed.subject <- current.subject[, feature.list]
    
    for (visit in 1:n.visits) {
      current.visit.norm <- current.subject.norm[visit, feature.list]
      if (any(is.na(current.visit.norm[features.to.impute]))) { # start imputation
        # extract other visits
        other.visits.norm <- current.subject.norm[-visit, feature.list]
        other.visits <- current.subject[-visit, feature.list]
        
        # impute each NA in current.visit
        na.names <- names(which(is.na(current.visit.norm[features.to.impute])))
        for (na.curr.name in na.names) {
          # Compute the distance with MIC for the current feature to impute
          v.dist <- rep(NA, n.visits-1)
          for (next.visit.idx in 1:(n.visits-1)) {
            next.visit.norm <- other.visits.norm[next.visit.idx, ]
            dist <- (current.visit.norm - next.visit.norm)^2.0
            dist <- dist*(pairwise.feature.weights[na.curr.name, ])
            w <- sum(pairwise.feature.weights[na.curr.name, which(!is.na(dist))])
            if (w == 0) {w <- 1e-6}
            v.dist[next.visit.idx] <- sqrt(sum(dist, na.rm = T))/w
          }
          # compute weights as the inverse of the distance (add epsilon to avoid division by 0)
          weights <- 1/(v.dist + 1e-6) 
          values <- other.visits[, na.curr.name]
          if (all(is.na(values))) { # if the current feature has no values
            imputed.subject[visit, na.curr.name] <- mean.values[na.curr.name] # impute with the mean on patient.data.matrix
          } else {
            col.to.drop <- which(is.na(values))
            if (length(col.to.drop)>0) {
              values.no.na <- values[-col.to.drop]
              weights.no.na <- weights[-col.to.drop]
            } else {
              values.no.na <- values
              weights.no.na <- weights
            }
            # knn step: select the first K neighbours
            # Select the number of neighbours
            if (K > length(weights.no.na)) { # if the candidates are not enough
              K.n <- length(weights.no.na)
            } else {
              K.n <- K
            }
            k.idx <- order(weights.no.na, decreasing = T)[1:K.n]
            # reduce to K both the weights and values
            values.no.na.k <- values.no.na[k.idx]
            weights.no.na.k <- weights.no.na[k.idx]
            # normalize weights
            weights.no.na.k.norm <- weights.no.na.k/sum(weights.no.na.k)
            # impute the current feature
            imputed.subject[visit, na.curr.name] <- sum(values.no.na.k*weights.no.na.k.norm)
          }
        }
      }
    }
    current.subject[, feature.list] <- imputed.subject
    current.subject
  }
  return(imputed.patient.data.matrix)
}