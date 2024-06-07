library(dplyr)
source("baseScripts/initWorld_onlyParticulate.R")
# Define the file paths and corresponding compartment abbreviations
file_paths <- c("../Emissions/emissions/EU/Results_SinkDynamic_Air-GBM_EU_2024-01-30-11-43_12.csv", 
                "../Emissions/emissions/EU/Results_SinkDynamic_STsoil-GBM_EU_2024-01-30-11-43_12.csv",
                "../Emissions/emissions/EU/Results_SinkDynamic_SurfaceWater-GBM_EU_2024-01-30-11-43_12.csv")
compartment_abbrs <- c("aCS", "s1CS", "w1CS")

World$kaas
World$NewSolver("SBsteady")
emissions <- data.frame(Abbr = "aRC", Emis = 1)
World$Solve(emissions)
# Define the function for interpolation
avg_emisfun <- function(Y) {
  # Use approxfun to create a linear interpolation function
  approxfun(data.frame(year = Y$Year_in_seconds ,
                       emis_kg = Y$Emis), rule = 1:2)
}

# Initialize an empty list to store the results
results_list <- list()
interpolations <- list()
output_emissions_list <- list()


# Loop over each file path and its corresponding compartment abbreviation
for (i in seq_along(file_paths)) {
  file <- file_paths[i]
  abbr <- compartment_abbrs[i]
  
  # Read the data
  Emissions <- read.csv(file)
  
  # Calculate the mean of each column, ignoring NA values
  avg_values <- sapply(Emissions, mean, na.rm = TRUE)
  
  # Create a new dataframe with the averages
  avg_Emissions <- data.frame(Column = names(avg_values), Emis = avg_values*1000)
  
  # Add the Abbr column
  avg_Emissions$Abbr <- abbr
  
  # Remove the first row
  avg_Emissions <- avg_Emissions[-1, ]
  
  # Extract the year from the Column names
  avg_Emissions$Year <- as.integer(sub("X", "", avg_Emissions$Column))
  avg_Emissions$Year_in_seconds <- avg_Emissions$Year * 365.25 *24 * 360
  
  # Add the result to the list
  results_list[[abbr]] <- avg_Emissions
  interpolation_function <- avg_emisfun(avg_Emissions)
  
  # Store the interpolation with the appropriate name
  interpolations[[abbr]] <- interpolation_function
  
  # Define the times sequence
  times <- seq(0, 24*365.25*24*360, by = 10000)
  
  # Interpolate emissions for each time point
  interpolated_emissions <- interpolation_function(times)
  
  # Create a dataframe for plotting
  output_emissions <- data.frame(Year_in_seconds = times, Emis = interpolated_emissions, Abbr = abbr)
  
  # Add to the output emissions list
  output_emissions_list[[abbr]] <- output_emissions
}


#interpolations <- do.call(rbind, interpolations)
emissions <- do.call(rbind, output_emissions_list)
emissionsum <-sum(emissions$Emis)
print(emissions)
func_aCS<- interpolations$aCS
func_s1CS <- interpolations$s1CS
func_w1CS <- interpolations$w1CS

# Plot the interpolation function
ggplot(emissions, aes(x = Year_in_seconds, y = Emis, color = Abbr)) +
  geom_line() +
  labs(x = "seconds", y = "Emissions (kg)", color = "Compartment") +
  ggtitle("Interpolation Functions for Air, Soil, and Water") +
  theme_minimal()


SimpleBoxODE = function(t, m, parms) {
  
  with(as.list(c(parms, m)), {
    e <- c(rep(0, length(SBNames)))
  
    e[grep("aCS", SBNames)] <- func_aCS(t)
    e[grep("s1CS",SBNames)] <- func_s1CS(t)
    e[grep("w1CS",SBNames)] <- func_w1CS(t)
    dm <- K%*% m + e
    res <- c(dm)
    list(res, signal = e)
  })
}

# exporting Engine
Engine <-World$exportEngineR()
SB.K <-Engine
SBNames <-colnames(Engine)
print(SBNames)
print(SBNames)
SB.m0 <- rep(0, length(SBNames))
print(length(SB.m0))

#Function to Solve
SBsolve4 <- function( tmax = 1e10, nTIMES = 100) {
  
  SB.K <- Engine
  
  SBtime <- seq(0,tmax,length.out = nTIMES)
  
  
  out <- deSolve::ode(
    y = as.numeric(SB.m0),
    times = SBtime ,
    func = SimpleBoxODE,
    parms = list(K = SB.K, SBNames,func_aCS, func_s1CS, func_w1CS),
    rtol = 1e-10, atol = 1e-2)
  #if(as.character(class(deS)[1])!="data.frame") return (list(errorstate="error", deS))
  
}
#Solving
Solution<- SBsolve4(tmax = 24*(365.25*24*360), nTIMES = 130)

