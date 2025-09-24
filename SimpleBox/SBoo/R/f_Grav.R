#' @title Gravitational impaction collision frequency coefficient (20181102)
#' @name fGrav
#' @description Collission frequency of ENPs with other particulates due to Gravitational or Intertial impaction in s-1 for heteroagglomeration
#' @param DynViscWaterStandard Dynamic viscosity of liquid  (fraction of) compartment [kg.m-1.s-1]
#' @param radius Radius of nanoparticle [m]
#' @param rho Density of nanoparticle [kg.m-3]
#' @param radius_Otherparticle  Radius of Other particle [m]
#' @param rho_Otherparticle Density (specific weight) of natural particle [kg/m3]
#' @return fGrav [s-1]
#' @export
f_Grav <- function(radiusParticle,rhoParticle,
                   radius_Otherparticle ,rho_Otherparticle,
                   rhoFluid, DynViscWaterStandard){

  SetVel <- f_SetVelWater(radius=radiusParticle, 
                          rhoParticle=rhoParticle, 
                          rhoWater=rhoFluid, 
                          DynViscWaterStandard)
  
  SetVelOther <- f_SetVelWater(radius=radius_Otherparticle, 
                               rhoParticle=rho_Otherparticle, 
                               rhoWater=rhoFluid, 
                               DynViscWaterStandard)

  
  pi*(radiusParticle+radius_Otherparticle )^2*abs(SetVel-SetVelOther)
}
