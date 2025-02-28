################################# Functions ####################################

CompareKs <- function(substance) {
  initializeWorld(substance)
  SBexcel.K <- GetExcelKaas(substance)
  kaas <- GetRKaas()
  filtered_excel <- GetDiagonalExcel(SBexcel.K)
  kaas2 <- GetFromToKaasR(kaas)
  filtered_R <- GetDiagonalR(kaas)
  diagonal_kaas <- MergeDiagonalExcelR(filtered_R, filtered_excel)
  from_to_kaas <- MergeFromToExcelR(kaas2, SBexcel.K)

  resultlist <- list(
    diagonal_kaas = diagonal_kaas,
    from_to_kaas = from_to_kaas
  )
  
  return(resultlist)
}

PlotFromToKs <- function(){
 PlotFromToKsFun(MergedKs$from_to_kaas)
}

PlotDiagonalKs <- function(){
  PlotDiagonalFun(MergedKs$diagonal_kaas)
}

PlotMasses <- function(){
  mergedmasses <- MergeMasses()
  PlotMassesFun(mergedmasses)
}

PlotConcentrations <- function() {
  
}

################################# Helper functions #############################

# Function for initializing the World
initializeWorld <- function(chosen_substance){
  substances <- read.csv("data/Substances.csv")
  
  chemclass <- substances |>
    filter(Substance == chosen_substance) |>
    select(ChemClass)
  
  chemclass <- chemclass$ChemClass
  
  if(chosen_substance == "microplastic"){
    source("baseScripts/initWorld_onlyPlastics.R")
  } else if (chemclass == "particle") {
    source("baseScripts/initWorld_onlyParticulate.R")
  } else {
    source("baseScripts/initWorld_onlyMolec.R")
  }
  
  World$substance <- chosen_substance
}

# Function to get the k's from an Excel file using the filename
GetExcelKaas <- function(chosen_substance){
  
  SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SBExcel_verification_", chosen_substance,".xlsm")
  
  SBexcel.K <- read.xlsx(SBExcelName,
                         colNames = FALSE,
                         namedRegion = "K")
  SBexcel.Names <- read.xlsx(SBExcelName,
                             colNames = FALSE,
                             namedRegion = "box_names")
  
  colnames(SBexcel.K) <- SBexcel.Names
  
  SBexcel.K$to <-  as.character(SBexcel.Names)
  
  SBexcel.K <- pivot_longer(SBexcel.K, cols =  as.character(SBexcel.Names), values_to = "k", names_to = "from")
  
  if(World$fetchData("ChemClass") != "particle"){
    SBexcel.K <- SBexcel.K |>
      mutate(from = paste0(from, "U")) |>
      mutate(to = paste0(to, "U"))
  } else {
    SBexcel.K <- SBexcel.K
  }
}

# Function to get k's from the World object and attach the correct abbreviations
GetRKaas <- function(){
  #adding "from" and "to" acronyms to the R K matrix
  kaas <- as_tibble(World$kaas) 
  
  kaas <- kaas |> mutate(from =  paste0(accronym_map[fromSubCompart], 
                                        accronym_map2[fromScale], 
                                        accronym_map3[fromSpecies]),
                         to = paste0(accronym_map[toSubCompart], 
                                     accronym_map2[toScale], 
                                     accronym_map3[toSpecies]))
  
  kaas <-
    kaas |>
    mutate(from =
             ifelse((fromScale == "Tropic" | fromScale == "Arctic" | fromScale == "Moderate") &
                      (fromSubCompart == "marinesediment" | fromSubCompart == "naturalsoil"),
                    str_replace_all(from, c("sd2"="sd","s1"="s")),
                    from)) |>
    mutate(to = ifelse((toScale == "Tropic" | toScale == "Arctic" | toScale == "Moderate") &
                         (toSubCompart == "marinesediment" | toSubCompart == "naturalsoil"), str_replace_all(to, c("sd2"="sd","s1"="s")), to))
}

# Function to get the diagonal k's (removal processes) from Excel k's dataframe
GetDiagonalExcel <- function(SBexcel.K){
  diagonal_excel <- SBexcel.K[SBexcel.K$from == SBexcel.K$to,] 
  
  #filter out dissolved and gas processes
  filtered_excel <- diagonal_excel[!endsWith(diagonal_excel$from, "D"), ]
  filtered_excel <- filtered_excel[!endsWith(filtered_excel$from, "G"), ]
}

# Function to get the R k's without the removal processes
GetFromToKaasR <- function(kaas){
  kaas2 <- kaas |>  
    filter(from != to) |> #filtering the diagonals out
    group_by(from, to) %>% summarize(k = sum(k)) |>
    mutate(fromto = paste(sep="_", from, to))
}

