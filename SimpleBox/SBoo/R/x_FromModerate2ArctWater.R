#' @title Mixing of upper and deeper sea water layers (w2 and w3)
#' 
#' @description
#' Moderate scale waters flow into Arctic scale through surface ocean currents based on a set ocean current.
#' 
#' @param OceanCurrent current implemented in the ocean [m3.s-1]
#' @param SubCompartName name of the subcompartment of the box at hand
#' @param ScaleName name of the scale of the box at hand
#' @return Flow [m3.s-1]
#' @export
#' 
x_FromModerate2ArctWater <- function ( OceanCurrent, SubCompartName, ScaleName) {
  switch (SubCompartName,
          "sea" = {OceanCurrent},
          "deepocean" = {return(0)},  #TODO add 0 in data not in code.
          NA
  )
  
}
