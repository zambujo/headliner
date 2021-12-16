# Set of utils for inst/rmd/main.Rmd

#' Defensive image download
#'
#' @param url_to_img a character string naming the URL of an image to be downloaded.
#' @param path_to_img a character string with the name where the downloaded image is saved.
#' @param max_size a numeric with the maximum size under which an image can be downloaded.
#'
#' @return 1 if success, 0 otherwise
#' @export
#'
#' @examples
download_img <- function(url_to_img, path_to_img, max_size=1000000) {
  # check whether image is available
  if (file.exists(path_to_img)) {
    message("Image already in path.")
    return(1)
  }

  all_ok <- TRUE
  # check img size on the server?
  if (isFALSE(httr::http_error(url_to_img))) {
    message("URL returns an HTTP error")
    all_ok <- FALSE
  } else {
    http_head <- httr::HEAD(url_to_img)
    if (grepl("^image", http_head$headers$`content-type`)) {
      stop("content type not an image.")
    }
    # download if not too big
    if (http_head$headers$`content-length` > max_size) {
      message("Image larger than max size. Increase 'max_size'.")
      all_ok <- FALSE
    }
  }

  if (all_ok) {
    download.file(url_to_img, path_to_img)
    return(1)
  } else {
    return(0)
  }
}


#' Make images latex-compatible
#'
#' @param path_to_img
#'
#' @return
#' @export
#'
#' @examples
fit_for_latex <- function(path_to_img) {


}
