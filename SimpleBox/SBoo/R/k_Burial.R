#'@title Burial by sediment
#'@name k_Burial
#'@description Burial based on net sedimentation rates, as described in Schoorl et al. (2015)
#'@param VertDistance mixed depth water sediment compartment [m]
#'@param NETsedrate Net sediment accumulation rate (from the surface water above). Values are constants as reported in Schoorl et al. (2015) [m/s]
#'@param ScaleName Scale name of the considered process
#'@param SubCompartName Subcompartment name for which the computation is done. 
#'@return k_Burial Burial from sediment [s-1]
#'@export

k_Burial <- function(VertDistance, all.NETsedrate, ScaleName, SubCompartName){
  # NETsedrate assumed identical to NETsedrate of the water column above the sediment
  waterabove <- switch (SubCompartName,
      "lakesediment" = "lake",
      "marinesediment" = {switch(ScaleName, 
                                 "Tropic" = "deepocean",
                                 "Moderate" = "deepocean",
                                 "Arctic" = "deepocean",
                                 "sea")}
        ,
      "freshwatersediment" = "river",
      NA
  )
  if (is.na(waterabove)) return (NA)
  rightRow <- which(all.NETsedrate$SubCompart == waterabove & all.NETsedrate$Scale == ScaleName)
  if (length(rightRow) != 1) return(NA)
  waterNETsedrate <- all.NETsedrate$NETsedrate[rightRow]
  waterNETsedrate / VertDistance
}
