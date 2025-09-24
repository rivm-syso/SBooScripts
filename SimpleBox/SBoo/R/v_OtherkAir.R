#' @title v_OtherkAir
#' @name v_OtherkAir
#' @description all other processes in air, used in 
#' @param all.kaas all other transfer rates in air, used in deposition flux
#' @param ScaleName scale name considered
#' @param Species species type considered (molecular)
#' @export
OtherkAir <- function (all.kaas, ScaleName, SpeciesName){
  #is only for Molecular
  if (SpeciesName != "Molecular") return (NA)
  return(sum(all.kaas$k[all.kaas$fromScale == ScaleName & all.kaas$fromSpecies == "Unbound" & all.kaas$fromSubCompart == "air"]))

}
