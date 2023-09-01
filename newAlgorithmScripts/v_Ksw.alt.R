#' @title Ksw.alt
#' @name Ksw.alt
#' @param Kow
#' @param pKa
#' @param CorgStandard
#' @param ChemClass
#' @param a
#' @param b
#' @param RHOsolid
#' @param Ksw
#' @export
Ksw.alt <- function (Kow, pKa, CorgStandard, ChemClass, a, b, all.rhoMatrix, Ksw){
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
  f_Ksw (Kow, pKa, CorgStandard , a, b, ChemClass, RHOsolid, TRUE, Ksw)
}
