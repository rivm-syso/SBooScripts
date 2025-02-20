"Script om emissies te berekenen:"
print("Emissie PFOA berekenen a.h.v. POPE model....")
library(ggplot2)
library(reshape2)
Rhine <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Rhine.shp")
Meuse <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/Meuse.shp")
nc <- nc_open("vignettes/CaseStudies/PFAS Tjebbe/Emissions/POPE_Glb_0.5x0.5_anthro_PFOA_v1_yearly.nc")

#sink('POPE_emission_PFOA_metadata.txt')
#print(nc)
#sink()

names(nc$var)
lat <- ncvar_get(nc, 'latitude')
lon <- ncvar_get(nc, 'longitude')

#Extract best guess variables 
#To plot total over 70 years turn apply function on and remove 3 dimension in values array
values <- array(0, dim = c(720, 360, 70))
emission <- data.frame(
  year = 1:dim(values)[3])
print("Door tijdsdimensie loopen en emissie dataframe maken....")
for (name in names(nc$var)){
  print(name)
  if (grepl("BB$", name)) {
    var_data.array <- ncvar_get(nc, name)
    sum_list = list()
    for (i in 1:dim(values)[3]) {
      var_data.slice <- var_data.array[,,i]
      r <- raster(t(var_data.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
      r <- flip(r, direction='y')
      mask <- mask(r, Rhine)
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

"plot line graph"
ggplot(emission)+
  geom_line(aes(x=year, y =sum_wat, color="water emission")) +
  geom_line(aes(x=year, y=sum_air, color="Air emission")) +
  labs(title= "PFOA emission Rhine catchment (1951-2020)",
       x="Years", y="Emission T/yr")

"making dataframe fit for SB"
emissions <- data.frame(
  Abbr = rep(c("aRU", "aRU", "aRU", "aRU", "aRU"), times = nrow(emission) / 5), 
  Emis = emission$sum_air, 
  Timed = 1:nrow(emission)
  ) 
rows <- data.frame(
  Abbr = rep(c("aRU", "aRU", "aRU", "aRU", "aRU"), times = (runtime-nrow(emission))/5), 
  Emis = 0, 
  Timed = seq(from = nrow(emission) + 1, to = runtime)
  )
emissions <- bind_rows(emissions, rows)

#Converting times and emis:
MW = World$fetchData('MW')

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> # Convert time from y to s
  ungroup() |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60))  #MW =500 # convert 1 t/y to si units: kg/s

"close down vars..."
print("closing NC file and Vars....")






