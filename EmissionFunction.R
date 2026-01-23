
#' @title EmissionScript
#' @description Maakt historisch en toekomst emissie dataframe voor SimpleBox PFAS in oppervlaktewater project
#' @param GlobalEmission Totale wereldwijde emissies in kg
#' @param time_steps de tijdsstappen van de dataframe
#' @param ReductionDuration het aantal jaar waarin het toekomstscenario afbouwt
#' @param TotalReduction in procenten het uiteindelijke doel van de reductie, bijvoorbeeld na 30 jaar 95% afgenomen
#' @param StepDuration Het aantal stappen waarin afgebouwd wordt in de ReductionDuration, standaard is equal waarbij gelijk wordt verdeeld, alternatief is vector
#' @param ReductionFractions vector met de fracties die het formaat van elke reductiestap aangeven, bijv vector[1] = reductiestap 1 is 30% van Total reduction standaard is equal waarbij gelijk wordt verdeeld, alternatief is vector
#'
#' @return EmissionsDataframe
# 
# result = sb_emission_df(GlobalEmission = 457.2, SelectScales=c("A", "M", "T", "R", "C"),
#                         time_steps= nTIMES, EmissionDuration = EmissionDuration, start_year = start_year, TotalRuntime = runtime,
#                         ReductionDuration = scenario[[1]], TotalReduction = scenario[[2]], ReductionSteps =scenario[[3]],
#                         StepDuration = 'equal', ReductionFractions = scenario[[4]], PlotTitle = scenario[[5]])


