#' @title Calculate residence time
#' @name f_TAU
#' @description general approximation of mean residence time
#' @param Area area of the compartment [m2]
#' @param WINDspeed windspeed within the compartment [m/s]
#' @return TAU [s]
#' @export
f_TAU <- function (Area, WINDspeed){
  1.5*(0.5 * sqrt(Area*pi/4)/WINDspeed)
}
