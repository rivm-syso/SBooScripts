"Script om emissies te berekenen:"
print("Emissie PFOA berekenen a.h.v. POPE model....")
library(ggplot2)
library(reshape2)
library(readxl)
Rhine <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Rhine.shp")
Meuse <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Meuse.shp")
Europe <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/europa_bereik_2.shp")
nc <- nc_open("vignettes/CaseStudies/PFAS Tjebbe/Emissions/POPE_Glb_0.5x0.5_anthro_PFOA_v1_yearly.nc")
emissies_jm <- read_excel("vignettes/CaseStudies/PFAS Tjebbe/Emissions/A_emission_phase_out_2003_scenario_20240321.xlsx", sheet = 'total emission_plat')
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
for (name in names(nc$var)){
  print(name)
  if (grepl("BB$", name)) {
    var_data.array <- ncvar_get(nc, name)
    sum_list = list()
    for (i in 1:dim(values)[3]) {
      var_data.slice <- var_data.array[,,i]
      r <- raster(t(var_data.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
      r <- flip(r, direction='y')
      mask <- mask(r, shape)
      emission[i, paste0(name, '_global')] <- cellStats(r, stat='sum', na.rm=TRUE) * 10^6 #tonnes
      emission[i, name] <- cellStats(mask, stat="sum", na.rm=TRUE)* 10^6 #From Teragrams to tonnes
    }
  }
}
"cumulative / added up"

emission$sum_wat <- rowSums(emission[, -1][, grepl("wat", names(emission)[-1]) & !grepl("global", names(emission)[-1])], na.rm = TRUE)
emission$sum_air <- rowSums(emission[, -1][, grepl("air", names(emission)[-1]) & !grepl("global", names(emission)[-1])], na.rm = TRUE)
emission$sum_wat_global <- rowSums(emission[, -1][, grepl("wat", names(emission)[-1]) & grepl("global", names(emission)[-1])], na.rm = TRUE)
emission$sum_air_global <- rowSums(emission[, -1][, grepl("air", names(emission)[-1]) & grepl("global", names(emission)[-1])], na.rm = TRUE)


#Plotting

# "plot line graph Chosen shape/range e.g. (rhine, meuse or europe)"
# ggplot(emission)+
#   geom_line(aes(x=year, y =sum_wat, color="water emission")) +
#   geom_line(aes(x=year, y=sum_air, color="Air emission")) +
#   labs(title= "PFOA emission Rhine catchment (1951-2020)",
#        x="Years", y="Emission T/yr")
# 
# "Global"
# ggplot(emission)+
#   geom_line(aes(x=year, y =sum_wat_global, color="water emission")) +
#   geom_line(aes(x=year, y=sum_air_global, color="Air emission")) +
#   labs(title= "PFOA emission Global (1951-2020)",
#        x="Years", y="Emission T/yr")

"Dataframes maken obv scenario en schaal"
"Globale emissie moet geemitteerd worden op elke schaal obv formaat schaal"
"ook is SB ongeveer helft van werkelijke aarde... Hoe hier mee omgaan"
make_emission_df <- function(emis, time_steps, location, scale) {
  areas = World$fetchData("TotalArea")
  areas <- areas %>%
    mutate(TotalArea = TotalArea/sum(areas$TotalArea)) %>%
    filter(Scale == scale)
  
  emission <- data.frame(
    Emis = rep(emis*areas$TotalArea, times= length(unique(location))),
    Time = rep(1:time_steps, times= length(unique(location))),
    Abbr = rep(location, each=time_steps)
  )
  empty_emission <- data.frame(
    Emis = 0,
    Time = seq(from = time_steps + 1, to = runtime),
    Abbr = rep(location, each=time_steps)
  )
  emission <- bind_rows(emission, empty_emission)
  return(emission)
}  

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
# emission$Year <- seq(from=1951, to=1951+nrow(emission)-1)
# merge = left_join(emissies_jm, emission, by = "Year")
# ggplot()+
#   geom_line(data = merge, aes(x=Year, y =`High Air (t/y)`, color="JM high air")) +
#   geom_line(data = merge, aes(x=Year, y = `High Water (t/y)`, color="JM high water")) +
#   geom_line(data = merge, aes(x=Year, y = sum_wat, color="Pope water")) +
#   geom_line(data = merge, aes(x=Year, y = sum_air, color="Pope air")) +
#   labs(title= "Emissies in europa - ValidationSB5 (JM) / POPE model (1951-2020)",
#        x="Years", y="Emission T/yr")
'Conclusie POPE model en ValidationSB emissies zijn aardig vergelijkbaar met elkaar'

#Converting times and emis:
MW = World$fetchData('MW')

emissions <- emissions |>
  mutate(Time = Time*(365.25*24*60*60)) |> # Convert time from y to s
  ungroup() |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60))  #MW =500 # convert 1 t/y to si units: kg/s

"close down vars..."
print("closing NC file and Vars....")
remove(mask, nc, r, var_data.slice, values, var_data.array, lat, lon, name)





