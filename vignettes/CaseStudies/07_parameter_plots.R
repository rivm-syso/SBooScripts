source <- "Tyre wear"
var <- "alpha"

load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SB_Material_parameters.RData")

Material_Parameters <- Material_Parameters_long |>
  mutate(Source = case_when(
    is.na(Source) ~ "Other sources",
    Source == "Tyre wear" ~ "Tyre wear",
    TRUE ~ NA
  )) |>
  filter(VarName == var) |>
  filter(Source == source) |>
  left_join(Concentrations_long, by=c("Source", "SubCompart", "Polymer", "RUN", "Species"), relationship = "many-to-many") |>
  distinct()

for(pol in unique(Material_Parameters$Polymer)){
  data <- Material_Parameters |>
    filter(Polymer == pol)
  
  plot <- ggplot(data, aes(x=value,y=Concentration)) +
    geom_point()+
    facet_wrap(vars(Species, SubCompart))+
    xlab(var) +
    ggtitle(pol)
  
  print(plot)
}
