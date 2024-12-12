################################################################################
# SimpleBox plots for LEON-T Deliverable 3.5                                   #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################

#####
## Initialize
library(tidyverse)
library(readxl)
#library(viridis)
library(scales)

## Define paths 
data_path <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/" # Define path to plot data
figurefolder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/D3.5_final_plots/" # Define figure folder path
abs_path_Measurements <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/LEONT_TNO_measurements_clean2.xlsx" # Define path to LEON-T measurement data

## Load functions
source("vignettes/CaseStudies/f_plot_functions.R")

## Load data
load(paste0(data_path, "SB_Masses.RData"))
load(paste0(data_path, "SB_Tyre_wear_data.RData"))
load(paste0(data_path, "SB_Material_parameters.RData"))
load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))

##### 
##Calculate number of complete runs
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

## Number of complete runs per Source
nruns <- yearcount |>
  group_by(Source) |>
  count()

## Number of complete runs for Tyre wear
TWruns <- nruns |>
  filter(Source == "Tyre wear") 
TWruns <- TWruns$n

## Number of complete runs for Other sources
Otherruns <- nruns |>
  filter(Source == "Other sources") 
Otherruns <- Otherruns$n

##### 
## Calculate concentrations from masses
source("baseScripts/initWorld_onlyPlastics.R")
Matrix <- World$fetchData("Matrix")

# Calculate concentrations for masses summed over polymers
mass_conc_summed_over_pol <- 
  Solution_long_summed_over_pol |>
  left_join(World$fetchData("Volume"), 
            by=c("Scale", "SubCompart")) |>
  # Change 'cloudwater' to 'air', and then sum the masses and volumes of these compartments together
  mutate(SubCompart = ifelse(SubCompart == "cloudwater", "air", SubCompart)) |>
  ungroup() |> 
  group_by(RUN, Source, Year, Scale, SubCompart) |>
  summarise(Mass = sum(Mass),
            Volume = sum(Volume)) |>
  ungroup() |>
  # Calculate the concentrations
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

# Calculate concentrations for NR SBR dataframe
mass_conc_NR_SBR <- NR_SBR_data |>
  mutate(Source = "Tyre wear") |>
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

##### 
## Select only the complete runs for all concentration dataframes 
mass_conc_summed_over_pol <- mass_conc_summed_over_pol |>
  inner_join(yearcount, by = c("RUN", "Source"))

mass_conc_NR_SBR <- mass_conc_NR_SBR |>
  inner_join(yearcount, by = c("RUN", "Source"))

mass_conc_continental_polymer <- mass_conc_continental_polymer |>
  inner_join(yearcount, by = c("RUN", "Source"))

mass_conc_SB_data_TW <- mass_conc_SB_data_TW |>
  inner_join(yearcount, by = c("RUN", "Source"))

##### 
## Set plot theme and colors
# Create a plot theme
plot_theme <-  theme(
  axis.title.x = element_text(size = 30),    
  axis.title.y = element_text(size = 30),    
  axis.text.x = element_text(size = 28, angle = 45, hjust = 1),     
  axis.text.y = element_text(size = 28),
  legend.text = element_text(size = 28),
  title = element_text(size=30),
  panel.background = element_rect(fill = "white"),  # White background
  panel.grid.major = element_line(color = "lightgrey", size = 1),  # Major grid lines in light grey
  panel.grid.minor = element_line(color = "lightgrey", size = 1)
)

Source_colors <- c("Tyre wear" = "#2D708EFF",
                   "Other sources" = "#440154FF")

NR_SBR_colors <- c("NR" = "#20A387FF",
                   "SBR" = "#481567FF")

year <- 2019

##### 
## Figure 17
conc_plot_data <- mass_conc_summed_over_pol  |>
  filter(Scale == "Continental") |>
  filter(Year == year)

