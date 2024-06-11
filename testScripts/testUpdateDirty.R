source("baseScripts/initWorld_onlyParticulate.R")
# Retrieve the list of modules
allves <- World$moduleList

# Create the data frame with variable names and distribution details
vnamestrial <- data.frame(
  vnames = c("AreaSea", "FRACa"),
  distNames = c("normal", "normal"), 
  secondPar = c(3, 5)
)

# Fetch the base data for the variables
baseVars <- lapply(vnamestrial$vnames, World$fetchData)
names(baseVars) <- vnamestrial$vnames
n = 5
# Assuming 'n' and 'unif01LHS' are defined and 'vnamesDistSD' is correctly set
for (i in 1:n) {
  for (vari in 1:nrow(vnamestrial)) {
    vname <- vnamestrial$vnames[vari]
    Updated <- baseVars[[vname]]
    
    # Transform uniform to scaling factor 
    scalingF <- switch(vnamestrial$distNames[vari],
                       "normal" = rnorm(1, mean = 1, sd = vnamestrial$secondPar[vari]),
    )
    
    # Add the scaling factor to the data frame
    vnamestrial[vnamestrial$vnames == vname, as.character(i)] <- scalingF
    Updated[, vname] <- scalingF * Updated[, vname]
    
    # Set the updated values in the World object
    asParam <- list(Updated)
    names(asParam) <- vname
    do.call(World$SetConst, asParam)
  }
  
  # Update the world with the new values
  World$UpdateDirty(vnamestrial$vnames)
}

print(World$fetchData("AreaSea"))
 