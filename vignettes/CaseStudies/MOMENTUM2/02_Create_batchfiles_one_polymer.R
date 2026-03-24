################################################################################
# Script to create batch files for running SimpleBox for Momentum2 
# Task 6.2.2
# 19-5-2025
# Anne Hids and Joris Quik
################################################################################

library(tidyverse)

input_data_folder <- "/data/BioGrid/hidsa/MOMENTUM2_input/"
data_folder <- "vignettes/CaseStudies/CaseData/MOMENTUM2/Data"

path_parameters_file <- paste0(input_data_folder, "Microplastic_variables_MOMENTUM2_one_polymer.xlsx")
  
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
  select(!starts_with(".")) |>
  mutate(Polymer = "General")

Correlations <- readxl::read_xlsx(path_parameters_file, sheet = "Correlation")
correlations <- Correlations |>
  mutate(correlation = as.numeric(str_replace(correlation, ",", "."))) |>
  mutate(Polymer = "General")

correlation_list <- list()

for(i in unique(correlations$Polymer)){
  correlation <- correlations |>
    filter(Polymer == i) |>
    select(-Polymer)
  
  correlation_list[[i]] <- correlation
}

##### Create the batch files for running SimpleBox
files <- list.files(data_folder)
dpmfa_data_fp <- grep("DPMFA", files)
dpmfa_data_fp <- files[[dpmfa_data_fp]]

load(paste0(data_folder, "/", dpmfa_data_fp))

emis_list <- list()

DPMFA_sink_micro <- DPMFA_sink_micro |>
  group_by(Abbr, Time, RUN) |>
  summarise(Emis = sum(Emis)) |>
  mutate(Polymer = "General")

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
  
  Correlations <- correlation_list[[i]]
  
  # Prepare the LHS samples
  source("baseScripts/initWorld_onlyPlastics.R")
  
  variable_distributions <- World$makeInvFuns(variable_df)
  
  World$NewSolver("DynamicSolver")
  World$Solve(emissions = NULL, 
              var_box_df = variable_df, 
              var_invFun = variable_distributions, 
              nRUNs = length(unique(emis_list[[i]]$RUN)), 
              correlations = Correlations, 
              ParallelPreparation = T)
  
  LHSsamples <- readRDS("data/scaledLHSsamples.RDS")
  lhs_list[[i]] <- LHSsamples
}

# # Check the power law
# variable_matrix <- lhs_list[["General"]]
# 
# variable_df <- as.data.frame(variable_matrix) |>
#   mutate(variable = rownames(variable_matrix)) |>  # Ensure rownames are assigned correctly
#   pivot_longer(
#     cols = -variable,               # Exclude the `variable` column from pivoting
#     names_to = "RUN",               # Column names of the matrix go into "RUN"
#     values_to = "value"             # Corresponding values go into "value"
#   ) |>
#   mutate(RUN = as.numeric(str_remove(RUN, "V"))) |>
#   mutate(Polymer = "General") |>
#   mutate(VarName = str_split_i(variable, " ", 1),
#          Scale = str_split_i(variable, " ", 2),
#          SubCompart = str_split_i(variable, " ", 3),
#          Species = str_split_i(variable, " ", 4)) |>
#   select(-variable)
# 
# all_variables <- variable_df

# rads <- all_variables |>
#   filter(VarName == "RadS")
# 
# plot(density(rads$value), 
#      main = "Density Plot of RadS Values", 
#      xlab = "Value", 
#      ylab = "Density")

# Save the variables and the emissions to the Data folder
save(lhs_list, file = paste0(data_folder, "/lhs_list_general.RData"))
save(emis_list, file = paste0(data_folder, "/emis_list_general.RData"))
save(variable_list, file = paste0(data_folder, "/Variable_list_general.RData"))
save(correlation_list, file = paste0(data_folder, "/correlation_list_general.RData"))

#### Create the batch files

# Define the folder path
folder_path <- "vignettes/CaseStudies/CaseData/MOMENTUM2/BatchFiles"

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

pathname <- "vignettes/CaseStudies/CaseData/MOMENTUM2/BatchFiles/"
filepaths <- list()

for(i in 1:nrow(pars)){
  for(polymer in unique(Material_Parameters$Polymer)){
    # Read in the file
    file <- readLines("vignettes/CaseStudies/MOMENTUM2/SB_run_one_polymer.R")
    
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
writeLines(LSF_vector, "vignettes/CaseStudies/CaseData/MOMENTUM2/HPC_commands_one_polymer.txt")

