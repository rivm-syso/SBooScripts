#### Make figures
library(tidyverse)
library(readxl)
library(viridis)
library(scales)

# Specify the environment
env <- "OOD"
#env <- "local"

mass_file_name <- "SB_Masses.RData"
TW_file_name <- "SB_Tyre_wear_data.RData"
Mat_file_name <- "SB_Material_parameters.RData"

# Load in the data
if(env == "local"){
  data_path <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/" # Define path to plot data
  figurefolder <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/" # Define figure folder path
  abs_path_Measurements <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_WP3_results.xlsx"  # Define path to LEON-T data
} else if(env == "OOD"){
  data_path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/" # Define path to plot data
  figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/SB_plots/" # Define figure folder path
  abs_path_Measurements <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_WP3_results.xlsx" # Define path to LEON-T data
}

# Load the data
load(paste0(data_path, mass_file_name))
load(paste0(data_path, TW_file_name))
load(paste0(data_path, Mat_file_name))

# Load functions
source("vignettes/CaseStudies/f_plot_functions.R")

####################### Calculate concentrations from masses ###################

source("baseScripts/initWorld_onlyPlastics.R")
Matrix <- World$fetchData("Matrix")

### Get a dataframe with complete runs
yearcount <- continental_polymer_data |>
  group_by(Source, RUN, Polymer) |>
  summarise(Year_count = n_distinct(Year), .groups = "drop") |>
  group_by(Source, RUN) |>
  summarise(Year_count = sum(Year_count)) |>
  mutate(npol = case_when(Source == "Tyre wear" ~ 2,
                          Source == "Other sources" ~ 15)) |>
  mutate(nyear = as.integer(Year_count/npol)) |>
  filter(nyear == 101) |>
  select(Source, RUN, nyear)

# Calculate concentrations for masses summed over polymers
mass_conc_summed_over_pol <- 
  Solution_long_summed_over_pol |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |> 
  group_by(RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"), 
            by=c("Scale", "SubCompart")) |>
  mutate(conc_kg_m3 = Mass/Volume) |> 
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |> 
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|> 
  mutate(Unit = "kg/m3") |> 
  mutate(Concentration =
           case_match(Matrix,
                      "air" ~ conc_kg_m3*1000000,
                      "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000, # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000,
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit)) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

mass_conc_summed_over_pol <- yearcount |>
  left_join(mass_conc_summed_over_pol, by = c("RUN", "Source"))

# Calculate concentrations for NR SBR dataframe
NR_SBR_data <- NR_SBR_data |>
  mutate(Source = "Tyre wear")

