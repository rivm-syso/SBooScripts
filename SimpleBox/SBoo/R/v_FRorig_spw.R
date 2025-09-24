#'@title Fraction of original species - soil pore water
#'@name FRorig_spw
#'@description Fraction original species in soil pore water
#'@param pH pH of soil
#'@param pKa Dissociation constant of (conjugated) acid (default = 7)
#'@param ChemClass Class of chemical, in this case Acid, Base or other
#'@param Matrix type of compartment considered
#'@export
FRorig_spw <- function(ChemClass, Matrix, 
                   pH,
                   pKa){
  if (Matrix %in% c("soil")){ # soil pore water
    switch(ChemClass,
           "acid" = 1/(1+10^(pH-pKa)),
           "base" = 1/(1+10^(pKa-pH)),
           1)
  } else return (NA)
  
}
