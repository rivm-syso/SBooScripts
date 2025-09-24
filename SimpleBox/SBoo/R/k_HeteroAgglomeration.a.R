#' @title Heteroagglomeration with aerosols
#' @name k_HeteroAgglomeration.a
#' @description Calculation of the first order rate constant (s-1) for heteroagglomeration of ENPs with natural particles 
#' based on Kulmala et al. (2003) https://doi.org/10.1034/j.1600-0889.2001.530411.x
#' @param to.alpha Attachment Efficiency of ENPs with other particulates, constants [-]
#' @param NumConc_Otherparticle Mass concentration of other particulates [kg.m-3]
#' @param RadS Radius of nanoparticle [m]
#' @param RhoS Density of nanoparticle [kg.m-3]
#' @param RadNuc radius of nucleation mode particle [m]
#' @param RadCOL radius of accumulation mode aerosol particle [m]
#' @param RadCP radius of coarse particulate mode aersol particle [m]
#' @param rho_species density of particle [kg m-3]
#' @param RhoNuc density of nucleation mode aerosol particle [ kg m-3]
#' @param RhoCOL density of accumulation mode aerosol particle [kg m-3]
#' @param RhoCP density of coarse particulate mode aerosol particle [kg m-3]
#' @param radius_Otherparticle Radius of natural particle [m]
#' @param f_Fuchs function describing Fuch's correction factor [-]
#' @param DynViscAirStandard dynamic viscosity of air [kg m-1 s-1]
#' @param NumConcNuc number concentration nucleation mode aerosol particles [# m-3]
#' @param NumConcAcc number concentration accumulation mode aerosol particle [# m-3]
#' @param NumConcCP number concentration coarse particulate mode aerosol particle [# m-3]
#' @param rho_Otherparticle Density (specific weight) of natural particle [kg/m3]
#' @param Matrix type of subcompartment
#' @param to.SpeciesName type of species considered
#' @param Test determines if SB4-Excel approach is taken or enhanced method from R version [boolean]
#' @param Temp Temperature of compartment [K]
#' @param ThermVel thermal veloicty of species [m s-1]
#' @return k_HeteroAgglomeration, the rate constant for 1rst order process: heteroagglomeration [s-1]
#' @export
#'
k_HeteroAgglomeration.a <- function(rad_species, 
                                    RadNuc,
                                    RadCOL,
                                    RadCP,
                                    rho_species, 
                                    RhoNuc,
                                    RhoCOL,
                                    RhoCP, Temp,
                                    DynViscAirStandard,
                                    NumConcNuc, NumConcAcc, NumConcCP,
                                    Matrix,
                                    to.SpeciesName, Test = "FALSE"){
  
  ThermVel <- function(Temp, Radius, Rho){
    kboltz <- constants::syms$k
    ((8*kboltz*Temp)/(pi*fVol(Radius)*Rho))^0.5
  }
  
  f_Fuchs <- function(Diff.P1,
                      Diff.P2,
                      Rad.P1,
                      Rad.P2,
                      Thermvel.P1,
                      Thermvel.P2){
    (1+(4*(Diff.P1+Diff.P2))/((Rad.P1+Rad.P2)*(Thermvel.P1^2+Thermvel.P2^2)^0.5))^-1
  }
  if (as.character(Test) == "TRUE") {
    ThermVelSpecies <- ThermVel(Temp = 285, Radius = rad_species, Rho = rho_species)
  } else {
    ThermVelSpecies <- ThermVel(Temp, Radius = rad_species, Rho = rho_species)
  }
  
  Diffusivity <- f_Diffusivity(Matrix, Temp, DynVisc = DynViscAirStandard, rad_species)
  
  switch(tolower(to.SpeciesName),
         "aggregated" = {
           # for Acc
           DiffAcc <- f_Diffusivity(Matrix, Temp = Temp, DynVisc = DynViscAirStandard, 
                                    rad_species = RadCOL)
           ThermVelAcc <- ThermVel(Temp, Radius = RadCOL, Rho = RhoCOL)
           FuchsAcc <- f_Fuchs (Diff.P1 = Diffusivity, Diff.P2 = DiffAcc,
                                Rad.P1 = rad_species, Rad.P2 = RadCOL,
                                Thermvel.P1 = ThermVelSpecies, Thermvel.P2 = ThermVelAcc)
           
           k_Acc <- FuchsAcc*(4*pi*(RadCOL+rad_species)*(DiffAcc+Diffusivity))*NumConcAcc
           # for Nuc
           DiffNuc <- f_Diffusivity(Matrix, Temp = Temp, DynVisc = DynViscAirStandard, 
                                    rad_species = RadNuc)
           ThermVelNuc <- ThermVel(Temp, Radius = RadNuc, Rho = RhoNuc)
           FuchsNuc <- f_Fuchs (Diff.P1 = Diffusivity, Diff.P2 = DiffNuc,
                                Rad.P1 = rad_species, Rad.P2 = RadNuc,
                                Thermvel.P1 = ThermVelSpecies, Thermvel.P2 = ThermVelNuc)
           
           k_Nuc <- FuchsNuc*(4*pi*(RadNuc+rad_species)*(DiffNuc+Diffusivity))*NumConcNuc
           return(k_Acc + k_Nuc)
         },
         "attached" = {
           DiffOther <- f_Diffusivity(Matrix, Temp = Temp, DynVisc = DynViscAirStandard, 
                                      rad_species = RadCP)
           ThermVelOther <- ThermVel(Temp, Radius = RadCP, Rho = RhoCP)
           Fuchs <- f_Fuchs (Diff.P1 = Diffusivity, Diff.P2 = DiffOther,
                             Rad.P1 = rad_species, Rad.P2 = RadCP,
                             Thermvel.P1 = ThermVelSpecies, Thermvel.P2 = ThermVelOther)
           
           return(Fuchs*(4*pi*(RadCP+rad_species)*(DiffOther+Diffusivity))*NumConcCP)
         },
         return(NA)
  )
}

