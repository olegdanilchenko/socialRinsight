# scrape FB insights for a given brand from a 
# start date in the form "2014-01-01" to a day before
# end date in the form "2014-02-01" along with
# token generated from FB graph explorer
# returns a cleaned date frame
# @export


fbPage <- function(brand, start, end, token) {
  dates <- fbDate(start, end)
  main_frame <- dates
  lifetime_page <- c("page_fans")
  day_page <- c("page_stories", "page_impressions", "page_impressions_unique",
                "page_impressions_paid", "page_impressions_paid_unique",
                "page_impressions_organic", "page_impressions_organic_unique", "page_impressions_viral",
                "page_impressions_viral_unique", "page_engaged_users", "page_consumptions", 
                "page_consumptions_unique", "page_negative_feedback", "page_negative_feedback_unique", 
                "page_fans_online", "page_fans_online_per_day", "page_fan_adds", "page_fan_adds_unique",
                "page_fan_removes", "page_fan_removes_unique", "page_views", "page_views_unique", 
                "page_views_login", "page_views_login_unique", "page_views_logout", "page_posts_impressions",
                "page_posts_impressions_unique", "page_posts_impressions_paid", "page_posts_impressions_paid_unique",
                "page_posts_impressions_organic", "page_posts_impressions_organic_unique",
                "page_posts_impressions_viral", "page_posts_impressions_viral_unique")
  others_page <- c("page_stories", "page_impressions", "page_impressions_unique",
                   "page_impressions_paid", "page_impressions_paid_unique",
                   "page_impressions_organic", "page_impressions_organic_unique", "page_impressions_viral",
                   "page_impressions_viral_unique", "page_engaged_users", "page_consumptions", 
                   "page_consumptions_unique", "page_negative_feedback", "page_negative_feedback_unique", 
                   "page_posts_impressions", "page_posts_impressions_unique", "page_posts_impressions_paid", "page_posts_impressions_paid_unique",
                   "page_posts_impressions_organic", "page_posts_impressions_organic_unique",
                   "page_posts_impressions_viral", "page_posts_impressions_viral_unique")
  main_frame <- page_loop(main_frame, lifetime_page, "lifetime", brand, start, end, token) 
  main_frame <- page_loop(main_frame, day_page, "day", brand, start, end, token)
  main_frame <- page_loop(main_frame, others_page, "week", brand, start, end, token)
  main_frame <- page_loop(main_frame, others_page, "days_28", brand, start, end, token)
  main_frame
  
}

# @internal
page_loop <- function(main_frame, vector, timing, brand, start, end, token){
  start <- as.Date(start) + 1
  end <- as.Date(end) + 1
  for (y in vector) {
    #vector of period metrics
    url <- paste('https://graph.facebook.com/v2.0/', brand, '/', "insights", '/', y, '?', 
                 'period=', timing, '&', 'since=', start, '&', 'until=', end, '&', 'access_token=', token, sep='')
    
    print(paste(y, "...done", sep=" "))
    fb.Graph <- content(GET(url, type="application/json"))
    fb.Graph <- fb.Graph$data
    
    if (length(fb.Graph[[1]][[4]][[1]][[1]]) > 1){
      for (i in seq(1, length(fb.Graph[[1]][[4]][[1]][[1]]))) {
        data <- sapply(fb.Graph[[1]][[4]], function (fb.Graph) fb.Graph[[1]][[i]])
        df <- data.frame(metric=data)
        names(df) <- paste(gsub(" ", "_", y), gsub(" ", "_", names(fb.Graph[[1]][[4]][[1]][[1]])[i]), sep="_")
        main_frame <- cbind(main_frame, df)
      }
    } else {
      data <- sapply(fb.Graph[[1]][[4]], function (fb.Graph) fb.Graph[[1]][[1]][[1]])
      df <- data.frame(metric=data)
      names(df) <- paste(y, timing, sep="_")
      main_frame <- cbind(main_frame, df)
    }
  }
  
  main_frame
}