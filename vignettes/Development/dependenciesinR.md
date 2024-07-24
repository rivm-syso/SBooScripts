Dependencies in R
================
Valerie de Rijk
2024-07-24

## Dependencies of R functions

Just like in Excel, we can trace the dependencies of processes and
variables. For this, we can use the function World\$nodelist. This
returns all calculated variables in SBoo and they’re required
parameters. In this vignette, we demonstrate both the dependencies for a
process module (k_Adsorption and AreaSea). You can use this technique to
generate plots like these for all calculated parameters.

### Generating nodes

``` r
source("baseScripts/initWorld_onlyMolec.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.0     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
    ## 
    ## Attaching package: 'ggdag'
    ## 
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter
    ## 
    ## 
    ## 
    ## Attaching package: 'rlang'
    ## 
    ## 
    ## The following objects are masked from 'package:purrr':
    ## 
    ##     %@%, flatten, flatten_chr, flatten_dbl, flatten_int, flatten_lgl,
    ##     flatten_raw, invoke, splice
    ## 
    ## 
    ## Joining with `by = join_by(Matrix)`
    ## Joining with `by = join_by(Compartment)`

``` r
allnodes <- World$nodelist
head(allnodes)
```

    ##           Calc     Params ModuleType
    ## 1 k_Adsorption    FRingas    Process
    ## 2 k_Adsorption      FRinw    Process
    ## 3 k_Adsorption    MTC_2sd    Process
    ## 4 k_Adsorption FRorig_spw    Process
    ## 5 k_Adsorption     MTC_2w    Process
    ## 6 k_Adsorption     MTC_2a    Process

``` r
filtered_nodelist <- World$nodelist[World$nodelist$Calc == "k_Adsorption", ]
filtered_nodelist_sea <- World$nodelist[World$nodelist$Calc == "AreaSea",]
print(filtered_nodelist)
```

    ##            Calc         Params ModuleType
    ## 1  k_Adsorption        FRingas    Process
    ## 2  k_Adsorption          FRinw    Process
    ## 3  k_Adsorption        MTC_2sd    Process
    ## 4  k_Adsorption     FRorig_spw    Process
    ## 5  k_Adsorption         MTC_2w    Process
    ## 6  k_Adsorption         MTC_2a    Process
    ## 7  k_Adsorption         MTC_2s    Process
    ## 8  k_Adsorption         FRorig    Process
    ## 9  k_Adsorption        Kacompw    Process
    ## 10 k_Adsorption        Kscompw    Process
    ## 11 k_Adsorption         Matrix    Process
    ## 12 k_Adsorption   VertDistance    Process
    ## 13 k_Adsorption       AreaLand    Process
    ## 14 k_Adsorption        AreaSea    Process
    ## 15 k_Adsorption           Area    Process
    ## 16 k_Adsorption SubCompartName    Process
    ## 17 k_Adsorption      ScaleName    Process
    ## 18 k_Adsorption           Test    Process

### k_Adsorption dependents

k_Adsorption is a great example of a process module that is dependent on
a significant amount of parameters.

``` r
NodeAsText <- paste(filtered_nodelist$Params, "->", filtered_nodelist$Calc)
AllNodesAsText <- do.call(paste, c(as.list(NodeAsText), list(sep = ";")))

# Create the DAG string
dag_string <- paste("dag{", AllNodesAsText, "}")

# Convert the string to a DAG object
dag <- dagitty::dagitty(dag_string)
tidy_dag <- tidy_dagitty(dag)



# Plot with customized node colors
ggdag(tidy_dag, text = FALSE) +
  theme_dag_blank() +  # Apply the default DAG theme
  geom_dag_node(aes(color = "black"), fill = "black", size = 25) +  # Customize node colors and size
  geom_dag_text(aes(label = name), size = 2, color = "white") +  # Customize node text size and color
  scale_fill_manual(values = "green") +  # Apply custom fill colors
  theme(
    plot.title = element_text(hjust = 0.5), 
    legend.position = "none"  # Remove the legend
  ) +
  labs(
    title = "Dependents of k_Adsorption"
  )
```

![](dependenciesinR_files/figure-gfm/World%20nodes-1.png)<!-- -->

### v_AreaSea dependents

As we can see below, v_AreaSea is dependent on way less parameters.

``` r
# Assuming filtered_nodelist_sea is a data frame and Params and Calc are columns in it
NodeAsText <- paste(filtered_nodelist_sea$Params, "->", filtered_nodelist_sea$Calc)

# Combine all nodes into a single string, separating them with ";"
AllNodesAsText <- do.call(paste, c(as.list(NodeAsText), list(sep = ";")))

# Create the DAG string
dag_string <- paste("dag{", AllNodesAsText, "}")

# Convert the string to a DAG object
dag <- dagitty::dagitty(dag_string)

# Convert the DAG object to a tidy format for plotting
tidy_dag <- tidy_dagitty(dag)

# Plot the DAG with customized aesthetics
ggdag(tidy_dag, text = FALSE) +
  theme_dag_blank() +  # Apply the default DAG theme
  geom_dag_node(aes(color = "black"), fill = "black", size = 25) +  # Customize node colors and size
  geom_dag_text(aes(label = name), size = 2, color = "white") +  # Customize node text size and color
  scale_fill_manual(values = "green") +  # Apply custom fill colors
  theme(
    plot.title = element_text(hjust = 0.5), 
    legend.position = "none"  # Remove the legend
  ) +
  labs(
    title = "Dependents of v_AreaSea"
  )
```

![](dependenciesinR_files/figure-gfm/v_AreaSea%20dependents-1.png)<!-- -->
