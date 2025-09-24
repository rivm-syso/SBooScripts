#' @title Fragmentation and degradation of plastics
#' @name k_Deagglomeration
#' @description Deagglomeration is the opposite of heteroagglomeration. For instance Polymer particles with an inorganic part can fragment. It is used in Plastics World. For instance for fragmentation of Tyre and Road wear particles into Tyre wear particles alone.
#' @param kdeag Falling appart or fragmenting of heteroaglomerates [s-1]
#' @return k_Deagglomeration, the combined degradation and fragmentation rate of microplastics [s-1]
#' @export


k_Deagglomeration <- function (kdeag, SubCompartName, ScaleName){
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
    return(kdeag)
  }
    
}