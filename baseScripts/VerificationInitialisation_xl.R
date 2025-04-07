### Verification of diagonal

Potential_substances <- c(
  "1-aminoanthraquinone", # no class
  "1-HYDROXYANTHRAQUINONE", # acid
  "1-Hexadecanamine, N,N-dimethyl-", # base
  "1-Chloro-2-nitro-propane", # neutral
  "Sb(III)" # metal
)

substance <- Potential_substances[2]

source("baseScripts/initWorld_onlyMolec.R")

LatestVersionKaas <- World$kaas

World$SetConst(Test = "TRUE")
World$UpdateKaas(mergeExisting = FALSE)

TestVersionKaas <- World$kaas

SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SBExcel_verification_", substance, ".xlsm")

SBexcel.K <- read.xlsx(SBExcelName,
                       colNames = FALSE,
                       namedRegion = "K"
)
SBexcel.Names <- read.xlsx(SBExcelName,
                           colNames = FALSE,
                           namedRegion = "box_names"
)

colnames(SBexcel.K) <- SBexcel.Names
SBexcel.K$to <- as.character(SBexcel.Names)

SBexcel.K <- pivot_longer(SBexcel.K, cols = as.character(SBexcel.Names), values_to = "k", names_to = "from")

# adding "from" and "to" acronyms to the R K matrix
kaas <- as_tibble(World$kaas)
World$FromDataAndTo()
# R version does not us the acronyms of the excel version, set-up to convert them
# Note: this map creates the wrong acronym for soil and sediment at global scale, this is fixed afterwards
accronym_map <- c(
  "marinesediment" = "sd2",
  "freshwatersediment" = "sd1",
  "lakesediment" = "sd0",
  "agriculturalsoil" = "s2",
  "naturalsoil" = "s1",
  "othersoil" = "s3",
  "air" = "a",
  "deepocean" = "w3",
  "sea" = "w2",
  "river" = "w1",
  "lake" = "w0"
)

accronym_map2 <- c(
  "Arctic" = "A",
  "Moderate" = "M",
  "Tropic" = "T",
  "Continental" = "C",
  "Regional" = "R"
)

kaas <- kaas |> mutate(
  from = paste0(
    accronym_map[fromSubCompart],
    accronym_map2[fromScale]
  ),
  to = paste0(
    accronym_map[toSubCompart],
    accronym_map2[toScale]
  )
)

# Issue that compartments sediment and soil at global scale in excel have sd and s as acronyms instead of sd2 and s1
kaas <-
  kaas |>
  mutate(
    from =
      ifelse((fromScale == "Tropic" | fromScale == "Arctic" | fromScale == "Moderate") &
               (fromSubCompart == "marinesediment" | fromSubCompart == "naturalsoil"),
             str_replace_all(from, c("sd2" = "sd", "s1" = "s")),
             from)
  ) |>
  mutate(to = ifelse((toScale == "Tropic" | toScale == "Arctic" | toScale == "Moderate") &
                       (toSubCompart == "marinesediment" | toSubCompart == "naturalsoil"), 
                     str_replace_all(to, c("sd2" = "sd", "s1" = "s")), 
                     to)
  )

kaas2 <- kaas |>
  filter(from != to) |> # filtering the diagonals ou
  group_by(from, to) %>%
  summarize(k = sum(k)) # R version sometimes has multiple k's per fromto box; excel only has the summed k's per box

kaas2$fromto <- paste(sep = "_", kaas2$from, kaas2$to)

diagonal_excel <- SBexcel.K[SBexcel.K$from == SBexcel.K$to, ] # all the diagonals in excel are negative values -> sums of all the "froms" of that compartment

diagonal_R <-
  aggregate(k ~ from, data = kaas, FUN = sum) # R model has k values per process, not per box. For the "diagonal" ("from = to") boxes, this is different than in the excel version. summing all the "froms" here to be able to compare them with excel matrix. This should result in one value for each compartment (scale-subcomp-species combo)

######### Some tests
dims <- dim(diagonal_R)

# Check if the matrix is 155x155
is_155x155 <- all(dims == c(35, 2))

# If the matrix is not 155x155, stop the execution
if (!is_155x155) {
  warning("The matrix does not have 155 rows. Execution stopped.")
}

# Continue with the rest of the code if the matrix is 155x155
matrix_info <- list(dimensions = dims, is_155x155 = is_155x155)


## check if all processes included
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
Functions <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Molecular)]
Functions <- paste0("k_", Functions)
Functions[!Functions %in% unique(World$kaas$process)]
world_processes <- unique(World$kaas$process)

# Check if Functions and unique world_processes match exactly
if (!setequal(Functions, world_processes)) {
  # Find elements in world_processes not in Functions
  missing_from_functions <- world_processes[!world_processes %in% Functions]
  
  # Find elements in Functions not in world_processes
  extra_in_functions <- Functions[!Functions %in% world_processes]
  
  # Print the mismatched elements
  cat("The following process names are missing from Functions:\n")
  print(missing_from_functions)
  cat("The following process names are extra in Functions:\n")
  print(extra_in_functions)
  
  # Stop the script
  stop("Mismatch found between Functions and unique(World$kaas$process).")
}


# Single dataframe with both the R and excel diagonals
merged_diagonal <- merge(diagonal_R, diagonal_excel, by = "from", suffixes = c("_R", "_Excel"))
merged_diagonal$k_Excel <- -merged_diagonal$k_Excel # Turning the "negative" values from the Excel matrix into positive ones
merged_diagonal$diff <- merged_diagonal$k_R - merged_diagonal$k_Excel
merged_diagonal$reldif <- merged_diagonal$diff / merged_diagonal$k_R

SBexcel.K <- filter(SBexcel.K, k != 0 & SBexcel.K$from != SBexcel.K$to)
SBexcel.K$fromto <- paste(sep = "_", SBexcel.K$from, SBexcel.K$to)

mergedkaas <- merge(kaas2, SBexcel.K, by = c("from", "to"), suffixes = c("_R", "_Excel"))

mergedkaas$diff <- mergedkaas$k_R - mergedkaas$k_Excel # compare R k to Excel K

mergedkaas <- as_tibble(mergedkaas) |> mutate(relDif = diff / k_R)



custom_theme <- function() {
  theme(
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    plot.margin = margin(t = 10, r = 10, b = 30, l = 10) # ,
    # panel.background = element_rect(fill = "white", colour = "grey"),   # White background
    # panel.grid.major = element_line(colour = "grey")#,                   # Black major grid lines
    # panel.grid.minor = element_line(colour = "black")                    # Black minor grid lines
  )
}

anti_join(LatestVersionKaas, TestVersionKaas,
          by = join_by(process, fromScale, fromSubCompart, fromSpecies, toScale, toSubCompart, toSpecies))

LatestVersionKaas |> filter(fromSubCompart == "lake")
TestVersionKaas |> filter(fromSubCompart == "lake")

LatestVersionKaas |> filter(fromSubCompart == "lakesediment")
TestVersionKaas |> filter(fromSubCompart == "lakesediment")