mass_conc_NR_SBR <- NR_SBR_data |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |> 
  group_by(RUN, Source, Year, Scale, SubCompart, Polymer) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"), 
            by=c("Scale", "SubCompart")) |>
  mutate(conc_kg_m3 = Mass/Volume) |> 
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |> 
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |> 
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|> 
  mutate(Unit = "kg/m3") |> 
  mutate(Concentration =
           case_match(Matrix,
                      "air" ~ conc_kg_m3*1000000,
                      "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000, # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000,
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

mass_conc_NR_SBR <- yearcount |>
  left_join(mass_conc_NR_SBR, by = c("RUN", "Source"))

# Calculate concentrations for continental polymer data
mass_conc_continental_polymer <- continental_polymer_data |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(RUN, Source, Year, Scale, SubCompart, Polymer) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
  mutate(conc_kg_m3 = Mass/Volume) |>
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |>
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|>
  mutate(Unit = "kg/m3") |>
  mutate(Concentration =
           case_match(Matrix,
                      "air" ~ conc_kg_m3*1000000,
                      "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000, # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000,
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

mass_conc_continental_polymer <- yearcount |>
  left_join(mass_conc_continental_polymer, by = c("RUN", "Source"))

# Calculate concentrations for SB_data_TW
mass_conc_SB_data_TW <- SB_data_TW |>
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |>
  group_by(RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass)) |>
  ungroup() |>
  left_join(World$fetchData("Volume"),
            by=c("Scale", "SubCompart")) |>
  mutate(conc_kg_m3 = Mass/Volume) |>
  left_join(World$fetchData("FRACw"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("FRACa"),
            by=c("Scale", "SubCompart")) |>
  left_join(World$fetchData("rhoMatrix"),
            by=c("SubCompart")) |>
  left_join(World$fetchData("Matrix"),
            by=c("SubCompart"))|>
  mutate(Unit = "kg/m3") |>
  mutate(Concentration =
           case_match(Matrix,
                      "air" ~ conc_kg_m3*1000000,
                      "water" ~ conc_kg_m3*1000,
                      "soil" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000, # RhoWater needed (we need to define subcompartment variables for rhoWater, rhoSolid and rhoAir)
                      "sediment" ~ conc_kg_m3  / ((1 - FRACw - FRACa) * rhoMatrix)*1000,
                      .default = conc_kg_m3),
         Unit =
           case_match(Matrix,
                      "air" ~ "mg/m3",
                      "water" ~ "mg/L",
                      "soil" ~ "g/kg dw",
                      "sediment" ~ "g/kg dw",
                      .default = Unit))  |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
  select(-c(conc_kg_m3, FRACw, FRACa, rhoMatrix, Matrix, Volume))

mass_conc_SB_data_TW <- yearcount |>
  left_join(mass_conc_SB_data_TW, by = c("RUN", "Source"))

nruns <- yearcount |>
  group_by(Source) |>
  count()

TWruns <- nruns |>
  filter(Source == "Tyre wear") 
TWruns <- TWruns$n

Otherruns <- nruns |>
  filter(Source == "Other sources") 
Otherruns <- Otherruns$n

############ Set plot theme and colors
# Create a plot theme
plot_theme <-  theme(
  axis.title.x = element_text(size = 30),    
  axis.title.y = element_text(size = 30),    
  axis.text.x = element_text(size = 28, angle = 45, hjust = 1),     
  axis.text.y = element_text(size = 28),
  legend.text = element_text(size = 28),
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

viridis_colors <- viridis(n=7)
year_colors <- c("1990" = viridis_colors[1],
                 "1995" = viridis_colors[2],
                 "2019" = viridis_colors[3],
                 "2020" = viridis_colors[4],
                 "2023" = viridis_colors[5],
                 "2030" = viridis_colors[6],
                 "2050" = viridis_colors[7])

year <- 2019

scales <- c("Continental", "Regional")
scale <- "Regional"
################ Concentration plots
for(scale in scales){
  conc_plot_data <- mass_conc_summed_over_pol  |>
    filter(Scale == scale) |>
    filter(Year == year)
  
  conc_plot_data_TW <- conc_plot_data |>
    filter(Source == "Tyre wear")
  
  conc_over_time_TW <- mass_conc_summed_over_pol  |>
    filter(Scale == scale) |>
    filter(Source == "Tyre wear") |>
    group_by(Source, Year, Scale, SubCompartName) |>
    summarise(Median = median(Concentration),
              Mean = mean(Concentration),
              p5 = quantile(Concentration, probs = 0.05, na.rm = T),
              p95 = quantile(Concentration, probs = 0.95, na.rm = T)) |>
    arrange(SubCompartName, Year) 
  
  # Concentration plot comparing tyre wear and other sources
  conc_p <- ggplot(conc_plot_data, mapping = aes(x = SubCompartName, y = Concentration, fill = Source)) +  
    geom_violin() + 
    labs(title = paste0("Concentrations at ", scale, " scale, ", as.character(year)),
         subtitle = paste0(TWruns, " runs for Tyre wear, ", Otherruns, " runs for Other sources"),
         x = "Compartment",
         y = "Concentration") +
    plot_theme +
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x))) +
    annotation_logticks(sides="l",  
                        short = unit(0.07, "cm"),
                        mid = unit(0.07, "cm"),
                        long = unit(0.1, "cm"),
                        size = 0.25) +
    scale_fill_manual(values = Source_colors) +
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))
    
  print(conc_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_comparison_", scale, ".png"), plot=conc_p, width = 25, height = 15, dpi = 1000)
  
  # Concentration plot for tyre wear
  conc_p <- ggplot(conc_plot_data_TW, mapping = aes(x = SubCompartName, y = Concentration, fill = SubCompart)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber concentrations at ", scale, " scale, ", as.character(year)),
         subtitle = paste0(TWruns, " runs for Tyre wear"),
         x = "Compartment",
         y = "Concentration") +
    plot_theme +
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x))) +
    annotation_logticks(sides="l",  
                        short = unit(0.07, "cm"),
                        mid = unit(0.07, "cm"),
                        long = unit(0.1, "cm"),
                        size = 0.25) +
    scale_fill_viridis_d() + 
    theme(axis.text.x = element_blank(),  
          legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_p, width = 25, height = 15, dpi = 1000)
  
  # Mean tyre wear concentrations over time
  conc_time_p <- ggplot(conc_over_time_TW, mapping = aes(x = Year, y = Mean, colour = SubCompartName, group = SubCompartName)) +
    geom_line(size = 1) +
    labs(title = paste0("Tyre wear rubber mean concentrations over time at ", scale, " scale"),
         subtitle = paste0(TWruns, " runs for Tyre wear"),
         x = "Year",
         y = "Mean concentration") +
    plot_theme +
    scale_y_log10() +
    scale_color_viridis_d() +
    theme(axis.text.x = element_text(),  
          legend.position = "bottom") +   
    guides(colour = guide_legend(title = NULL)) 
  
  print(conc_time_p)
  
  ggsave(paste0(figurefolder, "Concentration_plot_TW_", scale, ".png"), plot=conc_time_p, width = 25, height = 15, dpi = 1000)
  
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
  # ggsave(paste0(figurefolder, "Concentration_plot_TW_uncertain", scale, ".png"), plot=conc_time_2, width = 25, height = 15, dpi = 1000)
  
  # Make a stacked barplot for what percentage goes to air, soil and water
  # species_dist_barplot <- ggplot(conc_Tyre_wear, aes(fill = Species, x = SubCompartName, y = Mean)) +
  #   geom_bar(position = "fill", stat="identity", color = "transparent") +
  #   scale_fill_manual(values = species_colors) +
  #   scale_x_discrete(labels = wrap_format(10)) +                   # Wraps text longer than 10 characters
  #   scale_y_continuous(labels = scales::percent) +
  #   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 14),  # Increase x-axis text size
  #         axis.text.y = element_text(size = 14),                    # Increase y-axis text size
  #         axis.title.y = element_text(size = 16),                   # Increase y-axis title size
  #         legend.title = element_text(size = 14),                   # Increase legend title text size
  #         legend.text = element_text(size = 12),                    # Increase legend text size
  #         plot.title = element_text(size = 18),                     # Increase plot title text size (if you have a title)
  #         plot_theme) +
  #   labs(y= "Fraction to environmental compartment",
  #        x="") +
  #   labs(fill='Sink type') +
  #   plot_theme
  # print(species_dist_barplot)
  # 
  # ggsave(paste0(figurefolder, "Concentration_species_barplot_", scale, ".png"), plot=species_dist_barplot, width = 25, height = 15, dpi = 1000)
  
  NR_SBR_plot_data <- mass_conc_NR_SBR |>
    filter(Scale == scale)
  
  # Concentration plot for tyre wear (SBR/NR)
  conc_p <- ggplot(NR_SBR_plot_data, mapping = aes(x = SubCompartName, y = Concentration, fill = Polymer)) +  
    geom_violin() + 
    labs(title = paste0("Tyre wear rubber concentrations at ", scale, " scale, ", as.character(year)),
         subtitle = paste0(TWruns, " runs for Tyre wear"),
         x = "Compartment",
         y = "Concentration") +
    plot_theme +
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x))) +
    annotation_logticks(sides="l",  
                        short = unit(0.07, "cm"),
                        mid = unit(0.07, "cm"),
                        long = unit(0.1, "cm"),
                        size = 0.25) +
    scale_fill_manual(values = NR_SBR_colors) + 
    theme(legend.position = "bottom") +   
    guides(fill = guide_legend(title = NULL))  
  
  print(conc_p)
  
  ggsave(paste0(figurefolder, "NR_SBR_Concentration_", scale, ".png"), plot=conc_p, width = 25, height = 15, dpi = 1000)
}

