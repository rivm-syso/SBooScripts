#' @title k_Sedimentation
#' @name k_Sedimentation
#' @description Calculate the rate constant for sedimentation [s-1]
#' @param FRinw Fraction chemical dissolved in water [-]
#' @param VertDistance Compartment depth/height [m]
#' @param DynViscWaterStandard Dynamic viscosity of the fluid matrix
#' @param RadCP Radius of the Coarse natural particle [m]
#' @param RhoCP Density of the Coarse natural particle [m]
#' @param SettlingVelocity Settling velocity of particulate species [m.s-1]
#' @param SubCompartName Name of relevant subcompartment for which k_Sedimentation is being calculated
#' @param ScaleName Name of relevant scale for which k_Sedimentation is being calculated
#' @param SpeciesName Name of relevant species (Molecular or particulate) for which k_Sedimentation is being calculated
#' @param Test determines if SB4-Excel approach is taken or enhanced method from R version [boolean]
#' @return k_Sedimentation, the rate constant for sedimentation as first order process
#' @export
k_Sedimentation <- function(FRinw, SettlingVelocity, DynViscWaterStandard,
                            VertDistance, from.RhoCP, from.RadCP, RadS,
                            SpeciesName, SubCompartName, to.SubCompartName, ScaleName, Test){
  if ((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & SubCompartName == "sea" & to.SubCompartName == "marinesediment") {
    return(NA)
  }
  if ((ScaleName %in% c("Regional", "Continental")) & to.SubCompartName == "deepocean") {
    return(NA)
  }
  
  switch(SpeciesName,
          "Molecular" = {
            if (to.SubCompartName == "deepocean") {
              return(NA)
            } 
            if (as.character(Test) == "TRUE") {
              if (to.SubCompartName == "lakesediment") {
                return(NA)
              } else {
                SetlingVelocityCP <- 2.5/(24*3600)
                return(SetlingVelocityCP*(1 - FRinw) / VertDistance)
              }
            }
            SetlingVelocityCP <- f_SetVelWater(radius = from.RadCP,
                                               rhoParticle = from.RhoCP, rhoWater = 998, DynViscWaterStandard) 
            return(SetlingVelocityCP*(1 - FRinw) / VertDistance)
          },
          {
            if (SettlingVelocity <= 0) {
              return(0)
            }
            return(SettlingVelocity/VertDistance)
          }
          
  )
  
}