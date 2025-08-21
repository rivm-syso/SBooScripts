################################################################################
# This script tests the speed of the parallel vs sequential calculations
# for steady state and dynamic calculations.
# Anne Hids, 26-05-2025
################################################################################

source("baseScripts/installRequirements.R")
source('baseScripts/initWorld_onlyPlastics.R')

# Load emissions
#load("data/Examples/example_uncertain_data.R Data")
load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/MOMENTUM2/InputData/DPMFA_sink_NL.RData")

emissions_all <- DPMFA_sink |> 
  unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
  filter(RUN %in% 1:500) |>
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt") |>
  filter(Year %in% 2019:2024) |>
  rename(Cum_Mass_Polymer_kt = Mass_Polymer_kt) |> 
  ungroup() |> 
  group_by(Scale,Source,Polymer,To_Compartment, Material_Type, RUN) |> 
  reframe(Mass_Polymer_kt = Cum_Mass_Polymer_kt - lag(Cum_Mass_Polymer_kt, default = 0), # calculate yearly emission from cumulative
          Year = Year) |> 
  ungroup() |> 
  mutate(Emis = Mass_Polymer_kt*1000000/(365.25*24*3600)) |> # Convert kt/year to kg/s
  filter(Material_Type == "micro") |> # Select microplastics only
  mutate(SBscale = ifelse(Scale == "EU", "C", "R")) |>
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
  select(Abbr, Time, Polymer, Emis, RUN) |>
  filter(Polymer == "HDPE") |>
  select(-Polymer) 

# Create an empty dataframe to store elapsed times
Elapsed_times <- data.frame

# Load the variables
var_box_df <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")
var_invFun <- World$makeInvFuns(var_box_df)

#####Test steady state##########################################################

#####Parallel

seconds_2023 <- 2023*365.25*24*3600

# Select data for one year 
emissions <- emissions_all |>
  filter(Time == seconds_2023) |>
  select(-Time)

starttime <- Sys.time()

# Call the steady state solver
World$NewSolver("SteadyStateSolver")
World$Solve(emissions = NULL, var_box_df = var_box_df, var_invFun = var_invFun, nRUNs = length(unique(emissions$RUN)), ParallelPreparation = T)

nCores <- 3
max_runs_per_batch <- 10

source("baseScripts/ParallelSteadyState.R")

# Save the outcome
saveRDS(Solution, "data/Solution.RData")

endtime <- Sys.time()

elapsed_time <- as.numeric(endtime-starttime)

time_df <- data.frame(Runs = length(unique(emissions$RUN)),
                      Cores = nCores,
                      Time_min = elapsed_time,
                      Type = "Steady state")

Elapsed_times <- time_df

#####Sequential
starttime <- Sys.time()

# Call the steady state solver
World$NewSolver("SteadyStateSolver")
World$Solve(emissions = emissions, var_box_df = var_box_df, var_invFun = var_invFun, nRUNs = length(unique(emissions$RUN)))

Masses <- World$Masses()
Concentrations <- World$Concentration()
Variables <- World$VariableValues()
Emissions <- World$Emissions()

Solution = list(Masses,
                Concentrations,
                Variables,
                Emissions)

saveRDS(Solution, "data/Solution.RData")

endtime <- Sys.time()

elapsed_time <- as.numeric(endtime-starttime)

time_df <- data.frame(Runs = length(unique(emissions$RUN)),
                      Cores = 1,
                      Time_min = elapsed_time,
                      Type = "Steady state")

Elapsed_times <- rbind(Elapsed_times, time_df)

####Test dynamic################################################################
##### Parallel
emissions <- emissions_all

tmax <- 365.25*24*60*60*length(unique(emissions$Time))
nTIMES <- length(seq(0, tmax, length.out = 10))

nCores <- 3
max_runs_per_batch <- 10

starttime <- Sys.time()

World$NewSolver("DynamicSolver")
World$Solve(emissions = NULL, var_box_df = var_box_df, var_invFun = var_invFun, nRUNs = length(unique(emissions$RUN)), ParallelPreparation = T)

source("baseScripts/ParallelDynamic.R")
saveRDS(Solution, "data/Solution.RData")

endtime <- Sys.time()

elapsed_time <- as.numeric(endtime-starttime)

time_df <- data.frame(Runs = length(unique(emissions$RUN)),
                      Cores = nCores,
                      Time_min = elapsed_time,
                      Type = "Dynamic")

Elapsed_times <- rbind(Elapsed_times, time_df)
  
##### Sequential
starttime <- Sys.time()

World$NewSolver("DynamicSolver")
World$Solve(emissions = emissions, var_box_df = var_box_df, var_invFun = var_invFun, nRUNs = length(unique(emissions$RUN)), tmax=tmax, nTIMES=nTIMES)

endtime <- Sys.time()

elapsed_time <- as.numeric(endtime-starttime)

time_df <- data.frame(Runs = length(unique(emissions$RUN)),
                      Cores = 1,
                      Time_min = elapsed_time,
                      Type = "Dynamic")

Elapsed_times <- rbind(Elapsed_times, time_df)

# Save elapsed times
library(openxlsx)

write.xlsx(Elapsed_times, file = "Elapsed_times_parallel_sequential.xlsx")


