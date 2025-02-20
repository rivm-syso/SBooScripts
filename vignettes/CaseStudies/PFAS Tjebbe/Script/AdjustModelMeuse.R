print("Adjusting model for Meuse catchment...")

#Afvoer: wordt niet gebruikt enkel voor validatie neerslag
data_nl = read_delim("vignettes/CaseStudies/PFAS Tjebbe/data/20250114_009.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)
#message("Meetpunten: ", sort(unique(data_nl$MEETPUNT_IDENTIFICATIE)))
maas <- data_nl %>%
  dplyr::select(MEETPUNT_IDENTIFICATIE,WAARNEMINGDATUM, "WAARNEMINGTIJD (MET/CET)", ALFANUMERIEKEWAARDE, EENHEID_CODE) %>%
  filter(MEETPUNT_IDENTIFICATIE == "Eijsden grens") %>%
  mutate(ALFANUMERIEKEWAARDE = as.numeric(ALFANUMERIEKEWAARDE),
         ALFANUMERIEKEWAARDE = ifelse(ALFANUMERIEKEWAARDE == 9.99999E+37, NA, ALFANUMERIEKEWAARDE)) %>%
  mutate(WAARNEMINGDATUM = as.Date(WAARNEMINGDATUM, format = "%d-%m-%Y")) %>%
  group_by(WAARNEMINGDATUM) %>%
  summarize(AVERAGE_VALUE = mean(ALFANUMERIEKEWAARDE, na.rm = TRUE))
maas_last_10yr <-  maas%>%
  tail(10*365) %>%
  dplyr::select(AVERAGE_VALUE) %>%
  summarise(mean_value = mean(AVERAGE_VALUE, na.rm = TRUE)) %>%
  pull(mean_value)
message("Gemiddelde gemeten afvoer Maas 2013-2023: ", maas_last_10yr)



#Neerslag: neerslag waardes berekenen ahv model data en basin shape file
#NC handling
pre <- nc_open("vignettes/CaseStudies/PFAS Tjebbe/data/ERA5_monthly.nc")
lon <- ncvar_get(pre, "longitude")  
lat <- ncvar_get(pre, "latitude")
time <- ncvar_get(pre, "valid_time")
time_unit <- ncatt_get(pre, "valid_time" , "units")  #Eenheid van de tijd
tp_units <- ncatt_get(pre, "tp", "units")   #Eenheid van de tp = totale neerslag
ref_date <- strsplit(time_unit$value, "since ")[[1]][2]
ref_date <- as.POSIXct(ref_date, format = "%Y-%m-%d", tz = "UTC")
dates <- ref_date + time        #met ref date een omrekenslag van seconden na/voor 1970 een datum te maken
precipitation.array <- ncvar_get(pre, "tp")
dim(precipitation.array)
fillvalue <- ncatt_get(pre, "tp", "_FillValue")

##Shapefile van Rijn stroomgebied inladen
shape <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Meuse.shp")

#Loopen door de tijdsdimensie van het NC bestand om een dataframe met neerslag te maken
#df maken
precipitation_df <- data.frame(
  Month = dates,
  TotalPrecipitation = numeric(dim(precipitation.array)[3])
)
#Loopen
for (month in 1:dim(precipitation.array)[3]){
  precipitation.slide <- precipitation.array[, , month]
  r <- raster(t(precipitation.slide), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84        +no_defs+ towgs84=0,0,0"))
  r[is.nan(r)] <- NA
  mask <- mask(r, shape)
  monthly_pre <- cellStats(mask, stat="mean", na.rm=TRUE) * 1000 * 30.43  #data is month average [m] precipitation > conversion to mm/month
  precipitation_df$TotalPrecipitation[month] <- monthly_pre
}

#Jaarlijkse en maandelijkse vertalingen om te valideren
precipitation_df$month_number <- format(precipitation_df$Month, "%m")
monthly_summary <- precipitation_df %>%
  group_by(month_number) %>%
  summarise(
    TotalPrecipitationMean = mean(TotalPrecipitation, na.rm = TRUE),
    Observations = n()
  )

precipitation_df$year_number <- format(precipitation_df$Month, "%Y")
yearly_summary <- precipitation_df %>%
  group_by(year_number) %>%
  summarise(
    TotalPrecipitationMean = sum(TotalPrecipitation, na.rm = TRUE)
  )
#dataframe met klimaat standaard 30 jaarlijks gemiddelden
precipitation_df <- precipitation_df %>%
  filter(year_number > 1992, year_number < 2023) %>%
  group_by(year_number) %>%
  summarise(
    TotalPrecipitation= sum(TotalPrecipitation, na.rm=TRUE)
  )

#calculating long-term gemiddelde neerslag en oppervlakte rijn stroomgebied
rainrate_mod = mean(yearly_summary$TotalPrecipitationMean, na.rm=TRUE)
area = st_area(shape)

"Landfractions afgeleid van satelliet data geclipt op het stroomgebied"
landfrac <- read_delim("vignettes/CaseStudies/PFAS Tjebbe/GIS/landuse.csv", delim=',', show_col_types = FALSE) %>%
  filter(name == 'Meuse')

"partition coefficients: work in progress"



"-----------------------------------------------------------------------------------------------------------"
"-----------------------------------------------------------------------------------------------------------"
"Adjusting Model: aanpassingen aan het model maken"
"AREA"
TotalArea <- data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"),
  Waarde = c(4.25E+13, 7.43E+12, 8.50E+13, area, 1.27e+14),
  varName = "TotalArea")
World$mutateVars(TotalArea)
World$UpdateDirty("TotalArea")

"LANDFRAC"
landFRAC <- data.frame(
  Scale = c("Continental", "Continental", "Continental", "Continental", "Continental",
            "Regional", "Regional", "Regional", "Regional", "Regional"),
  SubCompart = c("agriculturalsoil", "lake", "naturalsoil", "othersoil", "river",
                 "agriculturalsoil", "lake", "naturalsoil", "othersoil", "river"),
  Waarde = c(0.6, 0.0025, 0.27, 0.1, 0.0275,
             landfrac$agricultural, 0.0025, landfrac$naturalsoil-0.00816116, landfrac$othersoil, 0.0275),
  varName = "landFRAC"
)
World$mutateVars(landFRAC)
World$UpdateDirty("landFRAC")

"NEERSLAG"
World$fetchData("RAINrate")
Rainrate = data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"),
  Waarde = c(250, 700, 700, rainrate_mod, 1300),
  varName = ("RAINrate")
)
World$mutateVars(Rainrate)
World$fetchData("RAINrate")
World$UpdateDirty("RAINrate")