############################### Tyre wear plots ################################
#Make plots for continental scale and polymers over time (concentration)
for(subcomp in unique(mass_conc_continental_polymer$SubCompart)) {
  plotdata_TW <- mass_conc_continental_polymer |>
    filter(SubCompart == subcomp) |>
    filter(Source == "Tyre wear") |>
    group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale) |>
    summarise(Mean_Concentration = mean(Concentration)) |>
    ungroup()
  
  plotdata_Other <- mass_conc_continental_polymer |>
    filter(SubCompart == subcomp) |>
    filter(Source == "Other sources") |>
    group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale) |>
    summarise(Mean_Concentration = mean(Concentration)) |>
    ungroup()
  
  cont_pol_plot_Other <- ggplot(plotdata_Other, mapping = aes(x = Year, y = Mean_Concentration, color = Polymer)) +
    geom_line(size = 2) +
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x))) +
    annotation_logticks(sides="l",  
                        short = unit(0.07, "cm"),
                        mid = unit(0.07, "cm"),
                        long = unit(0.1, "cm"),
                        size = 0.25) +
    labs(
      title = paste0("Microplastic concentrations in ", subcomp, " at Continental scale"),
      subtitle = paste0(Otherruns, " runs for Other sources"),
      x = "Year",
      y = paste0("Concentration (", unique(plotdata_Other$Unit), ")")) +
    plot_theme
  
  print(cont_pol_plot_Other)
  
  ggsave(paste0(figurefolder, "Concentration_over_time_Other_sources_Continental_", subcomp, ".png"), plot=cont_pol_plot_Other, width = 25, height = 15, dpi = 1000) 
  
  cont_pol_plot_TW <- ggplot(plotdata_TW, mapping = aes(x = Year, y = Mean_Concentration, color = Polymer)) +
    geom_line(size = 2) +
    scale_y_continuous(trans = "log10") +
    labs(
      title = paste0("Microplastic concentrations in ", subcomp, " at Continental scale"),
      subtitle = paste0(TWruns, " runs for Tyre wear"),
      x = "Year",
      y = paste0("Concentration (", unique(plotdata_TW$Unit), ")")
    ) +
    plot_theme
  
  print(cont_pol_plot_TW)
  
  ggsave(paste0(figurefolder, "Concentration_over_time_Tyre_wear_Continental_", subcomp, ".png"), plot=cont_pol_plot_TW, width = 25, height = 15, dpi = 1000) 
}

