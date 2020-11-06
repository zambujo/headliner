#' Build headline pages
#'
#' @param .data A data frame, data frame extension (e.g. a tibble),
#'   or a lazy data frame.  Expects the following string columns
#'   *title* (required), *description*, *link*, *pub_date*, and *thumbnail*.
#' @param save_as A string with the output file name.
#'   Either *.pdf* and *.html*.
#' @param title A string with the title of the headlines page.
#' @param layout A string with the style layout. Pass "list" or "card".
#'   Please note that a *.pdf* document sets *layout* to "card".
#'
#' @return 0
#'
#' @examples
#' \dontrun{
#' data(sciencegeist)
#' sciencegeist <- utils::head(sciencegeist)
#' headlines(sciencegeist, "sciencegeist.html")
#' }
#' @export
headlines <- function(.data,
                     save_as,
                     title = "Headlines",
                     layout = "list") {
  UseMethod("headlines")
}

#' @export
headlines.data.frame <- function(.data,
                                save_as,
                                title = "Headlines",
                                layout = "list") {
  # for consistency (file path in package)
  path_to_template <-
    fs::path_package(package = "headliner", "rmd", "main.Rmd")

  # require output format to be either "html" or "pdf"
  stopifnot('Please save as \".html\" or \".pdf\"...' =
              grepl("*[.]pdf$|*[.]html$", save_as))

  if (grepl("*[.]pdf$", save_as)) {
    format <- "pdf_document"
    # if format pdf_document, force layout to card
    layout <- "card"
  } else {
    format <- "html_document"
  }

  # require layout "list" or "card"
  stopifnot('Pass \"list\" or \"card\" to `layout`' =
              layout %in% c("list", "card"))

  # require a column named `title`
  stopifnot('data.frame must include column named \"title\"' =
              "title" %in% colnames(.data))

  empty_col <- rep("", nrow(.data))

  if (!"pub_date" %in% colnames(.data))
    .data <- cbind(.data, pub_date = empty_col)

  if (!"description" %in% colnames(.data))
    .data <- cbind(.data, description = empty_col)

  if (!"link" %in% colnames(.data))
    .data <- cbind(.data, link = empty_col)

  if (purrr::pluck(dplyr::pull(.data, "link"), 1) != "")  {
    links <- dplyr::pull(.data, "link")
    domains <- urltools::domain(links)
    .data <- cbind(.data, domain = domains)
  } else {
    .data <- cbind(.data, domain = empty_col)
  }

  message("Generating headlines ......")
  rmarkdown::render(
    input = path_to_template,
    output_format = format,
    output_file = save_as,
    output_dir = here::here(),
    params = list(
      headlines = .data,
      block_type = layout,
      main_title = title
    ),
    quiet = FALSE
  ) # FALSE for debugging

  if (file.exists(here::here("tmp"))) {
    message("Cleaning up temporary files ......")
    unlink(here::here("tmp"),
           recursive = TRUE,
           force = TRUE)
  }

  return(0)
}
