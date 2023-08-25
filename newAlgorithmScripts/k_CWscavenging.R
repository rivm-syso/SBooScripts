#' @title Cloud water scavenging coefficients as function of particle size and density
#' @name k_CWscavenging
#' @description a description follows .. Joris? based on Wang, X.; Zhang, L.;
#'   Moran, M.D. Uncertainty assessment of current size-resolved
#'   parameterizations for below-cloud particle scavenging by rain. Atmos. Chem.
#'   Phys. Discuss. 2010, 10, 2503–2548
#' @param rho_species particle density []
#' @param rad_species particle radius []
#' @param to.rhoMatrix density of cloud water []
#' @param rhoMatrix density of air []
#' @param DynVisc dynamic viscosity of air []
#' @param to.DynVisc dynamic viscosity of (cloud) water []
#' @param Temp tempreature [oC]
#' @param 
#' @return k_CWscavenging
#' @export
k_CWscavenging <- function(RAINrate, FRACtwet,
                           rad_species, rho_species, to.rhoMatrix, rhoMatrix,
                           DynVisc, to.DynVisc,
                           Temp,
                           SubCompartName){
  
  if(SubCompartName != "air") return(NA)
  
  # variables for calculation of 3 types of collection mechanisms (Gravitational, Intercept, Brownian)
  
  rad_RainDrop <- f_RadRain(RAINrate, FRACtwet)
  
  Settvel.Particle.a <- f_SettlingVelocity(rad_species, rho_species, 
                                         matrix.Rho = rhoMatrix, DynVisc=DynVisc,
                                         Matrix="air")
  Settvel.Particle.cw <- f_SettlingVelocity(rad_species=rad_RainDrop, rho_species=to.rhoMatrix, 
                                          matrix.Rho=rhoMatrix, DynVisc=DynVisc,
                                          Matrix="air")
  Relax.Particle.a <- ((rho_species-rhoMatrix)*(2*rho_species)^2*f_Cunningham(rad_species))/(18*DynVisc)
  
  StokesNumber.Particle.a  =(2*Relax.Particle.a*(Settvel.Particle.cw-Settvel.Particle.a))/(2*rad_RainDrop)
  
  ReyNumber.cw =((2*rad_RainDrop)*Settvel.Particle.cw*rhoMatrix)/(2*DynVisc)
  
  SchmidtNumber.Particle.a = DynVisc/(to.rhoMatrix*
                                            f_Diffusivity(Compartment, Temp, 
                                                         DynVisc, rad_species, 
                                                         Cunningham = f_Cunningham(rad_species)))
  
  CritStokesNumb.cw = ((1.2+(1/12)*log(1+ReyNumber.cw))/(1+log(1+ReyNumber.cw)))
  
  # calculation of graviational collection efficiency
  if(StokesNumber.Particle.a>CritStokesNumb.cw){
    Grav.a.cw = ((StokesNumber.Particle.a-CritStokesNumb.cw)/(StokesNumber.Particle.a-CritStokesNumb.cw+2/3))^(3/2)
  } else Grav.a.cw = 0
  
  # calculation of Interception collection efficiency
  Intercept.a.cw <- 4*(rad_species/rad_RainDrop)*
    ((DynVisc/to.DynVisc)+(1+2*ReyNumber.cw^0.5*(rad_species/rad_RainDrop)))
  
  # calculation of Brownian collection efficiency
  
  Brown.a.cw <- (4/(ReyNumber.cw*SchmidtNumber.Particle.a))*
    (1+0.4*(ReyNumber.cw^0.5*SchmidtNumber.Particle.a^(1/3))+0.16*(ReyNumber.cw^0.5*SchmidtNumber.Particle.a^0.5))
  #from f_Brown??  ((2*getConst("r")*Temp)/(3*viscosity))*(from.radius+radOther )^2/(from.radius*radOther)
  
  Total <- Brown.a.cw + Intercept.a.cw + Grav.a.cw
  
  # RAINrate.wet <- RAINrate/FRACtwet
  
  (3/2)*(fTotal*RAINrate)/(2*rad_RainDrop)
  
}

#init default core (World) with classic states, and classic kaas
substance <- "nAg_10nm"  #use a nano material, otherwise it only encounters Molecular
excelReference <- "data/20210331 SimpleBox4nano_rev006.xlsx"
source("baseScripts/initTestWorld.R")

lapply(c("rho_species", "rad_species"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})
World$fetchData("Temp")

World$fetchData("rhoMatrix")
#World$fetchData("rho")
World$fetchData("rad_species")
World$fetchData("NaturalRho")

#calculation of kaas is by executing a process
testClass <- World$NewProcess("k_CWscavenging")
testClass$execute(list())
World$allFromAndTo("k_CWscavenging")

debug(testClass$execute)
testClass$execute(debugAt = list()) #an empty list always triggers
#testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
