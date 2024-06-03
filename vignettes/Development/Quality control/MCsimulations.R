library(lhs)
library(ggplot2)
library(plotly)

# Define the range for particle size in consistent units (micrometers)
lower_bound <- 1
upper_bound <- 200000

# Define shape categories and encode them numerically
shapes <- c("Sphere", "Cube", "Ellipsoid")
shape_codes <- seq_along(shapes)

#Define Solvers 
solvers <- c("Dioguardi","Swamee", "Stokes", "Original")
solver_codes <- seq_along(solvers)

# Number of samples
n_samples <- 10

# Generate Latin Hypercube Samples for both particle size and shape code
set.seed(123)  # Setting seed for reproducibility
lhs_samples <- randomLHS(n_samples, 3)

# Scale samples to the specified ranges
scaled_particle_sizes <- lower_bound + (upper_bound - lower_bound) * lhs_samples[, 1]
scaled_shape_codes <- round(1 + (length(shapes) - 1) * lhs_samples[, 2])
scaled_solver_codes <- round(1 + (length(solvers) - 1) * lhs_samples[, 3])

# Map shape codes back to shape names
sample_shapes <- shapes[scaled_shape_codes]
sample_solvers <-solvers[scaled_solver_codes]
# Initialize a list to store the results for SettlingVelocity
settling_velocity_results <- list()
substance <- "microplastic"
#source("baseScripts/initWorld_onlyPlastics.R")
# Run the model for each LHS sample combination of particle size and shape
for (i in 1:n_samples) {
  # Set the current sample values in the environment
  shape <- sample_shapes[i]
  particle_size <- scaled_particle_sizes[i]
  DragMethod <- sample_solvers[i]
  # Source the initialization script with the current sample
  source("baseScripts/initWorld_onlyPlastics.R")
  # Fetch the SettlingVelocity after initialization
  settling_velocity <- World$fetchData("SettlingVelocity")
  
  
  # Convert the result to a data frame and add columns for particle size and shape
  settling_velocity_df <- as.data.frame(settling_velocity)
  settling_velocity_df$particle_size <- particle_size
  settling_velocity_df$shape <- shape
  settling_velocity_df$solver <- DragMethod
  
  # Store the result in the list
  settling_velocity_results[[i]] <- settling_velocity_df
}

# Combine all data frames into a single data frame
combined_results_df <- do.call(rbind, settling_velocity_results)

# Print or save the results
print(combined_results_df)

# Filter for Scale = "Moderate"
filtered_results_df <- subset(combined_results_df, Scale == "Moderate" & SubCompart != "air" & SubCompart != "sea")

filter2 <- subset(combined_results_df, Scale == "Moderate" & SubCompart == "lake" & Species == "Solid")

# Sensitivity analysis plot indicating sensitivity to size and shape
ggplot(filtered_results_df, aes(x = particle_size, y = SettlingVelocity, color = shape)) +
  geom_point(size = 1, alpha = 0.7) +
  labs(title = "Sensitivity Analysis: Settling Velocity vs. Particle Size and Shape",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)",
       color = "Shape") +
  theme_minimal()

# Sensitivity analysis plot for lake and solid species indicating sensitivity to size and solver
ggplot(filter2, aes(x = particle_size, y = SettlingVelocity, color = solver)) +
  geom_point(size = 1, alpha = 0.7) +
  labs(title = "Sensitivity Analysis: Settling Velocity vs. Particle Size and Shape (Lake, Solid)",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)",
       color = "Solver") +
  theme_minimal()

ggplot(filter2, aes(x=shape, y =SettlingVelocity)) + 
  geom_point(size = 1, alpha = 0.7) +
  labs(title = "Sensitivity Analysis: Settling Velocity vs. Particle Size and Shape (Lake, Solid)",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)") +
       #color = "Shape") +
       theme_minimal()
ggplot(filtered_results_df, aes(x = particle_size, y = SettlingVelocity, color =solver, shape = shape)) +
  geom_point(size = 1, alpha = 0.7) +
  labs(
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)",
       color = "Solver",
       shape = "Shape") +
  theme_minimal()
cube_df <- filtered_results_df %>%
  filter(shape == "Cube")

# Plot the influence of the solver on the settling velocity with particle size on the x-axis
ggplot(cube_df, aes(x = particle_size, y = SettlingVelocity, color = solver)) +
  geom_point(size = 2, alpha = 0.7) +
  geom_line(aes(group = solver), alpha = 0.7) +
  labs(title = "Influence of Solver on Settling Velocity (Shape: Cube)",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)",
       color = "Solver") +
  theme_minimal()

fig <- plot_ly(data = filtered_results_df, 
               x = ~particle_size, 
               y = ~shape, 
               z = ~SettlingVelocity, 
               color = ~solver, 
               colors = c('#BF382A', '#0C4B8E', '#00CC96', '#f4862f')) %>%
  add_markers(marker = list(size = 3)) %>%
  layout(scene = list(
    xaxis = list(
      title = 'Particle Size (um)',
      titlefont = list(size = 12),  # Adjust the title font size as needed
      tickfont = list(size = 10),  # Adjust the tick font size as needed
      tickformat = ".1e"  # Use scientific notation
    ),
    yaxis = list(
      title = 'Shape',
      titlefont = list(size = 12),  # Adjust the title font size as needed
      tickfont = list(size = 10),  # Adjust the tick font size as needed
      tickformat = ".1e"  # Use scientific notation
    ),
    zaxis = list(
      title = 'Settling Velocity (m/s)',
      titlefont = list(size = 12),  # Adjust the title font size as needed
      tickfont = list(size = 10),  # Adjust the tick font size as needed
      tickformat = ".1e"  # Use scientific notation
    )),
    title = '3D Scatter Plot: Settling Velocity and Parameters')
fig
