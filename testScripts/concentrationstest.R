Volume <-World$fetchData("Volume")
FRACw <- World$fetchData("FRACw")
FRACa <- World$fetchData("FRACa")
Rho <-World$fetchData("rhoMatrix")


accronym_map <- c("marinesediment" = "sd2",
                  "freshwatersediment" = "sd1",
                  "lakesediment" = "sd0", #SB Excel does not have this compartment. To do: can we turn this off (exclude this compartment) for testing?
                  "agriculturalsoil" = "s2",
                  "naturalsoil" = "s1",
                  "othersoil" = "s3",
                  "air" = "a",
                  "deepocean" = "w3",
                  "sea" = "w2",
                  "river" = "w1",
                  "lake" = "w0", 
                  "cloudwater" = "cw")

accronym_map2 <- c("Arctic" = "A",
                   "Moderate" = "M",
                   "Tropic" = "T",
                   "Continental" = "C",
                   "Regional" = "R")

accronym_map3 <- c("Dissolved" = "D", 
                   "Gas" = "G", 
                   "Large" = "P", 
                   "Small" = "A",
                   "Solid" = "S", 
                   "Unbound" = "U")

Volume <- Volume |> mutate(compartment =  paste0(accronym_map[SubCompart], 
                                      accronym_map2[Scale]))
FRACw <- FRACw |> mutate(compartment =  paste0(accronym_map[SubCompart], 
                                               accronym_map2[Scale]))
FRACa <- FRACa |> mutate(compartment =  paste0(accronym_map[SubCompart], 
                                               accronym_map2[Scale]))
Rho <-  Rho |> mutate(compartment =  paste0(accronym_map[SubCompart]))

# List of columns in A that need transformation
AConc <- A
columns_to_transform <- names(AConc)
# Loop through each column in A and calculate concentrations
for (col in columns_to_transform) {
  # Extract the compartment prefix (e.g., 'aA' from 'aAS')
  compartment <- substr(col, 1, 2)
  
  # Find the corresponding volume from Volume dataframe
  volume <- Volume$Volume[Volume$compartment == compartment]
  
  # Check if volume was found
  if (length(volume) == 1) {
    # Divide the column values by the volume
    AConc[[col]] <- AConc[[col]] / volume
  } else {
    warning(paste("Volume not found for compartment", compartment))
  }
}

AConc_soil_names <- grep("^s[123]", names(AConc), value = TRUE)
AConc_soil <- AConc[, AConc_soil_names]
RhoWater <- Rho |> filter(SubCompart == "river")

 #need both water and soil/sediment
f_Soil.wetweight <- function(AConc.soil, # in kg/m3 soil or sediment
                             Fracw,
                             Fraca,
                             RHOsolid){
  AConc.soil*1000/(FRACw*RhoWater+(1-FRACw-FRACa)*Rho) # in g/kg (wet) soil
}

# Step 1: Match and Extract Parameters
compartment_prefixes_scale <- substr(names(AConc_soil), 1, 3)
compartment_prefixes <- substr(names(AConc_soil), 1, 2)
print(compartment_prefixes)

# Find corresponding FRACw, FRACa, and Rho values
FRACw_values <- FRACw$FRACw[match(compartment_prefixes_scale, FRACw$compartment)]
print(FRACw_values)
FRACa_values <- FRACa$FRACa[match(compartment_prefixes_scale, FRACa$compartment)]
print(FRACa_values)
Rho_values <- Rho$rhoMatrix[match(compartment_prefixes, Rho$compartment)]
print(Rho_values)
# Retrieve RhoWater value
RhoWater_value <- RhoWater$rhoMatrix

# Step 2: Define the function f_Soil.wetweight
f_Soil.wetweight <- function(AConc.soil, Fracw, Fraca, RHOsolid) {
  AConc.soil * 1000 / (Fracw * RhoWater_value + (1 - Fracw - Fraca) * RHOsolid)
}

# Step 3: Apply the function to AConc_soil
AConc_soil_adjusted <- AConc_soil

for (col in 1:ncol(AConc_soil)) {
  current_col <- AConc_soil[, col]
  current_Fracw <- FRACw_values[col]
  current_Fraca <- FRACa_values[col]
  current_Rho <- Rho_values[col]
  
  AConc_soil_adjusted[, col] <- f_Soil.wetweight(current_col, current_Fracw, current_Fraca, current_Rho)
}

# Assigning column names to AConc_soil_adjusted
colnames(AConc_soil_adjusted) <- colnames(AConc_soil)
print(AConc_soil_adjusted)
