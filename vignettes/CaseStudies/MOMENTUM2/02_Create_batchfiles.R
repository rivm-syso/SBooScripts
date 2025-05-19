################################################################################
# Script to create batch files for running SimpleBox for Momentum2 
# Task 6.2.2
# 19-5-2025
# Anne Hids and Joris Quik
################################################################################

library(tidyverse)

path_parameters_file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Variables/Microplastic_variables_MOMENTUM2.xlsx"

##### Prepare variable data
Material_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Polymer_data") |> 
  # change um to nm unit conversion
  mutate(across(c(a, b, c, d), as.numeric)) |>
  mutate(across(c(a, b, c, d), ~ case_when(
    str_detect(Unit, "um") ~ . * 1000,
    TRUE ~ .
  ))) |>
  mutate(Unit = case_when(
    str_detect(Unit, "um") ~ "nm",
    TRUE ~ Unit
  )) 

# Select the needed columns
Material_Parameters <- Material_Parameters |>
  select(!starts_with("."))

# Define the name of 'other' polymers
materials <- c("ABS", "Acryl", "EPS", "HDPE", "LDPE", "OTHER", "PA", "PC", "PET", "PMMA", "PP", "PS", "PUR", "PVC", "RUBBER")

explodeF <- function(df, target_col, explode_value, new_values) {
  df |>
    # Use mutate to create a new column if the target column equals explode_value
    mutate(!!sym(target_col) := ifelse(!!sym(target_col) == explode_value, list(new_values), !!sym(target_col))) %>%
    # Unnest the target column to duplicate rows
    unnest(!!sym(target_col))
}

suppressWarnings({
  Material_Parameters <- explodeF(Material_Parameters, target_col = "Polymer", explode_value = "any", new_values = materials) # move this after and save unique values (n=same as in xlsx)
})

Material_Parameters <- Material_Parameters |>
  mutate(d = as.character(d)) |>
  mutate(d = case_when(
    Distribution == "TRWP_size" ~ path_parameters_file,
    TRUE ~ d
  ))

##### Run SimpleBox
load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/InputData/DPMFA_SBinput_20250519.RData")

emis_list <- list()

# Split the emissions per polymer
for(i in unique(DPMFA_sink_micro$Polymer)){
  emissions <- DPMFA_sink_micro |>
    filter(Polymer == i)
  
  emis_list[[i]] <- emissions
}

variable_list <- list()

# Split the variable values per polymer
for(i in unique(Material_Parameters$Polymer)){
  variable_df <- Material_Parameters |>
    filter(Polymer == i)
  
  variable_list[[i]] <- variable_df
}

# Save the variables and the emissions to the Data folder
save(emis_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/emis_list.RData")
save(variable_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/variable_list.RData")

polymer <- "PET"

#### Create the batch files

# Define the folder path
folder_path <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles"
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

for(polymer in unique(Material_Parameters$Polymer)){
  file <- readLines("vignettes/CaseStudies/MOMENTUM2/SB_run.R")
  
  target_string_runs <- "polymer <- "
  replacement_string_runs <- paste0("polymer <- ", '"', polymer, '"')
  
  line_index <- grep(paste0("^", target_string_runs), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_runs
  } else {
    message("String not found in file.")
  }
 
  pathname <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles/"
  filename <- paste0("SB_run_", polymer, ".R")
  
  filepath <- paste0(pathname, filename)
  filepaths <- c(filepaths, filepath)
  
  writeLines(file, filepath)
}

# Now write HPC commands into a txt file
mb <- 30
time <- 5000

# Make a string with the needed information for the cluster
LSF_string <- paste0("bsub -n 1 -e err.txt -o out.txt -W ", time, " -M ", mb, "MB Rscript")

# Paste the information to very string
LSF_vector <- paste(LSF_string, filepaths)

# Write to txt file to make copying easy
writeLines(LSF_vector, "vignettes/CaseStudies/MOMENTUM2/HPC_commands.txt")

