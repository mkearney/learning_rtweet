## Install devtools package if not already
if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

## If you don't already have the updated version of rtweet, then download it
##   from Github
if (packageVersion("rtweet") < "0.4.93") {
  devtools::install_github("mkearney/rtweet")
}

## Now you can read in the new function for adding genders variables by 
##   sourcing the add_genders_variables.R file (make sure it's saved in your
##   R folder of the learning_rtweet directory).
source("R/add_genders_variables.R")

## Load rtweet
library(rtweet)

## Select the third system token
token <- rtweet:::system_tokens()
token <- token[[3]]

## Search for tweets
rt <- search_tweets(
  "#DACA", n = 1000, include_rts = FALSE, token = token
)

## Use the add_genders_variables() function to get the genders variables
##   It will download the gender and genderdata packages for you if you 
##   haven't already done so (this can take a couple of minutes the first 
##   time you run it).
rt <- add_genders_variables(rt)

## inspect tweets data
rt

## users data
(usr <- users_data(rt))

## In theory, you could download the associated media content, e.g., 
##   save profile images.
download.file(
  gsub("normal\\.jpeg", "400x400.jpeg", usr$profile_image_url[1]), 
  "data/profile_image1.jpeg"
)

## To keep going back in time, pass the last "status_id" to the "max_id" 
##   parameter.
rt2 <- search_tweets(
  q = "#DACA", 
  n = 10000, 
  include_rts = FALSE, 
  max_id = rt$status_id[nrow(rt)]
)
## add gender variables
rt2 <- add_genders_variables(rt2)

## get users data from rt2
usr2 <- users_data(rt2)

## bind tweets data (rt, rt2) into one data frame
rt <- rbind(rt, rt2)

## bind users data (usr, usr2) into one data frame
usr <- rbind(usr, usr2)

## save the data
save_as_csv(rt, "data/DACA.csv")

## plot time series
ts_plot(rt, "15 mins")
ts_plot(rt, "days")

## most common words
words <- unlist(plain_tweets(rt$text, tokenize = TRUE))
words <- table(words)
words <- tibble::data_frame(
  word = names(words),
  n = as.integer(words)
)

## word cloud
with(
  words[words$n > 50, ], 
  wordcloud::wordcloud(
    word, n, random.color = FALSE, colors = c("purple", "blue", "red"),
    scale = c(5, 0.75)
  )
)


