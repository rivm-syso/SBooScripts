#'@title partial mass transfer coefficient  water and soil to air
#'@name MTC_2a
#'@description Partial mass transfer coefficient from water and soil to air
#'@param WINDspeed Windspeed in compartment/scale [m.s-1]
#'@param MW Molecular weight of compound [kg.mol-1]
#'@param Matrix Matrix/compartment from which the relevant process is taking place
#'@param kdegDorc calculated degradation rate [s-1]
#'@param Tempfactor temperature correction rate air, constant [-]
#'@param ScaleName scale considered
#'@param SubCompartName name of subcompartment considered
#'@return MTC_2a
#'@export
MTC_2a <- function(WINDspeed, MW, Tempfactor, KdegDorC, 
                   Matrix, SpeciesName, ScaleName, SubCompartName){
  if (SpeciesName %in% c("Molecular")) {
  switch(Matrix,
         "water" = {
           if (SubCompartName == "deepocean") return(NA)
           if (ScaleName %in% c("Arctic", "Moderate", "Tropic") & 
               SubCompartName %in% c("lake", "river")) return(NA)
           0.01*(0.0004+0.00004*WINDspeed^2)*((0.032/MW)^(0.5*0.5))
         },
         "soil" = {
           if (ScaleName %in% c("Arctic", "Moderate", "Tropic") & 
               SubCompartName %in% c("othersoil", "agriculturalsoil")) return(NA)
           0.1*Tempfactor*KdegDorC
         }, 
         NA
  )} else return(NA)
}
