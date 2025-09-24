#' @title Brownian motion or kinetic collision frequency coefficient (20181102)
#' @name f_Brown
#' @description Collision frequency of ENPs with other particulates due to Brownian motion (kinetic energy) in s-1 for heteroagglomeration. 
#' formula is based on Lyklema (2005)
#' @param Temp Temperature [K]
#' @param viscosity Dynamic viscosity of liquid (fraction of) compartment [kg.m-1.s-1]
#' @param radius Radius of nanoparticle [m]
#' @param radius_Otherparticle  Radius of Other particle [m]
#' @return fBrown [s-1]
#' @export
f_Brown <- function(Temp,viscosity,radius,radius_Otherparticle){
  
  ((2*constants::syms$k*Temp)/(3*viscosity))*((radius+radius_Otherparticle)^2)/(radius*radius_Otherparticle)
}
