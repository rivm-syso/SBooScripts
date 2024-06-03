library(lhs)
library(ggplot2)
source("baseScripts/fakeLib.R")

# to run the script with another selection of substance / excel reference,
# set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
if (!exists("substance")) {
  substance <- "microplastic"
}

# The script creates the "ClassicStateModule" object with the states of the classic 4. excel version.
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

# with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# We are interested in the particulate species only, so no need to filter like in the Molecular initWorld

# To proceed with testing we set

if (is.na(World$fetchData("pKa"))) {
  warning("pKa is needed but missing, setting pKa=7")
  World$SetConst(pKa = 7)
}

if (World$fetchData("ChemClass") == "") {
  warning("ChemClass is needed but missing, setting to particle")
  World$SetConst(ChemClass = "particle") # ????
}

if (is.na(World$fetchData("Pvap25"))) {
  warning("Pvap is missing but not used, setting constant")
  World$SetConst(Pvap25 = 1e-7)
}
World$SetConst(DragMethod = "Default")
World$SetConst(Shape = "Sphere")
# World$SetConst(RadS = particle_size)
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

# call the particulate processes
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Plastic)]
sapply(paste("k", ParProcesses, sep = "_"), World$NewProcess)
unique(World$kaas$process)
# add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)

# derive needed variables
World$VarsFromprocesses()

unique(World$kaas$process)

World$SetConst(Ksw = 47500) # default, not used for particle behavior")

World$UpdateKaas()
World$fetchData("SettlingVelocity")

unique(World$kaas$process)

lower_bound <- 1
upper_bound <- 20000
n_samples <- 10

# Generate Latin Hypercube Samples for particle size
set.seed(121)  # Setting seed for reproducibility
lhs_samples <- randomLHS(n_samples, 1)

particle_sizes <- lower_bound + (upper_bound - lower_bound) * lhs_samples[, 1]

# Initialize a list to store results
results <- list()

# Loop through each particle_size value
for (i in seq_along(particle_sizes)) {
  size <- particle_sizes[i]
  # Update the particle_size parameter
  World$SetConst(RadS = size)
  RadS <- World$fetchData("RadS")
  print(RadS)
  
  source("baseScripts/fakeLib.R")
  
  
  World$VarsFromprocesses()
  
  # Call the update function
  World$UpdateKaas(mergeExisting = F)
  
  # Fetch the SettlingVelocity data
  settling_velocity <- World$fetchData("SettlingVelocity")
  print(settling_velocity)
  
  # Convert to data frame and add the particle size
  settling_velocity_df <- as.data.frame(settling_velocity)
  settling_velocity_df$particle_size <- size
  
  # Store the result in the list
  results[[i]] <- settling_velocity_df
  rm(settling_velocity_df, settling_velocity)
  gc()
}
# Combine all results into a single data frame
combined_results_df <- do.call(rbind, results)

# Filter the data based on specific conditions
filtered_results <- subset(combined_results_df, Scale == "Moderate" & SubCompart == "air" & Species == "Solid")
rad_species <- World$fetchData("rad_species")
# Create the plot
ggplot(filtered_results, aes(x = particle_size, y = SettlingVelocity)) +
  geom_point() +
  labs(title = "Settling Velocity vs Particle Size",
       x = "Particle Size",
       y = "Settling Velocity") +
  theme_minimal()

