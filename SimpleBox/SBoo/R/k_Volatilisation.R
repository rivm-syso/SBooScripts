#'@title Volatilisation rate constant
#'@name k_Volatilisation
#'@description volatilisation process based on the two-film resistance model (Schwarzenbach et al., 1993) ISBN: 978-1-118-76723-8
#'@param FRACinf Fraction infiltration #[-]
#'@param RAINrate Average precipitation #[m/s]
#'@param VertDistance Mixing depth soil #[m]
#'@returns Volatilisation rate constant [s-1]
#'@export

k_Volatilisation <- function(to.MTC_2w, from.MTC_2a, to.MTC_2s, Kacompw, from.FRorig, from.FRorig_spw, FRinw, Kscompw,
                             VertDistance, SpeciesName, Matrix, relevant_depth_s, penetration_depth_s,
                             from.SubCompartName, from.ScaleName, to.SubCompartName,to.ScaleName){ 
# browser()

  if (SpeciesName %in% c("Molecular")) {
    switch(Matrix,
           "water" = { 
             flux = (to.MTC_2w*from.MTC_2a/(to.MTC_2w*(Kacompw*from.FRorig)+from.MTC_2a))*(Kacompw*from.FRorig)*FRinw
             return(flux/VertDistance)},
           "soil" = { 
             fcor <- f_CORRsoil(VertDistance, relevant_depth_s, penetration_depth_s)
             flux = (to.MTC_2s*from.MTC_2a)/(to.MTC_2s+from.MTC_2a/((Kacompw*from.FRorig_spw)/Kscompw))*fcor
             return(flux/VertDistance)}
    )
  } else { 
    return(NA)
  }
}

