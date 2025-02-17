# Script to test the output function
library(tidyverse)

source("baseScripts/initWorld_onlyPlastics.R")

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

Example_vars <- readxl::read_xlsx("vignettes/Example_uncertain_variables.xlsx", sheet = "Variable_data")
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

World$NewSolver("SteadyODE")
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)))

sol <- World$Solution()
states <- World$states$asDataFrame

ntime <- length(unique(sol$time))
nrun <- length(unique(sol$RUNs))

# Add states to the solution dataframe
sol <- merge(sol, states, by = intersect(names(sol), names(states)))

# Select only the needed columns
sol <- sol[c('Scale', 'SubCompart', 'Species', 'Mass_kg', 'RUNs')]

# Aggregate the data over species
sol <- aggregate(Mass_kg ~ Scale + SubCompart + RUNs, data = sol, sum)

# Aggregate the data over Scale and SubCompart
sol_aggregated <- aggregate(Mass_kg ~ Scale + SubCompart, data = sol, sum)

# Define a function to calculate summary statistics
summary_stats <- function(x) {
  c(
    count = length(x),
    mean = mean(x, na.rm = TRUE),
    sum = sum(x, na.rm = TRUE),
    sd = sd(x, na.rm = TRUE),
    min = min(x, na.rm = TRUE),
    max = max(x, na.rm = TRUE)
  )
}

# Use aggregate to calculate summary statistics for each Scale-SubCompart combination
summary_list <- aggregate(
  Mass_kg ~ Scale + SubCompart,
  data = sol,
  FUN = function(x) list(summary_stats(x))
)

# Extract the summary statistics and convert them into a data frame
summary_stats_df <- do.call(rbind, summary_list$Mass_kg)

# Combine the grouping columns with the summary statistics
summary_df <- cbind(summary_list[1:2], summary_stats_df)

# Assign meaningful column names to the summary statistics
colnames(summary_df)[3:8] <- c("count", "mean", "sum", "sd", "min", "max")
summary_df <- summary_df[c('Scale', 'SubCompart', "mean", "sum", "sd", "min", "max")]

# Melt the data to long format
melted_data <- reshape2::melt(summary_df, id.vars = c("Scale", "SubCompart"), variable.name = "SummaryStatistic", value.name = "Value")

# Create a data frame with all possible combinations of SubCompart, Scale, and SummaryStatistic
all_combinations <- expand.grid(
  SubCompart = unique(melted_data$SubCompart),
  Scale = unique(melted_data$Scale),
  SummaryStatistic = unique(melted_data$SummaryStatistic)
)

# Merge the complete grid with the melted data
complete_data <- merge(all_combinations, melted_data, by = c("SubCompart", "Scale", "SummaryStatistic"), all.x = TRUE)

# Cast the data to have Scales as columns and SubCompart as row names
mass_df <- reshape2::dcast(complete_data, SubCompart + SummaryStatistic ~ Scale, value.var = "Value")



#names(mass_df) <- sub("Mass_kg\\.", "", names(mass_df)) # Clean up column names








# Steady state deterministic
if(ntime == 1 && nrun == 1){
  
  # Select only the needed columns
  sol <- sol[c('Scale', 'SubCompart', 'Species', 'Mass_kg')]
  
  # Aggregate the data over species
  sol <- aggregate(Mass_kg ~ Scale + SubCompart, data = sol, sum)
  # Pivot the table so that the Scales are the column names and SubComparts are the rownames, while making sure that scale-subcompart combinations that don't exist are NA in the resulting df
  all_combinations <- expand.grid( # Create a data frame with all possible combinations of Scale and SubCompart
    SubCompart = unique(sol$SubCompart),
    Scale = unique(sol$Scale)
  )
  complete_data <- merge(all_combinations, summed_data, by = c("SubCompart", "Scale"), all.x = TRUE) # Merge the complete grid with the summed data
  mass_df <- reshape( # Reshape the data to have Scales as columns and SubCompart as row names
    complete_data,
    timevar = "Scale",
    idvar = "SubCompart",
    direction = "wide"
  )
  names(mass_df) <- sub("Mass_kg\\.", "", names(mass_df)) # Clean up column names
  rownames(mass_df) <- mass_df$SubCompart # Set row names to SubCompart and remove the SubCompart column
  mass_df$SubCompart <- NULL
  mass_df[] <- lapply(mass_df, function(x) ifelse(is.na(x), NA, formatC(x, format = "e", digits = 3)))


# Dynamic deterministic  
} else if(ntime > 1 && nrun == 1){
  
# Steady state probabilistic    
} else if(ntime == 1 && nrun > 1){
  
# Dynamic probabilistic  
} else if(ntime > 1 && nrun > 1){
  
  
}

# Test how the df looks printed
knitr::kable(mass_df)


############### Below is for dynamic deterministic calculations, not finished yet

# Add states to the solution dataframe
sol <- merge(sol, states, by = intersect(names(sol), names(states)))

# Select only the needed columns
sol <- sol[c('time', 'Scale', 'SubCompart', 'Species', 'Mass_kg')]

# Aggregate the data over species
sol <- aggregate(Mass_kg ~ Scale + SubCompart + time, data = sol, sum)

# Pivot the table so that the Scales are the column names and SubComparts are the rownames, while making sure that scale-subcompart combinations that don't exist are NA in the resulting df
all_combinations <- expand.grid( # Create a data frame with all possible combinations of Scale and SubCompart
  SubCompart = unique(sol$SubCompart),
  Scale = unique(sol$Scale)
)
complete_data <- merge(all_combinations, summed_data, by = c("SubCompart", "Scale"), all.x = TRUE) # Merge the complete grid with the summed data

mass_df <- reshape( # Reshape the data to have Scales as columns and SubCompart as row names
  complete_data,
  timevar = "Scale",
  idvar = "SubCompart",
  direction = "wide"
)
names(mass_df) <- sub("Mass_kg\\.", "", names(mass_df)) # Clean up column names
rownames(mass_df) <- mass_df$SubCompart # Set row names to SubCompart and remove the SubCompart column
mass_df$SubCompart <- NULL
mass_df[] <- lapply(mass_df, function(x) ifelse(is.na(x), NA, formatC(x, format = "e", digits = 3)))