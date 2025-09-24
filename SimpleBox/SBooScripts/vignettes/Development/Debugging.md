CalcGraph and Debugging
================
JS
2024-07-23

\#CalcGraph and Debugging This vignettes describes a way to debug the
functions that define variables, flows or processes.

## The “CalcGraph”

You can imagine that the calculations of SB variables (SBVs), flows and
processes need a specific order (processes can only be calculated after
all their inputs are calculated). This order is automated.

## Debugging

Once you have created a function, you might need to update it. SBOO is
created using R6 objects. These objects let the user define special
landscape variables and processes that define rates of the first-order
transfers. The R6 objects also calls the defining functions with the
right parameters. Normal debugging would mean you have to step through
SBOO methods and possibly even code from the R6 package. Therefor an
easier way to debug your defining function has been implemented. This
way of debugging in tailored for use in R-studio and cannot (easily) be
shown in a vignette, because of the interactive way debugging is needed.
The code that would trigger the debug mode is therefore commented out to
avoid executing in the vignette itself. We initialize in the normal way,
and use an availeable function as an example.

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
    ##     Function: function (AreaLand, AreaSea, landFRAC, all.landFRAC, SubCompartName, 
    ##     initNeedVars: function () 
    ##     MoreParams: list
    ##     MyCore: SBcore, R6
    ##     MyName: Area
    ##     NeedVars: AreaLand AreaSea landFRAC landFRAC SubCompartName ScaleName

From the needVars property we learn that we need “AreaLand” and
“AreaSea”. The execute method, normally called by World, return the
results for all cases, all scale-SubCompart combinations that exist in a
state.

``` r
CalcVariable$needVars
```

    ## [1] "AreaLand"       "AreaSea"        "landFRAC"       "landFRAC"      
    ## [5] "SubCompartName" "ScaleName"

``` r
for (SBVar in c("AreaLand", "AreaSea")){
  World$NewCalcVariable(SBVar)
  World$CalcVar(SBVar)
}
CalcVariable$execute()
```

    ##          Scale         SubCompart         Area
    ## 2       Arctic                sea 2.550000e+13
    ## 4       Arctic        naturalsoil 1.700000e+13
    ## 6       Arctic     marinesediment 2.550000e+13
    ## 7       Arctic          deepocean 2.550000e+13
    ## 10      Arctic                air 4.250000e+13
    ## 12 Continental   agriculturalsoil 2.091504e+12
    ## 13 Continental     marinesediment 3.713410e+12
    ## 14 Continental freshwatersediment 9.586060e+10
    ## 15 Continental       lakesediment 8.714600e+09
    ## 16 Continental                air 7.199250e+12
    ## 17 Continental              river 9.586060e+10
    ## 18 Continental               lake 8.714600e+09
    ## 19 Continental        naturalsoil 9.411768e+11
    ## 20 Continental                sea 3.713410e+12
    ## 22 Continental          othersoil 3.485840e+11
    ## 24    Moderate                sea 3.878559e+13
    ## 26    Moderate          deepocean 3.878559e+13
    ## 29    Moderate        naturalsoil 3.878559e+13
    ## 31    Moderate                air 7.757118e+13
    ## 32    Moderate     marinesediment 3.878559e+13
    ## 34    Regional     marinesediment 1.000000e+09
    ## 35    Regional freshwatersediment 6.285675e+09
    ## 36    Regional       lakesediment 5.714250e+08
    ## 37    Regional          othersoil 2.285700e+10
    ## 38    Regional                sea 1.000000e+09
    ## 39    Regional                air 2.295700e+11
    ## 40    Regional              river 6.285675e+09
    ## 41    Regional               lake 5.714250e+08
    ## 43    Regional   agriculturalsoil 1.371420e+11
    ## 44    Regional        naturalsoil 6.171390e+10
    ## 46      Tropic     marinesediment 8.925000e+13
    ## 47      Tropic          deepocean 8.925000e+13
    ## 50      Tropic                sea 8.925000e+13
    ## 52      Tropic                air 1.275000e+14
    ## 55      Tropic        naturalsoil 3.825000e+13

The results are not stored in the World object, it is not called by that
object! You called the execute method, which prepares the parameters and
call the defining function for each case separately. Each of the input
parameters is an atomic variable, this makes the defining function
easier to write for those who are not used to the vectored way R
normally uses. This supports debugging with a special set of
input-parameters you want to debug for. This is exactly what you
optionally put in the debugAt list. You can use any combination of the
input parameters, like below. Any empty parameter will “trigger” for any
value; use list() to pass an empty list, which will trigger at the first
call, AND all consecutive calls.

``` r
#commented out so it does not trigger
# use debugAt
# CalcVariable$execute(debugAt = list(ScaleName = "Arctic", SubCompartName = "deepocean"))
```
