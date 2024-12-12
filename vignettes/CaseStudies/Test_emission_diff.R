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

######
#Calculate mean percentages of total emissions per category
data_summary <- rbind(data_micro_summed_over_polymers, data_micro_summed_over_polymers_NL) |>
  group_by(Source, Year, RUN, Scale) |>
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
  ungroup() |>
  group_by(Source, Year, Scale) |>
  summarise(Mean_mass_t = mean(Mass_Polymer_t)) 

total_emis <- data_summary |>
  group_by(Scale) |>
  summarise(total_emis <- sum(Mean_mass_t))

total_emis_NL <- 



data_summary_NL <- data_micro_summed_over_polymers_NL |>
  group_by(Source, Year, RUN) |>
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
  ungroup() |>
  group_by(Source, Year) |>
  summarise(Mean_mass_t_NL = mean(Mass_Polymer_t)) 
  
total_emis_NL <- sum(data_summary_NL$Mean_mass_t_NL)

data_summary_NL <- data_summary_NL |>
  mutate(fraction_of_total_NL = Mean_mass_t_NL/total_emis_NL)



data_summary_EU <- data_micro_summed_over_polymers |>
  group_by(Source, Year, RUN) |>
  summarise(Mass_Polymer_t = sum(Mass_Polymer_t)) |>
  ungroup() |>
  group_by(Source, Year) |>
  summarise(Mean_mass_t_EU = mean(Mass_Polymer_t))

total_emis_EU <- sum(data_summary_EU$Mean_mass_t_EU)

data_summary_EU <- data_summary_EU |>
  mutate(fraction_of_total_EU = Mean_mass_t_EU/total_emis_EU)

# Make one table of the results
table_NL_EU <- data_summary_NL |>
  left_join(data_summary_EU, "Source")

long_NL_EU <- rbind(data_summary_EU, data_summary_NL)

write.xlsx(table_NL_EU, "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Emission_fraction_table_NL_EU.xlsx")

plot <- ggplot(table_NL_EU)

