library(lhs)
library(ggplot2)

# Define the range for particle size in consistent units (meters)
lower_bound <- 1
upper_bound <- 30000

# Define shape categories and encode them numerically
shapes <- c("Sphere", "Cube", "Ellipsoid")
shape_codes <- seq_along(shapes)

# Number of samples
n_samples <- 10

# Generate Latin Hypercube Samples for both particle size and shape code
set.seed(123)  # Setting seed for reproducibility
lhs_samples <- randomLHS(n_samples, 2)

# Scale samples to the specified ranges
scaled_particle_sizes <- lower_bound + (upper_bound - lower_bound) * lhs_samples[, 1]
scaled_shape_codes <- round(1 + (length(shapes) - 1) * lhs_samples[, 2])

# Map shape codes back to shape names
sample_shapes <- shapes[scaled_shape_codes]

# Initialize a list to store the results for SettlingVelocity
settling_velocity_results <- list()
substance <- "microplastic"
#source("baseScripts/initWorld_onlyPlastics.R")
# Run the model for each LHS sample combination of particle size and shape
for (i in 1:n_samples) {
  # Set the current sample values in the environment
  #particle_size <- scaled_particle_sizes[i]
  shape <- sample_shapes[i]
  particle_size <- scaled_particle_sizes[i]
  # Source the initialization script with the current sample
  source("baseScripts/initWorld_onlyPlastics.R")
  # Fetch the SettlingVelocity after initialization
  settling_velocity <- World$fetchData("SettlingVelocity")
  
  
  # Convert the result to a data frame and add columns for particle size and shape
  settling_velocity_df <- as.data.frame(settling_velocity)
  settling_velocity_df$particle_size <- particle_size
  settling_velocity_df$shape <- shape
  
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

# Sensitivity analysis plot for lake and solid species indicating sensitivity to size and shape
ggplot(filter2, aes(x = particle_size, y = SettlingVelocity, color = shape)) +
  geom_point(size = 1, alpha = 0.7) +
  labs(title = "Sensitivity Analysis: Settling Velocity vs. Particle Size and Shape (Lake, Solid)",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)",
       color = "Shape") +
  theme_minimal()

ggplot(filter2, aes(x=shape, y =SettlingVelocity)) + 
  geom_point(size = 1, alpha = 0.7) +
  labs(title = "Sensitivity Analysis: Settling Velocity vs. Particle Size and Shape (Lake, Solid)",
       x = "Particle Size (um)",
       y = "Settling Velocity (m/s)")
       #color = "Shape") +
       theme_minimal()
       