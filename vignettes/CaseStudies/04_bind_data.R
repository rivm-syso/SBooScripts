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

# Fix old filenames
selected_filepaths <- filepaths[grep("20241112", filepaths)]
filepaths_new <- gsub("20241112", "v1", selected_filepaths)
for(i in 1:length(selected_filepaths)){
  file.rename(selected_filepaths[i], filepaths_new[i])
}

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
    
    States <- polymer_outcome$States
    Units <- polymer_outcome$DynamicCons$Units
    
    if("NR" %in% unique(Output$Polymer)){
      conc <- conc |>
        mutate(Source = "Tyre wear")
      
      sol <- sol |>
        mutate(Source = "Tyre wear")
      TW_concentrations <- bind_rows(TW_concentrations, conc)
      TW_solutions <- bind_rows(TW_solutions, sol)
    } else {
      
      conc <- conc |>
        mutate(Source = "Other sources")
      
      sol <- sol |>
        mutate(Source = "Other sources")
      
      Other_concentrations <- bind_rows(Other_concentrations, conc)
      Other_solutions <- bind_rows(Other_solutions, sol)
    }
  }
}

# Bind the rows of the concentration and solution dataframes together for both sources 
Concentrations <- bind_rows(TW_concentrations, Other_concentrations)
Solution <- bind_rows(TW_solutions, Other_solutions) 

# Save the outcome 
if(env == "local"){
  save(Concentrations, Solution, Material_Parameters_long, States, Units,
       file = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.Rdata",
       compress = "xz",
       compression_level = 9)
} else if(env == "OOD"){
  save(Concentration, Solution, Material_Parameters_long, States, Units,
       file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Long_solution_v1.RData",
       compress = "xz",
       compression_level = 9) 
}
