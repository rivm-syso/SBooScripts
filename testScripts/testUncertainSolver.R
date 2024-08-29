library(lhs)
library(tidyverse)

#create World as SBcore
source("baseScripts/initWorld_onlyMolec.R")

emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

# Define the number of samples and the number of variables
n_samples <- 10
n_vars <- 3
n_comps <- 2

n_lhs <- n_vars+n_comps

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

# Define the names of the uncertain variables
comp1Name <- "aRU"

comp1 <-  emissions |>
  filter(Abbr == comp1Name)

# Set the parameters for the triangular distribution
comp1$a <- comp1$Emis*0.7    # Minimum value
comp1$b <- comp1$Emis*1.3    # Maximum value
comp1$c <- comp1$Emis        # Mode (peak)

comp1 <- comp1 |>
  select(-Emis)

# Define the names of the uncertain variables
comp2Name <- "s2RU"

comp2 <-  emissions |>
  filter(Abbr == comp2Name)

# Set the parameters for the triangular distribution
comp2$a <- comp2$Emis*0.7    # Minimum value
comp2$b <- comp2$Emis*1.3    # Maximum value
comp2$c <- comp2$Emis        # Mode (peak)

comp2 <- comp2 |>
  select(-Emis)

params <- tibble(
  Abbr = c(comp1Name, comp2Name),
  Emis = list(
    tibble(id = c("a", "b", "c"), value = c(comp1$a, comp1$b, comp1$c)),
    tibble(id = c("a", "b", "c"), value = c(comp2$a, comp2$b, comp2$c))
  )
)

emis_df <- params

# Transform each LHS sample column to the corresponding triangular distribution
for (i in 1:n_comps) {
  a <- filter(params$Emis[[i]], id == "a") %>% pull(value)
  b <- filter(params$Emis[[i]], id == "b") %>% pull(value)
  c <- filter(params$Emis[[i]], id == "c") %>% pull(value)
  
  samples <- triangular_cdf_inv(lhs_samples_emis[, i], a, b, c)
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  emis_df$Emis[[i]] <- new_data
}

################################## Solve #######################################

World$NewSolver("UncertainSolver")
solved <- World$Solve(emis_df, needdebug = T, sample_df)








######################### Find way to reach the values again ###################

# Get all values corresponding to a var
nrow(sample_df$data[1])

# Get one instance
nrow(sample_df$data[[1]])

# Get first value of first df in data
first_value <- map(sample_df$data[1], ~ .x$value[1])[[1]]

# Get first value of all dfs in data
first_values <- map(sample_df$data, ~ .x$value[1])

## Test if the data really is triangularly distributed
test <- sample_df$data[[1]]
hist(test$value)

