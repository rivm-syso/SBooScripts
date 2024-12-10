# Script to load the output in parallel

### initialize ###
library(tidyverse)

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

if(env == "OOD"){
  source("vignettes/CaseStudies/f_Read_SB_data_v2.R")
} else if(env == "HPC"){
  source("/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T/f_Read_SB_data.R")
}

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

# Get States df from the first file (states are the same for every file)
load(filepaths2[1])
States <- Output$SBoutput[[1]]$States

#### Long format solution

Solution_long <- Combined_results |>
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

#### Make plot dataframes

Solution_species <- Solution_long |>
  group_by(time, RUN, Source, Abbr, Scale, SubCompart, Species, Year) |>
  summarise(Mass = sum(Mass)) 

Solution_long_summed_over_pol <- Solution_species |>
  group_by(time, RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass))

# Make plots data for continental scale and polymers over time (concentration)
continental_polymer_data <- Solution_long |>
  filter(Scale == "Continental") |>
  group_by(Polymer, Year, Source, SubCompart, Scale, RUN) |>
  summarise(Mass = sum(Mass)) |> # sum over species
  ungroup()

# Species barplot data for tyre wear
conc_Tyre_wear <- Concentrations_species |>
  filter(Source == "Tyre wear") |>
  filter(Year == year) |>
  group_by(SubCompartName, Scale, Species) |>
  summarise(Mean = mean(Concentration)) |>
  filter(Mean != 0) |>
  filter(Scale == "Continental")

# Prepare SimpleBox data for plotting
SB_data_TW <- Solution_long |>
  filter(Source == "Tyre wear") |>
  filter(Scale == "Regional") |>
  filter(Year == year) |>
  group_by(SubCompart, RUN, Scale, Year, Source) |>
  summarise(Mass = sum(Mass)) |>
  mutate(Polymer = "SBR + NR") |>
  mutate(source = "SimpleBox") 

# Mass and concentrations of SBR vs NR
NR_SBR_data <- Solution_long |>
  filter(Source == "Tyre wear") |>
  filter(Year == year) |>
  group_by(SubCompart, Polymer, Scale, Year, RUN) |>
  summarise(Mass = sum(Mass))

# Save the outcome 
if(env == "OOD"){
  save(Solution_species, Solution_long_summed_over_pol, continental_polymer_data,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SB_Masses_Other.RData",
       compress = "xz",
       compression_level = 9) 
  save(conc_Tyre_wear, NR_SBR_data, SB_data_TW,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SB_Tyre_wear_data_Other.RData",
       compress = "xz",
       compression_level = 9)
  save(Combined_results,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/20241202_SB_Masses_v3.RData",
       compress = "xz",
       compression_level = 9) 
} else if(env == "HPC"){
  save(Solution_species, Solution_long_summed_over_pol, continental_polymer_data,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Masses.RData",
       compress = "xz",
       compression_level = 9) 
  save(conc_Tyre_wear, NR_SBR_data, SB_data_TW,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Tyre_wear_data.RData",
       compress = "xz",
       compression_level = 9) 
  save(Solution_species, Solution_long_summed_over_pol, continental_polymer_data,
       file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/SB_Masses.RData",
       compress = "xz",
       compression_level = 9) 
}
