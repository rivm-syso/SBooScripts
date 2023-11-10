classic solve
================
JS
12 Apr 2022

## Solve

This vignettes demonstrates solving the “engine” of SB, the matrix of
the matrix of first order rate constants (k’s) between all boxes
(“kaas”). The first chunk will initialize World (the core object) with
the special stateModule ClassicExcel, an object to explore the excel
version of SB, and read emissions from it.

``` r
#We need to initialize, by default a molecular substance is selected
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.2     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.3     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
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

    ## Warning in data("The3D"): data set 'The3D' not found

    ## Joining with `by = join_by(Matrix)`
    ## Joining with `by = join_by(Compartment)`
    ## Joining with `by = join_by(sheet, row)`

``` r
#library(magrittr)
library(htmlTable)
ClassicExcel
```

    ## <ClassicNanoProcess>
    ##   Inherits from: <ProcessModule>
    ##   Public:
    ##     clone: function (deep = FALSE) 
    ##     Exceldependencies: function (CellName, maxDepth = 5) 
    ##     ExcelEmissions: function (scenario_name) 
    ##     Excelgrep: function (grepstr, SenseCase = F) 
    ##     ExcelSB.K: function () 
    ##     Exceltrace: function (CellName, maxDepth = 5) 
    ##     execute: function (debugAt = NULL) 
    ##     exeFunction: active binding
    ##     FromAndTo: active binding
    ##     initialize: function (TheCore, filename) 
    ##     myCore: active binding
    ##     myName: active binding
    ##     namedValues: active binding
    ##     needVars: active binding
    ##     type: active binding
    ##     version: active binding
    ##     WithFlow: active binding
    ##   Private:
    ##     ExcelFileName: data/SimpleBox4.01_20211028.xlsm
    ##     ExcelGrep: function (grepstr, SenseCase) 
    ##     ExcelTrace: function (cellName, dependingOn = T, as.DAG = T, maxDepth) 
    ##     Execute: function (debugAt = NULL) 
    ##     Function: function (k.loc = system.file("testdata", "20190117 SimpleBox4.01-nano rev 21aug.xlsx", 
    ##     initNeedVars: function () 
    ##     l_dependencies: data.frame
    ##     l_namedValues: tbl_df, tbl, data.frame
    ##     l_PrepGrep: NA
    ##     l_type: vs4.02
    ##     l_version: 2021-10-28
    ##     LoadKaas: function (k.loc = system.file("testdata", "20190117 SimpleBox4.01-nano rev 21aug.xlsx", 
    ##     MoreParams: list
    ##     MyCore: SBcore, R6
    ##     MyName: LoadKaas
    ##     NeedVars: NULL
    ##     withFlow: NA

``` r
excelReference
```

    ## [1] "data/SimpleBox4.01_20211028.xlsm"

ClassicExcel is a ProcessModule, because it sets rate constants. In this
case by reading all the excel variables looking like k.b1.b2 (where b1
and b2 are boxes, or states) in the file given by excelReference. The
name of the process is LoadKaas. You can use this to update processes
one by one and compare with the excel-version. We can also make a view
of the k’s, creating a selection of from-states and to-states.

``` r
World$kaas[World$kaas$fromScale == "Regional" & World$kaas$toScale == "Continental",]
```

    ##     i   j            k  process fromAbbr fromScale fromSubCompart fromSpecies
    ## 1 184 182 9.420143e-06 LoadKaas      aRU  Regional            air     Unbound
    ## 6 234 232 1.369854e-06 LoadKaas     w2RU  Regional            sea     Unbound
    ##   toAbbr     toScale toSubCompart toSpecies
    ## 1    aCU Continental                       
    ## 6   w2CU Continental

Yes, there is only advection by air and water… The empty to-columns
indicate no change from the equivalent from-column. A transfer, and
therefor a rate-constant, has a maximum of 1 change of scale, OR
SubCompart OR Species; degradation for example has none.

## A Solver

Like processes, solvers are build on simple R functions, supported by R6
objects. Initiating a solver as part of the core World object take 4
lines of code to demonstrate; first the code of the most simple solver,
than the core-method of initiating, and finally executing it. Note that
a solver needs a reference to it’s “ParentModule”. (Actual inheriting
would make the function look more complex). When calling the solver from
Core, this is provided for.

``` r
SB1Solve
```

    ## function (ParentModule, tol = 1e-30) 
    ## {
    ##     SB.K = ParentModule$SB.k
    ##     vEmis = ParentModule$emissions
    ##     solve(SB.K, -vEmis, tol = tol)
    ## }

``` r
World$NewSolver("SB1Solve", tol=1e-10)
emissions <- ClassicExcel$ExcelEmissions("current.settings")
World$Solve(emissions)
```

    ##       i  Abbr       Scale         SubCompart Species       EqMass
    ## 184 184   aRU    Regional                air Unbound 6.700564e+08
    ## 229 224  w0RU    Regional               lake Unbound 5.893809e+05
    ## 234 229  w1RU    Regional              river Unbound 1.188038e+09
    ## 239 234  w2RU    Regional                sea Unbound 4.391298e+07
    ## 214 209  s1RU    Regional        naturalsoil Unbound 1.546769e+06
    ## 209 204  s2RU    Regional   agriculturalsoil Unbound 2.237280e+10
    ## 219 214  s3RU    Regional          othersoil Unbound 5.728773e+05
    ## 194 189 sd1RU    Regional freshwatersediment Unbound 3.153773e+08
    ## 204 199 sd2RU    Regional     marinesediment Unbound 3.035554e+06
    ## 182 182   aCU Continental                air Unbound 3.759817e+09
    ## 227 222  w0CU Continental               lake Unbound 1.855239e+06
    ## 232 227  w1CU Continental              river Unbound 1.578804e+06
    ## 237 232  w2CU Continental                sea Unbound 1.213716e+09
    ## 212 207  s1CU Continental        naturalsoil Unbound 4.220828e+06
    ## 207 202  s2CU Continental   agriculturalsoil Unbound 1.555089e+07
    ## 217 212  s3CU Continental          othersoil Unbound 1.563270e+06
    ## 192 187 sd1CU Continental freshwatersediment Unbound 4.191101e+05
    ## 202 197 sd2CU Continental     marinesediment Unbound 4.195003e+06
    ## 183 183   aMU    Moderate                air Unbound 7.074677e+09
    ## 238 233  w2MU    Moderate                sea Unbound 6.050241e+08
    ## 223 218  w3MU    Moderate          deepocean Unbound 1.803628e+09
    ## 218 213  s3MU    Moderate          othersoil Unbound 3.037552e+07
    ## 203 198 sd2MU    Moderate     marinesediment Unbound 4.155954e+05
    ## 181 181   aAU      Arctic                air Unbound 2.787641e+09
    ## 236 231  w2AU      Arctic                sea Unbound 1.313955e+09
    ## 221 216  w3AU      Arctic          deepocean Unbound 1.185632e+10
    ## 216 211  s3AU      Arctic          othersoil Unbound 3.527706e+07
    ## 201 196 sd2AU      Arctic     marinesediment Unbound 3.091238e+06
    ## 185 185   aTU      Tropic                air Unbound 7.047682e+09
    ## 240 235  w2TU      Tropic                sea Unbound 3.022154e+08
    ## 225 220  w3TU      Tropic          deepocean Unbound 3.206227e+08
    ## 220 215  s3TU      Tropic          othersoil Unbound 9.302728e+06
    ## 205 200 sd2TU      Tropic     marinesediment Unbound 6.069376e+04

## The constants package

Some global constants are imported from this package. For convenience
two functions are availeable, demonstrated below.

``` r
Concentrations <- function(EqMass, Volume) {
  EqMass / Volume
}
World$NewCalcVariable("Concentrations")
ConcPM <- World$CalcVar("Concentrations")
pivot_wider(ConcPM[, c("SubCompart", "Scale", "Concentrations")],
            values_from = "Concentrations",
            values_fill = NULL,
            names_from = "Scale")
