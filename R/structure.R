
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

create_proj <- function(dir = getwd(), yaml_file = system.file("reprodown.yaml", package = "reprodown")) {

    if (yaml_file != "") {
        paths <- yaml_to_paths(yaml_file)
        paths <- file.path(dir, paths)
        lapply(paths, function(x) dir.create(dirname(x), recursive = TRUE, showWarnings = FALSE))
        lapply(paths, function(x) file.create(x, recursive = TRUE, showWarnings = FALSE))
    }
}
