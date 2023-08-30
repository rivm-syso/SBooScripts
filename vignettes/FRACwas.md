Fractions of matrices in subcompartments
================
JS
2023-08-30

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
air, formerly known as FRears and FRearw. Note that the fraction of air
in air may appear as rounded to, but not equal to 1.0.

``` r
World$fetchData("FRACa")
```

    ##          Scale       SubCompart FRACa
    ## 5       Arctic      naturalsoil   0.2
    ## 8  Continental agriculturalsoil   0.2
    ## 15 Continental      naturalsoil   0.2
    ## 16 Continental        othersoil   0.2
    ## 23    Moderate      naturalsoil   0.2
    ## 26    Regional agriculturalsoil   0.2
    ## 33    Regional      naturalsoil   0.2
    ## 34    Regional        othersoil   0.2
    ## 41      Tropic      naturalsoil   0.2

``` r
World$fetchData("FRACw")
```

    ##          Scale         SubCompart FRACw
    ## 1       Arctic                air 2e-11
    ## 4       Arctic     marinesediment 8e-01
    ## 5       Arctic        naturalsoil 2e-01
    ## 8  Continental   agriculturalsoil 2e-01
    ## 9  Continental                air 2e-11
    ## 11 Continental freshwatersediment 8e-01
    ## 14 Continental     marinesediment 8e-01
    ## 15 Continental        naturalsoil 2e-01
    ## 16 Continental          othersoil 2e-01
    ## 19    Moderate                air 2e-11
    ## 22    Moderate     marinesediment 8e-01
    ## 23    Moderate        naturalsoil 2e-01
    ## 26    Regional   agriculturalsoil 2e-01
    ## 27    Regional                air 2e-11
    ## 29    Regional freshwatersediment 8e-01
    ## 32    Regional     marinesediment 8e-01
    ## 33    Regional        naturalsoil 2e-01
    ## 34    Regional          othersoil 2e-01
    ## 37      Tropic                air 2e-11
    ## 40      Tropic     marinesediment 8e-01
    ## 41      Tropic        naturalsoil 2e-01

``` r
World$fetchData("FRACs")
```

    ##          Scale SubCompart FRACs
    ## 1       Arctic        air 2e-11
    ## 9  Continental        air 2e-11
    ## 19    Moderate        air 2e-11
    ## 27    Regional        air 2e-11
    ## 37      Tropic        air 2e-11

``` r
FRACs
```

    ## function (FRACa, FRACw, FRACs, Matrix) 
    ## {
    ##     if (Matrix %in% c("soil", "sediment")) {
    ##         if (Matrix == "sediment") 
    ##             FRACa <- 0
    ##         return(1 - FRACw - FRACa)
    ##     }
    ##     else return(FRACs)
    ## }

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

An overview for the scale Regional

``` r
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
