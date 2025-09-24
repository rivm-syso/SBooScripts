#' @title Settling Velocity Solver based on RSS
#' @name f_SetVelSolver
#' @description Calculates the settling velocity by minimizing  the residual sum of squares (RSS)
#' @param CD Drag Coefficient of a particle [-]
#' @param DragMethod Method of calculating the Drag Coefficient
#' @param Psi Shape factor, circularity/sphericity [-]
#' @param Re Reynolds number, as returned by the solver [-]
#' @param CSF Corey Shape Factor [-]
#' @param d_eq Equivalent spherical diameter of the particle [-]
#' @param DynViscWaterStandard Dynamic viscosity of liquid  (fraction of) compartment [kg.m-1.s-1]
#' @param rhoParticle Density of nanoparticle [kg.m-3]
#' @param rhoWater Density of the water [kg m-3]
#' @param rad_species radius of the species [m]
#' @param GN gravitational force constant [m2 s-1]
#' @param Cunningham Cunningham coefficient, see f_Cunningham [-]
#' @return settling velocity [m/s] 
#' @export
#' 
f_SetVelSolver <- function(d_eq, Psi, DynViscWaterStandard, rhoParticle, rhoWater, DragMethod, CSF, Matrix, rad_species) {
  # Define the RSS function to be minimized
  GN <- constants::syms$gn
  switch(Matrix,
          "water" = {
  
            RSS_function <- function(v_s) {
              Re <- d_eq * v_s * rhoWater / DynViscWaterStandard
              CD <- f_DragCoefficient(DragMethod, Re, Psi, CSF)
              v_s_new <- sqrt(4 / 3 * d_eq / CD * ((rhoParticle - rhoWater) / rhoWater) * GN)
              RSS <- (v_s - v_s_new) ^ 2
              return(RSS)}
            result <- optimize(RSS_function, interval = c(0, 1), tol = 1e-9)
            
            return(result$minimum)
            },
          "air" = {
            RSS_function <- function(v_s) {
              Re <- d_eq * v_s * rhoWater / DynViscWaterStandard
              Cunningham <- f_Cunningham(rad_species)
              CD <- f_DragCoefficient(DragMethod, Re, Psi, CSF)
              v_s_new <- sqrt(4 / 3 * d_eq / CD * ((rhoParticle - rhoWater) / rhoWater) * GN) * Cunningham
              RSS <- (v_s - v_s_new) ^ 2
              return(RSS)}
            result <- optimize(RSS_function, interval = c(0, 1), tol = 1e-9)
            
            return(result$minimum)
            },
            NA
  )       

}
