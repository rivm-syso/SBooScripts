Comparison runoff update
================
Anne Hids, Nadim Saadi, Joris Quik
2025-05-27

# Explanation of update

The previous function for calculating the runoff rate for microplastics
was taken from SimpleBox4Plastics in MS Excel. This function included
runoff and erosion. In this calculation it is assumed that all
microplastics are transported from soil compartments to water
compartments by runoff. In reality however, some of the microplastics
are trapped or slowed down by vegetation present on the soil.

To avoid overestimation of the runoff rate, an interception rate was
added. This rate represents the fraction of microplastics intercepted by
the vegetation on soil. The default value of kinterception is 0.9715,
which is the average between the interception at high, medium and low
density vegetation as found by Han et al. (2022)

This function is based on Louvet et al. (in prep).

Old function:

$(Runoff * f_CORRsoil(VertDistance, relevant_depth_s, penetration_depth_s)) / Volume * to.FracROWatComp$

New function:

$(Runoff * f_CORRsoil(VertDistance, relevant_depth_s, penetration_depth_s)) / Volume * to.FracROWatComp * (1-IntrcptFrac)$

# Change in k values for runoff flows

<!-- TO DO: fetch development at a certain date instead of most recent version. This would ensure consequent outcomes of this comparison, no matter when the script is run. -->

    ## [1] "Directory: SBzips created."

    ## [1] "The SimpleBox model can be found in SimpleBox"

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

Do the same for the other implementation.

## Compare the k values for each of the substances

As can be seen in the figures below, the new runoff rates for
microplastics and TRWP are about 3 times lower than in the previous
version. For other substances k_Runoff remains unchanged.

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
      title = "Difference between old and new runoff k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(size = 0.2, color = "gray90"),  
      panel.background = element_blank() 
    )
  
  print(absdif_plot)
  
  reldif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
    geom_point() + 
    labs(
      title = "Relative difference between old and new runoff k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Relative difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(size = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  print(reldif_plot)
}
```

![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](20250825_Plastics_Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->
