################################################################################
# Script to run SimpleBox for Momentum2 
# Task 6.2
# 27-3-2025
# Anne Hids and Joris Quik
################################################################################

library(tidyverse)

##### Prepare emission data
# abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData" # data file location
# abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData"


abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/TEST_DPMFA_NL.RData"
abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/TEST_DPMFA_EU.RData"
path_parameters_file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Microplastic_variables_MOMENTUM2.xlsx"


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

rm("DPMFA_sink", "DPMFA_inflow", "DPMFA_outflow", "DPMFA_stock")

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

save(DPMFA_sink_micro, file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/DPMFA_SBinput_test_", 
                                   format(Sys.Date(),"%Y%m%d"),".RData"))

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
load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/DPMFA_SBinput_test_20250327.RData")

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

i <- "PET"

output_masses = list()
output_concentrations = list()
output_emissions = list()
output_variables = list

for(i in unique(Material_Parameters$Polymer)){
  source("baseScripts/initWorld_onlyPlastics.R")
  if(i %in% c("NR", "SBR")){
    World$substance <- "TRWP"
  } else {
    World$substance <- "microplastic"  
  }
  
  # Alter landscape parameters
  # Read in data to change Regional scale to fit NL scale DPMFA data
  Regional_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Netherlands_data") |>
    rename(varName = Variable) |>
    rename(Waarde = Value) |>
    select(-Unit) 
  
  # Recalculate the area's
  World$mutateVars(Regional_Parameters)
  World$UpdateDirty(unique(Regional_Parameters$varName))
  
  # Get variable values, emissions and variable functions for the polymer
  emissions <- emis_list[[i]]
  variable_df <- variable_list[[i]]
  variable_distributions <- World$makeInvFuns(variable_df)
  
  nRUNs = length(unique(emissions$RUN))
  tmax = max(emissions$Time)
  nTIMES = length(unique(emissions$Time))
  
  #nTIMES = 10
  
  # Solve
  World$NewSolver("DynamicSolver")
  World$Solve(emissions = emissions, var_box_df = variable_df, var_invFun = variable_distributions, nRUNs = nRUNs, tmax = tmax, nTIMES = nTIMES)
  
  output_masses[[i]] <- World$Masses()
  output_emissions[[i]] <- World$Emissions()
  output_concentrations[[i]] <- World$Concentration()
  output_variables[[i]] <- World$VariableValues()
  vars <- World$VariableValues()
}









