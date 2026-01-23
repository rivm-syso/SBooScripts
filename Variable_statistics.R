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
      TotalPrecipitation = sum(TotalPrecipitation, na.rm = TRUE)
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
print(paste0("Eenheid van afvoer data: ",unique(data_nl$EENHEID_CODE)))


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
    labs(title = "Histogram Afvoer Rijn",
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
         p1,p2))
  
}

#Rhine Neerslag en Afvoer 
resultaat_rijn <- histogrammen(afvoer_rijn, neerslag_rijn[[1]])

#Maas Neerslag en afvoer
resultaat_maas <- histogrammen(afvoer_maas, neerslag_maas[[1]])


cat("Min neerslag rijn: \t", min(neerslag_rijn[[2]]$TotalPrecipitation),
    "\nMax neerslag rijn: \t", max(neerslag_rijn[[2]]$TotalPrecipitation),
    "\nMin neerslag maas: \t", min(neerslag_maas[[2]]$TotalPrecipitation),
    "\nMax neerslag maas: \t", max(neerslag_maas[[2]]$TotalPrecipitation))


#To excel
write_xlsx(neerslag_rijn, "~/my_biogrid/Rijn.xlsx")
write_xlsx(neerslag_maas, "~/my_biogrid/Maas.xlsx")


# Runoff
# grdc_path <- "/rivm/n/jansont/Documents/Werk - Lokaal/python/GRDC-Caravan-extension-csv/"
# grdc_meta <- read.csv(paste0(grdc_path,"attributes/grdc/attributes_other_grdc.csv"))
# grdc <- read.csv(paste0(grdc_path,"attributes/grdc/attributes_hydroatlas_grdc.csv"))
# all_shapes <- st_read(paste0(grdc_path, "/shapefiles/grdc/grdc_basin_shapes.shp"))
# all_shapes <- st_make_valid(all_shapes)
# mask = st_intersection(all_shapes, rijn)
# 
# grdc_rijn <- grdc %>% filter(gauge_id %in% mask$gauge_id)
# grdc_rijn$runoff_percentage <- grdc_rijn$run_mm_syr * 100 / grdc_rijn$pre_mm_syr
# mean(grdc_rijn$run_mm_syr)
# mean(grdc_rijn$pre_mm_syr)
# mean(grdc_rijn$runoff_percentage)
# 
# mask <- merge(mask, grdc_rijn, by='gauge_id')
# plot(mask[["runoff_percentage"]])
# 
# ggplot(mask) +
#   geom_sf(aes(fill = runoff_percentage)) +
#   scale_fill_viridis_c() +
#   theme_minimal()
# 
# ggplot(grdc_rijn, aes(x = runoff_percentage)) +
#   geom_histogram(bins = 50, fill = "dodgerblue", color = "white") +
#   theme_minimal()
# 
# quantile(grdc_rijn$runoff_percentage, c(0.05, 0.95), na.rm=TRUE)
# 
# n <-length(grdc_rijn$runoff_percentage)
# min(grdc_rijn$runoff_percentage)
# max(grdc_rijn$runoff_percentage)
# 
# # plot runoff aridity
# run_q <- quantile(grdc_rijn$run_mm_syr, probs = c(0.05, 0.95), na.rm = TRUE)
# pre_q <- quantile(grdc_rijn$ari_ix_sav, probs = c(0.05, 0.95), na.rm = TRUE)
# filtered <- subset(
#   grdc_rijn,
#   run_mm_syr >= run_q[1] & run_mm_syr <= run_q[2] &
#     ari_ix_sav >= pre_q[1] & ari_ix_sav <= pre_q[2]
# )
# plot(x = filtered$run_mm_syr, y = filtered$ari_ix_sav)
# cor.test(x = filtered$run_mm_syr, y = filtered$ari_ix_sav)
# 
# 
# 
# plot(x=grdc$run_mm_syr, y=grdc$ari_ix_sav)
# cor.test(x=grdc$run_mm_syr, y=grdc$ari_ix_sav, method='pearson')
# 
# log_min <- log(0.22)
# log_max <- log(0.85)
# n <- 1000
# 
# # Voorbeeldje van random log uniform verdeling
# random_values <- exp(runif(n, min = log_min, max = log_max))
# hist(random_values, breaks = 50, main = "Log-uniform distribution", xlab = "Value")

