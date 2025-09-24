#'@title Erosion of particles
#'@name k_Erosion
#'@description Erosion process for attached ENP species corrected for the compartment their flowing to.
#'@param relevant_depth_s relevant depth that is susceptible to erosion [m], see f_CORRsoil
#'@param penentration_depth_s assumed penetration depth [m], from Hollander et al. (2007), see f_CORRsoil
#'@param VertDistance Vertical distance of compartment [m]
#'@param EROSIONsoil Soil erosion #[m/s]
#'@param ScaleName To adjust for the absence of rivers in global scales
#'@param to.SubCompartName name of the subcompartment of the destination box of this process
#'@param Matrix compartment type considered
#'@param landFRAC fraction of land of a certain compartment 
#'@param FracROWatComp a fraction of the water that erosion/runoff can go to [-], see v_FracROWatComp.
#'@return k_Erosion Erosion of attached ENP species (P) from soil to water #[s-1]
#'@export
k_Erosion <- function(relevant_depth_s,penetration_depth_s, EROSIONsoil, VertDistance,
                      to.FracROWatComp,
                      ScaleName, to.SubCompartName,  Matrix, all.landFRAC, all.Matrix ){
  if (ScaleName %in% c("Regional", "Continental") & to.SubCompartName == "sea") {
    return(NA)
  } 
  if ((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & to.SubCompartName != "sea") {
    return(NA)
  } 
  EROSIONsoil * f_CORRsoil(VertDistance, relevant_depth_s, penetration_depth_s) / VertDistance * to.FracROWatComp  #[s-1]
}
