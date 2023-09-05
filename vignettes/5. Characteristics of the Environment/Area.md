Nested areas
================
2023-09-05

## Calculation of area of SubCompartment within Scales

The calculation of area slightly differs from the excel version, also in
preparation of a local scale, and the wish to be able to situate the
Continental/Regional/Local system within Tropic, rather than fixed
within Moderate. Therefor the TotalArea contains the area including
possibly nested areas. This is different from SYSTEMAREA in the excel
version. We initiate World and start from the data TotalArea and FRACsea

``` r
source("baseScripts/initTestWorld.R")
World$fetchData("TotalArea")
```

    ##         Scale TotalArea
    ## 1      Arctic  4.25e+13
    ## 2 Continental  7.43e+12
    ## 3    Moderate  8.50e+13
    ## 4    Regional  2.30e+11
    ## 5      Tropic  1.28e+14

``` r
World$fetchData("FRACsea")
```

    ##         Scale    FRACsea
    ## 1      Arctic 0.60000000
    ## 2 Continental 0.50000000
    ## 3    Moderate 0.50000000
    ## 4    Regional 0.00435597
    ## 5      Tropic 0.70000000

## Nesting and splitting land and sea

Regional and Arctic have no nested scale, and are straightforward
calculation of AreaSea and AreaLand as resp. TotalArea\*FRACsea and
TotalArea\*(1-FRACsea)

Continental contains Regional; the TotalArea of Continental is reduced
by Regional, then the sea and land fraction are applied. Same procedure
for Moderate with its nested Continental

``` r
v_AreaSea <- World$NewCalcVariable("AreaSea")
tAreaSea <- World$CalcVar("AreaSea")
v_AreaLand <- World$NewCalcVariable("AreaLand")
tAreaLand <- World$CalcVar("AreaLand")
merge(tAreaLand, tAreaSea)
```

    ##         Scale old_AreaLand     AreaLand  old_AreaSea      AreaSea
    ## 1      Arctic 1.700000e+13 1.700000e+13 2.550000e+13 2.550000e+13
    ## 2 Continental 3.486002e+12 3.486002e+12 3.713998e+12 3.713998e+12
    ## 3    Moderate 3.878500e+13 3.878500e+13 3.878500e+13 3.878500e+13
    ## 4    Regional 2.289981e+11 2.289981e+11 1.001873e+09 1.001873e+09
    ## 5      Tropic 3.840000e+13 3.840000e+13 8.960000e+13 8.960000e+13

## Obvious and not so obvious variable references

Variable are often tables, as can be seen above for the AreaLand
variable. When a variable is applied in a “defining function” the SBoo
system looks for the proper dimension, e.g. when it finds Arealand and
it is calculating for Arctic it will use the AreaLand of Arctic. But
when calculating for instance AreaSea for Continental we need TotalArea
for both Continental AND Regional! How can we implement this in our
defining function?

In such a case use the “all.” preposition. The function will receive the
whole table for the variable at hand. As an example look the defining
function for AreaSea:

``` r
AreaSea
```

    ## function (all.TotalArea, all.FRACsea, ScaleName) 
    ## {
    ##     AreaSea4Scale <- function(forScale) {
    ##         ScaleArea <- all.TotalArea$TotalArea[all.TotalArea$Scale == 
    ##             forScale]
    ##         ScaleFracSea <- all.FRACsea$FRACsea[all.FRACsea$Scale == 
    ##             forScale]
    ##         return(ScaleArea * ScaleFracSea)
    ##     }
    ##     if (ScaleName %in% c("Regional", "Arctic")) {
    ##         return(AreaSea4Scale(ScaleName))
    ##     }
    ##     if (ScaleName == "Continental") {
    ##         return(AreaSea4Scale("Continental") - AreaSea4Scale("Regional"))
    ##     }
    ##     ContinentalInModerate <- T
    ##     if ((ScaleName == "Moderate" & ContinentalInModerate) | (ScaleName == 
    ##         "Tropic" & !ContinentalInModerate)) {
    ##         return(AreaSea4Scale(ScaleName) - AreaSea4Scale("Continental"))
    ##     }
    ##     else {
    ##         return(AreaSea4Scale(ScaleName))
    ##     }
    ## }
    ## <bytecode: 0x000001c017770298>

## The areas to be used in further calculations

All Scale/SubCompart combinations (present in in states) have an area,
including the subcompart “cloudwater”! It receives the same area as air,
namely the sum of AreaSea and AreaLand for the scale at hand. For sea
and for oceans, if present, the area equal that of AreaSea . Otherwise
(different Subcompartments that add up to “AreaLand”) the calculation is
straightforward (landFRAC \* AreaLand). Be aware that the definition of
landFRAC differs from AREAFRAC; landFRAC is the fraction of the
subcompartment of the AreaLand. With these different ways of calculation
the formula to apply depends on the subcompartment, we need to apply
another “trick”; we include SubCompartName as parameter in the defining
function. We then use it to make the distinguish which formula applies.
See the Area function below. In case you are not familiar with this:
return() ends the function and “returns” its parameter. All different
states are “peeled of” in order, and the last statements ensures that
other cases (not existing states) are not included in calculations.

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
    ##     if (SubCompartName == "naturalsoil") {
    ##         return(AreaLand)
    ##     }
    ##     return(NA)
    ## }
    ## <bytecode: 0x000001c0184df398>

``` r
v_Area <- World$NewCalcVariable("Area")
tArea <- World$CalcVar("Area")
```

Just taking the sum of areas grouped by scale would include double
counting the subcompartments which are on top of each other, or mixed:
air / cloudwater / sea / deepocean! But we can test if the TotalArea of
Arctic + Moderate + Tropic equals the total Area of air.

``` r
TotAreaGlobalScales <- World$fetchData("TotalArea")
TotAreaGlobalScales <- TotAreaGlobalScales$TotalArea[TotAreaGlobalScales$Scale %in% c(
  "Arctic","Moderate","Tropic")]
TotAir <- World$fetchData("Area")
TotAir <- TotAir$Area[TotAir$SubCompart == "air"]
sum(TotAreaGlobalScales) == sum(TotAir)
```

    ## [1] TRUE
