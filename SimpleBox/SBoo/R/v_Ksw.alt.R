#' @title Ksw.alt
#' @name Ksw.alt soil water partitioning coefficient for colloids
#'@param ChemClass Class of chemical, see QSAR table (REACH, 2012)
#'@param Kow octanol water partitioning coefficient [-]
#'@param CorgStandard Standard mass FRACTION organic carbon in soil/sediment [-]
#'@param a see QSAR table 
#'@param b see QSAR table 
#'@param rhoMatrix density of the matrix [kg/m3]
#'@param pKa Dissociation constant of (conjugated) acid (default = 7
#'@param KswDorC soil water partitioning coefficient for colloids [-]
#' @export
Ksw.alt <- function (Kow, pKa, CorgStandard, ChemClass, a, b, all.rhoMatrix, KswDorC){
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
  f_Ksw(Kow=Kow, 
        pKa=pKa, 
        CorgStandard=CorgStandard , 
        a=a, 
        b=b, 
        ChemClass=ChemClass, 
        RHOsolid=RHOsolid, 
        alt_form=TRUE, 
        Ksw_orig=KswDorC)
}