```

    ## # A tibble: 8 × 6
    ##   SubCompart              Arctic  Continental      Moderate    Regional   Tropic
    ##   <chr>                    <dbl>        <dbl>         <dbl>       <dbl>    <dbl>
    ## 1 air               0.0000000656  0.000000522  0.0000000912  0.00000291  5.51e-8
    ## 2 deepocean         0.000000155  NA            0.0000000155 NA           1.19e-9
    ## 3 sea               0.000000515   0.00000163   0.000000156   0.00438     3.37e-8
    ## 4 agriculturalsoil NA             0.0000372   NA             0.814      NA      
    ## 5 lake             NA             0.00000213  NA             0.0000103  NA      
    ## 6 naturalsoil      NA             0.0000897   NA             0.000500   NA      
    ## 7 othersoil        NA             0.0000897   NA             0.000500   NA      
    ## 8 river            NA             0.00000549  NA             0.0629     NA

``` r
# tidyHtmlTable(
#   x = ConcPM[, c("SubCompart", "Scale", "Concentrations")],
#   value = "Concentrations",
#   header = "Scale",
#   rnames = "SubCompart",
#   #col.header = "#FEFEFE",
#   col.rgroup = c("#FEFEFE", "#F7F7F7")
# )
```

## Mass fluxes

``` r
MsFlux <- left_join(World$kaas, World$fetchData("EqMass"), 
                    join_by(fromScale == Scale, fromSubCompart == SubCompart, fromSpecies == Species))
MsFlux$mFlux <- MsFlux$k * MsFlux$EqMass
aggregate(mFlux~toAbbr, data = MsFlux, FUN = sum)
```

    ##    toAbbr        mFlux
    ## 1     aAU 3.254165e+03
    ## 2     aCU 8.067847e+03
    ## 3     aMU 1.150701e+04
    ## 4     aRU 4.446973e+03
    ## 5     aTU 6.360233e+03
    ## 6    s1CU 8.584819e-01
    ## 7    s1RU 3.146001e-01
    ## 8    s2CU 2.175819e+00
    ## 9    s2RU 9.731860e+02
    ## 10   s3AU 1.592698e+00
    ## 11   s3CU 3.179563e-01
    ## 12   s3MU 6.178131e+00
    ## 13   s3RU 1.165186e-01
    ## 14   s3TU 4.623130e+00
    ## 15  sd1CU 4.060953e-02
    ## 16  sd1RU 3.056504e+01
    ## 17  sd2AU 1.842628e-01
    ## 18  sd2CU 3.134938e-01
    ## 19  sd2MU 3.105881e-02
    ## 20  sd2RU 2.296232e-01
    ## 21  sd2TU 6.251506e-03
    ## 22   w0CU 4.218976e-01
    ## 23   w0RU 1.467465e-01
    ## 24   w1CU 3.117399e+00
    ## 25   w1RU 1.886909e+02
    ## 26   w2AU 4.687745e+02
    ## 27   w2CU 2.806818e+02
    ## 28   w2MU 3.138793e+02
    ## 29   w2RU 9.047111e+01
    ## 30   w2TU 2.185981e+02
    ## 31   w3AU 5.780966e+02
    ## 32   w3MU 3.306498e+02
    ## 33   w3TU 1.395770e+02

accuracy? Roundings?? tol doesn’t make a difference?!

Happy calculations!
