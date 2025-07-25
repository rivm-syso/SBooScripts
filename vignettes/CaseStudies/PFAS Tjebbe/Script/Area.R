#Script om oppervlaktes van stroomgebieden te berekenen
library(sf)

#shapefiles inladen
RhineNL <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/RhineNL.shp")
RhineEU <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/RhineEU.shp")
MeuseNL <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/MeuseNL.shp")
MeuseEU <- st_read("vignettes/CaseStudies/PFAS Tjebbe/GIS/MeuseEU.shp")
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
