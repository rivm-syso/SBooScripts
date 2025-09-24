#' @title k_Degradation
#' @name k_Degradation
#' @description calculate k for degradation, based on observations from Wania & Daly (2002) https://doi.org/10.1016/S1352-2310(02)00693-3
#' @param FRingas fraction of original species in gas phase, see FRingas [-1]
#' @param KdegDorC calculated degradation rate constant, see KdegDorc [s-1]
#' @param C.OHrad OH radical concentration specific to compartment, based on Wania & Daly (2002)
#' @param C.OHrad.n general OH radical concentration, based on Wania & Daly (2002)
#' @param Tempfactor Temperature correction rate air, constant 
#' @param BACTcomp concentration bacteria in considered compartment [CFU mL -1]
#' @param BACTtest concentration bacteria in test water [CFU mL -1]
#' @param Matrix compartment type 
#' @param SpeciesName name of the considered species 
#' @param SubCompartName name of the subcompartment 
#' @param ScaleName name of the considered scale
#' @return Degradation rate constant for molecular species
#' @export
k_Degradation <- function(FRingas, KdegDorC, C.OHrad.n, C.OHrad, 
                         Tempfactor,
                          FRinw, BACTtest,BACTcomp,
                          Matrix, SpeciesName, SubCompartName, ScaleName, Test, kdis = NA) {
  # exclusions of process:
  if (((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & (SubCompartName == "freshwatersediment" | 
                                                            SubCompartName == "lakesediment" |
                                                            SubCompartName == "lake" |
                                                            SubCompartName == "river" |
                                                            SubCompartName == "agriculturalsoil"|
                                                            SubCompartName == "othersoil")) | 
      (ScaleName %in% c("Regional", "Continental")) & (SubCompartName == "deepocean" )) {
    return(NA)
  }
    
  if (SpeciesName %in% c("Molecular")) {
    
    switch(Matrix,
           "air" =   {
             FRingas * KdegDorC * (C.OHrad / C.OHrad.n) * Tempfactor
           },
           "soil" = {
             Tempfactor*KdegDorC
           },
           "sediment" = {
             Tempfactor*KdegDorC
           },
           "water" = {
             Tempfactor*KdegDorC*(BACTcomp/BACTtest)*FRinw
           }
           
    )
  } else { # Particulate
    
    if (as.character(Test) == "TRUE"){
      switch(Matrix,
             "air" =   {
               
               Tempfactor*KdegDorC + kdis # not corrected for temperature or other aspects
             },
             "soil" = {
               Tempfactor*KdegDorC + kdis # not corrected for temperature or other aspects
             },
             "sediment" = {
               
               Tempfactor*KdegDorC + kdis # not corrected for temperature or other aspects
             },
             "water" = {
               Tempfactor*KdegDorC + kdis # not corrected for temperature or other aspects
             }
      )
    }
    
    else

    switch(Matrix,
           "air" =   {
             
             Tempfactor*KdegDorC # not corrected for temperature or other aspects
           },
           "soil" = {
             Tempfactor*KdegDorC # not corrected for temperature or other aspects
           },
           "sediment" = {
             
             Tempfactor*KdegDorC # not corrected for temperature or other aspects
           },
           "water" = {
             Tempfactor*KdegDorC # not corrected for temperature or other aspects
           }
    )
  }
  
}
