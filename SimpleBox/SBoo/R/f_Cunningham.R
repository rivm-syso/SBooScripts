#' @title Cunningham
#' @name fCunningham
#' @description Collision frequency of ENPs with other particulates due to Gravitational or Inertial impaction for heteroagglomeration.
#' Experimental values for the empirical constants Alpha (1.142), Beta (0.558), and Gamma (0.999) from Allan and Raab 1985 (Schneider and Voigt H2)
#' The default for "mean free path in air" is 66*10^-92, based on Seinfeld, and Pandis (2006)
#' @param rad_species radius of the heteroagglomerates, calculated in v_rad_species [m]
#' @return Cunningham [-]
#' @export
f_Cunningham <- function(rad_species){
  
  Knudsen <- (66*10^-9)/(rad_species) 
  
  1+Knudsen*(1.142+0.558*exp(-0.999/Knudsen))
}
