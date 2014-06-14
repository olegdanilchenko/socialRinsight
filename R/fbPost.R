# scrape FB post insights for a given brand from a 
# start date in the form "2014-01-01" to an
# end date in the form "2014-01-15" along with
# token generated from FB graph explorer
# returns a cleaned date frame

fbPost <- function(brand, start, end, token){
  if(as.Date(end) - as.Date(start) > 14){
    print("Warning!!! Recommended time period of 2 weeks exceeded")
  }
  start <- as.Date(start)
  end <- as.Date(end) + 1
  url <- paste('https://graph.facebook.com/v2.0/', brand, '/', "posts", '?', 
               'since=', start, '&', 'until=', end, '&', 'access_token=', token, sep='')
  fb.Graph <- content(GET(url, type="application/json"))
  fb.Graph <- fb.Graph$data
  rawpost_ids <- sapply(fb.Graph, function(fb.Graph) fb.Graph[[1]][[1]])
  posts <- cleanIDs(rawpost_ids, fb.Graph)
  initialize <- post_loop(posts[1], token)
  for (post in posts[-1]){
    initialize <- rbind(initialize, post_loop(post, token))
  }
  initialize
}




#remove cover photos from post IDs
cleanIDs <- function(v, v2){
  clean <- ""
  for (i in seq(1, length(v))){
    if(regexpr("cover photo", v2[[i]][[3]]) == -1) {
      clean <- c(clean, v[i])
    }
  }
  clean[-1]
}

#vector is strings of each metric needed
post_loop <- function(post_id, token){
  
  url <- paste('https://graph.facebook.com/v2.0/', post_id, '?', 
               'access_token=', token, sep='')
  fb.Graph <- content(GET(url, type="application/json"))
  post_message <- fb.Graph$message
  post_date <- as.POSIXct(fb.Graph$created_time, format="%Y-%m-%dT%H:%M:%S+0000", tz="GMT") - 14400
  
  post_type <- fb.Graph$type
  post_status_type <- fb.Graph$status_type
  initialize <- data.frame(post_id=post_id, post_message=post_message, post_date=post_date, post_type=post_type,
                           post_status_type=post_status_type)
  vector <- c("post_stories", "post_storytellers", "post_impressions", "post_impressions_unique",
              "post_impressions_paid", "post_impressions_paid_unique", "post_impressions_fan",
              "post_impressions_fan_unique", "post_impressions_fan_paid", "post_impressions_fan_paid_unique",
              "post_impressions_organic", "post_impressions_organic_unique", "post_impressions_viral",
              "post_impressions_viral_unique", "post_consumptions", "post_consumptions_unique",
              "post_engaged_users", "post_negative_feedback", "post_negative_feedback_unique")
  for (y in vector) {
    #vector of period metrics
    url <- paste('https://graph.facebook.com/v2.0/', post_id, '/', "insights", '/', y, '?', 
                 'access_token=', token, sep='')
    
    fb.Graph <- content(GET(url, type="application/json"))
    fb.Graph <- fb.Graph$data
    data <- fb.Graph[[1]][[4]][[1]][[1]]
    df <- data.frame(metric=data)
    
    names(df) <- y
    initialize <- cbind(initialize, df)
  }
  url <- paste('https://graph.facebook.com/v2.0/', post_id, '/', "insights", '/', "post_storytellers_by_action_type", '?', 
               'access_token=', token, sep='')
  fb.Graph <- content(GET(url, type="application/json"))
  fb.Graph <- fb.Graph$data
  if (length(fb.Graph[[1]]$values[[1]]$value$share) > 0) {share <- fb.Graph[[1]]$values[[1]]$value$share} else {share <- 0}
  if (length(fb.Graph[[1]]$values[[1]]$value$like) > 0) {like <- fb.Graph[[1]]$values[[1]]$value$like} else {like <- 0}
  if (length(fb.Graph[[1]]$values[[1]]$value$comment) > 0) {comment <- fb.Graph[[1]]$values[[1]]$value$comment} else {comment <- 0}
  stories <- data.frame(likes=like, comments=comment, shares=share)
  initialize <- cbind(initialize, stories)
  print(paste("post", post_id, "...done", sep=" "))
  initialize
}