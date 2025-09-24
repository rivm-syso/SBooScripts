## code to prepare `DATASET` dataset goes here
The3D <- c("Scale","SubCompart","Species")
#usethis::use_data(The3D, overwrite = TRUE)
#moved to R/sysdata.rda internal use only + obey to the rules?
usethis::use_data(The3D, internal = FALSE, overwrite = T)