#### Make figures

library(tidyverse)
library(readxl)

# Specify the environment
env <- "OOD"
#env <- "local"

# Load in the data
if(env == "local"){
  abs_path_SB_data <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.Rdata"
  load(abs_path_SB_data)
  figurefolder <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/"
  abs_path_TNO <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_WP3_results.xlsx"
} else if(env == "OOD"){
  abs_path_SB_data <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.RData"
  load(abs_path_SB_data)
  figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/"
  abs_path_TNO <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_WP3_results.xlsx"
}

# Load functions
source("vignettes/CaseStudies/f_plot_functions.R")

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
  axis.title.x = element_text(size = 26),    
  axis.title.y = element_text(size = 26),    
  axis.text.x = element_text(size = 24, angle = 45, hjust = 1),     
  axis.text.y = element_text(size = 24),
  legend.text = element_text(size = 24),
  title = element_text(size=30),
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

year_colors <- c("2019" = "#596d9cff",
                 "2023" = "#f9a242ff")

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
  
  # # Mass plot comparing tyre wear and other sources
  # mass_p <- ggplot(sol_plot_data, mapping = aes(x = SubCompart, y = Mass, fill = Source)) +  
  #   geom_violin() + 
  #   labs(title = paste0("Masses at ", scale, " scale, ", as.character(year)),
  #        x = "Compartment",
  #        y = "Mass (kg)") +
  #   plot_theme +
  #   scale_y_continuous(trans = 'log10') +
  #   scale_fill_manual(values = Source_colors) +
  #   theme(legend.position = "bottom") +   
  #   guides(fill = guide_legend(title = NULL))  
  # 
  # print(mass_p)
  # 
  # ggsave(paste0(figurefolder, "Mass_plot_comparison_", scale, ".png"), plot=mass_p, width = 20, height = 15)
  # 
  # # Mass plot for tyre wear
  # mass_p <- ggplot(sol_plot_data_TW, mapping = aes(x = SubCompart, y = Mass, fill = SubCompart)) +  
  #   geom_violin() + 
  #   labs(title = paste0("Tyre wear rubber masses at ", scale, " scale, ", as.character(year)),
  #        x = "Compartment",
  #        y = "Mass (kg)") +
  #   plot_theme +
  #   scale_y_continuous(trans = 'log10') +
  #   scale_fill_viridis_d() + 
  #   theme(axis.text.x = element_blank(),  
  #         legend.position = "bottom") +   
  #   guides(fill = guide_legend(title = NULL))  
  # 
  # print(mass_p)
  # 
  # ggsave(paste0(figurefolder, "Mass_plot_TW_", scale, ".png"), plot=mass_p, width = 20, height = 15)
  
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
  
  ggsave(paste0(figurefolder, "Concentration_plot_comparison_", scale, ".png"), plot=conc_p, width = 20, height = 15)
  
  # Concentration plot for tyre wear
  conc_p <- ggplot(conc_plot_data_TW, mapping = aes(x = SubCompartName, y = Concentration, fill = SubCompart)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber concentrations at ", scale, " scale, ", as.character(year)),
         x = "Compartment",
         y = "Concentration") +
    plot_theme +
    scale_y_continuous(trans = 'log10') +
    scale_fill_viridis_d() + 
    theme(axis.text.x = element_blank(),  
          legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_p, width = 20, height = 15)
  
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
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_time_p, width = 20, height = 15)
  
  # # Tyre wear concentrations over time with uncertainty
  # conc_time_2 <- ggplot(conc_over_time_TW, aes(x = Year, group = SubCompartName)) +
  #   geom_ribbon(aes(ymin = p5, ymax = p95, fill = SubCompartName), alpha = 0.2) +
  #   geom_line(aes(y = Median, color = SubCompartName), size = 1.2) +  # Explicitly set mean here
  #   scale_color_viridis_d(option = "D") +  
  #   scale_fill_viridis_d(option = "D") +   
  #   labs(title = "Concentration of Tyre Wear over time at ", scale, " scale, ", as.character(year),
  #        x = "Year",
  #        y = "Concentration (Median, p5, p95)",
  #        color = "Sub-Compartment",
  #        fill = "Sub-Compartment") +
  #   plot_theme +
  #   scale_y_continuous(trans = 'log10') +
  #   theme(axis.text.x = element_text(),  
  #         legend.position = "bottom") +   
  #   guides(colour = guide_legend(title = NULL))
  # print(conc_time_2)
  # 
  # ggsave(paste0(figurefolder, "Concentration_plot_TW_uncertain", scale, ".png"), plot=conc_time_2, width = 20, height = 15)
  
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
  print(species_dist_barplot)
  
  ggsave(paste0(figurefolder, "Concentration_species_barplot_", scale, ".png"), plot=species_dist_barplot, width = 20, height = 15)
  
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
  
  ggsave(paste0(figurefolder, "NR_SBR_Concentration_", scale, ".png"), plot=conc_p, width = 20, height = 15)
  
  # # Concentration plot for tyre wear (SBR/NR)
  # mass_p <- ggplot(NR_SBR_data, mapping = aes(x = SubCompart, y = Mass, fill = Polymer)) +  
  #   geom_violin() + 
  #   labs(title = paste0("Tyre wear rubber masses at ", scale, " scale, ", as.character(year)),
  #        x = "Compartment",
  #        y = "Mass (kg)") +
  #   plot_theme +
  #   scale_y_continuous(trans = 'log10') +
  #   scale_fill_manual(values = NR_SBR_colors) + 
  #   theme(legend.position = "bottom") +   
  #   guides(fill = guide_legend(title = NULL))  
  # 
  # print(mass_p)
  # 
  # ggsave(paste0(figurefolder, "NR_SBR_Mass_", scale, ".png"), plot=mass_p, width = 20, height = 15)
}

