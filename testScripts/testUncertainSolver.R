library(lhs)
library(tidyverse)

#create World as SBcore
source("baseScripts/initWorld_onlyMolec.R")

#Make an emissions data frame
emissions <- data.frame(Abbr = "aRU", Emis = 1000)

# Define the number of samples and the number of variables
n_samples <- 1000
n_vars <- 3

# Generate LHS
lhs_samples <- randomLHS(n_samples, n_vars)

# Define triangular distribution function
triangular_cdf_inv <- function(u, a, b, c) {
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

######################## Get min, max, mode for each var #######################

# Define the names of the uncertain variables
var1Name <- "Area"

var1 <- World$fetchData(var1Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "sea")
  
# Set the parameters for the triangular distribution
var1$a <- var1$Area-10000    # Minimum value
var1$b <- var1$Area+10000    # Maximum value
var1$c <- var1$Area         # Mode (peak)

# Define the names of the uncertain variables
var2Name <- "Area"

var2 <- World$fetchData(var2Name) |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "river")

# Set the parameters for the triangular distribution
var2$a <- var2$Area-10000    # Minimum value
var2$b <- var2$Area+10000    # Maximum value
var2$c <- var2$Area         # Mode (peak)


# Define the names of the uncertain variables
var3Name <- "EROSIONsoil"

var3 <- World$fetchData(var3Name) |>
  filter(SubCompart == "agriculturalsoil") |>
  mutate(Scale = NA)

# Set the parameters for the triangular distribution
var3$a <- var3$EROSIONsoil*0.9    # Minimum value
var3$b <- var3$EROSIONsoil*1.1    # Maximum value
var3$c <- var3$EROSIONsoil         # Mode (peak)

#################### Make a tibble with the parameters #########################

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

################################## Solve #######################################

World$NewSolver("UncertainSolver")
World$Solve(emissions, needdebug = T, sample_df)







######################### Find way to reach the values again ###################

# Get all values corresponding to a var
sample_df$data[1]

# Get one instance
sample_df$data[[1]]

# Get first value of first df in data
first_value <- map(sample_df$data[1], ~ .x$value[1])[[1]]

# Get first value of all dfs in data
first_values <- map(sample_df$data, ~ .x$value[1])

## Test if the data really is triangularly distributed
test <- sample_df$data[[1]]
hist(test$value)

