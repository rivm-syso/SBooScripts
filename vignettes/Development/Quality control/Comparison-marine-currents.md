Comparison marine currents
================
Anne Hids, Joris Quik
2026-02-25

# Changes made

In the marine_currents_clean branch the following changes were made:

\- There is now a variable to remove the global scale:
**Remove_global**. Setting this variable to TRUE removes the advection
flows to, from and within the global scale.

\- As an alternative to calculating advection flows within SBoo, there
is an option to provide advection rates directly with the **AdvInput**
variable. If values for this variable are given, the advection flows are
not calculated for these flows.

\- When the **Regional_and_Continental_deepocean** variable is set to
TRUE, the deepocean subcompartment at Regional and Continental scale is
introduced. This means the following:

\- The deaggregation function is turned off for deepocean at Regional
and Continental scale. - The area for deepocean at Regional and
Continental scale is set to the area of the sea subcompartment at the
same scale.

\- The variable **VelInput** allows the user to provide a settling
velocity instead of the settling velocity being calculated in SBoo.

\## Comparisons setup

There are a few comparisons to be made to test these changes:

\- Compare marine_currents_clean with Remove_global = TRUE and
Regional_and_Continental_deepocean = TRUE to development branch

\- Compare marine_currents_clean with Remove_global = FALSE and
Regional_and_Continental_deepocean = FALSE to development.

\# Compare marine_currents_clean with new variables as TRUE to
development

The below scripts should be run to compare two versions of SBoo.

``` r
tag <- NA # Because we want to compare to current development, not to a release.
branch_sboo <- "marine_currents_clean"
branch_sbooscripts <- "marine_currents_clean"
```

## Define function for downloading and ordering the folders needed to compare

``` r
source("vignettes/Development/Quality control/ComparisonFunctions.R")
folderpaths <- CompareFilesPrep(Release = NA,
                             Test_SBoo = branch_sboo,
                             Test_SBooScripts = branch_sbooscripts,
                             Temp_Folder = dest_folder)
```

Select random substances for testing

``` r
excluded_substances <- c("Graphene Oxide", "Chitosan", "nTiO2_P25_CaLIBRAte_D6_3", "nAg_NanoFase", "nanoparticle", "GO-Chitosan")
# Select 5 random substances for each class from substances csv
substances <- read.csv("data/Substances.csv") |>
  filter(!Substance %in% excluded_substances)
mp <- substances |>
  filter(Substance == "microplastic")
set.seed(123)
substances <- substances |>
  group_by(ChemClass) |>
  slice_sample(n = 5, replace = FALSE) |>
  ungroup()
substances <- rbind(substances, mp) |>
  distinct()
substance_names <- substances$Substance
cc_substances <- substances |>
  select(Substance, ChemClass)
```

## Calculate first order rate constants for the development

``` r
# Save the original working directory for later
original_wd <- getwd()
# Change the wd to the wd of the development branches
setwd(paste0(folderpaths[1], "/SBooScripts"))
# Calculate the kaas
development_kaas <- data.frame()
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  source("baseScripts/initWorld.R")
  kaas <- World$kaas |>
    mutate(Substance = substance)
  development_kaas <- rbind(development_kaas, kaas)
}
```

## Calculate the first order rate constants for the test branches

``` r
# Change the wd to the wd of the development branches
setwd(paste0(folderpaths[2], "/SBooScripts"))
test_true_kaas <- data.frame()
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  source("baseScripts/initWorld.R")
  World$SetConst(Regional_and_Continental_deepocean = "TRUE") # Add deepocean to Regional and Continental scale
  World$SetConst(Remove_global = "TRUE") #if true, remove flows to moderate, arctic and tropic
  World$UpdateKaas(mergeExisting = FALSE)
  kaas <- World$kaas |>
    mutate(Substance = substance)
  test_true_kaas <- rbind(test_true_kaas, kaas)
}
```

## Compare the k values for each of the substances

``` r
common_cols <- setdiff(intersect(colnames(development_kaas), colnames(test_true_kaas)), "k")
kaas_comparison <- merge(development_kaas, test_true_kaas, by=common_cols, suffixes = c("_Old", "_New"))
kaas_comparison <- full_join(
  development_kaas,
  test_true_kaas,
  by = common_cols,
  suffix = c("_Old", "_New")
)
kaas_comparison <- kaas_comparison |>
  mutate(diff = k_New-k_Old) |> # If this number is positive, the New_k is higher than the Old_k (higher advection rate with new method)
  mutate(rel_diff = diff/k_New)
changed_kaas <- kaas_comparison |>
  filter(diff != 0) |>
  mutate(full_name = paste0("From ", fromSubCompart, "_", fromScale, " to ", toSubCompart, "_", toScale))
```

