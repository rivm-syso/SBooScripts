
prep_LEONT_data <- function(abs_file_path){
  LEONT_data <- read_excel(abs_file_path)
  
  LEONT_data2 <- LEONT_data |>
    select(Medium, Locatie, `TWP (TNO)`, Beschrijving, `TWP (SBR+NR)`, `TWP (AVG)...9`, SBR, NR, eenheid...12) |>
    mutate(SubCompart = case_when(
      str_detect(Beschrijving, "350mtr") ~ "agriculturalsoil",
      Medium == "lucht" ~ "air",
      Medium == "water" ~ "river",
      Medium == "sediment" ~ "freshwatersediment",
      Medium == "soil" ~ "othersoil",
      TRUE ~ NA
    )) |>
    filter(!Medium %in% c("runoff", "deposition")) |>
    mutate(Scale = "Regional") |>
    rename("eenheid" = "eenheid...12") |>
    rename("LEONT_SBR_NR" = `TWP (SBR+NR)`) |>
    mutate(LEONT_SBR_NR = as.numeric(LEONT_SBR_NR)) |>
    mutate(LEONT_SBR_NR_converted = case_when(
      eenheid == "µg/m3" ~ LEONT_SBR_NR/1000,
      eenheid == "mg/g" ~ LEONT_SBR_NR,
      TRUE ~ NA
    )) |>
    mutate(Unit = case_when(
      eenheid == "µg/m3" ~ " (g/m^3)",
      (eenheid == "mg/g" & SubCompart == "river") ~ " (g/L)",
      (eenheid == "mg/g" & SubCompart != "river") ~ " (g/kg dw)",
      TRUE ~ NA
    )) |>
    mutate(SBR = as.numeric(SBR)) |>
    mutate(LEONT_SBR_converted = case_when(
      eenheid == "µg/m3" ~ SBR/1000,
      eenheid == "mg/g" ~ SBR,
      TRUE ~ NA
    )) |>
    mutate(NR = as.numeric(NR)) |>
    mutate(LEONT_NR_converted = case_when(
      eenheid == "µg/m3" ~ NR/1000,
      eenheid == "mg/g" ~ NR,
      TRUE ~ NA
    )) |>
    mutate(SubCompartName = paste0(SubCompart, Unit)) |>
    mutate(source = "Measurement") 
  
  # Optional: add SBR and NR concentrations separately
  
  LEONT_TWP_data <- LEONT_data2 |>
    select(LEONT_SBR_NR_converted, Unit, SubCompart, SubCompartName) |>
    rename("Concentration" = "LEONT_SBR_NR_converted") |>
    mutate(Polymer = "SBR + NR") |>
    mutate(source = "LEONT measurement") |>
    filter(!is.na(Concentration))
  
}

plot_variable <- function(Material_parameters_df, PlotVariable){

  params <- Material_Parameters_long |>
    filter(VarName == PlotVariable)
  
  if(PlotVariable %in% c("kfrag", "kdeg", "alpha")){
    params <- params |>
      filter(SubCompart %in% c("freshwatersediment", "naturalsoil", "sea")) |>
      mutate(SubCompart = case_when(
        SubCompart == "freshwatersediment" ~ "sediment",
        SubCompart == "sea" ~ "water",
        SubCompart == "naturalsoil" ~ "soil"
      ))
  }
  
  plot <- ggplot(params, aes(x=value,y=SubCompart)) +
    geom_violin()+
    facet_wrap(vars(Polymer, Species))+
    xlab(PlotVariable)
}