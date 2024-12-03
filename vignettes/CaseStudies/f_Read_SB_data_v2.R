# Function to process a filepath and extract the SimpleBox outcome in the correct format
load_batch_result <- function(filepath = filepaths[1]) {
  load(filepath)
  
  # Extract run values
  runs <- str_extract(filepath, "(?<=_RUNS_)[0-9_]+")
  runs <- unlist(str_split(runs, "_"))
  minrun <- as.integer(runs[1])
  maxrun <- as.integer(runs[2])
  new_run_values <- seq(minrun, maxrun)
  
  # Extract source from filename
  source <- str_extract(filepath, "(?<=LEONT_)[^_]+(?=_RUNS)")
  
  output_data <- NA
  # Process outcomes
  for (j in seq_along(Output$SBoutput)) {
    polymer <- Output$Polymer[j]
    polymer_outcome <- Output$SBoutput[[j]]$DynamicMass
    
    sol <- polymer_outcome |>
      mutate(RUN = new_run_values[as.integer(RUN)], 
             Polymer = polymer)

    if (source == "TWP") { # This works, but take care as NR can be added to other sources in future as well!
      sol <- sol |> mutate(Source = "Tyre wear")

    } else if(source == "Other"){
      sol <- sol |> mutate(Source = "Other sources")
    }
    if(j==1){output_data <- sol} else output_data <- rbind(output_data, sol)
  }
  
  return(output_data)
}
