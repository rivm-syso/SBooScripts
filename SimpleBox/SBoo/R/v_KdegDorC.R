#' @title Degradation rate constant measured or calculated
#' @name v_KdegDorC
#' @description calculate k for degradation for particulates and molecules.
#' if no specific value for kdeg is available it is scaled into categories 
#' as defined in Technical Guidance Document on risk assessment in support of
#' Commission Directive 93/67/EEC (European Commission, 2003)
#' @param kdeg degradation rate (as input) [s-1]
#' @param C.OHrad OH radical concentration specific to compartment, based on Wania & Daly (2002) [mol m-3]
#' @param C.OHrad.n general OH radical concentration, based on Wania & Daly (2002) [mol m-3]
#' @param k0.OHrad frequency factor of the OH radical reaction [m3 s-1] 
#' @param Ea.OHrad activation energy OH radical reaction [J mol-1]
#' @param T25 298K [K]
#' @param Q.10 rate increase factor per 10C [-]
#' @param KswDorC calculated soil water partitioning coefficient  [-]
#' @param BioDeg biodegradability test result [-]
#' @param CorgStandard Standard mass fraction organic carbon in soil/sediment [-]
#' @param rhoMatrix density of the matrix
#' @param Matrix compartment type considered 
#' @param SpeciesName species name considered
#' @return Degradation rate constant for molecular species
#' @export
KdegDorC <- function(kdeg, C.OHrad.n, k0.OHrad, Ea.OHrad, T25, 
                          Q.10, KswDorC, Biodeg, CorgStandard, rhoMatrix,
                          Matrix, SpeciesName) {
  if (SpeciesName %in% c("Molecular")) {
    
    switch(Matrix,
           "sediment" = { 
             if(is.na(kdeg)){
               switch (Biodeg,
                       "r" = { a = # following table 5 in report 2015-0161
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,30,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,300,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,3000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,30000,NA))))}, # ready-biodegradable
                       "r-" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,90,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,900,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,9000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,90000,NA))))}, # ready-biodegradable (r-) substances failing the ten-day window
                       "i" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,300,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,3000,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,30000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,300000,NA))))}, # inherently biodegradable
                       "p" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,300,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,3000,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,30000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,300000,NA)))) }) # persistent
               return(0.1*Q.10^(13/10)*log(2)/a/(3600*24)) } else return(kdeg)
           },
           "soil" = {
             if(is.na(kdeg)){
               switch (Biodeg,
                       "r" = { a = # following table 5 in report 2015-0161
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,30,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,300,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,3000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,30000,NA))))}, # ready-biodegradable
                       "r-" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,90,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,900,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,9000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,90000,NA))))}, # ready-biodegradable (r-) substances failing the ten-day window
                       "i" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,300,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,3000,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,30000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,300000,NA))))}, # inherently biodegradable
                       "p" = { a = 
                         ifelse(KswDorC/CorgStandard*rhoMatrix/1000<100,300,
                                ifelse(KswDorC/CorgStandard*rhoMatrix/1000<1000,3000,
                                       ifelse(KswDorC/CorgStandard*rhoMatrix/1000<10000,30000,
                                              ifelse(KswDorC/CorgStandard*rhoMatrix/1000>100000,300000,NA)))) }) # persistent
               return(Q.10^(13/10)*log(2)/a/(3600*24)) } else return(kdeg)
           },
           "water" = {
             if(is.na(kdeg)){
               switch (Biodeg,
                       "r" = { Q.10^(13/10)*log(2)/15/(3600*24) }, # ready-biodegradable
                       "r-" = { Q.10^(13/10)*log(2)/50/(3600*24) }, # ready-biodegradable (r-) substances failing the ten-day window
                       "i" = { Q.10^(13/10)*log(2)/150/(3600*24) }, # inherently biodegradable
                       "p" = { 1e-20 }) } else return(kdeg) # persistent
           },
           "air" = {
             if(is.na(kdeg)){
               return(C.OHrad.n * k0.OHrad * exp(-Ea.OHrad/(constants::syms$r*T25)))
             } else return(kdeg)
           })
  } else { 
    switch(Matrix, # particulate
           "air" = kdeg,
           "soil" = kdeg,
           "sediment" = kdeg,
           "water" = kdeg,
           return(NA)
    )
  }
  
}