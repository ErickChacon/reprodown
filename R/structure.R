
create_path <- function(x) {
    if (!is.null(names(x))) {
        paths <- file.path(names(x), x[[1]])
    } else {
        paths <- x
    }
    paths <- file.path(paths, ".gitkeep")
}

yaml_to_paths <- function(file) {
    repro_str <- yaml::yaml.load_file(file)
    do.call(c, lapply(repro_str, create_path))
}

create_file <- function(file, showWarnings = TRUE) {
    dir.create(dirname(file), recursive = TRUE, showWarnings = showWarnings)
    if (!file.exists(file)) file.create(file, showWarnings = showWarnings)
}

#' @title Create folders and files for the project
#'
#' @description
#' \code{create_proj} creates folders based on the structure of a "yaml_file". By default
#' it is the structure of the file \code{system.file("reprodown.yaml", package =
#' "reprodown")}.
#'
#' @details
#' For the yaml_file. Each bullet item is understood as a folder, its corresponding
#' sub-items are considered sub-folders.
#'
#' @param dir Directory where to create our project. By default, this is the current
#' working directory.
#' @param yaml_file A file that defines the structure of the project.
#'
#' @author Erick A. Chacón-Montalván
#'
#' @export
create_proj <- function(dir = getwd(), yaml_file = system.file("reprodown.yaml", package = "reprodown")) {
    if (yaml_file != "") {
        paths <- yaml_to_paths(yaml_file)
        paths <- file.path(dir, paths)
        lapply(paths, function(x) create_file(x, showWarnings = TRUE))
    }
}