##### Make plot of NR fractions over time

continental_polymer_data_mean <- mass_conc_continental_polymer |>
  filter(Source == "Tyre wear") |> 
  group_by(Year, Source, SubCompart, Polymer, SubCompartName, Scale)|>
  summarise(Concentration = mean(Concentration)) |>
  ungroup()

NR_fraction_over_time <- continental_polymer_data_mean |>
  group_by(Year, Source, SubCompart, SubCompartName, Scale) |>
  summarise(Concentration_TW = sum(Concentration)) |>
  left_join(continental_polymer_data_mean, by=c("Source", "Year", "SubCompart", "SubCompartName", "Scale")) |>
  filter(Polymer != "SBR")|>
  mutate(fraction_NR = Concentration/Concentration_TW)

mean_NR_time_plot <- ggplot(NR_fraction_over_time, mapping = aes(x = Year, y = fraction_NR, color = SubCompart)) +
  geom_line(size = 2) +
  scale_y_continuous(trans = "log10") +
  labs(
    title = paste0("Mean natural rubber fraction at Continental scale"),
    subtitle = paste0(TWruns, " runs for Tyre wear"),
    x = "Year",
    y = paste0("Fraction")) +  plot_theme

print(mean_NR_time_plot)

ggsave(paste0(figurefolder, "Natural_rubber_fraction_over_time_continental_scale.png"), plot=mean_NR_time_plot, width = 25, height = 15, dpi = 1000) 

