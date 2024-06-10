library(rix)

rix(r_ver = "4.2.2",
    r_pkgs = "shiny",
    ide = "other",
    shell_hook = "Rscript -e 'shiny::runApp()' ",
    project_path = "."
    )
