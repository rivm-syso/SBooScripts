#Script om oppervlaktes van stroomgebieden te berekenen
library(sf)

#shapefiles inladen
RhineNL <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/RhineNL.shp", quiet = TRUE)
RhineEU <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/RhineEU.shp", quiet = TRUE)
MeuseNL <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/MeuseNL.shp", quiet = TRUE)
MeuseEU <- st_read("/rivm/biogrid/quikj/PFAS_A2/GIS/MeuseEU.shp", quiet = TRUE)
#transformeren naar lokale CRS
RhineNL <- st_transform(RhineNL, 28992)
RhineEU <- st_transform(RhineEU, 28992)
MeuseNL <- st_transform(MeuseNL, 28992)
MeuseEU <- st_transform(MeuseEU, 28992)
#Oppervlakte berekenen
area_rhine_nl <- st_area(RhineNL)
area_rhine_eu <- st_area(RhineEU)
area_meuse_nl <- st_area(MeuseNL)
area_meuse_eu <- st_area(MeuseEU)

remove(RhineNL, RhineEU, MeuseNL, MeuseEU)
