Volume FRACtions of phases in subcompartments
================
2023-09-05

## Matrix parts of a sub-compartment

A Subcompartment has a main matrix(medium); for soils and sediment this
is “solids”. But both also contain water, and soil also contains a
fraction of air, as wel as water. These matrices play a part in the
exchange of substances. The fraction of the non-main matrices are in the
data, named subFRACw, subFRACa, and subFRACs. The main fraction of the
subcompartment is calculated as the remainder. All fractions are are
determined by three variable defining functions. For example for soils
and sediments:

## Use FRAC’s for

This generalisation is extended to the solids and water fractions in
air, formerly known as FRACears and FRACearw. FRACaers -\> FRACs for
air, FRACaerw -\> FRACw for air.

``` r
World$fetchData("FRACa")
```

    ##          Scale       SubCompart FRACa
    ## 5       Arctic      naturalsoil   0.2
    ## 7  Continental agriculturalsoil   0.2
    ## 14 Continental      naturalsoil   0.2
    ## 15 Continental        othersoil   0.2
    ## 22    Moderate      naturalsoil   0.2
    ## 24    Regional agriculturalsoil   0.2
    ## 31    Regional      naturalsoil   0.2
    ## 32    Regional        othersoil   0.2
    ## 39      Tropic      naturalsoil   0.2

``` r
World$fetchData("FRACs")
```

    ##          Scale SubCompart FRACs
    ## 1       Arctic        air 2e-11
    ## 8  Continental        air 2e-11
    ## 18    Moderate        air 2e-11
    ## 25    Regional        air 2e-11
    ## 35      Tropic        air 2e-11

``` r
World$fetchData("FRACw")
```

    ##          Scale         SubCompart FRACw
    ## 1       Arctic                air 2e-11
    ## 4       Arctic     marinesediment 8e-01
    ## 5       Arctic        naturalsoil 2e-01
    ## 7  Continental   agriculturalsoil 2e-01
    ## 8  Continental                air 2e-11
    ## 10 Continental freshwatersediment 8e-01
    ## 13 Continental     marinesediment 8e-01
    ## 14 Continental        naturalsoil 2e-01
    ## 15 Continental          othersoil 2e-01
    ## 18    Moderate                air 2e-11
    ## 21    Moderate     marinesediment 8e-01
    ## 22    Moderate        naturalsoil 2e-01
    ## 24    Regional   agriculturalsoil 2e-01
    ## 25    Regional                air 2e-11
    ## 27    Regional freshwatersediment 8e-01
    ## 30    Regional     marinesediment 8e-01
    ## 31    Regional        naturalsoil 2e-01
    ## 32    Regional          othersoil 2e-01
    ## 35      Tropic                air 2e-11
    ## 38      Tropic     marinesediment 8e-01
    ## 39      Tropic        naturalsoil 2e-01

``` r
Fs <- World$NewCalcVariable("FRACs")
World$CalcVar("FRACs")
```

    ##          Scale         SubCompart old_FRACs FRACs
    ## 1       Arctic                air     2e-11 2e-11
    ## 2       Arctic     marinesediment        NA 2e-01
    ## 3       Arctic        naturalsoil        NA 6e-01
    ## 4  Continental   agriculturalsoil        NA 6e-01
    ## 5  Continental                air     2e-11 2e-11
    ## 6  Continental freshwatersediment        NA 2e-01
    ## 7  Continental     marinesediment        NA 2e-01
    ## 8  Continental        naturalsoil        NA 6e-01
    ## 9  Continental          othersoil        NA 6e-01
    ## 10    Moderate                air     2e-11 2e-11
    ## 11    Moderate     marinesediment        NA 2e-01
    ## 12    Moderate        naturalsoil        NA 6e-01
    ## 13    Regional   agriculturalsoil        NA 6e-01
    ## 14    Regional                air     2e-11 2e-11
    ## 15    Regional freshwatersediment        NA 2e-01
    ## 16    Regional     marinesediment        NA 2e-01
    ## 17    Regional        naturalsoil        NA 6e-01
    ## 18    Regional          othersoil        NA 6e-01
    ## 19      Tropic                air     2e-11 2e-11
    ## 20      Tropic     marinesediment        NA 2e-01
    ## 21      Tropic        naturalsoil        NA 6e-01

An overview for the scale Regional. The NA are not calculated, but also
not needed in further calculations of the partitioning between these
phases.

``` r
allFrac <- Reduce(merge, list(World$fetchData("FRACa"), World$fetchData("FRACw"), World$fetchData("FRACs"))) %>%
  dplyr::filter(Scale == "Regional") %>%
  pivot_longer(c(FRACa, FRACw, FRACs))

allFrac <- full_join(as_tibble(World$fetchData("FRACa")),
                     as_tibble(World$fetchData("FRACw")), by = c("SubCompart","Scale")) |> 
  full_join(as_tibble(World$fetchData("FRACs"))) |> filter(Scale=="Regional") |> print()
```

    ## Joining with `by = join_by(Scale, SubCompart)`

    ## # A tibble: 6 × 5
    ##   Scale    SubCompart         FRACa         FRACw         FRACs
    ##   <chr>    <chr>              <dbl>         <dbl>         <dbl>
    ## 1 Regional agriculturalsoil     0.2 0.2           0.6          
    ## 2 Regional naturalsoil          0.2 0.2           0.6          
    ## 3 Regional othersoil            0.2 0.2           0.6          
    ## 4 Regional air                 NA   0.00000000002 0.00000000002
    ## 5 Regional freshwatersediment  NA   0.8           0.2          
    ## 6 Regional marinesediment      NA   0.8           0.2

## colloidal and suspended matter in waters

For solids in water SB distinguishes colloidal and suspended matter.
Therefore subFRACs for waters is not in the data; use the data for “COL”
and “SUSP” for these quantities. These quantities are not used to
calculate a “FRACw” for waters.

``` r
World$fetchData("COL")
```

    ## [1] 0.001

``` r
World$fetchData("SUSP")
```

    ##    SubCompart   SUSP
    ## 9   deepocean 0.0050
    ## 10       lake 0.0005
    ## 11      river 0.0150
    ## 12        sea 0.0050
