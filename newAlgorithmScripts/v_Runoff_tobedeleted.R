#' @title Runoff
#' @name Runoff
#' @description The runoff is from soil. Normally this runs into a river, but, 
#' as there are no rivers modelled in the global scales, it is directed to the sea immediately there. 
#' Basically, it's a flow, but for this reason, modelled as a variable
#' @param FRACrun
#' @param Area area of the subcompartment within the scale
#' @param RAINrate is in mm/yr, SI-ed here
#' @param Compartment Only runoff for Compartment == "soil" 
#' @return rain water runoff from soils
#' @export
Runoff <- function (FRACrun, Area, RAINrate, Compartment){
  if (Compartment == "soil") {
    return(FRACrun * Area * RAINrate)
  } else {
    return(NA)
  }
}
