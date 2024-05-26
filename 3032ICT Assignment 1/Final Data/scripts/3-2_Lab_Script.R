library(vosonSML)
library(igraph)

# Load your chosen network graph

youtube_network_graph <- readRDS("YouTubeActor.rds")


# Transform into an undirected graph

undir_youtube_network_graph <- as.undirected(youtube_network_graph, mode = "collapse")


# Run Louvain algorithm

louvain_comm <- cluster_louvain(undir_youtube_network_graph)


# See sizes of communities

sizes(louvain_comm)


# Visualise the Louvain communities

plot(louvain_comm, 
     undir_youtube_network_graph, 
     vertex.label = V(undir_youtube_network_graph)$screen_name,
     vertex.size = 4,
     vertex.label.cex = 0.7)
write_graph(louvain_comm, file = "louvain_youtube_network.graphml", format = "graphml")


# Run Girvan-Newman (edge-betweenness) algorithm

eb_comm <- cluster_edge_betweenness(undir_youtube_network_graph)


# See sizes of communities

sizes(eb_comm)
view(eb_comm)

# Visualise the edge-betweenness communities

plot(eb_comm,
     undir_youtube_network_graph, 
     vertex.size = 4,
     vertex.label.cex = 0)


# Visualise the edge-betweenness hierarchy

is_hierarchical(eb_comm)
as.dendrogram(eb_comm)
plot_dendrogram(eb_comm)

plot_dendrogram(eb_comm, mode = "dendrogram", xlim = c(1,20))
