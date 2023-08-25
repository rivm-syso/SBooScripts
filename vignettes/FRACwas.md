Fractions of matrices in subcompartments
================
JS
2023-07-06

## Matrix parts of a sub-compartment

A Subcompartment has a main matrix(medium); for soils and sediment this
is “solids”. But both also contain water, and soil also contains a
fraction of air, as wel as water. These matrices play a part in the
exchange of substances. The fraction of the non-main matrices are in the
data, named subFRACw, subFRACa, and subFRACs. The main fraction of the
subcompartment is calculated as the remainder. All fractions are are
determined by three variable defining functions. For example for soils
and sediments:

``` r
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.2     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.2     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
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
    ## Joining with `by = join_by(sheet, row)`

``` r
source("newAlgorithmScripts/v_FRACs.R")
FRACs
```

    ## function (subFRACa, subFRACw, subFRACs, Matrix) 
    ## {
    ##     if (Matrix %in% c("soil", "sediment")) {
    ##         if (Matrix == "sediment") 
    ##             subFRACa <- 0
    ##         return(1 - subFRACw - subFRACa)
    ##     }
    ##     else return(subFRACs)
    ## }

## Use FRACs for

This generalisation is extended to the solids and water fractions in
air, formerly known as FRears and FRearw. Note that the fraction of air
in air may appear as rounded to, but not equal to 1.0.

``` r
Fs <- World$NewCalcVariable("FRACs")
World$CalcVar("FRACs")
```

    ##          SubCompart       Scale FRACs
    ## 3  agriculturalsoil    Regional 6e-01
    ## 5  agriculturalsoil Continental 6e-01
    ## 6               air      Arctic 2e-11
    ## 7               air      Tropic 2e-11
    ## 8               air    Regional 2e-11
    ## 9               air Continental 2e-11
    ## 10              air    Moderate 2e-11
    ## 36   marinesediment      Arctic 2e-01
    ## 37   marinesediment Continental 2e-01
    ## 38   marinesediment    Moderate 2e-01
    ## 39   marinesediment    Regional 2e-01
    ## 40   marinesediment      Tropic 2e-01
    ## 42      naturalsoil Continental 6e-01
    ## 44      naturalsoil    Regional 6e-01
    ## 46        othersoil Continental 6e-01
    ## 47        othersoil      Arctic 6e-01
    ## 48        othersoil    Moderate 6e-01
    ## 49        othersoil    Regional 6e-01
    ## 50        othersoil      Tropic 6e-01

``` r
source("newAlgorithmScripts/v_FRACa.R")
World$NewCalcVariable("FRACa")
World$CalcVar("FRACa")
```

    ##          SubCompart       Scale FRACa
    ## 3  agriculturalsoil    Regional   0.2
    ## 5  agriculturalsoil Continental   0.2
    ## 6               air      Arctic   1.0
    ## 7               air      Tropic   1.0
    ## 8               air    Regional   1.0
    ## 9               air Continental   1.0
    ## 10              air    Moderate   1.0
    ## 42      naturalsoil Continental   0.2
    ## 44      naturalsoil    Regional   0.2
    ## 46        othersoil Continental   0.2
    ## 47        othersoil      Arctic   0.2
    ## 48        othersoil    Moderate   0.2
    ## 49        othersoil    Regional   0.2
    ## 50        othersoil      Tropic   0.2

``` r
source("newAlgorithmScripts/v_FRACw.R")
World$NewCalcVariable("FRACw")
World$CalcVar("FRACw")
```

    ##          SubCompart       Scale FRACw
    ## 3  agriculturalsoil    Regional 2e-01
    ## 5  agriculturalsoil Continental 2e-01
    ## 6               air      Arctic 2e-11
    ## 7               air      Tropic 2e-11
    ## 8               air    Regional 2e-11
    ## 9               air Continental 2e-11
    ## 10              air    Moderate 2e-11
    ## 36   marinesediment      Arctic 8e-01
    ## 37   marinesediment Continental 8e-01
    ## 38   marinesediment    Moderate 8e-01
    ## 39   marinesediment    Regional 8e-01
    ## 40   marinesediment      Tropic 8e-01
    ## 42      naturalsoil Continental 2e-01
    ## 44      naturalsoil    Regional 2e-01
    ## 46        othersoil Continental 2e-01
    ## 47        othersoil      Arctic 2e-01
    ## 48        othersoil    Moderate 2e-01
    ## 49        othersoil    Regional 2e-01
    ## 50        othersoil      Tropic 2e-01

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
