#Script for calculating infiltration

#'@title Infiltration of chemical through soil to deeper soil layers.
#'@name k_Infiltration
#'@param FRACrun Fraction run-off #[-]
#'@param RAINrate Average precipitation #[m/s]
#'@param VertDistance Mixing depth soil #[m]
#'@param EROSIONsoil Soil erosion #[mm/yr]
#'@return k_Run-off Run-off of particles from soil to water #[s-1]
#'@export

k_Infiltration <- function(FRACrun, RAINrate, VertDistance, Kscompw,
                      penetration_depth_s,
                     ScaleName, to.SubCompart, SpeciesName, Matrix){
  switch(SpeciesName,
         "Molecular" = {
           FRACinf*RAINrate/Kscompw*CORRleach.s2R/DEPTH.s2R
         },
         (FRACrun*RAINrate*
            f_CORRsoil(VertDistance, Matrix, relevant_depth_s=0.5, penetration_depth_s)+EROSIONsoil)/VertDistance
         
  )
}
