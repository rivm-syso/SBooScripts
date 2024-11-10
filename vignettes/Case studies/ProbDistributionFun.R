######################################
# Distributions for LHS
# 2024-11-08
######################################


# Define triangular distribution function
triangular <- function(u, a, b, c) {               # u = samples, a = min, b = max, c = peak
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

# Define uniform distribution function
uniform <- function(u, a, b) {                     # u = samples, a = min, b = max
  transformed_samples <- a + (b - a) * u
  return(transformed_samples)
}

log_uniform <- function(u, a, b) {
  
  log_scaled <- -log(1 - u)
  transformed_samples <- a + (b - a) * (log_scaled / max(log_scaled))
  return(transformed_samples)
}

# Define power law distribution function
power_law <- function(u, a, b, c){                 # u = samples, a = min, b = max, c = alpha
  
  # Ensure that samples are within [0, 1]
  samples <- pmin(pmax(u, 0), 1)
  
  # Transform samples to the power-law distribution
  scaled_samples <- a * ((b / a) ^ samples) ^ (1 / (1 - c))
  
  return(scaled_samples)
}

trapezoidal <- function(u, a, b, c, d) {
  # Ensure u is in the range [0, 1]
  u <- pmin(pmax(u, 0), 1)  # Clip u to [0, 1]
  
  # Total width of the trapezoid
  width_total <- d - a
  base1 <- b - a    # Width of the left base
  base2 <- d - c    # Width of the right base
  
  # Calculate the CDF segments
  CDF_left <- base1 / width_total         # Area under the left triangle
  CDF_flat <- 1 - base2 / width_total     # Area under the flat top
  
  result <- ifelse(u < (base1 / width_total), 
                   a + sqrt(u * (base1) * width_total),  # Left triangle
                   ifelse(u <= (CDF_flat + base1 / width_total), 
                          b + (u - base1 / width_total) * (d - b),  # Flat top
                          d - sqrt((1 - u) * (base2) * width_total)  # Right triangle
                   )
  )
  return(result)
}

# Function to scale TRWP size to data from LEON-T deliverable 3.2
TRWP_size_dist <- function(u, path_parameters_file) {
  
  # Read the data and process it
  TRWP_data <- readxl::read_excel(path_parameters_file, sheet = "TRWP_data") |>
    separate(`Size Fraction (µm)`,
             into = c("Size_um","max_size_um"), sep = "-") |> 
    mutate(Size_um = as.numeric(gsub("400", "1000", Size_um))) |>  # Change "400" to "1000"
    mutate(PSD_um = as.numeric(PSD_um)) |> # Assuming PSD_um is the particle size distribution (weights)
    mutate(cdf = cumsum(PSD_um)) |>
    mutate(cdf = cdf / max(cdf))  # Normalize the CDF
  
  # Use the approx function to interpolate Size_um based on the CDF
  scaled_samples <- approx(x = TRWP_data$cdf, y = TRWP_data$Size_um, xout = u, rule = 2)$y
  
  return(scaled_samples)
}