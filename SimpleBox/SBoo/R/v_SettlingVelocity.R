#' @title SettlingVelocity
#' @name v_SettlingVelocity
#' @description Settling Velocity or terminal Velocity of particles in a fluid medium based on different DragMethods.
#' NB SettlingVelocity is a function to be used for all types of partical species, not just nano-species. Therefor it's not a variable defining function.
#' @param rho_species Density of particle [kg/m3]
#' @param rhoMatrix Density of fluid matrix in which particle is present [kg/m3]
#' @param DynViscAirStandard Dynamic viscosity of the fluid matrix [kg m-1 s-1]
#' @param DynViscWaterStandard Dynamic viscosity of the fluid matrix [kg m-1 s-1]
#' @param rad_species Radius of the particle [m]
#' @param Matrix function is defined for Water and Air; slightly different algorithm [text]
#' @param SubCompartName name of the different subcompartments, used to segregate different formulas [text] 
#' @param Shape Shape as defined by user, different possibilities (see f_Vol for options) [text]
#' @param Longest_side the longest side of the particle as defined by the user [m]
#' @param Intermediate_side the intermediate side of the particle as defined by user [m]
#' @param Shortest_side the shortst side of the particle as identified by user [m]
#' @param DragMethod The Method used for computing the drag coefficient as defined by user, opportunity for choosing 4 different ones. See f_DragCoefficient for options
#' @return Settling velocity
#' @export
SettlingVelocity <- function(rad_species, rho_species, rhoMatrix, 
                             DynViscWaterStandard,
                             DynViscAirStandard,
                             Matrix,SubCompartName, Shape,
                             Longest_side, Intermediate_side, Shortest_side, DragMethod) {
  if (anyNA(c(rho_species,rhoMatrix))){
    return(NA)
  }
  if (is.na(Longest_side) || is.null(Longest_side) || is.na(Intermediate_side) || is.null(Intermediate_side) || is.na(Shortest_side) || is.null(Shortest_side)) {
    Longest_side <- rad_species * 2
    Intermediate_side <- rad_species * 2
    Shortest_side <- rad_species * 2
  } #TODO check application of this default assumption
  if (is.na(Shape) || is.null(Shape)){
    Shape <- "Default"
  }
  
  GN <- constants::syms$gn
  
  if(Matrix == "soil" | Matrix == "sediment") return(NA)
  if(SubCompartName == "cloudwater") return(NA)
  
  if(DragMethod == "Original" & Matrix =="water"){
    sv <- 2*(rad_species^2*(rho_species-rhoMatrix)*GN) / (9*DynViscWaterStandard)
    if (sv <= 0){
      return(0)
    } 
    else {
      return(sv)
    }
  } 
  if(DragMethod == "Original" & Matrix =="air") {
    Cunningham <- f_Cunningham(rad_species)
    sv <- 2*(rad_species^2*(rho_species-rhoMatrix)*GN*Cunningham) / (9*DynViscAirStandard)
    if (sv <= 0){
      return(0)
    } 
    else {
      return(sv)
    }
  } 
  volume <- fVol(rad_species, Shape, Longest_side, Intermediate_side, Shortest_side)
  d_eq <- ( 6/ pi * volume)^(1/3)
  surfaceareaparticle <- f_SurfaceArea(Shape, Longest_side, Intermediate_side, Shortest_side, rad_species)
  surfaceareaperfectsphere <- f_SurfaceArea("Sphere", d_eq, d_eq, d_eq, rad_species)
  #circularity <- Longest_side*Intermediate_side / (d_eq*d_eq)
  perimeterparticle <- f_PerimeterParticle(Shape, Longest_side, Intermediate_side, Shortest_side, rad_species)
  perimetercircle <- f_PerimeterParticle("Sphere", d_eq, d_eq, d_eq, rad_species)
  circularity <- perimeterparticle/perimetercircle
  sphericity <- surfaceareaperfectsphere/surfaceareaparticle
  Psi <- sphericity/circularity # Shape factor Dioguardi
  CSF <- Shortest_side/(sqrt(Longest_side*Intermediate_side)) #Corey Shape Factor
  switch (Matrix,
          "water" = { 
            v_s <- f_SetVelSolver(d_eq, Psi, DynViscWaterStandard, rho_species, rhoMatrix, DragMethod, CSF, Matrix, rad_species)
            return(v_s)
            }, 
          "air"= {
            v_s <- f_SetVelSolver(d_eq, Psi, DynViscAirStandard, rho_species, rhoMatrix, DragMethod, CSF, Matrix, rad_species)
            return(v_s)
          },
          NA
        )
  if (v_s <= 0) {
    return(0)
  } 
  
  else {
    return(v_s)
  }
}
  
