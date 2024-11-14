# Script to load the output in parallel

### initialize ###
library(stringr)
library(tidyverse)
library(doParallel)

# Specify the environment
env <- "OOD"
#env <- "local"
#env <- "HPC"

Sys.info()

# Find file paths 
if(env == "local"){
  folderpath <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Output/" 
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
} else if(env == "OOD"){
  folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Output/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
} else if(env == "HPC"){
  folderpath <- "data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T_output/"
  filepaths <- list.files(folderpath)
  filepaths <- past0(folderpath, filepaths)
}

if(env == "local" | env == "OOD"){
  source("vignettes/CaseStudies/f_Read_SB_data.R")
} else if(env == "HPC"){
  source("/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/f_Read_SB_data.R")
}

# Set up a cluster
if (env == "local"){
  n_cores <- detectCores() - 1 
} else if (env == "OOD") {
  n_cores <- 4
} else if (env == "HPC") {
  n_cores <- detectCores()
}

cl <- makeCluster(n_cores)
registerDoParallel(cl)

# Load the data for each file path and transform the data to the correct
# Could be made into a function
results <- foreach(filepath = filepaths, .packages = c("dplyr", "tidyr", "stringr"), .combine = 'c') %dopar% {
  process_filepath(filepath)
}

# Stop the parallel backend
stopCluster(cl)

results_cleaned <- keep(results, ~ nrow(.) > 0)

TW_concentrations<- results_cleaned[["TW_concentrations"]]
TW_solutions <- results_cleaned[["TW_solutions"]]
Other_concentrations <- results_cleaned[["Other_concentrations"]]
Other_solutions <- results_cleaned[["Other_solutions"]]
Material_Parameters_long <- results_cleaned[["Material_Parameters_long"]]
Units <- results_cleaned[["Units"]] |>
  distinct()

# Bind the rows of the concentration and solution dataframes together for both sources 
Concentrations <- bind_rows(TW_concentrations, Other_concentrations)
Solution <- bind_rows(TW_solutions, Other_solutions) 

# Make longformat dfs
# Prepare the data for making figures
units <- Units |>
  pivot_longer(cols = everything(), names_to = "Abbr", values_to = "Unit")

# Make different concentration dfs for different plots
Concentrations_long <- Concentrations |>
  pivot_longer(!c(time, RUN, Polymer, Source), names_to = "Abbr", values_to = "Concentration") |>
  mutate(time = as.numeric(time)) |>
  mutate(RUN = as.integer(RUN)) |>
  mutate(Concentration = as.double(Concentration)) |>
  mutate(Year = time/(365.25*24*3600))  |>
  left_join(units, by="Abbr") |>
  left_join(States, by="Abbr") |>
  mutate(SubCompartName  = paste0(SubCompart, " (", Unit, ")"))

Solution_long <- Solution |>
  pivot_longer(!c(time, RUN, Polymer, Source), names_to = "Abbr", values_to = "Mass") |>
  mutate(time = as.numeric(time)) |>
  mutate(RUN = as.integer(RUN)) |>
  mutate(Mass = as.double(Mass)) |>
  mutate(Year = time/(365.25*24*3600)) |>
  filter(!str_starts(Abbr, "emis")) |>
  left_join(States, by="Abbr") |>
  mutate(SubCompart = case_when(
    str_detect(SubCompart, "cloudwater") ~ "air",
    TRUE ~ SubCompart)) |>
  ungroup()

# Save the outcome 
if(env == "local"){
  save(Concentrations_long, Solution_long, Material_Parameters_long, States, Units,
       file = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.Rdata",
       compress = "xz",
       compression_level = 9)
} else if(env == "OOD"){
  save(Concentrations_long, Solution_long, Material_Parameters_long, States, Units,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.2.RData",
       compress = "xz",
       compression_level = 9) 
} else if(env == "HPC"){
  save(Concentrations_long, Solution_long, Material_Parameters_long, States, Units,
       file = "data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/Long_solution_v1.2.RData",
       compress = "xz",
       compression_level = 9) 
}
