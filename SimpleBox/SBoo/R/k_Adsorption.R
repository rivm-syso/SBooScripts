#'@title Adsorption of chemical to across an interface
#'@name k_Adsorption
#'@description The adsorption rate constant (k_Adsorption) is calculated based on the principles of gas absorption as described by Hollander
#'et al. (2004) 10.1080/10629360412331297470 & Hollander et al. (2007) https://doi.org/10.1016/j.envpol.2006.09.018
#'@param FRinw fraction of species in water,see FRinw()
#'@param MTC_2sd mass transfer coefficient to sediment, see MTC_2sd()
#'@param MTC_2w mass transfer coefficient to water, see SBvariable
#'@param MTC_2a mass transfer coefficient to air, see SBvariable
#'@param MTC_2s mass transfer coefficient to soil, see SBvariable
#'@param FRorig fraction of species in original form, see SBvariable
#'@param Kacompw partitioning coefficient for air, see SBvariable
#'@param Kscompw partitioning coefficient for soil, see SB variable 
#'@param Matrix Receiving compartment type 
#'@param to.Area Area of the receiving compartent
#'@param VertDistance Vertical distance of the compartment 
#'@param AreaLand calculated land area of the scale considered, see SBvariable
#'@param AreaSea calculated sea area of the scale considered, see SBvariable 
#'@param FRorig_spw fraction of original species in soil pore water 
#'@param SubCompartName name of the subcompartname that is from/to 
#'@param ScaleName name of scale
#'@param Test Test = TRUE or FALSE, depending on if SBExcel version should be copied
#'@returns The adsorption rate constant relevant for the receiving compartments soil, water or sediment [s-1]
#'@export
k_Adsorption <- function (FRingas, FRinw, from.MTC_2sd, to.FRorig_spw,
                          to.MTC_2w, from.MTC_2w, to.MTC_2a, from.MTC_2s, to.FRorig, Kacompw, 
                          to.Kscompw, to.Matrix, VertDistance, 
                          AreaLand, AreaSea, to.Area, all.FRorig, all.FRorig_spw,
                          from.SubCompartName, to.SubCompartName, ScaleName, Test) {
  if ((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & from.SubCompartName == "sea") {
    return(NA)
  }
  switch(to.Matrix,
         
         "water" = { # air to water
           if (ScaleName %in% c("Regional", "Continental")){
             if (as.character(Test) == "TRUE"){
               to.FRorig <-  all.FRorig |>
                 filter(SubCompart == "river") 
               to.FRorig <- to.FRorig$FRorig
             } 
           }
           GASABS = FRingas*(from.MTC_2w*to.MTC_2a/(from.MTC_2w*(Kacompw*to.FRorig)+to.MTC_2a))
           AreaFrac = to.Area/(AreaLand+AreaSea)
           return(GASABS/VertDistance*AreaFrac) },
         "soil" = { # air to soil
           if (as.character(Test) == "TRUE"){
             to.FRorig_spw <- all.FRorig_spw |>
               filter(SubCompart == "naturalsoil")
             to.FRorig_spw <- to.FRorig_spw$FRorig_spw
           } 
           GASABS = FRingas*(from.MTC_2s*to.MTC_2a)/(from.MTC_2s*(Kacompw*to.FRorig_spw)/to.Kscompw+to.MTC_2a)
           AreaFrac = to.Area/(AreaLand+AreaSea)
           return(GASABS/VertDistance*AreaFrac) },
         "sediment" = { # water to sediment
           ADSORB = (from.MTC_2sd*to.MTC_2w)/(from.MTC_2sd+to.MTC_2w)*FRinw
           if (as.character(Test) == "TRUE" && to.SubCompartName == "lakesediment"){
             return(NA)
           } else {
              return(ADSORB/VertDistance) 
           }
          }, 
         return(NA)
  )
  
}
