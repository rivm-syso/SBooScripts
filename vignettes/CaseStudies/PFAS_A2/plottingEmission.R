library(maps)
library(viridis)
#sum_raster komt uit EmissionModel, en is de som van 70 jaar en verschillende variabelen waarin PFOA zit.

r <- raster(t(sum_raster), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
mask <- mask(r, Europe)
r <- flip(r, direction='y')
r_clipped <- r
r_clipped[r_clipped[] > 185] <- 185
mask_clipped <- mask
mask_clipped[mask_clipped[] > 150] <- 150

jpeg("Remco_PFOA_kaart.jpg", res=300, width = 2000, height =1500)
plot(r_clipped,
     col = viridis(100),
     bg = "white",
     zlim = c(1,185),
     xlim = c(-10,20),
     ylim = c(48, 60),
     main = "som PFOA emissions 1950-2020 - POPE",
     legend.args = list(text = "kg ", side = 4, cex = 0.8, line=2.5))
map('world', add=TRUE, )
dev.off()

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
  geom_sf(data=shape, fill='red', color='black') +
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

