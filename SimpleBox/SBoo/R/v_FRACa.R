#'@title FRACa
#'@name FRACa 
#'@description Calculates the total air fraction in the considered system.
#'either subFRACa or, when the main matrix, remainder after substracting subFRACs + subFRACw
#'@param subFRACa subfraction of air in a non-air compartment [-]
#'@param subFRACw subfraction of water in a non-water compartment [-]
#'@param subFRACs subfraction of solids in a non-soil, non-sediment compartment [-]
#'@param Matrix type of compartment 
#'@return FRACa 
#'@export
FRACa <- function(subFRACa, subFRACw, subFRACs, Matrix) {
  if (Matrix == "air") {
    return (1 - subFRACw - subFRACs)
  } else if (Matrix == "sediment") {
    return (0)
  } else {
    return (subFRACa)
  }
}


