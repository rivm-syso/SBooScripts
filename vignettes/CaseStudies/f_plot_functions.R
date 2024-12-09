
prep_LEONT_data <- function(abs_file_path){
  LEONT_data <- read_excel(abs_file_path)
  
  LEONT_data2 <- LEONT_data |>
    mutate(SubCompart = case_when(
      str_detect(Beschrijving, "350mtr") ~ "agriculturalsoil",
      Medium == "lucht" ~ "air",
      Medium == "water" ~ "river",
      Medium == "sediment" ~ "freshwatersediment",
      Medium == "soil" ~ "othersoil",
      TRUE ~ NA
    )) |>
    mutate(Unit = case_when(
      SubCompart == "air" ~ "µg/m^3",
      Unit == "mg/g" ~ "mg/g dw",
      TRUE ~ Unit)) |>
    mutate(SubCompartName = paste0(SubCompart, " (", Unit, ")")) |>
    select(Locatie, TWP_AVG, Unit, SubCompart, SubCompartName) |>
    rename("Concentration" = "TWP_AVG") |>
    mutate(Polymer = "SBR + NR") |>
    mutate(source = "LEON-T measurement") |>
    mutate(RUN = NA) |>
    mutate(Concentration = str_replace(Concentration, ",", ".")) |>
    mutate(Concentration = as.numeric(Concentration))
}

plot_variable <- function(Material_parameters_df, PlotVariable){

  params <- Material_parameters_df |>
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