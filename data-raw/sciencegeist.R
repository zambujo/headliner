library(magrittr)
# library(dplyr)
# library(purrr)
# library(glue)
# library(xml2)
# library(janitor)
# library(parsedate)


# RSS parsing -------------------------------------------------------------

get_names <- function(xml_rss, parent) {
  xml_rss %>%
    xml2::xml_find_first(glue::glue(".//{ parent }")) %>%
    xml2::xml_children() %>%
    xml2::xml_name(ns = xml2::xml_ns(xml_rss))
}

get_xpath <- function(xml_rss, parent) {
  children_names <- get_names(xml_rss, parent)
  xpath <- glue::glue('.//{ parent }//{ children_names }')
  names(xpath) <- children_names
  xpath
}

extract_text <- function(x, xml_rss) {
  xml_rss %>%
    xml2::xml_find_all(x, xml2::xml_ns(xml_rss)) %>%
    xml2::xml_text()
}

extract_img <- function(x) {
  glue::glue("<tag>{x}</tag>") %>%
    xml2::read_html() %>%
    xml2::xml_find_first(".//img") %>%
    xml2::xml_attr("src")
}

html_decode <- function(x) {
  glue::glue("<tag>{x}</tag>") %>%
    xml2::read_html() %>%
    xml2::xml_text(trim = TRUE)
}

# main --------------------------------------------------------------------

rss_loc <- "https://www.sciencegeist.ch/news/rss"
# rss_loc <- "data-raw/sciencegeist.xml"

rss <- rss_loc %>%
  xml2::read_xml()

sg <- rss %>%
  get_xpath("item") %>%
  purrr::map_df(extract_text, xml_rss = rss) %>%
  janitor::clean_names()

# clean HTML --------------------------------------------------------------

if ("title" %in% colnames(sg))
  sg <- sg %>%
  dplyr::mutate(title = purrr::map_chr(title, html_decode))

if ("description" %in% colnames(sg))
  sg <- sg %>%
  dplyr::mutate(
    description_raw = description,
    description = purrr::map_chr(description, html_decode),
    thumbnail = purrr::map_chr(description_raw,
                               purrr::possibly(extract_img,
                                               NA_character_))
  )

if ("pub_date" %in% colnames(sg))
  sg <- sg %>%
  dplyr::mutate(pub_date = parsedate::parse_date(pub_date))


# TODO: test against API
test <-
  glue::glue(
    'data-raw/',
    'rss2json_dot_com.json'
    # 'https://api.rss2json.com/v1/api.json?',
    # 'rss_url=https%3A%2F%2Fwww.sciencegeist.ch%2Fnews%2Frss"'
  ) %>%
  jsonlite::fromJSON()


usethis::use_data(sciencegeist, overwrite = TRUE)
