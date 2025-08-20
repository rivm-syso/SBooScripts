
r <- raster(t(var_data.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
mask <- mask(r, Rhine)
r <- flip(r, direction='y')
plot(mask)

#Plotting a total emission image
values_melt <- melt(values_slice)
lon <- seq(-179.75, 179.75, length.out = 720)
lat <- seq(-89.75, 89.75, length.out = 360)
names(values_melt) <- c("Longitude", "Latitude", "Value")
values_melt$Longitude <- lon[values_melt$Longitude]
values_melt$Latitude <- lat[values_melt$Latitude]

#Plotting:
values_df <- data.frame(values_melt)  
ggplot() +
  geom_tile(data=values_df, aes(x = Longitude, y = Latitude, fill = Value)) +
  geom_sf(data=Rhine, fill='red', color='black') +
  scale_fill_viridis_c(option = "C", 
                       limits = c(1, 100)) +
  labs(title = "Global Emissions of PFOA (Best Guess)",
       x = "Longitude",
       y = "Latitude",
       fill = "Emissions (Tg)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlim(-25, 50) +
  ylim(40, 70)

