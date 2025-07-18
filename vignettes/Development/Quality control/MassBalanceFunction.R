# Mass balance function

f_mbalans <- function(substance_name = "1-aminoanthraquinone"){
  # substance_name <- "microplastic" # use substance name microplastic when running for polymer particles.
  
  substances <- read.csv("data/Substances.csv")
  substanceData <- substances |>
    filter(Substance == substance_name)
  
  # Initialize the correct World
  chemclass <- substanceData$ChemClass
  
  if(substanceData$Substance == "microplastic"){
    source("baseScripts/initWorld_onlyPlastics.R")
  } else if (chemclass == "particle") {
    source("baseScripts/initWorld_onlyParticulate.R")
  } else {
    source("baseScripts/initWorld_onlyMolec.R")
  }
  
  World$substance <- substanceData$Substance
  
  # Solve steady state
  World$NewSolver("SteadyStateSolver")
  
  if(chemclass == "particle"){
    emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS","s1AS"), Emis = c(10000, 10000, 10000,100)) # convert 1 t/y to si units: kg/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  } else {
    emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (World$fetchData("MW")*365 * 24 * 60 * 60))
  }
  
  emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s
  emissions <- emissions |>
    mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  
  
  World$Solve(emissions)
  
  # Check the mass balance
  
  RateConstants <- f_AddAbbreviationsSBxlsx()  |>
    filter(!(toScale %in% c("Regional", "Continental") & toSubCompart == "deepocean")) # remove k's for deepocean at continental and regional scale
  
  # Remove the unbound compartments if the substance is particle/microplastic
  if(chemclass == "particle"){
    RateConstants <- RateConstants |>
      filter(fromSpecies != "Unbound") |>
      filter(toSpecies != "Unbound")
  }
  
  Masses <- World$Masses()
  
  # Remove the unbound compartments if the substance is particle/microplastic
  if(chemclass == "particle"){
    Masses <- Masses |>
      filter(!endsWith(Abbr, "U"))
  }
  
  MassBalanceTest <- 
    RateConstants |> 
    full_join(Masses, by = join_by(from == Abbr)) |> 
    rename(fromMass_kg = Mass_kg) |> 
    mutate(ProcessMassFlow_kg_s = fromMass_kg * k)
  
  test <- World$exportEngineR()
  
  Removal <- 
    MassBalanceTest |> 
    mutate(Type = case_when(
      process == "k_Degradation" ~ "Removal",
      process == "k_Adsorption" ~ "InterMedia",
      process == "k_Advection" ~ "InterMedia",
      process == "k_Deposition" ~ "InterMedia",
      process == "k_Desorption" ~ "InterMedia",
      process == "k_Erosion" ~ "InterMedia",
      process == "k_Escape" ~ "Removal",
      process == "k_Resuspension" ~ "InterMedia",
      process == "k_Leaching" ~ "Removal",
      process == "k_Runoff" ~ "InterMedia",
      process == "k_Sedimentation" ~ "InterMedia",
      process == "k_Volatilisation" ~ "InterMedia",
      process == "k_Burial" ~ "Removal",
      TRUE ~ NA
    )) |> filter(Type == "Removal") |> 
    group_by(from) |> 
    summarise(Removal_kg_s = sum(ProcessMassFlow_kg_s ))
  
  MassBalanceTest2 <-
    MassBalanceTest |> pivot_wider(id_cols = to, names_from = from, values_from = ProcessMassFlow_kg_s,
                                   values_fn = sum,
                                   values_fill = 0) 
  
  Trans_from <-
    MassBalanceTest2 |> select(-to) |>  ungroup() |> 
    summarise(across(everything(),sum)) |> t()
  
  colnames(Trans_from) <- "Trans_from"
  
  Trans_to <-
    MassBalanceTest2 |> select(-to) |>  rowwise() |>
    mutate(Trans_to = sum(c_across(everything()))) |> select(Trans_to)
  
  #Trans_to <- as.matrix(Trans_to)
  
  trans_to_rownames <- MassBalanceTest2$to
  rownames(Trans_to) <- trans_to_rownames
  
  Trans_from_aligned <- Trans_from[rownames(Trans_to), , drop = FALSE]
  MassBalanceCheck <- cbind(Trans_to, Trans_from_aligned)
  
  MassBalanceCheck$Compartment <- row.names(MassBalanceCheck)
  MassBalanceCheck <- merge(MassBalanceCheck,World$Emissions(),by.x = "Compartment",by.y = "Abbr")
  MassBalanceCheck <- merge(MassBalanceCheck,Removal,by.x = "Compartment",by.y = "from")
  
  MassBalanceCheck <- 
    MassBalanceCheck |> 
    mutate(
      Diff_Flows = (Trans_to+Emission_kg_s)-(Trans_from+Removal_kg_s)
    )
  
  df_mb <- list(Substance = World$substance,
                MassBalanceCheck = MassBalanceCheck,
                Total_mass_balance = sum(MassBalanceCheck$Diff_Flows))
  return(df_mb)
}