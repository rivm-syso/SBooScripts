#' @title ContSea2Reg
#' @name x_ContSea2Reg
#' @description THe mixing of continental and regional sea's  is based on a factor of 9 times the discharge rate of the regional freshwater to regional sea.
#' @param RiverDischarge river discharge rate, see x_RiverDischarge [s-1]
#' @return additional flux from continental sea to regional
#' @export
x_ContSea2Reg <- function(all.x_RiverDischarge) {
  # NB the regional river discharge determines the sea flow from continental!!
  x_RiverDischarge <- all.x_RiverDischarge$flow[all.x_RiverDischarge$fromScale == "Regional"]

  return((10 - 1) * x_RiverDischarge) # 10-1 based on SB4.01, maybe change to TAU based approach!
}
