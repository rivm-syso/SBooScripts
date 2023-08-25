Air Flow
================
JS
3/31/2022

## A flow in SBOO

This vignette demonstrates the implementation of a “flow”. A flow in the
context of SB is the massflow of a matrix (air, water, ) from one box to
another, where either the subcompartment or scale is different. This
flow is calculated for a process, usually and by default “Advection”.
The airflow is a nice example how to model and use flows.

## Initialise

We use a special script to initialize SB, creating two objects, the
first we will use is named “World”. When we print it, we see the methods
(functions) and properties (active binding), divided in a public and a
private part.

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
World
```

    ## <SBcore>
    ##   Public:
    ##     CalcVar: function (aVariable) 
    ##     CleanupCalcGraphAbove: function (VarName) 
    ##     clone: function (deep = FALSE) 
    ##     doInherit: function (fromData, toData) 
    ##     fetchData: function (varname = "all") 
    ##     findState: function (abbr) 
    ##     FromDataAndTo: function (processName = "all") 
    ##     initialize: function (NewstateModule) 
    ##     kaas: active binding
    ##     metaData: function () 
    ##     moduleList: active binding
    ##     NewCalcVariable: function (VariableFunction, AggrBy = NA, AggrFun = NA) 
    ##     NewFlow: function (FlowFunction, WithProcess = "k_Advection") 
    ##     NewProcess: function (ProcessFunction) 
    ##     NewSolver: function (SolverFunction, ...) 
    ##     nodelist: active binding
    ##     Solve: function (emissions, needdebug = F) 
    ##     states: active binding
    ##     UpdateData: function (UpdateDF, keys, TableName = NULL) 
    ##     UpdateDirty: function (Variables) 
    ##     UpdateKaas: function (aProcessModule = NULL, mergeExisting = T) 
    ##     whichDataTable: function (KeyNames) 
    ##     whichUnresolved: function () 
    ##   Private:
    ##     CalcTreeBack: function (aProcessModule) 
    ##     CalcTreeForward: function (DirtyVariables) 
    ##     CheckTree: function () 
    ##     cleanupCGAbove: function (VarName) 
    ##     DoInherit: function (fromDataName, toDataName) 
    ##     FetchData: function (varname) 
    ##     FindStatefrom3D: function (df3Ds) 
    ##     ijAddState: function (ijTable) 
    ##     ModuleList: list
    ##     nodeList: data.frame
    ##     SB4Ndata: list
    ##     SBkaas: data.frame
    ##     solver: NULL
    ##     States: SBstates, R6
    ##     storeNodes: function (aNewModule) 
    ##     substance: default substance
    ##     UpdateDL: function (VarFunName, DIMRestrict = NULL) 
    ##     WhichDataTable: function (KeyNames)

## World

The object named World is of the class SBcore, which is the most
imported in use. Other objects are often made part of SBCore objects.
Before calculating we need some variables. If you want to read more
about variables (in the context of SBOO) read the vignette “FirstVars”

``` r
SBvars <- c("AreaLand",
            "AreaSea",
            "Area",
            "Volume"
            )

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}
```

We calculate AirFlow in two steps. The first is the application of a
simple model of air circulation depending on windspeed; The mean
residence time in the region is according the fTAU function. The AirFlow
function calculates the amount that would enter/leave the region namely
the volume divided by the residence time. Notice that fTAU is a normal
function, but AirFlow will be used as a variable defining function.
After the call to World\$CalcVar(“AirFlow”) this property is stored in
the data within World.

``` r
fTAU
```

    ## function (Area, WINDspeed) 
    ## {
    ##     1.5 * (0.5 * sqrt(Area * pi/4)/WINDspeed)
    ## }

``` r
AirFlow
```

    ## function (Volume, Area, WINDspeed, SubCompartName) 
    ## {
    ##     if (SubCompartName %in% c("air")) {
    ##         TAU <- fTAU(Area, WINDspeed)
    ##         Volume/TAU
    ##     }
    ##     else {
    ##         return(NA)
    ##     }
    ## }

``` r
World$NewCalcVariable("AirFlow")
World$CalcVar("AirFlow")
```

    ##    SubCompart       Scale     AirFlow
    ## 6         air      Arctic 29424519893
    ## 7         air      Tropic 51064596572
    ## 8         air    Regional  2164605903
    ## 9         air Continental 12111032472
    ## 10        air    Moderate 39752259252

## But

this would not guarantee that the amount from one scale to the next
would equal the amount flowing the opposite way! To honour the mass
balance we give priority to the amount calculated for the smallest
volume to calculate the actual flows. For nested scales we need to know
how the nesting is. This brings a new challange; we need to know
properties of the scale the flow is going to, or possibly the scale
ehere it is going to. Because of the nesting, we need to know even
properties of scale not directly related to the to- or the from scale!
In this example we see use of the “to.”, the “from.” and the “all.”
preposition. The to- and from scaleName are atomic (a single string) but
the “all.” prepositions provides a full table of the variable and its
dimensions (in this case only scale). If you want to see what is really
going on in the function calls you can use the debug parameter. This
debugging is not availeable for (the whole) World; use the (silent)
return value of World\$New\[Variable\|Flow\|Process\] ! After the r
section below you can enter at the console prompt of R-studio:
AdvAir\$execute(debugAt = list(toScale = “Continental”))

``` r
x_Advection_Air
```

    ## function (all.AirFlow, from.ScaleName, to.ScaleName) 
    ## {
    ##     from.AirFlow <- all.AirFlow$AirFlow[all.AirFlow$Scale == 
    ##         from.ScaleName]
    ##     to.Airflow <- all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName]
    ##     Cont2Regional.Airflow <- function() {
    ##         all.AirFlow$AirFlow[all.AirFlow$Scale == "Regional"]
    ##     }
    ##     if (from.ScaleName %in% c("Arctic", "Regional", "Tropic")) {
    ##         return(all.AirFlow$AirFlow[all.AirFlow$Scale == from.ScaleName])
    ##     }
    ##     if (from.ScaleName == "Continental" & to.ScaleName == "Moderate") {
    ##         return(all.AirFlow$AirFlow[all.AirFlow$Scale == from.ScaleName] - 
    ##             Cont2Regional.Airflow())
    ##     }
    ##     if (from.ScaleName == "Moderate" & to.ScaleName == "Continental") {
    ##         return(all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName] - 
    ##             Cont2Regional.Airflow())
    ##     }
    ##     return(all.AirFlow$AirFlow[all.AirFlow$Scale == to.ScaleName])
    ## }

``` r
AdvAir <- World$NewFlow("x_Advection_Air")
#AdvAir$execute(debugAt = list(toScale = "Continental"))
World$CalcVar("x_Advection_Air")
```

    ##       toScale   fromScale fromSubCompart        flow        FlowName
    ## 1      Arctic    Moderate            air 29424519893 x_Advection_Air
    ## 2 Continental    Moderate            air  9946426570 x_Advection_Air
    ## 3 Continental    Regional            air  2164605903 x_Advection_Air
    ## 4    Moderate      Arctic            air 29424519893 x_Advection_Air
    ## 5    Moderate Continental            air  9946426570 x_Advection_Air
    ## 6    Moderate      Tropic            air 51064596572 x_Advection_Air
    ## 7    Regional Continental            air  2164605903 x_Advection_Air
    ## 8      Tropic    Moderate            air 51064596572 x_Advection_Air
    ##   toSubCompart
    ## 1          air
    ## 2          air
    ## 3          air
    ## 4          air
    ## 5          air
    ## 6          air
    ## 7          air
    ## 8          air

Does it add up?

``` r
AirFlows <- World$fetchData("x_Advection_Air")
ToFlow <- aggregate(flow~toScale, data = AirFlows, FUN = sum)
FromFlow <- aggregate(flow~fromScale, data = AirFlows, FUN = sum)
merge(FromFlow, ToFlow, by.x = "fromScale", by.y = "toScale")
```

    ##     fromScale      flow.x      flow.y
    ## 1      Arctic 29424519893 29424519893
    ## 2 Continental 12111032472 12111032472
    ## 3    Moderate 90435543035 90435543035
    ## 4    Regional  2164605903  2164605903
    ## 5      Tropic 51064596572 51064596572
