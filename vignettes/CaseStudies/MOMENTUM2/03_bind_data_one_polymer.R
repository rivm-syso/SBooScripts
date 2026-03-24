################################################################################
# Script to bind concentration data for Momentum2 
# Task 6.2.2
# 20-5-2025
# Anne Hids and Joris Quik
################################################################################

library(stringr)
library(tidyverse)

data_folder <- "vignettes/CaseStudies/MOMENTUM2/Output_general"

source("baseScripts/initWorld_onlyPlastics.R")
states <- World$states$asDataFrame

#### Bind concentration data

all_concentrations <- data.frame()
concentrations_2019 <- data.frame()

files <- list.files(data_folder)
concentration_files <- files[startsWith(files, "Concentrations")]

for(file in concentration_files){
  load(paste0(data_folder, "/", file))
  
  # Extract polymer
  polymer <- gsub("Concentrations_(.*?)_\\d+_\\d+", "\\1", file)
  
  all_conc <- output_concentrations |>
    left_join(states, by = "Abbr", relationship = "many-to-many") |> # join the states to the df
    filter(Scale %in% c("Regional", "Continental")) |> # select only the regional and continental scales
    mutate(Polymer = polymer) |> # add polymer to df
    group_by(RUNs, Unit, year, Scale, SubCompart, Polymer) |> # sum over species
    summarise(Concentration = sum(Concentration))
  
  conc_2019 <- all_conc |>
    filter(year == 2019)
  
  all_concentrations <- rbind(all_concentrations, all_conc)
  concentrations_2019 <- rbind(concentrations_2019, conc_2019)
}

#### Bind emission data
all_emissions <- data.frame()
emissions_2019 <- data.frame()

files <- list.files(data_folder)
emission_files <- files[startsWith(files, "Emissions")]

for(file in emission_files){
  load(paste0(data_folder, "/", file))

  # Extract polymer
  polymer <- gsub("Emissions_(.*?)_\\d+_\\d+", "\\1", file)
  
  all_emis <- output_emissions |>
    left_join(states, by = "Abbr", relationship = "many-to-many") |> # join the states to the df
    filter(Scale %in% c("Regional", "Continental")) |> # select only the regional and continental scales
    mutate(Polymer = polymer) |> # add polymer to df
    group_by(RUNs, year, Scale, SubCompart, Polymer) |> # sum over species
    summarise(Emission_kg_s = sum(Emission_kg_s))
  
  emis_2019 <- all_emis |>
    filter(year == 2019)
  
  all_emissions <- rbind(all_emissions, all_emis)
  emissions_2019 <- rbind(emissions_2019, emis_2019)
}

#### Bind mass data
all_masses <- data.frame()
masses_2019 <- data.frame()

files <- list.files(data_folder)
mass_files <- files[startsWith(files, "Masses")]

for(file in mass_files){
  load(paste0(data_folder, "/", file))
  
  # Extract polymer
  polymer <- gsub("Masses_(.*?)_\\d+_\\d+", "\\1", file)

  all_mass <- output_masses |>
    left_join(states, by = "Abbr", relationship = "many-to-many") |> # join the states to the df
    filter(Scale %in% c("Regional", "Continental")) |> # select only the regional and continental scales
    mutate(Polymer = polymer) |> # add polymer to df
    group_by(RUNs, year, Scale, SubCompart, Polymer) |> # sum over species
    summarise(Mass_kg = sum(Mass_kg))
  
  mass_2019 <- all_mass |>
    filter(year == 2019)
  
  all_masses <- rbind(all_masses, all_mass)
    masses_2019 <- rbind(masses_2019, mass_2019)
}

#### Bind variable data
load("vignettes/CaseStudies/CaseData/MOMENTUM2/Data/lhs_list_general.RData")

all_variables <- data.frame()

for(i in names(lhs_list)){
  variable_matrix <- lhs_list[[i]]
  variable_df <- as.data.frame(variable_matrix) |>
    mutate(variable = rownames(variable_matrix)) |>  # Ensure rownames are assigned correctly
    pivot_longer(
      cols = -variable,               # Exclude the `variable` column from pivoting
      names_to = "RUN",               # Column names of the matrix go into "RUN"
      values_to = "value"             # Corresponding values go into "value"
    ) |>
    mutate(RUN = as.numeric(str_remove(RUN, "V"))) |>
    mutate(Polymer = i) |>
    mutate(VarName = str_split_i(variable, " ", 1),
           Scale = str_split_i(variable, " ", 2),
           SubCompart = str_split_i(variable, " ", 3),
           Species = str_split_i(variable, " ", 4)) |>
    select(-variable)
  
  all_variables <- rbind(all_variables, variable_df)
}

#### Save the outcomes
data_folder <- "vignettes/CaseStudies/CaseData/MOMENTUM2/Bound_data/"

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(data_folder)) {
  dir.create(data_folder, recursive = TRUE)  # `recursive = TRUE` ensures that parent directories are created if needed
  message("Bound_data folder created: ", data_folder)
} else {
  message("Bound_data folder already exists: ", data_folder)
}

save(all_concentrations, file = paste0(data_folder, "All_concentrations_general_", 
                                     format(Sys.Date(),"%Y%m%d"),".RData"))
save(all_masses, file = paste0(data_folder, "All_masses_general_", 
                                       format(Sys.Date(),"%Y%m%d"),".RData"))
save(all_emissions, file = paste0(data_folder, "All_emissions_general_", 
                                       format(Sys.Date(),"%Y%m%d"),".RData"))
save(all_variables, file = paste0(data_folder, "All_variables_general_", 
                                       format(Sys.Date(),"%Y%m%d"),".RData"))

save(concentrations_2019, file = paste0(data_folder, "Concentrations_2019_general_", 
                                       format(Sys.Date(),"%Y%m%d"),".RData"))
save(masses_2019, file = paste0(data_folder, "Masses_2019_general_", 
                               format(Sys.Date(),"%Y%m%d"),".RData"))
save(emissions_2019, file = paste0(data_folder, "Emissions_2019_general_", 
                                  format(Sys.Date(),"%Y%m%d"),".RData"))


