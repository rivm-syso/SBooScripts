#' @title Fragmentation and degradation of plastics
#' @name k_Fragmentation
#' @description Calculation of fragmentation and degradation of plastics, only used in Plastics World
#' @param kmpdeg degradation rate of plastic in certain subcompartment [s-1]
#' @param kfrag fragmentation rate of plastic in certain subcompartment
#' @return k_Fragmentation, the combined degradation and fragmentation rate of microplastics [s-1]
#' @export


k_Fragmentation <- function (kfrag, SubCompartName, ScaleName){
  if (((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & (SubCompartName == "freshwatersediment" | 
                                                             SubCompartName == "lakesediment" |
                                                             SubCompartName == "lake" |
                                                             SubCompartName == "river" |
                                                             SubCompartName == "agriculturalsoil"|
                                                             SubCompartName == "othersoil")) ){
    return(NA)
  } else if (ScaleName %in% c("Regional", "Continental") && (SubCompartName == "deepocean")){
    return(NA)
  } else {
    return(kfrag)
  }
    
}