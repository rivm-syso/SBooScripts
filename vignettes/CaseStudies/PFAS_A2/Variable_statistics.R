#Statistiek
library(ggplot2)
library(patchwork)
library(ncdf4)
library(sf)
library(raster)
library(dplyr)
library(tidyverse)
library(writexl)

rijn <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Rhine.shp")
maas <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Meuse.shp")

calculate_precipitation <- function(shape) {
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
  
  #Loopen door de tijdsdimensie van het NC bestand om een dataframe met neerslag te maken
  #df maken
  precipitation_df <- data.frame(
    Month = dates,
    TotalPrecipitation = numeric(dim(precipitation.array)[3])
  )
  #Neerslag: Loopen
  for (month in 1:dim(precipitation.array)[3]){
    precipitation.slide <- precipitation.array[, , month]
    r <- raster(t(precipitation.slide), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84        +no_defs+ towgs84=0,0,0"))
    r[is.nan(r)] <- NA
    mask <- mask(r, shape)
    monthly_pre <- cellStats(mask, stat="mean", na.rm=TRUE) * 1000 * 30.43  #data is month average [m] precipitation > conversion to mm/month
    precipitation_df$TotalPrecipitation[month] <- monthly_pre
  }
  precipitation_df$year_number <- format(precipitation_df$Month, "%Y")
  yearly_summary <- precipitation_df %>%
    group_by(year_number) %>%
    summarise(
      TotalPrecipitationMean = sum(TotalPrecipitation, na.rm = TRUE)
    )
  return(list(yearly_summary, precipitation_df))
} 

#Neerslag Rijn
neerslag_rijn <- calculate_precipitation(rijn)
neerslag_maas <- calculate_precipitation(maas)

#Afvoer Lobith/Eijsden: 
data_nl = read_delim("vignettes/CaseStudies/PFAS Tjebbe/data/20250114_009.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)
#message("Meetpunten: ", sort(unique(data_nl$MEETPUNT_IDENTIFICATIE)))
afvoer_rijn <- data_nl %>%
  dplyr::select(MEETPUNT_IDENTIFICATIE,WAARNEMINGDATUM, "WAARNEMINGTIJD (MET/CET)", ALFANUMERIEKEWAARDE, EENHEID_CODE) %>%
  filter(MEETPUNT_IDENTIFICATIE == "Lobith") %>%
  mutate(ALFANUMERIEKEWAARDE = as.numeric(ALFANUMERIEKEWAARDE),
         ALFANUMERIEKEWAARDE = ifelse(ALFANUMERIEKEWAARDE == 9.99999E+37, NA, ALFANUMERIEKEWAARDE)) %>%
  mutate(WAARNEMINGDATUM = as.Date(WAARNEMINGDATUM, format = "%d-%m-%Y")) %>%
  group_by(WAARNEMINGDATUM) %>%
  summarize(AVERAGE_VALUE = mean(ALFANUMERIEKEWAARDE, na.rm = TRUE))

afvoer_maas <- data_nl %>%
  dplyr::select(MEETPUNT_IDENTIFICATIE,WAARNEMINGDATUM, "WAARNEMINGTIJD (MET/CET)", ALFANUMERIEKEWAARDE, EENHEID_CODE) %>%
  filter(MEETPUNT_IDENTIFICATIE == "Eijsden grens") %>%
  mutate(ALFANUMERIEKEWAARDE = as.numeric(ALFANUMERIEKEWAARDE),
         ALFANUMERIEKEWAARDE = ifelse(ALFANUMERIEKEWAARDE == 9.99999E+37, NA, ALFANUMERIEKEWAARDE)) %>%
  mutate(WAARNEMINGDATUM = as.Date(WAARNEMINGDATUM, format = "%d-%m-%Y")) %>%
  group_by(WAARNEMINGDATUM) %>%
  summarize(AVERAGE_VALUE = mean(ALFANUMERIEKEWAARDE, na.rm = TRUE))



#Histogrammen:
histogrammen <- function(afvoer, neerslag) {
  #Data op percentielen afsnijden
  percentiles1 <- quantile(neerslag$TotalPrecipitation, c(0.05,0.95), na.rm=TRUE)
  data1 <- neerslag[
    neerslag$TotalPrecipitation > percentiles1[1] & 
    neerslag$TotalPrecipitation < percentiles1[2], 
    ]
  percentiles2 <- quantile(afvoer$AVERAGE_VALUE, c(0.05,0.95), na.rm=TRUE)
  data2 <- afvoer[
    afvoer$AVERAGE_VALUE > percentiles2[1] & 
    afvoer$AVERAGE_VALUE < percentiles2[2], 
    ]
  

  #Data Plotten
  p1 <- ggplot(data = data1, aes(x=TotalPrecipitation)) +
    geom_histogram(bins=30, fill = "skyblue", color = "black", alpha = 0.7) +
    geom_vline(xintercept=median(data1$TotalPrecipitation), color="black", linetype="dashed", size=1.5) +
    geom_vline(xintercept=mean(data1$TotalPrecipitation), color="red", linetype="dashed",size=1.5) +
    labs(title = "Histogram Neerslag ERA5 Model ",
         x = "Waarde [mm/month]", y = "Frequentie") +
    theme_minimal()
  
  p2 <- ggplot(data = data2, aes(x=AVERAGE_VALUE)) +
    geom_histogram(bins=30, fill = "skyblue", color = "black", alpha = 0.7) +
    geom_vline(xintercept=median(data2$AVERAGE_VALUE, na.rm=TRUE), color="black", linetype="dashed",size=1.5) +
    geom_vline(xintercept=mean(data2$AVERAGE_VALUE, na.rm=TRUE), color="red", linetype="dashed",size=1.5) +
    labs(title = "Histogram Afvoer Maas",
         x = "Waarde [m3/s]", y = "Frequentie") +
    theme_minimal()
  
  
  return(list(neerslag_gem <- mean(data1$TotalPrecipitation),
         neerslag_med <- median(data1$TotalPrecipitation),
         neerslag_min <- min(data1$TotalPrecipitation, na.rm=TRUE),
         neerslag_max <- max(data1$TotalPrecipitation,  na.rm=TRUE),
         afvoer_gem <- mean(data2$AVERAGE_VALUE, na.rm=TRUE),
         afvoer_med<- median(data2$AVERAGE_VALUE, na.rm=TRUE),
         afvoer_min <- min(data2$AVERAGE_VALUE,  na.rm=TRUE),
         afvoer_max <- max(data2$AVERAGE_VALUE,  na.rm=TRUE),
         p1/p2))
  
}

#Rhine Neerslag en Afvoer 
resultaat_rijn <- histogrammen(afvoer_rijn, neerslag_rijn[[2]])

#Maas Neerslag en afvoer
resultaat_maas <- histogrammen(afvoer_maas, neerslag_maas[[2]])


cat("Min neerslag rijn: \t", min(neerslag_rijn[[2]]$TotalPrecipitation),
    "\nMax neerslag rijn: \t", max(neerslag_rijn[[2]]$TotalPrecipitation),
    "\nMin neerslag maas: \t", min(neerslag_maas[[2]]$TotalPrecipitation),
    "\nMax neerslag maas: \t", max(neerslag_maas[[2]]$TotalPrecipitation))


#To excel
write_xlsx(neerslag_rijn, "~/my_biogrid/Rijn.xlsx")
write_xlsx(neerslag_maas, "~/my_biogrid/Maas.xlsx")