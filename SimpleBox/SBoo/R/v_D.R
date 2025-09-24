#'@title D
#'@name D
#'@description octanol/water partitioning coefficient at neutral pH for colloids
#'@param ChemClass Class of chemical; in this case Acid, Base or other
#'@param FRorig Fraction of species in its original state
#'@param pKa Dissociation constant of (conjugated) acid (default = 7)
#'@param Kow octanol water partitioning coefficient [-]
#'@export
D <- function(FRorig, pKa, Kow, ChemClass){
  
  if (is.na(Kow) || Kow == "NA") {
    Kow = 18 
    warning("Kow is NA, default of 18 used!")
  }
  
  Kow.alt = 10^(log10(Kow)-3.5)
  
  switch(ChemClass,
         "acid" = 
           1/(1+10^(7-pKa)) * Kow + (1 - 1/(1+10^(7-pKa)))*Kow.alt,
         "base" = 
           1/(1+10^(pKa-7)) * Kow + (1- 1/(1+10^(pKa-7)))*Kow.alt,
         # else for other ChemClass:
         Kow
          
       )
}
