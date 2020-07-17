# Set of addon functions to inst/rmd/main.Rmd

# TODO: https://github.com/zambujo/headliner/issues/10

#' Defensive image download
#'
#' @param variables
#'
#' @return
#' @export
#'
#' @examples
img_download <- function(url_to_img, path_to_img) {

  # check whether image is available

  # check img size on the server?
  # download if not too big?


  # if not, use placeholder


  # purrr::walk2(dplyr::pull(df, image),
  #              dplyr::pull(df, tmp),
  #              download.file)

}

#' Make images latex-compatible
#'
#' @param path_to_img
#'
#' @return
#' @export
#'
#' @examples
img_fixes <- function(path_to_img) {


}
