
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
solution <- World$Solution()

DetDynPlot <- function(scale = "Regional", subcompart = NULL){
  
  # Get the solution
  solution <- merge(World$Solution(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'time', 'Mass_kg')]
    
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(solution$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  if (!is.null(subcompart)) {
    solution <- solution[solution$SubCompart %in% subcompart, ]
  } else {
    solution <- solution
  }
  
  # Convert time from seconds to years
  solution$time <- as.numeric(solution$time)
  solution$Year <- solution$time / (365.25 * 24 * 3600)
  
  plot <- ggplot(solution, aes(x = Year, y = Mass_kg, group = SubCompart, color = SubCompart)) + 
    theme_bw() + 
    geom_line() +
    ggtitle(paste0("Masses in compartments at ", scale, " scale"))
}

print(DetDynPlot(scale = "Regional"))

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
solution <- World$Solution()

scale = "Regional"
subcompart = "river"

ProbDynPlot <- function(scale = "Regional", subcompart = "agriculturalsoil"){
  
  # Get the solution
  solution <- merge(World$Solution(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'time', 'RUNs', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  if(length(subcompart) != 1){
    stop("Please select 1 subcompartment")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(solution$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  if (!is.null(subcompart)) {
    solution <- solution[solution$SubCompart %in% subcompart, ]
  } else {
    solution <- solution
  }
  
  # Convert time from seconds to years
  solution$time <- as.numeric(solution$time)
  solution$Year <- solution$time / (365.25 * 24 * 3600)
  
  summary_stats <- solution |>
    group_by(Year) |>
    summarise(
      Mean_Value = mean(Mass_kg, na.rm = TRUE),
      SD_Value = sd(Mass_kg, na.rm = TRUE),
      Lower_CI = Mean_Value - 1.96 * SD_Value / sqrt(n()),
      Upper_CI = Mean_Value + 1.96 * SD_Value / sqrt(n())
    ) |>
    ungroup()
  
  ggplot(summary_stats, aes(x = Year, y = Mean_Value)) +
    geom_line(color = "blue", size = 1) +
    geom_ribbon(aes(ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2, fill = "blue") +
    labs(title = paste("Mean mass in", subcompart, " at ", scale, " scale with uncertainty bands over time"),
         x = "Year",
         y = paste("Mass of substance in ", subcompart, "[kg]")) +
    theme_minimal()
}

print(ProbDynPlot(scale = "Regional", subcompart = "agriculturalsoil"))

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

scale = "Regional"

ProbSSPlot <- function(scale = "Regional"){
  
  # Get the solution
  solution <- merge(World$Solution(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'RUNs', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }

  ggplot(solution, aes(x = SubCompart, y = Mass_kg)) +
    geom_violin()+
    theme_bw() +
    labs(title = paste("Mass at ", scale, "scale"),
         x = "",
         y = paste("Mass of substance [kg]")) +
    theme_minimal()
}

print(ProbSSPlot(scale = "Regional"))
