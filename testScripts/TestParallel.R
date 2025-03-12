library(foreach)
library(doParallel)
library(openxlsx)

# Test dynamic parallel calculation with 4 cores, 20 runs, 100 time steps
source('baseScripts/initWorld_onlyPlastics.R')

load("data/Examples/example_uncertain_data.RData")

example_data <- example_data |>
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

# Load the Excel file containing example distributions for variables
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

varFuns <- World$makeInvFuns(Example_vars)

World$NewSolver("DynamicSolver")

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 100))
nCores <- 4
nRUNs <- length(unique(example_data$RUN))

start_time <- Sys.time()

World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns,
            nRUNs = nRUNs, Parallel = T, nCores = nCores, tmax = tmax, nTIMES = nTIMES)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
all_elapsed_times <- data.frame(
  Cores = nCores,
  Calculation_type = "Dynamic",
  Runs = nRUNs, 
  TimeSteps = nTIMES,
  RunTime = elapsed_time)

# Test dynamic parallel calculation with 3 cores, 20 runs, 100 time steps
source('baseScripts/initWorld_onlyPlastics.R')

World$NewSolver("DynamicSolver")

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 100))
nCores <- 3
nRUNs <- length(unique(example_data$RUN))

start_time <- Sys.time()

World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns,
            nRUNs = nRUNs, Parallel = T, nCores = nCores, tmax = tmax, nTIMES = nTIMES)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Dynamic",
  Runs = nRUNs, 
  TimeSteps = nTIMES,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

# Test dynamic parallel calculation with 2 cores, 20 runs, 100 time steps
source('baseScripts/initWorld_onlyPlastics.R')

World$NewSolver("DynamicSolver")

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 100))
nCores <- 2
nRUNs <- length(unique(example_data$RUN))

start_time <- Sys.time()

World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns,
            nRUNs = nRUNs, Parallel = T, nCores = nCores, tmax = tmax, nTIMES = nTIMES)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Dynamic",
  Runs = nRUNs, 
  TimeSteps = nTIMES,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

# Test dynamic parallel calculation with 1 core, 20 runs, 100 time steps
source('baseScripts/initWorld_onlyPlastics.R')

World$NewSolver("DynamicSolver")

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 100))
nCores <- 1
nRUNs <- length(unique(example_data$RUN))

start_time <- Sys.time()

World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns,
            nRUNs = nRUNs, Parallel = F, tmax = tmax, nTIMES = nTIMES)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Dynamic",
  Runs = nRUNs, 
  TimeSteps = nTIMES,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

# Calculate how much faster
all_elapsed_times_2 <- all_elapsed_times |>
  mutate(RunTime_mins = as.double(str_remove(RunTime, " mins"))) |>
  select(-RunTime)

sequential_time <- all_elapsed_times_2 |>
  filter(Cores == 1)
sequential_time <- sequential_time$RunTime_mins

all_elapsed_times_2 <- all_elapsed_times_2 |>
  mutate(runtime_fraction_of_sequential = RunTime_mins/sequential_time)

openxlsx::write.xlsx(all_elapsed_times_2, paste0("ParallelTestRunTimes_", as.character(nRUNs), "_runs_", as.character(nTIMES), "_times.xlsx"))

############################### Test steady state ##############################

# 4 cores

source('baseScripts/initWorld_onlyPlastics.R')

load("data/Examples/example_uncertain_data.RData")

# Example of an emission dataframe formatted for for use in SimpleBox
example_data <- example_data |>
  # Select the emission compartment, year of analysis and RUN for one microplastic and scale.
  select(To_Compartment, `2023`, RUN) |>
  # Change the name of column with emission values to "Emis"
  rename("Emis" = `2023`) |>
  # Add the abreviations with the key for compartment, scale and species
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  # Convert kt/year to kg/s
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> 
  select(-To_Compartment) # leave out original compartment name

# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

varFuns <- World$makeInvFuns(Example_vars)

# Call the steady state solver
World$NewSolver("SteadyStateSolver")

nRUNs = length(unique(example_data$RUN))
nCores = 4

start_time <- Sys.time()

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = nRUNs,
            Parallel = TRUE, nCores = nCores)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Steady state",
  Runs = nRUNs, 
  TimeSteps = NA,
  RunTime = elapsed_time)

all_elapsed_times <- elapsed_time_df

# 3 cores
source('baseScripts/initWorld_onlyPlastics.R')

# Call the steady state solver
World$NewSolver("SteadyStateSolver")

nRUNs = length(unique(example_data$RUN))
nCores = 3

start_time <- Sys.time()

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = nRUNs,
            Parallel = TRUE, nCores = nCores)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Steady state",
  Runs = nRUNs, 
  TimeSteps = NA,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

# 2 cores
source('baseScripts/initWorld_onlyPlastics.R')

# Call the steady state solver
World$NewSolver("SteadyStateSolver")

nRUNs = length(unique(example_data$RUN))
nCores = 2

start_time <- Sys.time()

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = nRUNs,
            Parallel = TRUE, nCores = nCores)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Steady state",
  Runs = nRUNs, 
  TimeSteps = NA,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

# 1 core (sequentially)
source('baseScripts/initWorld_onlyPlastics.R')

# Call the steady state solver
World$NewSolver("SteadyStateSolver")

nRUNs = length(unique(example_data$RUN))
nCores = 1

start_time <- Sys.time()

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = nRUNs)

end_time <- Sys.time()

elapsed_time <- end_time-start_time

# Create df to store elapsed times in
elapsed_time_df <- data.frame(
  Cores = nCores,
  Calculation_type = "Steady state",
  Runs = nRUNs, 
  TimeSteps = NA,
  RunTime = elapsed_time)

all_elapsed_times <- bind_rows(all_elapsed_times, elapsed_time_df)

openxlsx::write.xlsx(all_elapsed_times_2, paste0("ParallelTestRunTimes_", as.character(nRUNs), "_runs.xlsx"))

