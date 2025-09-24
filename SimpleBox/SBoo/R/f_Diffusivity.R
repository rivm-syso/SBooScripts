#' @title Diffusivity
#' @name f_Diffusivity
#' @description Diffusivity, the rate of diffusion [m2/s]
#' @param Matrix as in c("air", "water", "soil")
#' @param Temp Temperature [K]
#' @param DynVisc Dynamic viscosity (air, water) [kg/m/s]
#' @param rad_species radius of heteroagglomerates [m], calculated in v_rad_species
#' @param Cunningham, Collision frequency of ENPs with other particulates [-], see f_Cunningham
#' @param kboltz Boltzmann constant, relates the average relative thermal energies of particles with the temperature of the gas
#' @param pi Pi constant number ~3.14 [-]
#' @return Diffusivity [m2/s]
#' @export
f_Diffusivity <- function(Matrix, Temp, DynVisc, rad_species, Cunningham = NULL) {
  if(!is.numeric(Temp)){
    warning("Temp missing in f_Diffusivity")
    return(NA)
  }
  if(!is.numeric(DynVisc)){
    warning("DynVisc missing in f_Diffusivity")
    return(NA)
  }
  if(!is.numeric(rad_species)){
    warning("rad_species missing in f_Diffusivity")
    return(NA)
  }
  kboltz <- constants::syms$k
  if (Matrix == "air") {
    if (is.null(Cunningham))
      Cunningham <- f_Cunningham(rad_species)
    return ((kboltz*Temp*Cunningham)/(6*pi*DynVisc*rad_species))
  } else {
    (kboltz*Temp)/(6*pi*DynVisc*rad_species)
  }

}