``` r
diffs <- kaas_comparison |>
  mutate(fromname = paste0(process, "_", fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(process, "_", toSubCompart, "_", toScale)) |>
  mutate(diff = ifelse(diff == 0, NaN, diff)) |>
  left_join(cc_substances, by = "Substance")
chemclass <- "metal"
for(chemclass in unique(diffs$ChemClass)){
  changed <- diffs |>
    filter(rel_diff != 0) |>
    filter(ChemClass == chemclass)
  mean_changed <- changed |>
  group_by(fromname, toname) |>
  summarise(diff = mean(diff),
            rel_diff = mean(rel_diff))
  diff_plot <- ggplot(mean_changed, mapping = aes(x = toname, y = fromname, color = diff)) +
  geom_point() +
  scale_color_gradient2(
    low = "blue",    # Colors for negative values
    mid = "grey",   # Neutral point at zero
    high = "red",  # Colors for positive values
    midpoint = 0,   # Center the scale at zero
    limits = c(-max(abs(changed$diff)), max(abs(changed$diff)))  # Ensure symmetric scale
  ) +
  labs(
    title = paste0("Mean difference between old and new k's for ", chemclass, " substances"),
    subtitle = "Only k's with a difference above or below zero are shown. Global scale removed.",
    x = "To",
    y = "From",
    color = "Difference"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()
  )
  print(diff_plot)
  rel_diff_plot <- ggplot(mean_changed, mapping = aes(x = toname, y = fromname, color = rel_diff)) +
  geom_point() +
  scale_color_gradient2(
    low = "blue",    # Colors for negative values
    mid = "grey",   # Neutral point at zero
    high = "red",  # Colors for positive values
    midpoint = 0,   # Center the scale at zero
    limits = c(-max(abs(changed$rel_diff)), max(abs(changed$rel_diff)))  # Ensure symmetric scale
  ) +
  labs(
    title = paste0("Mean relative difference between old and new k's for ", chemclass, " substances"),
    subtitle = "Only k's with a difference above or below zero are shown. Global scale removed.",
    x = "To",
    y = "From",
    color = "Difference"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()
  )
  print(rel_diff_plot)
  table_for_display <- changed |>
  select(fromScale, fromSubCompart, toScale, toSubCompart, Substance, k_Old, k_New, diff, rel_diff) |>
  mutate(diff = format(diff, scientific = TRUE, digits = 2)) |>
  mutate(rel_diff = format(rel_diff, scientific = TRUE, digits = 2))
  print(knitr::kable(table_for_display))
}
```

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-1.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-2.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart |toScale     |toSubCompart     |Substance                  |   k_Old|   k_New|diff     |rel_diff |
    ## |:-----------|:--------------|:-----------|:----------------|:--------------------------|-------:|-------:|:--------|:--------|
    ## |Arctic      |air            |Arctic      |naturalsoil      |diisopropyl ether          | 0.0e+00| 0.0e+00|8.0e-17  |5.0e-07  |
    ## |Arctic      |air            |Arctic      |sea              |diisopropyl ether          | 0.0e+00| 0.0e+00|1.2e-16  |5.0e-07  |
    ## |Continental |air            |Continental |agriculturalsoil |diisopropyl ether          | 0.0e+00| 0.0e+00|1.3e-16  |8.2e-07  |
    ## |Continental |air            |Continental |lake             |diisopropyl ether          | 0.0e+00| 0.0e+00|5.4e-19  |8.2e-07  |
    ## |Continental |air            |Continental |naturalsoil      |diisopropyl ether          | 0.0e+00| 0.0e+00|5.8e-17  |8.2e-07  |
    ## |Continental |air            |Continental |othersoil        |diisopropyl ether          | 0.0e+00| 0.0e+00|2.2e-17  |8.2e-07  |
    ## |Continental |air            |Continental |river            |diisopropyl ether          | 0.0e+00| 0.0e+00|5.9e-18  |8.2e-07  |
    ## |Continental |air            |Continental |sea              |diisopropyl ether          | 0.0e+00| 0.0e+00|2.3e-16  |8.2e-07  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |diisopropyl ether          | 0.0e+00| 0.0e+00|2.0e-16  |7.3e-07  |
    ## |Moderate    |air            |Moderate    |sea              |diisopropyl ether          | 0.0e+00| 0.0e+00|2.0e-16  |7.3e-07  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |diisopropyl ether          | 0.0e+00| 0.0e+00|5.1e-17  |2.5e-07  |
    ## |Tropic      |air            |Tropic      |sea              |diisopropyl ether          | 0.0e+00| 0.0e+00|1.2e-16  |2.5e-07  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |N-butylbenzenesulphonamide | 3.2e-06| 3.3e-06|6.8e-08  |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |N-butylbenzenesulphonamide | 4.8e-06| 4.9e-06|1.0e-07  |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |N-butylbenzenesulphonamide | 2.2e-06| 2.3e-06|8.7e-08  |3.8e-02  |
    ## |Continental |air            |Continental |lake             |N-butylbenzenesulphonamide | 0.0e+00| 0.0e+00|3.6e-10  |3.8e-02  |
    ## |Continental |air            |Continental |naturalsoil      |N-butylbenzenesulphonamide | 1.0e-06| 1.0e-06|3.9e-08  |3.8e-02  |
    ## |Continental |air            |Continental |othersoil        |N-butylbenzenesulphonamide | 4.0e-07| 4.0e-07|1.5e-08  |3.8e-02  |
    ## |Continental |air            |Continental |river            |N-butylbenzenesulphonamide | 1.0e-07| 1.0e-07|4.0e-09  |3.8e-02  |
    ## |Continental |air            |Continental |sea              |N-butylbenzenesulphonamide | 4.0e-06| 4.1e-06|1.5e-07  |3.8e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |N-butylbenzenesulphonamide | 3.9e-06| 4.0e-06|1.3e-07  |3.3e-02  |
    ## |Moderate    |air            |Moderate    |sea              |N-butylbenzenesulphonamide | 3.9e-06| 4.0e-06|1.3e-07  |3.3e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |N-butylbenzenesulphonamide | 2.4e-06| 2.4e-06|2.8e-08  |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |N-butylbenzenesulphonamide | 5.5e-06| 5.6e-06|6.6e-08  |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |formaldehyde               | 2.1e-06| 2.1e-06|-6.1e-09 |-2.9e-03 |
    ## |Arctic      |air            |Arctic      |sea              |formaldehyde               | 3.1e-06| 3.1e-06|-9.1e-09 |-2.9e-03 |
    ## |Continental |air            |Continental |agriculturalsoil |formaldehyde               | 1.4e-06| 1.4e-06|-6.5e-09 |-4.6e-03 |
    ## |Continental |air            |Continental |lake             |formaldehyde               | 0.0e+00| 0.0e+00|-2.7e-11 |-4.6e-03 |
    ## |Continental |air            |Continental |naturalsoil      |formaldehyde               | 6.0e-07| 6.0e-07|-2.9e-09 |-4.6e-03 |
    ## |Continental |air            |Continental |othersoil        |formaldehyde               | 2.0e-07| 2.0e-07|-1.1e-09 |-4.6e-03 |
    ## |Continental |air            |Continental |river            |formaldehyde               | 1.0e-07| 1.0e-07|-3.0e-10 |-4.6e-03 |
    ## |Continental |air            |Continental |sea              |formaldehyde               | 2.5e-06| 2.5e-06|-1.2e-08 |-4.6e-03 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |formaldehyde               | 2.4e-06| 2.4e-06|-9.4e-09 |-3.9e-03 |
    ## |Moderate    |air            |Moderate    |sea              |formaldehyde               | 2.4e-06| 2.4e-06|-9.4e-09 |-3.9e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |formaldehyde               | 1.4e-06| 1.4e-06|-1.8e-09 |-1.2e-03 |
    ## |Tropic      |air            |Tropic      |sea              |formaldehyde               | 3.3e-06| 3.3e-06|-4.1e-09 |-1.2e-03 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|4.7e-17  |7.4e-07  |
    ## |Arctic      |air            |Arctic      |sea              |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|7.1e-17  |7.4e-07  |
    ## |Continental |air            |Continental |agriculturalsoil |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|1.2e-16  |1.9e-06  |
    ## |Continental |air            |Continental |lake             |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|4.8e-19  |1.9e-06  |
    ## |Continental |air            |Continental |naturalsoil      |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|5.2e-17  |1.9e-06  |
    ## |Continental |air            |Continental |othersoil        |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|1.9e-17  |1.9e-06  |
    ## |Continental |air            |Continental |river            |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|5.3e-18  |1.9e-06  |
    ## |Continental |air            |Continental |sea              |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|2.1e-16  |1.9e-06  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|1.7e-16  |1.6e-06  |
    ## |Moderate    |air            |Moderate    |sea              |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|1.7e-16  |1.6e-06  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|5.5e-17  |7.0e-07  |
    ## |Tropic      |air            |Tropic      |sea              |1,1,1-trichloroethane      | 0.0e+00| 0.0e+00|1.3e-16  |7.0e-07  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |isopropylamine             | 0.0e+00| 0.0e+00|-1.4e-21 |-1.5e-06 |
    ## |Arctic      |air            |Arctic      |sea              |isopropylamine             | 0.0e+00| 0.0e+00|-2.0e-21 |-1.5e-06 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |isopropylamine             | 0.0e+00| 0.0e+00|-1.0e-21 |-6.5e-07 |
    ## |Tropic      |air            |Tropic      |sea              |isopropylamine             | 0.0e+00| 0.0e+00|-2.4e-21 |-6.5e-07 |

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-3.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-4.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart |toScale     |toSubCompart     |Substance               |   k_Old|   k_New|diff    |rel_diff |
    ## |:-----------|:--------------|:-----------|:----------------|:-----------------------|-------:|-------:|:-------|:--------|
    ## |Arctic      |air            |Arctic      |naturalsoil      |ISOBUTYRIC ACID         | 4.0e-07| 4.0e-07|1.9e-09 |4.4e-03  |
    ## |Arctic      |air            |Arctic      |sea              |ISOBUTYRIC ACID         | 6.0e-07| 6.0e-07|2.9e-09 |4.4e-03  |
    ## |Continental |air            |Continental |agriculturalsoil |ISOBUTYRIC ACID         | 2.0e-07| 2.0e-07|1.6e-09 |6.6e-03  |
    ## |Continental |air            |Continental |lake             |ISOBUTYRIC ACID         | 0.0e+00| 0.0e+00|6.6e-12 |6.6e-03  |
    ## |Continental |air            |Continental |naturalsoil      |ISOBUTYRIC ACID         | 1.0e-07| 1.0e-07|7.2e-10 |6.6e-03  |
    ## |Continental |air            |Continental |othersoil        |ISOBUTYRIC ACID         | 0.0e+00| 0.0e+00|2.6e-10 |6.6e-03  |
    ## |Continental |air            |Continental |river            |ISOBUTYRIC ACID         | 0.0e+00| 0.0e+00|7.3e-11 |6.6e-03  |
    ## |Continental |air            |Continental |sea              |ISOBUTYRIC ACID         | 4.0e-07| 4.0e-07|2.8e-09 |6.6e-03  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |ISOBUTYRIC ACID         | 4.0e-07| 4.0e-07|2.4e-09 |5.7e-03  |
    ## |Moderate    |air            |Moderate    |sea              |ISOBUTYRIC ACID         | 4.0e-07| 4.0e-07|2.4e-09 |5.7e-03  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |ISOBUTYRIC ACID         | 2.0e-07| 2.0e-07|4.3e-10 |1.8e-03  |
    ## |Tropic      |air            |Tropic      |sea              |ISOBUTYRIC ACID         | 6.0e-07| 6.0e-07|9.9e-10 |1.8e-03  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |3-METHYL-4-CHLOROPHENOL | 4.0e-07| 4.0e-07|5.8e-10 |1.4e-03  |
    ## |Arctic      |air            |Arctic      |sea              |3-METHYL-4-CHLOROPHENOL | 6.0e-07| 6.0e-07|8.8e-10 |1.4e-03  |
    ## |Continental |air            |Continental |agriculturalsoil |3-METHYL-4-CHLOROPHENOL | 2.0e-07| 2.0e-07|1.5e-10 |9.5e-04  |
    ## |Continental |air            |Continental |lake             |3-METHYL-4-CHLOROPHENOL | 0.0e+00| 0.0e+00|6.2e-13 |9.5e-04  |
    ## |Continental |air            |Continental |naturalsoil      |3-METHYL-4-CHLOROPHENOL | 1.0e-07| 1.0e-07|6.7e-11 |9.5e-04  |
    ## |Continental |air            |Continental |othersoil        |3-METHYL-4-CHLOROPHENOL | 0.0e+00| 0.0e+00|2.5e-11 |9.5e-04  |
    ## |Continental |air            |Continental |river            |3-METHYL-4-CHLOROPHENOL | 0.0e+00| 0.0e+00|6.8e-12 |9.5e-04  |
    ## |Continental |air            |Continental |sea              |3-METHYL-4-CHLOROPHENOL | 3.0e-07| 3.0e-07|2.6e-10 |9.5e-04  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |3-METHYL-4-CHLOROPHENOL | 3.0e-07| 3.0e-07|2.3e-10 |8.6e-04  |
    ## |Moderate    |air            |Moderate    |sea              |3-METHYL-4-CHLOROPHENOL | 3.0e-07| 3.0e-07|2.3e-10 |8.6e-04  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |3-METHYL-4-CHLOROPHENOL | 1.0e-07| 1.0e-07|2.0e-11 |1.7e-04  |
    ## |Tropic      |air            |Tropic      |sea              |3-METHYL-4-CHLOROPHENOL | 3.0e-07| 3.0e-07|4.7e-11 |1.7e-04  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |BUTYL XANTHATE          | 1.0e-07| 1.0e-07|9.4e-12 |8.7e-05  |
    ## |Arctic      |air            |Arctic      |sea              |BUTYL XANTHATE          | 2.0e-07| 2.0e-07|1.4e-11 |8.7e-05  |
    ## |Continental |air            |Continental |agriculturalsoil |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|1.4e-12 |3.3e-05  |
    ## |Continental |air            |Continental |lake             |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|5.8e-15 |3.3e-05  |
    ## |Continental |air            |Continental |naturalsoil      |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|6.3e-13 |3.3e-05  |
    ## |Continental |air            |Continental |othersoil        |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|2.3e-13 |3.3e-05  |
    ## |Continental |air            |Continental |river            |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|6.4e-14 |3.3e-05  |
    ## |Continental |air            |Continental |sea              |BUTYL XANTHATE          | 1.0e-07| 1.0e-07|2.5e-12 |3.3e-05  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |BUTYL XANTHATE          | 1.0e-07| 1.0e-07|2.3e-12 |3.3e-05  |
    ## |Moderate    |air            |Moderate    |sea              |BUTYL XANTHATE          | 1.0e-07| 1.0e-07|2.3e-12 |3.3e-05  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |BUTYL XANTHATE          | 0.0e+00| 0.0e+00|7.9e-14 |2.3e-06  |
    ## |Tropic      |air            |Tropic      |sea              |BUTYL XANTHATE          | 1.0e-07| 1.0e-07|1.8e-13 |2.3e-06  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |2,6-dichlorophenol      | 3.0e-07| 3.0e-07|1.1e-09 |3.4e-03  |
    ## |Arctic      |air            |Arctic      |sea              |2,6-dichlorophenol      | 5.0e-07| 5.0e-07|1.7e-09 |3.4e-03  |
    ## |Continental |air            |Continental |agriculturalsoil |2,6-dichlorophenol      | 1.0e-07| 1.0e-07|3.2e-10 |3.0e-03  |
    ## |Continental |air            |Continental |lake             |2,6-dichlorophenol      | 0.0e+00| 0.0e+00|1.4e-12 |3.0e-03  |
    ## |Continental |air            |Continental |naturalsoil      |2,6-dichlorophenol      | 0.0e+00| 0.0e+00|1.5e-10 |3.0e-03  |
    ## |Continental |air            |Continental |othersoil        |2,6-dichlorophenol      | 0.0e+00| 0.0e+00|5.4e-11 |3.0e-03  |
    ## |Continental |air            |Continental |river            |2,6-dichlorophenol      | 0.0e+00| 0.0e+00|1.5e-11 |3.0e-03  |
    ## |Continental |air            |Continental |sea              |2,6-dichlorophenol      | 2.0e-07| 2.0e-07|5.8e-10 |3.0e-03  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |2,6-dichlorophenol      | 2.0e-07| 2.0e-07|4.9e-10 |2.6e-03  |
    ## |Moderate    |air            |Moderate    |sea              |2,6-dichlorophenol      | 2.0e-07| 2.0e-07|4.9e-10 |2.6e-03  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |2,6-dichlorophenol      | 1.0e-07| 1.0e-07|5.0e-11 |6.2e-04  |
    ## |Tropic      |air            |Tropic      |sea              |2,6-dichlorophenol      | 2.0e-07| 2.0e-07|1.2e-10 |6.2e-04  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |PHENYLEPHRINE HCL       | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |PHENYLEPHRINE HCL       | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |PHENYLEPHRINE HCL       | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |PHENYLEPHRINE HCL       | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |PHENYLEPHRINE HCL       | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |PHENYLEPHRINE HCL       | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |PHENYLEPHRINE HCL       | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |PHENYLEPHRINE HCL       | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |PHENYLEPHRINE HCL       | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |PHENYLEPHRINE HCL       | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |PHENYLEPHRINE HCL       | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |PHENYLEPHRINE HCL       | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-5.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-6.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart |toScale     |toSubCompart     |Substance               |   k_Old|   k_New|diff     |rel_diff |
    ## |:-----------|:--------------|:-----------|:----------------|:-----------------------|-------:|-------:|:--------|:--------|
    ## |Arctic      |air            |Arctic      |naturalsoil      |Triasulfuron            | 3.2e-06| 3.3e-06|6.8e-08  |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |Triasulfuron            | 4.8e-06| 4.9e-06|1.0e-07  |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |Triasulfuron            | 2.3e-06| 2.4e-06|9.1e-08  |3.9e-02  |
    ## |Continental |air            |Continental |lake             |Triasulfuron            | 0.0e+00| 0.0e+00|3.8e-10  |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |Triasulfuron            | 1.0e-06| 1.1e-06|4.1e-08  |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |Triasulfuron            | 4.0e-07| 4.0e-07|1.5e-08  |3.9e-02  |
    ## |Continental |air            |Continental |river            |Triasulfuron            | 1.0e-07| 1.0e-07|4.2e-09  |3.9e-02  |
    ## |Continental |air            |Continental |sea              |Triasulfuron            | 4.0e-06| 4.2e-06|1.6e-07  |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Triasulfuron            | 4.0e-06| 4.1e-06|1.4e-07  |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |Triasulfuron            | 4.0e-06| 4.1e-06|1.4e-07  |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Triasulfuron            | 2.4e-06| 2.5e-06|3.0e-08  |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |Triasulfuron            | 5.7e-06| 5.7e-06|7.0e-08  |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |1,2-DIAMINOPROPANE      | 3.0e-06| 3.1e-06|5.3e-08  |1.7e-02  |
    ## |Arctic      |air            |Arctic      |sea              |1,2-DIAMINOPROPANE      | 4.5e-06| 4.6e-06|7.9e-08  |1.7e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |1,2-DIAMINOPROPANE      | 2.0e-06| 2.0e-06|3.5e-08  |1.7e-02  |
    ## |Continental |air            |Continental |lake             |1,2-DIAMINOPROPANE      | 0.0e+00| 0.0e+00|1.4e-10  |1.7e-02  |
    ## |Continental |air            |Continental |naturalsoil      |1,2-DIAMINOPROPANE      | 9.0e-07| 9.0e-07|1.6e-08  |1.7e-02  |
    ## |Continental |air            |Continental |othersoil        |1,2-DIAMINOPROPANE      | 3.0e-07| 3.0e-07|5.8e-09  |1.7e-02  |
    ## |Continental |air            |Continental |river            |1,2-DIAMINOPROPANE      | 1.0e-07| 1.0e-07|1.6e-09  |1.7e-02  |
    ## |Continental |air            |Continental |sea              |1,2-DIAMINOPROPANE      | 3.5e-06| 3.6e-06|6.2e-08  |1.7e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |1,2-DIAMINOPROPANE      | 3.4e-06| 3.5e-06|5.5e-08  |1.6e-02  |
    ## |Moderate    |air            |Moderate    |sea              |1,2-DIAMINOPROPANE      | 3.4e-06| 3.5e-06|5.5e-08  |1.6e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |1,2-DIAMINOPROPANE      | 2.0e-06| 2.0e-06|3.8e-09  |1.9e-03  |
    ## |Tropic      |air            |Tropic      |sea              |1,2-DIAMINOPROPANE      | 4.6e-06| 4.6e-06|8.9e-09  |1.9e-03  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |CHLORIDAZON             | 2.5e-06| 2.5e-06|2.4e-09  |9.8e-04  |
    ## |Arctic      |air            |Arctic      |sea              |CHLORIDAZON             | 3.7e-06| 3.7e-06|3.6e-09  |9.8e-04  |
    ## |Continental |air            |Continental |agriculturalsoil |CHLORIDAZON             | 1.8e-06| 1.8e-06|-1.8e-08 |-1.0e-02 |
    ## |Continental |air            |Continental |lake             |CHLORIDAZON             | 0.0e+00| 0.0e+00|-7.6e-11 |-1.0e-02 |
    ## |Continental |air            |Continental |naturalsoil      |CHLORIDAZON             | 8.0e-07| 8.0e-07|-8.2e-09 |-1.0e-02 |
    ## |Continental |air            |Continental |othersoil        |CHLORIDAZON             | 3.0e-07| 3.0e-07|-3.0e-09 |-1.0e-02 |
    ## |Continental |air            |Continental |river            |CHLORIDAZON             | 1.0e-07| 1.0e-07|-8.3e-10 |-1.0e-02 |
    ## |Continental |air            |Continental |sea              |CHLORIDAZON             | 3.2e-06| 3.2e-06|-3.2e-08 |-1.0e-02 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |CHLORIDAZON             | 3.1e-06| 3.1e-06|-2.6e-08 |-8.5e-03 |
    ## |Moderate    |air            |Moderate    |sea              |CHLORIDAZON             | 3.1e-06| 3.1e-06|-2.6e-08 |-8.5e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |CHLORIDAZON             | 1.9e-06| 1.9e-06|-5.9e-09 |-3.1e-03 |
    ## |Tropic      |air            |Tropic      |sea              |CHLORIDAZON             | 4.4e-06| 4.4e-06|-1.4e-08 |-3.1e-03 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |HYDRAZINE, 1,1-DIBUTYL- | 2.3e-06| 2.3e-06|-3.7e-09 |-1.6e-03 |
    ## |Arctic      |air            |Arctic      |sea              |HYDRAZINE, 1,1-DIBUTYL- | 3.5e-06| 3.5e-06|-5.5e-09 |-1.6e-03 |
    ## |Continental |air            |Continental |agriculturalsoil |HYDRAZINE, 1,1-DIBUTYL- | 1.7e-06| 1.7e-06|-1.0e-08 |-6.2e-03 |
    ## |Continental |air            |Continental |lake             |HYDRAZINE, 1,1-DIBUTYL- | 0.0e+00| 0.0e+00|-4.3e-11 |-6.2e-03 |
    ## |Continental |air            |Continental |naturalsoil      |HYDRAZINE, 1,1-DIBUTYL- | 8.0e-07| 8.0e-07|-4.7e-09 |-6.2e-03 |
    ## |Continental |air            |Continental |othersoil        |HYDRAZINE, 1,1-DIBUTYL- | 3.0e-07| 3.0e-07|-1.7e-09 |-6.2e-03 |
    ## |Continental |air            |Continental |river            |HYDRAZINE, 1,1-DIBUTYL- | 1.0e-07| 1.0e-07|-4.8e-10 |-6.2e-03 |
    ## |Continental |air            |Continental |sea              |HYDRAZINE, 1,1-DIBUTYL- | 3.0e-06| 3.0e-06|-1.8e-08 |-6.2e-03 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |HYDRAZINE, 1,1-DIBUTYL- | 2.9e-06| 2.9e-06|-1.4e-08 |-4.9e-03 |
    ## |Moderate    |air            |Moderate    |sea              |HYDRAZINE, 1,1-DIBUTYL- | 2.9e-06| 2.9e-06|-1.4e-08 |-4.9e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |HYDRAZINE, 1,1-DIBUTYL- | 1.8e-06| 1.7e-06|-3.5e-09 |-2.0e-03 |
    ## |Tropic      |air            |Tropic      |sea              |HYDRAZINE, 1,1-DIBUTYL- | 4.1e-06| 4.1e-06|-8.3e-09 |-2.0e-03 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |alpha-Naphthylamine     | 4.1e-06| 4.1e-06|-1.4e-08 |-3.4e-03 |
    ## |Arctic      |air            |Arctic      |sea              |alpha-Naphthylamine     | 6.1e-06| 6.1e-06|-2.1e-08 |-3.4e-03 |
    ## |Continental |air            |Continental |agriculturalsoil |alpha-Naphthylamine     | 2.7e-06| 2.7e-06|-1.3e-08 |-4.8e-03 |
    ## |Continental |air            |Continental |lake             |alpha-Naphthylamine     | 0.0e+00| 0.0e+00|-5.4e-11 |-4.8e-03 |
    ## |Continental |air            |Continental |naturalsoil      |alpha-Naphthylamine     | 1.2e-06| 1.2e-06|-5.8e-09 |-4.8e-03 |
    ## |Continental |air            |Continental |othersoil        |alpha-Naphthylamine     | 5.0e-07| 5.0e-07|-2.1e-09 |-4.8e-03 |
    ## |Continental |air            |Continental |river            |alpha-Naphthylamine     | 1.0e-07| 1.0e-07|-5.9e-10 |-4.8e-03 |
    ## |Continental |air            |Continental |sea              |alpha-Naphthylamine     | 4.8e-06| 4.8e-06|-2.3e-08 |-4.8e-03 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |alpha-Naphthylamine     | 4.7e-06| 4.6e-06|-1.9e-08 |-4.0e-03 |
    ## |Moderate    |air            |Moderate    |sea              |alpha-Naphthylamine     | 4.7e-06| 4.6e-06|-1.9e-08 |-4.0e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |alpha-Naphthylamine     | 2.5e-06| 2.5e-06|-2.6e-09 |-1.0e-03 |
    ## |Tropic      |air            |Tropic      |sea              |alpha-Naphthylamine     | 5.8e-06| 5.8e-06|-6.0e-09 |-1.0e-03 |

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-7.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-8.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart |toScale     |toSubCompart     |Substance |   k_Old|   k_New|diff    |rel_diff |
    ## |:-----------|:--------------|:-----------|:----------------|:---------|-------:|-------:|:-------|:--------|
    ## |Arctic      |air            |Arctic      |naturalsoil      |V(V)      | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |V(V)      | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |V(V)      | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |V(V)      | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |V(V)      | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |V(V)      | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |V(V)      | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |V(V)      | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |V(V)      | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |V(V)      | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |V(V)      | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |V(V)      | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |Ba(II)    | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |Ba(II)    | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |Ba(II)    | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |Ba(II)    | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |Ba(II)    | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |Ba(II)    | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |Ba(II)    | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |Ba(II)    | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Ba(II)    | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |Ba(II)    | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Ba(II)    | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |Ba(II)    | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |Pb(II)    | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |Pb(II)    | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |Pb(II)    | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |Pb(II)    | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |Pb(II)    | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |Pb(II)    | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |Pb(II)    | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |Pb(II)    | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Pb(II)    | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |Pb(II)    | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Pb(II)    | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |Pb(II)    | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |Tl(I)     | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |Tl(I)     | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |Tl(I)     | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |Tl(I)     | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |Tl(I)     | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |Tl(I)     | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |Tl(I)     | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |Tl(I)     | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Tl(I)     | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |Tl(I)     | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Tl(I)     | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |Tl(I)     | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |Cr(III)   | 3.2e-06| 3.3e-06|6.8e-08 |2.1e-02  |
    ## |Arctic      |air            |Arctic      |sea              |Cr(III)   | 4.8e-06| 4.9e-06|1.0e-07 |2.1e-02  |
    ## |Continental |air            |Continental |agriculturalsoil |Cr(III)   | 2.3e-06| 2.4e-06|9.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |lake             |Cr(III)   | 0.0e+00| 0.0e+00|3.8e-10 |3.9e-02  |
    ## |Continental |air            |Continental |naturalsoil      |Cr(III)   | 1.0e-06| 1.1e-06|4.1e-08 |3.9e-02  |
    ## |Continental |air            |Continental |othersoil        |Cr(III)   | 4.0e-07| 4.0e-07|1.5e-08 |3.9e-02  |
    ## |Continental |air            |Continental |river            |Cr(III)   | 1.0e-07| 1.0e-07|4.2e-09 |3.9e-02  |
    ## |Continental |air            |Continental |sea              |Cr(III)   | 4.0e-06| 4.2e-06|1.6e-07 |3.9e-02  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Cr(III)   | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Moderate    |air            |Moderate    |sea              |Cr(III)   | 4.0e-06| 4.1e-06|1.4e-07 |3.4e-02  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Cr(III)   | 2.4e-06| 2.5e-06|3.0e-08 |1.2e-02  |
    ## |Tropic      |air            |Tropic      |sea              |Cr(III)   | 5.7e-06| 5.7e-06|7.0e-08 |1.2e-02  |

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-9.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-10.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart |toScale     |toSubCompart     |Substance                                 |   k_Old|   k_New|diff     |rel_diff |
    ## |:-----------|:--------------|:-----------|:----------------|:-----------------------------------------|-------:|-------:|:--------|:--------|
    ## |Arctic      |air            |Arctic      |naturalsoil      |Propanedioic acid, chloro-, diethyl ester | 2.0e-07| 2.0e-07|3.4e-10  |1.9e-03  |
    ## |Arctic      |air            |Arctic      |sea              |Propanedioic acid, chloro-, diethyl ester | 3.0e-07| 3.0e-07|5.2e-10  |1.9e-03  |
    ## |Continental |air            |Continental |agriculturalsoil |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|1.4e-10  |2.0e-03  |
    ## |Continental |air            |Continental |lake             |Propanedioic acid, chloro-, diethyl ester | 0.0e+00| 0.0e+00|5.8e-13  |2.0e-03  |
    ## |Continental |air            |Continental |naturalsoil      |Propanedioic acid, chloro-, diethyl ester | 0.0e+00| 0.0e+00|6.2e-11  |2.0e-03  |
    ## |Continental |air            |Continental |othersoil        |Propanedioic acid, chloro-, diethyl ester | 0.0e+00| 0.0e+00|2.3e-11  |2.0e-03  |
    ## |Continental |air            |Continental |river            |Propanedioic acid, chloro-, diethyl ester | 0.0e+00| 0.0e+00|6.3e-12  |2.0e-03  |
    ## |Continental |air            |Continental |sea              |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|2.5e-10  |2.0e-03  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|2.1e-10  |1.7e-03  |
    ## |Moderate    |air            |Moderate    |sea              |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|2.1e-10  |1.7e-03  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|2.6e-11  |4.6e-04  |
    ## |Tropic      |air            |Tropic      |sea              |Propanedioic acid, chloro-, diethyl ester | 1.0e-07| 1.0e-07|6.0e-11  |4.6e-04  |
    ## |Arctic      |air            |Arctic      |naturalsoil      |Carbofuran                                | 2.3e-06| 2.3e-06|-2.6e-09 |-1.1e-03 |
    ## |Arctic      |air            |Arctic      |sea              |Carbofuran                                | 3.5e-06| 3.5e-06|-4.0e-09 |-1.1e-03 |
    ## |Continental |air            |Continental |agriculturalsoil |Carbofuran                                | 1.7e-06| 1.7e-06|-9.7e-09 |-5.8e-03 |
    ## |Continental |air            |Continental |lake             |Carbofuran                                | 0.0e+00| 0.0e+00|-4.1e-11 |-5.8e-03 |
    ## |Continental |air            |Continental |naturalsoil      |Carbofuran                                | 8.0e-07| 8.0e-07|-4.4e-09 |-5.8e-03 |
    ## |Continental |air            |Continental |othersoil        |Carbofuran                                | 3.0e-07| 3.0e-07|-1.6e-09 |-5.8e-03 |
    ## |Continental |air            |Continental |river            |Carbofuran                                | 1.0e-07| 1.0e-07|-4.5e-10 |-5.8e-03 |
    ## |Continental |air            |Continental |sea              |Carbofuran                                | 3.0e-06| 3.0e-06|-1.7e-08 |-5.8e-03 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |Carbofuran                                | 2.9e-06| 2.9e-06|-1.3e-08 |-4.5e-03 |
    ## |Moderate    |air            |Moderate    |sea              |Carbofuran                                | 2.9e-06| 2.9e-06|-1.3e-08 |-4.5e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |Carbofuran                                | 1.7e-06| 1.7e-06|-3.4e-09 |-1.9e-03 |
    ## |Tropic      |air            |Tropic      |sea              |Carbofuran                                | 4.1e-06| 4.0e-06|-7.8e-09 |-1.9e-03 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 2.3e-06| 2.3e-06|-6.7e-09 |-2.9e-03 |
    ## |Arctic      |air            |Arctic      |sea              |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 3.5e-06| 3.5e-06|-1.0e-08 |-2.9e-03 |
    ## |Continental |air            |Continental |agriculturalsoil |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 1.7e-06| 1.7e-06|-1.5e-08 |-8.8e-03 |
    ## |Continental |air            |Continental |lake             |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 0.0e+00| 0.0e+00|-6.3e-11 |-8.8e-03 |
    ## |Continental |air            |Continental |naturalsoil      |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 8.0e-07| 8.0e-07|-6.9e-09 |-8.8e-03 |
    ## |Continental |air            |Continental |othersoil        |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 3.0e-07| 3.0e-07|-2.5e-09 |-8.8e-03 |
    ## |Continental |air            |Continental |river            |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 1.0e-07| 1.0e-07|-7.0e-10 |-8.8e-03 |
    ## |Continental |air            |Continental |sea              |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 3.1e-06| 3.1e-06|-2.7e-08 |-8.8e-03 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 3.0e-06| 3.0e-06|-2.1e-08 |-7.3e-03 |
    ## |Moderate    |air            |Moderate    |sea              |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 3.0e-06| 3.0e-06|-2.1e-08 |-7.3e-03 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 1.8e-06| 1.8e-06|-5.0e-09 |-2.8e-03 |
    ## |Tropic      |air            |Tropic      |sea              |BENZALDEHYDE, 3-ETHOXY-4-HYDROXY-         | 4.2e-06| 4.2e-06|-1.2e-08 |-2.8e-03 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-2.3e-15 |-4.7e-07 |
    ## |Arctic      |air            |Arctic      |sea              |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-3.5e-15 |-4.7e-07 |
    ## |Continental |air            |Continental |agriculturalsoil |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-1.3e-15 |-1.0e-06 |
    ## |Continental |air            |Continental |lake             |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-5.4e-18 |-1.0e-06 |
    ## |Continental |air            |Continental |naturalsoil      |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-5.9e-16 |-1.0e-06 |
    ## |Continental |air            |Continental |othersoil        |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-2.2e-16 |-1.0e-06 |
    ## |Continental |air            |Continental |river            |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-6.0e-17 |-1.0e-06 |
    ## |Continental |air            |Continental |sea              |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-2.3e-15 |-1.0e-06 |
    ## |Moderate    |air            |Moderate    |naturalsoil      |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-1.8e-15 |-8.5e-07 |
    ## |Moderate    |air            |Moderate    |sea              |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-1.8e-15 |-8.5e-07 |
    ## |Tropic      |air            |Tropic      |naturalsoil      |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-1.9e-16 |-2.4e-07 |
    ## |Tropic      |air            |Tropic      |sea              |1,5-DIMETHYLNAPHTHALENE                   | 0.0e+00| 0.0e+00|-4.5e-16 |-2.4e-07 |
    ## |Arctic      |air            |Arctic      |naturalsoil      |1-pentanol                                | 0.0e+00| 0.0e+00|1.6e-11  |3.5e-04  |
    ## |Arctic      |air            |Arctic      |sea              |1-pentanol                                | 1.0e-07| 1.0e-07|2.4e-11  |3.5e-04  |
    ## |Continental |air            |Continental |agriculturalsoil |1-pentanol                                | 0.0e+00| 0.0e+00|1.3e-11  |4.9e-04  |
    ## |Continental |air            |Continental |lake             |1-pentanol                                | 0.0e+00| 0.0e+00|5.4e-14  |4.9e-04  |
    ## |Continental |air            |Continental |naturalsoil      |1-pentanol                                | 0.0e+00| 0.0e+00|5.8e-12  |4.9e-04  |
    ## |Continental |air            |Continental |othersoil        |1-pentanol                                | 0.0e+00| 0.0e+00|2.2e-12  |4.9e-04  |
    ## |Continental |air            |Continental |river            |1-pentanol                                | 0.0e+00| 0.0e+00|5.9e-13  |4.9e-04  |
    ## |Continental |air            |Continental |sea              |1-pentanol                                | 0.0e+00| 0.0e+00|2.3e-11  |4.9e-04  |
    ## |Moderate    |air            |Moderate    |naturalsoil      |1-pentanol                                | 0.0e+00| 0.0e+00|2.0e-11  |4.4e-04  |
    ## |Moderate    |air            |Moderate    |sea              |1-pentanol                                | 0.0e+00| 0.0e+00|2.0e-11  |4.4e-04  |
    ## |Tropic      |air            |Tropic      |naturalsoil      |1-pentanol                                | 0.0e+00| 0.0e+00|3.4e-12  |1.3e-04  |
    ## |Tropic      |air            |Tropic      |sea              |1-pentanol                                | 1.0e-07| 1.0e-07|8.0e-12  |1.3e-04  |

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-11.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20true-12.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

