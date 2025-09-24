#' @title Rate constant for wet deposition of particulate species due to rain
#' @name k_WetDeposition
#' @description Calculation of the first order rate constant for particle deposition from cloudwater compartment to the soil or water surface [s-1]
#' @param to.AREA Surface area of receiving land or water compartment [m2]
#' @param from.VOLUME Volume of cloudwater compartment [m3]
#' @param RAINrate average rain rate [m s-1]
#' @export
k_WetDeposition <- function (to.Area, from.Volume, RAINrate){
  
  (RAINrate* to.Area)/from.Volume
}

