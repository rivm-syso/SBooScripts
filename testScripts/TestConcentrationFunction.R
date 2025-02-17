source("baseScripts/initWorld_onlyMolec.R")

# Calculate the concentrations with the concentration function
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000))

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60))

World$NewSolver("SteadyODE")
World$Solve(emissions = emissions)

conc_fun <- World$Concentration() |>
  rename(conc_fun = Concentration_kg_m3) |>
  left_join(World$states$asDataFrame, by = "Abbr")

# Calculate the concentrations manually
sol <- World$Solution() |>
  left_join(World$states$asDataFrame, by = "Abbr")

# Calculate concentrations for masses summed over polymers
conc_manual <-
  sol |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
  # Change 'cloudwater' to 'air', and then sum the masses and volumes of these compartments together
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(Scale, SubCompart) |>
  summarise(Mass_kg = sum(Mass_kg),
            Volume = sum(Volume)) |>
  ungroup() |>
  # Calculate the concentrations
  mutate(conc_manual = Mass_kg/Volume) |>

  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |>
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|>
  mutate(Unit = "kg/m3") |>
  mutate(conc_manual =
           case_match(Matrix,
                      "air" ~ conc_manual,
                      "water" ~ conc_manual,
                      "soil" ~ conc_manual  / ((1 - FRACw - FRACa) * rhoMatrix), # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_manual  / ((1 - FRACw - FRACa) * rhoMatrix),
                      .default = conc_manual),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit)) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(FRACw, FRACa, rhoMatrix, Matrix, Volume))

# Compare the concentrations
concentrations_joined <- conc_fun |>
  left_join(conc_manual, by = c("Scale", "SubCompart")) |>
  select(Scale, SubCompart, conc_fun, conc_manual) |>
  mutate(conc_diff = abs(conc_fun-conc_manual))

#### Test with dynamic probabilistic solution

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
solution <- World$Solution()

conc_fun <- World$Concentration() |>
  rename(conc_fun = Concentration_kg_m3) |>
  left_join(World$states$asDataFrame, by = "Abbr")

# Calculate the concentrations manually
sol <- World$Solution() |>
  left_join(World$states$asDataFrame, by = "Abbr")

# Calculate concentrations for masses summed over polymers
conc_manual <- 
  sol |>
  left_join(World$fetchData("Volume"), 
            by=c("Scale", "SubCompart")) |>
  # Change 'cloudwater' to 'air', and then sum the masses and volumes of these compartments together
  #mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |> 
  group_by(Scale, SubCompart, Species, RUNs, time) |>
  summarise(Mass_kg = sum(Mass_kg),
            Volume = sum(Volume)) |>
  ungroup() |>
  # Calculate the concentrations
  mutate(conc_manual = Mass_kg/Volume) |>
  
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |>
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|>
  mutate(Unit = "kg/m3") |>
  mutate(conc_manual =
           case_match(Matrix,
                      "air" ~ conc_manual,
                      "water" ~ conc_manual,
                      "soil" ~ conc_manual  / ((1 - FRACw - FRACa) * rhoMatrix), # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_manual  / ((1 - FRACw - FRACa) * rhoMatrix),
                      .default = conc_manual),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit)) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(FRACw, FRACa, rhoMatrix, Matrix, Volume)) 

# Compare the concentrations
concentrations_joined <- conc_fun |>
  left_join(conc_manual, by = c("Scale", "SubCompart", "RUNs", "Species", "time")) |>
  select(Scale, SubCompart, conc_fun, conc_manual, time, RUNs, Species) |>
  mutate(conc_diff = abs(conc_fun-conc_manual))











