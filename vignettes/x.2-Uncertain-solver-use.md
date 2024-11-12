Uncertain solver use
================
Anne Hids, Valerie de Rijk, Joris Quik, Jaap Slootweg
2024-09-02

## Initialize World

First, we will load the neccesary packages and initialize the world for
molecules

``` r
library(lhs)
library(tidyverse)

source("baseScripts/initWorld_onlyMolec.R")
```

## Use of the steady state uncertain solver

There are two ways to use the UncertainSolver:

1.  With uncertain variables and variable emissions.
2.  With uncertain variables but one set of emissions

Method 1 will be explained first, then method 2.

### Use the solver with uncertain variables and variable emissions

#### Create tibble with samples for uncertain variables

The first step is to determine the number of uncertain variables, the
number of compartments that have emissions and the number of runs.

``` r
n_vars <- 3 # The number of variables you want to create a distribution for
n_comps <- 2 # The number of compartments that have emissions
n_samples <- 10 # The number of samples you want to pull from the distributions for each variable

n_lhs <- n_vars + n_comps # Total number of vectors to create with latin hypercube sampling (lhs)

lhs_samples <- randomLHS(n_samples, n_lhs) # Generate numbers between 0 and 1 using lhs

# Separate the samples for the variable and emission distributions from each other:
lhs_samples_vars <- lhs_samples[, 1:n_vars] 
lhs_samples_emis <- lhs_samples[, (n_vars + 1):ncol(lhs_samples)]
```

The lhs samples are pulled from a uniform distribution between 0 and 1.
So these numbers have to be scaled to the real values you want to use,
and it is possible to transform this uniform distribution to a different
distribution. In this example, a triangular distribution will be used.

Define triangular distribution function:

``` r
triangular_cdf_inv <- function(u, a, b, c) {
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}
```

##### Prepare variable samples

Now we are ready to prepare the variable data and define the min, max
and mode of the distribution for each variable.

In this example the following three variables are used:

1.  Area for regional sea
2.  Area for regional river
3.  Erosion of agricultural soil

In the chunk below, the name, scale, subcompartment, min, max and mode
are defined for each variable.

``` r
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
```

Now this data needs to be combined into a tibble, and the function for
the triangular distribution written earlier is applied to the tibble.
The result is a nested tibble, containing the name, scale and
subcompartment for each variable, and the sample data is nested.

``` r
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
```

##### Prepare emission data

In this example, we will take a steady state emission data frame as the
starting point for creating the triangular distributions. You could also
directly enter the min, max and mode values if you have them.

``` r
# Create the steady state emission dataframe
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 
```

Now that the emission data frame is made, we can scale the samples we
took earlier to the triangular distribution just like we did for the
variables.

``` r
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
```

#### Solve

``` r
World$NewSolver("UncertainSolver")
solved <- World$Solve(emissions, needdebug = F, sample_df)
```

### Use solver with uncertain variables but one set of emissions

#### Create tibble with samples for uncertain variables

Because we only use one set of emissions, we only have to create samples
for the number of variables we want to use.

``` r
n_vars <- 3 # The number of variables you want to create a distribution for
n_samples <- 10 # The number of samples you want to pull from the distributions for each variable

lhs_samples <- randomLHS(n_samples, n_vars) # Generate numbers between 0 and 1 using lhs
```

The rest of the steps to create the dataframe with samples are the same
as for method 1.

``` r
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
```

#### Prepare emission data

When using this method, all we need is one steady state dataframe with
emissions.

``` r
# Create the steady state emission dataframe
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 
```

#### Solve

``` r
World$NewSolver("UncertainSolver")
solved <- World$Solve(emissions, needdebug = F, sample_df)
```
