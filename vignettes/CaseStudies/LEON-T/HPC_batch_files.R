# Create HPC batch files
library(tidyverse)
# Initialize variables

## Define batch parameters
#batch_n <- 2
#batch_max <- 10  # Should be a multiple of batch_n for the loop logic to work

#Source <- NA
#Source <- '"Tyre wear"'

## Create parameter grid
pars <- expand.grid(
  MaxRun = seq(batch_n, batch_max, batch_n)
) |>
  mutate(MinRun = MaxRun - (batch_n - 1))

# Define the folder path
folder_path <- "vignettes/CaseStudies/LEON-T/BatchFiles"
filepaths <- c()

# Check if the folder exists
if (dir.exists(folder_path)) {
  # If the folder exists, empty its contents
  files_in_folder <- list.files(folder_path, full.names = TRUE)
  if (length(files_in_folder) > 0) {
    file.remove(files_in_folder)  # Remove all files in the folder
  }
} else {
  # If the folder doesn't exist, create it
  dir.create(folder_path)
}

for(i in 1:nrow(pars)){
  file <- readLines("vignettes/CaseStudies/LEON-T/03_get_Solution_SB.R")
  
  target_string_runs <- "RUNSamples = c"
  replacement_string_runs <- paste0("RUNSamples = c(", pars$MinRun[i], ":", pars$MaxRun[i], ")")
  
  line_index <- grep(paste0("^", target_string_runs), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_runs
  } else {
    message("String not found in file.")
  }
  
  target_string_source <- "source_of_interest <- "
  replacement_string_source <- paste0("source_of_interest = ", Source)
  
  line_index <- grep(paste0("^", target_string_source), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_source
  } else {
    message("String not found in file.")
  }
  
  if(is.na(Source)){
    source <- "Other"
  } else {
    source <- "TWP"
  }
  
  pathname <- "vignettes/CaseStudies/LEON-T/BatchFiles/"
  filename <- paste0("get_Solution_", as.character(source), "_RUN_", as.character(pars$MinRun[i]), "_", as.character(pars$MaxRun[i]), ".R")
  
  filepath <- paste0(pathname, filename)
  filepaths <- c(filepaths, filepath)
  
  writeLines(file, filepath)
}

# Now write HPC commands into a txt file
kb_per_run <- 300
time_per_run <- 20

if(!is.na(Source) && Source == "Tyre wear"){
  kb <- kb_per_run*2
  time <- time_per_run*2
} else {
  kb <- kb_per_run*15
  time <- time_per_run*15
}

# Make a string with the needed information for the cluster
LSF_string <- paste0("bsub -n 1 -W ", time, " -M ", kb, "KB Rscript")

# Paste the information toe very string
LSF_vector <- paste(LSF_string, filepaths)

# Write to txt file to make copying easy
writeLines(LSF_vector, "vignettes/CaseStudies/LEON-T/HPC_commands.txt")
