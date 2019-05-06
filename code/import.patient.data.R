import.patient.data <- function(patient.data.folder, features) {
  csv.files <- list.files(path = patient.data.folder, pattern = "\\.csv$")
  patient.ids <- sort(as.integer(gsub(pattern = "\\.csv$", "", csv.files)))
  n.patients <- length(patient.ids)
  
  patient.data.list = vector("list", n.patients) 
  for (i in 1:n.patients) { # for each subject file
    id <- patient.ids[i]
    patient.data.list[[i]] = read.csv(sprintf("%s/%d.csv", patient.data.folder, id)) # load current subject
  }
  names(patient.data.list) = patient.ids # rename list elements  
  
  # count the total number of visits, i.e. the total number of rows in the output matrix
  tot.n.visits <- 0
  for (p in patient.data.list) { # for each subject 
    tot.n.visits <- tot.n.visits + dim(p)[1]
  }
  
  patient.data.matrix <- matrix(data=NA, nrow=tot.n.visits, ncol=length(features))
  colnames(patient.data.matrix) <- features
  
  ii <- 1
  for (i in 1:n.patients) { # for each subject 
    p <- patient.data.list[[i]]
    n.visits <- dim(p)[1]
    for (j in 1:n.visits) { # for each visit
      patient.data.matrix[ii,] <- c("subID"=patient.ids[i], unlist(p[j, ]))
      ii <- ii + 1
    }
  }
  
  return(patient.data.matrix)
}