#a = 0.22 , b = 0.85
# waardes genereren voor runoff en precipitation om afvoer te berekenen
library(MASS)
install.packages("triangle")
library(triangle)

plots <- function(params, obs) {
  n <- length(obs)
  correlatie <- params[6]
  Sigma <- matrix(c(1, correlatie, correlatie, 1), 2, 2)
  samples <- mvrnorm(n, mu = c(0, 0), Sigma)
  a <- params[4]
  b <- params[5]
  u <- pnorm(samples[,1])
  log_uniform <- exp(log(a) + (log(b) - log(a)) * u)
  
  # mu_normaal <- 1045.5
  # sd_normaal <- 145.5
  # normaal <- mu_normaal + sd_normaal * samples[,2]
  
  a_tri <- params[1] #min
  b_tri <- 1045.502#params[2] #modus
  c_tri <- params[3] #max
  normaal <- rtri_custom(n, a = a_tri, b = b_tri, c = c_tri)
  
  area <- 240311500000
  sim <- (normaal * log_uniform) * area * 0.001 / (365 * 24 * 60 * 60)
  par(mfrow = c(1, 2))
  p1 <- hist(sim, breaks=50)
  p2 <- hist(obs, breaks=50)
  print("Simulated:")
  print(paste0("mean:", mean(sim)))
  print(paste0("median:", median(sim)))
  print(quantile(sim))
  # print("Observed:")
  # print(paste0("mean:", mean(obs)))
  # print(paste0("median:", median(obs)))
  # print(quantile(obs))
}

rtri_custom <- function(n, a, b, c) {
  u <- runif(n)
  v <- ifelse(u < (b - a)/(c - a),
              a + sqrt(u * (b - a) * (c - a)),
              c - sqrt((1 - u) * (c - b) * (c - a)))
  return(v)
}

x <- rtri_custom(10, a = a_tri, b = b_tri, c = c_tri)
print(x)


#Automatic calibration
rmse <- function(sim, obs) {
  sqrt(mean((sim - obs)^2, na.rm = TRUE))
  # val <- sqrt(mean((sim - obs)^2, na.rm = TRUE))
  # print(c(params, RMSE=val))
  # val
}

simulate <- function(params) {
  set.seed(1)
  mu <- params[1]
  sd <- params[2]
  a <- params[3]
  b <- params[4]
  correlatie <- params[5]
  
  obs <- afvoer_rijn$AVERAGE_VALUE
  n <- length(obs)
  Sigma <- matrix(c(1, correlatie, correlatie, 1), 2, 2)
  samples <- mvrnorm(n, mu = c(0, 0), Sigma)
  u <- pnorm(samples[,1]) # Uniform(0,1)
  log_uniform <- exp(log(a) + (log(b) - log(a)) * u)
  normaal <- mu + sd * samples[,2]
  area <- 240311500000
  sim <- (normaal * log_uniform) * area * 0.001 / (365 * 24 * 60 * 60)
  
  rmse(sim, obs)
}

start_params = c(1045.5, 145.5, 0.22, 0.85, 0.88)
result <- optim(
  start_params, simulate, 
  method = "L-BFGS-B",
  lower = c(0, 0.0001, 0.01, 0.01, 0),    
  upper = c(1e5, 1e5, 10, 10, 0.999)  
)

print(result$par)
plots(c(751.26, 1136.6, 1355.93, 0.12, 0.5, 0.88), afvoer_rijn$AVERAGE_VALUE)


get_mode_round <- function(v, digits = 1) {
  v_rounded <- round(v, digits)
  uniqv <- unique(v_rounded)
  uniqv[which.max(tabulate(match(v_rounded, uniqv)))]
}

get_mode_round(neerslag_rijn[[1]]$TotalPrecipitation, digits = 1)

