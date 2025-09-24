#' @title Interception or peri-kinetic collision frequency coefficient (20181102)
#' @name f_Inter
#' @description Collission frequency of ENPs with other particulates due to fluid motion in s-1 for heteroagglomeration
#' @param Shear Shear rate of the fluid matrix [s-1]
#' @param from.radius Radius of nanoparticle [m]
#' @param radius_Otherparticle  Radius of Other particle [m]
#' @return f_Inter [s-1]
#' @export
f_Inter <- function(Shear=0,from.radius,radius_Otherparticle ){
  (4/3)*Shear*(from.radius+radius_Otherparticle )^3
}
