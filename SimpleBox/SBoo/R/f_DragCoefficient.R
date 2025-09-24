#' @title Drag Coefficient particles 
#' @name f_DragCoefficient
#' @description Computes the Drag Coefficoent based on the DragMethod as defined by user 
#' @param CD Drag Coefficient of a particle [-]
#' @param DragMethod Method of calculating the Drag Coefficient
#' @param Psi Shape factor, circularity/sphericity [-]
#' @param Re Reynolds number, as returned by the solver [-]
#' @param CSF Corey Shape Factor [-]
#' @param Dioguardi A Drag Coefficient method as described in Dioguardi & Mele (2018) https://doi.org/10.1016/j.powtec.2015.02.062
#' @param Swamee A Drag Coefficient method as described in Swamee & Ojha (1991) https://doi.org/10.1061/(ASCE)0733-9429(1991)117:5(660)
#' @param Stokes A Stokes-Dietrich approximation as described in Dietrich (1982) https://doi.org/10.1029/WR018i006p01615
#' @return f_DragCoefficient 
#' @export

f_DragCoefficient <- function(DragMethod, Re, Psi, CSF) {
  if (DragMethod == "Dioguardi" | DragMethod == "Default") {
    term1 <- (24 / Re) * (((1 - Psi) / Re) + 1) ^ 0.25
    term2 <- (24 / Re) * (0.1806 * Re ^ 0.6459) * Psi ^ - (Re^0.08)
    term3 <- 0.4251 / (1 + (6880.95 / Re) * Psi ^ 5.05)
    CD <- term1 + term2 + term3
  } else if (DragMethod == "Swamee") {
    term1 = 48.5 / (((1 + 4.5 * CSF ^ 0.35) ^ 0.8) * (Re ^ 0.64))
    term2 = ((Re / (Re + 100 + 1000 * CSF)) ^ 0.32) * (1 / (CSF ^ 18 + 1.05 * CSF ^ 0.8))
    CD <- (term1 + term2) ^ 1.25
  } else if (DragMethod == "Stokes"){
    CD <- 24 / Re + 4 / sqrt(Re) + 0.4
  } else {
    stop("Invalid DragMethod! Please choose from available DragMethods.")
  }
  return(CD)
}