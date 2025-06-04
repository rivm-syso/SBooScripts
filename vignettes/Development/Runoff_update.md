Comparison runoff update
================
Anne Hids, Nadim Saadi
2025-05-27

# Explanation of update

The previous function for calculating the runoff rate for microplastics
was taken from SimpleBox4Plastics in MS Excel. It was noted that the
runoff rate was relatively high. Therefore, an interception rate
(kinterception) was added to the runoff rate, which represents the
particles being held back by vegetation on soil. This lowers the runoff
rate (Louvet et al. (in prep)).

# Change in k values for advection flows

<!-- TO DO: fetch development at a certain date instead of most recent version. This would ensure consequent outcomes of this comparison, no matter when the script is run. -->

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

    ## [1] "Already up to date."

Do the same for the new implementation.

    ## [1] "Already up to date."

## Compare the k values for each of the substances

As can be seen in the figures below, the new runoff rates for
microplastics and TRWP are about 34 times lower than in the previous
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

![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](Runoff_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->
