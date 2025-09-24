#' @title Function for calculating the Settling Velocity of a particle through water
#' @name f_SetVelWater
#' @description Settling Velocity or terminal Velocity of particles in a fluid medium based on Stokes' theorem (1901)
#' NB SettlingVelocity is a function to be used for all types of partical species, not just nano-species. Therefor it's not a variable defining function.
#' @param rhoParticle Density of particle [kg/m3]
#' @param rhoWater Density of fluid matrix in which particle is present [kg/m3]
#' @param DynViscWaterStandard Dynamic viscosity of water []
#' @param radius Radius of the particle [m]
#' @param GN gravitational force constabt [m2/s]
#' @return f_SetVelWater
#' @export
f_SetVelWater <- function(radius, rhoParticle, rhoWater, DynViscWaterStandard) {
  GN <- constants::syms$gn
  2*(radius^2*(rhoParticle-rhoWater)*GN) / (9*DynViscWaterStandard) #,
  
  # if(2*(radius^2*(rhoParticle-rhoWater)*GN) / (9*DynViscWaterStandard) <= 0) {
  #   return(0)
  # }
  # 
  # else {
  #   return(2*(radius^2*(rhoParticle-rhoWater)*GN) / (9*DynViscWaterStandard))
  # }
}
