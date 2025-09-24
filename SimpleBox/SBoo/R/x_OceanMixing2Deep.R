#' @title Mixing of upper to deeper sea water layer (w2 and w3)
#' @name x_OceanMixing2Deep
#' @param to.Volume Volume of the to box
#' @param from.Volume Volume of the from box
#' @param to.TAUsea TAU - Residence time in sea; scale variable
#' @param from.TAUsea TAU - Residence time in sea; for the "to" box 
#' @param OceanCurrent [m3.s-1]
#' @param ScaleName name of the scale of the box at hand
#' @return Mixing flow surface to deep ocean [m3.s-1]
#' @export
x_OceanMixing2Deep <- function (Volume,
                                TAUsea, #either one is NA the other not
                                OceanCurrent, ScaleName, SubCompartName) {
  switch (SubCompartName,
    "sea" = {
      OceanMixingFlow <- Volume / TAUsea
      if (ScaleName %in% c("Moderate", "Arctic", "Tropic")){ 
        return((OceanMixingFlow + OceanCurrent) )
      } else {
        return (NA)
      } 
    },
    return(NA)
  )
}