# Violin plot comparing tyre wear and other sources
Figure_17 <- ggplot(conc_plot_data, mapping = aes(x = SubCompartName, y = Concentration, fill = Source)) +  
  geom_violin() + 
  labs(title = paste0("Concentrations at continental scale, ", as.character(year)),
       x = "",
       y = "Concentration") +
  plot_theme +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  )  +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  scale_fill_manual(values = Source_colors) +
  theme(legend.position = "bottom") +   
  guides(fill = guide_legend(title = NULL))

Figure_17

ggsave(paste0(figurefolder, "Figure_17", ".png"), plot=Figure_17, width = 25, height = 15, dpi = 1000)

##### 
## Figure 18
rads <- Material_Parameters_long |>
  filter(VarName == "RadS") |>
  filter(Source == "Tyre wear") |>
  select(-c(Scale, SubCompart, Species))

rads_conc_TW <- mass_conc_NR_SBR |>
  filter(Source == "Tyre wear") |>
  left_join(rads, by=c("Polymer", "RUN")) |>
  filter(Scale == "Continental") |>
  filter(!is.na(value))

rads_plot_data <- rads_conc_TW |>
  filter(Polymer == "SBR") |>
  mutate(SubCompartName = case_when(
    SubCompartName == "air (mg/m3)" ~ "air (mg/m^3)",
    TRUE ~ SubCompartName
  ))

Figure_18 <- ggplot(rads_plot_data, aes(x=value, y=Concentration, color=SubCompartName)) + 
  geom_point() +
  scale_color_discrete() +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  plot_theme +
  labs(title = "SBR",
       x = "Particle radius (nm)",
       y = "Concentration") +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  annotation_logticks(sides="b",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  theme(legend.title = element_blank()) + 
  guides(color = guide_legend(override.aes = list(size = 10)))

Figure_18

ggsave(paste0(figurefolder, "Figure_18", ".png"), plot=Figure_18, width = 15, height = 15, dpi = 600)

##### 
## Figure 19
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

Figure_19 <- ggplot(NR_fraction_over_time, mapping = aes(x = Year, y = fraction_NR, color = SubCompart)) +
  geom_line(size = 2) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  labs(
    title = paste0("Mean natural rubber fraction at Continental scale"),
    x = "Year",
    y = paste0("Fraction")) +  
  plot_theme +
  theme(legend.title = "Subcompartment")

Figure_19

ggsave(paste0(figurefolder, "Figure_19.png"), plot=Figure_19, width = 25, height = 15, dpi = 1000) 

##### 
## Figure 20
plotdata_other <- mass_conc_continental_polymer |>
  filter(SubCompart == "othersoil") |>
  filter(Source == "Other sources") |>
  group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale, Unit) |>
  summarise(Mean_Concentration = mean(Concentration)) |>
  ungroup() |>
  group_by(Year, Source, SubCompart, SubCompartName, Scale, Unit) |>
  summarise(Mean_Concentration = mean(Mean_Concentration)) |>
  ungroup() |>
  mutate(Polymer = "Other polymers")

plotdata_TW <- mass_conc_continental_polymer |>
  filter(SubCompart == "othersoil") |>
  filter(Source == "Tyre wear") |>
  group_by(Polymer, Year, Source, SubCompart, SubCompartName, Scale, Unit) |>
  summarise(Mean_Concentration = mean(Concentration)) |>
  ungroup()

plotdata <- bind_rows(plotdata_other, plotdata_TW)

Figure_20 <- ggplot(plotdata, mapping = aes(x = Year, y = Mean_Concentration, color = Polymer)) +
  geom_line(size = 2) +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 5),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  labs(
    title = paste0("Microplastic concentrations in other soil at Continental scale"),
    x = "Year",
    y = paste0("Concentration (", unique(plotdata_TW$Unit), ")")
  ) +
  plot_theme

Figure_20

ggsave(paste0(figurefolder, "Figure_20",".png"), plot=Figure_20, width = 25, height = 15, dpi = 1000) 

