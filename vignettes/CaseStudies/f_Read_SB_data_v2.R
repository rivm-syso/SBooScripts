# Function to process a filepath and extract the SimpleBox outcome in the correct format
load_batch_result <- function(filepath = filepaths[1]) {
  load(filepath)
  
  # Extract run values
  runs <- str_extract(filepath, "(?<=_RUNS_)[0-9_]+")
  runs <- unlist(str_split(runs, "_"))
  minrun <- as.integer(runs[1])
  maxrun <- as.integer(runs[2])
  new_run_values <- seq(minrun, maxrun)
  
  # would also add something here to extract the source from the filename.
  
  # # Process material parameters
  # Material_Parameters_n <- Material_Parameters_n |>
  #   select(VarName, Source, Scale, SubCompart, Species, Distribution, Polymer, Unit, data) |>
  #   mutate(data = lapply(data, function(df) {
  #     df$RUN <- new_run_values
  #     return(df)
  #   })) |>
  #   unnest(data)
  
  # # Initialize output lists
  # output_data <- list(
  #   TW_concentrations = tibble(),
  #   TW_solutions = tibble(),
  #   TW_emissions = tibble(),
  #   Other_concentrations = tibble(),
  #   Other_solutions = tibble(),
  #   Other_emissions = tibble(),
  #   Material_Parameters_long = Material_Parameters_n,
  #   Units = tibble(),
  #   States = tibble()
  # )
  # 
  
  output_data <- NA
  # Process outcomes
  for (j in seq_along(Output$SBoutput)) {
    polymer <- Output$Polymer[j]
    polymer_outcome <- Output$SBoutput[[j]]$DynamicMass
    
    sol <- polymer_outcome |>
      mutate(RUN = new_run_values[as.integer(RUN)], 
             Polymer = polymer)
    
    # emis <- polymer_outcome$Input_Emission |>
    #   unnest(Emis) |>
    #   mutate(RUN = new_run_values[as.integer(RUN)], Polymer = polymer)
    # 
    # output_data$Units <- polymer_outcome$DynamicConc$Units
    # output_data$States <- polymer_outcome$States
    
    if ("NR" %in% unique(Output$Polymer)) { # This works, but take care as NR can be added to other sources in future as well!
      # conc <- conc |> mutate(Source = "Tyre wear")
      sol <- sol |> mutate(Source = "Tyre wear")
      # emis <- emis |> mutate(Source = "Tyre wear")
      
      # output_data$TW_concentrations <- bind_rows(output_data$TW_concentrations, conc)
      # output_data$TW_solutions <- bind_rows(output_data$TW_solutions, sol)
      # output_data$TW_emissions <- bind_rows(output_data$TW_emissions, emis)
    } else {
      # conc <- conc |> mutate(Source = "Other sources")
      sol <- sol |> mutate(Source = "Other sources")
      # emis <- emis |> mutate(Source = "OTher sources")
      
      # output_data$Other_concentrations <- bind_rows(output_data$Other_concentrations, conc)
      # output_data$Other_solutions <- bind_rows(output_data$Other_solutions, sol)
      # output_data$Other_emissions <- bind_rows(output_data$Other_emissions, emis)
    }
    if(j==1){output_data <- sol} else output_data <- rbind(output_data, sol)
  }
  
  return(output_data)
}
