#'@title Fraction of orginigal species - air, soil, sediment and water
#'@name FRorig
#'@description Fraction original species in air, soil, sediment or water
#'@param pH pH of soil, sediment, water or aerosol water
#'@param pKa Dissociation constant of (conjugated) acid (default = 7)
#'@param ChemClass Class of chemical, in this case Acid, Base or other
#'@param Matrix type of compartment considered
#'@return FRorig
#'@export
FRorig <- function(ChemClass, Matrix, 
                pH,
                pKa){
  if (Matrix %in% c("soil", "sediment")) {
  switch(ChemClass,
         "acid" = 1/(1+10^(pH-0.6-pKa)),
         "base" = 1/(1+10^(pKa-4.5)),
         1) # the else clause
  } else if (Matrix %in% c("water", "air")){ # tried to include solid and water FRorig in 1 function for different matrices.
    switch(ChemClass,
           "acid" = 1/(1+10^(pH-pKa)),
           "base" = 1/(1+10^(pKa-pH)),
           1)
  } else return (NA)
  
}
