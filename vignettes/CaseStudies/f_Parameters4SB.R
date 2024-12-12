########################################################
# Parameter preparation for probabilistic SB analysis

read_Prob4SB <- function(path_parameters_file = "vignettes/CaseStudies/CaseData/Microplastic_variables_v1.xlsx",
                         source_of_interest=source_of_interest,
                         n_samples = nrow(DPMFA_sink_micro$Emis[[1]]), # Number of emission runs 
                         # materials <- unique(Material_Parameters$Polymer)
                         materials = unique(DPMFA_sink_micro$Polymer), # materials in selected sources
                         scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale)),
                         subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart)),
                         species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))
){
  
  # path_parameters_file = path_parameters_file
  # source_of_interest=source_of_interest
  # n_samples = nrow(DPMFA_sink_micro$Emis[[1]]) # Number of emission runs
  # # materials <- unique(Material_Parameters$Polymer)
  # materials = unique(DPMFA_sink_micro$Polymer) # materials in selected sources
  # scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale))
  # subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart))
  # species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))

  source("vignettes/CaseStudies/ProbDistributionFun.R")
  
  Material_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Polymer_data") |> 
    # change um to nm unit conversion
    mutate(across(c(a, b, c, d), as.numeric)) |>
    mutate(across(c(a, b, c, d), ~ case_when(
      str_detect(Unit, "um") ~ . * 1000,
      TRUE ~ .
    ))) |>
    mutate(Unit = case_when(
      str_detect(Unit, "um") ~ "nm",
      TRUE ~ Unit
    ))
  
  if(!is.na(source_of_interest)){
    Material_Parameters <- Material_Parameters |>
      filter(MP_source == "Tyre wear")
  } else if(is.na(source_of_interest)){
    Material_Parameters <- Material_Parameters |>
      filter(is.na(MP_source))
  }
  
  explodeF <- function(df, target_col, explode_value, new_values) {
    df %>%
      # Use mutate to create a new column if the target column equals explode_value
      mutate(!!sym(target_col) := ifelse(!!sym(target_col) == explode_value, list(new_values), !!sym(target_col))) %>%
      # Unnest the target column to duplicate rows
      unnest(!!sym(target_col))
  }
  
  VarNames <- na.omit(unique(Material_Parameters$VarName))
  
  DefinedVariables <- lapply(VarNames,World$fetchData)
  names(DefinedVariables) = VarNames
  
  # how to cope with any. For now this, but materials should be only for material being calculated for.
  suppressWarnings({
    Material_Parameters <- explodeF(Material_Parameters, target_col = "Polymer", explode_value = "any", new_values = materials) # move this after and save unique values (n=same as in xlsx)
  })
  
  Material_Parameters_n <- data.frame()

  for(pol in materials){
    
    input_vars <- 
      Material_Parameters |>
      filter(!is.na(Distribution)) |>
      filter(Polymer == pol) 
    
    input_vars <- input_vars[order(input_vars$VarName), ]
    
    n_unique_vars <- length(unique(input_vars$VarName))
    
    # Generate LHS
    lhs_samples <- lhs::randomLHS(n_samples, n_unique_vars)
    
    # Count the number of sample columns needed per unique VarName
    var_counts <- table(input_vars$VarName)
    
    # Repeat the lhs sample columns based on var_counts
    repeated_lhs <- do.call(cbind, lapply(seq_len(ncol(lhs_samples)), function(i) {
      var_name <- names(var_counts)[i]
      replicate(var_counts[var_name], lhs_samples[, i])
    }))
    
    n_vars <- ncol(repeated_lhs)
    
    # Scale the lhs samples to the correct distributions
    sample_df_var <-  
      input_vars |> 
      mutate(nvar = c(1:n_vars)) |> 
      rowwise() |> 
      mutate(
        data = 
          case_match(
            Distribution,
            "Triangular" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = triangular(repeated_lhs[, nvar], a, b, c)
            )),
            "Uniform" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = uniform(repeated_lhs[, nvar], a, b)
            )),
            "Powerlaw" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = power_law(repeated_lhs[, nvar], a, b, c)
            )),
            "Trapezoidal" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = trapezoidal(repeated_lhs[, nvar], a, b, c, d)
            )),
            "TRWP_size" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = TRWP_size_dist(repeated_lhs[, nvar], path_parameters_file)
            )),
            "Log uniform" ~ list(tibble(
              RUN = seq_len(nrow(repeated_lhs)), 
              value = log_uniform(repeated_lhs[, nvar], a, b)
            )),
            .default = NA
          )
      )
    
    Material_Parameters_n <- rbind(Material_Parameters_n, sample_df_var)
  }
  
  # Make a table with statistics of the samples
  report_table <- Material_Parameters_n |>
    select(c(VarName, MP_source, Scale, SubCompart, Species, Distribution, Polymer, Unit, data, `Data Source`)) |>
    unnest(data) |> 
    ungroup() |> 
    group_by(VarName, Scale, SubCompart, Species, Distribution, Polymer, Unit, `Data Source`) |>
    summarise(min = min(value),
              p5 = quantile(value, 0.05),
              p25 = quantile(value, 0.25),
              p50 = quantile(value, 0.50),
              mean = mean(value),
              p75 = quantile(value, 0.75),
              p95 = quantile(value, 0.95))
  
  Material_Parameters_n <- 
    Material_Parameters_n %>% 
    separate_rows(Species, sep = "_") |> 
    separate_rows(SubCompart, sep = "_") |>
    mutate( Scale = str_replace_all(Scale, "any",
                                    paste(scales,collapse="__"))) |> 
    separate_rows(Species, sep = "__") |> 
    mutate( SubCompart = str_replace_all(SubCompart, "Water",
                                         paste(c("lake", "sea", "deepocean", "river"),
                                               collapse = "__"))) |> 
    separate_rows(SubCompart, sep = "__") |> 
    mutate( SubCompart = str_replace_all(SubCompart, "Soil",
                                         paste(subCompartments |> str_subset(c("soil")),
                                               collapse = "__"))) |> 
    separate_rows(SubCompart, sep = "__") |> 
    mutate( SubCompart = str_replace_all(SubCompart, "Sediment",
                                         paste(subCompartments |> str_subset(c("sediment")),
                                               collapse = "__"))) |> 
    separate_rows(SubCompart, sep = "__") |> 
    mutate( Species = str_replace_all(Species, "any",
                                      paste(species,collapse="__"))) |> 
    separate_rows(Species, sep = "__") |> 
    mutate( SubCompart = str_replace_all(SubCompart, "any",
                                         paste(subCompartments,collapse="__"))) |> 
    separate_rows(SubCompart, sep = "__") |> 
    rename(Source = MP_source)
  
  return(list(Parameter_summary=report_table,
              Material_Parameters_n = Material_Parameters_n))
  
}
