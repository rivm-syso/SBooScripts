Debugging
================
JS
2023-03-13

This vignettes describes a way to debug the functions that define
variables, processes or flows.

## Defining functions

You can create and modify existing calculations in simplebox, see the
vignette FirstVars. If you do, you will write an R function, and you may
need to debug this funcion. SBoo is created using R6 objects. These
objects let the user define special landscape variables and processes
that define rates of the first-order transfers. The R6 objects also
calls the defining functions with the right parameters. Normal debugging
would mean you have to step through SBoo methods and possibly even code
from the R6 package. Therefor an easier way to debug your defining
function has been implemented. This way of debugging in tailored for use
in R-studio and cannot (easily) be shown in a vignette, because of the
interactive way debugging is needed. The code that would trigger the
debug mode is therefore commented out to avoid executing in the vignette
itself. We initialize in the normal way, and use an availeable function
as an example.

``` r
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.0     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.1     ✔ tibble    3.1.8
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the ]8;;http://conflicted.r-lib.org/conflicted package]8;; to force all conflicts to become errors
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
Area
```

    ## function (AreaLand, AreaSea, landFRAC, SubCompartName, ScaleName) 
    ## {
    ##     if (SubCompartName %in% c("air", "cloudwater")) {
    ##         return(AreaLand + AreaSea)
    ##     }
    ##     if (SubCompartName == "sea") {
    ##         return(AreaSea)
    ##     }
    ##     if (SubCompartName == "deepocean" & ScaleName %in% c("Arctic", 
    ##         "Moderate", "Tropic")) {
    ##         return(AreaSea)
    ##     }
    ##     if (ScaleName %in% c("Regional", "Continental")) {
    ##         return(landFRAC * AreaLand)
    ##     }
    ##     if (SubCompartName == "othersoil") {
    ##         return(AreaLand)
    ##     }
    ##     return(NA)
    ## }

Normally we define a SBoo variable by just calling the NewCalcVariable
method. This method silently returns an object for the variable.
Silently means that normally you don’t see this. Normally you don’t need
it because the object is “injected” in the World object. But for
debugging we do need it. Printing it reveals that it is indeed an R6
object.

``` r
CalcVariable <- World$NewCalcVariable("Area")
CalcVariable
```

    ## <VariableModule>
    ##   Inherits from: <CalcGraphModule>
    ##   Public:
    ##     aggr.by: active binding
    ##     aggr.FUN: active binding
    ##     clone: function (deep = FALSE) 
    ##     execute: function (debugAt = NULL) 
    ##     exeFunction: active binding
    ##     FromAndTo: active binding
    ##     initialize: function (TheCore, exeFunction, AggrBy, AggrFun) 
    ##     myCore: active binding
    ##     myName: active binding
    ##     needVars: active binding
    ##   Private:
    ##     aggrBy: NA
    ##     aggrFUN: NA
    ##     Execute: function (debugAt = NULL) 
    ##     Function: function (AreaLand, AreaSea, landFRAC, SubCompartName, ScaleName) 
    ##     initNeedVars: function () 
    ##     MoreParams: list
    ##     MyCore: SBcore, R6
    ##     MyName: Area
    ##     NeedVars: AreaLand AreaSea landFRAC SubCompartName ScaleName

From the needVars property we learn that we need “AreaLand” and
“AreaSea”. The execute method, normally called by World, return the
results for all cases, all scale-SubCompart combinations that exist in a
state.

``` r
CalcVariable$needVars
```

    ## [1] "AreaLand"       "AreaSea"        "landFRAC"       "SubCompartName"
    ## [5] "ScaleName"

``` r
for (SBVar in c("AreaLand", "AreaSea")){
  World$NewCalcVariable(SBVar)
  World$CalcVar(SBVar)
}
CalcVariable$execute()
```

    ##          Scale       SubCompart         Area
    ## 1       Arctic        othersoil 1.700000e+13
    ## 2       Arctic        deepocean 2.550000e+13
    ## 4       Arctic              sea 2.550000e+13
    ## 5       Arctic              air 4.250000e+13
    ## 6       Arctic       cloudwater 4.250000e+13
    ## 7  Continental agriculturalsoil 2.091601e+12
    ## 8  Continental      naturalsoil 9.412205e+11
    ## 10 Continental              air 7.200000e+12
    ## 11 Continental             lake 8.715005e+09
    ## 14 Continental            river 9.586505e+10
    ## 15 Continental       cloudwater 7.200000e+12
    ## 16 Continental              sea 3.713998e+12
    ## 17 Continental        othersoil 3.486002e+11
    ## 18    Moderate        othersoil 3.878500e+13
    ## 19    Moderate        deepocean 3.878500e+13
    ## 20    Moderate              air 7.757000e+13
    ## 21    Moderate              sea 3.878500e+13
    ## 22    Moderate       cloudwater 7.757000e+13
    ## 24    Regional              air 2.300000e+11
    ## 27    Regional      naturalsoil 6.182949e+10
    ## 28    Regional agriculturalsoil 1.373989e+11
    ## 29    Regional            river 6.297448e+09
    ## 30    Regional        othersoil 2.289981e+10
    ## 31    Regional             lake 5.724953e+08
    ## 32    Regional       cloudwater 2.300000e+11
    ## 34    Regional              sea 1.001873e+09
    ## 35      Tropic              air 1.280000e+14
    ## 36      Tropic        othersoil 3.840000e+13
    ## 37      Tropic        deepocean 8.960000e+13
    ## 38      Tropic              sea 8.960000e+13
    ## 40      Tropic       cloudwater 1.280000e+14

The results are not stored in the World object, it is not called by that
object! You called the execute method, which prepares the parameters and
call the defining function for each case separately. Each of the input
parameters is an atomic variable, this makes the defining function
easier to write for those who are not used to the vectorize way R
normally uses. This supports debugging with a special set of
input-parameters you want to debug for. This is exactly what you
optionally put in the debugAt list. You can use any combination of the
input parameters, like below. Any empty parameter will “trigger” for any
value; use list() to pass an empty list, which will trigger at the first
call, AND all consecutive calls.

``` r
# try this at home... CalcVariable$execute(debugAt = list(ScaleName = "Arctic", SubCompartName = "deepocean"))
```

Happy programming :)
