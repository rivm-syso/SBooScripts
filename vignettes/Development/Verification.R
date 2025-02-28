substance <- "1-HYDROXYANTHRAQUINONE"
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

############################# Initialize World #################################

# Initialize World
substances <- read.csv("data/Substances.csv")

chemclass <- substances |>
  filter(Substance == substance) |>
  select(ChemClass)

chemclass <- chemclass$ChemClass

if(substance == "microplastic"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if (chemclass == "particle") {
  source("baseScripts/initWorld_onlyParticulate.R")
} else {
  source("baseScripts/initWorld_onlyMolec.R")
}

World$substance <- substance

World$SetConst(Test = test_value)
World$UpdateKaas(mergeExisting = FALSE)

############################### Compare k's  ###################################

# Get kaas from Excel
SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SBExcel_verification_", substance,".xlsm")

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

# Get kaas from World
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


# Get the diagonal k's (removal processes) from Excel k's dataframe
diagonal_excel <- SBexcel.K[SBexcel.K$from == SBexcel.K$to,] 

#filter out dissolved and gas processes
filtered_excel <- diagonal_excel[!endsWith(diagonal_excel$from, "D"), ]
filtered_excel <- filtered_excel[!endsWith(filtered_excel$from, "G"), ]

# Get the From - To kaas from R
kaas2 <- kaas |>  
  filter(from != to) |> #filtering the diagonals out
  group_by(from, to) %>% summarize(k = sum(k)) |>
  mutate(fromto = paste(sep="_", from, to))

# Merge Form - To kaas
SBexcel.K <- filter(SBexcel.K, k != 0 & SBexcel.K$from != SBexcel.K$to)
SBexcel.K$fromto <- paste(sep = "_", SBexcel.K$from, SBexcel.K$to)

from_to_kaas <- merge(kaas2, SBexcel.K, by = c("from", "to"), suffixes = c("_R", "_Excel"))

from_to_kaas$diff <- from_to_kaas$k_R - from_to_kaas$k_Excel #compare R k to Excel K

from_to_kaas <- as_tibble(from_to_kaas) |> mutate(reldif = diff/k_R) |> select(-fromto_R) |> select(-fromto_Excel)

# Filter out the diagonal k's
# filtered_R <- aggregate(k ~ from, data = kaas, FUN = sum) 
filtered_R <- kaas |>
  group_by(from) |>
  summarise(k = sum(k))

# Merge the diagonal k's
merged_diagonal <- merge(filtered_R, filtered_excel, by = "from", suffixes = c("_R", "_Excel")) 
merged_diagonal$k_Excel <- -merged_diagonal$k_Excel #Turning the "negative" values from the Excel matrix into positive ones
merged_diagonal$diff <- merged_diagonal$k_R - merged_diagonal$k_Excel 
diagonal_kaas <- merged_diagonal[order(abs(merged_diagonal$diff), decreasing = TRUE), ] |>
  mutate(reldif  = abs(diff/k_R))

#### Plot k's
# From - To
plot <- ggplot(from_to_kaas, aes(x = to, y = from)) + 
  geom_point(aes(color = abs(reldif) < 0.001)) +  # Logical condition for color
  scale_color_manual(values = c("TRUE" = "green", "FALSE" = "red")) +  # Set manual colors
  ggtitle(paste0(substance)) +
  labs(color = "Relative difference < 0.001") +
  theme(
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12), 
    plot.margin = margin(t = 10, r = 10, b = 30, l = 10)
  ) +
  custom_theme()

print(plot)

# Diagonal
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

print(plot)

#### Merge masses
World$NewSolver("SteadyODE")

if(World$fetchData("ChemClass") == "particle"){
  emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10000, 10000, 10000) ) # convert 1 t/y to si units: kg/s
  emissions <- emissions |>
    mutate(Emis = Emis*1000/(365*24*60*60))
} else {
  emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) # convert 1 t/y to si units: kg/s
  MW <- World$fetchData("MW")
  emissions <- emissions |>
    mutate(Emis = Emis*1000/(MW*365*24*60*60))
}

World$Solve(emissions)

SSsolve.R <- World$Solution() |>
  select(Abbr, Mass_kg) |>
  left_join(World$states$asDataFrame, by = "Abbr")

if(World$fetchData("ChemClass") == "particle"){
  SSsolve.excel <- read.xlsx(SBExcelName,
                             sheet="engine",
                             colNames=TRUE,
                             rows=c(167,169))
  SSsolve.excel <- SSsolve.excel |>
    select(-STEADY.STATE) |>
    pivot_longer(names_to = "Abbr", values_to = "Mass_kg", cols = everything()) |>
    filter(!str_ends(Abbr, "D"))
} else {
  SSsolve.excel <- read.xlsx(SBExcelName,
                             sheet="engine",
                             colNames=TRUE,
                             rows=c(44,45))
  SSsolve.excel <- SSsolve.excel |>
    select(-c(STEADY.STATE, X2)) |>
    pivot_longer(names_to = "Abbr", values_to = "Mass_kg", cols = everything()) |>
    mutate(Abbr = paste0(Abbr, "U"))
}

SSsolve.R <- SSsolve.R |> 
  mutate(Abbr =  paste0(accronym_map[SubCompart], 
                                                accronym_map2[Scale], accronym_map3[Species])) |>
  mutate(Abbr = ifelse((Scale == "Tropic" | Scale == "Arctic" | Scale == "Moderate") &
                    (SubCompart == "marinesediment" | SubCompart == "naturalsoil"),
                  str_replace_all(Abbr, c("sd2"="sd","s1"="s")),
                  Abbr)) |>
  group_by(Scale, SubCompart, Species, Abbr) |>
  summarise(Mass_kg = sum(Mass_kg))

if(World$fetchData("ChemClass") == "particle"){
  SSsolve.R <- SSsolve.R
} else {
  SSsolve.R <- SSsolve.R |>
    mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
    mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
    mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
    group_by(Scale, SubCompart, Species, Abbr) |>
    summarise(Mass_kg = sum(Mass_kg))
}

mergedmasses <- merge(SSsolve.R, SSsolve.excel, by="Abbr", suffixes = c(".R", ".Excel")) |>
  mutate(absdiff = Mass_kg.R-Mass_kg.Excel) |>
  mutate(reldiff = absdiff/Mass_kg.R)

#### Plot masses
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

print(plot)