#Processing Results
Solution.df <- as.data.frame(Solution)
colnames(Solution)[2:156] <- SBNames
Solution_df <- as.data.frame(Solution)


signals <- Solution_df[, 157:311]
signals$sum <- rowSums(signals)
signals$time <- Solution_df[, 1]
signals_plot <- data.frame(signals$sum)
signals_plot$time <- signals$time

#Checks
#Emission over time
ggplot(signals_plot, aes(x = time, y =signals.sum)) + 
  geom_line() +
  labs(title = "Emissions Over Time", x = "Time", y = "Emissions")

signals_plot$cumulative_area <- cumsum(c(0, diff(signals_plot$time) * (head(signals_plot$signals.sum, -1) + tail(signals_plot$signals.sum, -1)) / 2))
mass_time <- data.frame(time = Solution_df$time, mass = rowSums(Solution_df[, 2:156]))
# Plot the cumulative area
p <- ggplot() +
  geom_line(data = signals_plot, aes(x = time/(365.25*24*360), y = cumulative_area, color = "Cumulative Signals"), size = 1.5) +
  geom_line(data = mass_time, aes(x = time/(365.25*24*360), y = mass, color = "Mass over Time"), size = 1.5) +
  labs(title = "Amount [kgs]", x = "Time [years]", y = "Cumulative Area", color = "Dataset")
print(p)


Solution_df <- Solution_df %>% select(-matches("U$"))
solution_matrix <- Solution_df[, 1:121]
print(solution_matrix)
ggplot(Solution_df, aes(x = time, y = aCS)) +
  geom_point() +
  geom_line() +
  labs(title = "aCS", x = "times", y = "aCS [kg]")
ggplot(Solution_df, aes(x = time, y = s1CS)) +
  geom_point() +
  geom_line() +
  labs(title = "s1CS", x = "times", y = "s1CS [kg]")
ggplot(Solution_df, aes(x = time, y = w1CS)) +
  geom_point() +
  geom_line() +
  labs(title = "w1CS", x = "times", y = "w1CS [kg]")
split_df <- function(df) {
  # Extract the capital letters (A, R, C, T, M) in column names
  patterns <- unique(gsub("[^ARCTM]", "", colnames(df)))
  
  # Split the dataframe based on the presence of specified capital letters
  split_dfs <- lapply(patterns, function(pat) {
    cols <- grepl(pat, colnames(df))
    df[, cols]
  })
  
  names(split_dfs) <- patterns
  
  return(split_dfs)
}

# Apply the function to split the dataframe
split_dfs <- split_df(solution_matrix)

# Output the split dataframes
for (pattern in names(split_dfs)) {
  cat(pattern)
  print(split_dfs[[pattern]])
  cat("\n")
}

Continental <- split_dfs[["C"]]
Continental$time <- solution_matrix$time

data_to_plot <- gather(Continental, key = "variable", value = "value", -time)

ggplot(data_to_plot, aes(x = time/(365.25*24*360), y = value, color = variable)) +
  geom_line() +
  labs(title = "Continental Subset Plotted Against Time",
       x = "Time [y]",
       y = "Mass [kg]")


# Assuming A, C, T, R, and M are the split dataframes
A <- split_dfs[["A"]]
C <- split_dfs[["C"]]
T <- split_dfs[["T"]]
R <- split_dfs[["R"]]
M <- split_dfs[["M"]]

# Applying adjustments to all dataframes
adjust_df <- function(df) {
  df$time <- solution_matrix$time
  return(df)
}

A <- adjust_df(A)
C <- adjust_df(C)
T <- adjust_df(T)
R <- adjust_df(R)
M <- adjust_df(M)

plot_dataframe <- function(df, title) {
  data_to_plot <- tidyr::gather(df, key = "variable", value = "value", -time)
  
  ggplot(data_to_plot, aes(x = time, y = value, color = variable)) +
    geom_line() +
    labs(title = title,
         x = "Time",
         y = "Value")
}

# Plot each adjusted dataframe with corresponding title
plot_A <- plot_dataframe(A, "A")
plot_C <- plot_dataframe(C, "C")
plot_T <- plot_dataframe(T, "T")
plot_R <- plot_dataframe(R, "R")
plot_M <- plot_dataframe(M, "M")

# Show the plots
#Arctic is not right, needs more data refinement
print(plot_A)
print(plot_C)
print(plot_T)
print(plot_R)
print(plot_M)