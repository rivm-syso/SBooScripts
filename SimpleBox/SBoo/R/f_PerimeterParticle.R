#' @title Calculate volume of perimeter of particle
#' @name f_PerimeterParticle
#' @description Calculate the perimeter of the 2d object of a 3d particle for ENPs
#' @param rad_particle Radius of particle [m]
#' @param Shape Particle Shape defined by user, used for nano and plastic [-]
#' @param Longest_side Longest side length as defined by user [m]
#' @param Intermediate_side Intermediate side length as defined by user [m]
#' @param Shortest_side Shortest side length as defined by user [m]
#' @return fPerimeterParticle [m]
#' @export

f_PerimeterParticle <- function(Shape, Longest_side = NULL, Intermediate_side = NULL, Shortest_side = NULL, rad_particle) {
  if (is.na(Shape) || is.null(Shape)){
    Shape <- "Default"
  }
  if (is.na(Longest_side) || is.null(Longest_side) || is.na(Intermediate_side) || is.null(Intermediate_side) || is.na(Shortest_side) || is.null(Shortest_side)) {
    Longest_side <- rad_particle * 2
    Intermediate_side <- rad_particle * 2
    Shortest_side <- rad_particle * 2
  }
  
  
  if (Shape == "Sphere" | Shape == "Default") {
    radius <- Longest_side / 2
    perimeter <- 2 * pi * radius
    return(perimeter)
  } else if (Shape == "Ellipsoid") {
    a <- Longest_side / 2
    b <- Intermediate_side / 2
    c <- Shortest_side / 2
    # For simplicity, let's just consider the perimeter of the ellipse in the xy-plane
    perimeter <- pi * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b)))
    return(perimeter)
  } else if (Shape == "Cube" | Shape == "Box") {
    # For cubes and boxes, perimeter of their 2D projection is just the perimeter of their base
    perimeter <- 4 * Longest_side
    return(perimeter)
  } else if (Shape == "Cylindric - circular") {
    radius <- Longest_side / 2
    # For circular cylinder, the perimeter of its 2D projection is just the circumference of the base circle
    perimeter <- 2 * pi * radius
    return(perimeter)
  } else if (Shape == "Cylindric - elliptic") {
    a <- Longest_side / 2
    b <- Intermediate_side / 2
    # For simplicity, let's just consider the perimeter of the ellipse in the xy-plane
    perimeter <- pi * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b)))
    return(perimeter)
  } else {
    return("Invalid Shape! Please choose from Sphere, Ellipsoid, Cube, Box, Cylindric - circular, or Cylindric - elliptic.")
  }
}