"RUNOFF"
#Runoff bekijken en aanpassen
World$fetchData("FRACrun")
FRACrun = data.frame(
  Waarde = 0.25,
  varName = ("FRACrun")
)
World$mutateVars(FRACrun)
World$fetchData("FRACrun")
World$UpdateDirty("FRACrun")


"INFILTRATIE"
World$fetchData("FRACinf")
FRACinf = data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"),
  Waarde = c(0.25, 0.25, 0.25, 0.25, 0.25),
  varName = ("FRACinf")
)
World$mutateVars(FRACinf)
World$fetchData("FRACinf")
World$UpdateDirty("FRACinf")

"PARTIONING"


"---------------------------------------------------------------------------------------------------------------"
"---------------------------------------------------------------------------------------------------------------"
"Update print"
print("Variables aangepast om het Rijn stroomgebied na te maken:")
cat("Area adjusted to:\n", area)
cat("\nlandfractions adjusted to:")
print(landfrac)
cat("\nRain rate adjusted to:\n")
print(Rainrate)

"Closing variables:"
print("Onnodige variables verwijderen....")
remove(data_NL, maas, pre, lon, lat, time, time_unit, tp_units, ref_date, dates, fillvalue, shape, r,
       monthly_pre, precipitation_df, monthly_summary, yearly_summary, precipitation.slide, TotalArea,
       landFRAC, rainrate_mod, FRACinf)

check_catchment <- function() {
  print("MEUSE:")
  cat("Area adjusted to:\n", area)
  cat("\nlandfractions adjusted to:")
  print(landFRAC)
  cat("\nRain rate adjusted to:\n")
  print(Rainrate)
  cat("\nRunoff adjusted to:\n")
  print(FRACrun) }


