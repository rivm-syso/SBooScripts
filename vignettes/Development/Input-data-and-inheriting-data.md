Input Data and Inheriting data
================
Jaap Slootweg, Valerie de Rijk
2024-07-23

## Introduction

We implemented a modest mechanism of setting “defaults” for your data.
Through this mechanism you need to enter less (possibly redundant) row
of data. This vignette demonstrates how to set defaults, and how to
verify their application.

## Input data related to the 3 dimension

A crucial mechanism of SBoo is the consistent use of the the dimensions
(scale, subcompartment, species) as key fields in the data. The input
data is normally in one of tables with a key of the combinations of
these three. (Because of the intensive use of the dimensions, a variable
The3D is defined by the package)

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
The3D
```

    ## [1] "Scale"      "SubCompart" "Species"

``` r
for (m in 1:length(The3D)) {
  combies <- combn(The3D, m)
  print(apply(t(combies), 1, function(x){
    do.call(paste, as.list(c(x, "sheet", sep = "")))
  }))
}
```

    ## [1] "Scalesheet"      "SubCompartsheet" "Speciessheet"   
    ## [1] "ScaleSubCompartsheet"   "ScaleSpeciessheet"      "SubCompartSpeciessheet"
    ## [1] "ScaleSubCompartSpeciessheet"

## Defaults at initialisation

There are three input (csv-)files that automatically “translate” their
data to the normal data tables mentioned above: Matrixsheet,
Compartments and SpeciesCompartments which put their data into
Subcompartsheet, or SpeciesSubCompartments. In the following code the
original data is taken from the csv files, and the fetched data is from
the initialised “World” object.

The way this translation works is by the relation with SubCompartment,
which has the properties Matrix and Compartment:

``` r
merge(World$fetchData("Matrix"), World$fetchData("Compartment"))
```

    ##            SubCompart   Matrix Compartment
    ## 1    agriculturalsoil     soil        soil
    ## 2                 air      air         air
    ## 3          cloudwater    water         air
    ## 4           deepocean    water       water
    ## 5  freshwatersediment sediment    sediment
    ## 6                lake    water       water
    ## 7        lakesediment sediment    sediment
    ## 8      marinesediment sediment    sediment
    ## 9         naturalsoil     soil        soil
    ## 10          othersoil     soil        soil
    ## 11              river    water       water
    ## 12                sea    water       water

## Inherit defaults

The other mechanism in SBoo to avoid redundacy in data is the doInherit
method. For this you need two variables in your data, the fromData and
the toData parameters.

``` r
World$doInherit
```

    ## function (fromData, toData) 
    ## {
    ##     private$DoInherit(fromData, toData)
    ## }
    ## <environment: 0x5652416f4688>

The fromData can be in 1) CONSTANTS 2) Matrix or 3) a dimension which is
part of the dimensions of the toData. We demonstrate this with two
examples.

``` r
World$fetchData("DefaultpH")
```

    ## [1] 7

``` r
World$fetchData("pH")
```

    ##            SubCompart pH
    ## 1    agriculturalsoil  7
    ## 2                 air  3
    ## 4           deepocean  8
    ## 5  freshwatersediment  7
    ## 6                lake  7
    ## 7        lakesediment  7
    ## 8      marinesediment  8
    ## 9         naturalsoil  5
    ## 10          othersoil  7
    ## 11              river  7
    ## 12                sea  8

``` r
World$doInherit("DefaultpH","pH")
```

    ## Joining with `by = join_by(SubCompart)`

    ##            SubCompart old_pH pH
    ## 1    agriculturalsoil      7  7
    ## 2                 air      3  3
    ## 3          cloudwater     NA  7
    ## 4           deepocean      8  8
    ## 5  freshwatersediment      7  7
    ## 6                lake      7  7
    ## 7        lakesediment      7  7
    ## 8      marinesediment      8  8
    ## 9         naturalsoil      5  5
    ## 10          othersoil      7  7
    ## 11              river      7  7
    ## 12                sea      8  8

``` r
World$fetchData("DefaultNETsedrate")
```

    ##    SubCompart DefaultNETsedrate
    ## 4   deepocean          6.34e-14
    ## 6        lake          8.62e-11
    ## 11      river          8.62e-11
    ## 12        sea          2.74e-11

``` r
World$fetchData("NETsedrate")
```

    ##          Scale SubCompart NETsedrate
    ## 4       Arctic  deepocean   6.30e-14
    ## 18 Continental       lake   8.60e-11
    ## 23 Continental      river   8.60e-11
    ## 24 Continental        sea   2.74e-11
    ## 28    Moderate  deepocean   8.95e-14
    ## 42    Regional       lake   8.70e-11
    ## 47    Regional      river   8.70e-11
    ## 48    Regional        sea   2.70e-11
    ## 52      Tropic  deepocean   6.30e-14

``` r
World$doInherit(fromData = "DefaultNETsedrate", toData = "NETsedrate")
```

    ## Joining with `by = join_by(Scale, SubCompart)`
    ## Joining with `by = join_by(SubCompart)`

    ##          Scale SubCompart old_NETsedrate NETsedrate
    ## 1       Arctic  deepocean       6.30e-14   6.30e-14
    ## 2       Arctic       lake             NA   8.62e-11
    ## 3       Arctic      river             NA   8.62e-11
    ## 4       Arctic        sea             NA   2.74e-11
    ## 5  Continental  deepocean             NA   6.34e-14
    ## 6  Continental       lake       8.60e-11   8.60e-11
    ## 7  Continental      river       8.60e-11   8.60e-11
    ## 8  Continental        sea       2.74e-11   2.74e-11
    ## 9     Moderate  deepocean       8.95e-14   8.95e-14
    ## 10    Moderate       lake             NA   8.62e-11
    ## 11    Moderate      river             NA   8.62e-11
    ## 12    Moderate        sea             NA   2.74e-11
    ## 13    Regional  deepocean             NA   6.34e-14
    ## 14    Regional       lake       8.70e-11   8.70e-11
    ## 15    Regional      river       8.70e-11   8.70e-11
    ## 16    Regional        sea       2.70e-11   2.70e-11
    ## 17      Tropic  deepocean       6.30e-14   6.30e-14
    ## 18      Tropic       lake             NA   8.62e-11
    ## 19      Tropic      river             NA   8.62e-11
    ## 20      Tropic        sea             NA   2.74e-11
