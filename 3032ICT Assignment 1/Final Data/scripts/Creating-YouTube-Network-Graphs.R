library(vosonSML)
library(igraph)
library(dplyr)
library(textclean)
library(tidytext)
library(tidyr)
library(tm)


# YouTube Data Collection ------------------------------------------------------

# Set up YouTube authentication variables
my_youtube_api_key <- "AIzaSyA_FCkrPxhbytLzMMFyV2KyPpZw0d1Ne3M"

# Authenticate to YouTube and collect data
yt_auth <- Authenticate("youtube", apiKey = my_youtube_api_key)

video_url <- c("https://www.youtube.com/watch?v=y83x7MgzWOA", 
               "https://www.youtube.com/watch?v=JGwWNGJdvx8", 
"https://www.youtube.com/watch?v=lp-EO5I60KA", 
"https://www.youtube.com/watch?v=2Vv-BfVoq4g")

yt_data <- yt_auth |> Collect(videoIDs = video_url,
                              maxComments = 750,
                              writeToFile = TRUE,
                              verbose = TRUE) # use 'verbose' to show download progress

# View collected YouTube data
View(yt_data)


# YouTube Actor Graph -----------------------------------------------------

# Create actor network 
yt_actor_network <- yt_data |> 
  Create("actor") |> 
  AddText(yt_data,
          repliesFromText = TRUE,
          verbose = TRUE) |> 
  AddVideoData(yt_auth,
               actorSubOnly = TRUE,
               verbose = TRUE)

# Create graph from the network and change IDs to screen names
yt_actor_graph <- yt_actor_network |> Graph()
yt_actor_graph
V(yt_actor_graph)$name <- V(yt_actor_graph)$screen_name
yt_actor_graph


# Save and write graph to file
saveRDS(yt_actor_graph, file = "YouTubeActor.rds")
write_graph(yt_actor_graph, file = "YouTubeActor.graphml", format = "graphml")


# YouTube Semantic Graph --------------------------------------------------

# Clean the text with help from the textclean package
yt_clean_text <- yt_data$Comment |> 
  replace_url() |> 
  replace_html() |>
  replace_non_ascii() |> # ` vs '
  replace_word_elongation() |>
  replace_internet_slang() |>
  replace_contraction() |>
  removeNumbers() |> 
  removePunctuation()   |> 
  replace_emoji() |> # optional
  replace_emoticon() #|> # optional

yt_clean_df <- data.frame(yt_clean_text)

#  Tokenisation: split into bigrams (two neighbouring words)
yt_bigrams <- yt_clean_df |> unnest_tokens(output = bigram,
                                        input = yt_clean_text,
                                        token = "ngrams",
                                        n = 2)

yt_bigrams_table <- yt_bigrams |> 
  count(bigram, sort = TRUE) |> 
  separate(bigram, c("left", "right"))

yt_bigrams_nostops <- yt_bigrams_table |> 
  anti_join(stop_words, join_by(left == word)) |> 
  anti_join(stop_words, join_by(right == word))

# Remove rows that have 'NA'
yt_bigrams_nostops <- yt_bigrams_nostops[complete.cases(yt_bigrams_nostops), ]

# If you have lots of bigrams, keep only those that occur at least X times (here X is 2)
yt_bigrams_nostops <- yt_bigrams_nostops |> filter(n >= 2)

yt_bigram_graph <- graph_from_data_frame(yt_bigrams_nostops, directed = FALSE)

yt_bigram_graph <- simplify(yt_bigram_graph) # remove loops and multiple edges

# Save and write graph to file
saveRDS(yt_bigram_graph, file = "YouTubeSemantic.rds")
write_graph(yt_bigram_graph, file = "YouTubeSemantic.graphml", format = "graphml")
