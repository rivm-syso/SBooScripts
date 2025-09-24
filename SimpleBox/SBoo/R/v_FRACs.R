#'@title FRACs
#'@name FRACs 
#'@description fraction of solid in any matrix 
#' either subFRACs or, when the main matrix, remainder after substracting subFRACa + subFRACw
#'@param subFRACa fraction of air in a non-air subcompartment [-]
#'@param subFRACw fraction of water in a non-water subcompartment [-]
#'@param subFRACs fraction of solids in a non-soil, non-sediment compartment [-]
#'@param Matrix type of compartment
#'@return FRACs 
#'@export
FRACs <- function(subFRACa, subFRACw, subFRACs, Matrix){
  if (Matrix %in% c("soil", "sediment")) {
    if (Matrix == "sediment") subFRACa <- 0
    return (1 - subFRACw - subFRACa)
  } else
    return (subFRACs)
}

