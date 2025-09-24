#' @title Calculate volume of sphere assuming (20181102)
#' @name f_SurfaceArea
#' @description Calculate the volume of spherical particle using the radius in m3, Shapes based on Gov4Nano 
#' @param rad_particle Radius of particle [m]
#' @param Shape Particle Shape defined by user, used for nano and plastic [-]
#' @param Longest_side Longest side length as defined by user [m]
#' @param Intermediate_side Intermediate side length as defined by user [m]
#' @param Shortest_side Shortest side length as defined by user
#' @return f_SurfaceArea [m2]
#' @export

f_SurfaceArea <- function(Shape, Longest_side = NULL, Intermediate_side = NULL, Shortest_side = NULL, rad_particle) {
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
      surface_area <- 4 * pi * radius^2
      return(surface_area)
    } else if (Shape == "Ellipsoid") {
      a <- Longest_side / 2
      b <- Intermediate_side / 2
      c <- Shortest_side / 2
      z <- 1.6075
      surface_area <-  surface_area <- 4 * pi * ((((a / 2)^z * (b / 2)^z) + ((a / 2)^z * (c / 2)^z) + ((b / 2)^z * (c / 2)^z)) / 3)^(1/z)
      return(surface_area)
    } else if (Shape == "Cube" | Shape == "Box") {
      surface_area <- 2 * (Longest_side * Intermediate_side + Intermediate_side * Shortest_side + Shortest_side * Longest_side)
      return(surface_area)
    } else if (Shape == "Cylindric - circular") {
      radius <- Longest_side / 2
      height <- Intermediate_side
      surface_area <- (2 * radius^2 + Longest_side * Shortest_side) * pi
      return(surface_area)
    } else if (Shape == "Cylindric - elliptic") {
      a <- Longest_side / 2
      b <- Intermediate_side / 2
      surface_area <- (pi() * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b))) * Shortest_side) + 2 * (pi * (a * b))
      return(surface_area)
    } else {
      return("Invalid Shape! Please choose from Sphere, Ellipsoid, Cube, Box, Cylindric - circular, or Cylindric - elliptic.")
    }
  }