# Make plots for continental scale and polymers over time (concentration)
continental_polymer_data <- Concentrations_long |>
  filter(Scale == "Continental") |>
  group_by(Polymer, Year, Source, Scale, SubCompart, SubCompartName, Unit) |>
  summarise(Concentration = sum(Concentration)) |>
  group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale, Unit) |>
  summarise(Concentration = mean(Concentration))

for(subcomp in unique(continental_polymer_data$SubCompart)) {
  plotdata_TW <- continental_polymer_data |>
    filter(SubCompart == subcomp) |>
    filter(Source == "Tyre wear") 
  
  plotdata_Other <- continental_polymer_data |>
    filter(SubCompart == subcomp) |>
    filter(Source == "Other sources")
  
  cont_pol_plot_Other <- ggplot(plotdata_Other, mapping = aes(x = Year, y = Concentration, color = Polymer)) +
    geom_line(size = 2) +
    scale_y_continuous(trans = "log10") +
    labs(
      title = paste0("Microplastic concentrations in ", subcomp, " at Continental scale"),
      x = "Year",
      y = paste0("Concentration (", unique(plotdata_Other$Unit), ")")
    ) +
    plot_theme
  
  print(cont_pol_plot_Other)
  
  ggsave(paste0(figurefolder, "Concentration_over_time_Other_sources_Continental_", subcomp, ".png"), plot=cont_pol_plot_Other, width = 20, height = 15) 

  cont_pol_plot_TW <- ggplot(plotdata_TW, mapping = aes(x = Year, y = Concentration, color = Polymer)) +
    geom_line(size = 2) +
    scale_y_continuous(trans = "log10") +
    labs(
      title = paste0("Microplastic concentrations in ", subcomp, " at Continental scale"),
      x = "Year",
      y = paste0("Concentration (", unique(plotdata_TW$Unit), ")")
    ) +
    plot_theme
  
  print(cont_pol_plot_TW)
  
  ggsave(paste0(figurefolder, "Concentration_over_time_Tyre_wear_Continental_", subcomp, ".png"), plot=cont_pol_plot_TW, width = 20, height = 15) 
  
}

##### Make plot of NR fractions over time

NR_fraction_over_time <- continental_polymer_data |>
  filter(Source == "Tyre wear") |> 
  group_by(Year, Source, SubCompart, SubCompartName, Scale) |>
  summarise(Concentration_TW = sum(Concentration)) |>
  left_join(continental_polymer_data, by=c("Source", "Year", "SubCompart", "SubCompartName", "Scale")) |>
  filter(Polymer != "SBR")|>
  mutate(fraction_NR = Concentration/Concentration_TW)

