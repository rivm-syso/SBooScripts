# Script to load the output

### initialize ###
library(stringr)
library(tidyverse)
# Specify the environment
#env <- "OOD"
env <- "local"

if(env == "local"){
  folderpath <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Output/" 
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
} else if(env == "OOD"){
  folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Output/"
  filepaths <- list.files(folderpath)
  filepaths <- paste0(folderpath, filepaths)
}

filepath = filepaths[1]

TW_concentrations <- tibble()
TW_solutions <- tibble()

Other_concentrations <- tibble()
Other_solutions <- tibble()

Material_Parameters_long <- tibble()

for(filepath in filepaths){
  load(filepath)
  
  runs <-  str_extract(filepath, "(?<=_RUNS_)[0-9_]+") # Find the "99_100" part
  runs <- unlist(str_split(runs, "_"))  
  
  minrun <- runs[1]
  maxrun <- runs[2]
  new_run_values <- seq(minrun, maxrun)
  
  outcome <- Output$SBoutput
  
  Material_Parameters_n <- Material_Parameters_n |>
    select(VarName, Source, Scale, SubCompart, Species, Distribution, Polymer, Unit, data) |>
    mutate(data = lapply(data, function(df) {
      df$RUN <- new_run_values
      return(df)
    })) |>
    unnest(data)
  
  Material_Parameters_long <- bind_rows(Material_Parameters_n, Material_Parameters_long)
  
  for(j in 1:length(outcome)){
    polymer <- Output$Polymer[j]
    
    polymer_outcome <- outcome[[j]]
    
    conc <- polymer_outcome$DynamicConc$Concentrations |>
      mutate(RUN = as.integer(RUN))|>
      mutate(Polymer = polymer)
    conc$RUN <- new_run_values[conc$RUN]
    
    sol <- polymer_outcome$DynamicMass |>
      mutate(RUN = as.integer(RUN)) |>
      mutate(Polymer= polymer)
    sol$RUN <- new_run_values[sol$RUN]  
    
    if("NR" %in% unique(Output$Polymer)){
      TW_concentrations <- bind_rows(TW_concentrations, conc)
      TW_solutions <- bind_rows(TW_solutions, sol)
    } else {
      Other_concentrations <- bind_rows(Other_concentrations, conc)
      Other_solutions <- bind_rows(Other_solutions, sol)
    }
  }
}

# Save the outcome 
if(env == "local"){
  save(TW_concentrations, TW_solutions, Other_concentrations, Other_solutions, Material_Parameters_long,
       file = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.Rdata",
       compress = "xz",
       compression_level = 9)
} else if(env == "OOD"){
  save(TW_concentrations, TW_solutions, Other_concentrations, Other_solutions, Material_Parameters_long,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.RData",
       compress = "xz",
       compression_level = 9) 
}
