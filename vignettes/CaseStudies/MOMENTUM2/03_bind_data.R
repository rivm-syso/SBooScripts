################################################################################
# Script to bind concentration data for Momentum2 
# Task 6.2.2
# 20-5-2025
# Anne Hids and Joris Quik
################################################################################

library(stringr)
library(tidyverse)

data_folder <- "vignettes/CaseStudies/MOMENTUM2/Output"

# Find the filenames of the concentration files
files <- list.files(data_folder)
concentration_files <- files[startsWith(files, "Concentrations")]

all_concentrations <- data.frame()
concentrations_2019 <- data.frame()

source("baseScripts/initWorld_onlyPlastics.R")

states <- World$states$asDataFrame

for(file in concentration_files){
  load(paste0(data_folder, "/", file))
  
  polymer <- gsub("Concentrations_", "", file)
  
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
