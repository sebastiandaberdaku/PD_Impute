interpolate <- function(time.points, values) {
  na.idx <- which(is.na(values))
  non.na.idx <- which(!is.na(values))
  # mean.value <- mean(values, na.rm = T)
  if (na.idx[1] == 1) { # if the first value is NA
    for (idx in 1:(non.na.idx[1]-1)) { # propagate first non-NA value left
      values[idx] <- values[non.na.idx[1]] #mean.value #values[non.na.idx[1]]
    }
  }
  if (na.idx[length(na.idx)] == length(values)) { # if the last value is NA
    for (idx in (non.na.idx[length(non.na.idx)]+1):length(values)) { # propagate last non-NA value right
      values[idx] <- values[non.na.idx[length(non.na.idx)]] #mean.value #values[non.na.idx[length(non.na.idx)]]
    }
  }
  while(any(is.na(values))) {
    na.idx <- which(is.na(values))
    na.interval <- c(na.idx[1])
    ii <- 2
    while(ii <= length(na.idx) && na.interval[length(na.interval)]+1 == na.idx[ii]) {
      na.interval <- c(na.interval, na.idx[ii])
      ii <- ii + 1
    }
    y <- c(values[na.interval[1]-1], values[na.interval[length(na.interval)]+1])
    x <- c(time.points[na.interval[1]-1], time.points[na.interval[length(na.interval)]+1])
    to.compute <- time.points[na.interval]
    linear.model <- lm(y ~ x)
    values[na.interval] <- predict(linear.model, data.frame(x = to.compute))
  }
  return(values)
}
