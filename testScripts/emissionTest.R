library(readxl)
library(deSolve)
library(patchwork)
source("baseScripts/initWorld_onlyParticulate.R")
# Define the file paths and corresponding compartment abbreviations
file_paths <- c("../Emissions/emissions/EU/Results_SinkDynamic_Air-GBM_EU_2024-01-30-11-43_12.csv", 
                "../Emissions/emissions/EU/Results_SinkDynamic_STsoil-GBM_EU_2024-01-30-11-43_12.csv",
                "../Emissions/emissions/EU/Results_SinkDynamic_SurfaceWater-GBM_EU_2024-01-30-11-43_12.csv")
compartment_abbrs <- c("aCS", "s1CS", "w1CS")
# Define the function for interpolation
avg_emisfun <- function(Y) {
  # Use approxfun to create a linear interpolation function
  approxfun(data.frame(year = Y$Year * (60 * 60 * 24 * 365.25),
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
  avg_Emissions <- data.frame(Column = names(avg_values), Emis = avg_values)
  
  # Add the Abbr column
  avg_Emissions$Abbr <- abbr
  
  # Remove the first row
  avg_Emissions <- avg_Emissions[-1, ]
  
  # Extract the year from the Column names
  avg_Emissions$Year <- as.integer(sub("X", "", avg_Emissions$Column))
  
  # Add the result to the list
  results_list[[abbr]] <- avg_Emissions
  interpolation_function <- avg_emisfun(avg_Emissions)
  
  # Store the interpolation with the appropriate name
  interpolations[[abbr]] <- interpolation_function
  
  # Define the times sequence
  times <- seq(0, 756864000, by = 1000)
  
  # Interpolate emissions for each time point
  interpolated_emissions <- interpolation_function(times)
  
  # Create a dataframe for plotting
  output_emissions <- data.frame(seconds = times, Emis = interpolated_emissions, Abbr = abbr)
  
  # Add to the output emissions list
  output_emissions_list[[abbr]] <- output_emissions
}

# Combine all results into a single dataframe
combined_results <- do.call(rbind, results_list)
combined_output_emissions <- do.call(rbind, output_emissions_list)
# View the combined results
print(combined_results)

# Define the function for interpolation
avg_emisfun <- function(Y) {
  # Use approxfun to create a linear interpolation function
  approxfun(data.frame(year = Y$Year * (60 * 60 * 24 * 365.25),
                       emis_kg = Y$Emis), rule = 1:2)
}

# Apply the interpolation function to avg_EmissionsAir dataframe
interpolation_function <- avg_emisfun(avg_EmissionsAir)
y <- c(Abbr = "aCS")
times <- seq(0, 756864000, by = 1000)

# Use the interpolation function to interpolate emissions for each time point
interpolated_emissions <- interpolation_function(times)

# Create a dataframe for plotting
output_emissions <- data.frame(seconds= times, Emis = interpolated_emissions, Abbr = "aCS")

# Plot the interpolation function
ggplot(combined_output_emissions, aes(x = seconds, y = Emis, color = Abbr)) +
  geom_line() +
  labs(x = "Seconds", y = "Emissions (tonnes)", color = "Compartment") +
  ggtitle("Interpolation Functions for Air, Soil, and Water") +
  theme_minimal()

# Evaluate the function at each year
#emissions <- f_emis(years)
# Solver <- World$NewSolver("deSolve")
Solver <- World$NewSolver("SBsolve")
Solution <- World$Solve(emissions = combined_output_emissions,
                             needdebug = F,
                             nTIMES = 10000,
                             tmax = 756864000 #,
)

#plots

toPlot <- World$SolutionAsRelational()

toPlot$SBtime
toPlot$SBtime <- toPlot$SBtime
ggplot(data = toPlot[toPlot$Scale == "Continental" & toPlot$SubCompart == "agriculturalsoil" &toPlot$Species == "Small",],
       aes(x = SBtime, y = Mass),) +
  geom_line() + 
  labs(title = "Tropic Deep Ocean Small",
       x = "Time (s)",
       y = "Mass") +
  theme_minimal()


# Creating the first plot for "Small" species
plot1 <- ggplot(data = toPlot[toPlot$Scale == "Continental" & toPlot$Species == "Small", ],
                aes(x = SBtime, y = Mass, color = SubCompart)) +
  geom_line() + 
  labs(title = "Continental - Small",
       x = "Time (s)",
       y = "Mass") +
  theme_minimal()

# Creating the second plot for "Solid" species
plot2 <- ggplot(data = toPlot[toPlot$Scale == "Continental" & toPlot$Species == "Solid", ],
                aes(x = SBtime, y = Mass, color = SubCompart)) +
  geom_line() + 
  labs(title = "Continental - Solid",
       x = "Time (s)",
       y = "Mass") +
  theme_minimal()

# Creating the third plot for "Large" species
plot3 <- ggplot(data = toPlot[toPlot$Scale == "Continental" & toPlot$Species == "Large", ],
                aes(x = SBtime, y = Mass, color = SubCompart)) +
  geom_line() + 
  labs(title = "Continental - Large",
       x = "Time (s)",
       y = "Mass") +
  theme_minimal()
combined_plot <- plot1 + plot2 + plot3 + 
  plot_layout(ncol = 1, guides = "collect") 

# Print the combined plot
print(combined_plot)




ggplot(data = toPlot[toPlot$Scale == "Continental" &toPlot$Species == "Small",],
       aes(x = SBtime, y = Mass, color = SubCompart),) +
  geom_line() + 
  labs(title = "Continental",
       x = "Time (s)",
       y = "Mass (tonnes?)") +
  theme_minimal()

ggplot(data = toPlot[toPlot$Scale == "Continental" &toPlot$Species == "Solid",],
       aes(x = SBtime, y = Mass, color = SubCompart),) +
  geom_line() + 
  labs(title = "Continental",
       x = "Time (s)",
       y = "Mass (tonnes?)") +
  theme_minimal()

ggplot(data = toPlot[toPlot$Scale == "Continental" &toPlot$Species == "Large",],
       aes(x = SBtime, y = Mass, color = SubCompart),) +
  geom_line() + 
  labs(title = "Continental",
       x = "Time (s)",
       y = "Mass (tonnes?)") +
  theme_minimal()

codes <- Solution$Abbr


ggplot(Solution, aes(x = Abbr, y = EqMass, color = SubCompart )) + 
  geom_point() +
  labs(title = "Solution",
       x = "Abbr",
       y = "EqMass") +
  theme_minimal()

library(plotly)

plot <- plot_ly(Solution, x = ~Abbr, y = ~EqMass, color = ~SubCompart, type = 'scatter', mode = 'markers') %>%
  layout(title = "Solution",
         xaxis = list(title = "Abbr"),
         yaxis = list(title = "EqMass"),
         template = "plotly_white")
                                                                                                                                                                                                                      
htmlwidgets::saveWidget(plot, "temp_plotly_plot.html")
browseURL("temp_plotly_plot.html")
