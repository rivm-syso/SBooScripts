#' @title Correction factor depth-dependency soil concentrations
#' @name f_CORRsoil
#' @description 
#' Correction factor depth dependent soil concentrations [-]. 
#' This is used for correcting the rate of runoff and volatilisation 
#' due to the non-homogeneous distribution across the top soil layer.
#' The default relevant depth is 0 m and the soil penetration depth is 0.1 m.
#' The approach to derive this correction factor can be obtained from Hollander et al. (2007, https://doi.org/10.1016/j.envpol.2006.09.018) and Hollander et al. (2004, https://doi.org/10.1080/10629360412331297470).
#' @param vertDistance depth of regional, continental and global soils [m]
#' @param penetration_depth_s chemical specific depth that the chemical penetrates into the soil [m]
#' @param relevant_depth_s the soil depth at which a process occurs/is relevant [m] 
#' @return Correction factor depth dependent soil concentration [-]
#' @export
f_CORRsoil <- function (VertDistance, relevant_depth_s, penetration_depth_s){

    return(exp((-1/penetration_depth_s)*relevant_depth_s)*(1/penetration_depth_s) * VertDistance/(1-exp((-1/penetration_depth_s) * VertDistance))) #[-])

  }