# # Plot variables
# for(var in unique(Material_Parameters_long$VarName)){
#   plot <- plot_variable(Material_Parameters_long, var)
#   #print(plot)
#   
#   ggsave(paste0(figurefolder, "Variable_plot_", var, ".png"), plot=plot, width=40, height=20, dpi = 1000)
# }

# Make plot comparing 2019 emissions to 2023 emissions
conc_years <- mass_conc_summed_over_pol |>
  filter(Source == "Tyre wear") |>
  filter(Year %in% c(1990, 1995, 2019, 2020, 2023, 2030, 2050)) |>
  filter(Scale == "Continental") |>
  mutate(Year = as.character(Year))

conc_years_plot <- ggplot(conc_years, mapping = aes(x = SubCompartName, y = Concentration, fill = Year)) +  
  geom_violin() + 
  labs(title = paste0("TWP concentrations at continental scale"),
       subtitle = paste0(TWruns, " runs for Tyre wear"),
       x = "Compartment",
       y = "Concentration") +
  plot_theme +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  scale_fill_manual(values = year_colors) +
  theme(legend.position = "bottom") +   
  guides(fill = guide_legend(title = NULL)) +
  theme(
    legend.position = "bottom",   
    panel.grid.major = element_line(color = "lightgrey", size = 0.7), # Major grid lines
    panel.grid.minor = element_line(color = "lightgrey", size = 0.7)  # Minor grid lines
  ) 

print(conc_years_plot)

ggsave(paste0(figurefolder, "Concentration_plot_year_comparison.png"), plot=conc_years_plot, width = 27, height = 20, dpi = 1000)
##### Make plots compared to measurements

# Prepare the measurement data for plotting
LEONT_TWP_data <- prep_LEONT_data(abs_path_Measurements) 

subcomparts <- c(unique(LEONT_TWP_data$SubCompart), "agriculturalsoil")

# Prepare SimpleBox data for plotting
mass_conc_SB_data_TW <- mass_conc_SB_data_TW |>
  mutate(Concentration = case_when(
    SubCompart == "air" ~ Concentration/1000,
    SubCompart == "river" ~ Concentration/1000,
    TRUE ~ Concentration
  )) |>
  mutate(Unit = case_when(
    SubCompart == "air" ~ "g/m^3",
    SubCompart == "river" ~ "g/L",
    TRUE ~ Unit
  )) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")" )) |>
  mutate(Polymer = "SBR + NR") |>
  mutate(source = "SimpleBox") |>
  filter(SubCompart %in% subcomparts) |>
  select(colnames(LEONT_TWP_data)) |>
  mutate(Unit = paste0("(", Unit, ")"))

# Make plot comparing LEONT and SB data
LEONT_SB_SBR_NR <- bind_rows(LEONT_TWP_data, mass_conc_SB_data_TW) |>
  filter(Polymer == "SBR + NR") |>
  mutate(SubCompartName = case_when(
    SubCompart == "othersoil" ~ "roadsidesoil (g/kg dw)",
    TRUE ~ SubCompartName
  ),
  SubCompartName = factor(SubCompartName, levels = c("air (g/m^3)", "freshwatersediment (g/kg dw)", "river (g/L)", "roadsidesoil (g/kg dw)", "agriculturalsoil (g/kg dw)")))

# Concentration plot comparing tyre wear and other sources
conc_LEONT_SB_SBR_NR <- ggplot(LEONT_SB_SBR_NR, aes(x = SubCompartName, y = Concentration, fill = source)) +  
  geom_violin() + 
  labs(
    title = paste0("SBR + NR concentrations at Regional scale, ", as.character(year)),
    subtitle = paste0(TWruns, " runs for Tyre wear"),
    x = "Compartment",
    y = "Concentration"
  ) +
  plot_theme +  # Ensure plot_theme is defined
  scale_y_log10(
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x))
  ) +
  annotation_logticks(
    sides = "l",  
    short = unit(0.07, "cm"),
    mid = unit(0.07, "cm"),
    long = unit(0.1, "cm"),
    size = 0.25
  ) +
  theme(
    legend.position = "bottom",   
    panel.grid.major = element_line(color = "lightgrey", size = 0.7), # Major grid lines
    panel.grid.minor = element_line(color = "lightgrey", size = 0.5)  # Minor grid lines
  ) +
  guides(fill = guide_legend(title = NULL))  # Remove legend title

