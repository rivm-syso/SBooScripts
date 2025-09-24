#'@title Fraction of chemical in solid phase soil
#'@name FRins
#'@description Fraction of chemical in solid phase soil (relevant to Molecular species)
#'@param Kp soil/water partitioning coefficient [-]
#'@param SUSP Concentration suspended matter in water [mg.L-1]
#'@param COL Concentration of colloidal organic matter in water [mg.L-1]
#'@param KpCOL Colloidal organic matter/water partition coefficient [L.kg-1]
#'@param Matrix Type of compartment matrix (soil, water, sediment or air)
#'@param FRACa Fraction air in compartment [-]
#'@param FRACw Fraction water in compartment [-]
#'@param FRACs Fraction solids in compartment [-]
#'@param Kacompw Dimensionless air/water partitioning coefficient of original species at compartment temperature [-]
#'@param FRorig_spw Fraction original species in porewater of soil [-]
#'@param RHOsolid Mineral DENSITY sediment and soil [kg.m-3]
#'@return FRins
#'@export
FRins <- function(Kp, SUSP, COL, KpCOL,
                FRACw, FRACa, FRACs, Kacompw, 
                FRorig_spw, all.rhoMatrix, Matrix){
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
  switch(Matrix,
         "soil" =  
           FRACs/(FRACa*(Kacompw*FRorig_spw)/(Kp*RHOsolid/1000)+FRACw/(Kp*RHOsolid/1000)+FRACs),
         return(NA)
  )
}
