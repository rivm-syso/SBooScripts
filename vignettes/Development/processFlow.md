processFlow
================
Jaap Slootweg, Valerie de Rijk
2024-07-24

## NewProcess

The flow of mass between compartments in SimpleBox depends on first
order rate constants (k in s-1). As such, all new processes should
adhere to this approach. In case of creating a new algorithm in R use
the following approach. It is advised to test a new process with world
initialisation for *all* types of particles (e.g. molecules (acid, base,
metal), particulates and microplastics) in your own branch to limit
polluting the main with unwanted processes. Secondly, all processes
should be documented well, preferably with sources to the paper the
process is derived from. Here an example for calculating the leaching
rate constant from soil to water:

``` r
#'@title Leaching of particles (unbound species to be added)
#'@name k_Leaching
#'@param FRACinf Fraction infiltration #[-]
#'@param RAINrate Average precipitation #[m/s]
#'@param VertDistance Mixing depth soil #[m]
#'@return Leaching of aggregated (A) or free (S) enp species from natural soil #[s-1]
#'@export

k_Leaching <- function(FRACinf, RAINrate, VertDistance, SpeciesName, ...){ #k_ Leaching
  
  if (SpeciesName %in% c("Aggregated", "Nanoparticle")) {
    #Correction factor depth dependent soil concentration
    CORRleach <- (exp((-1/0.1)*0.5)*(1/0.1) * VertDistance / (1-exp((-1/0.1) * VertDistance))) #[-]
    
    #Leaching of aggregated (A) and free (S) enp species from natural soil [s-1]
    return( (FRACinf * RAINrate * CORRleach) / VertDistance )
    
  } else { # This function needs a future update to include the algorithm for the unbound species!
    return(NA)
  }
}
```
