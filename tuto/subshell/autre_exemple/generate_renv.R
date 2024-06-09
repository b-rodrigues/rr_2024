library("rix")

path_env_stringr <- file.path(".", "_env_stringr_1.4.1")

rix_init(
  project_path = path_env_stringr,
  rprofile_action = "overwrite",
  message_type = "simple"
)

rix(
  r_ver = "latest",
  r_pkgs = "stringr@1.4.1",
  overwrite = TRUE,
  project_path = path_env_stringr
)

out_nix_stringr <- with_nix(
  expr = function() stringr::str_subset(c("", "a"), ""),
  program = "R",
  exec_mode = "non-blocking",
  project_path = path_env_stringr,
  message_type = "simple"
)
