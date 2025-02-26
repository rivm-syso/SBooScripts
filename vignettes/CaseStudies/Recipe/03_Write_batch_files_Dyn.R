# Create HPC batch files
library(tidyverse)
# Initialize variables

## Define batch parameters

#Source <- NA
Source <- "Tyre wear"

env <- "OOD"
#env <- "HPC"

if(env == "OOD"){
  if(!is.na(Source) && Source == "Tyre wear"){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241130.RData"))
  } else if(is.na(Source)){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241130.RData"))
  }
} else if(env == "HPC"){
  mainfolder <- "/data/BioGrid/hidsa/GitHub/SBooScripts/"
  if(!is.na(Source) && Source == "Tyre wear"){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_TWP_20241130.RData"))
  } else if(is.na(Source)){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_Other_20241130.RData"))
  }
}

unique_polymers <- unique(Parameters$Material_Parameters_n$Polymer)

# Define the folder path
if(env == "OOD"){
  folder_path <- "vignettes/CaseStudies/Recipe/BatchFilesRecipe"
} else if(env == "HPC"){
  folder_path <- paste0(mainfolder,"vignettes/CaseStudies/Recipe/BatchFilesRecipe")
}

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

for(pol in unique_polymers){
  file <- readLines("vignettes/CaseStudies/Recipe/04_FateFactors_Dynamic.R")
  
  target_string_pol <- "Polymer_of_interest <- "
  replacement_string_pol <- paste0("Polymer_of_interest <- '", pol, "'")
  
  line_index <- grep(paste0("^", target_string_pol), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_pol
  } else {
    message("String not found in file.")
  }
  
  target_string_env <- "env <- "
  replacement_string_env <- paste0("env <- '", env, "'")
  
  line_index <- grep(paste0("^", target_string_env), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_env
  } else {
    message("String not found in file.")
  }
  
  target_string_source <- "source_of_interest <- "
  
  if(!is.na(Source) && Source == "Tyre wear"){
    replacement_string_source <- paste0("source_of_interest = '", Source, "'")
  } else if(is.na(Source)){
    replacement_string_source <- paste0("source_of_interest = ", Source)
  }

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
  
  pathname <- "vignettes/CaseStudies/Recipe/BatchFilesRecipe/"
  filename <- paste0("get_Solution_", as.character(source), "_", pol, ".R")
  
  filepath <- paste0(pathname, filename)
  filepaths <- c(filepaths, filepath)
  
  writeLines(file, filepath)
}

# Now write HPC commands into a txt file
kb <- 30000
time <- 400

# Make a string with the needed information for the cluster
LSF_string <- paste0("bsub -n 1 -W ", time, " -M ", kb, " -e err.txt -o out.txt Rscript")

# Paste the information toe very string
LSF_vector <- paste(LSF_string, filepaths)

# Write to txt file to make copying easy
writeLines(LSF_vector, "vignettes/CaseStudies/Recipe/HPC_commands_recipe.txt")
