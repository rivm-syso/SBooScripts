## Define paths 
data_path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/PlotData/"  # Define path to plot data
figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/Figures/" # Define figure folder path
abs_path_Measurements <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_TNO_measurements_clean.xlsx" # Define path to LEON-T measurement data

## Load functions
source("vignettes/CaseStudies/LEON-T/f_plot_functions.R")

## Load data
load(paste0(data_path, "LEON-T_SB_Masses.RData"))
load(paste0(data_path, "LEON-T_SB_Tyre_wear_data.RData"))
load(paste0(data_path, "LEON-T_SB_Material_parameters.RData"))

##### 
##Calculate number of complete runs
yearcount <- continental_polymer_data |>
  group_by(Source, RUN, Polymer) |>
  summarise(Year_count = n_distinct(Year), .groups = "drop") |>
  group_by(Source, RUN) |>
  summarise(Year_count = sum(Year_count)) |>
  mutate(npol = case_when(Source == "Tyre wear" ~ 2,
                          Source == "Other sources" ~ 15)) |>
  mutate(nyear = as.integer(Year_count/npol)) |>
  filter(nyear == 101) |>
  select(Source, RUN, nyear)

## Number of complete runs per Source
nruns <- yearcount |>
  group_by(Source) |>
  count()

## Number of complete runs for Tyre wear
TWruns <- nruns |>
  filter(Source == "Tyre wear") 
TWruns <- TWruns$n

## Number of complete runs for Other sources
Otherruns <- nruns |>
  filter(Source == "Other sources") 
Otherruns <- Otherruns$n

##### 
## Calculate concentrations from masses
source("baseScripts/initWorld_onlyPlastics.R")
Matrix <- World$fetchData("Matrix")

# Calculate concentrations for continental polymer data
mass_conc_continental_polymer <- continental_polymer_data |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(RUN, Source, Year, Scale, SubCompart, Polymer) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
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
  mutate(Concentration = conc_kg_m3) |>
  mutate(Concentration =
           case_match(Matrix,
                      #                     "air" ~ conc_kg_m3*1000000,
                      #                     "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix), # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix),
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      #                     "air" ~ "mg/m3",
                      #                     "water" ~ "mg/L",
                      "soil" ~ "kg/kg dw",
                      "sediment" ~ "kg/kg dw",
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

# Calculate concentrations for regional polymer data
mass_conc_regional_polymer <- regional_polymer_data |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(RUN, Source, Year, Scale, SubCompart, Polymer) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
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
  mutate(Concentration = conc_kg_m3) |>
  mutate(Concentration =
           case_match(Matrix,
                      #                     "air" ~ conc_kg_m3*1000000,
                      #                     "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix), # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix),
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      #                     "air" ~ "mg/m3",
                      #                     "water" ~ "mg/L",
                      "soil" ~ "kg/kg dw",
                      "sediment" ~ "kg/kg dw",
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

# Calculate concentrations for SB_data_TW
mass_conc_SB_data_TW <- SB_data_TW |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
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
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

# ##### 
# ## Select only the complete runs for all concentration dataframes 
mass_conc_continental_polymer <- mass_conc_continental_polymer |>
  inner_join(yearcount, by = c("RUN", "Source"))

mass_conc_regional_polymer <- mass_conc_regional_polymer |>
  inner_join(yearcount, by = c("RUN", "Source"))

mass_conc_SB_data_TW <- mass_conc_SB_data_TW |>
  inner_join(yearcount, by = c("RUN", "Source"))

save(mass_conc_continental_polymer, mass_conc_regional_polymer, mass_conc_SB_data_TW,
     file = paste0(data_path,"LEON-T_concentrations.RData"),
     compress = "xz",
     compression_level = 9) 


