# Load long solution data and material parameters
load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SB_Material_parameters.RData")
load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.RData")

# Define folder where figures should be saved
figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/" # Define figure folder path

# Define source of interest and compartment of interest
source <- "Tyre wear"
compartment <- "river"

# Get unique varnames from material parameters dataframe
varnames <- unique(Material_Parameters_long$VarName)

# Filter the loaded dataframes for the source of interest
Material_Parameters_long <- Material_Parameters_long |>
  filter(Source == source)
Concentrations_long <- Concentrations_long |>
  filter(Source == source)
Solution_long <- Solution_long |>
  filter(Source == source)

Material_Parameters <- Material_Parameters_long |>
  filter(SubCompart == compartment)

conc_sol <- Concentrations_long |>
  filter(Year == 2019) |>
  left_join(Solution_long, by = c("RUN", "Polymer", "Source", "Year", "Abbr", "Species", "time", "Scale", "SubCompart"))

for(pol in unique(Material_Parameters$Polymer)){
  vars <- c("kdeg", "kfrag", "alpha")
  for(var in vars){
    Material_Parameters_var <- Material_Parameters_long |>
    filter(Polymer == pol) |>
    filter(VarName == var) |>
    filter(Source == source) |>
    filter(SubCompart == compartment) |>
    left_join(conc_sol, by=c("Source", "SubCompart", "Polymer", "RUN", "Species"), relationship = "many-to-many") |>
    distinct()
  
    plot_conc <- ggplot(Material_Parameters_var, aes(x = value, y = Concentration)) + 
      geom_point()+
      labs(x = var,
           y = unique(Material_Parameters_var$SubCompartName),
           title = paste0(unique(Material_Parameters_var$SubCompart), ", ", pol)) +
      scale_y_log10()+
      scale_x_log10()
    
    print(plot_conc)
    
    ggsave(paste0(figurefolder, "Concentration_parameter_plot_", var, "_", compartment, "_", pol, ".png"), plot=plot_conc, width=20, height=10, dpi = 1000)
  }
  
  vars <- c("RhoS", "RadS")
  for(var in vars){
    Material_Parameters_var <- Material_Parameters_long |>
      filter(VarName == var) |>
      filter(Source == source) |>
      left_join(conc_sol, by=c("Source", "Polymer", "RUN"), relationship = "many-to-many") |>
      distinct()
    
    plot_conc <- ggplot(Material_Parameters_var, aes(x = value, y = Concentration)) + 
      geom_point()+
      labs(x = var,
           y = "Concentration (g/L)",
           title = compartment) +
      scale_y_log10()+
      scale_x_log10()
    
    print(plot_conc)
    
    ggsave(paste0(figurefolder, "Concentration_parameter_plot_", var, "_", compartment, "_", pol, ".png"), plot=plot_conc, width=20, height=10, dpi = 1000)
  }
}
# 
# for(pol in unique(Material_Parameters$Polymer)){
#   data <- Material_Parameters |>
#     filter(Polymer == pol)
#   
#   plot <- ggplot(data, aes(x=value,y=Concentration)) +
#     geom_point()+
#     facet_wrap(vars(Species, SubCompart))+
#     xlab(var) +
#     ggtitle(pol)
#   
#   print(plot)
#   
#   ggsave(paste0(figurefolder, "Variable_plot_", var, ".png"), plot=plot, width=40, height=20, dpi = 1000)
# }
