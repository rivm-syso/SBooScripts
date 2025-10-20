Comparison shape update
================
Nadim Saadi, Valerie de Rijk, Anne Hids, Joris Quik
2025-10-20

# Explanation of update

This explains the way we include drag of particles with shapes different
to a sphere.

Several processes which depend on the settling velocity now are
dependant on the Settling Velocity solver based on a specific Drag
method. The supported particle shapes can be found in section <u>3.2
Particle Properties</u> of the documentation.

The updated functions are:

- f_SetVelWater and v_SettlingVelocity

  - For which several functions are introduced or changed to cope with
    shape:

  - R/f_DragCoefficient.R

  - R/f_SetVelSolver.R

  - R/f_PerimeterParticle.R

  - R/f_SurfaceAreaParticle.R

  - R/f_Vol.R

  - R/v_rad_species.R

  - R/v_rho_species.R

- f_Grav.R and R/k_HeteroAgglomeration.wsd.R

  - In future shape could also be included for SPM, now still sphere
    assumed representative

- k_Resuspension due to the update of f_SetVelWater

- R/k_Sedimentation.R due to the update of f_SetVelWater

<!-- -->

    ## [1] "Directory: SBzips created."

    ## [1] "The SimpleBox model can be found in SimpleBox"

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

    ## [1] "kdis is missing, setting kdis = 0"

Do the same for the other implementation.

## Verification of previous and new implementation (Original drag method)

    ## [1] "k_CWscavenging"  "k_DryDeposition" "k_Sedimentation"

As can be seen in the figures below, the new rate constants for the
substances, 1-aminoanthraquinone, microplastic, nAg_10nm, TRWP, have a
negligible difference of max 1.1565065^{-5} % difference to the previous
version, related to processes: k_CWscavenging, k_DryDeposition,
k_Sedimentation. The figures below also show this and therefore this
verification of replicating the previous version with the new code is
complete.

``` r
all_diffs <- kaas_comparison |>
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

for(i in unique(all_diffs$Substance)){
  diffs_substance <- all_diffs |>
    filter(Substance == i)
  
  absdif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = diff)) + 
    geom_point() + 
    labs(
      title = "Difference between old and new k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),  
      panel.background = element_blank() 
    )
  
  print(absdif_plot)
  
  reldif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
    geom_point() + 
    labs(
      title = "Relative difference between old and new k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Relative difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  print(reldif_plot)
}
```

![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-7.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-8.png)<!-- -->

## Quantify changes for new drag method options

The Original and Bagheri drag method will be compared.

    ## [1] "kdis is missing, setting kdis = 0"

Change drag method and recalculate k values

    ## [1] "kdis is missing, setting kdis = 0"

    ## [1] "k_CWscavenging"            "k_DryDeposition"          
    ## [3] "k_HeteroAgglomeration.wsd" "k_Sedimentation"

As can be seen in the figures below, the new rate constants for the
substances, 1-aminoanthraquinone, microplastic, nAg_10nm, TRWP, have a
difference of max 51.2651154 % between the original and Bagheri drag
methods. This affects the k_CWscavenging, k_DryDeposition,
k_HeteroAgglomeration.wsd, k_Sedimentation processes.

``` r
all_diffs <- kaas_comparison |>
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

for(i in unique(all_diffs$Substance)){
  diffs_substance <- all_diffs |>
    filter(Substance == i)
  
  absdif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = diff)) + 
    geom_point() + 
    labs(
      title = "Difference between k's for originial and Bagheri's drag method",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),  
      panel.background = element_blank() 
    )
  
  print(absdif_plot)
  
  reldif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
    geom_point() + 
    labs(
      title = "Relative  between k's for originial and Bagheri's drag method",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Relative difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  print(reldif_plot)
}
```

![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-2.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-3.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-4.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-5.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-6.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-7.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/unnamed-chunk-4-8.png)<!-- -->

## Example for differently shaped particles

Change shapes based on substance data

Run SBoo for a sphere Using Bagheri Dragmethod.
<!--# TODO: Compare the new shapes to spheres with same volume to show the implications of using shapes. And doing this for different sizes. -->

``` r
substances <- read.csv("data/Substances.csv")
substances <- substances |>
  filter(str_detect(Substance, "^microplastic"))

this_kaas_shape <- data.frame()

for(substanceK in substances$Substance){
  
  substance <- substanceK
      source("baseScripts/initWorld.R")

  kaas <- World$kaas |>
    mutate(Substance = substance)
  
  this_kaas_shape <- rbind(this_kaas_shape, kaas)
}
```

All are calculated, but let’s check if the new microplastics_sphere (set
as Shortest_side) provides the same k’s as the default microplastic (set
as RadS).

    ## [1] "test passed, no changes in k's found"
