# Reprodown

Reproducible Projects with R Markdown and Hugo. This packages is tested only on
Linux OS.

## About

[Reprodown](https://github.com/erickchacon/reprodown) is an R package that helps to
improve reproducibility by using:

- [Blogdown](https://github.com/rstudio/blogdown): An `R` package that
  integrates [rmarkdown](https://rmarkdown.rstudio.com) with
  [Hugo](https://gohugo.io) to create a website.
- [GNU make](https://www.gnu.org/software/make/manual/make.html): A `GNU`
  utility that determines which pieces of a program need to be compiled. This is
  based on a file called `Makefile` where dependencies are defined.
- [scholar-docs](https://github.com/erickchacon/scholar-docs): A custom `hugo`
  theme for a webpage.

The workflow of `reprodown` is to write the `.Rmd` files containing our data
analysis inside a sub-folder (e.g. scripts). Then the function
`reprodown::makefile` will read the `.Rmd` files to create automatically the
`Makefile`. The outputs are render to `html` files by simply running the utility
`make` on the terminal.

## Install

We need to install the R packages `blogdown` and `reprodown`. We need my custom
fork of `blogdown` given that I made a pull request to add a functionality to
the function `blogdown:::build_rmds`. Hopefully, this will accepted in the
future.

```r
remotes::install_github("ErickChacon/blogdown")
remotes::install_github("ErickChacon/reprodown")
```

In addition, we also need the `GNU make` utility which comes with any GNU/Linux
distribution.

## Quick start-up

```r
# create folders for project
reprodown::create_proj()
# add theme for the website
blogdown::new_site('docs', theme = 'ErickChacon/scholar-docs', sample = FALSE)
# convert the rmd files to html files
reprodown::makefile(); system(make)
# serve the site
setwd("docs"); blogdown::serve_site(); setwd("..")
# stop serve
servr::daemon_stop()
```

Look further details at 
[erickchacon.gitlab.io](https://erickchacon.gitlab.io/blog/2020-09-10-reprodown/)
