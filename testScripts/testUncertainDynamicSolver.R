library(lhs)
library(tidyverse)

#create World as SBcore
source("baseScripts/initWorld_onlyMolec.R")

##### Solve with single emission df example

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
World$NewSolver("UncertainDynamicSolver")
solved_emis_df <- World$Solve(emissions, sample_df, tmax = tmax, needdebug = F)

conc <- World$GetConcentration()

# Access one solution df
sol1 <- solved_emis_df$Mass[[1]]

##### Solve with one funlist as input 

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
solved_funlist <- World$Solve(funlist, sample_df, tmax = tmax, needdebug = F)

##### Solve with nested emission dataframe 

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

# Define the names of the uncertain variables
comp3Name <- "w1RU"

comp3 <-  emissions |>
  filter(Abbr == comp3Name)

# Set the parameters for the triangular distribution
comp3$a <- comp3$Emis*0.7    # Minimum value
comp3$b <- comp3$Emis*1.3    # Maximum value
comp3$c <- comp3$Emis        # Mode (peak)

comp3 <- comp3 |>
  select(-Emis)

params <- rbind(comp1, comp2, comp3)

emis_df <- params

# Transform each LHS sample column to the corresponding triangular distribution
for (i in 1:nrow(params)) {
  a <- params$a[i]
  b <- params$b[i]
  c <- params$c[i]
  
  samples <- triangular_cdf_inv(lhs_samples_emis[, i], a, b, c)
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  emis_df$Emis[[i]] <- new_data
}

emis_df <- emis_df |>
  select(Abbr, Timed, Emis)

World$NewSolver("UncertainDynamicSolver")
solved_nested_emis_df <- World$Solve(emis_df, sample_df, tmax = tmax, needdebug = F)

##### Solve with nested tibble containing approxfuns 

fun_tibble <- tibble(
  Abbr = character(),
  EmisFun = list(),
  RUN = integer()
)

for(i in 1:nrow(lhs_samples_emis)){
  fun_df <- emis_df |>
    select(-Emis)
  print(i)
  fun_df$Emis <- map(emis_df$Emis, ~ .x$value[i])
  
  SBEmissions3 <- 
    fun_df |> 
    group_by(Abbr) |> 
    summarise(n=n(),
              EmisFun = list(
                approxfun(
                  data.frame(Timed = c(0,Timed), 
                             Emis=c(0,Emis)),
                  rule = 2) # Change to rule 1:1 for no extrapolation
              )
    ) |>
    select(-n)
  
  SBEmissions3$RUN <- i
  
  fun_tibble <- rbind(fun_tibble, SBEmissions3) |>
    filter(!is.na(RUN))
}

final_fun_tibble <- fun_tibble |>
  group_by(Abbr) |>
  summarize(Funlist = list(EmisFun))

# Solve
World$NewSolver("UncertainDynamicSolver")
solved_nested_funlist<- World$Solve(final_fun_tibble, sample_df, tmax = tmax, needdebug = F)


