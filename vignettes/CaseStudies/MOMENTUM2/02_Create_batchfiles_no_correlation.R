################################################################################
# Script to create batch files for running SimpleBox for Momentum2 
# Task 6.2.2
# 19-5-2025
# Anne Hids and Joris Quik
################################################################################

library(tidyverse)

data_folder <- "vignettes/CaseStudies/MOMENTUM2/Data/"

path_parameters_file <- paste0(data_folder, "Microplastic_variables_MOMENTUM2.xlsx")
  
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

# #### Prepare the correlations
# materials <- c(materials, "NR", "SBR")
# 
# Correlations <- readxl::read_xlsx(path_parameters_file, sheet = "Correlation")
# Correlations <- Correlations |>
#   mutate(correlation = as.numeric(str_replace(correlation, ",", ".")))
# 
# polymer_specific_correlations <- Correlations |>
#   filter(Polymer != "any")
# 
# any_polymer_correlations <- Correlations |>
#   filter(Polymer == "any")
# 
# suppressWarnings({
#   correlations <- explodeF(any_polymer_correlations, target_col = "Polymer", explode_value = "any", new_values = materials) # move this after and save unique values (n=same as in xlsx)
# })
# 
# correlations <- correlations |>
#   anti_join(polymer_specific_correlations, by = c("varName_1", "varName_2", "Polymer"))
# 
# correlations <- bind_rows(correlations, polymer_specific_correlations)
# 
# correlation_list <- list()
# 
# for(i in unique(correlations$Polymer)){
#   correlation <- correlations |>
#     filter(Polymer == i) |>
#     select(-Polymer)
#   
#   correlation_list[[i]] <- correlation
# }

##### Create the batch files for running SimpleBox
load(paste0(data_folder, "DPMFA_SBinput_20250519.RData"))

emis_list <- list()

# Split the emissions per polymer
for(i in unique(DPMFA_sink_micro$Polymer)){
  emissions <- DPMFA_sink_micro |>
    filter(Polymer == i)
  
  emis_list[[i]] <- emissions
}

variable_list <- list()
lhs_list <- list()

# Split the variable values per polymer
for(i in unique(Material_Parameters$Polymer)){
  variable_df <- Material_Parameters |>
    filter(Polymer == i)
  
  variable_list[[i]] <- variable_df
  
  #Correlations <- correlation_list[[i]]
  
  # Prepare the LHS samples
  source("baseScripts/initWorld_onlyPlastics.R")
  if(i %in% c("NR", "SBR")){
    World$substance <- "TRWP"
  } else {
    World$substance <- "microplastic"  
  }
  
  variable_distributions <- World$makeInvFuns(variable_df)
  
  World$NewSolver("DynamicSolver")
  World$Solve(emissions = NULL, 
              var_box_df = variable_df, 
              var_invFun = variable_distributions, 
              nRUNs = length(unique(emis_list[[i]]$RUN)), 
              #correlations = Correlations, 
              ParallelPreparation = T)
  
  LHSsamples <- readRDS("data/scaledLHSsamples.RDS")
  lhs_list[[i]] <- LHSsamples
}

# Save the variables and the emissions to the Data folder
save(lhs_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/lhs_list.RData")
save(emis_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/emis_list.RData")
save(variable_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/variable_list.RData")
#save(correlation_list, file = "vignettes/CaseStudies/MOMENTUM2/Data/correlation_list.RData")

#### Create the batch files

# Define the folder path
folder_path <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles"

if (!dir.exists(folder_path)) {
  # The folder does not exist, so create it
  dir.create(folder_path, recursive = TRUE)
  cat("Folder created:", folder_path, "\n")
} else {
  # The folder already exists, so empty it
  files <- list.files(folder_path, full.names = TRUE) # List all files in the folder
  if (length(files) > 0) {
    file.remove(files) # Remove all files
    cat(length(files), "files removed from folder:", folder_path, "\n")
  } else {
    cat("Folder already exists and is already empty:", folder_path, "\n")
  }
}

filepaths <- c()

# Define runs per batch and total runs
runs_per_batch <- 10
total_runs <- length(unique(emissions$RUN))

# Calculate the max batch number
batch_max <- ceiling(total_runs / runs_per_batch)

# Create the pars dataframe
pars <- expand.grid(
  MaxRun = seq(runs_per_batch, runs_per_batch * batch_max, runs_per_batch)
) |>
  mutate(
    MinRun = MaxRun - (runs_per_batch - 1),
    # Ensure MaxRun doesn't exceed total_runs
    MaxRun = ifelse(MaxRun > total_runs, total_runs, MaxRun)
  )

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

pathname <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles/"
filepaths <- list()

for(i in 1:nrow(pars)){
  for(polymer in unique(Material_Parameters$Polymer)){
    # Read in the file
    file <- readLines("vignettes/CaseStudies/MOMENTUM2/SB_run_no_correlation.R")
    
    # Change the polymer to the current polymer
    target_string_polymer <- "polymer <- "
    replacement_string_polymer <- paste0("polymer <- ", '"', polymer, '"')
    
    line_index <- grep(paste0("^", target_string_polymer), file)
    
    if (length(line_index) > 0) {
      file[line_index] <- replacement_string_polymer
    } else {
      message("String not found in file.")
    }
    
    # Change minrun and maxrun to current runs
    minrun <- pars[i,]$MinRun
    maxrun <- pars[i,]$MaxRun
    
    target_string_minrun <- "minrun <- "
    replacement_string_minrun <- paste0("minrun <- ", minrun)
    
    line_index <- grep(paste0("^", target_string_minrun), file)
    
    if (length(line_index) > 0) {
      file[line_index] <- replacement_string_minrun
    } else {
      message("String not found in file.")
    }
    
    target_string_maxrun <- "maxrun <- "
    replacement_string_maxrun <- paste0("maxrun <- ", maxrun)
    
    line_index <- grep(paste0("^", target_string_maxrun), file)
    
    if (length(line_index) > 0) {
      file[line_index] <- replacement_string_maxrun
    } else {
      message("String not found in file.")
    }
    
    filename <- paste0("SB_run_", polymer, "_", as.character(minrun), "_", as.character(maxrun), ".R")
    
    filepath <- paste0(pathname, filename)
    filepaths <- c(filepaths, filepath)
    
    writeLines(file, filepath)
  }
}

# Now write HPC commands into a txt file
mb <- 300*batch_max
time <- 10*batch_max

# Make a string with the needed information for the cluster
LSF_string <- paste0("bsub -n 1 -e err.txt -o out.txt -W ", time, " -M ", mb, " Rscript")

# Paste the information to very string
LSF_vector <- paste(LSF_string, filepaths)

# Write to txt file to make copying easy
writeLines(LSF_vector, "vignettes/CaseStudies/MOMENTUM2/HPC_commands.txt")

