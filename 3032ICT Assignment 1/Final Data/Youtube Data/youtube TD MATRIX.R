library(vosonSML)
library(dplyr)
library(tidyr)
library(tidytext)
library(textclean)
library(tm)
library(ggplot2)
library(igraph)


# TD Matrix Creation
#Youtube 
yt_clean_text <- yt_data_no_na$Comment |> 
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
yt_data_no_na <- yt_clean_df[complete.cases(yt_clean_df), ]
yt_data_no_na[1:10]

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
saveRDS(yt_bigram_graph, file = "Test_YouTubeSemantic.rds")
write_graph(yt_bigram_graph, file = "Test_YouTubeSemantic.graphml", format = "graphml")
