#' @title Calculate volume of sphere or other shape
#' @name fVol
#' @description Calculate the volume of spherical particle using the radius in m3, shapes based on Gov4Nano 
#' @param rad_particle Radius of particle [m]
#' @param Shape Particle shape defined by user, used for nano and plastic [-]
#' @param Longest_side Longest side length as defined by user [m]
#' @param Intermediate_side Intermediate side length as defined by user [m]
#' @param Shortest_side Shortest side length as defined by user
#' @return fVol [m3]
#' @export

fVol <- function(rad_particle, Shape = NULL, Longest_side = NULL, Intermediate_side = NULL, Shortest_side = NULL){
    if (is.na(Shape) || is.null(Shape)){
      Shape <- "Default"
    }
    
    # Check if any of the sides is NA or NULL and assign default values if so
    if (is.na(Longest_side) || is.null(Longest_side) || is.na(Intermediate_side) || is.null(Intermediate_side) || is.na(Shortest_side) || is.null(Shortest_side)) {
      Longest_side <- rad_particle * 2
      Intermediate_side <- rad_particle * 2 #maybe 0.75 or build in shape functions
      Shortest_side <- rad_particle * 2 # maybe 0.5 
    }

      if (Shape == "Sphere" | Shape == "Default") {
        radius <- Longest_side / 2
        volume <- (4/3) * pi * radius^3
        return(volume)
      } else if (Shape == "Ellipsoid") {
        volume <- (4/3) * pi * Longest_side * Intermediate_side * Shortest_side
        return(volume)
      } else if (Shape == "Cube" | Shape == "Box") {
        #Longest_side <- sqrt(3)*Longest_side
        #Intermediate_side <-sqrt(2)*Longest_side
        volume <- Longest_side * Intermediate_side * Shortest_side
        return(volume)
      } else if (Shape == "Cylindric - circular") {

        radius <- Longest_side / 2
        height <- Intermediate_side
        volume <- pi * radius^2 * height
        return(volume)
      } else if (Shape == "Cylindric - elliptic") {
        radius_major <- Longest_side / 2
        radius_minor <- Intermediate_side / 2
        height <- Shortest_side
        volume <- pi * radius_major * radius_minor * height
        return(volume)
      } else {
        return("Invalid Shape! Please choose from Sphere, Ellipsoid, Cube, Box, Cylindric - circular, or Cylindric - elliptic.")
      }
}

