General script comparing plastic_fade_degradation branches to
development
================
Anne Hids, Joris Quik
2025-11-20

# Setup for comparison

The below scripts should be run to compare two versions of SBoo.

``` r
tag <- NA # For comparison with most recent version of development
branch_sboo <- "plastic_fade_degradation"
branch_sbooscripts <- "plastic_fade_degradation"
```

# Define function for downloading and ordering the folders needed to compare

``` r
source("vignettes/Development/Quality control/ComparisonFunctions.R")

folderpaths <- CompareFilesPrep(Release = tag,
                             Test_SBoo = branch_sboo,
                             Test_SBooScripts = branch_sbooscripts,
                             Temp_Folder = dest_folder)
```

Select random substances for testing

``` r
excluded_substances <- c("Graphene Oxide", "Chitosan", "nTiO2_P25_CaLIBRAte_D6_3", "nAg_NanoFase", "nanoparticle", "GO-Chitosan")

substances <- read.csv("data/Substances.csv") |>
  filter(!Substance %in% excluded_substances) |>
  filter(!grepl("^microplastic_", Substance))

mp <- substances |>
  filter(Substance == "microplastic")

set.seed(123)

substances <- substances |>
  group_by(ChemClass) |>
  slice_sample(n = 5, replace = FALSE) |>
  ungroup()

substances <- rbind(substances, mp) |>
  distinct()

substance_names <- substances$Substance    # Assuming the column for names is 'SubstanceName'

cc_substances <- substances |>
  select(Substance, ChemClass)
```

# Calculate first order rate constants for the main

``` r
# Save the original working directory for later
original_wd <- getwd()

# Change the wd to the wd of the main branches
setwd(paste0(folderpaths[1], "/SBooScripts"))

# Calculate the kaas 
main_kaas <- data.frame()
  
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  
  source("baseScripts/initWorld.R")

  kaas <- World$kaas |>
    mutate(Substance = substance)
  
  main_kaas <- rbind(main_kaas, kaas)
}
```

# Calculate the first order rate constants for the test branches

``` r
# Change the wd to the wd of the main branches
setwd(paste0(folderpaths[2], "/SBooScripts"))

test_kaas <- data.frame()
  
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  
  source("baseScripts/initWorld.R")

  kaas <- World$kaas |>
    mutate(Substance = substance)
  
  test_kaas <- rbind(test_kaas, kaas)
}
```

## Compare the k values for each of the substances

``` r
common_cols <- setdiff(intersect(colnames(main_kaas), colnames(test_kaas)), "k")

kaas_comparison <- merge(main_kaas, test_kaas, by=common_cols, suffixes = c("_Old", "_New"))

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

for(chemclass in unique(diffs$ChemClass)){
  changed <- diffs |>
    filter(rel_diff != 0) |>
    filter(ChemClass == chemclass)
  
  if(nrow(changed) == 0){
    print(paste0("No differences found for ", chemclass, " substances"))
  } else {
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
      subtitle = "Only k's with a difference above or below zero are shown",
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
      subtitle = "Only k's with a difference above or below zero are shown",
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
}
```

