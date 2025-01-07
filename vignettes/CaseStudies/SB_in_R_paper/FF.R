################################################################################
# Script for calculating fate factors at Regional and Continental scales       #
# Created for SimpleBox in R paper                                             #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################

library(tidyverse)

source("baseScripts/initWorld_onlyParticulate.R")

## Get the areas for compartments at Regional scale
Area_w0R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "lake") |>  pull(Area)
Area_w1R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "river") |>  pull(Area)
Area_aR <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "air") |>  pull(Area)
Area_soilR <- World$fetchData("Area") |> filter(Scale == "Regional" & grepl("soil",SubCompart)) |>  pull(Area) |> sum()

## Get the areas for compartments at Continental scale
Area_w0C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "lake") |>  pull(Area)
Area_w1C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "river") |>  pull(Area)
Area_aC <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "air") |>  pull(Area)
Area_soilC <- World$fetchData("Area") |> filter(Scale == "Continental" & grepl("soil",SubCompart)) |>  pull(Area)|> sum()

## Calculate the river and lake fractions of freshwater at Regional scale
FracArea_w0R = Area_w0R/(Area_w0R+Area_w1R)
FracArea_w1R = Area_w1R/(Area_w0R+Area_w1R)

## Calculate the river and lake fractions of freshwater at Continental scale
FracArea_w0C = Area_w0C/(Area_w0C+Area_w1C)
FracArea_w1C = Area_w1C/(Area_w0C+Area_w1C)

## Calculate the fraction of air, soil and freshwater area at Regional scale compared to at Continental scale
FracArea_aRC = Area_aR/(Area_aR+Area_aC)
FracArea_wRC = (Area_w0R+Area_w1R)/((Area_w0R+Area_w1R)+(Area_w0C+Area_w1C))
FracArea_sRC = Area_soilR/(Area_soilR+Area_soilC)

## Store the emissions in a nested dataframe
EmisSourceFF <- expand_grid(Scale = c("Regional","Continental"),
                            EmisUnified = NA)

EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] == "Regional")] <- 
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

EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] == "Continental")] <- 
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

# Make an empty dataframe to store the output
Output_deterministic <- expand_grid(EmisComp = names(EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] ==  "Regional")][[1]]),
                          Scale = c("Regional","Continental"),
                          SBoutput = NA)

# Initialize the deterministic steady state solver
World$NewSolver("SBsteady")

for(ecomp in unique(Output_deterministic$EmisComp)){
    for(scl in unique(Output_deterministic$Scale)){
      
    emis_source <- as.data.frame(EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] == scl)][[1]][[ecomp]])
      
    solved <- World$Solve(emis_source)

    Output_deterministic$SBoutput[(Output_deterministic[["EmisComp"]] == ecomp &
                       Output_deterministic[["Scale"]] == scl)] <- list(solved)
  }
}