mean_NR_time_plot <- ggplot(NR_fraction_over_time, mapping = aes(x = Year, y = fraction_NR, color = SubCompart)) +
  geom_line(size = 2) +
  scale_y_continuous(trans = "log10") +
  labs(
    title = paste0("Mean natural rubber fraction at Continental scale"),
    x = "Year",
    y = paste0("Fraction")
  ) +
  plot_theme

print(mean_NR_time_plot)

ggsave(paste0(figurefolder, "Natural_rubber_fraction_over_time_continental_scale.png"), plot=mean_NR_time_plot, width = 20, height = 15) 

# Plot variables
for(var in unique(Material_Parameters_long$VarName)){
  plot <- plot_variable(Material_Parameters_long, var)
  print(plot)

  ggsave(paste0(figurefolder, "Variable_plot_", var, ".png"), plot=plot, width=40, height=20)
}

# Make plot comparing 2019 emissions to 2023 emissions
conc_2019_2023 <- Conc_summed_over_pol |>
  filter(Source == "Tyre wear") |>
  filter(Year %in% c(2019, 2023)) |>
  filter(Scale == "Continental") |>
  filter(Source == "Tyre wear")  |>
  mutate(Year = as.character(Year))

conc_2019_2023_plot <- ggplot(conc_2019_2023, mapping = aes(x = SubCompartName, y = Concentration, fill = Year)) +  
  geom_violin() + 
  labs(title = paste0("Concentrations at continental scale"),
       x = "Compartment",
       y = "Concentration") +
  plot_theme +
  scale_y_continuous(trans = 'log10') +
  scale_fill_manual(values = year_colors) +
  theme(legend.position = "bottom") +   
  guides(fill = guide_legend(title = NULL))  

print(conc_2019_2023_plot)

ggsave(paste0(figurefolder, "Concentration_plot_2019_2023.png"), plot=conc_2019_2023_plot, width = 20, height = 15)

##### Make plots compared to measurements

# Prepare the measurement data for plotting
TNO_TWP_data <- prep_TNO_data(abs_path_TNO)

subcomparts <- c(unique(TNO_TWP_data$SubCompart), "agriculturalsoil")

# Prepare SimpleBox data for plotting
SB_data <- Concentrations_long |>
  filter(Source == "Tyre wear") |>
  left_join(Solution_long, by=c("Scale", "Year", "RUN", "SubCompart", "Species", "time", "Polymer", "Source", "Abbr")) |>
  filter(Scale == "Regional") |>
  filter(Year == year) |>
  group_by(SubCompartName, SubCompart, RUN) |>
  summarise(Concentration = sum(Concentration)) |>
  mutate(Polymer = "SBR + NR") |>
  filter(SubCompart %in% subcomparts) |>
  mutate(source = "SimpleBox") 

# Make plot comparing TNO and SB data
TNO_SB_SBR_NR <- bind_rows(TNO_TWP_data, SB_data) |>
  filter(Polymer == "SBR + NR") |>
  mutate(SubCompartName = case_when(
    SubCompart == "othersoil" ~ "roadsidesoil (g/kg dw)",
    TRUE ~ SubCompartName
  ),
  SubCompartName = factor(SubCompartName, levels = c("air (g/m^3)", "freshwatersediment (g/kg dw)", "river (g/L)", "roadsidesoil (g/kg dw)", "agriculturalsoil (g/kg dw)")))

# Concentration plot comparing tyre wear and other sources
conc_TNO_SB_SBR_NR <- ggplot(TNO_SB_SBR_NR, mapping = aes(x = SubCompartName, y = Concentration, fill = source)) +  
  geom_violin() + 
  labs(title = paste0("SBR + NR concentrations at Regional scale, ", as.character(year)),
       x = "Compartment",
       y = "Concentration") +
  plot_theme +
  scale_y_continuous(trans = 'log10') +
  theme(legend.position = "bottom") +   
  guides(fill = guide_legend(title = NULL))  

print(conc_TNO_SB_SBR_NR)

ggsave(paste0(figurefolder, "SBR_NR_measurement_comparison",".png"), plot=conc_TNO_SB_SBR_NR, width = 20, height = 15)

source <- "Tyre wear"
var <- "alpha"

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












