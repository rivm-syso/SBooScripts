library(tidyverse)
data_folder <-  "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/"

########################## Load and prepare the data ###########################
MFAtype <- "DPMFA"

load(file = paste0(data_folder, MFAtype, "_EU", ".RData"))

sinks_EU <- unique(DPMFA_sink$To_Compartment)

year <- 2019

data_long_EU <- 
  DPMFA_inflow |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt") |>
  select(-c(Scale, iD_source)) 

load(file = paste0(data_folder, MFAtype, "_NL", ".RData"))

sinks_NL <- unique(DPMFA_sink$To_Compartment)

data_long_NL <-
  DPMFA_inflow |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |>
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt") |>
  select(-c(Scale, iD_source)) 

sinks <- unique(c(sinks_EU, sinks_NL))

data_long <- data_long_EU |>
  full_join(data_long_NL, by = c("Type", "Source", "Polymer", "To_Compartment", "Material_Type", "RUN", "Year")) |>
  mutate(Mass_Polymer_kt = replace_na(Mass_Polymer_kt.x, 0) + replace_na(Mass_Polymer_kt.y, 0)) |> # Account for cases where Mass_Polymer_kt is NA
  select(-c(Mass_Polymer_kt.x, Mass_Polymer_kt.y)) |>
  mutate(Scale = "EU") |>
  filter(To_Compartment %in% sinks & Type == "Inflow") 

############################ Make datasets to save #############################
TW_emissions_over_time <- data_long |>
  filter(Source == "Tyre wear")

data_long <- data_long |>
  filter(Year == year)

data_long_NL <- data_long_NL |>
  filter(To_Compartment %in% sinks & Type == "Inflow") |>
  filter(Year == year)

data_long_EU <-data_long_EU |>
  filter(To_Compartment %in% sinks & Type == "Inflow") |>
  filter(Year == year)

################################ Save datasets #################################
save(data_long, 
     file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/DPMFA_NL_EU_long.RData",
     compress = "xz",
     compression_level = 9) 
save(data_long_EU,
     file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/DPMFA_NL_long.RData",
     compress = "xz",
     compression_level = 9) 
save(data_long_NL,
     file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/DPMFA_EU_long.RData",
     compress = "xz",
     compression_level = 9) 
save(TW_emissions_over_time,
     file = "/data/BioGrid/hidsa/SimpleBox/SBooScripts/vignettes/CaseStudies/CaseData/DPMFA_emission_NL_EU_TW_time.RData",
     compress = "xz",
     compression_level = 9) 
