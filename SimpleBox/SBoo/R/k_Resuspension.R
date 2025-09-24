#' @title Resuspension rate constant of substances in sediment
#' @name k_Resuspension
#' @description Calculation of the resuspension rate. The top layer of sediment is assumed to be well mixed and thus continiously refreshed,
#' for additional details see Schoorl et al. (2015)
#' @param DynViscWaterStandard Dynamic viscosity of water [kg m-1 s-1]
#' @param rhoMatrix density of the Matrix [kg m-3]
#' @param NETsedrate net sedimentation rate, data input [s] (Schoorl et al., 2015)
#' @param VertDistance mixed depth sediment compartment #[m]
#' @param RhoCP Mineral density of sediment and soil #[kg/m3]
#' @param FRACs Volume fraction solids in sediment #[-]
#' @param RadCP radius of coarse particulate particles [m]
#' @param SUSP mass concentration of suspended matter [kg m-3]
#' @param SpeciesName species considered
#' @param ScaleName scale considered
#' @param SubCompartName subcompartment considered
#' @param Test determines if SB4-Excel approach is taken or enhanced method from R version [boolean]
#' @param SettlingVelocitySPM settling velocity of suspended matter particles
#' @return k_Resuspension Resuspension flow from sediment #[s-1]
#' @export

k_Resuspension <- function(VertDistance, # SettlVelocitywater
                           DynViscWaterStandard,
                           to.rhoMatrix,
                           to.NETsedrate,
                           to.RadCP, to.RhoCP, from.RhoCP, FRACs, to.SUSP, SpeciesName, ScaleName, to.SubCompartName, from.SubCompartName, Test) {
  if (SpeciesName == "Molecular") {
    if (as.character(Test) == "TRUE") {
      SettlingVelocitySPM <- 2.5 / (24 * 3600)
    } else {
      # ScaleName
      SettlingVelocitySPM <- f_SetVelWater(
        radius = to.RadCP,
        rhoParticle = to.RhoCP, rhoWater = to.rhoMatrix, DynViscWaterStandard
      )
    }
  } else {
    # ScaleName
    SettlingVelocitySPM <- f_SetVelWater(
      radius = to.RadCP,
      rhoParticle = to.RhoCP, rhoWater = to.rhoMatrix, DynViscWaterStandard
    )
  }

  # Gross sedimentation rate from water [m/s]
  GROSSEDrate <- SettlingVelocitySPM * to.SUSP / (FRACs * from.RhoCP) # [m.s-1] possibly < NETsedrate

  # Resuspension flow from sediment [m/s]; can't be < 0
  RESUSflow <- max(0, GROSSEDrate - to.NETsedrate) # for particulates this NETsedrate is not optimal!

  # Resuspension k to water [s-1]
  return(RESUSflow / VertDistance)
}
