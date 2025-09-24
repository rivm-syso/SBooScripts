#' @title Aerosol water - air Partition coefficient
#' @name Kaerw
#' @description pm
#' @param Kacompw  air water partitioning coefficient [-]
#' @param FRorig fraction of original species [-]
#' @param SubCompartName subcompartment considered
#' @return Kaerw
#' @export
Kaerw <- function (Kacompw, FRorig, SubCompartName) {

  switch(SubCompartName,
         "air" = 1/(Kacompw*FRorig),
         NA)
  

  
}