## Discussion

From the plots we can see the following: - The marine_currents_clean
branch turns the advection flow from Regional sea to Continental sea off
for all species - All deposition rates from air to water and soil
compartments are slightly different for molecules (neutral, no class,
base, acid, metal) v_Otherkair is a variable used in k_Deposition.
Otherkair is always NA for particulates, but for molecules Otherkair
equals the sum of all k’s from the same Scale-Species combination where
the SubCompart is air. Because changes in Advection processes (removal
of global scales) changes the other k’s to the air compartment at global
and continental scales, this causes changes in k_Deposition.

# Compare marine_currents_clean with new variables as FALSE to development

There is no need to run SB again for the development, we already have
the development k’s for the substances we want to compare. \## Calculate
the first order rate constants for the test branches

``` r
# Change the wd to the wd of the development branches
setwd(paste0(folderpaths[2], "/SBooScripts"))
test_false_kaas <- data.frame()
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  source("baseScripts/initWorld.R")
  # The code below is not necessary because the default values are FALSE
  
  # World$SetConst(Regional_and_Continental_deepocean = "FALSE") # If true, add deepocean to Regional and Continental scale
  # World$SetConst(Remove_global = "FALSE") #if true, remove flows to moderate, arctic and tropic
  # World$UpdateKaas(mergeExisting = FALSE)
  
  kaas <- World$kaas |>
    mutate(Substance = substance)
  test_false_kaas <- rbind(test_false_kaas, kaas)
}
```

