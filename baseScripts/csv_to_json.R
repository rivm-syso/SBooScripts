library(dplyr)
library(jsonlite)

na_or_value <- function(x) {
  if (is.na(x)) NULL else x
}

particulate_substance_to_json <- function(data, 
                                           bact_test_value = 40000, 
                                           degapproach = "Default",
                                           kssdr = NA_real_, 
                                           velinput = NA_real_
                                          # ,
                                          #  shape = "Sphere",
                                          #  Shortest_side = 1,
                                          #  Intermediate_side = 1.5,
                                          #  Longest_side = 2
                                           ) {
  bact_test_value = as.numeric(bact_test_value)
  
  substance_row <- data %>%
    dplyr::filter(is.na(VarName)) %>%
    dplyr::slice(1)
  
  # alpha rows
  alpha_rows <- data %>%
    dplyr::filter(VarName == "alpha") |>
    select(VarName, Waarde, SubCompart, Species)
  
  alpha_list <- setNames(
    lapply(seq_len(nrow(alpha_rows)), function(i) {
      list(
        SubCompart = alpha_rows$SubCompart[i],
        Species    = alpha_rows$Species[i],
        alpha       = alpha_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(alpha_rows)))
  )
  
  # kdeag rows
  kdeag_rows <- data %>%
    dplyr::filter(VarName == "kdeag") |>
    select(VarName, Waarde, SubCompart, Species)
  
  kdeag_list <- setNames(
    lapply(seq_len(nrow(kdeag_rows)), function(i) {
      list(
        SubCompart = kdeag_rows$SubCompart[i],
        Species    = kdeag_rows$Species[i],
        kdeag       = kdeag_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(kdeag_rows)))
  )
  
  # kdis rows
  kdis_rows <- data %>%
    dplyr::filter(VarName == "kdis") |>
    select(VarName, Waarde, SubCompart, Species)
  
  kdis_list <- setNames(
    lapply(seq_len(nrow(kdis_rows)), function(i) {
      list(
        SubCompart = kdis_rows$SubCompart[i],
        Species    = kdis_rows$Species[i],
        kdis       = kdis_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(kdis_rows)))
  )
  
  # kfrag rows
  kfrag_rows <- data %>%
    dplyr::filter(VarName == "kfrag") |>
    select(VarName, Waarde, SubCompart, Species)
  
  kfrag_list <- setNames(
    lapply(seq_len(nrow(kfrag_rows)), function(i) {
      list(
        SubCompart = kfrag_rows$SubCompart[i],
        Species    = kfrag_rows$Species[i],
        kfrag       = kfrag_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(kfrag_rows)))
  )
  
  # kdeg rows
  kdeg_rows <- data %>%
    dplyr::filter(VarName == "kdeg")
  
  if (all(is.na(kdeg_rows$SubCompart))) {
    kdeg_list <- setNames(
      lapply(seq_len(nrow(kdeg_rows)), function(i) {
        list(
          Compartment = kdeg_rows$Compartment[i],
          kdeg        = kdeg_rows$Waarde[i]
        )
      }),
      as.character(seq_len(nrow(kdeg_rows)))
    )
  } else {
    
    # kdeg_rows <- kdeg_rows |>
    #   mutate(Compartment = case_when(
    #     SubCompart == "air" ~ "air",
    #     SubCompart %in% c("river", "lake", "sea", "deepocean") ~ "water",
    #     SubCompart %in% c("agriculturalsoil", "naturalsoil", "othersoil") ~ "soil",
    #     SubCompart %in% c("freshwatersediment", "lakesediment", "marinesediment") ~  "sediment"
    #   )) |>
    #   group_by(Compartment) |>
    #   summarise(Waarde = unique(Waarde))
    # 
    # kdeg_list <- setNames(
    #   lapply(seq_len(nrow(kdeg_rows)), function(i) {
    #     list(
    #       Compartment = kdeg_rows$Compartment[i],
    #       kdeg        = kdeg_rows$Waarde[i]
    #     )
    #   }),
    #   as.character(seq_len(nrow(kdeg_rows)))
    # )
    # The code below works, but the implementation of kdeg values per subcompart/species combination does not work right now. 
    
    kdeg_list <- setNames(
      lapply(seq_len(nrow(kdeg_rows)), function(i) {
        list(
          SubCompart = kdeg_rows$SubCompart[i],
          Species    = kdeg_rows$Species[i],
          kdeg        = kdeg_rows$Waarde[i]
        )
      }),
      as.character(seq_len(nrow(kdeg_rows)))
    )
  }
  
  # EF rows
  EF_rows <- data %>%
    dplyr::filter(VarName == "EF")
  
  EF_list <- setNames(
    lapply(seq_len(nrow(EF_rows)), function(i) {
      list(
        Compartment = EF_rows$Compartment[i],
        EF          = EF_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(EF_rows)))
  )
  
  # 3. Build substance list
  substance_list <- list(
    name       = substance_row$Substance,
    SBmode     = "Particulate",
    ChemClass  = substance_row$ChemClass,
    pKa        = substance_row$pKa,
    MW         = substance_row$MW,
    Tm         = substance_row$Tm,
    Pvap25     = substance_row$Pvap25,
    Sol25      = substance_row$Sol25,
    Kaw25      = substance_row$Kaw25,
    Kow        = substance_row$Kow,
    Ksw        = substance_row$Ksw,
    Kp.col     = substance_row$Kp.col,
    Kp.susp    = substance_row$Kp.susp,
    Kp.sed     = substance_row$Kp.sed,
    Kp.soil    = substance_row$Kp.soil,
    RadS       = substance_row$RadS,
    RhoS       = substance_row$RhoS,
    `hamakerSP.w` = substance_row$hamakerSP.w,
    Koc        = substance_row$Koc,
    KocAlt     = substance_row$KocAlt,
    MinSettVel = substance_row$MinSettVel,
    DegApproach= degapproach,
    Kssdr      = kssdr,
    # Shortest_side = Shortest_side,
    # Intermediate_side = Intermediate_side,
    # Longest_side = Longest_side,
    # Shape      = shape,
    
    Shortest_side = substance_row$Shortest_side,
    Intermediate_side = substance_row$Intermediate_side,
    Longest_side = substance_row$Longest_side,
    Shape      = substance_row$Shape,
    
    VelInput   = velinput,
    alpha      = alpha_list,
    kdeag      = kdeag_list,
    kdis       = kdis_list,
    kfrag      = kfrag_list,
    kdeg       = kdeg_list,
    EF         = EF_list
  )
  
  out <- list(
    CONST     = list(BACTtest = bact_test_value),
    Substance = substance_list
  )
  
  jsonlite::toJSON(out, auto_unbox = TRUE, pretty = TRUE, na = "null")
}

molecular_substance_to_json <- function(data, bact_test_value = 40000) {
  bact_test_value = as.numeric(bact_test_value)
  
  substance_row <- data %>%
    dplyr::filter(is.na(VarName)) %>%
    dplyr::slice(1)
  
  # 2. kdeg-rijen
  kdeg_rows <- data %>%
    dplyr::filter(VarName == "kdeg")
  
  kdeg_list <- setNames(
    lapply(seq_len(nrow(kdeg_rows)), function(i) {
      list(
        Compartment = kdeg_rows$Compartment[i],
        kdeg        = kdeg_rows$Waarde[i]
      )
    }),
    as.character(seq_len(nrow(kdeg_rows)))
  )
  
  # 3. Bouw Substance-lijst
  substance_list <- list(
    name       = substance_row$Substance,
    SBmode     = "Molecular",
    ChemClass  = substance_row$ChemClass,
    pKa        = substance_row$pKa,
    MW         = substance_row$MW,
    Tm         = substance_row$Tm,
    Pvap25     = substance_row$Pvap25,
    Sol25      = substance_row$Sol25,
    Kaw25      = substance_row$Kaw25,
    Kow        = substance_row$Kow,
    Ksw        = substance_row$Ksw,
    Kp.col     = substance_row$Kp.col,
    Kp.susp    = substance_row$Kp.susp,
    Kp.sed     = substance_row$Kp.sed,
    Kp.soil    = substance_row$Kp.soil,
    RadS       = substance_row$RadS,
    RhoS       = substance_row$RhoS,
    `hamakerSP.w` = substance_row$hamakerSP.w,
    Koc        = substance_row$Koc,
    KocAlt     = substance_row$KocAlt,
    kdeg       = kdeg_list
  )
  
  out <- list(
    CONST     = list(BACTtest = bact_test_value),
    Substance = substance_list
  )
  
  jsonlite::toJSON(out, auto_unbox = TRUE, pretty = TRUE, na = "null")
}

csv_to_json <- function(
    substance_name  = "default substance",
    data_path       = "data",
    type            = "molecule" # Options are: molecule, particle or microplastic
) {
  substance_csvs <- grep("Substance.*\\.csv$", list.files(data_path), value = TRUE)
  
  data <- data.frame()
  
  for (file in substance_csvs) {
    substance_data <- read.csv(file.path(data_path, file)) %>%
      filter(Substance == substance_name)
    
    data <- bind_rows(data, substance_data)
  }
  
  if (nrow(data) == 0) {
    stop("Geen data gevonden voor substance_name = ", substance_name)
  }

  bact_test_value = read.csv(file.path(data_path, "CONSTANTS.csv")) |>
    filter(VarName == "BACTtest") |>
    pull(Waarde)
  
  # Make json string  
  if(type == "molecule"){
    json_str <- molecular_substance_to_json(data, bact_test_value = bact_test_value)
  } else if(type == "particle"){
    json_str <- particulate_substance_to_json(data, bact_test_value = bact_test_value)
  } 
  # else if(type == "microplastic"){
  #   json_str <- nanoparticle_substance_to_json(data, bact_test_value = bact_test_value)
  # }
  # 
  # map voor output
  out_dir <- file.path(data_path, "custom_jsons")
  
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }
  
  safe_name <- gsub("\\s+", "_", substance_name)
  file_out  <- file.path(out_dir, paste0("substance_data_", safe_name, ".json"))
  
  writeLines(json_str, file_out)
  
  invisible(json_str)
}

# Aanroep:
csv_to_json(substance_name  = "microplastic", 
            data_path = "data", 
            type = "particle" ) 
