env <- "OOD"

source_of_interest =  NA

path_parameters_file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Microplastic_variables_v1.xlsx"

if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
  load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
} else {
  load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
}

DPMFA_sink_micro <- DPMFA_SBoutput$DPMFA_sink_micro

#source("baseScripts/initWorld_onlyPlastics.R")

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}




path_parameters_file = path_parameters_file
source_of_interest=source_of_interest
n_samples = nrow(DPMFA_sink_micro$Emis[[1]]) # Number of emission runs
# materials <- unique(Material_Parameters$Polymer)
materials = unique(DPMFA_sink_micro$Polymer) # materials in selected sources
scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale))
subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart))
species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))

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
#pol <- "Acryl"
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
            lhs_sample = repeated_lhs[, nvar], 
            value = triangular(repeated_lhs[, nvar], a, b, c)
          )),
          "Uniform" ~ list(tibble(
            RUN = seq_len(nrow(repeated_lhs)), 
            lhs_sample = repeated_lhs[, nvar], 
            value = uniform(repeated_lhs[, nvar], a, b)
          )),
          "Powerlaw" ~ list(tibble(
            RUN = seq_len(nrow(repeated_lhs)), 
            lhs_sample = repeated_lhs[, nvar], 
            value = power_law(repeated_lhs[, nvar], a, b, c)
          )),
          "Trapezoidal" ~ list(tibble(
            RUN = seq_len(nrow(repeated_lhs)), 
            lhs_sample = repeated_lhs[, nvar], 
            value = trapezoidal(repeated_lhs[, nvar], a, b, c, d)
          )),
          "TRWP_size" ~ list(tibble(
            RUN = seq_len(nrow(repeated_lhs)), 
            lhs_sample = repeated_lhs[, nvar], 
            value = TRWP_size_dist(repeated_lhs[, nvar], path_parameters_file)
          )),
          "Log uniform" ~ list(tibble(
            RUN = seq_len(nrow(repeated_lhs)), 
            lhs_sample = repeated_lhs[, nvar], 
            value = log_uniform(repeated_lhs[, nvar], a, b)
          )),
          .default = NA
        )
    )
  print(pol)
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

Parameters <- (list(Parameter_summary=report_table,
                    Material_Parameters_n = Material_Parameters_n))


# Plot the lhs values per polymer per variable

Material_Parameters_n <- Parameters$Material_Parameters_n

for(pol in unique(Material_Parameters_n$Polymer)){
  Material_Parameters_n_pol <- Material_Parameters_n |>
    filter(Polymer == pol) |>
    unnest(data) |>
    filter(RUN %in% 1:20)
  for(var in unique(Material_Parameters_n_pol$VarName)){
    Material_Parameters_n_var <- Material_Parameters_n_pol |>
      filter(VarName == var)
    
    if (length(unique(Material_Parameters_n_var$SubCompart)) != 1 && !any(is.na(Material_Parameters_n_var$SubCompart))) {
      plot1 <- ggplot(Material_Parameters_n_var, aes(x=RUN, y=lhs_sample, color=SubCompart)) +
        geom_line() +
        scale_color_discrete()+
        ggtitle(paste0(pol, ", ", var))

    print(plot1)
    } else {
      plot1 <- ggplot(Material_Parameters_n_var, aes(x=RUN, y=lhs_sample)) +
        geom_line() +
        scale_color_discrete()+
        ggtitle(paste0(pol, ", ", var))
      
      print(plot1)
    }
  }
}

