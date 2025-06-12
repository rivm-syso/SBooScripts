# Script to load the output in parallel

### initialize ###
library(tidyverse)

# Specify the environment
env <- "OOD"

# Find file paths 
if(env == "OOD"){
  folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/HPC_output_v4/"
  files <- list.files(folderpath)
  filepaths <- paste0(folderpath, files)
} else if(env == "HPC"){
  folderpath <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T_output_v3/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
}

if(env == "OOD"){
  source("vignettes/CaseStudies/LEON-T/f_Read_SB_data_v2.R")
} else if(env == "HPC"){
  source("/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/LEON-T/f_Read_SB_data.R")
}

# Load the data for each file path and transform the data to the correct
# Could be made into a function

Combined_results <- NA

start_time <- Sys.time() # to see how long it all takes...
for(BatchFile in filepaths){
  results <- load_batch_result(BatchFile)
  if(BatchFile == filepaths[1]){
    Combined_results <- results
  } else {
    Combined_results <- rbind(Combined_results,results)
  }
  print(BatchFile)
}

elapsed_time <- Sys.time() - start_time
print(elapsed_time)

# Get States df from the first file (states are the same for every file)
load(filepaths[1])
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
Mass_summed_over_species <- Solution_long |>
  group_by(time, RUN, Polymer, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass))

Mass_2019 <- Mass_summed_over_species |>
  filter(Year == 2019)

Mass_2019_regional <- Mass_2019 |>
  filter(Scale == "Regional")

Mass_2019_continental <- Mass_2019 |>
  filter(Scale == "Continental")

Mass_all_regional <- Mass_summed_over_species |>
  filter(Scale == "Regional")

Mass_all_continental <- Mass_summed_over_species |>
  filter(Scale == "Continental")

# Calculate concentrations

source("baseScripts/initWorld_onlyPlastics.R")
Matrix <- World$fetchData("Matrix")

# Calculate concentrations for masses summed over polymers
Concentration_summed_over_species <- Mass_summed_over_species |>
  left_join(World$fetchData("Volume"), 
            by=c("Scale", "SubCompart")) |>
  # Change 'cloudwater' to 'air', and then sum the masses and volumes of these compartments together
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |> 
  group_by(RUN, Polymer, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass),
            Volume = sum(Volume)) |>
  ungroup() |>
  # Calculate the concentrations
  mutate(conc_kg_m3 = Mass/Volume) |> 
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |> 
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|> 
  mutate(Unit = "kg/m3") |> 
  mutate(Concentration =
           case_match(Matrix,
                      "air" ~ conc_kg_m3*1000000,
                      "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000, # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000,
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit)) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

Concentration_2019 <- Concentration_summed_over_species |>
  filter(Year == 2019)

Concentration_2019_regional <- Concentration_2019 |>
  filter(Scale == "Regional")

Concentration_2019_continental <- Concentration_2019 |>
  filter(Scale == "Continental")

Concentration_all_regional <- Concentration_summed_over_species |>
  filter(Scale == "Regional")

Concentration_all_continental <- Concentration_summed_over_species |>
  filter(Scale == "Continental")

if(env == "OOD"){
  path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Output/"
} else if(env == "HPC"){
  path <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/MOMENTUM2/Output/"
}

# Save the outcome 
save(Mass_summed_over_species,
     file = paste0(path, "LEON-T_Mass_summed_over_species.RData"),
     compress = "xz",
     compression_level = 9)
save(Mass_2019,
     file = paste0(path, "LEON-T_Mass_2019.RData"),
     compress = "xz",
     compression_level = 9)
save(Mass_2019_regional,
     file = paste0(path, "LEON-T_Mass_2019_regional.RData"),
     compress = "xz",
     compression_level = 9)
save(Mass_2019_continental,
     file = paste0(path, "LEON-T_Mass_2019_continental.RData"),
     compress = "xz",
     compression_level = 9)
save(Mass_all_regional,
     file = paste0(path, "LEON-T_Mass_all_regional.RData"),
     compress = "xz",
     compression_level = 9)
save(Mass_all_continental,
     file = paste0(path, "LEON-T_Mass_all_continental.RData"),
     compress = "xz",
     compression_level = 9)

save(Concentration_summed_over_species,
     file = paste0(path, "LEON-T_Concentration_summed_over_species.RData"),
     compress = "xz",
     compression_level = 9)
save(Concentration_2019,
     file = paste0(path, "LEON-T_Concentration_2019.RData"),
     compress = "xz",
     compression_level = 9)
save(Concentration_2019_regional,
     file = paste0(path, "LEON-T_Concentration_2019_regional.RData"),
     compress = "xz",
     compression_level = 9)
save(Concentration_2019_continental,
     file = paste0(path, "LEON-T_Concentration_2019_continental.RData"),
     compress = "xz",
     compression_level = 9)
save(Concentration_all_regional,
     file = paste0(path, "LEON-T_Concentration_all_regional.RData"),
     compress = "xz",
     compression_level = 9)
save(Concentration_all_continental,
     file = paste0(path, "LEON-T_Concentration_all_continental.RData"),
     compress = "xz",
     compression_level = 9)