## Compare the k values for each of the substances

``` r
common_cols <- setdiff(intersect(colnames(development_kaas), colnames(test_false_kaas)), "k")
kaas_comparison <- merge(
  development_kaas,
  test_false_kaas,
  by = common_cols,
  all = TRUE,
  suffixes = c("_Old", "_New")
)
kaas_comparison <- kaas_comparison |>
  mutate(diff = k_New-k_Old) |> # If this number is positive, the New_k is higher than the Old_k (higher advection rate with new method)
  mutate(rel_diff = diff/k_New)
changed_kaas <- kaas_comparison |>
  filter(diff != 0) |>
  mutate(full_name = paste0("From ", fromSubCompart, "_", fromScale, " to ", toSubCompart, "_", toScale))
```

``` r
diffs <- kaas_comparison |>
  mutate(fromname = paste0(process, "_", fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(process, "_", toSubCompart, "_", toScale)) |>
  mutate(diff = ifelse(diff == 0, NaN, diff)) |>
  left_join(cc_substances, by = "Substance")
chemclass <- "metal"
for(chemclass in unique(diffs$ChemClass)){
  changed <- diffs |>
    filter(rel_diff != 0) |>
    filter(ChemClass == chemclass)
  mean_changed <- changed |>
  group_by(fromname, toname) |>
  summarise(diff = mean(diff),
            rel_diff = mean(rel_diff))
  diff_plot <- ggplot(mean_changed, mapping = aes(x = toname, y = fromname, color = diff)) +
  geom_point() +
  scale_color_gradient2(
    low = "blue",    # Colors for negative values
    mid = "grey",   # Neutral point at zero
    high = "red",  # Colors for positive values
    midpoint = 0,   # Center the scale at zero
    limits = c(-max(abs(changed$diff)), max(abs(changed$diff)))  # Ensure symmetric scale
  ) +
  labs(
    title = paste0("Mean difference between old and new k's for ", chemclass, " substances"),
    subtitle = "Only k's with a difference above or below zero are shown. Global scale not removed.",
    x = "To",
    y = "From",
    color = "Difference"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()
  )
  print(diff_plot)
  rel_diff_plot <- ggplot(mean_changed, mapping = aes(x = toname, y = fromname, color = rel_diff)) +
  geom_point() +
  scale_color_gradient2(
    low = "blue",    # Colors for negative values
    mid = "grey",   # Neutral point at zero
    high = "red",  # Colors for positive values
    midpoint = 0,   # Center the scale at zero
    limits = c(-max(abs(changed$rel_diff)), max(abs(changed$rel_diff)))  # Ensure symmetric scale
  ) +
  labs(
    title = paste0("Mean relative difference between old and new k's for ", chemclass, " substances"),
    subtitle = "Only k's with a difference above or below zero are shown. Global scale not removed.",
    x = "To",
    y = "From",
    color = "Difference"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()
  )
  print(rel_diff_plot)
  table_for_display <- changed |>
  select(fromScale, fromSubCompart, toScale, toSubCompart, Substance, k_Old, k_New, diff, rel_diff) |>
  mutate(diff = format(diff, scientific = TRUE, digits = 2)) |>
  mutate(rel_diff = format(rel_diff, scientific = TRUE, digits = 2))
  print(knitr::kable(table_for_display))
}
```

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-1.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-2.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-3.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-4.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-5.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-6.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-7.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-8.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-9.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-10.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-11.png)<!-- -->![](Comparison-marine-currents_files/figure-gfm/Plots%20development%20and%20marine%20currents%20with%20vars%20as%20false-12.png)<!-- -->

    ## 
    ## 
    ## |fromScale |fromSubCompart |toScale |toSubCompart |Substance | k_Old| k_New|diff |rel_diff |
    ## |:---------|:--------------|:-------|:------------|:---------|-----:|-----:|:----|:--------|