![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart   |toScale     |toSubCompart     |Substance  |    k_Old|    k_New|diff     |rel_diff |
    ## |:-----------|:----------------|:-----------|:----------------|:----------|--------:|--------:|:--------|:--------|
    ## |Arctic      |air              |Arctic      |naturalsoil      |Carbofuran | 4.00e-07| 4.00e-07|3.3e-12  |8.0e-06  |
    ## |Arctic      |air              |Arctic      |sea              |Carbofuran | 2.30e-06| 2.30e-06|1.8e-11  |8.0e-06  |
    ## |Continental |air              |Continental |agriculturalsoil |Carbofuran | 3.00e-07| 3.00e-07|3.9e-13  |1.3e-06  |
    ## |Continental |air              |Continental |lake             |Carbofuran | 0.00e+00| 0.00e+00|7.3e-15  |1.6e-06  |
    ## |Continental |air              |Continental |naturalsoil      |Carbofuran | 1.00e-07| 1.00e-07|1.7e-13  |1.3e-06  |
    ## |Continental |air              |Continental |othersoil        |Carbofuran | 1.00e-07| 1.00e-07|6.4e-14  |1.3e-06  |
    ## |Continental |air              |Continental |river            |Carbofuran | 1.00e-07| 1.00e-07|8.0e-14  |1.6e-06  |
    ## |Continental |air              |Continental |sea              |Carbofuran | 2.00e-06| 2.00e-06|3.1e-12  |1.6e-06  |
    ## |Moderate    |air              |Moderate    |naturalsoil      |Carbofuran | 5.00e-07| 5.00e-07|6.7e-13  |1.3e-06  |
    ## |Moderate    |air              |Moderate    |sea              |Carbofuran | 1.90e-06| 1.90e-06|3.0e-12  |1.6e-06  |
    ## |Regional    |air              |Regional    |agriculturalsoil |Carbofuran | 6.00e-07| 6.00e-07|8.0e-13  |1.3e-06  |
    ## |Regional    |air              |Regional    |lake             |Carbofuran | 0.00e+00| 0.00e+00|1.5e-14  |1.6e-06  |
    ## |Regional    |air              |Regional    |naturalsoil      |Carbofuran | 3.00e-07| 3.00e-07|3.6e-13  |1.3e-06  |
    ## |Regional    |air              |Regional    |othersoil        |Carbofuran | 1.00e-07| 1.00e-07|1.3e-13  |1.3e-06  |
    ## |Regional    |air              |Regional    |river            |Carbofuran | 1.00e-07| 1.00e-07|1.7e-13  |1.6e-06  |
    ## |Regional    |air              |Regional    |sea              |Carbofuran | 0.00e+00| 0.00e+00|2.6e-14  |1.6e-06  |
    ## |Tropic      |air              |Tropic      |naturalsoil      |Carbofuran | 3.00e-07| 3.00e-07|2.5e-13  |7.9e-07  |
    ## |Tropic      |air              |Tropic      |sea              |Carbofuran | 2.70e-06| 2.70e-06|3.4e-12  |1.3e-06  |
    ## |Arctic      |air              |Arctic      |air              |Carbofuran | 1.45e-05| 1.45e-05|1.2e-10  |8.0e-06  |
    ## |Continental |air              |Continental |air              |Carbofuran | 1.75e-05| 1.75e-05|2.8e-11  |1.6e-06  |
    ## |Moderate    |air              |Moderate    |air              |Carbofuran | 1.75e-05| 1.75e-05|2.8e-11  |1.6e-06  |
    ## |Regional    |air              |Regional    |air              |Carbofuran | 1.75e-05| 1.75e-05|2.8e-11  |1.6e-06  |
    ## |Tropic      |air              |Tropic      |air              |Carbofuran | 1.94e-05| 1.94e-05|2.6e-11  |1.3e-06  |
    ## |Arctic      |air              |Arctic      |naturalsoil      |Carbofuran | 2.30e-06| 2.30e-06|-3.4e-12 |-1.5e-06 |
    ## |Arctic      |air              |Arctic      |sea              |Carbofuran | 3.50e-06| 3.50e-06|-5.1e-12 |-1.5e-06 |
    ## |Continental |air              |Continental |agriculturalsoil |Carbofuran | 1.70e-06| 1.70e-06|-4.6e-12 |-2.8e-06 |
    ## |Continental |air              |Continental |lake             |Carbofuran | 0.00e+00| 0.00e+00|-1.9e-14 |-2.8e-06 |
    ## |Continental |air              |Continental |naturalsoil      |Carbofuran | 8.00e-07| 8.00e-07|-2.1e-12 |-2.8e-06 |
    ## |Continental |air              |Continental |othersoil        |Carbofuran | 3.00e-07| 3.00e-07|-7.7e-13 |-2.8e-06 |
    ## |Continental |air              |Continental |river            |Carbofuran | 1.00e-07| 1.00e-07|-2.1e-13 |-2.8e-06 |
    ## |Continental |air              |Continental |sea              |Carbofuran | 3.00e-06| 3.00e-06|-8.2e-12 |-2.8e-06 |
    ## |Moderate    |air              |Moderate    |naturalsoil      |Carbofuran | 2.90e-06| 2.90e-06|-7.8e-12 |-2.7e-06 |
    ## |Moderate    |air              |Moderate    |sea              |Carbofuran | 2.90e-06| 2.90e-06|-7.8e-12 |-2.7e-06 |
    ## |Regional    |air              |Regional    |agriculturalsoil |Carbofuran | 3.60e-06| 3.60e-06|-1.2e-11 |-3.2e-06 |
    ## |Regional    |air              |Regional    |lake             |Carbofuran | 0.00e+00| 0.00e+00|-4.8e-14 |-3.2e-06 |
    ## |Regional    |air              |Regional    |naturalsoil      |Carbofuran | 1.60e-06| 1.60e-06|-5.2e-12 |-3.2e-06 |
    ## |Regional    |air              |Regional    |othersoil        |Carbofuran | 6.00e-07| 6.00e-07|-1.9e-12 |-3.2e-06 |
    ## |Regional    |air              |Regional    |river            |Carbofuran | 2.00e-07| 2.00e-07|-5.3e-13 |-3.2e-06 |
    ## |Regional    |air              |Regional    |sea              |Carbofuran | 0.00e+00| 0.00e+00|-8.4e-14 |-3.2e-06 |
    ## |Tropic      |air              |Tropic      |naturalsoil      |Carbofuran | 1.70e-06| 1.70e-06|-1.2e-11 |-6.7e-06 |
    ## |Tropic      |air              |Tropic      |sea              |Carbofuran | 4.10e-06| 4.10e-06|-2.7e-11 |-6.7e-06 |
    ## |Arctic      |naturalsoil      |Arctic      |naturalsoil      |Carbofuran | 0.00e+00| 0.00e+00|-8.1e-24 |-7.3e-14 |
    ## |Continental |agriculturalsoil |Continental |agriculturalsoil |Carbofuran | 0.00e+00| 0.00e+00|-1.9e-22 |-1.3e-12 |
    ## |Continental |naturalsoil      |Continental |naturalsoil      |Carbofuran | 0.00e+00| 0.00e+00|-4.2e-22 |-1.3e-12 |
    ## |Continental |othersoil        |Continental |othersoil        |Carbofuran | 0.00e+00| 0.00e+00|-4.2e-22 |-1.3e-12 |
    ## |Moderate    |naturalsoil      |Moderate    |naturalsoil      |Carbofuran | 0.00e+00| 0.00e+00|-4.2e-22 |-1.3e-12 |
    ## |Regional    |agriculturalsoil |Regional    |agriculturalsoil |Carbofuran | 0.00e+00| 0.00e+00|-1.9e-22 |-1.3e-12 |
    ## |Regional    |naturalsoil      |Regional    |naturalsoil      |Carbofuran | 0.00e+00| 0.00e+00|-4.2e-22 |-1.3e-12 |
    ## |Regional    |othersoil        |Regional    |othersoil        |Carbofuran | 0.00e+00| 0.00e+00|-4.2e-22 |-1.3e-12 |
    ## |Tropic      |naturalsoil      |Tropic      |naturalsoil      |Carbofuran | 0.00e+00| 0.00e+00|-3.5e-21 |-6.1e-12 |
    ## |Arctic      |naturalsoil      |Arctic      |sea              |Carbofuran | 0.00e+00| 0.00e+00|-1.2e-21 |-7.3e-14 |
    ## |Continental |agriculturalsoil |Continental |lake             |Carbofuran | 0.00e+00| 0.00e+00|-2.3e-21 |-1.3e-12 |
    ## |Continental |agriculturalsoil |Continental |river            |Carbofuran | 0.00e+00| 0.00e+00|-2.6e-20 |-1.3e-12 |
    ## |Continental |naturalsoil      |Continental |lake             |Carbofuran | 0.00e+00| 0.00e+00|-5.2e-21 |-1.3e-12 |
    ## |Continental |naturalsoil      |Continental |river            |Carbofuran | 0.00e+00| 0.00e+00|-5.7e-20 |-1.3e-12 |
    ## |Continental |othersoil        |Continental |lake             |Carbofuran | 0.00e+00| 0.00e+00|-5.2e-21 |-1.3e-12 |
    ## |Continental |othersoil        |Continental |river            |Carbofuran | 0.00e+00| 0.00e+00|-5.7e-20 |-1.3e-12 |
    ## |Moderate    |naturalsoil      |Moderate    |sea              |Carbofuran | 0.00e+00| 0.00e+00|-6.2e-20 |-1.3e-12 |
    ## |Regional    |agriculturalsoil |Regional    |lake             |Carbofuran | 0.00e+00| 0.00e+00|-2.3e-21 |-1.3e-12 |
    ## |Regional    |agriculturalsoil |Regional    |river            |Carbofuran | 0.00e+00| 0.00e+00|-2.6e-20 |-1.3e-12 |
    ## |Regional    |naturalsoil      |Regional    |lake             |Carbofuran | 0.00e+00| 0.00e+00|-5.2e-21 |-1.3e-12 |
    ## |Regional    |naturalsoil      |Regional    |river            |Carbofuran | 0.00e+00| 0.00e+00|-5.7e-20 |-1.3e-12 |
    ## |Regional    |othersoil        |Regional    |lake             |Carbofuran | 0.00e+00| 0.00e+00|-5.2e-21 |-1.3e-12 |
    ## |Regional    |othersoil        |Regional    |river            |Carbofuran | 0.00e+00| 0.00e+00|-5.7e-20 |-1.3e-12 |
    ## |Tropic      |naturalsoil      |Tropic      |sea              |Carbofuran | 1.00e-07| 1.00e-07|-5.2e-19 |-6.1e-12 |
    ## |Arctic      |naturalsoil      |Arctic      |air              |Carbofuran | 0.00e+00| 0.00e+00|9.7e-15  |6.2e-04  |
    ## |Arctic      |sea              |Arctic      |air              |Carbofuran | 0.00e+00| 0.00e+00|4.4e-17  |6.2e-04  |
    ## |Continental |agriculturalsoil |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|8.1e-14  |5.5e-04  |
    ## |Continental |lake             |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|8.0e-16  |5.5e-04  |
    ## |Continental |naturalsoil      |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|1.8e-13  |5.5e-04  |
    ## |Continental |othersoil        |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|1.8e-13  |5.5e-04  |
    ## |Continental |river            |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|2.7e-14  |5.5e-04  |
    ## |Continental |sea              |Continental |air              |Carbofuran | 0.00e+00| 0.00e+00|4.0e-16  |5.5e-04  |
    ## |Moderate    |naturalsoil      |Moderate    |air              |Carbofuran | 0.00e+00| 0.00e+00|1.8e-13  |5.5e-04  |
    ## |Moderate    |sea              |Moderate    |air              |Carbofuran | 0.00e+00| 0.00e+00|8.0e-16  |5.5e-04  |
    ## |Regional    |agriculturalsoil |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|8.1e-14  |5.5e-04  |
    ## |Regional    |lake             |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|8.0e-16  |5.5e-04  |
    ## |Regional    |naturalsoil      |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|1.8e-13  |5.5e-04  |
    ## |Regional    |othersoil        |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|1.8e-13  |5.5e-04  |
    ## |Regional    |river            |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|2.7e-14  |5.5e-04  |
    ## |Regional    |sea              |Regional    |air              |Carbofuran | 0.00e+00| 0.00e+00|8.0e-15  |5.5e-04  |
    ## |Tropic      |naturalsoil      |Tropic      |air              |Carbofuran | 0.00e+00| 0.00e+00|8.1e-13  |5.1e-04  |
    ## |Tropic      |sea              |Tropic      |air              |Carbofuran | 0.00e+00| 0.00e+00|3.6e-15  |5.1e-04  |
    ## [1] "No differences found for  substances"
    ## [1] "No differences found for base substances"

![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart     |toScale     |toSubCompart       |Substance         |   k_Old|   k_New|diff     |rel_diff |
    ## |:-----------|:------------------|:-----------|:------------------|:-----------------|-------:|-------:|:--------|:--------|
    ## |Arctic      |air                |Arctic      |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|5.8e-23  |2.0e-09  |
    ## |Arctic      |air                |Arctic      |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.3e-22  |2.0e-09  |
    ## |Arctic      |deepocean          |Arctic      |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.5e-22  |7.0e-11  |
    ## |Continental |air                |Continental |agriculturalsoil   |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.4e-21  |3.5e-09  |
    ## |Continental |air                |Continental |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.0e-22  |3.5e-09  |
    ## |Continental |air                |Continental |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.9e-21  |3.5e-09  |
    ## |Continental |air                |Continental |othersoil          |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.1e-21  |3.5e-09  |
    ## |Continental |air                |Continental |river              |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.1e-21  |3.5e-09  |
    ## |Continental |air                |Continental |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.3e-20  |3.5e-09  |
    ## |Continental |lake               |Continental |lakesediment       |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|9.7e-22  |3.5e-12  |
    ## |Continental |river              |Continental |freshwatersediment |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|9.6e-19  |1.0e-10  |
    ## |Continental |sea                |Continental |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|9.7e-21  |7.0e-11  |
    ## |Moderate    |air                |Moderate    |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.1e-20  |3.5e-09  |
    ## |Moderate    |air                |Moderate    |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.2e-20  |3.5e-09  |
    ## |Moderate    |deepocean          |Moderate    |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.5e-22  |7.0e-11  |
    ## |Regional    |air                |Regional    |agriculturalsoil   |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.3e-20  |3.5e-09  |
    ## |Regional    |air                |Regional    |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.1e-22  |3.5e-09  |
    ## |Regional    |air                |Regional    |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|5.9e-21  |3.5e-09  |
    ## |Regional    |air                |Regional    |othersoil          |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.2e-21  |3.5e-09  |
    ## |Regional    |air                |Regional    |river              |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.3e-21  |3.5e-09  |
    ## |Regional    |air                |Regional    |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.7e-22  |3.5e-09  |
    ## |Regional    |lake               |Regional    |lakesediment       |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|9.7e-22  |3.5e-12  |
    ## |Regional    |river              |Regional    |freshwatersediment |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|9.6e-19  |1.0e-10  |
    ## |Regional    |sea                |Regional    |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.9e-19  |7.0e-11  |
    ## |Tropic      |air                |Tropic      |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.9e-19  |3.5e-08  |
    ## |Tropic      |air                |Tropic      |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.1e-18  |3.5e-08  |
    ## |Tropic      |deepocean          |Tropic      |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.5e-22  |7.0e-11  |
    ## |Arctic      |air                |Arctic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|7.8e-21  |2.0e-09  |
    ## |Arctic      |deepocean          |Arctic      |deepocean          |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.3e-18  |7.0e-11  |
    ## |Arctic      |sea                |Arctic      |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.3e-18  |7.0e-11  |
    ## |Continental |air                |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-18  |3.5e-09  |
    ## |Continental |lake               |Continental |lake               |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|7.6e-19  |3.5e-12  |
    ## |Continental |river              |Continental |river              |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|2.3e-17  |1.0e-10  |
    ## |Continental |sea                |Continental |sea                |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|1.5e-17  |7.0e-11  |
    ## |Moderate    |air                |Moderate    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-18  |3.5e-09  |
    ## |Moderate    |deepocean          |Moderate    |deepocean          |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|1.5e-17  |7.0e-11  |
    ## |Moderate    |sea                |Moderate    |sea                |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|1.5e-17  |7.0e-11  |
    ## |Regional    |air                |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-18  |3.5e-09  |
    ## |Regional    |lake               |Regional    |lake               |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|7.6e-19  |3.5e-12  |
    ## |Regional    |river              |Regional    |river              |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|2.3e-17  |1.0e-10  |
    ## |Regional    |sea                |Regional    |sea                |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|1.5e-17  |7.0e-11  |
    ## |Tropic      |air                |Tropic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.6e-16  |3.5e-08  |
    ## |Tropic      |deepocean          |Tropic      |deepocean          |PHENYLEPHRINE HCL | 5.0e-07| 5.0e-07|3.8e-17  |7.0e-11  |
    ## |Tropic      |sea                |Tropic      |sea                |PHENYLEPHRINE HCL | 5.0e-07| 5.0e-07|3.8e-17  |7.0e-11  |
    ## |Arctic      |air                |Arctic      |naturalsoil        |PHENYLEPHRINE HCL | 3.2e-06| 3.2e-06|1.4e-20  |4.5e-15  |
    ## |Arctic      |air                |Arctic      |sea                |PHENYLEPHRINE HCL | 4.8e-06| 4.8e-06|2.1e-20  |4.4e-15  |
    ## |Continental |air                |Continental |agriculturalsoil   |PHENYLEPHRINE HCL | 2.3e-06| 2.3e-06|-8.8e-20 |-3.9e-14 |
    ## |Continental |air                |Continental |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-3.7e-22 |-3.9e-14 |
    ## |Continental |air                |Continental |naturalsoil        |PHENYLEPHRINE HCL | 1.0e-06| 1.0e-06|-4.0e-20 |-3.9e-14 |
    ## |Continental |air                |Continental |othersoil          |PHENYLEPHRINE HCL | 4.0e-07| 4.0e-07|-1.5e-20 |-3.9e-14 |
    ## |Continental |air                |Continental |river              |PHENYLEPHRINE HCL | 1.0e-07| 1.0e-07|-4.0e-21 |-3.9e-14 |
    ## |Continental |air                |Continental |sea                |PHENYLEPHRINE HCL | 4.0e-06| 4.0e-06|-1.6e-19 |-3.9e-14 |
    ## |Moderate    |air                |Moderate    |naturalsoil        |PHENYLEPHRINE HCL | 4.0e-06| 4.0e-06|-1.6e-19 |-4.1e-14 |
    ## |Moderate    |air                |Moderate    |sea                |PHENYLEPHRINE HCL | 4.0e-06| 4.0e-06|-1.6e-19 |-4.1e-14 |
    ## |Regional    |air                |Regional    |agriculturalsoil   |PHENYLEPHRINE HCL | 4.1e-06| 4.1e-06|-3.6e-20 |-8.9e-15 |
    ## |Regional    |air                |Regional    |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.5e-22 |-8.9e-15 |
    ## |Regional    |air                |Regional    |naturalsoil        |PHENYLEPHRINE HCL | 1.8e-06| 1.8e-06|-1.7e-20 |-8.9e-15 |
    ## |Regional    |air                |Regional    |othersoil          |PHENYLEPHRINE HCL | 7.0e-07| 7.0e-07|-6.1e-21 |-9.0e-15 |
    ## |Regional    |air                |Regional    |river              |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|-1.7e-21 |-8.9e-15 |
    ## |Regional    |air                |Regional    |sea                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-2.6e-22 |-8.9e-15 |
    ## |Tropic      |air                |Tropic      |naturalsoil        |PHENYLEPHRINE HCL | 2.4e-06| 2.4e-06|-1.3e-17 |-5.4e-12 |
    ## |Tropic      |air                |Tropic      |sea                |PHENYLEPHRINE HCL | 5.7e-06| 5.7e-06|-3.0e-17 |-5.4e-12 |
    ## |Arctic      |marinesediment     |Arctic      |deepocean          |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.8e-12  |2.5e-06  |
    ## |Continental |freshwatersediment |Continental |river              |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.2e-12  |2.0e-06  |
    ## |Continental |lakesediment       |Continental |lake               |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.2e-12  |2.0e-06  |
    ## |Continental |marinesediment     |Continental |sea                |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.8e-12  |2.5e-06  |
    ## |Moderate    |marinesediment     |Moderate    |deepocean          |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.8e-12  |2.5e-06  |
    ## |Regional    |freshwatersediment |Regional    |river              |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.2e-12  |2.0e-06  |
    ## |Regional    |lakesediment       |Regional    |lake               |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.2e-12  |2.0e-06  |
    ## |Regional    |marinesediment     |Regional    |sea                |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.8e-12  |2.5e-06  |
    ## |Tropic      |marinesediment     |Tropic      |deepocean          |PHENYLEPHRINE HCL | 1.1e-06| 1.1e-06|2.8e-12  |2.5e-06  |
    ## |Arctic      |naturalsoil        |Arctic      |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-14  |8.8e-06  |
    ## |Continental |agriculturalsoil   |Continental |agriculturalsoil   |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.9e-14  |9.0e-06  |
    ## |Continental |naturalsoil        |Continental |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.0e-14  |8.8e-06  |
    ## |Continental |othersoil          |Continental |othersoil          |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.1e-14  |9.0e-06  |
    ## |Moderate    |naturalsoil        |Moderate    |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.0e-14  |8.8e-06  |
    ## |Regional    |agriculturalsoil   |Regional    |agriculturalsoil   |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.9e-14  |9.0e-06  |
    ## |Regional    |naturalsoil        |Regional    |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.0e-14  |8.8e-06  |
    ## |Regional    |othersoil          |Regional    |othersoil          |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|4.1e-14  |9.0e-06  |
    ## |Tropic      |naturalsoil        |Tropic      |naturalsoil        |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|7.4e-14  |8.8e-06  |
    ## |Arctic      |naturalsoil        |Arctic      |sea                |PHENYLEPHRINE HCL | 2.0e-07| 2.0e-07|2.1e-12  |8.8e-06  |
    ## |Continental |agriculturalsoil   |Continental |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.3e-13  |9.0e-06  |
    ## |Continental |agriculturalsoil   |Continental |river              |PHENYLEPHRINE HCL | 3.0e-07| 3.0e-07|2.5e-12  |9.0e-06  |
    ## |Continental |naturalsoil        |Continental |lake               |PHENYLEPHRINE HCL | 1.0e-07| 1.0e-07|5.0e-13  |8.8e-06  |
    ## |Continental |naturalsoil        |Continental |river              |PHENYLEPHRINE HCL | 6.0e-07| 6.0e-07|5.4e-12  |8.8e-06  |
    ## |Continental |othersoil          |Continental |lake               |PHENYLEPHRINE HCL | 1.0e-07| 1.0e-07|5.1e-13  |9.0e-06  |
    ## |Continental |othersoil          |Continental |river              |PHENYLEPHRINE HCL | 6.0e-07| 6.0e-07|5.6e-12  |9.0e-06  |
    ## |Moderate    |naturalsoil        |Moderate    |sea                |PHENYLEPHRINE HCL | 7.0e-07| 7.0e-07|5.9e-12  |8.8e-06  |
    ## |Regional    |agriculturalsoil   |Regional    |lake               |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|2.3e-13  |9.0e-06  |
    ## |Regional    |agriculturalsoil   |Regional    |river              |PHENYLEPHRINE HCL | 3.0e-07| 3.0e-07|2.5e-12  |9.0e-06  |
    ## |Regional    |naturalsoil        |Regional    |lake               |PHENYLEPHRINE HCL | 1.0e-07| 1.0e-07|5.0e-13  |8.8e-06  |
    ## |Regional    |naturalsoil        |Regional    |river              |PHENYLEPHRINE HCL | 6.0e-07| 6.0e-07|5.4e-12  |8.8e-06  |
    ## |Regional    |othersoil          |Regional    |lake               |PHENYLEPHRINE HCL | 1.0e-07| 1.0e-07|5.1e-13  |9.0e-06  |
    ## |Regional    |othersoil          |Regional    |river              |PHENYLEPHRINE HCL | 6.0e-07| 6.0e-07|5.6e-12  |9.0e-06  |
    ## |Tropic      |naturalsoil        |Tropic      |sea                |PHENYLEPHRINE HCL | 1.3e-06| 1.3e-06|1.1e-11  |8.8e-06  |
    ## |Arctic      |deepocean          |Arctic      |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-6.9e-19 |-6.5e-05 |
    ## |Continental |lake               |Continental |lakesediment       |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.0e-18 |-1.4e-04 |
    ## |Continental |river              |Continental |freshwatersediment |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.0e-15 |-1.4e-04 |
    ## |Continental |sea                |Continental |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.0e-17 |-6.5e-05 |
    ## |Moderate    |deepocean          |Moderate    |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-6.9e-19 |-6.5e-05 |
    ## |Regional    |lake               |Regional    |lakesediment       |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.0e-18 |-1.4e-04 |
    ## |Regional    |river              |Regional    |freshwatersediment |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-1.0e-15 |-1.4e-04 |
    ## |Regional    |sea                |Regional    |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-2.1e-16 |-6.5e-05 |
    ## |Tropic      |deepocean          |Tropic      |marinesediment     |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|-6.9e-19 |-6.5e-05 |
    ## |Arctic      |naturalsoil        |Arctic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.6e-24  |8.8e-06  |
    ## |Arctic      |sea                |Arctic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.4e-33  |7.0e-11  |
    ## |Continental |agriculturalsoil   |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.2e-23  |9.0e-06  |
    ## |Continental |lake               |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.7e-32  |3.5e-12  |
    ## |Continental |naturalsoil        |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-22  |8.8e-06  |
    ## |Continental |othersoil          |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-22  |9.0e-06  |
    ## |Continental |river              |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.7e-29  |1.0e-10  |
    ## |Continental |sea                |Continental |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.5e-31  |7.0e-11  |
    ## |Moderate    |naturalsoil        |Moderate    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-22  |8.8e-06  |
    ## |Moderate    |sea                |Moderate    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.0e-31  |7.0e-11  |
    ## |Regional    |agriculturalsoil   |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|6.2e-23  |9.0e-06  |
    ## |Regional    |lake               |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.7e-32  |3.5e-12  |
    ## |Regional    |naturalsoil        |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-22  |8.8e-06  |
    ## |Regional    |othersoil          |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-22  |9.0e-06  |
    ## |Regional    |river              |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.7e-29  |1.0e-10  |
    ## |Regional    |sea                |Regional    |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.0e-30  |7.0e-11  |
    ## |Tropic      |naturalsoil        |Tropic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|1.4e-21  |8.8e-06  |
    ## |Tropic      |sea                |Tropic      |air                |PHENYLEPHRINE HCL | 0.0e+00| 0.0e+00|3.1e-30  |7.0e-11  |
    ## [1] "No differences found for metal substances"

![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](Comparison-plasticFADE-degradation_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->

    ## 
    ## 
    ## |fromScale   |fromSubCompart     |toScale     |toSubCompart       |Substance    | k_Old| k_New|diff    |rel_diff |
    ## |:-----------|:------------------|:-----------|:------------------|:------------|-----:|-----:|:-------|:--------|
    ## |Arctic      |deepocean          |Arctic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Arctic      |deepocean          |Arctic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Arctic      |deepocean          |Arctic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Arctic      |marinesediment     |Arctic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Arctic      |marinesediment     |Arctic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Arctic      |marinesediment     |Arctic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Arctic      |naturalsoil        |Arctic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Arctic      |naturalsoil        |Arctic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Arctic      |naturalsoil        |Arctic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Arctic      |sea                |Arctic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Arctic      |sea                |Arctic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Arctic      |sea                |Arctic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |agriculturalsoil   |Continental |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |agriculturalsoil   |Continental |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |agriculturalsoil   |Continental |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |freshwatersediment |Continental |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |freshwatersediment |Continental |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |freshwatersediment |Continental |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |lake               |Continental |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |lake               |Continental |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |lake               |Continental |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |lakesediment       |Continental |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |lakesediment       |Continental |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |lakesediment       |Continental |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |marinesediment     |Continental |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |marinesediment     |Continental |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |marinesediment     |Continental |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Continental |naturalsoil        |Continental |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |naturalsoil        |Continental |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |naturalsoil        |Continental |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |othersoil          |Continental |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |othersoil          |Continental |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |othersoil          |Continental |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Continental |river              |Continental |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |river              |Continental |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |river              |Continental |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |sea                |Continental |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |sea                |Continental |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Continental |sea                |Continental |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |deepocean          |Moderate    |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |deepocean          |Moderate    |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |deepocean          |Moderate    |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |marinesediment     |Moderate    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Moderate    |marinesediment     |Moderate    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Moderate    |marinesediment     |Moderate    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Moderate    |naturalsoil        |Moderate    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Moderate    |naturalsoil        |Moderate    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Moderate    |naturalsoil        |Moderate    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Moderate    |sea                |Moderate    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |sea                |Moderate    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Moderate    |sea                |Moderate    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |agriculturalsoil   |Regional    |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |agriculturalsoil   |Regional    |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |agriculturalsoil   |Regional    |agriculturalsoil   |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |freshwatersediment |Regional    |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |freshwatersediment |Regional    |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |freshwatersediment |Regional    |freshwatersediment |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |lake               |Regional    |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |lake               |Regional    |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |lake               |Regional    |lake               |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |lakesediment       |Regional    |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |lakesediment       |Regional    |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |lakesediment       |Regional    |lakesediment       |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |marinesediment     |Regional    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |marinesediment     |Regional    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |marinesediment     |Regional    |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Regional    |naturalsoil        |Regional    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |naturalsoil        |Regional    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |naturalsoil        |Regional    |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |othersoil          |Regional    |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |othersoil          |Regional    |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |othersoil          |Regional    |othersoil          |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Regional    |river              |Regional    |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |river              |Regional    |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |river              |Regional    |river              |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |sea                |Regional    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |sea                |Regional    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Regional    |sea                |Regional    |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |deepocean          |Tropic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |deepocean          |Tropic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |deepocean          |Tropic      |deepocean          |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |marinesediment     |Tropic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Tropic      |marinesediment     |Tropic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Tropic      |marinesediment     |Tropic      |marinesediment     |microplastic | 0e+00| 0e+00|2.2e-08 |5e-01    |
    ## |Tropic      |naturalsoil        |Tropic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Tropic      |naturalsoil        |Tropic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Tropic      |naturalsoil        |Tropic      |naturalsoil        |microplastic | 3e-07| 6e-07|3.0e-07 |5e-01    |
    ## |Tropic      |sea                |Tropic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |sea                |Tropic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |
    ## |Tropic      |sea                |Tropic      |sea                |microplastic | 0e+00| 1e-07|4.2e-08 |5e-01    |

The differences found for neutral and acidic substances are related to
rounding differences between the Substances.csv in the development
branch and the plastic_fate_degradation branch.

The updates made to the degradation rate in the plastic_fade_branch
cause the changes visible in the plot with mean relative difference for
particulates; only k_Degradation rates were changed. All degradation
rates are 50% higher than before.
