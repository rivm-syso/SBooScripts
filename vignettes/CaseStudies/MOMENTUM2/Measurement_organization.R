library(openxlsx)
library(tidyverse)

#### SB4N validation data
SB4P_raw <- read.xlsx("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Measurements/Concentrations_SB4N_validation.xlsx", sheet = "Plastics")

# Select needed data and clean up the dataframe
SB4P <- SB4P_raw |>
  filter(country == "Netherlands") |>
  mutate(type = tolower(type)) |>
  filter(type2 == "Surf") |>
  mutate(min_diameter_um = map_chr(str_split(size.um, " - "), 1)) |>
  mutate(max_diameter_um = map_chr(str_split(size.um, " - "), 2)) |>
  filter(unit == "#/m3") |>
  mutate(source = paste0(ref, " (", pub.year, ")")) |>
  rename(subcompartment = type) |>
  rename(value = mean) |>
  select(subcompartment, min_diameter_um, max_diameter_um, value, unit)

#### KWR data
KWR_data_concentrations <- read.xlsx("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Measurements/KWR/Data KWR/readme.xlsx", sheet = "Meta")

KWR_path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Measurements/KWR/Data KWR/"
KWR_data_dfs <- data.frame()

for(i in 1:nrow(KWR_data_concentrations)){
  # Load the file
  filename <- KWR_data_concentrations$Filename[i]
  filepath <- paste0(KWR_path, filename, ".xlsx")
  file_df <- read.xlsx(filepath)
  
  MP_m3 <- KWR_data_concentrations$MP.per.m3[i]
  
  file_df <- file_df |>
    mutate(MP_m3 = MP_m3) |>
    mutate(location = filename)
  
  if(nrow(KWR_data_dfs) == 0){
    KWR_data_dfs <- file_df
  } else {
    KWR_data_dfs <- bind_rows(KWR_data_dfs, file_df)
  }
}

KWR_location_concentrations_data <- KWR_data_dfs |>
  group_by(location) |>
  summarise(min_diameter_um = min(`Diameter.(µm)`),
            max_diameter_um = max(`Diameter.(µm)`),
            value = mean(MP_m3)) |>
  mutate(subcompart = "river") |>
  mutate(unit = "#/m3")

#### KWR effluent data
KWR_effluent_concentrations <- read.xlsx("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Measurements/KWR/Effluent/readme.xlsx", sheet = "Data")

KWR_path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Measurements/KWR/Effluent/"
KWR_effluent_dfs <- data.frame()

for(i in 1:nrow(KWR_effluent_concentrations)){
  # Load the file
  filename <- KWR_effluent_concentrations$File[i]
  filepath <- paste0(KWR_path, filename)
  file_df <- read.xlsx(filepath)
  
  MP_m3 <- KWR_effluent_concentrations$`MP./m3`[i]
  
  file_df <- file_df |>
    mutate(MP_m3 = MP_m3) |>
    mutate(location = filename)
  
  if(nrow(KWR_effluent_dfs) == 0){
    KWR_effluent_dfs <- file_df
  } else {
    KWR_effluent_dfs <- bind_rows(KWR_effluent_dfs, file_df)
  }
}

KWR_location_concentrations_effluent <- KWR_effluent_dfs |>
  group_by(location) |>
  summarise(min_diameter_um = min(Diameter),
            max_diameter_um = max(Diameter),
            value = mean(MP_m3)) |>
  mutate(subcompart = "river") |>
  mutate(unit = "#/m3") |>
  filter(str_detect(location, "front|upstream"))




