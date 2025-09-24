#' @title LakeOut
#' @name x_LakeOut
#' @description This calculates the flow from a freshwater (w0) compartment (e.g. lake) within the regional or continental scale to the main freshwater compartment (w1).
#' @param RainOnFreshwater The direct rain on the freshwater compartment (e.g. a lake).
#' @param all.RunoffFlow RunoffFlow from soil to the freshwater compartment
#' @param FracROWatComp The fraction runoff discharging into the separate w0 freshwater compartment based on surface area fraction.
#' @param SubCompartName Only applies to lake compartment, so the compartment name is needed.
#' @param ScaleName Runoff needs to be calculated per scale.
#' @return Lake discharge
#' @export
x_LakeOut <- function(RainOnFreshwater,
                           all.RunoffFlow,
                           FracROWatComp,
                       SubCompartName,
                           ScaleName){
  switch(SubCompartName, # if this is coded with if statement it fails as SubCompartName for Arctic is NA
          "lake" = {
            SumRunoff <- sum(all.RunoffFlow$RunoffFlow[all.RunoffFlow$Scale == ScaleName])
            return(RainOnFreshwater + FracROWatComp*SumRunoff)
          },
          NA
  )
}
