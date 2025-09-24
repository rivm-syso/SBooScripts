#' @title Volume of the SubCompartment
#' @name Volume
#' @param VertDistance height or depth for subcompartments below the horizon [m]
#' @param Area area of the compartment [m2]
#' @param FRACcldw fraction of cloudwater [-]
#' @param SubCompartName subcompartment considered
#' @return Volume
#' @export
Volume <- function (VertDistance, Area, FRACcldw, SubCompartName){
  
  if(SubCompartName == "air"){
    VertDistance * Area * (1-FRACcldw)
  } else if(SubCompartName == "cloudwater") {
    VertDistance * Area * FRACcldw
  } else 
    VertDistance * Area 
}
