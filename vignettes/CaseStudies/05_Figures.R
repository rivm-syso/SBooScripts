#### Make figures

library(tidyverse)

# Specify the environment
env <- "OOD"
#env <- "local"

# Load in the data
if(env == "local"){
  load("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.Rdata")
  figurefolder <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/"
} else if(env == "OOD"){
  load("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.RData")
  figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/"
}

# Make different concentration dfs for different plots
Concentrations_species <- Concentrations_long |>
  group_by(time, RUN, Source, Scale, SubCompart, Species, Year, Unit, SubCompartName) |>
  summarise(Concentration = sum(Concentration)) |>
  ungroup() 

Conc_summed_over_pol <- Concentrations_species |>
  group_by(time, RUN, Source, Year, Scale, SubCompart, SubCompartName, Unit) |>
  summarise(Concentration = sum(Concentration)) 

# Make different solution dfs for different plots
Solution_species <- Solution_long |>
  group_by(time, RUN, Source, Abbr, Scale, SubCompart, Species, Year) |>
  summarise(Mass = sum(Mass)) 

Solution_long_summed_over_pol <- Solution_species |>
  group_by(time, RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass))

############ Set plot theme and colors

# Create a plot theme
plot_theme <-  theme(
  axis.title.x = element_text(size = 14),    
  axis.title.y = element_text(size = 14),    
  axis.text.x = element_text(size = 12, angle = 45, hjust = 1),     
  axis.text.y = element_text(size = 12),
  title = element_text(size=20),
  panel.background = element_rect(fill = "white"),  # White background
  panel.grid.major = element_line(color = "lightgrey", size = 0.5),  # Major grid lines in light grey
  panel.grid.minor = element_line(color = "lightgrey", size = 0.25)
)

Source_colors <- c("Tyre wear" = "#2D708EFF",
                   "Other sources" = "#440154FF")

NR_SBR_colors <- c("NR" = "#20A387FF",
                   "SBR" = "#481567FF")

species_colors <- c("Large" = "#404788FF",
                    "Small" = "#238A8DFF",
                    "Solid" = "#55C667FF",
                    "Unbound" = "#FDE725FF")

year <- 2019

################ Make plots
scales <- unique(Solution_long$Scale)