### Check if deepocean at Regional and Continental scale disappear

``` r
development_combo <- development_kaas %>% distinct(fromScale, fromSubCompart)
test_combo <- test_false_kaas %>% distinct(fromScale, fromSubCompart)

development_combo <- development_combo %>% mutate(source = "development")
test_combo <- test_combo %>% mutate(source = "test")

all_combos <- bind_rows(development_combo, test_combo)

# Tel per combinatie hoe vaak deze voorkomt (in development, test, of beide)
combo_check <- all_combos %>%
  group_by(fromScale, fromSubCompart) %>%
  summarise(
    in_development = any(source == "development"),
    in_test = any(source == "test"),
    .groups = "drop"
  )

#Alleen in development:
only_in_development <- combo_check %>% filter(in_development & !in_test)
#Alleen in test:
only_in_test <- combo_check %>% filter(!in_development & in_test)
#In beide:
in_both <- combo_check %>% filter(in_development & in_test)

extra_compartment_check_from <- kaas_comparison |> 
  filter(fromSubCompart %in% only_in_test$fromSubCompart & fromScale %in% only_in_test$fromScale) 

extra_compartment_check_to <- kaas_comparison |> 
  filter(toSubCompart %in% only_in_test$fromSubCompart & fromScale %in% only_in_test$fromScale)

extra_compartment_check <- rbind(extra_compartment_check_from, extra_compartment_check_to) |>
  filter(!is.na(k_New))

functions_to_be_altered <- unique(extra_compartment_check$process)

print(functions_to_be_altered)
```

    ## character(0)

There are no remaining functions to which exceptions should be added.

### Check if the connection from sea to marinesediment reappears

``` r
marine_sediment_check <- kaas_comparison |>
  filter(toSubCompart == "marinesediment" | toSubCompart == "sea") |>
  filter(fromSubCompart == "sea" | fromSubCompart == "marinesediment") |>
  filter(fromSubCompart != toSubCompart)
```

It does not, because exceptions were added to the k_Sedimentation and
k_Resuspension functions.

## Discussion

When both test values are turned off in the marine_currents_clean
branch, the results are the same as in the development.
