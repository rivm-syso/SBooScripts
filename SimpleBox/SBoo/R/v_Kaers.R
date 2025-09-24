#' @title Aerosol solids - air Partition coefficient
#' @name Kaers
#' @description partitioning coefficient between aerosol solids and air [-]
#' @param Corg mass fraction organic carbon in soil/sediment [-]			
#' @param Kaw25 Dimensionless gas/water partitioning coefficient of the original species at 25C [-]			
#' @param RhoCOL density of accumulation mode aerosol particle [kg m-3]
#' @param Matrix type of compartment considered
#' @param Pvap25 vapor pressure of original species at 25 C [Pa]
#' @param MaxPvap  maximum vapor pressure of original species at 25 C [Pa]
#' @param Sol25 water solubility of original species at 25 C [mol.m-3]
#' @param MW molar weight of original species [kg mol-1]
#' @param ChemClass chemical class, see QSAR table 
#' @param Kow octanol water partitioning coefficient [-]
#' @return Kaers
#' @export
Kaers <- function (Kaw25,Kow, Corg, RhoCOL, Matrix,
                   Pvap25, MaxPvap, Sol25, MW, T25, ChemClass) {
  
  if(ChemClass == "particle"){
    return(NA)
  } else {
    
    #easy reading kBolts as R
    R = getConst("r")
  
    if (is.na(Kaw25) || Kaw25 == "NA") {
      Kaw25 <- switch (ChemClass,
                      "metal" = 1E-20,
                      "particle" = 1e-20,
                      max(  (ifelse(Pvap25>MaxPvap,MaxPvap,Pvap25) / (Sol25/MW) ) / (R * T25),
                            1E-20)) #yet another precaution for too small Kaw and too high Pvap25.
    }
    if (is.na(Kow) || Kow == "NA") {
      Kow = 18 
      warning("Kow is NA, default of 18 used!")
    }
    switch(Matrix,
          "air" = 0.54 * (Kow/Kaw25) * Corg * (RhoCOL/1000),
          NA)
  }
}