##### 
## Figure 21
LEONT_TWP_data <- prep_LEONT_data(abs_path_Measurements) 

subcomparts <- unique(LEONT_TWP_data$SubCompart)

# Prepare SimpleBox data for plotting
mass_conc_SB_data_TW2 <- mass_conc_SB_data_TW |>
  mutate(Concentration = case_when(
    SubCompart == "air" ~ Concentration*1000,
    SubCompart == "river" ~ Concentration*1000,
    TRUE ~ Concentration
  )) |>
  mutate(Unit = case_when(
    SubCompart == "air" ~ "µg/m^3",
    SubCompart == "river" ~ "µg/L",
    Unit == "g/kg dw" ~ "mg/g dw",
    TRUE ~ Unit
  )) |>
  mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")" )) |>
  mutate(Polymer = "SBR + NR") |>
  mutate(source = "SimpleBox") |>
  filter(SubCompart %in% subcomparts) |>
  mutate(Locatie = "SimpleBox") |>
  select(colnames(LEONT_TWP_data)) 

# Make plot comparing LEONT and SB data
LEONT_SB_SBR_NR <- bind_rows(LEONT_TWP_data, mass_conc_SB_data_TW2) |>
  filter(Polymer == "SBR + NR") 

Figure_21 <- ggplot(LEONT_SB_SBR_NR, aes(x = SubCompartName, y = Concentration, col=source)) +  
  geom_violin(data = LEONT_SB_SBR_NR %>% filter(source == "SimpleBox"), 
              aes(fill = source), alpha = 0.5) + 
  geom_jitter(data = LEONT_SB_SBR_NR %>% filter(source == "LEON-T measurement"), 
              aes(col = source), 
              position = position_jitter(width = 0.2), alpha = 1, size = 3) +
  scale_fill_manual(values = c("SimpleBox" = "#00c0AF", "LEON-T measurement" = "#F8766D")) +
  scale_color_manual(values = c("LEON-T measurement" = "#F8766D")) +
  labs(
    title = paste0("SBR + NR concentrations at Regional scale, ", as.character(year)),
    x = "",
    y = "Concentration"
  ) +
  plot_theme +  
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  annotation_logticks(
    sides = "l",  
    short = unit(0.07, "cm"),
    mid = unit(0.07, "cm"),
    long = unit(0.1, "cm"),
    size = 0.25) +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(title = NULL), color = guide_legend(title = NULL))  # Remove legend titles

Figure_21

ggsave(paste0(figurefolder, "Figure_21.png"), plot = Figure_21, width = 20, height = 23, dpi = 1000)

##### 
## Figure S1
Material_Parameters_TW <- Material_Parameters_long |>
  filter(Source == "Tyre wear") |>
  filter(VarName == "RadS")

Figure_S1 <- ggplot(Material_Parameters_TW, aes(x=value)) +
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
    size = 0.25)

Figure_S1

ggsave(paste0(figurefolder, "Figure_S1",".png"), plot=Figure_S1, width = 20, height = 15, dpi = 1000)

## Figure S2
Figure_S2 <- ggplot(NR_SBR_fractions, aes(x=NR_fraction)) +
  geom_histogram(color="black", fill="white") +
  plot_theme +
  xlab("NR fraction") +
  ylab("Count") +
  ggtitle("NR fraction distribution")

Figure_S2

ggsave(paste0(figurefolder, "Figure_S2",".png"), plot=Figure_S2 , width = 20, height = 15, dpi = 1000)

#####
## Table S18
Table_S18 <- continental_polymer_data |>
  group_by(Source, RUN, Polymer) |>
  summarise(Year_count = n_distinct(Year), .groups = "drop") |>
  mutate(complete = 
           case_when(Year_count == 101 ~ 1,
                     Year_count != 101 ~ 0)) |>
  group_by(Source, Polymer) |>
  summarise

