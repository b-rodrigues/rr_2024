library(targets)
library(tarchetypes)

list(
  tar_force(
    name = paper,
    command = quarto::quarto_render("presentation/pres_rr_2024.qmd"),
    format = "file", 
    force = TRUE
  ),

  tar_force(
    name = paper,
    command = quarto::quarto_render("tuto/tuto_rr_2024.qmd"),
    format = "file", 
    force = TRUE
  
)
