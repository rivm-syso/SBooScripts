################################################################################
# Script for calculating fate factors dynamically and probabilistically for    #
# nano-TiO2                                                                    #
# Created for SimpleBox in R paper                                             #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 7-1-2024                                                                    #
################################################################################

library(tidyverse)

source("baseScripts/initWorld_onlyParticulate.R")
World$substance <- "nTiO2_10nm"

## Get the areas for compartments at Regional Scale
Area_w0R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "lake") |>  pull(Area)
Area_w1R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "river") |>  pull(Area)
Area_aR <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "air") |>  pull(Area)
Area_soilR <- World$fetchData("Area") |> filter(Scale == "Regional" & grepl("soil",SubCompart)) |>  pull(Area) |> sum()

## Get the areas for compartments at Continental Scale
Area_w0C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "lake") |>  pull(Area)
Area_w1C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "river") |>  pull(Area)
Area_aC <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "air") |>  pull(Area)
Area_soilC <- World$fetchData("Area") |> filter(Scale == "Continental" & grepl("soil",SubCompart)) |>  pull(Area)|> sum()

## Calculate the river and lake fractions of freshwater at Regional Scale
FracArea_w0R = Area_w0R/(Area_w0R+Area_w1R)
FracArea_w1R = Area_w1R/(Area_w0R+Area_w1R)

## Calculate the natural, agricultural an other soil fractions at Regional Scale
#FracArea_s1R = Area_s1R/(Area+)

## Calculate the river and lake fractions of freshwater at Continental Scale
FracArea_w0C = Area_w0C/(Area_w0C+Area_w1C)
FracArea_w1C = Area_w1C/(Area_w0C+Area_w1C)

## Calculate the fraction of air, soil and freshwater area at Regional Scale compared to at Continental Scale
FracArea_aRC = Area_aR/(Area_aR+Area_aC)
FracArea_wRC = (Area_w0R+Area_w1R)/((Area_w0R+Area_w1R)+(Area_w0C+Area_w1C))
FracArea_sRC = Area_soilR/(Area_soilR+Area_soilC)

## Store the emissions in a nested dataframe
EmisSourceFF <- expand_grid(EmisScale = c("Regional","Continental"),
                            EmisUnified = NA)

EmisSourceFF$EmisUnified[(EmisSourceFF[["EmisScale"]] == "Regional")] <- 
  list(list(
    Air = tibble(Abbr = c("aRP",
                          "s3RP",
                          "w1RP",
                          "w0RP"),
                 Emis = c(1,0,0,0)),
    Soil = tibble(Abbr = c("aRP",
                           "s3RP",
                           "w1RP",
                           "w0RP"),
                  Emis = c(0,1,0,0)),
    Water = tibble(Abbr = c("aRP",
                            "s3RP",
                            "w1RP",
                            "w0RP"),
                   Emis = c(0,0,
                            1*FracArea_w1R,
                            1*FracArea_w0R))))

EmisSourceFF$EmisUnified[(EmisSourceFF[["EmisScale"]] == "Continental")] <- 
  list(  list(
    Air = tibble(Abbr = c("aRP",
                          "s3RP",
                          "w1RP",
                          "w0RP",
                          "aCP",
                          "s3CP",
                          "w1CP",
                          "w0CP"),
                 Emis = c(1*FracArea_aRC,
                          0,0,0,
                          1*(1-FracArea_aRC),
                          0,0,0)),
    Soil = tibble(Abbr = c("aRP",
                           "s3RP",
                           "w1RP",
                           "w0RP",
                           "aCP",
                           "s3CP",
                           "w1CP",
                           "w0CP"),
                  Emis = c(0,1*FracArea_sRC,
                           0,0,
                           0,1*(1-FracArea_sRC),
                           0,0)),
    Water = tibble(Abbr = c("aRP",
                            "s3RP",
                            "w1RP",
                            "w0RP",
                            "aCP",
                            "s3CP",
                            "w1CP",
                            "w0CP"),
                   Emis = c(0,0,
                            1*FracArea_w1R*FracArea_wRC,
                            1*FracArea_w0R*FracArea_wRC,
                            0,0,
                            1*FracArea_w1C*(1-FracArea_wRC),
                            1*FracArea_w0C*(1-FracArea_wRC)))))

## Make a sample tibble containing a particle size for each run
set.seed(123)

# Set min and max particle size, based on Clément et al. (2016)
min_size_nm <- 1 
max_size_nm <- 100

# Set number of samples
n_samples <- 100

# Generate samples
samples <- runif(n=n_samples, min=min_size_nm, max=max_size_nm)
samples <- tibble(samples) |>
  rename(value = samples) |>
  mutate(RUN = row_number())

# Create an empty tibble
sample_df <- tibble(
  varName = "RadS",
  Scale = NA,
  SubCompart = NA, 
  Species = NA,
  data=list(samples))

