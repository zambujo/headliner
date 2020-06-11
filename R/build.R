#' Build headline pages
#'
#' @param .data A data frame, data frame extension (e.g. a tibble),
#'   or a lazy data frame.  Expects the following string columns
#'   *title* (required), *description*, *link*, *pubDate*, and *image*.
#' @param save_as A string with the name of the static page for the output.
#' @param title A string with the title of the headlines page.
#' @param format The output format to be passed to `rmarkdown::render` (TODO)
#' @param layout A string with the style layout. Pass "list" or "card".
#'
#' @return 0
#'
#' @examples
#' \dontrun{
#' data(sciencegeist)
#' sciencegeist <- head(sciencegeist)
#' build_hd(sciencegeist)
#' }
#' @export
build_hd <- function(.data,
                     save_as = "headlines.html",
                     title = "Headlines",
                     format = "html_document",
                     layout = "list") {
  UseMethod("build_hd")
}

#' @export
build_hd.data.frame <- function(.data,
                                save_as = "headlines.html",
                                title = "Headlines",
                                format = "html_document",
                                layout = "list") {

  # require a column named `title`
  stopifnot('data.frame must include column named \"title\"' =
              "title" %in% colnames(.data))
  # require layout "list" or "card"
  stopifnot('Pass \"list\" or \"card\" to `layout`' =
              layout %in% c("list", "card"))
  # require format to be either "html_document" or "pdf_document"
  stopifnot('Pass \"html_document\" or \"pdf_document\" to `format`' =
              format %in% c("html_document", "pdf_document"))

  # absolute path to the rmd template
  path_to_template <- system.file(
    "rmd", "html_main.Rmd", package = "headliner")

  rmarkdown::render(
    input = path_to_template,
    output_format = format,
    output_file = save_as,
    output_dir = "./",
    params = list(headlines = .data,
                  block_type = layout,
                  main_title = title),
    quiet = FALSE) # FALSE for debugging

  return(0)
}