# Display the plot
print(conc_LEONT_SB_SBR_NR)

ggsave(paste0(figurefolder, "SBR_NR_measurement_comparison",".png"), plot=conc_LEONT_SB_SBR_NR, width = 13, height = 23, dpi = 1000)

################################### NR fraction ################################

load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))

Mean <- mean(NR_SBR_fractions$NR_fraction)     
Median <- median(NR_SBR_fractions$NR_fraction)
q5 <- quantile(NR_SBR_fractions$NR_fraction, 0.05)
q25 <- quantile(NR_SBR_fractions$NR_fraction, 0.25)
q75 <- quantile(NR_SBR_fractions$NR_fraction, 0.75)
q95 <- quantile(NR_SBR_fractions$NR_fraction, 0.95)

# Make a histogram of the NR fraction distribution
hist_NR_fraction <- ggplot(NR_SBR_fractions, aes(x=NR_fraction)) +
  geom_histogram(color="black", fill="white") +
  plot_theme +
  xlab("NR fraction") +
  ylab("Count") +
  ggtitle("NR fraction distribution")

hist_NR_fraction

ggsave(paste0(figurefolder, "NR_fraction_histogram",".png"), plot=hist_NR_fraction, width = 20, height = 15, dpi = 1000)

############################## TWP radius histogram ############################ 

Material_Parameters_TW <- Material_Parameters_long |>
  filter(Source == "Tyre wear") |>
  filter(VarName == "RadS")

hist_TWP_radius <- ggplot(Material_Parameters_TW, aes(x=value)) +
  geom_histogram(color="black", fill="white") +
  plot_theme +
  xlab("Particle radius (nm)") +
  ylab("Count") +
  ggtitle("TWP radius distribution") + 
  scale_x_log10(
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x))
  ) +
  annotation_logticks(
    sides = "b",  
    short = unit(0.2, "cm"),
    mid = unit(0.2, "cm"),
    long = unit(0.3, "cm"),
    size = 0.25
  )

hist_TWP_radius

ggsave(paste0(figurefolder, "TWP_radius_histogram",".png"), plot=hist_TWP_radius, width = 20, height = 15, dpi = 1000)

######## Plot comparing NR and SBR concentration in water compartments #########

water_twp <- mass_conc_NR_SBR |>
  filter(Source == "Tyre wear") |>
  filter(SubCompart %in% c("lake", "sea", "river")) |>
  filter(Year == 2019) 

water_plot <- ggplot(water_twp, aes(y=Concentration, x=SubCompart, fill=Polymer)) + 
  geom_violin() +
  scale_y_log10(
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x))
  ) +
    annotation_logticks(
      sides = "l",  
      short = unit(0.2, "cm"),
      mid = unit(0.2, "cm"),
      long = unit(0.3, "cm"),
      size = 0.25
    ) + 
  plot_theme + 
  scale_fill_manual(values=NR_SBR_colors) +
  labs(title = "Concentration at continental scale, 2019",
       subtitle = paste0(TWruns, " runs for Tyre wear"),
       x = "Compartment",
       y = "Concentration")

water_plot

ggsave(paste0(figurefolder, "NR_SBR_water_compartments_comparison",".png"), plot=water_plot, width = 15, height = 20, dpi = 1000)

#################### Relation between concentration and kdeg ###################

degradation_in_water <- Material_Parameters_long |>
  filter(VarName == "kdeg") |>
  filter(Source == "Tyre wear") |>
  filter(Species == "Small") |>
  select(-Scale)