sb_emission_df <- function(GlobalEmission, EuropeFraction =NULL, SelectScales=c("A", "C", "M", "R", "T"), time_steps, EmissionDuration, start_year,
                           TotalRuntime, SubCompartments = c('a', 's2', 's1', 's3', 'w0', 'w1', 'w2', 'w3'),
                           ReductionDuration, TotalReduction, ReductionSteps, StepDuration='equal', ReductionFractions='equal',
                           rc = NULL, PlotTitle = "Emissies op alle schalen", number_runs=FALSE) {
  print("Emissie dataframe maken met afbouwend scenario op basis van gegeven input")
  print("GlobalEmission wordt naar oppervlakte over de schalen verspreidt, binnen een schaal gaat 1/3 naar zowel bodem, lucht en water")
  #prob runnen:
  if (is.numeric(number_runs)){
    prob = TRUE
    runs = number_runs 
  } else if (number_runs == FALSE) {
    prob = FALSE
  }
  
  #Lineair of exponentieel verlagen van emissies
  if (any(ReductionFractions == 'equal')) {
    ReductionFractions = rep((TotalReduction/100)/ReductionSteps, ReductionSteps)
  }
  if ((ReductionSteps != 0) & (any(StepDuration == 'equal'))) {
    StepDuration = rep(ReductionDuration/ReductionSteps, ReductionSteps)
    
  }
  
  if ((any(ReductionFractions == 'exponential')) & (!is.null(rc))) {
    exponential = TRUE
    ReductionFractions <- rc^(0:(ReductionSteps-1))
    ReductionFractions <- ReductionFractions / sum(ReductionFractions) 
  } else {
    exponential = FALSE
  }
  
  #Voorwaarden voor runnen
  if ((ReductionSteps != 0) & (length(ReductionFractions) != ReductionSteps))  {
    #ReductionSteps niet hetzelfde als het aantal fracties
    stop("Het aantal opgegeven fracties is niet hetzelfde als de aantal [ReductionSteps]")
  }
  # if (sum(ReductionFractions) < 0.99) {
  #   #Som reductieFracties te laag
  #   stop("De som van de reductiefracties < 0.99")
  # }
  
  #Dataframe met oppervlaktes per schaal en subcompartiment
  #Indien EuropeFraction verhoog de fractie Continental en Regional om meer van globale emissies in EU te laten plaats vinden
  areas = World$fetchData("TotalArea")
  TotalArea <- sum(areas$TotalArea)
  
  #EuropeFraction verwerken zodat meer emissie naar europa gaat
  if (!is.null(EuropeFraction)) {
    Europe_toevoeging <- TotalArea * (EuropeFraction/100)
    Continental_Regional <- areas %>%
      filter(Scale == 'Continental' |
             Scale == 'Regional') 
    Continental <- Continental_Regional %>%
      mutate(TotalArea = TotalArea/sum(Continental_Regional$TotalArea)) %>%
      filter(Scale=='Continental') %>%
      mutate(Toevoeging = TotalArea * Europe_toevoeging) %>%
      pull(Toevoeging)
    Regional <- Continental_Regional %>%
      mutate(TotalArea = TotalArea/sum(Continental_Regional$TotalArea)) %>%
      filter(Scale=='Regional') %>%
      mutate(Toevoeging = TotalArea * Europe_toevoeging) %>%
      pull(Toevoeging)
    areas$TotalArea[areas$Scale=="Regional"] <- areas$TotalArea[areas$Scale=="Regional"]+Regional
    areas$TotalArea[areas$Scale=="Continental"] <- areas$TotalArea[areas$Scale=="Continental"]+Continental
  }
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
  
  for (schaal in SelectScales) {
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
      if (prob) {
      emission_x <- expand.grid(
        Emis = emi_value,
        Abbr = location,
        Time = 1:EmissionDuration,
        RUN=c(1:runs)
      )
      } else {
        emission_x <- expand.grid(
          Emis = emi_value,
          Abbr = location,
          Time = 1:EmissionDuration
        )
      }
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
  #Frame om toekomst aan toe te voegen
  Hist_Futu_emissions <- emissions
  #Exponentiele reeks staat al goed voor vermenigvuldiging met startwaarde, dit ook doen voor fractions
  print(ReductionFractions)
  if (any(ReductionDuration != '-')) {
    if (!exponential) {
      #Omzetten naar fracties op startwaarde
      tol <- .Machine$double.eps^0.5
      if (abs(sum(ReductionFractions) - (TotalReduction/100)) < tol) {
        Fraction_same_as_TotalReduction = TRUE
      } else {
        print("Waarschuwing: TotalReduction niet hetzelfde als totaal van ReductionFractions")
        Fraction_same_as_TotalReduction = FALSE
      }
      ReductionFractions = cumsum(ReductionFractions)
      ReductionFractions = 1-ReductionFractions
    } 
  
    #Laatste tijdstap van emissies
    lastemi <- emissions %>%
      filter(Time == EmissionDuration)
    
    #Variabele dataframe om nieuwe timewindow te definieren
    var <- emissions %>%
      filter(Time == EmissionDuration)
    
    #Loop
    for (step in 1:ReductionSteps) {
      timewindow <- (var$Time[1]+1):(var$Time[1]+1+StepDuration[step]-1)
      
      #Reduction_x maken
      if (ReductionFractions[step] > 1) {
        reduction_x <- ReductionFractions[step]
        print("Waarschuwing: Stijgende emissie in ReductionFractions")
      } else if (exponential) {
        reduction_x <- (TotalReduction/100) * (ReductionFractions[step])
      } else {
        if (Fraction_same_as_TotalReduction) {
          reduction_x <- ReductionFractions[step]
        } else {
          reduction_x <- (TotalReduction/100) * (ReductionFractions[step])
        }
        if (ReductionSteps != length(ReductionFractions)) {
          print("Waarschuwing: Reductiesteps is niet gelijk aan het aantal ReductieFractions")
        }
      }
      emi_future <- lastemi %>%
        slice(rep(1:n(), each=length(timewindow))) %>%
        mutate(Time = rep(timewindow, times=nrow(lastemi)),
               Emis = Emis * (reduction_x))
      #Update var voor timewindow
      var <- emi_future %>%
          filter(Time == tail(timewindow, 1))
      #Voeg toe aan output
      Hist_Futu_emissions <- bind_rows(Hist_Futu_emissions, emi_future)
    }
  }
  #Overblijvende runtime leeg toevoegen
  lasttime <-tail(Hist_Futu_emissions$Time, 1)
  lastemi <- Hist_Futu_emissions %>%
    filter(Time == lasttime)
  years <- seq(from = lasttime + 1, to = TotalRuntime)
  
  if (prob) {
    remaining_years <- data.frame(
      Abbr = rep(lastemi$Abbr, each = length(years)),
      Time = rep(years, times = length(lastemi$Abbr)),
      Emis = rep(lastemi$Emis, each = length(years)),
      RUN = rep(1:runs, each=length(years))
    )
  } else {
    remaining_years <- data.frame(
      Abbr = rep(lastemi$Abbr, each = length(years)),
      Time = rep(years, times = length(lastemi$Abbr)),
      Emis = rep(lastemi$Emis, each = length(years))
    )
  }
  Hist_Futu_emissions <-  bind_rows(Hist_Futu_emissions, remaining_years)
  
  if (!prob) {
    Grouped <- Hist_Futu_emissions %>%
      group_by(Time) %>%
      summarise(Emis_sum = sum(Emis)) %>%
      mutate(year = (start_year-1) + (Time),
             procent = 100*Emis_sum/GlobalEmission)
  } else {
    Grouped <- Hist_Futu_emissions %>%
      group_by(Time, Abbr) %>%
      summarise(mean_emis = mean(Emis),
                .groups = "drop") %>%
      group_by(Time) %>%
      summarise(Emis_sum = sum(mean_emis),
                .groups="drop") %>%
      mutate(year = (start_year-1) + (Time),
             procent = 100*Emis_sum/GlobalEmission)
  }
  
  p1 = ggplot(Grouped, aes(x=year, y=procent)) +
    geom_step() +
    labs(title=paste("Emissie Scenario:", PlotTitle), x="Jaar", y="Emissies [%]") +
    theme_minimal() +
    scale_x_continuous(breaks = seq(min(Grouped$year), max(Grouped$year), by = 5)) +
    scale_y_continuous(limits = c(0, NA)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  p2 <- ggplot(Grouped[1:35, ], aes(x=year, y=procent)) +
    geom_line() +
    labs(title=paste("Emissie Scenario:", PlotTitle), x="Jaar", y="Emissies [%]") +
    theme_minimal() +
    scale_x_continuous(breaks = seq(min(Grouped$year), max(Grouped$year), by = 5)) +
    scale_y_continuous(limits = c(0, NA)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    annotate("text", x = 2040, y = 80, label = "Modeltijd 2020-2175 →", hjust = 0, vjust = -1)
  
  #Omzetten naar juiste eenheden en lege start toevoegen
  MW = World$fetchData('MW')
  if (prob) {
    Hist_Futu_emissions <- Hist_Futu_emissions |>
      mutate(Time = Time*(365.25*24*60*60)) |> # Convert time from y to s
      ungroup() |>
      mutate(Emis = Emis*1000/(MW*365*24*60*60)) |> #MW =500 # convert 1 t/y to si units: kg/s
      full_join(expand.grid(Abbr=unique(emissions$Abbr),
                            RUN=c(1:runs)) |>
                  mutate(Time = 0,
                         Emis = 0))
  } else {
    Hist_Futu_emissions <- Hist_Futu_emissions |>
      mutate(Time = Time*(365.25*24*60*60)) |> # Convert time from y to s
      ungroup() |>
      mutate(Emis = Emis*1000/(MW*365*24*60*60)) |> #MW =500 # convert 1 t/y to si units: kg/s
      full_join(expand.grid(Abbr=unique(emissions$Abbr)) |>
                  mutate(Time = 0,
                         Emis = 0))
  }
  
 
  #Plotten
  
  
 
  procenten <- c()
  for (i in 1:(nrow(Grouped)/1)) {
    procenten <- append(procenten, (paste0("Afname% in ", Grouped$year[seq(1, length(Grouped$year), by = 1)][i], " = ", Grouped$procent[seq(1, length(Grouped$procent), by = 1)][i])))
  }
  
  
  return(list(plot=p1, emissions= Hist_Futu_emissions, procenten=procenten, plot_25j = p2))  
}  


get_reduction_steps <- function(sheet_name, variable, start, end) {
 
  path="/rivm/biogrid/quikj/PFAS_A2/data/emissions_stock_cumulative_stock_scenarios_A_F.xlsx"
  if (file.exists(path)) {
    print("emissions_stock_cumulative_stock_scenarios_A_F.xlsx laden vanuit BioGrid...")
    headers <- read_xlsx(path, sheet = sheet_name, n_max = 2, col_names = FALSE)
    header1 <- as.character(headers[1,])
    header1 <- tidyr::fill(data.frame(h = header1), h, .direction = "down")$h
    header2 <- as.character(headers[2,])
    combined_names <- ifelse(
      is.na(header1) | header1 == "",
      header2,
      paste(header1, header2, sep = " ")
    )
    combined_names <- combined_names %>%
      str_replace_all("NA", "") %>%
      str_replace_all(" +", " ") %>%
      str_trim()
    data <- suppressMessages(read_xlsx(path, sheet = sheet_name, skip = 2, col_names = FALSE))
    colnames(data) <- combined_names
    data <- data[-1,]
  } else {
    stop("emissions_stock_cumulative_stock_scenarios_A_F.xlsx niet gevonden...")
  }
  
  startingpoint <- data[[variable]][(start+1-as.numeric(data$Year[1]))]
  reduction = data.frame(
    variable = data[[variable]][(start+1-as.numeric(data$Year[1])):(end+1-as.numeric(data$Year[1]))]
  )
  reduction <- mutate(reduction, procent = (100*reduction$variable/startingpoint)/100)
  reduction$perc_change <- c(0, diff(reduction$procent) / head(reduction$procent, -1) * 100)
  
  return(reduction$procent)
}
  # #Area fraction
  # subcompartments_data <- read.csv("data/SubCompartSheet.csv") |>
  #   dplyr::select(SubCompartName, AbbrC) |>
  #   rename(Abbreviation = AbbrC) |>
  #   rename(SubCompartment = SubCompartName)
  # SubCompartArea = World$fetchData("Area") %>%
  #   merge(subcompartments_data, by.x="SubCompart", by.y="SubCompartment") %>%
  #   filter(Scale == "Arctic") 
  # areas <- SubCompartArea %>%
  #   mutate(Area = Area/sum(SubCompartArea$Area)) 
  # 
  # #Cumulative wereldwijde emissies in ton als startpunt emissie dataframe
  # if (bound=='average') {
  #   cumulative_emission <- mean(
  #     c(
  #       data$`Lower cumulative stock estimate at global scale (t.y) In total`[(start_year+EmissionDuration-1950)], 
  #       data$`Higher cumulative stock estimate at global scale (t.y) In total`[(start_year+EmissionDuration-1950)]
  #     )
  #   )
  #   soil <- rowMeans(
  #     cbind(
  #       data$`Lower dynamic stock estimate at global scale (t) In soil`, 
  #       data$`Higher dynamic stock estimate at global scale (t) In soil`
  #     ),
  #     na.rm=TRUE
  #   )
  #   water <- rowMeans(
  #     cbind(
  #       data$`Lower dynamic stock estimate at global scale (t) In water`, 
  #       data$`Higher dynamic stock estimate at global scale (t) In water`
  #     ),
  #     na.rm=TRUE
  #   )
  #   air <- rowMeans(
  #     cbind(
  #       data$`Lower dynamic stock estimate at global scale (t) In air`, 
  #       data$`Higher dynamic stock estimate at global scale (t) In air`
  #     ),
  #     na.rm=TRUE
  #   )
  #   sediment <- rowMeans(
  #     cbind(
  #       data$`Lower dynamic stock estimate at global scale (t) In sediment`, 
  #       data$`Higher dynamic stock estimate at global scale (t) In sediment`
  #     ),
  #     na.rm=TRUE
  #   )
  #   
  #   emissions <- data.frame(
  #     year = data$Year,
  #     soil = soil,
  #     water = water,
  #     air = air,
  #     sediment = sediment
  #   )
  #   
  # }
  # 
  # for (schaal in c("A", "M", "T")) {
  #   emissions <- data.frame()
  #   
  # }
