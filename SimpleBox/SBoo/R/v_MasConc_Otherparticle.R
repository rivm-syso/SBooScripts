#' @title MasConc_Otherparticle
#' @name MasConc_Otherparticle
#' @param mConcSusp concentration of suspended matter in considered matrix
#' @param mConcCol concentration of colloids in considered matrix
#' @param SpeciesName name of the considered species
#' @return MasConc_Otherparticle
#' @export
MasConc_Otherparticle <- function (mConcSusp, mConcCol, SpeciesName){
  dplyr::case_when(
    SpeciesName == "Small" ~ mConcCol,
    SpeciesName == "Large" ~ mConcSusp,
    TRUE ~ NA_real_  #all but Small or Large
  )
}
