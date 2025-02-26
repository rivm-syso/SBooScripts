#### Fate Factor calculations
library(tidyverse)

env <- "OOD"
#env <- "HPC"

if(env == "OOD"){
  path_parameters_file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Microplastic_variables_v1.1.xlsx"
} else if(env == "HPC"){
  mainfolder <- "/data/BioGrid/hidsa/GitHub/SBooScripts/"
  path_parameters_file = paste0(mainfolder, "vignettes/CaseStudies/CaseData/Microplastic_variables_v1.1.xlsx")
}

source("baseScripts/initWorld_onlyPlastics.R")

# Select polymer's
# source_of_interest <- "Tyre wear"
source_of_interest <- NA


if(env == "OOD"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241130.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241130.RData"))
  }
} else if(env == "HPC"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_TWP_20241130.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_Other_20241130.RData"))
  }
}

Polymer_of_interest <- "RUBBER"

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  source <- "TWP"
  World$substance <- "TRWP"
} else {
  source <- "Other"
  World$substance <- "microplastic"
}

#### Select subset of RUNs from emission and parameters ####
#  Set the runs that need to be run, should be consecutive from x to y.
RUNSamples = c(1:1000)
print(paste("LOG: run started for", min(RUNSamples), "to", max(RUNSamples)))
##

## Specify the number of years
nYears <- 101

subsetRuns2 <- function(dfRUNs,nummers){ #Function to select RUNsamples from parameter data
  dfRUNs[nummers,]
}
Material_Parameters_n <- Parameters$Material_Parameters_n |> 
  mutate(data = map(data, subsetRuns2, nummers = RUNSamples))

# Read in data to change Regional scale to fit NL scale DPMFA data
Regional_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Netherlands_data") |>
  rename(varName = Variable) |>
  rename(Waarde = Value) |>
  select(-c(Unit,`...6`,`...7`) )

# Recalculate the area's
World$mutateVars(Regional_Parameters)
World$UpdateDirty(unique(Regional_Parameters$varName))

## Emissions
Area_w0R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "lake") |>  pull(Area)
Area_w1R <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "river") |>  pull(Area)
Area_w0C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "lake") |>  pull(Area)
Area_w1C <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "river") |>  pull(Area)
Area_aR <- World$fetchData("Area") |> filter(Scale == "Regional" & SubCompart == "air") |>  pull(Area)
Area_soilR <- World$fetchData("Area") |> filter(Scale == "Regional" & grepl("soil",SubCompart)) |>  pull(Area) |> sum()
Area_aC <- World$fetchData("Area") |> filter(Scale == "Continental" & SubCompart == "air") |>  pull(Area)
Area_soilC <- World$fetchData("Area") |> filter(Scale == "Continental" & grepl("soil",SubCompart)) |>  pull(Area)|> sum()

FracArea_w0R = Area_w0R/(Area_w0R+Area_w1R)
FracArea_w1R = Area_w1R/(Area_w0R+Area_w1R)
FracArea_w0C = Area_w0C/(Area_w0C+Area_w1C)
FracArea_w1C = Area_w1C/(Area_w0C+Area_w1C)

FracArea_aRC = Area_aR/(Area_aR+Area_aC)
FracArea_wRC = (Area_w0R+Area_w1R)/((Area_w0R+Area_w1R)+(Area_w0C+Area_w1C))
FracArea_sRC = Area_soilR/(Area_soilR+Area_soilC)

EmisSourceFF <- expand_grid(Scale = c("Regional","Continental"),
                            EmisUnified = NA)

# Make function to repeat the emission tibbles nYears and add Timed column
repeat_tibble <- function(tib, n) {
  tib |>
    slice(rep(1:n(), each = n)) |>
    mutate(Timed = rep(1:n, times = nrow(tib))) |>
    mutate(Timed = Timed-1)
}

#### Regional emissions
Air <- tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP"),
             Emis = c(1,0,0,0))

Soil = tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP"),
              Emis = c(0,1,0,0))

