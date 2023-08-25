
#' @title Particle thermal velocity 
#' @name ThermalVel
#' @description a description follows .. Joris?
#' @description Ketzel, M.; Berkowicz, R. Modelling the fate of ultrafine particles from exhaust pipe to rural background: an analysis of time scales for dilution, coagulation and deposition. Atmospheric Environment 2004, 38, 2639–2652
#' @description Kulmala, M; Dal Maso, J.; Makela, J.M.; Pirjola, J.; Vakeva, M.; Aalto, P.; Miikulainen, P.; Hameri, K.; O’Dowd, C.D. On the formation, growth and composition of nucleation mode particles. Tellus 2001, 53B, 479–490
#' @param Temp Matrix temperature [K]
#' @param Radius particle radius [m]
#' @param Rho particle density [kg/m3]
#' @return Particle Thermal Velocity
#' @export
ThermalVel <- function(Temp, Radius, Rho){

  ((8*constants::syms$k*Temp)/(pi*fVol(Radius)*Rho))^0.5
}
