#' Conversion factor mass to concentration
#'
#' Mass2Conc returns the factor to calculate relevant concentrations in reach compartment e.g. to get[kg/kg w] or [kg/m3]
#'
#' @param Volume of the Box (state) [m3]
#' @param all.rhoMatrix density of the matrix [kg m-3]
#' @param FRACa fraction of air in media/matrix [-]
#' @param FRACw fraction of water in media/matrix [-]
#' @param Matrix Media or Matrix type
#' @return Mass2Conc factor
#' @export
Mass2Conc <- function(Volume, SubCompartName, all.rhoMatrix, FRACa, FRACw) {
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "othersoil"]
  RHOw <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "lake"]

  ifelse(SubCompartName %in% c("air", "cloudwater", "deepocean", "lake", "sea", "river"),
    1 / Volume,
    {
      Fracs <- (1 - FRACw - FRACa)
      conc <- 1 / Volume
      conc / (FRACw * RHOw + Fracs * RHOsolid)
    }
  )
}