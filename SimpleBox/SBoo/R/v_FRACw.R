#'@title FRACw
#'@name FRACw
#'@description Fraction of water in any matrix, 
#' either subFRACw or, when the main matrix, remainder after substracting subFRACs + subFRACa
#'@param subFRACa subfraction of air in a non-air compartment [-]
#'@param subFRACw subfraction of water in a non-water compartment [-]
#'@param subFRACs subfraction of solids in a non-soil, non-sediment compartment [-]
#'@param Matrix type of compartment 
#'@return FRACw
#'@export
FRACw <- function(subFRACa, subFRACw, subFRACs, Matrix){
  if (Matrix == "water") {
    return (1 - subFRACs - subFRACa)
  } else
    return (subFRACw)
}
