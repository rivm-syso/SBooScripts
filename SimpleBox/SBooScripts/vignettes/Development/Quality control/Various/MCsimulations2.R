library(lhs)
library(ggplot2)
#Initialize fake library
source("baseScripts/fakeLib.R")

if (!exists("substance")) {
  substance <- "microplastic"
}
ClassicStateModule <- ClassicNanoWorld$new("data", substance)
World <- SBcore$new(ClassicStateModule)
World$SetConst(DragMethod = "Default")

lower_bound <- 1
upper_bound <- 20000
n_samples <- 100

#Latin Hypercube Sampling
set.seed(121) # Setting seed for reproducibility
lhs_samples <- randomLHS(n_samples, 1)

particle_sizes <- lower_bound + (upper_bound - lower_bound) * lhs_samples[, 1]

#initialize list 
results <- list()
#loop through particle sizes
for (i in seq_along(particle_sizes)) {
  print(i)
  size <- particle_sizes[i]
  World$SetConst(RadS = size)
  
  World$NewCalcVariable("rad_species")
  World$CalcVar("rad_species")
  
  World$NewCalcVariable("rho_species")
  needs <- World$moduleList[["rho_species"]]$needVars
  # for (aNeed in needs){
  #   print(aNeed)
  #   #print(World$fetchData(aNeed))
  # }
  #RhoS is missing!
  World$CalcVar("rho_species")
  
  World$NewCalcVariable("SettlingVelocity")
  World$CalcVar("SettlingVelocity")
  
  settling_velocity <- World$fetchData("SettlingVelocity")
  #print(settling_velocity)

  settling_velocity_df <- as.data.frame(settling_velocity)
  settling_velocity_df$particle_size <- size
  
  results[[i]] <- settling_velocity_df
  rm(settling_velocity_df, settling_velocity)
  
}

combined_results_df <- do.call(rbind, results)

filtered_results <- subset(combined_results_df, Scale == "Moderate" & SubCompart == "air" & Species == "Solid")

ggplot(filtered_results, aes(x = particle_size, y = SettlingVelocity)) +
  geom_point() +
  labs(title = "Settling Velocity vs Particle Size",
       x = "Particle Size",
       y = "Settling Velocity") +
  theme_minimal()