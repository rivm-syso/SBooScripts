#### Test the steady state parallel script

# Initialize the World you want to use for your calculations
source('baseScripts/initWorld_onlyPlastics.R')

# Define the needed variables for the solver: var_box_df, var_invFun and emissisions
var_box_df <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

var_invFun <- World$makeInvFuns(var_box_df)

load("data/Examples/example_uncertain_data.RData")

emissions <- example_data |>
  select(To_Compartment, `2023`, RUN) |>
  rename("Emis" = `2023`) |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> 
  select(-To_Compartment)

# Specify how many cores you have available. If you are calculating on your own computer, use a maximum of all available cores - 1 
nCores <- 3

# Source the script for solving steady state in parallel
source("baseScripts/ParallelSteadyState.R")

# Save the outcome
saveRDS(Solution, "data/Solution.RDS")

#### Test the dynamic parallel script

# Initialize the World you want to use for your calculations
source('baseScripts/initWorld_onlyPlastics.R')

# Define the needed variables for the solver: var_box_df, var_invFun, emissisions, tmax and nTIMES
var_box_df <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

var_invFun <- World$makeInvFuns(var_box_df)

load("data/Examples/example_uncertain_data.RData")

emissions <- example_data |>
  select(To_Compartment, `2020`, `2021`,`2022`, `2023`, RUN) |>
  pivot_longer(!c(To_Compartment, RUN), names_to = "year", values_to = "Emis") |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  select(-To_Compartment) |>
  mutate(Time = ((as.numeric(year)-2019)*365.25*24*3600)) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-year)

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 10))

# Specify how many cores you have available. If you are calculating on your own computer, use a maximum of all available cores - 1 
nCores <- 3

source("baseScripts/ParallelDynamic.R")

# Save the outcome
saveRDS(Solution, "data/Solution.RDS")

