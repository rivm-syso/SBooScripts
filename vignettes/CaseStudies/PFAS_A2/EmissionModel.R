"Script om emissies te berekenen:"
library(ggplot2)
library(reshape2)
library(readxl)

##Simple1 scenario is wereldwijde constante 30 ton aan emissies voor 50 jaar, de 30 ton is verdeeld over de compartimenten op basis van hun oppervlakte.
##prob_nruns is het aantal runs voor rekenen met onzekerheid

emission_fun <- function  (plot=FALSE, runtime=140, Wereldwijd=TRUE, scenario ='simple1', prob_nruns=0) {
  if (prob_nruns != 0) {
    prob = TRUE
  } else {
    prob=FALSE
  }
  #Functie om dataframe te maken met input: emis per tijdstap, locatie. 
  #Geeft ook prob_nruns mee, blijkt niet nodig. 
  make_emission_df <- function(emis, time_steps, location, scale, prob_nruns, prob) {
    #Schalen naar oppervlakte
    areas = World$fetchData("TotalArea")
    areas <- areas %>%
      mutate(TotalArea = TotalArea/sum(areas$TotalArea)) %>%
      filter(Scale == scale)
    
    #Probabilistisch dataframe
    if (prob) {
      emission <- expand.grid(
        Emis = emis*areas$TotalArea,
        Abbr = location,
        Time = 1:time_steps,
        RUN = 1:prob_nruns
      )
    
      empty_emission <- expand.grid(
        Time = seq(from = time_steps + 1, to = runtime),
        Abbr = location,
        RUN = 1:prob_nruns
      )
      empty_emission$Emis <- 0
    
    #Deterministisch dataframe
    } else {
      emission <- expand.grid(
        Emis = emis*areas$TotalArea,
        Abbr = location,
        Time = 1:time_steps
      )
      
      empty_emission <- expand.grid(
        Time = seq(from = time_steps + 1, to = runtime),
        Abbr = location
      )
      empty_emission$Emis <- 0
    }
    # empty_start <- expand.grid(
    #   Emis = 0,
    #   Abbr = location,
    #   Time = 0,
    #   RUN = 1:prob_nruns
    # )
    
    #VOlle emissie dataframe aan lege dataframe knopen
    emission <- bind_rows(emission, empty_emission)
    return(emission)
  }  
  
  #Functie aanroepen om voor alle locaties schalen/compartiment combi's dataframes te maken
  if (scenario == 'simple1') {
    #Simpel scenario met wereldwijde constante 30 ton emissies voor een bepaalde tijd 
    emissions_regional_wat <- make_emission_df(30000, 50, c("w0RU", "w1RU", "w2RU"), "Regional", prob_nruns, prob)
    emissions_regional_air <- make_emission_df(30000, 50, c("aRU"), "Regional", prob_nruns, prob)
    
    emissions_continental_wat <- make_emission_df(30000, 50, c("w0CU", "w1CU", "w2CU"), "Continental", prob_nruns, prob)
    emissions_continental_air <- make_emission_df(30000, 50, c("aCU"), "Continental", prob_nruns, prob)
    
    emissions_moderate_wat <- make_emission_df(30000, 50, c("w0MU", "w1MU", "w2MU"), "Moderate", prob_nruns, prob)
    emissions_moderate_air <- make_emission_df(30000, 50, c("aMU"), "Moderate", prob_nruns, prob)
    
    emissions_tropic_wat <- make_emission_df(30000, 50, c("w0TU", "w1TU", "w2TU"), "Tropic", prob_nruns, prob)
    emissions_tropic_air <- make_emission_df(30000, 50, c("aTU"), "Tropic", prob_nruns, prob)
    
    emissions_arctic_wat <- make_emission_df(30000, 50, c("w0AU", "w1AU", "w2AU"), "Arctic", prob_nruns, prob)
    emissions_arctic_air <- make_emission_df(30000, 50, c("aAU"), "Arctic", prob_nruns, prob)
    emissions <- bind_rows(emissions_regional_wat, emissions_regional_air,
                           emissions_continental_wat, emissions_continental_air,
                           emissions_moderate_wat, emissions_moderate_air,
                           emissions_tropic_wat, emissions_tropic_air,
                           emissions_arctic_wat, emissions_arctic_air)
    #Waardes omzetten
    MW = World$fetchData('MW')
    print(MW)
    emissions <- emissions |>
      mutate(Time = Time*(365.25*24*60*60)) |> # Convert time from y to s
      ungroup() |>
      mutate(Emis = Emis*1000/(MW*365*24*60*60))  #|> #MW =500 # convert 1 t/y to si units: kg/s
      # full_join(expand.grid(Abbr=unique(emissions$Abbr)) |>
      #             mutate(Time = 0,
      #                    Emis = 0,
      #                    RUN = rep(1:prob_nruns, times=prob_nruns)))
    
    #Lege start 'stap' toevoegen
    if (prob) {
      empty_start = expand.grid(
        Emis=0,
        Abbr=unique(emissions$Abbr),
        Time=0,
        RUN = 1:prob_nruns
      )
    } else {
      empty_start = expand.grid(
        Emis=0,
        Abbr=unique(emissions$Abbr),
        Time=0)
    }
    
    #Dataframes aan elkaar knopen
    emissions <- bind_rows(empty_start, emissions)
    return(emissions)
  }
  
  #Ander scenario
  if (scenario =='simple2') {
    emissions_simple <- data.frame(Abbr = c("aRU", "s2RU", "s1RU", "s3RU", "w0RU", "w1RU", "w2RU",
                                            "aCU", "s2CU", "s1CU", "s3CU", "w0CU", "w1CU", "w2CU"), 
                                   Emis = c(2, 0.5, 0.5, 0.5, 0.1, 0.1, 0.10, 
                                            124.5, 15.38271, 15.38271, 15.38271, 95, 95, 95))
    emissions_simple <- emissions_simple |>
      mutate(Emis = Emis*1000/(365*24*60*60))
    return(emissions_simple)
  }
  
  
  ##UIT POPE
  print("Emissie PFOA berekenen a.h.v. POPE model....")
  Rhine <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/Rhine.shp")
  Meuse <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/Meuse.shp")
  Nederland <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/landgrenzen.shp")
  Europe <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/europa_bereik_2.shp")
  nc <- nc_open("/rivm/biogrid/quikj/PFAS_A2/Emissions/POPE_Glb_0.5x0.5_anthro_PFOA_v1_yearly.nc")
  emissies_jm <- read_excel("/rivm/biogrid/quikj/PFAS_A2/Emissions/A_emission_phase_out_2003_scenario_20240321.xlsx", sheet = 'total emission_plat')
  Europe <- st_set_crs(Europe, 3035)
  Europe <- st_transform(Europe, 4326)
  
  #sink('POPE_emission_PFOA_metadata.txt')
  #print(nc)
  #sink()
  
  lat <- ncvar_get(nc, 'latitude')
  lon <- ncvar_get(nc, 'longitude')
  
  #Extract best guess variables 
  #To plot total over 70 years turn apply function on and remove 3 dimension in values array
  values <- array(0, dim = c(720, 360, 70))
  emission <- data.frame(
    year = 1:dim(values)[3])
  print("Door tijdsdimensie loopen en emissie dataframe maken....")
  
  if (catchment == "Rhine") {
    shape = Rhine
  } else if (catchment == "Meuse") {
    shape = Meuse
  } else if (catchment == "Europe") {
    shape = Europe
  }
  
  #loopen door variablen en masken op 'catchment'
  sum_raster = array(0, dim= c(720, 360))
  for (name in names(nc$var)){
    print(name)
    if (grepl("BB$", name)) {
      var_data.array <- ncvar_get(nc, name)
      sum_slice <- apply(var_data.array, c(1, 2), sum, na.rm = TRUE) * 10^9
      sum_raster <- sum_raster + sum_slice
      for (i in 1:dim(values)[3]) {
        var_data.slice <- var_data.array[,,i]
        r <- raster(t(var_data.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
        r <- flip(r, direction='y')
        mask <- mask(r, shape)
        emission[i, paste0(name, '_global')] <- cellStats(r, stat='sum', na.rm=TRUE) * 10^9 #tonnes
        emission[i, name] <- cellStats(mask, stat="sum", na.rm=TRUE)* 10^9 #From Teragrams to tonnes
      }
    }
  }
  "cumulative / added up"
  
  emission$sum_wat <- rowSums(emission[, -1][, grepl("wat", names(emission)[-1]) & !grepl("global", names(emission)[-1])], na.rm = TRUE)
  emission$sum_air <- rowSums(emission[, -1][, grepl("air", names(emission)[-1]) & !grepl("global", names(emission)[-1])], na.rm = TRUE)
  emission$sum_wat_global <- rowSums(emission[, -1][, grepl("wat", names(emission)[-1]) & grepl("global", names(emission)[-1])], na.rm = TRUE)
  emission$sum_air_global <- rowSums(emission[, -1][, grepl("air", names(emission)[-1]) & grepl("global", names(emission)[-1])], na.rm = TRUE)
  
  
  #Plotting
  
  "plot line graph Chosen shape/range e.g. (rhine, meuse or europe)"
  if (plot == TRUE) {
    ggplot(emission)+
      geom_line(aes(x=year, y =sum_wat, color="water emission")) +
      geom_line(aes(x=year, y=sum_air, color="Air emission")) +
      labs(title= "PFOA emission Rhine catchment (1951-2020)",
           x="Years", y="Emission T/yr", color = "Legenda")
    
    "Global"
    ggplot(emission)+
      geom_line(aes(x=year, y =sum_wat_global, color="water emission")) +
      geom_line(aes(x=year, y=sum_air_global, color="Air emission")) +
      labs(title= "PFOA emission Global (1951-2020)",
           x="Years", y="Emission T/yr", color= "Legenda")
    
  }
  
  "Dataframes maken obv scenario en schaal"
  "Globale emissie moet geemitteerd worden op elke schaal obv formaat schaal"
  "ook is SB ongeveer helft van werkelijke aarde... Hoe hier mee omgaan"
  
  
  
  if (Wereldwijd == TRUE) {
    "making dataframe fit for SB"
    emissions_air_continental <- make_emission_df(emission$sum_air_global, 70, c("aCU"), "Continental")
    emissions_water_continental <- make_emission_df(emission$sum_wat_global, 70, c("w0CU", "w1CU", "w2CU"), "Continental")
    
    emissions_air_regional <- make_emission_df(emission$sum_air_global, 70, c("aRU"), "Regional")
    emissions_water_regional <- make_emission_df(emission$sum_wat_global, 70, c("w0RU", "w1RU", "w2RU"), "Regional")
    
    emissions_air_tropic <- make_emission_df(emission$sum_air_global, 70, c("aTU"), "Tropic")
    emissions_water_tropic <- make_emission_df(emission$sum_wat_global, 70, c("w0TU", "w1TU", "w2TU"), "Tropic")
    
    emissions_air_moderate <- make_emission_df(emission$sum_air_global, 70, c("aMU"), "Moderate")
    emissions_water_moderate <- make_emission_df(emission$sum_wat_global, 70, c("w0MU", "w1MU", "w2MU"), "Moderate")
    
    emissions_air_arctic <- make_emission_df(emission$sum_air_global, 70, c("aAU"), "Arctic")
    emissions_water_arctic <- make_emission_df(emission$sum_wat_global, 70, c("w0AU", "w1AU", "w2AU"), "Arctic")
    
    emissions <- bind_rows(emissions_air_continental, emissions_water_continental,
                           emissions_air_regional, emissions_water_regional,
                           emissions_air_tropic, emissions_water_tropic,
                           emissions_air_moderate, emissions_water_moderate,
                           emissions_air_arctic, emissions_water_arctic)
    
  } else if (Wereldwijd == FALSE) {
    emissions <- data.frame(
      Emis = emission$sum_air, ##Tonnes/year 
      Time = 1:nrow(emission),
      Abbr = rep(c("aRU", "aRU", "aRU", "aRU", "aRU"), times = nrow(emission) / 5)
    ) 
    
    rows <- data.frame(
      Emis = 0,
      Time = seq(from = nrow(emission) + 1, to = runtime),
      Abbr = rep(c("aRU", "aRU", "aRU", "aRU", "aRU"), times = nrow(emission) / 5)
    )
  }
  
  "Emissies Joris Meester Simplebox validation PFOA"
  "Vergelijken met POPE"
  if (plot==TRUE) {
    emission$Year <- seq(from=1951, to=1951+nrow(emission)-1)
    merge = left_join(emissies_jm, emission[, c("sum_wat", "sum_air", "Year")], by = "Year")
    ggplot()+
      geom_line(data = merge, aes(x=Year, y =`High Air (t/y)` * 10^3, color="RIVM Lucht")) +
      geom_line(data = merge, aes(x=Year, y = `High Water (t/y)` * 10^3, color="RIVM Water")) +
      geom_line(data = merge, aes(x=Year, y = sum_wat, color="POPE Water")) +
      geom_line(data = merge, aes(x=Year, y = sum_air, color="POPE Lucht")) +
      labs(title= "Emissies in Europa - RIVM / POPE model - (1951-2020)",
           x="Jaren", y="Emissies kg/yr")
    'Conclusie POPE model en ValidationSB emissies zijn aardig vergelijkbaar met elkaar'
    
  }
 
  #Converting times and emis:
  MW = World$fetchData('MW')
  
  emissions <- emissions |>
    mutate(Time = Time*(365.25*24*60*60)) |> # Convert time from y to s
    ungroup() |>
    mutate(Emis = Emis*1000/(MW*365*24*60*60)) |> #MW =500 # convert 1 t/y to si units: kg/s
    full_join(expand.grid(Abbr=unique(emissions$Abbr)) |>
                mutate(Time = 0,
                       Emis = 0))
  
  "close down vars..."
  print("closing NC file and Vars....")
  remove(mask, nc, r, var_data.slice, values, var_data.array, lat, lon, name)
  
  
  
  
 return(emissions) 
} 





