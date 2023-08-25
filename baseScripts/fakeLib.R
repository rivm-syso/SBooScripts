library(tidyverse)
library(ggdag) #for plotting DAG graphs
library(R6)
library(rlang)
#path to the SBoo package
Path2PackageSource <- "../SBoo"

#source all R files and load data from the package
Dfiles <- list.files(paste(Path2PackageSource, "data", sep = "/"), pattern = "\\.rda$")
Rded <- lapply(Dfiles, function(x) {
  Dfilename <- paste(Path2PackageSource, "data", x, sep = "/")
  if (exists("verbose") && verbose) cat(Dfilename, "\n")
  load(Dfilename, envir = global_env())
})
Rfiles <- list.files(paste(Path2PackageSource, "R", sep = "/"), pattern = "\\.R$")
sourced <- lapply(Rfiles, function(x) {
  Rfilename <- paste(Path2PackageSource, "R", x, sep = "/")
  if (exists("verbose") && verbose) cat(Rfilename, "\n")
  source(Rfilename)
})
