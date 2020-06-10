#' Build headline pages
#'
#' @param .data A data frame, data frame extension (e.g. a tibble),
#'   or a lazy data frame.  Expects the following string columns
#'   *title* (required), *description*, *link*, *pubDate*, and *image*.
#' @param save_as A string with the name of the static page for the output.
#' @param title A title of the headlines page
#'
#' @return 0
#'
#' @example
#' \dontrun{
#' data(sciencegeist)
#' sciencegeist <- head(sciencegeist)
#' build_hd(sciencegeist)
#' }
#' @export
build_hd <- function(.data, save_as = "headlines.html", title = "Headlines") {
  UseMethod("build_hd")
}

#' @export
build_hd.data.frame <- function(.data,
                                save_as = "headlines.html",
                                title = "Headlines") {
  # require title
  stopifnot("must include column title" = any(title %in% colnames(.data)))

  path_to_template <- system.file(
    "rmd",
    "html_simple.Rmd",
    package = "headliner")

  path_to_row <- system.file(
    "rmd/templates",
    "simple_headline.Rmd",
    package = "headliner")

  rmarkdown::render(
    input = path_to_template,
    output_format = "html_document",
    output_file = save_as,
    output_dir = "./",
    params = list(headlines = .data,
                  template_child = path_to_row,
                  set_title = title),
    quiet = TRUE)

  return(0)
}

