#' @title Ksw
#' @name KswDorC
#' @description soil-water partitioning coefficient for organic colloids
#' @param ChemClass Class of chemical, see QSAR table (REACH, 2012)
#' @param Kow octanol water partitioning coefficient [-]
#' @param CorgStandard Standard mass FRACTION organic carbon in soil/sediment [-]
#' @param a see QSAR table 
#' @param b see QSAR table 
#' @param rhoMatrix density of the matrix [kg/m3]
#' @param pKa Dissociation constant of (conjugated) acid (default = 70
#' @param Ksw soil water partitioning coefficient in data
#' @export
KswDorC <- function (Kow, pKa, CorgStandard, ChemClass, a, b, all.rhoMatrix, Ksw){
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
  
  if (is.na(Ksw) || Ksw == "NA") { 
    if (is.na(pKa) || pKa == "NA"){
      pKa <- 7
      warning("pKa is needed but missing, setting pKa=7")
    }
    f_Ksw(Kow, pKa, CorgStandard , a, b, ChemClass, RHOsolid, FALSE, Ksw)
    
  } else return(Ksw)
  
}
