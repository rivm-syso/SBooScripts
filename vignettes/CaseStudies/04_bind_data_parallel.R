# Script to load the output in parallel

### initialize ###
library(stringr)
library(tidyverse)
library(doParallel)

# Specify the environment
env <- "OOD"
#env <- "HPC"

# Find file paths 
if(env == "OOD"){
  folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/HPC_output/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
} else if(env == "HPC"){
  folderpath <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T_output/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
}

if(env == "OOD"){
  source("/rivm/n/hidsa/Documents/GitHub/SimpleBox/SBooScripts/vignettes/CaseStudies/f_Read_SB_data.R")
} else if(env == "HPC"){
  source("/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/f_Read_SB_data.R")
}

# Set up a cluster
if (env == "local"){
  n_cores <- detectCores() - 1 
} else if (env == "OOD") {
  n_cores <- 1
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

# Filter out tibbles with the specified name and bind rows together
TW_concentrations <- bind_rows(results_cleaned[names(results_cleaned) == "TW_concentrations"])
TW_solutions <- bind_rows(results_cleaned[names(results_cleaned) == "TW_solutions"])
TW_emissions <- bind_rows(results[names(results_cleaned) == "TW_emissions"])

Other_concentrations <- bind_rows(results_cleaned[names(results_cleaned) == "Other_concentrations"])
Other_solutions <- bind_rows(results_cleaned[names(results_cleaned) == "Other_solutions"])
Other_emissions <- bind_rows(results_cleaned[names(results_cleaned) == "Other_emissions"])

Material_Parameters_long <- bind_rows(results_cleaned[names(results_cleaned) == "Material_Parameters_long"])

Units <- results_cleaned[["Units"]] |>
  distinct()
States <- results_cleaned[["States"]] |>
  distinct()

# Bind the rows of the concentration and solution dataframes together for both sources 
Concentrations <- bind_rows(TW_concentrations, Other_concentrations)
Solution <- bind_rows(TW_solutions, Other_solutions) 
Emissions <- bind_rows(TW_emissions, Other_emissions)

# Prepare the data for making figures
units <- Units |>
  pivot_longer(cols = everything(), names_to = "Abbr", values_to = "Unit")

year <- 2019

# Concentration datasets
Concentrations_long <- Concentrations |>
  pivot_longer(!c(time, RUN, Polymer, Source), names_to = "Abbr", values_to = "Concentration") |>
  mutate(time = as.numeric(time)) |>
  mutate(RUN = as.integer(RUN)) |>
  mutate(Concentration = as.double(Concentration)) |>
  mutate(Year = time/(365.25*24*3600))  |>
  left_join(units, by="Abbr") |>
  left_join(States, by="Abbr") |>
  mutate(SubCompartName  = paste0(SubCompart, " (", Unit, ")"))

Concentrations_species <- Concentrations_long |>
  group_by(time, RUN, Source, Scale, SubCompart, Species, Year, Unit, SubCompartName) |>
  summarise(Concentration = sum(Concentration)) |>
  ungroup() 

Conc_summed_over_pol <- Concentrations_species |>
  group_by(time, RUN, Source, Year, Scale, SubCompart, SubCompartName, Unit) |>
  summarise(Concentration = sum(Concentration)) 

# Make plots data for continental scale and polymers over time (concentration)
continental_polymer_data <- Concentrations_long |>
  filter(Scale == "Continental") |>
  group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale, Unit) |>
  summarise(Concentration = mean(Concentration))

# Mass datasets
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

Solution_species <- Solution_long |>
  group_by(time, RUN, Source, Abbr, Scale, SubCompart, Species, Year) |>
  summarise(Mass = sum(Mass)) 

Solution_long_summed_over_pol <- Solution_species |>
  group_by(time, RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass))

# Species barplot data for tyre wear
conc_Tyre_wear <- Concentrations_species |>
  filter(Source == "Tyre wear") |>
  filter(Year == year) |>
  group_by(SubCompartName, Scale, Species) |>
  summarise(Mean = mean(Concentration)) |>
  filter(Mean != 0) |>
  filter(Scale == "Continental")

# Prepare SimpleBox data for plotting
SB_data_TW <- Concentrations_long |>
  filter(Source == "Tyre wear") |>
  left_join(Solution_long, by=c("Scale", "Year", "RUN", "SubCompart", "Species", "time", "Polymer", "Source", "Abbr")) |>
  filter(Scale == "Regional") |>
  filter(Year == year) |>
  group_by(SubCompartName, SubCompart, RUN) |>
  summarise(Concentration = sum(Concentration)) |>
  mutate(Polymer = "SBR + NR") |>
  mutate(source = "SimpleBox") 

# Mass and concentrations of SBR vs NR
NR_SBR_data <- Concentrations_long |>
  filter(Source == "Tyre wear") |>
  left_join(Solution_long, by=c("Scale", "Year", "RUN", "SubCompart", "Species", "time", "Polymer", "Source", "Abbr")) |>
  filter(Year == year) |>
  group_by(SubCompartName, SubCompart, Polymer, Scale, Year, RUN) |>
  summarise(Concentration = sum(Concentration),
            Mass = sum(Mass))

# Save the outcome 
if(env == "OOD"){
  save(Concentrations_long, Solution_long, Material_Parameters_long, States, Units,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.3.RData",
       compress = "xz",
       compression_level = 9) 
} else if(env == "HPC"){
  save(Concentrations_species, Conc_summed_over_pol, continental_polymer_data,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Concentrations.RData",
       compress = "xz",
       compression_level = 9) 
  save(Solution_species, Solution_long_summed_over_pol,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Masses.RData",
       compress = "xz",
       compression_level = 9) 
  save(conc_Tyre_wear, NR_SBR_data, SB_data_TW,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Tyre_wear_data.RData",
       compress = "xz",
       compression_level = 9) 
  save(Material_Parameters_long,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Material_parameters.RData",
       compress = "xz",
       compression_level = 9) 
  save(Emissions, 
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Emissions.RData",
       compress = "xz",
       compression_level = 9)
  save(Concentrations_long, Solution_long, Emissions,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Long_solutions.RData",
       compress = "xz",
       compression_level = 9)
}