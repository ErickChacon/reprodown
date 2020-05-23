#' @title Prepare Default Targets and Prerequisites for Makefile
#'
#' @description
#' \code{prepare_yaml} Obtains the yaml header of a Rmd document to add the default
#' prerequisites and targets to be used in a Makefile.
#'
#' @details
#' The yaml header is checked to add the default target "html" file and the default
#' prerequisite "Rmd" file. It append these default in case other targets and
#' prerequisites have already been defined in the header file. These can be defined
#' using a parameter starting with "targ" (e.g. targets: path/to/file.RData) for
#' targets and a parameter starting with "prer" (e.g. prerequisites:
#' path/to/req1.RData path/to/req2.RData) for prerequisites.
#'
#' @param file_rmd File to obtain the initial yaml header. This should be relative to
#' the project root path.
#' @param dir_blog File to obtain the initial yaml header.
#'
#' @return A yaml list with added default target and prerequisite.
#'
#' @author Erick A. Chacón-Montalván
#'
#' @export
prepare_yaml <- function(file_rmd, dir_blog = "docs") {
    target_html <- sub("^scripts", file.path(dir_blog, "contents"), file_rmd)
    target_html <- sub(".Rmd$", ".html", target_html)

    yaml_list <- blogdown:::split_yaml_body(blogdown:::fetch_yaml2(file_rmd))$yaml_list
    yaml_names <- names(yaml_list)
    targ_id <-  grep("^targ", yaml_names)
    prer_id <-  grep("^prer", yaml_names)

    if (length(targ_id) == 0) {
        yaml_list[["targ"]] = target_html
    } else {
        yaml_list[[targ_id]] = c(yaml_list[[targ_id]], target_html)
    }

    if (length(prer_id) == 0) {
        yaml_list[["prer"]] = file_rmd
    } else {
        yaml_list[[prer_id]] = c(file_rmd, yaml_list[[prer_id]])
    }

    return(yaml_list)
}

#' @title Create Dependency Rule Based on Yaml Header
#'
#' @description
#' \code{make_dependency} Creates a string with the Makefile syntax to create a
#' dependency rule based on a yaml list.
#'
#' @details
#' It evaluates the yaml list to obtain the prerequisites (a parameter starting with
#' "prer") and the targets (a parameter defined with "targ").
#'
#' @param yaml_list A yaml list obtained from the yaml header of a Rmd file.
#'
#' @return A string with the Makefile syntax of the dependency.
#'
#' @author Erick A. Chacón-Montalván
#'
#' @export
make_dependency <- function(yaml_list) {

    yaml_names <- names(yaml_list)
    prer_id <-  grep("^prer", yaml_names)
    targ_id <-  grep("^targ", yaml_names)

    if (length(prer_id) != 1 | length(targ_id) != 1) {
        stop("Define adequately target and prerequisites")
    }

    tg <- paste(yaml_list[[targ_id]], collapse = " ")
    pr <- paste(yaml_list[[prer_id]], collapse = " \\\n\t")
    paste(tg, pr, sep = ": \\\n\t")
}

#' @title Create Makefile for Rmd Files
#'
#' @description
#' \code{makefile} Creates a Makefile based on the prerequisites and targets defined
#' on the yaml header of Rmd scripts.
#'
#' @details
#' The prerequisites and targets of a Rmd files are defined on the yaml header using
#' parameters starting with "prer" or "targ" respectively. It is not required to put
#' the obvious prerequisite (the same Rmd file) and the obvious target (the
#' associated html file). An example is below:
#' ---
#' title: Causal Analysis of COVID-19
#' prerequisites:
#'      - data/counts.RData
#'      - data/transportation.RData
#' targets:
#'      - data/model/spatial.RData
#'      - data/model/global.RData
#' ---
#'
#' @param dir_src Directory path of the Rmd scripts.
#' @param dir_blog Directory path of your \code{blogdown} web inside your project.
#'
#' @return A Makefile with the rules
#'
#' @author Erick A. Chacón-Montalván
#'
#' @export
makefile <- function(dir_src = "scripts", dir_blog = "docs",
                     command = "") {

    # find all rmds files
    files <- blogdown:::list_rmds(dir_src, check = FALSE)
    yamls <- lapply(files, prepare_yaml, dir_blog = dir_blog)

    # ignore files where yamls includes "makefile: false"
    ignore <- sapply(yamls, function(x) isFALSE(x[["makefile"]]))
    files <- files[!ignore]
    yamls <- yamls[!ignore]

    # targets
    targets_all <- lapply(yamls, function(x) x[[grep("^targ", names(x))]])
    targets_all <- unique(unlist(targets_all))
    targets_clean <- grep(".html$", targets_all, value = TRUE)

    # makefile body
    make_var_all <-
        paste("targets_all =", paste(targets_all, collapse = " \\\n\t"))
    make_var_clean <-
        paste("targets_clean =", paste(targets_clean, collapse = " \\\n\t"))
    make_rule_all <- "all: $(target_all)"
    make_dependencies <- unlist(lapply(yamls, make_dependency))
    make_recipe_all <-
        paste0("$(target_all):\n\t", "@Rscript -e ",
               "\'blogdown:::build_rmds(\"$(<D)/$(<F)\", \"docs\", \"scripts\")\'")
    make_rule_clean <- paste("clean:", "rm -f $(targets_clean)", sep = "\n\t")

    # write makefile
    makefile <- file("Makefile")
    writeLines(c(make_var_all, make_var_clean,
                 make_rule_all, make_dependencies, make_recipe_all,
                 make_rule_clean),
               makefile, sep = "\n\n")
    close(makefile)
}