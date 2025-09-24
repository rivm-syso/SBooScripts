#'@title Estimate radius of rain drops
#'@name f_RadRain
#'@param RAINrate Yearly Rain rate [m/s]
#'@param FRACtwet Time fraction of wet episodes (~0-1) [-]
#'@return Rainrate in wet episodes is added in SB4.0, for nanoparticles rain rate is used as in model definition prototype (average in whole year)
#'@export
f_RadRain <- function(RAINrate,FRACtwet){
  RAINrate.wet <- RAINrate/FRACtwet # RAINrate is yearly average in m/s (input DATA in mm/yr)
  Rad.cw <- ((0.7*(60*60*1000*RAINrate.wet)^0.25)/2)/1000
}
