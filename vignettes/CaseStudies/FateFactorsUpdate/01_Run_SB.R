library(tidyverse)
library(openxlsx)

# Read csvs
plastic_values <- read_delim(file = "vignettes/CaseStudies/FateFactorsUpdate/Polymer_list.csv")

regions <- read.xlsx("vignettes/CaseStudies/FateFactorsUpdate/SI_3_Fate.xlsx", sheet = "4.1.Regio_param") 

colnames(regions) <- regions[2,]

regions <- regions[3:46,] |>
  filter(!is.na(Variable)) |>
  select(Variable, Scale, SubCompart, `North America`, `Latin America`, Europe, 
         `Africa & Middle East`, `Central Asia`, `Southeast Asia`, `Northern regions`, `Oceania`) |>
  rename(varName = Variable)

# Initalize World
source("baseScripts/initWorld_onlyPlastics.R")

# Change global landscape properties - make scales really small to remove them
global_df <- data.frame(varName = c("TotalArea", "TotalArea", "TotalArea"), 
                          Scale = c("Arctic", "Moderate", "Tropic"),
                          Waarde = c(10^-10, 10^-10, 10^-10))

World$mutateVars(global_df)
World$UpdateDirty(unique(global_df$varName))

# Loop over regions
region_names <- colnames(regions)[4:11]

# Instead of this, make a dataframe per emission compartment - emission scale combination
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10)) 
# emissions <- data.frame(Abbr = c"aCS", Emis = 1)

# Get the names and abbreviations of all compartments
states <- World$states$asDataFrame

results <- data.frame(region = character(),
                      polymer = character(),
                      size = integer(),
                      emissions_compartment = character(),
                      receiving_compartment = character(),
                      FF = numeric())

for(reg in region_names){
  region_df <- regions[, c("varName", "Scale", "SubCompart", reg)] 
  names(region_df)[ncol(region_df)] <- "Waarde"
  
  region_df <- region_df |>
    mutate(Waarde = as.numeric(Waarde))
  
  World$mutateVars(region_df)
  World$UpdateDirty(unique(region_df$varName))
  
  # Polymer loop
  for(i in 1:nrow(plastic_values)){
    pol <- plastic_values$polymer_type[i]
    
    variable_df <- data.frame(varName = "RhoS",
                              Waarde = plastic_values$density_average[i])
    
    World$mutateVars(variable_df)
    World$UpdateDirty(unique(variable_df$varName))
    
    World$NewSolver("SteadyStateSolver")
    World$Solve(emissions = emissions)
    
    Masses <- World$Masses()
    
    Masses_grouped_over_species <- Masses |>
      left_join(states, by = "Abbr") |>
      group_by(Scale, SubCompart) |>
      summarise(Mass_kg = sum(Mass_kg))
    
    
  }
}



















# remove_advection <- data.frame(varName = "x_Advection_Air", 
#                                fromScale = "Continental",
#                                toScale = "Moderate",
#                                fromSubCompart = "air",
#                                toSubCompart = "air",
#                                Waarde = 0)
# 
# World$mutateVars(remove_advection)
# 
# World$fetchData("x_Advection_Air")
# 
# World$UpdateDirty(unique(remove_advection$varName))
# 
# World$fetchData("x_Advection_Air")



