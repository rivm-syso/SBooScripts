#' @title Ocean currents flowing to Moderate scale (w2 and w3) 
#' @description 
#' Advection of continental sea, Tropic and Arctic sea compartments to sea and deepocean at Moderate scale.
#' @param Volume Volume of compartment [m3]
#' @param TAUsea Residence time of water in sea - scale variable [s]
#' @param all.x_RegSea2Cont All flows from regional to continental seawater [s-1]
#' @param OceanCurrent Global ocean circulation current [m3.s-1] 
#' @param SubCompartName Name of the subcompartment of the box at hand
#' @param ScaleName Name of the scale of the box at hand
#' @return Water flow to Moderate scale surface and deepocean waters [m3 s-1]
#' @export
#' 
x_ToModerateWater <- function (Volume, TAUsea, 
                             all.x_RegSea2Cont, OceanCurrent, SubCompartName, ScaleName) {
  switch(ScaleName,
         "Tropic" = {
           switch (SubCompartName,
                   "sea" = {OceanCurrent},
                   "deepocean" = {return(0)}, #fix, data in code
                   NA
           )},
         "Arctic" = {
           switch (SubCompartName,
                   "sea" = {return(0)}, #fix, data in code
                   "deepocean" = {OceanCurrent},
                   NA
           )},
         "Continental" = {
           switch (SubCompartName,
                   "sea" = {
                     RegSea2Cont <- all.x_RegSea2Cont$flow[all.x_RegSea2Cont$fromSubCompart == "sea" & 
                                                             all.x_RegSea2Cont$fromScale == "Regional"]
                     return((Volume/TAUsea)-RegSea2Cont)}, 
                   NA
           )},
         return(NA)
  )
  
}
