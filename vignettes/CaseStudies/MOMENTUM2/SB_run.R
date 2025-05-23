################################################################################
# Standard script for running SB for one polymer for Momentum2 
# Task 6.2.2
# 19-5-2025
# Anne Hids and Joris Quik
################################################################################
starttime <- Sys.time()
data_folder <- "vignettes/CaseStudies/MOMENTUM2/Data/"

path_parameters_file <- paste0(data_folder, "Microplastic_variables_MOMENTUM2.xlsx")
input_folder <- "vignettes/CaseStudies/MOMENTUM2/Data/"
output_folder <- "vignettes/CaseStudies/MOMENTUM2/Output/"

load(paste0(input_folder, "emis_list.RData"))
load(paste0(input_folder, "variable_list.RData"))

polymer <- "Acryl"

source("baseScripts/initWorld_onlyPlastics.R")
if(polymer %in% c("NR", "SBR")){
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

Regional_Parameters <- Regional_Parameters |>
  select(!starts_with("."))

# Recalculate the area's
World$mutateVars(Regional_Parameters)
World$UpdateDirty(unique(Regional_Parameters$varName))

# Get variable values, emissions and variable functions for the polymer
emissions <- emis_list[[polymer]] |>
  filter(RUN %in% 1:2)
variable_df <- variable_list[[polymer]]
variable_distributions <- World$makeInvFuns(variable_df)

nRUNs = length(unique(emissions$RUN))
tmin = min(emissions$Time)
tmax = max(emissions$Time)
nTIMES = length(unique(emissions$Time))

# Solve
World$NewSolver("DynamicSolver")
World$Solve(emissions = emissions, var_box_df = variable_df, var_invFun = variable_distributions, nRUNs = nRUNs, tmin = tmin, tmax = tmax, nTIMES = nTIMES)

output_masses <- World$Masses() |>
  mutate(year = as.numeric(time)/(365.25*24*60*60)) |>
  select(-time)
output_emissions <- World$Emissions() |>
  mutate(year = as.numeric(time)/(365.25*24*60*60)) |>
  select(-time)
output_concentrations <- World$Concentration() |>
  mutate(year = as.numeric(time)/(365.25*24*60*60)) |>
  select(-time)
output_variables <- World$VariableValues() 

save(output_masses, file = paste0(output_folder, "Masses_", polymer))
save(output_emissions, file = paste0(output_folder, "Emissions_", polymer))
save(output_concentrations, file = paste0(output_folder, "Concentrations_", polymer))
save(output_variables, file = paste0(output_folder, "Variables_", polymer))

endtime <- Sys.time()
elapsed_time <- endtime-starttime

print(paste0("Elapses time is ", elapsed_time))