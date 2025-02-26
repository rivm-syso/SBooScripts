######################## Test deterministic steady state plot #######################
source('baseScripts/initWorld_onlyPlastics.R')
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10)) 

# Initialize the dynamic solver
World$NewSolver("SteadyODE")
World$Solve(emissions = emissions)

World$PlotSolution()
World$PlotSolution(scale = "Regional", subcompart = c("river", "lake", "sea"))
World$PlotConcentration(scale = "Continental")

######################## Test deterministic dynamic plot #######################
source('baseScripts/initWorld_onlyPlastics.R')
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS","aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10, 20, 20, 20), Timed = c(1, 2, 3, 4, 5, 6)) 

# convert 1 t/y to si units: kg/s
emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> ungroup()

tmax <- 365.25*24*60*60*10 # 10 years in seconds
nTIMES <- 10 # Solve 10 times

# Initialize the dynamic solver
World$NewSolver("ApproxODE")
World$Solve(emissions = emissions, tmax = tmax, nTIMES = nTIMES)

World$PlotSolution()
World$PlotConcentration()

####################### Test probabilistic dynamic plot ########################
source('baseScripts/initWorld_onlyPlastics.R')

load("vignettes/example_uncertain_data.RData")
example_data <- example_data |>
  select(To_Compartment, `2020`, `2021`,`2022`, `2023`, RUN) |>
  pivot_longer(!c(To_Compartment, RUN), names_to = "year", values_to = "Emis") |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  select(-To_Compartment) |>
  mutate(Timed = ((as.numeric(year)-2019)*365.25*24*3600)) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-year)

# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("vignettes/Example_uncertain_variables.xlsx", sheet = "Variable_data")

# Define functions for each row based on the distribution type
varFuns <- apply(Example_vars, 1, function(aRow) {
  dist_type <- aRow["Distribution"]
  
  if (dist_type == "triangular") {
    prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c")]))
    names(prepArgs) <- c("a", "b", "c")
  } else if (dist_type == "normal") {
    prepArgs <- as.list(as.numeric(aRow[c("a", "b")]))
    names(prepArgs) <- c("a", "b")
  } else if (dist_type == "uniform") {
    prepArgs <- as.list(as.numeric(aRow[c("a", "b")]))
    names(prepArgs) <- c("a", "b")
  } else {
    stop("Unsupported distribution type")
  }
  
  # Create the inverse CDF function using the prepared arguments
  Make_inv_unif01(fun_type = dist_type, pars = prepArgs)
})

tmax <- 365.25*24*60*60*10 # 10 years in seconds
nTIMES <- 10 # Solve 10 times

# Initialize the dynamic solver
World$NewSolver("ApproxODE")
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)), tmax = tmax, nTIMES = nTIMES)

World$PlotSolution()
World$PlotConcentration()

####################### Test probabilistic steady plot #########################
load("vignettes/example_uncertain_data.RData")

example_data <- example_data |>
  select(To_Compartment, `2023`, RUN) |>
  rename("Emis" = `2023`) |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-To_Compartment) 

# Call the steady state solver
World$NewSolver("SteadyODE")

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)))

World$PlotSolution()
World$PlotConcentration()
