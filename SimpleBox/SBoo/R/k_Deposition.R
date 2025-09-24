#'@title k_Deposition
#'@name k_Deposition 
#'@description Deposition process for molecular species through dry aerosol deposition,
#' wet aerosol and gas washout. Approach is based on Jolliet and Hauschild (2006) https://doi.org/10.1021/es049913+
#'@param FRingas fraction of species in gaseous phase, see FRingas [-]
#'@param VertDistance Vertical distance of the compartment [m]
#'@param RAINrate average rain rate [m/s]
#'@param twet average duration of dry periods [s]
#'@param tdry average duration of wet periods [s]
#'@param COLLECTeff collection efficiency of aerosols by raindrops [-]
#'@param AEROSOLdeprate deposition velocity of aerosol particles [m/s]
#'@param Kacompw air water partitioning coefficient [-]
#'@param FRorig Fraction original species in water or porewater, see FRorig [-]
#'@param FRinaerw Fraction original species in aerosol water, see FRaerw [-]
#'@param FRinaers Fraction original species in aerosol solids, see FRaers[s]
#'@param SpeciesName Name of the species the function is applied to
#'@param otherKair other k-flows within the air domain aggregated (this process is calculated less)
#'@param AREAFRAC Fraction of area compartment relative to the whole surface area of this scale (systemarea) [-]
#'@param RAINrate Average precipitation #[m/s]
#'@param VertDistance Mixing depth air compartment #[m]
#'@param OtherkAir correction term for processes other than deposition affecting the air compartment, see OtherKair [s-1]
#'@param Area area of the compartment [-]
#'@param Kaers aerosol solid air partitioning coefficient  [-]
#'@param Kaerw aerosol water air partitioning coefficient [-]
#'@return Transfer rate constant gaseous species air to soil or water #[s-1]
#'@export
k_Deposition <- function(FRingas, 
                         VertDistance,
                         RAINrate,
                         twet ,
                         tdry ,
                         COLLECTeff, 
                         AEROSOLdeprate , 
                         Kacompw,
                         FRorig,
                         SpeciesName,
                         OtherkAir,
                         to.Area,
                         from.Area,
                         Kaers,
                         Kaerw,
                         FRinaerw,
                         FRinaers){ 
  
  if (SpeciesName %in% c("Molecular")) {
    
    DRYDEPaerosol <- AEROSOLdeprate*(FRinaerw+FRinaers)
    AerosolWashout <- FRinaers*(tdry+twet)/twet*COLLECTeff*RAINrate
    GasWashout <- FRingas*(tdry+twet)/twet*RAINrate/(Kacompw*FRorig) # (Kacompw * GRorig) == Aerosol collection efficiency
    
    kdry <- DRYDEPaerosol/VertDistance  + OtherkAir
    
    kwet <- (AerosolWashout+GasWashout)/VertDistance + OtherkAir
    
    
    MeanRemAir <- ((1/kdry)*tdry/(tdry+twet)+(1/kwet)*twet/(tdry+twet)-
                     ((1/kwet-1/kdry)^2/(tdry+twet))*
                     (1-exp(-kdry*tdry))*(1-exp(-kwet*twet))/(1-exp(-kdry*tdry-kwet*twet)))^-1
    
    MeanDep <- (MeanRemAir - OtherkAir) * (to.Area/from.Area)
    
    return( MeanDep ) # the gasabs here is for the two compartments for which this function is run (air to soil/water)
    
  } else { # 
    return(NA)
  }
}
