#' @title Area
#' @name Area
#' @param AREAland the land area in the considered compartment [m2]
#' @param AREAsea  the sea area in the considered compartment [m2]
#' @param landFRAC fraction of land in the considered compartment [-]
#' @param SubCompartName the subcompartment which is considered
#' @param ScaleName the scale which is considered
#' @return Area (but not for sediment) based on data for the SubCompartment / Scale
#' @export
Area <- function (AreaLand,
                     AreaSea,
                     landFRAC,
                     all.landFRAC, 
                     SubCompartName,
                     ScaleName) {
  # easiest
  if (SubCompartName %in% c("air", "cloudwater")) {
    return(AreaLand + AreaSea)
  }
  
  if (SubCompartName %in% c("sea", "marinesediment")) {
    return(AreaSea)
  }
  if (SubCompartName == "deepocean" &
      ScaleName %in% c("Arctic", "Moderate", "Tropic")) {
    return(AreaSea)
  }
  if (SubCompartName == "lakesediment" & ScaleName %in% c("Regional", "Continental")){
    return(all.landFRAC$landFRAC[all.landFRAC$SubCompart == "lake" & all.landFRAC$Scale == ScaleName] *AreaLand)
  }
  
  if (SubCompartName == "freshwatersediment" & ScaleName %in% c("Regional", "Continental")){
    return(all.landFRAC$landFRAC[all.landFRAC$SubCompart == "river" & all.landFRAC$Scale == ScaleName] *AreaLand)
  }
  
  
  # on land, lake, freshwater and soils;
  if (ScaleName %in% c("Regional", "Continental")) {
    return(landFRAC * AreaLand)
  }
  
  # on land, on global scales: only naturalsoil
  if (SubCompartName == "naturalsoil") {
    return(AreaLand)
  }
  
  #all other cases
  return(NA)
}
