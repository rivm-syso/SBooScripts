################################################################################
# Script to prepare emission data for Momentum2 
# Task 6.2.2
# 27-3-2025
# Anne Hids and Joris Quik
################################################################################

library(tidyverse)

##### Prepare emission data
abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/InputData/DPMFA_sink_NL.RData" # data file location
abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/InputData/DPMFA_sink_EU.RData"

load(abspath_EU)

# Convert to long format
data_long_EU <- 
  DPMFA_sink |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt") |>
  rename(Cum_Mass_Polymer_kt = Mass_Polymer_kt) |> 
  ungroup() |> 
  group_by(Scale,Source,Polymer,To_Compartment, Material_Type, RUN) |> 
  reframe(Mass_Polymer_kt = Cum_Mass_Polymer_kt - lag(Cum_Mass_Polymer_kt, default = 0),
          Year = Year) |> # calculate yearly emission from cummulative
  ungroup() |> 
  mutate(Emis = Mass_Polymer_kt*1000000/(365.25*24*3600)) |> # Convert kt/year to kg/s
  filter(Material_Type == "micro") |> # Select microplastics only
  mutate(SBscale = ifelse(Scale == "EU", "C", "R")) 

# Load NL data
load(abspath_NL)


# Convert to long format
data_long_NL <- 
  DPMFA_sink |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt") |>
  rename(Cum_Mass_Polymer_kt = Mass_Polymer_kt) |> 
  ungroup() |> 
  group_by(Scale,Source,Polymer,To_Compartment, Material_Type, RUN) |> 
  reframe(Mass_Polymer_kt = Cum_Mass_Polymer_kt - lag(Cum_Mass_Polymer_kt, default = 0), # calculate yearly emission from cummulative
          Year = Year) |> 
  ungroup() |> 
  mutate(Emis = Mass_Polymer_kt*1000000/(365.25*24*3600)) |> # Convert kt/year to kg/s
  filter(Material_Type == "micro") |> # Select microplastics only
  mutate(SBscale = ifelse(Scale == "EU", "C", "R")) 

data_long <- rbind(data_long_EU, data_long_NL)

rm("DPMFA_sink")

# Split data between tyre wear and other compartments
TW_long <- data_long |>
  filter(Source == "Tyre wear")
other_long <- data_long |>
  filter(Source != "Tyre wear")

# Divide the TW data between NR and SBR 
TRWP_data <- readxl::read_excel(path_parameters_file, sheet = "TRWP_data") |>
  select(NR_Average_fraction)
TRWP_data <- na.omit(TRWP_data)
a <- min(TRWP_data$NR_Average_fraction)
b <- max(TRWP_data$NR_Average_fraction)
c <- mean(TRWP_data$NR_Average_fraction)

nsamples <- max(TW_long$RUN)
NR_SBR_fractions <- triangle::rtriangle(nsamples, a, b, c)
NR_SBR_fractions <- data.frame(NR_SBR_fractions) |>
  mutate(RUN = 1:nsamples) |>
  rename(NR_fraction = NR_SBR_fractions)

TW_long <- TW_long |>
  left_join(NR_SBR_fractions, by = "RUN")

NR_df <- TW_long |>
  mutate(Polymer = "NR") |>
  mutate(Emis = Emis*NR_fraction) |>
  select(-NR_fraction)

SBR_df <- TW_long |>
  mutate(Polymer = "SBR") |>
  mutate(SBR_fraction = 1-NR_fraction) |>
  mutate(Emis = Emis*SBR_fraction) |>
  select(-c(NR_fraction, SBR_fraction))

TW_long <- rbind(NR_df, SBR_df)

# Bind the Tyre wear and other dfs together again
data_long <- bind_rows(TW_long, other_long)

# Assign SB compartments to DPMFA compartments
DPMFA_sink_micro <- data_long |>
  #filter(Source %in% sources) |>
  select(Source, To_Compartment, Emis, Year, RUN, Polymer, SBscale) |>
  rename(Scale = SBscale) |>
  filter(To_Compartment != "Sub-surface soil (micro)") |> # Exclude sub-surface soil because this is currently outside the scope of SimpleBox
  mutate(Compartment = case_when(
    str_detect(To_Compartment, "soil") ~ "s",
    str_detect(To_Compartment, "water") ~ "w",
    str_detect(To_Compartment, "air") ~ "a"
  )) |>
  mutate(Subcompartment = case_when(
    str_detect(To_Compartment, "Agricultural") ~ "2",
    str_detect(To_Compartment, "Natural") ~ "1",
    str_detect(To_Compartment, "Road side") ~ "3",
    str_detect(To_Compartment, "Residential") ~ "3",
    str_detect(To_Compartment, "Sea") ~ "2",
    str_detect(To_Compartment, "Surface") ~ "1",
    str_detect(To_Compartment, "Outdoor") ~ ""
  )) |>
  mutate(Species = case_when(
    Source == "Tyre wear" ~ "P",
    TRUE ~ "S")) |>
  mutate(Abbr = paste0(Compartment, Subcompartment, Scale, Species)) |>
  mutate(Subcompartment = paste0(Compartment, Subcompartment)) |>
  group_by(Abbr, Year, RUN, Polymer, Subcompartment) |>
  summarise(Emis = sum(Emis)) |>
  ungroup() |> 
  mutate(Time = as.numeric(Year)*365.25*24*3600) |>
  select(Abbr, Time, Polymer, Emis, RUN)

save(DPMFA_sink_micro, file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/InputData/DPMFA_SBinput_", 
                                   format(Sys.Date(),"%Y%m%d"),".RData"))