for(scale in scales){
  sol_plot_data <- Solution_long_summed_over_pol |>
    filter(Scale == scale) |>
    filter(Year == year) |>
    group_by(RUN, Source, Year, Scale, SubCompart) |>
    summarise(Mass = sum(Mass))
  
  sol_plot_data_TW <- sol_plot_data |>
    filter(Source == "Tyre wear")
  
  conc_plot_data <- Conc_summed_over_pol |>
    filter(Scale == scale) |>
    filter(Year == year)|>
    group_by(RUN, Source, Year, Scale, SubCompart, SubCompartName) |>
    summarise(Concentration = sum(Concentration))
  
  conc_plot_data_TW <- conc_plot_data |>
    filter(Source == "Tyre wear")
  
  conc_over_time_TW <- Conc_summed_over_pol |>
    filter(Scale == scale) |>
    filter(Source == "Tyre wear") |>
    group_by(RUN, Source, Year, Scale, SubCompart, SubCompartName) |>
    summarise(Concentration = sum(Concentration)) |>
    ungroup() |>
    group_by(Source, Year, Scale, SubCompartName) |>
    summarise(Median = median(Concentration),
              Mean = mean(Concentration),
              p5 = quantile(Concentration, probs = 0.05, na.rm = T),
              p95 = quantile(Concentration, probs = 0.95, na.rm = T)) |>
    arrange(SubCompartName, Year) 
  
  # Mass plot comparing tyre wear and other sources
  mass_p <- ggplot(sol_plot_data, mapping = aes(x = SubCompart, y = Mass, fill = Source)) +  
    geom_violin() + 
    labs(title = paste0("Masses at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Mass (kg)") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_manual(values = Source_colors) +
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(mass_p)
  
  ggsave(paste0(figurefolder, "Mass_plot_comparison_", scale, ".png"), plot=mass_p, width = 20, height = 10)
  
  # Mass plot for tyre wear
  mass_p <- ggplot(sol_plot_data_TW, mapping = aes(x = SubCompart, y = Mass, fill = SubCompart)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber masses at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Mass (kg)") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_viridis_d() + 
    theme(axis.text.x = element_blank(),  
          legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(mass_p)
  
  ggsave(paste0(figurefolder, "Mass_plot_TW_", scale, ".png"), plot=mass_p, width = 20, height = 10)
  
  # Concentration plot comparing tyre wear and other sources
  conc_p <- ggplot(conc_plot_data, mapping = aes(x = SubCompartName, y = Concentration, fill = Source)) +  
    geom_violin() + 
    labs(title = paste0("Concentrations at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Mass (kg)") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_manual(values = Source_colors) +
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_comparison_", scale, ".png"), plot=conc_p, width = 20, height = 10)
  
  # Concentration plot for tyre wear
  conc_p <- ggplot(conc_plot_data_TW, mapping = aes(x = SubCompartName, y = Concentration, fill = SubCompart)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber concentrations at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Mass (kg)") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_viridis_d() + 
    theme(axis.text.x = element_blank(),  
          legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_p, width = 20, height = 10)
  
  # Mean tyre wear concentrations over time
  conc_time_p <- ggplot(conc_over_time_TW, mapping = aes(x = Year, y = Mean, colour = SubCompartName, group = SubCompartName)) +
    geom_line(size = 1) +
    labs(title = paste0("Tyre wear rubber mean concentrations over time at ", scale, " scale"),
         x = "Year",
         y = "Mean concentration") +
    plot_theme +
    scale_y_continuous(trans = 'log10') + 
    scale_color_viridis_d() +
    theme(axis.text.x = element_text(),  
          legend.position = "bottom") +   
    guides(colour = guide_legend(title = NULL)) 
  
  print(conc_time_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_time_p, width = 20, height = 10)
  
  # Tyre wear concentrations over time with uncertainty
  conc_time_2 <- ggplot(conc_over_time_TW, aes(x = Year, group = SubCompartName)) +
    geom_ribbon(aes(ymin = p5, ymax = p95, fill = SubCompartName), alpha = 0.2) +
    geom_line(aes(y = Median, color = SubCompartName), size = 1.2) +  # Explicitly set mean here
    scale_color_viridis_d(option = "D") +  
    scale_fill_viridis_d(option = "D") +   
    labs(title = "Concentration of Tyre Wear over time at ", scale, " scale, ", as.character(year),
         x = "Year",
         y = "Concentration (Median, p5, p95)",
         color = "Sub-Compartment",
         fill = "Sub-Compartment") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    theme(axis.text.x = element_text(),  
          legend.position = "bottom") +   
    guides(colour = guide_legend(title = NULL))
  print(conc_time_2)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_uncertain", scale, ".png"), plot=conc_time_2, width = 20, height = 10)
  
  # Mass and concentration plots of SBR vs NR
  NR_SBR_data <- Concentrations_long |>
    filter(Source == "Tyre wear") |>
    left_join(Solution_long, by=c("Scale", "Year", "RUN", "SubCompart", "Species", "time", "Polymer", "Source", "Abbr")) |>
    filter(Scale == scale) |>
    filter(Year == year) |>
    group_by(SubCompartName, SubCompart, Polymer, RUN) |>
    summarise(Concentration = sum(Concentration),
              Mass = sum(Mass))
  
  # Barplot with tyre wear concentration distribution over species
  conc_TW_bar <- Concentrations_species |>
    filter(Source == "Tyre wear") |>
    filter(Year == year) |>
    group_by(SubCompartName, Scale, Species) |>
    summarise(Mean = mean(Concentration)) |>
    filter(Mean != 0) |>
    filter(Scale == scale)
  
  # Make a stacked barplot for what percentage goes to air, soil and water
  species_dist_barplot <- ggplot(conc_TW_bar, aes(fill = Species, x = SubCompartName, y = Mean)) +
    geom_bar(position = "fill", stat="identity", color = "transparent") +
    scale_fill_manual(values = species_colors) +
    scale_x_discrete(labels = wrap_format(10)) +                   # Wraps text longer than 10 characters
    scale_y_continuous(labels = scales::percent) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 14),  # Increase x-axis text size
          axis.text.y = element_text(size = 14),                    # Increase y-axis text size
          axis.title.y = element_text(size = 16),                   # Increase y-axis title size
          legend.title = element_text(size = 14),                   # Increase legend title text size
          legend.text = element_text(size = 12),                    # Increase legend text size
          plot.title = element_text(size = 18),                     # Increase plot title text size (if you have a title)
          plot_theme) +
    labs(y= "Fraction to environmental compartment",
         x="") +
    labs(fill='Sink type') +
    plot_theme
  species_dist_barplot
  
  ggsave(paste0(figurefolder, "Concentration_species_barplot_", scale, ".png"), plot=species_dist_barplot, width = 20, height = 10)
  
  # Concentration plot for tyre wear (SBR/NR)
  conc_p <- ggplot(NR_SBR_data, mapping = aes(x = SubCompartName, y = Concentration, fill = Polymer)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber concentrations at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Concentration") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_manual(values = NR_SBR_colors) + 
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "NR_SBR_Concentration_", scale, ".png"), plot=species_dist_barplot, width = 20, height = 10)
  
  # Concentration plot for tyre wear (SBR/NR)
  mass_p <- ggplot(NR_SBR_data, mapping = aes(x = SubCompart, y = Mass, fill = Polymer)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber masses at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Mass (kg)") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_manual(values = NR_SBR_colors) + 
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(mass_p)
  
  ggsave(paste0(figurefolder, "NR_SBR_Mass_", scale, ".png"), plot=species_dist_barplot, width = 20, height = 10)
}
