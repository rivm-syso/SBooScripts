library(foreach)
library(doParallel)
library(lhs)
library(ggplot2)
library(plotly)

# Define the range for particle size in consistent units (meters)
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

# Initialize parallel processing
cores <- detectCores()
cl <- makeCluster(cores)
registerDoParallel(cl)

# Run the function in parallel
foreach(i = 1:n_samples, .combine = rbind) %dopar% {
  # Set the current sample values in the environment
  shape <- sample_shapes[i]
  print(shape)
  particle_size <- scaled_particle_sizes[i]
  DragMethod <- sample_solvers[i]  # Corrected variable name
  
  # Source the initialization script with the current sample
  source("baseScripts/initWorld_onlyPlastics.R")
  
  # Fetch the SettlingVelocity after initialization
  settling_velocity <- World$fetchData("SettlingVelocity")
  
  # Convert the result to a data frame and add columns for particle size and shape
  settling_velocity_df <- as.data.frame(settling_velocity)
  settling_velocity_df$particle_size <- particle_size
  settling_velocity_df$shape <- shape  # Assign shape correctly
  settling_velocity_df$solver <- DragMethod  # Assign solver correctly
  
  settling_velocity_results[[i]] <- settling_velocity_df
}

# Stop parallel processing
stopCluster(cl)
combined_results_df <- do.call(rbind, settling_velocity_results)
# Rename the columns for clarity
#colnames(results)[colnames(results) == "X1"] <- "SettlingVelocity"

# Combine the results into a single data frame
#final_result <- results
