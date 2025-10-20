
#' @title EmissionScript
#' @description Maakt historisch en toekomst emissie dataframe voor SimpleBox PFAS in oppervlaktewater project
#' @param GlobalEmission Totale wereldwijde emissies in kg
#' @param time_steps de tijdsstappen van de dataframe
#' @param ReductionDuration het aantal jaar waarin het toekomstscenario afbouwt
#' @param TotalReduction in procenten het uiteindelijke doel van de reductie, bijvoorbeeld na 30 jaar 95% afgenomen
#' @param StepDuration Het aantal stappen waarin afgebouwd wordt in de ReductionDuration
#' @param ReductionFractions vector met de fracties die het formaat van elke reductiestap aangeven, bijv vector[1] = reductiestap 1 is 30% van Total reduction
#'
#' @return EmissionsDataframe

sb_emission_df <- function(GlobalEmission, time_steps, EmissionDuration, TotalRuntime, SubCompartments = c('a', 's2', 's1', 's3', 'w0', 'w1', 'w2', 'w3'),
                           ReductionDuration = 30, TotalReduction = 95, ReductionSteps = 3, StepDuration = c(10,10,10), ReductionFractions = c(0.33, 0.33, 0.33)) {
  #Voorwaarden voor runnen
  if (length(ReductionFractions) != ReductionSteps)  {
    #ReductionSteps niet hetzelfde als het aantal fracties
    stop("Het aantal opgegeven fracties is niet hetzelfde als de aantal [ReductionSteps]")
  }
  if (sum(ReductionFractions) < 0.99) {
    #Som reductieFracties te laag
    stop("De som van de reductiefracties < 0.99")
  }
  
  #Dataframe met oppervlaktes per schaal en subcompartiment
  areas = World$fetchData("TotalArea")
  areas <- areas %>%
    mutate(TotalArea = TotalArea/sum(areas$TotalArea)) 
  print("Area fractions:")
  print(areas)
  
  subcompartments_data <- read.csv("data/SubCompartSheet.csv") |>
    dplyr::select(SubCompartName, AbbrC) |>
    rename(Abbreviation = AbbrC) |>
    rename(SubCompartment = SubCompartName)
  SubCompartArea = World$fetchData("Area") %>%
    merge(subcompartments_data, by.x="SubCompart", by.y="SubCompartment")
  
  #1 Dataframe met historische emissies obv GlobalEmission
  ##Verdeling van GlobalEmission: 1/3 naar zowel bodem, lucht als water
  emissions <- data.frame()
  
  for (schaal in c("A", "C", "M", "R", "T")) {
    #Global emission schalen naar 'schaal'
    EmissieSchaal = areas %>%
      filter(substr(Scale,1,1) == schaal)
    EmissieSchaal = GlobalEmission * EmissieSchaal$TotalArea
    check = 0
    cat(paste0("Schaal: ", schaal," - ", GlobalEmission,"/",round(EmissieSchaal,2), "\t(", round((EmissieSchaal*100/GlobalEmission),5),"%)\n"))
    for (subcompartment in SubCompartments) {
      #Bepaal voor subcompartiment het aandeel van GlobalEmissions
      location = paste0(subcompartment, schaal, 'U')
      if (subcompartment == "a") {
        To_Filter = "a"
      } else {
        To_Filter = paste0(substr(subcompartment, 1,1), "[0-9]")
      }
      emi = filter(SubCompartArea, substr(Scale, 1, 1) == schaal) %>%
        filter(grepl(To_Filter, Abbreviation))
      
      if ((nrow(emi) == 1) & any((emi$Abbreviation == subcompartment))) {
        emi_value = EmissieSchaal / 3
      } else if ((nrow(emi) > 1) & (subcompartment %in% emi$Abbreviation)) {
        summed = sum(emi$Area)
        emi <- emi %>%
          filter(Abbreviation == subcompartment) %>%
          mutate(AreaFraction = Area / summed)
        emi_value = EmissieSchaal / 3* emi$AreaFraction
        emi_value <- sum(emi_value)
      } else {
        next
      }
      #Maak dataframe voor schaal en subcompartiment waarbij globale emissie proportioneel is verdeeld
      emission_x <- expand.grid(
        Emis = emi_value,
        Abbr = location,
        Time = 1:EmissionDuration
      )
      emissions <- bind_rows(emissions, emission_x)
      check <- check + emi_value
    }
    #Als verdeling niet klopt, stoppen
    if (abs(EmissieSchaal-check) > 1) {
      print(paste0("difference emission and check: ", EmissieSchaal-check))
      stop(paste("Te groot verschil in verdeelde emissies en emissies voor schaal", schaal))
    }
  }

  #2 Dataframe met afbouwende emissies volgens input
  lastemi <- emissions %>%
    filter(Time == EmissionDuration)
  var <- emissions %>%
    filter(Time == EmissionDuration)
  Hist_Futu_emissions <- emissions
  last_reduction = 0
  
  for (step in 1:ReductionSteps) {
    timewindow <- (var$Time[1]+1):(var$Time[1]+1+StepDuration[step]-1)
    reduction_x <- ((100-(TotalReduction*ReductionFractions[step])) /100) - last_reduction
    print(timewindow)
    print(reduction_x) 
    last_reduction <- 1-reduction_x
    
    emi_future <- lastemi %>%
      slice(rep(1:n(), each=length(timewindow))) %>%
      mutate(Time = rep(timewindow, times=nrow(lastemi)),
             Emis = Emis * reduction_x)
    var <- emi_future %>%
        filter(Time == tail(timewindow, 1))
    Hist_Futu_emissions <- bind_rows(Hist_Futu_emissions, emi_future)
  }
  
  Grouped <- Hist_Futu_emissions %>%
    group_by(Time) %>%
    summarise(Emis_sum = sum(Emis))
  
  
  
  
  ggplot(Grouped, aes(x=Time, y=Emis_sum)) +
    geom_line() +
    labs(title="Emissies op alle schalen", x="Tijd", y="Emissies [kg]") +
    theme_minimal()
  
  return(Hist_Futu_emissions)  
}  
 