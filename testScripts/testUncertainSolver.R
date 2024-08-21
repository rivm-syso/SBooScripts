library(triangle)

#create World as SBcore
source("baseScripts/initWorld_onlyMolec.R")

#Make an emissions data frame
emissions <- data.frame(Abbr = "aRU", Emis = 1000)

########################## Generate numbers for var1 ###########################
# Define the names of the uncertain variables
var1Name <- "Area"

reg1 <- World$fetchData(var1Name)
reg1 <- reg1 |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "sea") 

# Set the parameters for the triangular distribution
Min <- reg1$Area-10000    # Minimum value
Max <- reg1$Area+10000    # Maximum value
Mode <- reg1$Area         # Mode (peak)

# Generate samples from the triangular distribution
set.seed(123)  # Setting seed for reproducibility
n <- 10     # Number of samples
var1samples <- rtriangle(n, a = Min, b = Max, c = Mode)

######################### Generate numbers for var2 ############################
# Define the names of the uncertain variables
var2Name <- "Area"

reg2 <- World$fetchData(var1Name)
reg2 <- reg2 |>
  filter(Scale == "Regional") |>
  filter(SubCompart == "river") 

# Set the parameters for the triangular distribution
Min <- reg2$Area-10000    # Minimum value
Max <- reg2$Area+10000    # Maximum value
Mode <- reg2$Area         # Mode (peak)

# Generate samples from the triangular distribution
set.seed(123)  # Setting seed for reproducibility
n <- 10     # Number of samples
var2samples <- rtriangle(n, Min, Max, Mode)

###################### Make a nested tibble with the data ######################

# Test nested tibble
df <- tibble(
  varname = c(var1Name, var2Name),
  scale = c(reg1$Scale, reg2$Scale),
  subcompart = c(reg1$SubCompart, reg2$SubCompart),
  data = list(tibble(value = var1samples),
              tibble(value = var2samples))
)







