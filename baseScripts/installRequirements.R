check_and_install <- function(package) {
  tryCatch({
    # Load the package
    library(package, character.only = TRUE)
    #message(paste("Package", package, "is already installed and loaded."))
  }, error = function(e) {
    # If an error occurs, install the package
    #message(paste("Package", package, "is not installed. Installing now..."))
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
    #message(paste("Package", package, "has been successfully installed and loaded."))
  })
}

# Install the required packages
check_and_install("ggplot2")
check_and_install("tidyverse")
check_and_install("constants")
check_and_install("deSolve")
check_and_install("knitr")
check_and_install("ggdag")
check_and_install("R6")
check_and_install("rlang")
check_and_install("treemapify")
check_and_install("foreach")
check_and_install("doParallel")
check_and_install("gridExtra")
