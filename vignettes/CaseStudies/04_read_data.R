# Script to load the output in parallel

### initialize ###
# library(stringr)
library(tidyverse)
# library(doParallel)

# Specify the environment
env <- "OOD"
#env <- "HPC"

# Find file paths 
if(env == "OOD"){
  folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/HPC_output_v3/"
  files <- list.files(folderpath)
  filepaths2 <- paste0(folderpath, files)
} else if(env == "HPC"){
  folderpath <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T_output_v3/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
}

#filepaths <- filepaths[grep("TWP", filepaths)]

if(env == "OOD"){
  source("vignettes/CaseStudies/f_Read_SB_data_v2.R")
} else if(env == "HPC"){
  source("/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/f_Read_SB_data.R")
}

# # Set up a cluster
# if (env == "local"){
#   n_cores <- detectCores() - 1 
# } else if (env == "OOD") {
#   n_cores <- 1
# } else if (env == "HPC") {
#   n_cores <- 12
# }
# 
# cl <- makeCluster(n_cores)
# registerDoParallel(cl)


# Load the data for each file path and transform the data to the correct
# Could be made into a function

Combined_results <- NA


start_time <- Sys.time() # to see how long it all takes...
for(BatchFile in filepaths2){
  results <- load_batch_result(BatchFile)
  if(BatchFile == filepaths2[1]){
    Combined_results <- results
  } else {
    Combined_results <- rbind(Combined_results,results)
  }
    print(BatchFile)
}

elapsed_time <- Sys.time() - start_time
print(elapsed_time)

# Save the outcome 
if(env == "OOD"){
  save(Combined_results,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/20241202_SB_Masses_v3.RData",
       compress = "xz",
       compression_level = 9) 
} else if(env == "HPC"){
  save(Solution_species, Solution_long_summed_over_pol, continental_polymer_data,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Masses.RData",
       compress = "xz",
       compression_level = 9) 
}

