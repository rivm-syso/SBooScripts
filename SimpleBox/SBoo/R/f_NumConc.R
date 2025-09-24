#' @title Calculate number concentration from mass concentration
#' @name fNumConc
#' @description Calculate number concentration from mass concentration [#.m-3]
#' @param rad_particle Radius of particle [m]
#' @param rho_partocle Density of particle [kg.m-3]
#' @param MasConc Mass based concentration of particle per volume [kg.m-3]
#' @return fNumConc [#.m-3]
#' @export
f_NumConc <- function(rad_particle,rho_particle, MasConc){
  (MasConc)/(fVol(rad_particle)*rho_particle)
}
