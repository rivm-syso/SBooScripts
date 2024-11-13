
prep_TNO_data <- function(abs_file_path){
  TNO_data <- read_excel(abs_file_path)
  
  TNO_data2 <- TNO_data |>
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
    rename("TNO_SBR_NR" = `TWP (SBR+NR)`) |>
    mutate(TNO_SBR_NR = as.numeric(TNO_SBR_NR)) |>
    mutate(TNO_SBR_NR_converted = case_when(
      eenheid == "µg/m3" ~ TNO_SBR_NR/1000,
      eenheid == "mg/g" ~ TNO_SBR_NR,
      TRUE ~ NA
    )) |>
    mutate(Unit = case_when(
      eenheid == "µg/m3" ~ " (g/m^3)",
      (eenheid == "mg/g" & SubCompart == "river") ~ " (g/L)",
      (eenheid == "mg/g" & SubCompart != "river") ~ " (g/kg dw)",
      TRUE ~ NA
    )) |>
    mutate(SBR = as.numeric(SBR)) |>
    mutate(TNO_SBR_converted = case_when(
      eenheid == "µg/m3" ~ SBR/1000,
      eenheid == "mg/g" ~ SBR,
      TRUE ~ NA
    )) |>
    mutate(NR = as.numeric(NR)) |>
    mutate(TNO_NR_converted = case_when(
      eenheid == "µg/m3" ~ NR/1000,
      eenheid == "mg/g" ~ NR,
      TRUE ~ NA
    )) |>
    mutate(SubCompartName = paste0(SubCompart, Unit)) |>
    mutate(source = "Measurement") 
  
  # Optional: add SBR and NR concentrations separately
  
  TNO_TWP_data <- TNO_data2 |>
    select(TNO_SBR_NR_converted, Unit, SubCompart, SubCompartName) |>
    rename("Concentration" = "TNO_SBR_NR_converted") |>
    mutate(Polymer = "SBR + NR") |>
    mutate(source = "TNO measurement") |>
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