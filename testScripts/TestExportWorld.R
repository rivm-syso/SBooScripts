###################### Step 1: prep for parallel solving
source('baseScripts/initWorld_onlyPlastics.R')

# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

varFuns <- World$makeInvFuns(Example_vars)

# Call the steady state solver
World$NewSolver("SteadyStateSolver")
World$Solve(emissions = NULL, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = 20, ParallelPreparation = T)

rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

##################### Step 2: prep the emissions
source("baseScripts/installRequirements.R")

load("data/Examples/example_uncertain_data.RData")

# Example of an emission dataframe formatted for for use in SimpleBox
example_data <- example_data |>
  select(To_Compartment, `2023`, RUN) |>
  rename("Emis" = `2023`) |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> 
  select(-To_Compartment)

###################### Step 3: load the scaled samples
# Load the Excel file containing example distributions for variablese
#Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

LHSsamples <- readRDS("data/scaledLHSsamples.RData")

###################### Step 4: Solve in parallel

# Divide the emissions and LHS samples over different lists as evenly as possible for parallel solving
nCores <- 3
total_runs <- ncol(LHSsamples)

# Calculate base runs per core and remainder
base_runs_per_core <- total_runs %/% nCores
extra_runs <- total_runs %% nCores

# Initialize a vector to store the number of runs per core
runs_distribution <- rep(base_runs_per_core, nCores)

# Distribute the extra runs over the first few cores
runs_distribution[1:extra_runs] <- runs_distribution[1:extra_runs] + 1

# Split emissions data into chunks based on computed runs_distribution
emis_slices <- list()
start_index <- 1
for (runs in runs_distribution) {
  end_index <- start_index + runs - 1
  emis_slices[[length(emis_slices) + 1]] <- example_data[example_data$RUN %in% (start_index:end_index), ]
  start_index <- end_index + 1
}

# Slice LHS based on runs_distribution
LHS_slices <- list()
start_index <- 1
for (run in runs_distribution) {
  end_index <- start_index + run - 1
  # Ensure we don't exceed the total number of columns in the LHS data
  slice <- LHSsamples[, start_index:min(end_index, total_runs), drop = FALSE]
  colnames(slice) <- colnames(LHSsamples)[start_index:min(end_index, total_runs)]
  LHS_slices[[length(LHS_slices) + 1]] <- slice
  start_index <- end_index + 1
}


library(doParallel)

nSlices <- length(emis_slices)
nCores <- 4

cl <- makeCluster(nCores)
registerDoParallel(cl)

processSlice <- function(i) {
  # Source fakeLib inside each parallel job to ensure full functionality of World
  source("baseScripts/fakeLib.R")
  
  # Load a fresh instance of World to avoid mutability issues
  localWorld <- readRDS("data/World.RData")
  
  # Perform computations using localWorld and functions from fakeLib
  localWorld$Solve(emissions = emis_slices[[i]], 
                   LHSmatrix = LHS_slices[[i]], 
                   nRUNs = length(unique(emis_slices[[i]]$RUN)))
  
  # Create a result list to return
  result_list <- list(
    SliceID = i,
    Masses = localWorld$Masses(),
    Concentrations = localWorld$Concentration(),
    Emissions = localWorld$Emissions(),
    Variables = localWorld$VariableValues()
  )
  
  return(result_list)
}

# Define parallel execution and combine results with rbind
combinedResults <- foreach(i = seq_len(nSlices), 
                           .export = c("LHS_slices", "emis_slices", "source", "readRDS")) %dopar% {
                             processSlice(i)
                           }

stopCluster(cl)

massesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Masses"))
concentrationsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Concentrations"))
emissionsCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Emissions"))
variablesCombined <- do.call(rbind, lapply(combinedResults, `[[`, "Variables"))

Solution <- list(
               Masses = massesCombined,
               Concentrations = concentrationsCombined,
               Emissions = emissionsCombined,
               Variables = variablesCombined)
