Defaults
================
JS
2023-03-01

# Defaults

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
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.4.0     ✔ purrr   1.0.1
    ## ✔ tibble  3.1.8     ✔ dplyr   1.1.0
    ## ✔ tidyr   1.3.0     ✔ stringr 1.5.0
    ## ✔ readr   2.1.3     ✔ forcats 1.0.0
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
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
    ## Joining with `by = join_by(sheet, row)`

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

``` r
Nrad <- read.csv("data/SpeciesCompartments.csv")
Nrad[Nrad$VarName == "NaturalRad",]
```

    ##      VarName Compartment Species   Waarde SB4N_name Unit
    ## 1 NaturalRad         air   Large 9.00e-07   RadCP.a    m
    ## 2 NaturalRad    sediment   Large 1.28e-04  RadFP.sd    m
    ## 3 NaturalRad    sediment   Small 1.50e-07  RadNC.sd    m
    ## 4 NaturalRad        soil   Large 1.28e-04   RadFP.s    m
    ## 5 NaturalRad        soil   Small 1.50e-07   RadNC.s    m
    ## 6 NaturalRad       water   Large 3.00e-06  RadSPM.w    m
    ## 7 NaturalRad       water   Small 1.50e-07   RadNC.w    m

``` r
World$fetchData("NaturalRad")
```

    ##            SubCompart Species NaturalRad
    ## 1                 air   Large   9.00e-07
    ## 2          cloudwater   Large   9.00e-07
    ## 3  freshwatersediment   Large   1.28e-04
    ## 4  freshwatersediment   Small   1.50e-07
    ## 5        lakesediment   Large   1.28e-04
    ## 6        lakesediment   Small   1.50e-07
    ## 7      marinesediment   Large   1.28e-04
    ## 8      marinesediment   Small   1.50e-07
    ## 9    agriculturalsoil   Large   1.28e-04
    ## 10   agriculturalsoil   Small   1.50e-07
    ## 11        naturalsoil   Large   1.28e-04
    ## 12        naturalsoil   Small   1.50e-07
    ## 13          othersoil   Large   1.28e-04
    ## 14          othersoil   Small   1.50e-07
    ## 15          deepocean   Large   3.00e-06
    ## 16          deepocean   Small   1.50e-07
    ## 17               lake   Large   3.00e-06
    ## 18               lake   Small   1.50e-07
    ## 19              river   Large   3.00e-06
    ## 20              river   Small   1.50e-07
    ## 21                sea   Large   3.00e-06
    ## 22                sea   Small   1.50e-07

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
    ## <environment: 0x558df2a462c0>

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

    ##        SubCompart pH
    ## 2      cloudwater  3
    ## 5  marinesediment  8
    ## 7     naturalsoil  5
    ## 9       deepocean  8
    ## 12            sea  8

``` r
World$doInherit("DefaultpH","pH")
```

    ## Joining with `by = join_by(SubCompart)`

    ##            SubCompart old_pH pH
    ## 1    agriculturalsoil     NA  7
    ## 2                 air     NA  7
    ## 3          cloudwater      3  3
    ## 4           deepocean      8  8
    ## 5  freshwatersediment     NA  7
    ## 6                lake     NA  7
    ## 7        lakesediment     NA  7
    ## 8      marinesediment      8  8
    ## 9         naturalsoil      5  5
    ## 10          othersoil     NA  7
    ## 11              river     NA  7
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

    ##       Scale SubCompart NETsedrate
    ## 11 Moderate  deepocean   8.95e-14

``` r
World$doInherit(fromData = "DefaultNETsedrate", toData = "NETsedrate")
```

    ## Joining with `by = join_by(Scale, SubCompart)`
    ## Joining with `by = join_by(SubCompart)`

    ##          Scale SubCompart old_NETsedrate NETsedrate
    ## 1       Arctic  deepocean             NA   6.34e-14
    ## 2       Arctic        sea             NA   2.74e-11
    ## 3  Continental       lake             NA   8.62e-11
    ## 4  Continental      river             NA   8.62e-11
    ## 5  Continental        sea             NA   2.74e-11
    ## 6     Moderate  deepocean       8.95e-14   8.95e-14
    ## 7     Moderate        sea             NA   2.74e-11
    ## 8     Regional       lake             NA   8.62e-11
    ## 9     Regional      river             NA   8.62e-11
    ## 10    Regional        sea             NA   2.74e-11
    ## 11      Tropic  deepocean             NA   6.34e-14
    ## 12      Tropic        sea             NA   2.74e-11
