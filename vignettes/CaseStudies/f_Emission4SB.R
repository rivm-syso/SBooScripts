# script for running DMPFA Solvers

# part 1 loading DPMFA data

Load_DPMFA4SB <- function(abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData", 
                          abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData", # data file location
                          source_of_interest = "Tyre wear", # a specific source or NA for all
                          path_parameters_file = "vignettes/CaseStudies/CaseData/Microplastic_variables_v1.xlsx",
                          TESTING = F # if set to T, using only first 2 runs.
){
  library(tidyverse)
  load(abspath_EU)
  
  # Convert to long format
  data_long_EU <- 
    DPMFA_sink |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
    pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
                 names_to = "Year",
                 values_to = "Mass_Polymer_kt") |>
    rename(Cum_Mass_Polymer_kt = Mass_Polymer_kt) |> 
    ungroup() |> 
    group_by(Scale,Source,Polymer,To_Compartment, Material_Type, RUN) |> 
    reframe(Mass_Polymer_kt = Cum_Mass_Polymer_kt - lag(Cum_Mass_Polymer_kt, default = 0),
            Year = Year) |> # calculate yearly emission from cummulative
    ungroup() |> 
    mutate(Mass_Polymer_kg_s = Mass_Polymer_kt*1000000/(365.25*24*3600)) |> # Convert kt/year to kg/s
    filter(Material_Type == "micro") |> # Select microplastics only
    mutate(SBscale = ifelse(Scale == "EU", "C", "R")) 
  
  # Load NL data
  load(abspath_NL)
  
  # Convert to long format
  data_long_NL <- 
    DPMFA_sink |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
    pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
                 names_to = "Year",
                 values_to = "Mass_Polymer_kt") |>
    rename(Cum_Mass_Polymer_kt = Mass_Polymer_kt) |> 
    ungroup() |> 
    group_by(Scale,Source,Polymer,To_Compartment, Material_Type, RUN) |> 
    reframe(Mass_Polymer_kt = Cum_Mass_Polymer_kt - lag(Cum_Mass_Polymer_kt, default = 0), # calculate yearly emission from cummulative
            Year = Year) |> 
    ungroup() |> 
    mutate(Mass_Polymer_kg_s = Mass_Polymer_kt*1000000/(365.25*24*3600)) |> # Convert kt/year to kg/s
    filter(Material_Type == "micro") |> # Select microplastics only
    mutate(SBscale = ifelse(Scale == "EU", "C", "R")) 
  
  data_long <- rbind(data_long_EU, data_long_NL)
  
  ## TODO: this could be made more generic, related to hard coded "Tyre wear"
  if (all(!is.na(source_of_interest))) {
    # Check if all the elements of source_of_interest are present in data_long$Source
    if (!all(source_of_interest %in% unique(data_long$Source))) {
      print("Selected source(s) not in dataframe")
    } else {
      sources <- source_of_interest
    }
  } else if (all(is.na(source_of_interest))) {
    # If all elements are NA, return all unique sources
    sources <- unique(data_long$Source)
    sources <- sources[sources != "Tyre wear"]
  }
  
  # Assign SB compartments to DPMFA compartments
  DPMFA_sink_micro <- data_long |>
    filter(Source %in% sources) |>
    select(Source, To_Compartment, Mass_Polymer_kg_s, Year, RUN, Polymer, SBscale) |>
    rename(Scale = SBscale) |>
    filter(To_Compartment != "Sub-surface soil (micro)") |> # Exclude sub-surface soil because this is currently outside the scope of SimpleBox
    mutate(Compartment = case_when(
      str_detect(To_Compartment, "soil") ~ "s",
      str_detect(To_Compartment, "water") ~ "w",
      str_detect(To_Compartment, "air") ~ "a"
    )) |>
    mutate(Subcompartment = case_when(
      str_detect(To_Compartment, "Agricultural") ~ "2",
      str_detect(To_Compartment, "Natural") ~ "1",
      str_detect(To_Compartment, "Road side") ~ "3",
      str_detect(To_Compartment, "Residential") ~ "3",
      str_detect(To_Compartment, "Sea") ~ "2",
      str_detect(To_Compartment, "Surface") ~ "1",
      str_detect(To_Compartment, "Outdoor") ~ ""
    )) |>
    mutate(Species = case_when(
      Source == "Tyre wear" ~ "P",
      TRUE ~ "S")) |>
    mutate(Abbr = paste0(Compartment, Subcompartment, Scale, Species)) |>
    mutate(Subcompartment = paste0(Compartment, Subcompartment)) |>
    group_by(Abbr, Year, RUN, Polymer, Subcompartment) |>
    summarise(Mass_Polymer_kg_s = sum(Mass_Polymer_kg_s)) |>
    ungroup() |>
    select(Abbr, Year, Polymer, Mass_Polymer_kg_s, RUN, Subcompartment)
  
  # If the source is tyre wear, separate the mass into NR and SBR, according to a triangular distribution based on data of LEON-T deliverable 3.2
  if (!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    
    TRWP_data <- readxl::read_excel(path_parameters_file, sheet = "TRWP_data") |>
      select(NR_Average_fraction) 
    TRWP_data <- na.omit(TRWP_data)
    a <- min(TRWP_data$NR_Average_fraction)
    b <- max(TRWP_data$NR_Average_fraction)
    c <- mean(TRWP_data$NR_Average_fraction)
    
    nsamples <- max(DPMFA_sink_micro$RUN)
    NR_SBR_fractions <- triangle::rtriangle(nsamples, a, b, c)
    NR_SBR_fractions <- data.frame(NR_SBR_fractions) |>
      mutate(RUN = 1:nsamples) |>
      rename(NR_fraction = NR_SBR_fractions)
    
    DPMFA_sink_micro <- DPMFA_sink_micro |> 
      left_join(NR_SBR_fractions, by = "RUN") 
    
    NR_df <- DPMFA_sink_micro |>
      mutate(Polymer = "NR") |>
      mutate(Mass_Polymer_kg_s = Mass_Polymer_kg_s*NR_fraction) |>
      select(-NR_fraction)
    
    SBR_df <- DPMFA_sink_micro |>
      mutate(Polymer = "SBR") |>
      mutate(SBR_fraction = 1-NR_fraction) |>
      mutate(Mass_Polymer_kg_s = Mass_Polymer_kg_s*SBR_fraction) |>
      select(-c(NR_fraction, SBR_fraction))
    
    DPMFA_sink_micro <- rbind(NR_df, SBR_df)
  }
  
  if(TESTING==TRUE)  DPMFA_sink_micro <- DPMFA_sink_micro |> filter(RUN<3)
  
  DPMFA_sink_micro <- DPMFA_sink_micro |>
    rename(Mass_kg_s = Mass_Polymer_kg_s) |> # Input of uncertain solver needs columns with name "Mass_kg_s".
    mutate(Timed = as.double(Year)*(365.25*24*3600)) |>
    nest(Emis = c(RUN, Mass_kg_s))
  
  if (!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    return(list(DPMFA_sink_micro=DPMFA_sink_micro,
                NR_SBR_fractions=NR_SBR_fractions))
  } else {
    return(list(DPMFA_sink_micro=DPMFA_sink_micro))
  }
  
}