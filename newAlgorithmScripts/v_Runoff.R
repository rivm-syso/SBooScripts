#' @title Runoff flow from soil to water
#' @name Runoff
#' @description The runoff is from soil to water. Normally this runs into a river, but, 
#' as there are no rivers modelled in the global scales, it is directed to the sea immediately there. 
#' Basically, it's a flow, but for this reason, modelled as a variable. IN order to also use it for k_runoff and x_ContRiver2Reg.
#' @param FRACrun volume fraction of precipitation on regional and 
#' continental natural, agricultural and other soil run off to surface water [-] 
#' @param Area area of the subcompartment within the scale
#' @param RAINrate Precipitation for each subcompartment [m/s]
#' @param Compartment Only runoff for Compartment == "soil" 
#' @return Rain water runoff from soils [m3/s]
#' @export
Runoff <- function (FRACrun, Area, RAINrate, Compartment){
  if (Compartment == "soil") {
    return(FRACrun * Area * RAINrate)
  } else {
    return(NA)
  }
}
