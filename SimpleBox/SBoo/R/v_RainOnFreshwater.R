#' @title RainOnFreshwater
#' @name RainOnFreshwater
#' @description The fraction of rain falling on lake or river water.
#' @param RAINrate m.s-1
#' @param Area in m2
#' @param SubCompartName #only for lake/rivers
#' @return waterflow of rain directly on lake/river
#' and continental being a part of Moderate (/ Tropic)
#' @export
RainOnFreshwater <- function (RAINrate, Area, SubCompartName) {
  if (SubCompartName %in% c("river", "lake")) {
    # RAINrateToSI is generarted from units !
    return(RAINrate * Area)
  } else    return(NA)
}
