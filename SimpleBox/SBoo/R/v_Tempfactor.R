#'@title Temperature correction degradation rate water/sed/soil
#'@name Tempfactor
#'@param Q.10 Degradation rate increase factor per  10 C [-]
#'@param Temp Average temeperature [K]
#'@param T25 25 degrees C [K]
#'@param EA.OHrad activation energy OH radical reaction [J mol-1]
#'@param Matrix compartment type considered
#'@param SpeciesName species considered
#'@return  Temperature correction degradation rate water/sed/soil [-]
#'@export

Tempfactor <- function(Q.10,Temp, T25, Ea.OHrad, Matrix, SpeciesName) {
  
  if (SpeciesName %in% c("Molecular")) {
    
    switch(Matrix,
           "air" =   {
             return(exp((Ea.OHrad/constants::syms$r)*((Temp-T25)/T25^2)))
           },
           "soil" = {return(Q.10^((Temp-T25)/10))
           },
           "sediment" = {return(Q.10^((Temp-T25)/10))
           },
           "water" = {return(Q.10^((Temp-T25)/10))
           },
           return(NA)
    )
  } else { # Particulate
    
    switch(Matrix,
           "air" =   {
             
             return(1) # not corrected for temperature or other aspects
           },
           "soil" = {
             return(1) # not corrected for temperature or other aspects
           },
           "sediment" = {
             
             return(1) # not corrected for temperature or other aspects
           },
           "water" = {
             return(1) # not corrected for temperature or other aspects
           },
           return(NA)
    )
  }
  
}