#' @title Continental surface water to Regional [s-1]
#' @name x_ContRiver2Reg
#' @param ScaleName Name of the relevant scale
#' @param SubCompartName Name of the relevant sub-compartment
#' @param RunoffFlow RunoffFlow flow from soil to river [m3.s-1]
#' @param RainOnFreshwater Water flow of rain directly on lake/river [m3.s-1]
#' @param dischargeFRAC Fraction discharge of freshwater between regional and continental scales and vice versa [-]
#' @return River Discharge for scale Continental [s-1]
#' @export
x_ContRiver2Reg <- function(ScaleName, SubCompartName,
                            all.RunoffFlow, all.RainOnFreshwater,
                            dischargeFRAC) {
  switch(ScaleName,
    "Continental" = {
      switch(SubCompartName,
        "river" = {
          SumRainRunoff <- sum(all.RunoffFlow$RunoffFlow[all.RunoffFlow$Scale == ScaleName]) +
            sum(all.RainOnFreshwater$RainOnFreshwater[all.RainOnFreshwater$Scale == ScaleName])
          # River2sea  <- RainOnFreshwater + SumRunoff * (1-dischargeFRAC)
          # Lake2River <- LakeFracRiver * River2sea

          return((SumRainRunoff) * dischargeFRAC)
        },
        return(NA)
      )
    },
    return(NA)
  )
}