# Make an empty dataframe to store the output
Output_deterministic <- expand_grid(EmisComp = names(EmisSourceFF$EmisUnified[(EmisSourceFF[["EmisScale"]] ==  "Regional")][[1]]),
                                    EmisScale = c("Regional","Continental"),
                                    SBoutput = NA)

# Initialize the deterministic steady state solver
World$NewSolver("UncertainSolver")

for(ecomp in unique(Output_deterministic$EmisComp)){
  for(scl in unique(Output_deterministic$EmisScale)){
    
    emis_source <- as.data.frame(EmisSourceFF$EmisUnified[(EmisSourceFF[["EmisScale"]] == scl)][[1]][[ecomp]])
    
    solved <- World$Solve((emis_source), needdebug = F, sample_df)
    
    Output_deterministic$SBoutput[(Output_deterministic[["EmisComp"]] == ecomp &
                                     Output_deterministic[["EmisScale"]] == scl)] <- list(solved$SteadyStateMass)
  }
}

# Unnest the deterministic output
FF_allScale <- Output_deterministic |> 
  unnest(SBoutput) |> 
  filter(Species != "Unbound") |> 
  group_by(EmisComp,EmisScale, Scale, SubCompart, RUN) |> 
  summarise(EqMass_SAP = sum(EqMass)) |>
  mutate(Unit = "kg[ss]/kg[e] seconds")

# Plot outcome
library(ggplot2)
library(scales)

# Define a function for plotting uncertain FF
violin_plot_FF <- function(FF_df, SelectedEmisScale, SelectedEmisComp){
  filtered_FF <- FF_df |>
    filter(EmisScale == SelectedEmisScale) |>
    filter(EmisComp == SelectedEmisComp) |>
    filter(Scale == SelectedEmisScale) |>
    filter(EqMass_SAP != 0)
  
  plot <- ggplot(data=filtered_FF, aes(x=SubCompart, y=EqMass_SAP)) + 
    geom_violin() +
    labs(title = "Fate factors calculated with uncertain particle size for nano-TiO2",
         subtitle = paste0("Calculated for emissions to ", SelectedEmisScale, " ", SelectedEmisComp),
         y = paste0("FF value ", unique(filtered_FF$Unit))) +
    scale_y_log10()
  
  return(plot)
}

# Plot FF in a violin plot for regional emissions to freshwater
plot_regional_freshwater <- violin_plot_FF(FF_allScale, "Regional", "Water")
print(plot_regional_freshwater)

filtered_FF <- FF_allScale |>
  filter(EmisScale == "Regional") |>
  filter(EmisComp == "Water") |>
  filter(Scale == "Regional")


# Calculate the FF at Regional Scale
FF_Regional <- FF_allScale |> filter(EmisScale == "Regional" & Scale == "Regional") |>
  mutate(
    CompartmentFF = case_when(
      SubCompart == "cloudwater" ~ "air",
      SubCompart == "lake" ~ "freshwater",
      SubCompart == "river" ~ "freshwater",
      SubCompart == "lakesediment" ~ "freshwatersediment",
      TRUE ~ SubCompart)
  ) |> ungroup() |> 
  group_by(CompartmentFF, EmisComp, RUN) |>
  summarise(EqMass_SAP = sum(EqMass_SAP)) |>
  mutate(Unit = "kg[ss]/kg[e] seconds")

# Calculate the FF at Continental Scale
FF_Continental <- FF_allScale |> 
  filter(EmisScale == "Continental" & (EmisScale == c("Regional")|EmisScale == c("Continental"))) |> 
  ungroup() |> 
  group_by(EmisComp,EmisScale,SubCompart) |> 
  summarise(EqMass_SAP = sum(EqMass_SAP)) |>  # sum nested regional mass and rest of continental mass
  mutate(
    CompartmentFF = case_when(
      SubCompart == "cloudwater" ~ "air",
      SubCompart == "lake" ~ "freshwater",
      SubCompart == "river" ~ "freshwater",
      SubCompart == "lakesediment" ~ "freshwatersediment",
      TRUE ~ SubCompart)
  ) |> ungroup() |> 
  group_by(CompartmentFF,EmisComp) |> 
  summarise(EqMass_SAP = mean(EqMass_SAP)) |> 
  mutate(Unit = "kg[ss]/kg[e] seconds")

# Make nicely formatted tables showing the FF
library(gridExtra)
pdf("vignettes/CaseStudies/SB_in_R_paper/Output/Regional_FF_table_deterministic_SS.pdf", height=11, width=8.5)
grid.table(FF_Regional)
dev.off()

pdf("vignettes/CaseStudies/SB_in_R_paper/Output/Continental_FF_table_deterministic_SS.pdf", height=11, width=8.5)
grid.table(FF_Continental)
dev.off()







