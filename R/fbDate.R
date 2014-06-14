#scrubs dates to align with FB format

fbDate <- function(start, end) {
  rawDate <- seq.Date(as.Date(start), as.Date(end), by='day')
  date <- rawDate[-length(rawDate)]
  date.df <- data.frame(date=date)
  date.df
}