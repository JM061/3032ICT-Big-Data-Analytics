#Necessary Libraries
library(VOSONDash)
library(vosonSML)
library(igraph)

#Youtube API Key
my_youtube_api_key <- "AIzaSyA_FCkrPxhbytLzMMFyV2KyPpZw0d1Ne3M"

#Youtube API Key Verification
yt_auth <- Authenticate("youtube", apiKey = my_youtube_api_key)

#Collect Youtube Video Comment Data
video_urls <- c("https://www.youtube.com/watch?v=y83x7MgzWOA", "https://www.youtube.com/watch?v=JGwWNGJdvx8", "https://www.youtube.com/watch?v=lp-EO5I60KA", "https://www.youtube.com/watch?v=2Vv-BfVoq4g")


video_url <- c("https://www.youtube.com/watch?v=2Vv-BfVoq4g")
yt_data_i_dont_care <- yt_auth |> Collect(videoIDs = video_url,
                              maxComments = 500,
                              writeToFile = TRUE,
                              verbose = TRUE)
#View Collected data
View(yt_data_i_dont_care)


#user analysis 
authors <- yt_data_i_dont_care$AuthorDisplayName
authors[1:10]

#checking duplicated authors
authors[duplicated(authors)]
#view in a table
table(authors[duplicated(authors)])

#Network Graph
yt_i_dont_care_network_graph <- yt_data_i_dont_care |> Create("actor")
yt_i_dont_care_network_actor_graph <- yt_i_dont_care_network_graph |> Graph()

#create Plot
plot(yt_i_dont_care_network_graph, vertex.label = "", vertex.size = 6, edge.arrow.size = .25, zoom = 3)

write_graph(yt_i_dont_care_network_graph, file = "i_dont_care_ACTOR_23-05.graphml", format = "graphml")


#Find important users wiht page rank
rank_yt_thinking_out_Loud <- sort(page_rank(yt_thinking_out_loud_network_actor_graph_23_05)$vector, decreasing=TRUE)
rank_yt_thinking_out_Loud[1:5]

#from yt userID to name
(yt_thinking_out_loud_network_actor_graph_23_05)$name <- V(yt_thinking_out_loud_network_actor_graph_23_05)$AuthorDisplayName

rank_yt_thinking_out_Loud <- sort(page_rank(rank_yt_thinking_out_Loud)$vector, decreasing = TRUE)
rank_yt_thinking_out_Loud[1:5]

table(authors[duplicated(authors)])
 