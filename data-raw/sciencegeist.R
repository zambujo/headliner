library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(xml2)
library(rvest)
library(parsedate)

rss <- read_xml("https://www.sciencegeist.ch/news/rss")

sciencegeist <- tibble(
  title = xml_text(xml_nodes(rss, 'item title')),
  description = xml_text(xml_nodes(rss, 'item description')),
  pubDate = xml_text(xml_nodes(rss, 'item pubDate')),
  link = xml_text(xml_nodes(rss, 'item link'))) %>%
  mutate(
    title = str_squish(title),
    image = map_chr(description,
                    function(x)
                      html_attr(html_node(read_html(x), "img"), "src")),
    description = map_chr(description,
                          function(x) html_text(read_html(x))),
    description = str_squish(description),
    description = str_replace_all(description, "\'", "\\\\'"),
    description = str_replace_all(description, '\"', '\\\\"'),
    description = str_replace_all(description, "\`", "\\\\`"),
    pubDate = str_sub(pubDate, 6, 16),
    pubDate = parse_date(pubDate)) %>%
  drop_na()

usethis::use_data(sciencegeist, overwrite = TRUE)
