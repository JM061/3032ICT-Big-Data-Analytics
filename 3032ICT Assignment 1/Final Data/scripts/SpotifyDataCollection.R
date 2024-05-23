#required libraries for spotify
library(spotifyr)
library(ggplot2)
library(ggridges)

#data collection
app_id <- "82ea56894caf45e0be8b8576799cd24c"
app_secret <- "5daf0912a0584efd8186bdf0ccab25eb"
token <- "1"

Sys.setenv(SPOTIFY_CLIENT_ID = app_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = app_secret)
access_token <- get_spotify_access_token()

#find artist
find_my_artist <- search_spotify("Ed Sheeran", type = "artist")
View(find_my_artist)
Ed_Sheeran_ID <- "6eUKZXaKkcviH0Ku9w2n3V"

#View artist album
albums <- get_artist_albums(Ed_Sheeran_ID, #Ed Sheeran ID
                            include_groups = c("album", "single", "appears_on", "compilation"))
View(albums)

FirstAlbum_ID <- "02pi98kE0nra0yBqCStzbC"
MostRecentAlbum_ID <- "5bLE2kmkZWlzAYeb6To6LA"

MostRecentAlbum_Songs <- get_album_tracks(MostRecentAlbum_ID) # Ed Sheeran Album ID Autumn Variations

#view songs
View(autumn_variations_album_songs)
song <- get_track_audio_features("6b8Be6ljOzmkOmFslEb23P")
View(song)


ed_sheeran_audio_features <- get_artist_audio_features(Ed_Sheeran_ID) # artist ID for Ed 
View(ed_sheeran_audio_features)


ed_sheeran_audio_features <- ed_sheeran_audio_features[!duplicated(ed_sheeran_audio_features$track_name), ]

ggplot(ed_sheeran_audio_features, aes(x = energy, y = album_name)) +
  geom_density_ridges() +
  theme_ridges() +
  ggtitle("Energy in Ed Sheeran Albums",
          subtitle = "Based on valence from Spotify's Web API")

#Find related Artists
related_artists_es <- get_related_artists("6eUKZXaKkcviH0Ku9w2n3V")
View(related_artists_es)


edges <- c() # Line 1
for (artist in related_artists_es$id){ # Line 2
  related <- get_related_artists(artist) # Line 3
  artist_name <- get_artist(artist)$name # Line 4
  for (relatedartist in related$name){ # Line 5
    edges <- append(edges, artist_name) # Line 6
    edges <- append(edges, relatedartist) # Line 7
  }
}

edges[1:10]
related_artists_graph <- graph(edges)

plot(related_artists_graph, vertex.label = artist, vertex.size = 4, edge.arrow.size = 0.5)
write_graph(related_artists_graph, file = "Ed_Sheeran_RelatedArtists.graphml", format = "graphml")