# Function to sum all k's in R that have the same from and to abbreviation
GetDiagonalR <- function(kaas){
  filtered_R <- aggregate(k ~ from, data = kaas, FUN = sum) 
  filtered_R <- kaas |>
    group_by(from) |>
    summarise(k = sum(k))
}

#filtered_R <- filtered_R[!endsWith(filtered_R$from, "U"), ]

# Function to make one dataframe containing the k's for removal processes from Excel and R, and calculate the absolute and relative differences
MergeDiagonalExcelR <- function(filtered_R, filtered_excel){
  merged_diagonal <- merge(filtered_R, filtered_excel, by = "from", suffixes = c("_R", "_Excel")) 
  merged_diagonal$k_Excel <- -merged_diagonal$k_Excel #Turning the "negative" values from the Excel matrix into positive ones
  merged_diagonal$diff <- merged_diagonal$k_R - merged_diagonal$k_Excel 
  sorted_diff <- merged_diagonal[order(abs(merged_diagonal$diff), decreasing = TRUE), ] |>
    mutate(reldif  = abs(diff/k_R))
}

# Function to make one dataframe containing the k's for non-removal processes and calculate the absolute and relative differences
MergeFromToExcelR <- function(kaas2, SBexcel.K){
  SBexcel.K <- filter(SBexcel.K, k != 0 & SBexcel.K$from != SBexcel.K$to)
  SBexcel.K$fromto <- paste(sep = "_", SBexcel.K$from, SBexcel.K$to)
  
  mergedkaas <- merge(kaas2, SBexcel.K, by = c("from", "to"), suffixes = c("_R", "_Excel"))
  
  mergedkaas$diff <- mergedkaas$k_R - mergedkaas$k_Excel #compare R k to Excel K
  
  mergedkaas <- as_tibble(mergedkaas) |> mutate(reldif = diff/k_R) |> select(-fromto_R) |> select(-fromto_Excel)
}

MergeMasses <- function(){
  SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SBExcel_verification_", substance,".xlsm")
  
  World$NewSolver("SteadyODE")
  emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) # convert 1 t/y to si units: kg/s
  
  MW <- World$fetchData("MW")
  
  emissions <- emissions |>
    mutate(Emis = Emis*1000/(MW*365*24*60*60))
  
  World$Solve(emissions)
  
  SSsolve.R <- World$Solution() |>
    select(Abbr, Mass_kg) |>
    left_join(World$states$asDataFrame, by = "Abbr")
  
  SSsolve.excel <- read.xlsx(SBExcelName,
                             sheet=11,
                             colNames=TRUE,
                             rows=c(44,45))
  
  SSsolve.excel <- SSsolve.excel |>
    select(-c(STEADY.STATE, X2)) |>
    pivot_longer(names_to = "Abbr", values_to = "Mass_kg", cols = everything()) 
  
  SSsolve.R <- SSsolve.R |> mutate(Abbr =  paste0(accronym_map[SubCompart], 
                                                  accronym_map2[Scale])) |>
    mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
    mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
    mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
    group_by(Scale, SubCompart, Species, Abbr) |>
    summarise(Mass_kg = sum(Mass_kg))
  
  mergedmasses <- merge(SSsolve.R, SSsolve.excel, by="Abbr", suffixes = c(".R", ".Excel")) |>
    mutate(absdiff = Mass_kg.R-Mass_kg.Excel) |>
    mutate(reldiff = absdiff/Mass_kg.R)
  
  return(mergedmasses)
}
  
# Function that converts Excel acronyms to R acronyms for sediment and soil at global scale
MatchAbbrsExcel <- function(df){
  df <- df |>
    mutate(Abbr = case_when(
      Abbr == "sdM" ~ "sd2M",
      Abbr == "sdT" ~ "sd2T",
      Abbr == "sdA" ~ "sd2A",
      Abbr == "sM" ~ "s1M",
      Abbr == "sT" ~ "s1T",
      Abbr == "sA" ~ "s1A",
      TRUE ~ Abbr
    )) 
}

MatchAbbrsR <- function(df){
  df <- df |>
    mutate(Abbr =  paste0(accronym_map[SubCompart], 
                              accronym_map2[Scale])) |>
    mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
    mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
    mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
    mutate(Abbr = str_replace(Abbr, "cw", "a")) 
}

