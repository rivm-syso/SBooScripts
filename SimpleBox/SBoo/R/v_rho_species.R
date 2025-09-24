#' @title Rho (density) of species
#' @name rho_species
#' @param SpeciesName Dimension
#' @param SubCompartName Dimension
#' @param RadS nanoparticle radius [m]
#' @param RhoS nanoparticle density [kg/m3]
#' @param Df fractal dimension of combined heteroagglomerate [-]
#' @param RadNuc Nucleation mode aerosol particle radius [m]
#' @param RadAcc Accumulation mode aerosol particle radius [m]
#' @param RhoNuc Nucleation mode aerosol particle  [kg/m3]
#' @param RhoAcc Accumulation mode aerosol particle  [kg/m3]
#' @param NumConcNuc Number concentration of Nucleation mode aerosol particles [#/m3]
#' @param NumConcAcc Number concentration of Accumulation mode aerosol particles [#/m3]
#' @return rho_species, approach to calculate density of species in air or water [kg.m-3]
#' @export
rho_species <- function (SpeciesName, SubCompartName,
                         RhoS, RadS, 
                         RadCOL, RadCP, RhoCOL, RhoCP,
                         RhoNuc, RadNuc, 
                         NumConcNuc, NumConcAcc, Df){
  
  switch (SpeciesName,
          "Nanoparticle" = return (RhoS),
          "Aggregated" ={
            if(SubCompartName == "air") {
              SingleMass <- ((NumConcNuc*(RhoNuc*fVol(RadNuc)+RhoS*fVol(RadS)))+(NumConcAcc*(RhoCOL*(fVol(RadCOL))+RhoS*fVol(RadS)))) /
                (NumConcNuc+NumConcAcc)
              SingleVol <- ((NumConcNuc*(fVol(RadS)+((fVol(RadNuc)))))+(NumConcAcc*(fVol(RadS)+(fVol(RadCOL))))) /
                (NumConcNuc+NumConcAcc)
              return(SingleMass/SingleVol)
            } else {
              SingleMass <- RhoS*fVol(RadS) + RhoCOL*fVol(RadCOL) #Requires update for DF is not 1/3, include matrix mass
              SingleVol <- fVol((RadCOL^3 + RadS^3)^(Df)) 
              return(SingleMass/SingleVol)
            }
          },
          "Attached" = {
            SingleMass <- RhoS*fVol(RadS) + RhoCP*fVol(RadCP) #Requires update for DF is not 1/3, include matrix mass
            SingleVol <- fVol((RadCP^3 + RadS^3)^(Df)) 
            return(SingleMass/SingleVol)
          },
          return(NA)
  )
  
}
