################################################################################
# DPMFA plots for LEON-T Deliverable 3.5                                       #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################

#####
## Initialize
library(ggplot2)
library(tidyverse)
library(scales)
library(openxlsx)
library(networkD3)
library(webshot)
library(jsonlite)
library(viridis)

## Define folder paths
Figure_folder <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Figures/D3.5_final_plots/"

#####
## Load data
load(file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL_EU_long.RData")
load(file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL_long.RData")
load(file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU_long.RData")
load(file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_emission_NL_EU_TW_time.RData")

#####
## Make functions for data preparation 

# Function that calculates t from kt, detects air, water and soil compartments and changes the names of sources
DPMFA_data_year_prep <- function(dpmfa_df){
  data_Year <- dpmfa_df |>
    mutate(Mass_Polymer_t = Mass_Polymer_kt * 1000, .keep = "unused") |> # convert kt to ton
    mutate(`Environmental_compartment` = # make column indicating of this an air, water or soil sink.
             case_when(
               str_detect(To_Compartment, 'water') ~ "water",
               str_detect(To_Compartment, 'air') ~ "air",
               str_detect(To_Compartment, 'soil') ~ "soil",
               .default = "none"
             )) |> filter(`Environmental_compartment` != "none") |> # remove sinks that are not environmental
    mutate(IenW_Source = # aggregate inputs to the Major sources classes the study focusses on
             case_when(
               str_detect(Source, 'Import of primary plastics') ~ "Pre-production pellets",
               str_detect(Source, 'Domestic primary plastic production') ~ "Pre-production pellets",
               str_detect(Source, 'Clothing') ~ "Clothing",
               str_detect(Source, 'Household textiles') ~ "Household textiles",
               .default = Source
             )) |>
    filter(!is.na(Mass_Polymer_t)) 
  
  return(data_Year)
}

# Function that creates a dataframe where microplastics and microplastics are identified
DPMFA_macro_sep <- function(dpmfa_df){
  data_Year_sep_macro <- dpmfa_df |> 
    filter(Material_Type == "micro") |> full_join(
      data_Year |> 
        filter(Material_Type == "macro") |> 
        ungroup() |> 
        group_by(Type, Scale, Polymer,To_Compartment, Material_Type, RUN, Year, Environmental_compartment) |> 
        summarise(Mass_Polymer_t = sum(Mass_Polymer_t),
                  IenW_Source = "Macroplastic",
                  Source = "Macroplastic"))
  return(data_Year_sep_macro)
}

# Function that sums microplastics over polymers
DPMFA_sum_over_polymers <- function(dpmfa_df){
  data_micro_summed_over_polymers <- dpmfa_df |>
    filter(Material_Type == "micro") |>
    group_by(Type, Scale, Source, To_Compartment, Material_Type, RUN, Year, Environmental_compartment, IenW_Source) |>
    summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
    mutate(TW_class = ifelse(Source == "Tyre wear", "Tyre wear", "Other sources"))
  return(data_micro_summed_over_polymers)
}

#####
## Prepare data for plotting
data_Year <- DPMFA_data_year_prep(data_long) |>
  mutate(Scale = "EU_with_NL")
data_Year_NL <- DPMFA_data_year_prep(data_long_NL) |>
  mutate(Scale = "NL")
data_Year_EU <- DPMFA_data_year_prep(data_long_EU) |>
  mutate(Scale = "EU")

data_Year_sep_macro <- DPMFA_macro_sep(data_Year)
data_Year_sep_macro_NL <- DPMFA_macro_sep(data_Year_NL)
data_Year_sep_macro_EU <- DPMFA_macro_sep(data_Year_EU)

data_micro_summed_over_polymers <- DPMFA_sum_over_polymers(data_Year)
data_micro_summed_over_polymers_NL <- DPMFA_sum_over_polymers(data_Year_NL)
data_micro_summed_over_polymers_EU <- DPMFA_sum_over_polymers(data_Year_EU)

##### 
## Set plot theme and colors
# Create a theme for the plots
plot_theme = theme(
  axis.title.x = element_text(size = 32),
  legend.text = element_text(size = 26),
  axis.text = element_text(size = 26), 
  axis.title.y = element_text(size = 32),
  title = element_text(size = 32),
  plot.background = element_rect(fill = 'white'),
  panel.background = element_rect(fill = 'white'),
  axis.line = element_line(color='black'),
  plot.margin = margin(2, 4, 2, 2, "cm"),
  legend.title = element_blank(),  
  panel.grid.major = element_line(color = "lightgrey", size = 0.5),  # Major grid lines in light grey
  panel.grid.minor = element_line(color = "lightgrey", size = 0.25)
)

# Define colors for groups
source_colors <- c(
  "Agriculture" = "#F8766D",
  "Clothing" = "#E58700",
  "Household textiles" = "#E76BF3",
  "Intentionally produced microparticles" = "#C99800",
  "Macroplastic" = "#A3A500",
  "Packaging" = "#619cff",
  "Paint" = "#00BA38",
  "Pre-production pellets" = "#00C0AF",
  "Technical textiles" = "#00B0F6",
  "Textile" = "#B983FF",
  "Tyre wear" = "#ff67a4"
)

TW_other_colors <- c(
  "Tyre wear" = "#ff67a4",
  "Other sources" = "#619cff"
)

micro_macro_colors <- c(
  "Microplastic" = "#A3A500",
  "Macroplastic" = "#B983FF"
)

sink_colors <- c(
  "Sea water" = "dodgerblue4",
  "Air" = "slategray3",
  "Other soil" = "darkgoldenrod",
  "Fresh water" = "cyan3",
  "Roadside soil" = "azure4"
)

to_comp_colors <- c(
  "Agricultural soil" = "#ff67a4",
  "Outdoor air" = "purple",
  "Residential soil" = "chartreuse4",
  "Road side soil" = "azure4",
  "Surface water" = "cyan3",
  "Sub-surface soil" = "orange"
)

##### 
## Figure 12
TW_other <- bind_rows(data_micro_summed_over_polymers, data_micro_summed_over_polymers_EU, data_micro_summed_over_polymers_NL) |>
  group_by(TW_class, RUN, Scale) |>
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
  mutate(
    Scale = str_replace_all(Scale, "EU_with_NL", "EU + NL"),
    Scale = factor(Scale, levels = c("EU + NL", "EU", "NL")) # Reorder levels
  ) |>
  mutate(as.factor(Scale)) 

Figure_12 <- ggplot(TW_other, aes(x = Scale, y = Mass_Polymer_t, fill=TW_class)) +
  geom_violin() +
  theme(legend.position="bottom")+
  
  scale_fill_manual(values = TW_other_colors) +
  scale_y_log10(labels = scales::number_format())+          
  labs(x = "",
       y = "Microplastic emissions (ton)")+
  coord_flip() +
  plot_theme 

Figure_12

ggsave(paste0(Figure_folder, "Figure_12", ".png"), plot=Figure_12,
       width = 20, height = 10)
#####
## Figure 13
barplot_data <- data_micro_summed_over_polymers |>
  ungroup() |> 
  mutate(Environmental_compartment = case_when(
    Environmental_compartment == "soil" ~ "Other soil",
    Environmental_compartment == "air" ~ "Air",
    .default = Environmental_compartment
  )) |>
  mutate(Environmental_compartment = case_when(
    To_Compartment == "Road side soil (micro)" ~ "Roadside soil",
    To_Compartment == "Surface water (micro)" ~ "Fresh water",
    To_Compartment == "Sea water (micro)" ~ "Sea water",
    .default = Environmental_compartment
  )) |>
  group_by(Scale, TW_class, To_Compartment, Environmental_compartment, Year, Type, Material_Type) |> 
  summarise(Mass_Polymer_t = mean(Mass_Polymer_t),
            n = n()) |> 
  ungroup() |> 
  group_by(Scale, TW_class, Environmental_compartment, Year, Type) |> 
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t),
            n= n())

# Make a stacked barplot for what percentage goes to air, soil and water
Figure_13 <- ggplot(barplot_data, aes(fill = Environmental_compartment, x = TW_class, y = Mass_Polymer_t)) +
  geom_bar(position = "fill", stat="identity", color = "transparent") +
  scale_fill_manual(values = sink_colors) +
  scale_x_discrete(labels = wrap_format(10)) +                   # Wraps text longer than 10 characters
  scale_y_continuous(labels = scales::percent) +
  plot_theme +
  labs(y= "Distribution",
       x="") +
  labs(fill='Sink type') +
  theme( # Override specific elements
    panel.grid.major = element_blank(), # Major grid lines removed
    panel.grid.minor = element_blank()  # Minor grid lines removed
  ) 

Figure_13

ggsave(paste0(Figure_folder, "Figure_13",".png"), plot=Figure_13,
       width = 20, height = 10)

##### 
## Figure 14
TW_data <- data_micro_summed_over_polymers |>
  mutate(TW_class = ifelse(Source == "Tyre wear", "Tyre wear", "Other sources")) |>
  filter(Source == "Tyre wear") |>
  mutate(To_Compartment = str_remove(To_Compartment, fixed(" (micro)")))

Figure_14 <- ggplot(TW_data, aes(x = To_Compartment, y = Mass_Polymer_t, fill=To_Compartment)) +
  geom_violin() +
  theme(legend.position="none")+
  scale_y_log10(labels = scales::number_format())+          
  labs(x = "", y = "Microplastic emissions (ton)") +                   # Adjust labels
  coord_flip() +
  plot_theme 

Figure_14

ggsave(paste0(Figure_folder, "Figure_14",".png"), plot=Figure_14,
       width = 20, height = 10)

#####
## Figure 15
excluded_compartments <- c("Landfill", "Elimination", "Secondary material reuse")

TW_mean_data <- TW_emissions_over_time |>
  mutate(Mass_Polymer_t = Mass_Polymer_kt*1000) |>
  group_by(Source, To_Compartment, Year, Scale, Polymer) |>
  summarise(Mean = mean(Mass_Polymer_t)) |>
  mutate(Year = as.integer(Year)) |>
  filter(!To_Compartment %in% excluded_compartments) |>
  mutate(To_Compartment = str_replace_all(To_Compartment, " \\(micro\\)", ""))

Figure_15 <- ggplot(TW_mean_data, aes(x = Year, y = Mean, colour = To_Compartment, group = To_Compartment)) +
  geom_line(size=1) +
  plot_theme +          
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="l",  
                      short = unit(0.07, "cm"),
                      mid = unit(0.07, "cm"),
                      long = unit(0.1, "cm"),
                      size = 0.25) +
  labs(x = "Year", y = "Mean microplastic emission (ton)", title = "Tyre wear emissions to environmental compartments") +
  scale_color_manual(values = to_comp_colors) 

Figure_15

ggsave(paste0(Figure_folder, "Figure_15", ".png"), plot=Figure_15,
       width = 20, height = 10)

#####
## Figure S3
palette_name <-"RdYlBu"

# Calculate mean flows for TW
TW_sankey_data <- TW_emissions_over_time |>
  filter(Year == 2019) |>
  group_by(Source, Polymer, To_Compartment) |>
  summarise(Mass_Polymer_kt = mean(Mass_Polymer_kt)) |>
  mutate(From_Compartment = "Tyre wear") |>
  mutate(Mass_Polymer_t = Mass_Polymer_kt*1000)

links <- TW_sankey_data |>
  group_by(Source, To_Compartment) |>
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
  filter(Mass_Polymer_t !=0)|>
  rename(source = Source, target = To_Compartment, value = Mass_Polymer_t)

# Prepare node labels
source_label_names <- links |>
  group_by(source) |>
  summarise(value = sum(value) / 1000, 2) |>
  mutate(value = format(value, scientific = TRUE, digits = 3))|>
  mutate(label = paste0(source, ': ', value, " kt"))

target_label_names <- links |>
  group_by(target) |>
  summarise(value = sum(value) / 1000, 2) |>
  mutate(value = format(value, scientific = TRUE, digits = 3))|>
  mutate(label = paste0(target, ': ', value, " kt"))

all_names <- c(source_label_names$source, target_label_names$target)
all_labels <- c(source_label_names$label, target_label_names$label)

# Make dataframe with node names
nodes <- data.frame(name = all_names, label = all_labels)

# Add columns to links (needed for sankey function)
links$source_id <- match(links$source, nodes$name) - 1
links$target_id <- match(links$target, nodes$name) - 1

# Create a color scheme
viridis_colors <- viridis(length(unique(links$target)), option = "D")

color_scale <- paste0(
  'd3.scaleOrdinal()',
  '.domain(["', paste(unique(links$target), collapse = '", "'), '"])',
  '.range(["', paste(viridis_colors, collapse = '", "'), '"])')

# Make the sankey diagram
sankey <- sankeyNetwork(Links = links, 
                        Nodes = nodes, 
                        Source = 'source_id',
                        Target = 'target_id',
                        Value = 'value', 
                        NodeID = 'label',
                        fontSize = 25, 
                        LinkGroup='target')

sankey 

filename<- "Figure_S3"

# Save the sankey diagram as an HTML file
html_file <- paste0(Figure_folder, filename, ".html")
saveNetwork(sankey, file = html_file, selfcontained = TRUE)
