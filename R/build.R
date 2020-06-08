#' Build a simple headline page
#'
#' @param x A dataframe containing columns title, description, and link.
#' @param saveas A string with the name of the static page for the output.
#' @param title A title of the headlines page
#'
#' @return NULL
build_simple <- function(x, saveas = "headlines.html", title = "Title") {
  rmarkdown::render(
    input = here::here("inst", "rmd", "html_simple.Rmd"),
    output_format = "html_document",
    output_file = saveas,
    output_dir = "./",
    params = list(headlines = x, set_title = title),
    quiet = FALSE)

}

