#'@title Kp
#'@name Kp
#'@description subcompartment/water partitioning coefficient
#'@param FRorig, fraction of species in its original form [-]
#'@param KswDorC calculated soil water partitioning coefficient [-]
#'@param RHOsolid density of the solid [kg m-3]
#'@param Corg mass fraction organic carbon in soil/sediment [-]
#'@param CorgStandard standard mass fraction organic carbon in soil/sediment [-]
#'@param ChemClass Chemical class, e.g. neutral or metal
#'@param Matrix the medium, the formula is only applicable to soil and sediment
#'@param ksw.alt 
#'@export
Kp <- function(FRorig, KswDorC, Ksw.alt, all.rhoMatrix, Corg, CorgStandard, Matrix, ChemClass){
  if (Matrix %in% c("soil", "sediment","water")) {
    RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
    return(
      switch (ChemClass,
        "acid" = (FRorig*KswDorC + (1-FRorig)*Ksw.alt) * (1000 / RHOsolid / CorgStandard) * Corg,
        "base" = (FRorig*KswDorC + (1-FRorig)*Ksw.alt) * (1000 / RHOsolid / CorgStandard) * Corg,
        {(FRorig*KswDorC) * (1000 / RHOsolid) * (Corg / CorgStandard)} #Corg
      )
      
    )
  } else return (NA)
}
