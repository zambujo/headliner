library(headliner)
sciencegeist <- rss_to_df("https://www.sciencegeist.ch/news/rss")
usethis::use_data(sciencegeist, overwrite = TRUE)