Water = tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP"),
               Emis = c(0, 0, 1*FracArea_w1R, 1*FracArea_w0R))

EmisSourceFF$EmisUnified[EmisSourceFF[["Scale"]] == "Regional"] <- list(
  list(
    Air = repeat_tibble(Air, nYears),
    Soil = repeat_tibble(Soil, nYears),
    Water = repeat_tibble(Water, nYears)
  )
)

#### Continental emissions
Air <- tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP", "aCP", "s3CP", "w1CP", "w0CP"),
              Emis = c(1*FracArea_aRC, 0, 0, 0, 1*(1-FracArea_aRC), 0, 0, 0))

Soil <- tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP", "aCP", "s3CP", "w1CP", "w0CP"),
               Emis = c(0, 1*FracArea_sRC, 0, 0, 0, 1*(1-FracArea_sRC), 0, 0))

Water <- tibble(Abbr = c("aRP", "s3RP", "w1RP", "w0RP", "aCP", "s3CP", "w1CP", "w0CP"),
                Emis = c(0, 0, 1*FracArea_w1R*FracArea_wRC, 1*FracArea_w0R*FracArea_wRC,
                         0, 0, 1*FracArea_w1C*(1-FracArea_wRC), 1*FracArea_w0C*(1-FracArea_wRC)))

EmisSourceFF$EmisUnified[EmisSourceFF[["Scale"]] == "Continental"] <- list(
  list(
    Air = repeat_tibble(Air, nYears),
    Soil = repeat_tibble(Soil, nYears),
    Water = repeat_tibble(Water, nYears)
  )
)

# empty tibble for storing output for all runs:

Output <- expand_grid(Polymer = Polymer_of_interest,
                      EmisComp = names(EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] ==  "Regional")][[1]]),
                      Scale = "Continental",
                      SBoutput = NA)

start_time <- Sys.time() # to see how long it all takes...

World$NewSolver("UncertainDynamicSolver")
i <- 1

for(ecomp in unique(Output$EmisComp)){
  for(pol in unique(Output$Polymer)){
    for(scl in unique(Output$Scale)){
      
      emis_source <- EmisSourceFF$EmisUnified[(EmisSourceFF[["Scale"]] == scl)][[1]][[ecomp]]
      
      if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
        sample_source <- Material_Parameters_n |>
          filter(Source == source_of_interest) |>
          filter(Polymer == pol)  |>
          dplyr::select(VarName, Scale, SubCompart, Species, data) |> 
          rename(varName = VarName) # SBoo uses varName TODO: make Capital...
      } else if(is.na(source_of_interest)){
        sample_source <- Material_Parameters_n |>
          filter(is.na(Source)) |>
          filter(Polymer == pol)  |>
          dplyr::select(VarName, Scale, SubCompart, Species, data) |> 
          rename(varName = VarName) # SBoo uses varName TODO: make Capital...
      }
      
      solved <- World$Solve((emis_source), sample_source, needdebug = F,
                            rtol_ode=1e-30, atol_ode = 0.5e-2)
      
      # Output$EmisComp[i] = names(EmisSourceFF) [i]
      
      Output$SBoutput[(Output[["EmisComp"]] == ecomp &
                         Output[["Polymer"]] == pol &
                         Output[["Scale"]] == scl)] <- list(solved)
      print(i)
      i <- i+1
    }
  }
}

elapsed_time <- Sys.time() - start_time
print(paste0("Elapsed time is ", elapsed_time))
elapsed_time 

if(env == "OOD"){
  save(Output, file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/FateFactors_Recipe_Dyn_", source, "_", Polymer_of_interest, 
                             format(Sys.Date(),"%Y%m%d"),".RData"))
} else if(env == "HPC"){
  save(Output, file = paste0(mainfolder, "vignettes/CaseStudies/Recipe/Output/FateFactors_Recipe_Dyn_", source, "_", Polymer_of_interest, 
                             format(Sys.Date(),"%Y%m%d"),".RData"))
}