deg_conc_TW <- mass_conc_NR_SBR |>
  filter(Source == "Tyre wear") |>
  left_join(degradation_in_water, by=c("Polymer", "RUN", "SubCompart", "Source")) |>
  filter(Scale == "Continental") |>
  filter(!is.na(value))

for(j in unique(deg_conc_TW$Polymer)){
  deg_plot_data <- deg_conc_TW |>
    filter(Polymer == j)
  
  deg_plot <- ggplot(deg_plot_data, aes(x=value, y=Concentration, color=SubCompart)) + 
    geom_point() +
    scale_color_discrete() +
    ggtitle(paste0(j)) +
    scale_x_log10() + 
    scale_y_log10()
  
  print(deg_plot)
  
  ggsave(paste0(figurefolder, "kdeg_scatterplot_continental_", j, ".png"), plot=water_plot, width = 20, height = 20, dpi = 1000)
}

#################### Relation between concentration and kdeg ###################

rads <- Material_Parameters_long |>
  filter(VarName == "RadS") |>
  filter(Source == "Tyre wear") |>
  select(-c(Scale, SubCompart, Species))

rads_conc_TW <- mass_conc_NR_SBR |>
  filter(Source == "Tyre wear") |>
  left_join(rads, by=c("Polymer", "RUN")) |>
  filter(Scale == "Continental") |>
  filter(!is.na(value))

for(j in unique(rads_conc_TW$Polymer)){
  rads_plot_data <- rads_conc_TW |>
    filter(Polymer == j)
  
  rads_plot <- ggplot(rads_plot_data, aes(x=value, y=Concentration, color=SubCompart)) + 
    geom_point() +
    scale_color_discrete() +
    ggtitle(paste0("RadS, ", j)) +
    scale_x_log10() + 
    scale_y_log10()
  
  print(rads_plot)
  
  ggsave(paste0(figurefolder, "rads_scatterplot_continental_", j, ".png"), plot=rads_plot, width = 20, height = 20, dpi = 1000)
}

################ Find out why 'Other sources' runs often don't work 

## Check if there is a relation between complete runs and radii for each polymer
yearcount_other <- yearcount |>
  filter(Source == "Other sources")

Material_Parameters_long_other <- Material_Parameters_long |>
  filter(is.na(Source)) |>
  mutate(Source = "Other sources")

for(pol in unique(Material_Parameters_long_other$Polymer)){
  
  rads <- Material_Parameters_long_other |>
    filter(is.na(Source)) |>
    filter(Polymer == pol) |>
    filter(VarName == "RadS") |>
    full_join(yearcount_other, by=c("Source", "RUN")) |>
    mutate(complete_run = case_when(
      is.na(nyear) ~ "False",
      !is.na(nyear) ~ "True"))
  
  rads_hist <- ggplot(rads, aes(x = value, fill = complete_run)) +
    geom_histogram(color = "black", alpha = 0.7) + 
    theme_minimal() +
    xlab("Particle radius (nm)") +
    ylab("Count") +
    ggtitle(paste0("Histogram of ", pol ," Radii (other sources)")) +
    scale_fill_discrete() 
  
  print(rads_hist)
}

## Check if there is a relation between complete runs and kdeg values

comps <- c("sea", "naturalsoil")

kdeg <- Material_Parameters_long_other |>
  filter(VarName == "kdeg") |>
  filter(SubCompart %in% comps) |>
  full_join(yearcount_other, by=c("Source", "RUN")) |>
  mutate(complete_run = case_when(
    is.na(nyear) ~ "False",
    !is.na(nyear) ~ "True")) |>
  filter(Polymer == "RUBBER")

for(i in comps){
  kdeg_plot_data <- kdeg |>
    filter(SubCompart == i)
  
  kdeg_plot <- ggplot(kdeg_plot_data, aes(x = value, fill = complete_run)) +
    geom_histogram(color = "black", alpha = 0.7) + 
    theme_minimal() +
    xlab("Particle radius (nm)") +
    ylab("Count") +
    ggtitle(paste0("Histogram of kdeg ", i)) +
    scale_fill_discrete() 
  
  print(kdeg_plot)
}





