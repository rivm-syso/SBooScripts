library(lhs)
library(tidyverse)

#create World as SBcore
source("baseScripts/initWorld_onlyMolec.R")

########################## Single emission df example ##########################
# Make emission df with timed column
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU","aRU", "s2RU", "w1RU"), Emis = c(10, 10, 10,20, 20, 20), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> ungroup() |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

tmax <- 365.25*24*60*60*10
times <- seq(0, tmax, length.out = 10)

# Make variable input 
# Define the number of samples and the number of variables
n_samples <- 10
n_vars <- 3

# Generate LHS
lhs_samples <- randomLHS(n_samples, n_vars)

# Define triangular distribution function
triangular_cdf_inv <- function(u, a, b, c) {
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

# Define the names of the uncertain variables
var1Name <- "Area"

var1 <- World$fetchData(var1Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "sea")

# Set the parameters for the triangular distribution
var1$a <- var1$Area*0.7    # Minimum value
var1$b <- var1$Area*1.3    # Maximum value
var1$c <- var1$Area         # Mode (peak)

# Define the names of the uncertain variables
var2Name <- "Area"

var2 <- World$fetchData(var2Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "river")

# Set the parameters for the triangular distribution
var2$a <- var2$Area*0.7    # Minimum value
var2$b <- var2$Area*1.3    # Maximum value
var2$c <- var2$Area         # Mode (peak)


# Define the names of the uncertain variables
var3Name <- "EROSIONsoil"

var3 <- World$fetchData(var3Name) |>
  filter(SubCompart == "agriculturalsoil") |>
  mutate(Scale = NA)

# Set the parameters for the triangular distribution
var3$a <- var3$EROSIONsoil*0.7    # Minimum value
var3$b <- var3$EROSIONsoil*1.3    # Maximum value
var3$c <- var3$EROSIONsoil         # Mode (peak)

params <- tibble(
  varName = c(var1Name, var2Name, var3Name),
  Scale = c(var1$Scale, var2$Scale, var3$Scale),
  SubCompart = c(var1$SubCompart, var2$SubCompart, var3$SubCompart),
  data = list(
    tibble(id = c("a", "b", "c"), value = c(var1$a, var1$b, var1$c)),
    tibble(id = c("a", "b", "c"), value = c(var2$a, var2$b, var2$c)),
    tibble(id = c("a", "b", "c"), value = c(var3$a, var3$b, var3$c))
  )
)

sample_df <- params

# Transform each LHS sample column to the corresponding triangular distribution
for (i in 1:n_vars) {
  a <- filter(params$data[[i]], id == "a") %>% pull(value)
  b <- filter(params$data[[i]], id == "b") %>% pull(value)
  c <- filter(params$data[[i]], id == "c") %>% pull(value)
  
  samples <- triangular_cdf_inv(lhs_samples[, i], a, b, c)
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  sample_df$data[[i]] <- new_data
}

# Solve with dynamic uncertain solver
# World$NewSolver("UncertainDynamicSolver")
# solved <- World$Solve(emissions, sample_df, tmax = tmax, needdebug = T)

# sol1 <- solved$Mass[[1]]
############################ Test with one funlist as input ####################

SBEmissions3 <- 
  emissions |> 
  group_by(Abbr) |> 
  summarise(n=n(),
            EmisFun = list(
              approxfun(
                data.frame(Timed = c(0,Timed), 
                           Emis=c(0,Emis)),
                rule = 2) # Change to rule 1:1 for no extrapolation
            )
  )

funlist <- SBEmissions3$EmisFun
names(funlist) <- SBEmissions3$Abbr

tmax <- 365.25*24*60*60*10
times <- seq(0, tmax, length.out = 10)

World$NewSolver("UncertainDynamicSolver")
solved <- World$Solve(funlist, sample_df, tmax = tmax, needdebug = T)

################################################################################

# Make emission df with timed column
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU","aRU", "s2RU", "w1RU"), Emis = c(10, 10, 10,20, 20, 20), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> ungroup() |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

tmax <- 365.25*24*60*60*10
times <- seq(0, tmax, length.out = 10)











# Define the number of samples and the number of variables
n_samples <- 10
n_vars <- 3
n_comps <- length(unique(emissions$Abbr))
n_times <- length(unique(emissions$Timed))

n_lhs <- n_vars+(n_comps*n_times)

# Generate LHS
lhs_samples <- randomLHS(n_samples, n_lhs)

# Define triangular distribution function
triangular_cdf_inv <- function(u, a, b, c) {
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

######################## Get min, max, mode for each var #######################

lhs_samples_vars <- lhs_samples[, 1:n_vars]

# Define the names of the uncertain variables
var1Name <- "Area"

var1 <- World$fetchData(var1Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "sea")

# Set the parameters for the triangular distribution
var1$a <- var1$Area*0.7    # Minimum value
var1$b <- var1$Area*1.3    # Maximum value
var1$c <- var1$Area         # Mode (peak)

# Define the names of the uncertain variables
var2Name <- "Area"

var2 <- World$fetchData(var2Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "river")

# Set the parameters for the triangular distribution
var2$a <- var2$Area*0.7    # Minimum value
var2$b <- var2$Area*1.3    # Maximum value
var2$c <- var2$Area         # Mode (peak)


# Define the names of the uncertain variables
var3Name <- "EROSIONsoil"

var3 <- World$fetchData(var3Name) |>
  filter(SubCompart == "agriculturalsoil") |>
  mutate(Scale = NA)

# Set the parameters for the triangular distribution
var3$a <- var3$EROSIONsoil*0.7    # Minimum value
var3$b <- var3$EROSIONsoil*1.3    # Maximum value
var3$c <- var3$EROSIONsoil         # Mode (peak)

params <- tibble(
  varName = c(var1Name, var2Name, var3Name),
  Scale = c(var1$Scale, var2$Scale, var3$Scale),
  SubCompart = c(var1$SubCompart, var2$SubCompart, var3$SubCompart),
  data = list(
    tibble(id = c("a", "b", "c"), value = c(var1$a, var1$b, var1$c)),
    tibble(id = c("a", "b", "c"), value = c(var2$a, var2$b, var2$c)),
    tibble(id = c("a", "b", "c"), value = c(var3$a, var3$b, var3$c))
  )
)

sample_df <- params

# Transform each LHS sample column to the corresponding triangular distribution
for (i in 1:n_vars) {
  a <- filter(params$data[[i]], id == "a") %>% pull(value)
  b <- filter(params$data[[i]], id == "b") %>% pull(value)
  c <- filter(params$data[[i]], id == "c") %>% pull(value)
  
  samples <- triangular_cdf_inv(lhs_samples_vars[, i], a, b, c)
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  sample_df$data[[i]] <- new_data
}

################################### emissions ##################################
lhs_samples_emis <- lhs_samples[, (n_vars + 1):ncol(lhs_samples)]

# Function to define triangular distribution parameters
define_triangular_params <- function(data) {
  data %>%
    mutate(a = Emis * 0.7,
           b = Emis * 1.3,
           c = Emis) %>%
    select(Timed, Abbr, a, b, c)
}

# Define triangular parameters for each unique combination of Timed and Abbr
params <- emissions %>%
  group_by(Timed, Abbr) %>%
  do(define_triangular_params(.)) %>%
  ungroup()

# Create a list of parameters for each unique combination
params_list <- split(params, list(params$Timed, params$Abbr))

# Function to apply triangular CDF inverse transformation
triangular_transform <- function(lhs_samples, params) {
  lapply(seq_along(params), function(i) {
    param_set <- params[[i]]
    a <- param_set$a
    b <- param_set$b
    c <- param_set$c
    
    samples <- triangular_cdf_inv(lhs_samples[, i], a, b, c)
    tibble(value = samples)
  })
}

# Apply the transformation for each combination of Timed and Abbr
emis_df_list <- lapply(params_list, function(param_set) {
  timed_abbr <- unique(param_set[c("Timed", "Abbr")])
  lhs_samples_filtered <- lhs_samples_emis %>% 
    select(which(names(lhs_samples_emis) %in% colnames(param_set)))
  
  transformed_samples <- triangular_transform(lhs_samples_filtered, param_set)
  
  # Combine transformed samples with Timed and Abbr
  tibble(Timed = timed_abbr$Timed, Abbr = timed_abbr$Abbr, Emis = transformed_samples)
})

# Combine all transformed data into a single data frame
emis_df <- bind_rows(emis_df_list)

################################## Solve #######################################
World$NewSolver("UncertainDynamicSolver")
solved <- World$Solve(emissions, needdebug = T, sample_df)