MergeConcentrations <- function(){
  SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SBExcel_verification_", substance,".xlsm")
  
  World$NewSolver("SteadyODE")
  emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) # convert 1 t/y to si units: kg/s
  
  MW <- World$fetchData("MW")
  
  emissions <- emissions |>
    mutate(Emis = Emis*1000/(MW*365*24*60*60))
  
  World$Solve(emissions)
  
  Volume.excel <- read.xlsx(SBExcelName,
                            sheet=11,
                            colNames=TRUE,
                            rows=c(3,4)) |>
    select(-c(X1, X2)) |>
    pivot_longer(names_to = "Abbr", values_to = "Volume.excel", cols = everything())
  
  Volume.excel <- MatchAbbrsExcel(Volume.excel)

  Volume.R <- MatchAbbrsR(World$fetchData("Volume")) |>
    group_by(Abbr) |>
    summarise(Volume = sum(Volume)) |>
    rename(Volume.R = Volume)
  
  merged_volume <- Volume.R |>
    full_join(Volume.excel, by = "Abbr") |>
    mutate(diff = Volume.excel-Volume.R) 
  
  
  

  Concentration.R <- World$Solution() |>
    select(Abbr, Mass_kg) |>
    mutate(Abbr = substr(Abbr, 1, nchar(Abbr) - 1)) |>
    left_join(World$states$asDataFrame, by = "Abbr") |>
    left_join(Volume.R, by = c("Abbr")) |>
    mutate(Concentration = Mass_kg/Volume.R) 

  Concentration.excel <- read.xlsx(SBExcelName,
                             sheet=11,
                             colNames=TRUE,
                             rows=c(44,49))
  
  Concentration.excel <- Concentration.excel |>
    select(-c(STEADY.STATE, X2)) |>
    pivot_longer(names_to = "Abbr", values_to = "Concentration", cols = everything()) 

  Concentration.R <- Concentration.R |> mutate(Abbr =  paste0(accronym_map[SubCompart], 
                                                  accronym_map2[Scale])) |>
    mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
    mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
    mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
    group_by(Scale, SubCompart, Species, Abbr) |>
    summarise(Concentration = sum(Concentration))
  
  mergedconcentrations <- merge(Concentration.R, Concentration.excel, by="Abbr", suffixes = c(".R", ".Excel")) |>
    mutate(absdiff = Concentration.R-Concentration.Excel) |>
    mutate(reldiff = absdiff/Concentration.R)
}

PlotDiagonalFun <- function(diagonal_kaas){
  plot <- ggplot(diagonal_kaas, aes(x = from, y = reldif)) +
    geom_boxplot() +
    ggtitle(paste0(substance)) +
    geom_hline(yintercept = 0.001, color = "red") +
    geom_hline(yintercept = -0.001, color = "red") +
    custom_theme()+
    labs(title = "Relative difference between diagonal k's in SBExcel and SBOO",
         subtitle = substance,
         x = "from", 
         y = "Relative difference") + 
    theme_bw() +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(plot)
}

PlotMassesFun <- function(mergedmasses){
  # Relative difference between SS masses in R and Excel for each compartment
  plot <- ggplot(mergedmasses, aes (x = Abbr, y = reldiff)) +
    geom_boxplot() +
    ggtitle(paste0( substance)) +
    geom_hline(yintercept = 0.001, color="red") +
    geom_hline(yintercept = -0.001, color="red") +
    custom_theme() + 
    labs(title = "Relative difference between masses in SBExcel and SBOO",
         subtitle = substance,
         x = "Abbreviation",
         y = "Relative difference") + 
    theme_bw() +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(plot)
}

PlotFromToKsFun <- function(from_to_kaas){
  plot <- ggplot(from_to_kaas, aes(x = to, y = from, color = abs(reldif))) + 
    geom_point() +
    scale_color_gradient(low = "green", high = "red") +
    ggtitle(paste0( substance)) +
    theme(
      axis.text.y = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 12), 
      plot.margin = margin(t = 10, r = 10, b = 30, l = 10))
  
  return(plot)
}

################################### Variables ##################################

#R version does not us the acronyms of the excel version, set-up to convert them
#Note: this map creates the wrong acronym for soil and sediment at global scale, this is fixed afterwards
accronym_map <- c("marinesediment" = "sd2",
                  "freshwatersediment" = "sd1",
                  "lakesediment" = "sd0", #SB Excel does not have this compartment. To do: can we turn this off (exclude this compartment) for testing?
                  "agriculturalsoil" = "s2",
                  "naturalsoil" = "s1",
                  "othersoil" = "s3",
                  "air" = "a",
                  "deepocean" = "w3",
                  "sea" = "w2",
                  "river" = "w1",
                  "lake" = "w0", 
                  "cloudwater" = "cw")

accronym_map2 <- c("Arctic" = "A",
                   "Moderate" = "M",
                   "Tropic" = "T",
                   "Continental" = "C",
                   "Regional" = "R")

accronym_map3 <- c("Dissolved" = "D", 
                   "Gas" = "G", 
                   "Large" = "P", 
                   "Small" = "A",
                   "Solid" = "S", 
                   "Unbound" = "U")

custom_theme <- function() {
  theme(
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12), 
    plot.margin = margin(t = 10, r = 10, b = 30, l = 10)
  )
} 
























