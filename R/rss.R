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
  img_src <- NA_character_
  img_size <- c("height", "height")
  img_attrs <- glue::glue("<tag>{x}</tag>") %>%
    xml2::read_html() %>%
    xml2::xml_find_first(".//img") %>%
    xml2::xml_attrs()
  if ((!is.na(img_attrs)) &&
      (all(img_size %in% names(img_attrs)))) {
    h <- as.numeric(purrr::pluck(img_attrs, "height"))
    w <- as.numeric(purrr::pluck(img_attrs, "width"))
    if ((h > 99 & h < 601) && (w > 199 & w < 801)) {
      img_src <- purrr::pluck(img_attrs, "src")
    }
  }
  img_src
}

html_decode <- function(x) {
  glue::glue("<tag>{x}</tag>") %>%
    xml2::read_html() %>%
    xml2::xml_text(trim = TRUE)
}


#' Parse an RSS feed (XML)
#'
#' @param rss_feed A string pointing to the RSS URL.
#'
#' @return A tibble with RSS data.
#' @export
#'
#' @examples
#' rss_to_df("https://www.sciencegeist.ch/news/rss")
rss_to_df <- function(rss_feed) {
  rss_obj <-  xml2::read_xml(rss_feed)

  df <- rss_obj %>%
    get_xpath("item") %>%
    purrr::map_df(extract_text, xml_rss = rss_obj) %>%
    janitor::clean_names()

  if ("title" %in% colnames(df))
    df <- dplyr::mutate(df,
                        title = purrr::map_chr(title, html_decode))

  if ("dc_creator" %in% colnames(df))
    df <- dplyr::mutate(df,
                        dc_creator = stringr::str_squish(dc_creator))

  if ("description" %in% colnames(df))
    df <- df %>%
    dplyr::mutate(
      description_raw = description,
      description = purrr::map_chr(description, html_decode),
      thumbnail = purrr::map_chr(
        description_raw,
        purrr::possibly(extract_img,
                        NA_character_)
      )
    ) %>%
    dplyr::select(-description_raw)

  if ("pub_date" %in% colnames(df))
    df <- dplyr::mutate(
      df,
      pub_date = parsedate::parse_date(pub_date),
      pub_date = stringr::str_sub(pub_date, 1, 10)
    )

  df
}
