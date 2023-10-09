Particulate Deposition air to soil/water
================
2023-10-09

``` r
# knitr::opts_chunk$set(echo = TRUE)
# projectRoot <- paste(getwd(), "..", sep = "/")
# knitr::opts_knit$set(root.dir = NULL) #assuming vignette is in a direct subfolder of the project


# knitr::opts_knit$get()
```

``` r
# knitr::opts_chunk$set(echo = TRUE)
# projectRoot <- paste(getwd(), "..", sep = "/")
# knitr::opts_knit$set(root.dir = projectRoot) #assuming vignette is in a direct subfolder of the project

# see which relevant substances are in the database:
library(tidyverse)
SubstanceDatabase <- read.csv("data/Substances.csv")
# unique(as.tibble(SubstanceDatabase$ChemClass))
SubstanceDatabase |> filter(ChemClass == "particle")
```

    ##     X  Substance ChemClass pKa      MW  Tm   Pvap25 Sol25 Kaw25 Kow Ksw
    ## 1 796   nAg_10nm  particle  NA 107.870  NA 2.41e-36    NA 1e-20  NA  NA
    ## 2 801  nC60_10nm  particle  NA 720.640 280 2.41e-36    NA    NA  NA  NA
    ## 3 814 nTiO2_10nm  particle  NA  47.367  NA 2.41e-36    NA 1e-20  NA  NA
    ##   kdeg.air kdeg.water kdeg.sed kdeg.soil Kp.col Kp.susp Kp.sed Kp.soil  RadS
    ## 1    1e-20      1e-20    1e-20     1e-20     NA      NA     NA      NA 5e-09
    ## 2    1e-20      1e-20    1e-20     1e-20     NA      NA     NA      NA 5e-09
    ## 3    1e-20      1e-20    1e-20     1e-20     NA      NA     NA      NA 5e-09
    ##    RhoS hamakerSP.w
    ## 1 10500    2.02e-20
    ## 2  1650    2.76e-20
    ## 3  4230    6.90e-21

``` r
rm(substance) #for "default substance", example of neutral substance
substance <- "nAg_10nm"
#substance <- "organic acid" #example of acid
#substance <- "organic base" #example of base
#substance <- "Ag(I)" #example of metal

source("baseScripts/initTestWorld.R")
```

## Introduction

See if the following variable are available. They are required for the
DryDeposition function

to.Area, from.Volume, AEROresist, Diffusivity,
DynVisc,rhoMatrix,ColRad,rad_species,rho_species, Temp,to.alpha.surf,
Cunningham, SetVel

``` r
World$fetchData("Area")
```

    ##          Scale       SubCompart         Area
    ## 1       Arctic              air 4.250000e+13
    ## 2       Arctic       cloudwater 4.250000e+13
    ## 3       Arctic        deepocean 2.550000e+13
    ## 5       Arctic      naturalsoil 1.700000e+13
    ## 6       Arctic              sea 2.550000e+13
    ## 7  Continental agriculturalsoil 2.091601e+12
    ## 8  Continental              air 7.200000e+12
    ## 9  Continental       cloudwater 7.200000e+12
    ## 11 Continental             lake 8.715005e+09
    ## 14 Continental      naturalsoil 9.412205e+11
    ## 15 Continental        othersoil 3.486002e+11
    ## 16 Continental            river 9.586505e+10
    ## 17 Continental              sea 3.713998e+12
    ## 18    Moderate              air 7.757000e+13
    ## 19    Moderate       cloudwater 7.757000e+13
    ## 20    Moderate        deepocean 3.878500e+13
    ## 22    Moderate      naturalsoil 3.878500e+13
    ## 23    Moderate              sea 3.878500e+13
    ## 24    Regional agriculturalsoil 1.373989e+11
    ## 25    Regional              air 2.300000e+11
    ## 26    Regional       cloudwater 2.300000e+11
    ## 28    Regional             lake 5.724953e+08
    ## 31    Regional      naturalsoil 6.182949e+10
    ## 32    Regional        othersoil 2.289981e+10
    ## 33    Regional            river 6.297448e+09
    ## 34    Regional              sea 1.001873e+09
    ## 35      Tropic              air 1.280000e+14
    ## 36      Tropic       cloudwater 1.280000e+14
    ## 37      Tropic        deepocean 8.960000e+13
    ## 39      Tropic      naturalsoil 3.840000e+13
    ## 40      Tropic              sea 8.960000e+13

``` r
World$fetchData("Volume")
```

    ##          Scale       SubCompart       Volume
    ## 1       Arctic              air 4.249999e+16
    ## 2       Arctic       cloudwater 1.275000e+10
    ## 3       Arctic        deepocean 7.650000e+16
    ## 5       Arctic      naturalsoil 8.500000e+11
    ## 6       Arctic              sea 2.550000e+15
    ## 7  Continental agriculturalsoil 4.183202e+11
    ## 8  Continental              air 7.199998e+15
    ## 9  Continental       cloudwater 2.160000e+09
    ## 11 Continental             lake 8.715005e+11
    ## 14 Continental      naturalsoil 4.706103e+10
    ## 15 Continental        othersoil 1.743001e+10
    ## 16 Continental            river 2.875952e+11
    ## 17 Continental              sea 7.427996e+14
    ## 18    Moderate              air 7.756998e+16
    ## 19    Moderate       cloudwater 2.327100e+10
    ## 20    Moderate        deepocean 1.163550e+17
    ## 22    Moderate      naturalsoil 1.939250e+12
    ## 23    Moderate              sea 3.878500e+15
    ## 24    Regional agriculturalsoil 2.747978e+10
    ## 25    Regional              air 2.299999e+14
    ## 26    Regional       cloudwater 6.900000e+07
    ## 28    Regional             lake 5.724953e+10
    ## 31    Regional      naturalsoil 3.091475e+09
    ## 32    Regional        othersoil 1.144991e+09
    ## 33    Regional            river 1.889235e+10
    ## 34    Regional              sea 1.001873e+10
    ## 35      Tropic              air 1.280000e+17
    ## 36      Tropic       cloudwater 3.840000e+10
    ## 37      Tropic        deepocean 2.688000e+17
    ## 39      Tropic      naturalsoil 1.920000e+12
    ## 40      Tropic              sea 8.960000e+15

``` r
World$fetchData("AEROresist")
```

    ## [1] 74

``` r
World$fetchData("Matrix")
```

    ##            SubCompart   Matrix
    ## 1                 air      air
    ## 2          cloudwater    water
    ## 3  freshwatersediment sediment
    ## 4        lakesediment sediment
    ## 5      marinesediment sediment
    ## 6    agriculturalsoil     soil
    ## 7         naturalsoil     soil
    ## 8           othersoil     soil
    ## 9           deepocean    water
    ## 10               lake    water
    ## 11              river    water
    ## 12                sea    water

``` r
#Diffusivity is calculated based on f_Diffusivity

World$fetchData("DynVisc")
```

    ##    SubCompart   DynVisc
    ## 1         air 0.0000181
    ## 2  cloudwater 0.0000181
    ## 9   deepocean 0.0010020
    ## 10       lake 0.0010020
    ## 11      river 0.0010020
    ## 12        sea 0.0010020

``` r
World$fetchData("rhoMatrix")
```

    ##            SubCompart rhoMatrix
    ## 1                 air     1.225
    ## 2          cloudwater   998.000
    ## 3  freshwatersediment  2500.000
    ## 4        lakesediment  2500.000
    ## 5      marinesediment  2500.000
    ## 6    agriculturalsoil  2500.000
    ## 7         naturalsoil  2500.000
    ## 8           othersoil  2500.000
    ## 9           deepocean   998.000
    ## 10               lake   998.000
    ## 11              river   998.000
    ## 12                sea   998.000

``` r
World$fetchData("ColRad")
```

    ##         SubCompart ColRad
    ## 6 agriculturalsoil  0.003
    ## 7      naturalsoil  0.003
    ## 8        othersoil  0.010

``` r
World$NewCalcVariable("rad_species")
World$CalcVar("rad_species")
```

    ##           Scale         SubCompart Species  rad_species
    ## 1        Arctic     marinesediment   Solid 5.000000e-09
    ## 2        Arctic        naturalsoil   Large 1.280000e-04
    ## 4        Arctic               lake   Small 1.500019e-07
    ## 5        Arctic   agriculturalsoil   Small 1.500019e-07
    ## 6        Arctic          deepocean   Large 3.000000e-06
    ## 7        Arctic   agriculturalsoil   Large 1.280000e-04
    ## 9        Arctic          othersoil   Large 1.280000e-04
    ## 10       Arctic                sea   Large 3.000000e-06
    ## 11       Arctic         cloudwater   Solid 5.000000e-09
    ## 12       Arctic         cloudwater   Large 9.000001e-07
    ## 14       Arctic     marinesediment   Small 1.500019e-07
    ## 15       Arctic freshwatersediment   Solid 5.000000e-09
    ## 16       Arctic       lakesediment   Solid 5.000000e-09
    ## 17       Arctic                sea   Solid 5.000000e-09
    ## 18       Arctic       lakesediment   Large 1.280000e-04
    ## 19       Arctic   agriculturalsoil   Solid 5.000000e-09
    ## 20       Arctic               lake   Solid 5.000000e-09
    ## 21       Arctic                air   Large 9.000001e-07
    ## 23       Arctic              river   Small 1.500019e-07
    ## 25       Arctic freshwatersediment   Large 1.280000e-04
    ## 27       Arctic          deepocean   Small 1.500019e-07
    ## 28       Arctic          deepocean   Solid 5.000000e-09
    ## 29       Arctic                air   Small 4.537267e-08
    ## 30       Arctic        naturalsoil   Small 1.500019e-07
    ## 33       Arctic              river   Solid 5.000000e-09
    ## 34       Arctic               lake   Large 3.000000e-06
    ## 35       Arctic freshwatersediment   Small 1.500019e-07
    ## 36       Arctic       lakesediment   Small 1.500019e-07
    ## 38       Arctic              river   Large 3.000000e-06
    ## 39       Arctic     marinesediment   Large 1.280000e-04
    ## 40       Arctic                air   Solid 5.000000e-09
    ## 42       Arctic          othersoil   Small 1.500019e-07
    ## 43       Arctic          othersoil   Solid 5.000000e-09
    ## 44       Arctic                sea   Small 1.500019e-07
    ## 45       Arctic        naturalsoil   Solid 5.000000e-09
    ## 48  Continental                air   Large 9.000001e-07
    ## 50  Continental   agriculturalsoil   Small 1.500019e-07
    ## 52  Continental          othersoil   Solid 5.000000e-09
    ## 53  Continental     marinesediment   Small 1.500019e-07
    ## 54  Continental                air   Solid 5.000000e-09
    ## 55  Continental          deepocean   Large 3.000000e-06
    ## 57  Continental              river   Large 3.000000e-06
    ## 58  Continental         cloudwater   Solid 5.000000e-09
    ## 59  Continental         cloudwater   Large 9.000001e-07
    ## 60  Continental                air   Small 4.537267e-08
    ## 61  Continental               lake   Small 1.500019e-07
    ## 62  Continental              river   Small 1.500019e-07
    ## 64  Continental     marinesediment   Large 1.280000e-04
    ## 65  Continental   agriculturalsoil   Large 1.280000e-04
    ## 66  Continental               lake   Large 3.000000e-06
    ## 67  Continental        naturalsoil   Solid 5.000000e-09
    ## 68  Continental       lakesediment   Solid 5.000000e-09
    ## 69  Continental        naturalsoil   Small 1.500019e-07
    ## 70  Continental        naturalsoil   Large 1.280000e-04
    ## 71  Continental          othersoil   Small 1.500019e-07
    ## 72  Continental               lake   Solid 5.000000e-09
    ## 73  Continental freshwatersediment   Large 1.280000e-04
    ## 75  Continental freshwatersediment   Small 1.500019e-07
    ## 77  Continental                sea   Large 3.000000e-06
    ## 78  Continental          deepocean   Solid 5.000000e-09
    ## 80  Continental       lakesediment   Small 1.500019e-07
    ## 81  Continental                sea   Small 1.500019e-07
    ## 83  Continental              river   Solid 5.000000e-09
    ## 85  Continental          othersoil   Large 1.280000e-04
    ## 86  Continental   agriculturalsoil   Solid 5.000000e-09
    ## 87  Continental     marinesediment   Solid 5.000000e-09
    ## 88  Continental       lakesediment   Large 1.280000e-04
    ## 90  Continental                sea   Solid 5.000000e-09
    ## 91  Continental freshwatersediment   Solid 5.000000e-09
    ## 94  Continental          deepocean   Small 1.500019e-07
    ## 95     Moderate   agriculturalsoil   Large 1.280000e-04
    ## 96     Moderate       lakesediment   Small 1.500019e-07
    ## 97     Moderate          deepocean   Large 3.000000e-06
    ## 98     Moderate               lake   Large 3.000000e-06
    ## 99     Moderate     marinesediment   Large 1.280000e-04
    ## 100    Moderate              river   Solid 5.000000e-09
    ## 101    Moderate       lakesediment   Solid 5.000000e-09
    ## 102    Moderate freshwatersediment   Solid 5.000000e-09
    ## 104    Moderate   agriculturalsoil   Small 1.500019e-07
    ## 106    Moderate     marinesediment   Small 1.500019e-07
    ## 107    Moderate         cloudwater   Solid 5.000000e-09
    ## 108    Moderate   agriculturalsoil   Solid 5.000000e-09
    ## 110    Moderate                air   Small 4.537267e-08
    ## 111    Moderate          othersoil   Large 1.280000e-04
    ## 115    Moderate                sea   Large 3.000000e-06
    ## 116    Moderate                sea   Small 1.500019e-07
    ## 117    Moderate                air   Large 9.000001e-07
    ## 118    Moderate              river   Large 3.000000e-06
    ## 119    Moderate freshwatersediment   Large 1.280000e-04
    ## 120    Moderate          othersoil   Small 1.500019e-07
    ## 121    Moderate               lake   Solid 5.000000e-09
    ## 122    Moderate     marinesediment   Solid 5.000000e-09
    ## 123    Moderate        naturalsoil   Small 1.500019e-07
    ## 124    Moderate          deepocean   Solid 5.000000e-09
    ## 125    Moderate          othersoil   Solid 5.000000e-09
    ## 126    Moderate       lakesediment   Large 1.280000e-04
    ## 129    Moderate                air   Solid 5.000000e-09
    ## 131    Moderate          deepocean   Small 1.500019e-07
    ## 132    Moderate               lake   Small 1.500019e-07
    ## 133    Moderate              river   Small 1.500019e-07
    ## 134    Moderate        naturalsoil   Solid 5.000000e-09
    ## 135    Moderate         cloudwater   Large 9.000001e-07
    ## 136    Moderate freshwatersediment   Small 1.500019e-07
    ## 139    Moderate        naturalsoil   Large 1.280000e-04
    ## 140    Moderate                sea   Solid 5.000000e-09
    ## 142    Regional   agriculturalsoil   Large 1.280000e-04
    ## 143    Regional       lakesediment   Large 1.280000e-04
    ## 144    Regional                air   Solid 5.000000e-09
    ## 145    Regional          deepocean   Large 3.000000e-06
    ## 146    Regional                air   Small 4.537267e-08
    ## 147    Regional       lakesediment   Small 1.500019e-07
    ## 149    Regional                air   Large 9.000001e-07
    ## 150    Regional        naturalsoil   Large 1.280000e-04
    ## 151    Regional freshwatersediment   Solid 5.000000e-09
    ## 153    Regional     marinesediment   Small 1.500019e-07
    ## 154    Regional         cloudwater   Large 9.000001e-07
    ## 155    Regional              river   Large 3.000000e-06
    ## 157    Regional        naturalsoil   Small 1.500019e-07
    ## 158    Regional              river   Small 1.500019e-07
    ## 159    Regional freshwatersediment   Small 1.500019e-07
    ## 161    Regional        naturalsoil   Solid 5.000000e-09
    ## 162    Regional              river   Solid 5.000000e-09
    ## 164    Regional   agriculturalsoil   Small 1.500019e-07
    ## 165    Regional          deepocean   Solid 5.000000e-09
    ## 166    Regional   agriculturalsoil   Solid 5.000000e-09
    ## 167    Regional         cloudwater   Solid 5.000000e-09
    ## 169    Regional     marinesediment   Large 1.280000e-04
    ## 170    Regional                sea   Large 3.000000e-06
    ## 171    Regional               lake   Large 3.000000e-06
    ## 173    Regional          othersoil   Large 1.280000e-04
    ## 174    Regional          deepocean   Small 1.500019e-07
    ## 175    Regional          othersoil   Small 1.500019e-07
    ## 176    Regional                sea   Small 1.500019e-07
    ## 177    Regional               lake   Small 1.500019e-07
    ## 178    Regional freshwatersediment   Large 1.280000e-04
    ## 179    Regional                sea   Solid 5.000000e-09
    ## 181    Regional          othersoil   Solid 5.000000e-09
    ## 182    Regional     marinesediment   Solid 5.000000e-09
    ## 183    Regional               lake   Solid 5.000000e-09
    ## 185    Regional       lakesediment   Solid 5.000000e-09
    ## 189      Tropic     marinesediment   Large 1.280000e-04
    ## 190      Tropic freshwatersediment   Small 1.500019e-07
    ## 191      Tropic       lakesediment   Small 1.500019e-07
    ## 192      Tropic               lake   Solid 5.000000e-09
    ## 195      Tropic                sea   Large 3.000000e-06
    ## 197      Tropic         cloudwater   Large 9.000001e-07
    ## 198      Tropic          deepocean   Large 3.000000e-06
    ## 200      Tropic   agriculturalsoil   Solid 5.000000e-09
    ## 201      Tropic freshwatersediment   Solid 5.000000e-09
    ## 203      Tropic   agriculturalsoil   Small 1.500019e-07
    ## 204      Tropic                air   Solid 5.000000e-09
    ## 205      Tropic     marinesediment   Small 1.500019e-07
    ## 207      Tropic                air   Large 9.000001e-07
    ## 208      Tropic          deepocean   Small 1.500019e-07
    ## 209      Tropic        naturalsoil   Small 1.500019e-07
    ## 210      Tropic                air   Small 4.537267e-08
    ## 211      Tropic     marinesediment   Solid 5.000000e-09
    ## 212      Tropic          othersoil   Large 1.280000e-04
    ## 213      Tropic                sea   Solid 5.000000e-09
    ## 214      Tropic freshwatersediment   Large 1.280000e-04
    ## 215      Tropic              river   Solid 5.000000e-09
    ## 216      Tropic               lake   Large 3.000000e-06
    ## 217      Tropic        naturalsoil   Solid 5.000000e-09
    ## 219      Tropic                sea   Small 1.500019e-07
    ## 221      Tropic        naturalsoil   Large 1.280000e-04
    ## 223      Tropic              river   Small 1.500019e-07
    ## 224      Tropic       lakesediment   Large 1.280000e-04
    ## 225      Tropic          othersoil   Solid 5.000000e-09
    ## 227      Tropic              river   Large 3.000000e-06
    ## 228      Tropic         cloudwater   Solid 5.000000e-09
    ## 229      Tropic   agriculturalsoil   Large 1.280000e-04
    ## 230      Tropic          deepocean   Solid 5.000000e-09
    ## 232      Tropic          othersoil   Small 1.500019e-07
    ## 234      Tropic       lakesediment   Solid 5.000000e-09
    ## 235      Tropic               lake   Small 1.500019e-07

``` r
World$NewCalcVariable("rho_species")
World$CalcVar("rho_species")
```

    ##           Scale         SubCompart Species rho_species
    ## 2        Arctic          othersoil   Small    2000.315
    ## 3        Arctic          deepocean   Large    2500.000
    ## 4        Arctic               lake   Solid   10500.000
    ## 5        Arctic        naturalsoil   Solid   10500.000
    ## 9        Arctic                sea   Small    2000.315
    ## 11       Arctic       lakesediment   Small    2000.315
    ## 12       Arctic       lakesediment   Solid   10500.000
    ## 13       Arctic          deepocean   Solid   10500.000
    ## 14       Arctic              river   Small    2000.315
    ## 17       Arctic                sea   Large    2500.000
    ## 19       Arctic          othersoil   Large    2500.000
    ## 20       Arctic              river   Solid   10500.000
    ## 21       Arctic                air   Large    2000.001
    ## 22       Arctic        naturalsoil   Large    2500.000
    ## 23       Arctic freshwatersediment   Solid   10500.000
    ## 24       Arctic freshwatersediment   Small    2000.315
    ## 26       Arctic              river   Large    2500.000
    ## 27       Arctic         cloudwater   Solid   10500.000
    ## 28       Arctic          othersoil   Solid   10500.000
    ## 29       Arctic         cloudwater   Large    2000.001
    ## 30       Arctic                sea   Solid   10500.000
    ## 31       Arctic               lake   Large    2500.000
    ## 34       Arctic                air   Solid   10500.000
    ## 35       Arctic               lake   Small    2000.315
    ## 36       Arctic                air   Small    2007.444
    ## 38       Arctic     marinesediment   Small    2000.315
    ## 39       Arctic   agriculturalsoil   Solid   10500.000
    ## 42       Arctic     marinesediment   Solid   10500.000
    ## 44       Arctic        naturalsoil   Small    2000.315
    ## 45       Arctic   agriculturalsoil   Small    2000.315
    ## 46       Arctic          deepocean   Small    2000.315
    ## 47       Arctic   agriculturalsoil   Large    2500.000
    ## 48  Continental   agriculturalsoil   Large    2500.000
    ## 52  Continental          deepocean   Small    2000.315
    ## 54  Continental     marinesediment   Solid   10500.000
    ## 55  Continental         cloudwater   Large    2000.001
    ## 56  Continental   agriculturalsoil   Small    2000.315
    ## 58  Continental                sea   Large    2500.000
    ## 60  Continental freshwatersediment   Small    2000.315
    ## 61  Continental       lakesediment   Solid   10500.000
    ## 62  Continental freshwatersediment   Solid   10500.000
    ## 64  Continental     marinesediment   Small    2000.315
    ## 66  Continental               lake   Solid   10500.000
    ## 68  Continental   agriculturalsoil   Solid   10500.000
    ## 69  Continental               lake   Large    2500.000
    ## 70  Continental        naturalsoil   Small    2000.315
    ## 71  Continental          deepocean   Solid   10500.000
    ## 72  Continental          deepocean   Large    2500.000
    ## 73  Continental                air   Solid   10500.000
    ## 74  Continental                air   Large    2000.001
    ## 76  Continental                air   Small    2007.444
    ## 78  Continental                sea   Small    2000.315
    ## 79  Continental               lake   Small    2000.315
    ## 80  Continental          othersoil   Small    2000.315
    ## 82  Continental              river   Small    2000.315
    ## 83  Continental          othersoil   Solid   10500.000
    ## 84  Continental              river   Large    2500.000
    ## 86  Continental              river   Solid   10500.000
    ## 87  Continental        naturalsoil   Solid   10500.000
    ## 88  Continental       lakesediment   Small    2000.315
    ## 90  Continental                sea   Solid   10500.000
    ## 91  Continental        naturalsoil   Large    2500.000
    ## 93  Continental          othersoil   Large    2500.000
    ## 94  Continental         cloudwater   Solid   10500.000
    ## 95     Moderate   agriculturalsoil   Solid   10500.000
    ## 97     Moderate                air   Solid   10500.000
    ## 98     Moderate               lake   Small    2000.315
    ## 100    Moderate                air   Large    2000.001
    ## 101    Moderate          deepocean   Solid   10500.000
    ## 104    Moderate                air   Small    2007.444
    ## 105    Moderate   agriculturalsoil   Small    2000.315
    ## 106    Moderate          deepocean   Large    2500.000
    ## 107    Moderate       lakesediment   Small    2000.315
    ## 110    Moderate              river   Large    2500.000
    ## 111    Moderate        naturalsoil   Small    2000.315
    ## 112    Moderate         cloudwater   Solid   10500.000
    ## 114    Moderate         cloudwater   Large    2000.001
    ## 116    Moderate   agriculturalsoil   Large    2500.000
    ## 117    Moderate     marinesediment   Small    2000.315
    ## 118    Moderate               lake   Large    2500.000
    ## 119    Moderate          othersoil   Small    2000.315
    ## 120    Moderate        naturalsoil   Solid   10500.000
    ## 121    Moderate                sea   Small    2000.315
    ## 122    Moderate          deepocean   Small    2000.315
    ## 124    Moderate       lakesediment   Solid   10500.000
    ## 125    Moderate freshwatersediment   Small    2000.315
    ## 126    Moderate               lake   Solid   10500.000
    ## 127    Moderate              river   Small    2000.315
    ## 130    Moderate freshwatersediment   Solid   10500.000
    ## 132    Moderate     marinesediment   Solid   10500.000
    ## 133    Moderate          othersoil   Solid   10500.000
    ## 135    Moderate        naturalsoil   Large    2500.000
    ## 136    Moderate          othersoil   Large    2500.000
    ## 137    Moderate                sea   Solid   10500.000
    ## 139    Moderate              river   Solid   10500.000
    ## 140    Moderate                sea   Large    2500.000
    ## 142    Regional   agriculturalsoil   Large    2500.000
    ## 143    Regional         cloudwater   Solid   10500.000
    ## 144    Regional                air   Solid   10500.000
    ## 145    Regional freshwatersediment   Small    2000.315
    ## 146    Regional                air   Large    2000.001
    ## 148    Regional        naturalsoil   Solid   10500.000
    ## 149    Regional   agriculturalsoil   Solid   10500.000
    ## 151    Regional                air   Small    2007.444
    ## 152    Regional              river   Large    2500.000
    ## 155    Regional        naturalsoil   Large    2500.000
    ## 156    Regional         cloudwater   Large    2000.001
    ## 158    Regional        naturalsoil   Small    2000.315
    ## 159    Regional          deepocean   Large    2500.000
    ## 160    Regional   agriculturalsoil   Small    2000.315
    ## 161    Regional freshwatersediment   Solid   10500.000
    ## 163    Regional       lakesediment   Solid   10500.000
    ## 166    Regional     marinesediment   Solid   10500.000
    ## 168    Regional               lake   Solid   10500.000
    ## 170    Regional               lake   Large    2500.000
    ## 171    Regional              river   Small    2000.315
    ## 174    Regional                sea   Small    2000.315
    ## 175    Regional               lake   Small    2000.315
    ## 176    Regional     marinesediment   Small    2000.315
    ## 177    Regional          deepocean   Small    2000.315
    ## 178    Regional          othersoil   Small    2000.315
    ## 180    Regional          othersoil   Solid   10500.000
    ## 181    Regional       lakesediment   Small    2000.315
    ## 182    Regional                sea   Solid   10500.000
    ## 183    Regional          deepocean   Solid   10500.000
    ## 185    Regional          othersoil   Large    2500.000
    ## 186    Regional                sea   Large    2500.000
    ## 188    Regional              river   Solid   10500.000
    ## 189      Tropic   agriculturalsoil   Large    2500.000
    ## 191      Tropic        naturalsoil   Small    2000.315
    ## 192      Tropic          deepocean   Large    2500.000
    ## 193      Tropic         cloudwater   Large    2000.001
    ## 194      Tropic freshwatersediment   Solid   10500.000
    ## 195      Tropic       lakesediment   Solid   10500.000
    ## 197      Tropic     marinesediment   Small    2000.315
    ## 198      Tropic   agriculturalsoil   Small    2000.315
    ## 199      Tropic         cloudwater   Solid   10500.000
    ## 200      Tropic                air   Large    2000.001
    ## 202      Tropic   agriculturalsoil   Solid   10500.000
    ## 203      Tropic freshwatersediment   Small    2000.315
    ## 204      Tropic                air   Small    2007.444
    ## 205      Tropic               lake   Solid   10500.000
    ## 208      Tropic               lake   Large    2500.000
    ## 209      Tropic               lake   Small    2000.315
    ## 211      Tropic                sea   Small    2000.315
    ## 212      Tropic          othersoil   Small    2000.315
    ## 214      Tropic          deepocean   Solid   10500.000
    ## 215      Tropic                sea   Solid   10500.000
    ## 216      Tropic              river   Large    2500.000
    ## 217      Tropic       lakesediment   Small    2000.315
    ## 218      Tropic              river   Small    2000.315
    ## 219      Tropic          othersoil   Large    2500.000
    ## 220      Tropic                sea   Large    2500.000
    ## 222      Tropic                air   Solid   10500.000
    ## 227      Tropic          deepocean   Small    2000.315
    ## 228      Tropic          othersoil   Solid   10500.000
    ## 229      Tropic        naturalsoil   Large    2500.000
    ## 231      Tropic     marinesediment   Solid   10500.000
    ## 233      Tropic        naturalsoil   Solid   10500.000
    ## 234      Tropic              river   Solid   10500.000

``` r
World$fetchData("Temp")
```

    ##         Scale Temp
    ## 1      Arctic  263
    ## 2 Continental  285
    ## 3    Moderate  285
    ## 4    Regional  285
    ## 5      Tropic  298

``` r
World$fetchData("alpha.surf")
```

    ##          SubCompart alpha.surf
    ## 6  agriculturalsoil        1.2
    ## 7       naturalsoil        1.0
    ## 8         othersoil        1.5
    ## 10             lake      100.0
    ## 11            river      100.0
    ## 12              sea      100.0

``` r
# Cunningham calculated using f_Cunningham

# World$fetchData("SettlingVelocity")
World$NewCalcVariable("SettlingVelocity")
World$CalcVar("SettlingVelocity")
```

    ##     SubCompart       Scale Species SettlingVelocity
    ## 21         air Continental   Small     1.526439e-06
    ## 22         air      Arctic   Solid     7.237741e-07
    ## 23         air    Regional   Large     2.112548e-04
    ## 24         air      Arctic   Large     2.112548e-04
    ## 25         air    Moderate   Large     2.112548e-04
    ## 26         air      Tropic   Large     2.112548e-04
    ## 27         air      Tropic   Small     1.526439e-06
    ## 28         air      Tropic   Solid     7.237741e-07
    ## 29         air      Arctic   Small     1.526439e-06
    ## 30         air    Moderate   Small     1.526439e-06
    ## 31         air    Moderate   Solid     7.237741e-07
    ## 32         air Continental   Solid     7.237741e-07
    ## 33         air    Regional   Small     1.526439e-06
    ## 34         air    Regional   Solid     7.237741e-07
    ## 35         air Continental   Large     2.112548e-04
    ## 42  cloudwater      Tropic   Solid     2.860122e-08
    ## 44  cloudwater    Regional   Solid     2.860122e-08
    ## 45  cloudwater      Arctic   Solid     2.860122e-08
    ## 46  cloudwater    Moderate   Solid     2.860122e-08
    ## 47  cloudwater Continental   Solid     2.860122e-08
    ## 48  cloudwater      Tropic   Large     9.771989e-05
    ## 49  cloudwater      Arctic   Large     9.771989e-05
    ## 50  cloudwater    Moderate   Large     9.771989e-05
    ## 51  cloudwater Continental   Large     9.771989e-05
    ## 52  cloudwater    Regional   Large     9.771989e-05
    ## 56   deepocean Continental   Small     4.904986e-08
    ## 57   deepocean      Arctic   Small     4.904986e-08
    ## 58   deepocean Continental   Solid     5.166489e-10
    ## 59   deepocean      Arctic   Solid     5.166489e-10
    ## 60   deepocean      Tropic   Solid     5.166489e-10
    ## 61   deepocean      Tropic   Large     2.940038e-05
    ## 62   deepocean      Tropic   Small     4.904986e-08
    ## 64   deepocean    Regional   Solid     5.166489e-10
    ## 67   deepocean    Regional   Small     4.904986e-08
    ## 69   deepocean Continental   Large     2.940038e-05
    ## 70   deepocean    Regional   Large     2.940038e-05
    ## 71   deepocean      Arctic   Large     2.940038e-05
    ## 72   deepocean    Moderate   Large     2.940038e-05
    ## 73   deepocean    Moderate   Small     4.904986e-08
    ## 74   deepocean    Moderate   Solid     5.166489e-10
    ## 96        lake      Tropic   Large     2.940038e-05
    ## 97        lake    Regional   Large     2.940038e-05
    ## 98        lake Continental   Large     2.940038e-05
    ## 99        lake    Regional   Small     4.904986e-08
    ## 100       lake      Arctic   Large     2.940038e-05
    ## 101       lake      Arctic   Small     4.904986e-08
    ## 102       lake      Tropic   Small     4.904986e-08
    ## 103       lake      Tropic   Solid     5.166489e-10
    ## 105       lake    Regional   Solid     5.166489e-10
    ## 108       lake Continental   Small     4.904986e-08
    ## 110       lake    Moderate   Large     2.940038e-05
    ## 111       lake    Moderate   Small     4.904986e-08
    ## 112       lake    Moderate   Solid     5.166489e-10
    ## 113       lake      Arctic   Solid     5.166489e-10
    ## 115       lake Continental   Solid     5.166489e-10
    ## 196      river      Tropic   Large     2.940038e-05
    ## 197      river Continental   Large     2.940038e-05
    ## 198      river    Regional   Large     2.940038e-05
    ## 199      river    Moderate   Large     2.940038e-05
    ## 200      river      Arctic   Large     2.940038e-05
    ## 201      river      Arctic   Small     4.904986e-08
    ## 202      river      Arctic   Solid     5.166489e-10
    ## 208      river Continental   Small     4.904986e-08
    ## 209      river Continental   Solid     5.166489e-10
    ## 210      river    Regional   Small     4.904986e-08
    ## 211      river    Moderate   Small     4.904986e-08
    ## 212      river    Moderate   Solid     5.166489e-10
    ## 213      river      Tropic   Solid     5.166489e-10
    ## 214      river    Regional   Solid     5.166489e-10
    ## 215      river      Tropic   Small     4.904986e-08
    ## 216        sea      Arctic   Solid     5.166489e-10
    ## 217        sea Continental   Small     4.904986e-08
    ## 220        sea    Moderate   Solid     5.166489e-10
    ## 221        sea Continental   Solid     5.166489e-10
    ## 222        sea      Arctic   Small     4.904986e-08
    ## 223        sea    Moderate   Small     4.904986e-08
    ## 224        sea Continental   Large     2.940038e-05
    ## 226        sea    Regional   Small     4.904986e-08
    ## 227        sea    Regional   Solid     5.166489e-10
    ## 229        sea    Regional   Large     2.940038e-05
    ## 230        sea      Arctic   Large     2.940038e-05
    ## 231        sea    Moderate   Large     2.940038e-05
    ## 232        sea      Tropic   Large     2.940038e-05
    ## 233        sea      Tropic   Small     4.904986e-08
    ## 234        sea      Tropic   Solid     5.166489e-10

``` r
World$fetchData("gamma.surf")
```

    ##          SubCompart gamma.surf
    ## 6  agriculturalsoil       0.54
    ## 7       naturalsoil       0.56
    ## 8         othersoil       0.56
    ## 10             lake       0.50
    ## 11            river       0.50
    ## 12              sea       0.50

``` r
World$fetchData("FricVel")
```

    ## [1] 0.19

``` r
World$fetchData("SubCompartName")
```

    ##            SubCompart     SubCompartName
    ## 1                 air                air
    ## 2          cloudwater         cloudwater
    ## 3  freshwatersediment freshwatersediment
    ## 4        lakesediment       lakesediment
    ## 5      marinesediment     marinesediment
    ## 6    agriculturalsoil   agriculturalsoil
    ## 7         naturalsoil        naturalsoil
    ## 8           othersoil          othersoil
    ## 9           deepocean          deepocean
    ## 10               lake               lake
    ## 11              river              river
    ## 12                sea                sea

## Calculation of Dry Deposition rate constant for particulates

The implementation follows the LOTOS-EUROS v2.0 2016 guidance for dry
deposition of particles. This does mean there might be small deviations
from the current implementation in SimpleBox4nano xlsx.

``` r
World$FromDataAndTo("k_DryDeposition")
```

    ##     fromSubCompart         process     toSubCompart   fromScale     toScale
    ## 121            air k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 122     cloudwater k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 123            air k_DryDeposition             lake      Arctic      Arctic
    ## 124     cloudwater k_DryDeposition             lake      Arctic      Arctic
    ## 125            air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 126     cloudwater k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 127            air k_DryDeposition        othersoil      Arctic      Arctic
    ## 128     cloudwater k_DryDeposition        othersoil      Arctic      Arctic
    ## 129            air k_DryDeposition            river      Arctic      Arctic
    ## 130     cloudwater k_DryDeposition            river      Arctic      Arctic
    ## 131            air k_DryDeposition              sea      Arctic      Arctic
    ## 132     cloudwater k_DryDeposition              sea      Arctic      Arctic
    ## 133            air k_DryDeposition agriculturalsoil Continental Continental
    ## 134     cloudwater k_DryDeposition agriculturalsoil Continental Continental
    ## 135            air k_DryDeposition             lake Continental Continental
    ## 136     cloudwater k_DryDeposition             lake Continental Continental
    ## 137            air k_DryDeposition      naturalsoil Continental Continental
    ## 138     cloudwater k_DryDeposition      naturalsoil Continental Continental
    ## 139            air k_DryDeposition        othersoil Continental Continental
    ## 140     cloudwater k_DryDeposition        othersoil Continental Continental
    ## 141            air k_DryDeposition            river Continental Continental
    ## 142     cloudwater k_DryDeposition            river Continental Continental
    ## 143            air k_DryDeposition              sea Continental Continental
    ## 144     cloudwater k_DryDeposition              sea Continental Continental
    ## 145            air k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 146     cloudwater k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 147            air k_DryDeposition             lake    Moderate    Moderate
    ## 148     cloudwater k_DryDeposition             lake    Moderate    Moderate
    ## 149            air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 150     cloudwater k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 151            air k_DryDeposition        othersoil    Moderate    Moderate
    ## 152     cloudwater k_DryDeposition        othersoil    Moderate    Moderate
    ## 153            air k_DryDeposition            river    Moderate    Moderate
    ## 154     cloudwater k_DryDeposition            river    Moderate    Moderate
    ## 155            air k_DryDeposition              sea    Moderate    Moderate
    ## 156     cloudwater k_DryDeposition              sea    Moderate    Moderate
    ## 157            air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 158     cloudwater k_DryDeposition agriculturalsoil    Regional    Regional
    ## 159            air k_DryDeposition             lake    Regional    Regional
    ## 160     cloudwater k_DryDeposition             lake    Regional    Regional
    ## 161            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 162     cloudwater k_DryDeposition      naturalsoil    Regional    Regional
    ## 163            air k_DryDeposition        othersoil    Regional    Regional
    ## 164     cloudwater k_DryDeposition        othersoil    Regional    Regional
    ## 165            air k_DryDeposition            river    Regional    Regional
    ## 166     cloudwater k_DryDeposition            river    Regional    Regional
    ## 167            air k_DryDeposition              sea    Regional    Regional
    ## 168     cloudwater k_DryDeposition              sea    Regional    Regional
    ## 169            air k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 170     cloudwater k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 171            air k_DryDeposition             lake      Tropic      Tropic
    ## 172     cloudwater k_DryDeposition             lake      Tropic      Tropic
    ## 173            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 174     cloudwater k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 175            air k_DryDeposition        othersoil      Tropic      Tropic
    ## 176     cloudwater k_DryDeposition        othersoil      Tropic      Tropic
    ## 177            air k_DryDeposition            river      Tropic      Tropic
    ## 178     cloudwater k_DryDeposition            river      Tropic      Tropic
    ## 179            air k_DryDeposition              sea      Tropic      Tropic
    ## 180     cloudwater k_DryDeposition              sea      Tropic      Tropic
    ## 181            air k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 182     cloudwater k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 183            air k_DryDeposition             lake      Arctic      Arctic
    ## 184     cloudwater k_DryDeposition             lake      Arctic      Arctic
    ## 185            air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 186     cloudwater k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 187            air k_DryDeposition        othersoil      Arctic      Arctic
    ## 188     cloudwater k_DryDeposition        othersoil      Arctic      Arctic
    ## 189            air k_DryDeposition            river      Arctic      Arctic
    ## 190     cloudwater k_DryDeposition            river      Arctic      Arctic
    ## 191            air k_DryDeposition              sea      Arctic      Arctic
    ## 192     cloudwater k_DryDeposition              sea      Arctic      Arctic
    ## 193            air k_DryDeposition agriculturalsoil Continental Continental
    ## 194     cloudwater k_DryDeposition agriculturalsoil Continental Continental
    ## 195            air k_DryDeposition             lake Continental Continental
    ## 196     cloudwater k_DryDeposition             lake Continental Continental
    ## 197            air k_DryDeposition      naturalsoil Continental Continental
    ## 198     cloudwater k_DryDeposition      naturalsoil Continental Continental
    ## 199            air k_DryDeposition        othersoil Continental Continental
    ## 200     cloudwater k_DryDeposition        othersoil Continental Continental
    ## 201            air k_DryDeposition            river Continental Continental
    ## 202     cloudwater k_DryDeposition            river Continental Continental
    ## 203            air k_DryDeposition              sea Continental Continental
    ## 204     cloudwater k_DryDeposition              sea Continental Continental
    ## 205            air k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 206     cloudwater k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 207            air k_DryDeposition             lake    Moderate    Moderate
    ## 208     cloudwater k_DryDeposition             lake    Moderate    Moderate
    ## 209            air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 210     cloudwater k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 211            air k_DryDeposition        othersoil    Moderate    Moderate
    ## 212     cloudwater k_DryDeposition        othersoil    Moderate    Moderate
    ## 213            air k_DryDeposition            river    Moderate    Moderate
    ## 214     cloudwater k_DryDeposition            river    Moderate    Moderate
    ## 215            air k_DryDeposition              sea    Moderate    Moderate
    ## 216     cloudwater k_DryDeposition              sea    Moderate    Moderate
    ## 217            air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 218     cloudwater k_DryDeposition agriculturalsoil    Regional    Regional
    ## 219            air k_DryDeposition             lake    Regional    Regional
    ## 220     cloudwater k_DryDeposition             lake    Regional    Regional
    ## 221            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 222     cloudwater k_DryDeposition      naturalsoil    Regional    Regional
    ## 223            air k_DryDeposition        othersoil    Regional    Regional
    ## 224     cloudwater k_DryDeposition        othersoil    Regional    Regional
    ## 225            air k_DryDeposition            river    Regional    Regional
    ## 226     cloudwater k_DryDeposition            river    Regional    Regional
    ## 227            air k_DryDeposition              sea    Regional    Regional
    ## 228     cloudwater k_DryDeposition              sea    Regional    Regional
    ## 229            air k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 230     cloudwater k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 231            air k_DryDeposition             lake      Tropic      Tropic
    ## 232     cloudwater k_DryDeposition             lake      Tropic      Tropic
    ## 233            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 234     cloudwater k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 235            air k_DryDeposition        othersoil      Tropic      Tropic
    ## 236     cloudwater k_DryDeposition        othersoil      Tropic      Tropic
    ## 237            air k_DryDeposition            river      Tropic      Tropic
    ## 238     cloudwater k_DryDeposition            river      Tropic      Tropic
    ## 239            air k_DryDeposition              sea      Tropic      Tropic
    ## 240     cloudwater k_DryDeposition              sea      Tropic      Tropic
    ## 241            air k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 242     cloudwater k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 243            air k_DryDeposition             lake      Arctic      Arctic
    ## 244     cloudwater k_DryDeposition             lake      Arctic      Arctic
    ## 245            air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 246     cloudwater k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 247            air k_DryDeposition        othersoil      Arctic      Arctic
    ## 248     cloudwater k_DryDeposition        othersoil      Arctic      Arctic
    ## 249            air k_DryDeposition            river      Arctic      Arctic
    ## 250     cloudwater k_DryDeposition            river      Arctic      Arctic
    ## 251            air k_DryDeposition              sea      Arctic      Arctic
    ## 252     cloudwater k_DryDeposition              sea      Arctic      Arctic
    ## 253            air k_DryDeposition agriculturalsoil Continental Continental
    ## 254     cloudwater k_DryDeposition agriculturalsoil Continental Continental
    ## 255            air k_DryDeposition             lake Continental Continental
    ## 256     cloudwater k_DryDeposition             lake Continental Continental
    ## 257            air k_DryDeposition      naturalsoil Continental Continental
    ## 258     cloudwater k_DryDeposition      naturalsoil Continental Continental
    ## 259            air k_DryDeposition        othersoil Continental Continental
    ## 260     cloudwater k_DryDeposition        othersoil Continental Continental
    ## 261            air k_DryDeposition            river Continental Continental
    ## 262     cloudwater k_DryDeposition            river Continental Continental
    ## 263            air k_DryDeposition              sea Continental Continental
    ## 264     cloudwater k_DryDeposition              sea Continental Continental
    ## 265            air k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 266     cloudwater k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 267            air k_DryDeposition             lake    Moderate    Moderate
    ## 268     cloudwater k_DryDeposition             lake    Moderate    Moderate
    ## 269            air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 270     cloudwater k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 271            air k_DryDeposition        othersoil    Moderate    Moderate
    ## 272     cloudwater k_DryDeposition        othersoil    Moderate    Moderate
    ## 273            air k_DryDeposition            river    Moderate    Moderate
    ## 274     cloudwater k_DryDeposition            river    Moderate    Moderate
    ## 275            air k_DryDeposition              sea    Moderate    Moderate
    ## 276     cloudwater k_DryDeposition              sea    Moderate    Moderate
    ## 277            air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 278     cloudwater k_DryDeposition agriculturalsoil    Regional    Regional
    ## 279            air k_DryDeposition             lake    Regional    Regional
    ## 280     cloudwater k_DryDeposition             lake    Regional    Regional
    ## 281            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 282     cloudwater k_DryDeposition      naturalsoil    Regional    Regional
    ## 283            air k_DryDeposition        othersoil    Regional    Regional
    ## 284     cloudwater k_DryDeposition        othersoil    Regional    Regional
    ## 285            air k_DryDeposition            river    Regional    Regional
    ## 286     cloudwater k_DryDeposition            river    Regional    Regional
    ## 287            air k_DryDeposition              sea    Regional    Regional
    ## 288     cloudwater k_DryDeposition              sea    Regional    Regional
    ## 289            air k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 290     cloudwater k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 291            air k_DryDeposition             lake      Tropic      Tropic
    ## 292     cloudwater k_DryDeposition             lake      Tropic      Tropic
    ## 293            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 294     cloudwater k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 295            air k_DryDeposition        othersoil      Tropic      Tropic
    ## 296     cloudwater k_DryDeposition        othersoil      Tropic      Tropic
    ## 297            air k_DryDeposition            river      Tropic      Tropic
    ## 298     cloudwater k_DryDeposition            river      Tropic      Tropic
    ## 299            air k_DryDeposition              sea      Tropic      Tropic
    ## 300     cloudwater k_DryDeposition              sea      Tropic      Tropic
    ## 301            air k_DryDeposition agriculturalsoil      Arctic      Arctic
    ## 303            air k_DryDeposition             lake      Arctic      Arctic
    ## 305            air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 307            air k_DryDeposition        othersoil      Arctic      Arctic
    ## 309            air k_DryDeposition            river      Arctic      Arctic
    ## 311            air k_DryDeposition              sea      Arctic      Arctic
    ## 313            air k_DryDeposition agriculturalsoil Continental Continental
    ## 315            air k_DryDeposition             lake Continental Continental
    ## 317            air k_DryDeposition      naturalsoil Continental Continental
    ## 319            air k_DryDeposition        othersoil Continental Continental
    ## 321            air k_DryDeposition            river Continental Continental
    ## 323            air k_DryDeposition              sea Continental Continental
    ## 325            air k_DryDeposition agriculturalsoil    Moderate    Moderate
    ## 327            air k_DryDeposition             lake    Moderate    Moderate
    ## 329            air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 331            air k_DryDeposition        othersoil    Moderate    Moderate
    ## 333            air k_DryDeposition            river    Moderate    Moderate
    ## 335            air k_DryDeposition              sea    Moderate    Moderate
    ## 337            air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 339            air k_DryDeposition             lake    Regional    Regional
    ## 341            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 343            air k_DryDeposition        othersoil    Regional    Regional
    ## 345            air k_DryDeposition            river    Regional    Regional
    ## 347            air k_DryDeposition              sea    Regional    Regional
    ## 349            air k_DryDeposition agriculturalsoil      Tropic      Tropic
    ## 351            air k_DryDeposition             lake      Tropic      Tropic
    ## 353            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 355            air k_DryDeposition        othersoil      Tropic      Tropic
    ## 357            air k_DryDeposition            river      Tropic      Tropic
    ## 359            air k_DryDeposition              sea      Tropic      Tropic
    ##     fromSpecies toSpecies
    ## 121       Large     Large
    ## 122       Large     Large
    ## 123       Large     Large
    ## 124       Large     Large
    ## 125       Large     Large
    ## 126       Large     Large
    ## 127       Large     Large
    ## 128       Large     Large
    ## 129       Large     Large
    ## 130       Large     Large
    ## 131       Large     Large
    ## 132       Large     Large
    ## 133       Large     Large
    ## 134       Large     Large
    ## 135       Large     Large
    ## 136       Large     Large
    ## 137       Large     Large
    ## 138       Large     Large
    ## 139       Large     Large
    ## 140       Large     Large
    ## 141       Large     Large
    ## 142       Large     Large
    ## 143       Large     Large
    ## 144       Large     Large
    ## 145       Large     Large
    ## 146       Large     Large
    ## 147       Large     Large
    ## 148       Large     Large
    ## 149       Large     Large
    ## 150       Large     Large
    ## 151       Large     Large
    ## 152       Large     Large
    ## 153       Large     Large
    ## 154       Large     Large
    ## 155       Large     Large
    ## 156       Large     Large
    ## 157       Large     Large
    ## 158       Large     Large
    ## 159       Large     Large
    ## 160       Large     Large
    ## 161       Large     Large
    ## 162       Large     Large
    ## 163       Large     Large
    ## 164       Large     Large
    ## 165       Large     Large
    ## 166       Large     Large
    ## 167       Large     Large
    ## 168       Large     Large
    ## 169       Large     Large
    ## 170       Large     Large
    ## 171       Large     Large
    ## 172       Large     Large
    ## 173       Large     Large
    ## 174       Large     Large
    ## 175       Large     Large
    ## 176       Large     Large
    ## 177       Large     Large
    ## 178       Large     Large
    ## 179       Large     Large
    ## 180       Large     Large
    ## 181       Small     Small
    ## 182       Small     Small
    ## 183       Small     Small
    ## 184       Small     Small
    ## 185       Small     Small
    ## 186       Small     Small
    ## 187       Small     Small
    ## 188       Small     Small
    ## 189       Small     Small
    ## 190       Small     Small
    ## 191       Small     Small
    ## 192       Small     Small
    ## 193       Small     Small
    ## 194       Small     Small
    ## 195       Small     Small
    ## 196       Small     Small
    ## 197       Small     Small
    ## 198       Small     Small
    ## 199       Small     Small
    ## 200       Small     Small
    ## 201       Small     Small
    ## 202       Small     Small
    ## 203       Small     Small
    ## 204       Small     Small
    ## 205       Small     Small
    ## 206       Small     Small
    ## 207       Small     Small
    ## 208       Small     Small
    ## 209       Small     Small
    ## 210       Small     Small
    ## 211       Small     Small
    ## 212       Small     Small
    ## 213       Small     Small
    ## 214       Small     Small
    ## 215       Small     Small
    ## 216       Small     Small
    ## 217       Small     Small
    ## 218       Small     Small
    ## 219       Small     Small
    ## 220       Small     Small
    ## 221       Small     Small
    ## 222       Small     Small
    ## 223       Small     Small
    ## 224       Small     Small
    ## 225       Small     Small
    ## 226       Small     Small
    ## 227       Small     Small
    ## 228       Small     Small
    ## 229       Small     Small
    ## 230       Small     Small
    ## 231       Small     Small
    ## 232       Small     Small
    ## 233       Small     Small
    ## 234       Small     Small
    ## 235       Small     Small
    ## 236       Small     Small
    ## 237       Small     Small
    ## 238       Small     Small
    ## 239       Small     Small
    ## 240       Small     Small
    ## 241       Solid     Solid
    ## 242       Solid     Solid
    ## 243       Solid     Solid
    ## 244       Solid     Solid
    ## 245       Solid     Solid
    ## 246       Solid     Solid
    ## 247       Solid     Solid
    ## 248       Solid     Solid
    ## 249       Solid     Solid
    ## 250       Solid     Solid
    ## 251       Solid     Solid
    ## 252       Solid     Solid
    ## 253       Solid     Solid
    ## 254       Solid     Solid
    ## 255       Solid     Solid
    ## 256       Solid     Solid
    ## 257       Solid     Solid
    ## 258       Solid     Solid
    ## 259       Solid     Solid
    ## 260       Solid     Solid
    ## 261       Solid     Solid
    ## 262       Solid     Solid
    ## 263       Solid     Solid
    ## 264       Solid     Solid
    ## 265       Solid     Solid
    ## 266       Solid     Solid
    ## 267       Solid     Solid
    ## 268       Solid     Solid
    ## 269       Solid     Solid
    ## 270       Solid     Solid
    ## 271       Solid     Solid
    ## 272       Solid     Solid
    ## 273       Solid     Solid
    ## 274       Solid     Solid
    ## 275       Solid     Solid
    ## 276       Solid     Solid
    ## 277       Solid     Solid
    ## 278       Solid     Solid
    ## 279       Solid     Solid
    ## 280       Solid     Solid
    ## 281       Solid     Solid
    ## 282       Solid     Solid
    ## 283       Solid     Solid
    ## 284       Solid     Solid
    ## 285       Solid     Solid
    ## 286       Solid     Solid
    ## 287       Solid     Solid
    ## 288       Solid     Solid
    ## 289       Solid     Solid
    ## 290       Solid     Solid
    ## 291       Solid     Solid
    ## 292       Solid     Solid
    ## 293       Solid     Solid
    ## 294       Solid     Solid
    ## 295       Solid     Solid
    ## 296       Solid     Solid
    ## 297       Solid     Solid
    ## 298       Solid     Solid
    ## 299       Solid     Solid
    ## 300       Solid     Solid
    ## 301     Unbound   Unbound
    ## 303     Unbound   Unbound
    ## 305     Unbound   Unbound
    ## 307     Unbound   Unbound
    ## 309     Unbound   Unbound
    ## 311     Unbound   Unbound
    ## 313     Unbound   Unbound
    ## 315     Unbound   Unbound
    ## 317     Unbound   Unbound
    ## 319     Unbound   Unbound
    ## 321     Unbound   Unbound
    ## 323     Unbound   Unbound
    ## 325     Unbound   Unbound
    ## 327     Unbound   Unbound
    ## 329     Unbound   Unbound
    ## 331     Unbound   Unbound
    ## 333     Unbound   Unbound
    ## 335     Unbound   Unbound
    ## 337     Unbound   Unbound
    ## 339     Unbound   Unbound
    ## 341     Unbound   Unbound
    ## 343     Unbound   Unbound
    ## 345     Unbound   Unbound
    ## 347     Unbound   Unbound
    ## 349     Unbound   Unbound
    ## 351     Unbound   Unbound
    ## 353     Unbound   Unbound
    ## 355     Unbound   Unbound
    ## 357     Unbound   Unbound
    ## 359     Unbound   Unbound

``` r
testProc <- World$NewProcess("k_DryDeposition")
testProc$execute()
```

    ##     fromSubCompart         process     toSubCompart   fromScale     toScale
    ## 5              air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 11             air k_DryDeposition              sea      Arctic      Arctic
    ## 13             air k_DryDeposition agriculturalsoil Continental Continental
    ## 15             air k_DryDeposition             lake Continental Continental
    ## 17             air k_DryDeposition      naturalsoil Continental Continental
    ## 19             air k_DryDeposition        othersoil Continental Continental
    ## 21             air k_DryDeposition            river Continental Continental
    ## 23             air k_DryDeposition              sea Continental Continental
    ## 29             air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 35             air k_DryDeposition              sea    Moderate    Moderate
    ## 37             air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 39             air k_DryDeposition             lake    Regional    Regional
    ## 41             air k_DryDeposition      naturalsoil    Regional    Regional
    ## 43             air k_DryDeposition        othersoil    Regional    Regional
    ## 45             air k_DryDeposition            river    Regional    Regional
    ## 47             air k_DryDeposition              sea    Regional    Regional
    ## 53             air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 59             air k_DryDeposition              sea      Tropic      Tropic
    ## 65             air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 71             air k_DryDeposition              sea      Arctic      Arctic
    ## 73             air k_DryDeposition agriculturalsoil Continental Continental
    ## 75             air k_DryDeposition             lake Continental Continental
    ## 77             air k_DryDeposition      naturalsoil Continental Continental
    ## 79             air k_DryDeposition        othersoil Continental Continental
    ## 81             air k_DryDeposition            river Continental Continental
    ## 83             air k_DryDeposition              sea Continental Continental
    ## 89             air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 95             air k_DryDeposition              sea    Moderate    Moderate
    ## 97             air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 99             air k_DryDeposition             lake    Regional    Regional
    ## 101            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 103            air k_DryDeposition        othersoil    Regional    Regional
    ## 105            air k_DryDeposition            river    Regional    Regional
    ## 107            air k_DryDeposition              sea    Regional    Regional
    ## 113            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 119            air k_DryDeposition              sea      Tropic      Tropic
    ## 125            air k_DryDeposition      naturalsoil      Arctic      Arctic
    ## 131            air k_DryDeposition              sea      Arctic      Arctic
    ## 133            air k_DryDeposition agriculturalsoil Continental Continental
    ## 135            air k_DryDeposition             lake Continental Continental
    ## 137            air k_DryDeposition      naturalsoil Continental Continental
    ## 139            air k_DryDeposition        othersoil Continental Continental
    ## 141            air k_DryDeposition            river Continental Continental
    ## 143            air k_DryDeposition              sea Continental Continental
    ## 149            air k_DryDeposition      naturalsoil    Moderate    Moderate
    ## 155            air k_DryDeposition              sea    Moderate    Moderate
    ## 157            air k_DryDeposition agriculturalsoil    Regional    Regional
    ## 159            air k_DryDeposition             lake    Regional    Regional
    ## 161            air k_DryDeposition      naturalsoil    Regional    Regional
    ## 163            air k_DryDeposition        othersoil    Regional    Regional
    ## 165            air k_DryDeposition            river    Regional    Regional
    ## 167            air k_DryDeposition              sea    Regional    Regional
    ## 173            air k_DryDeposition      naturalsoil      Tropic      Tropic
    ## 179            air k_DryDeposition              sea      Tropic      Tropic
    ##     fromSpecies toSpecies            k
    ## 5         Large     Large 8.492013e-08
    ## 11        Large     Large 1.548152e-07
    ## 13        Large     Large 6.158321e-08
    ## 15        Large     Large 3.123184e-10
    ## 17        Large     Large 2.775298e-08
    ## 19        Large     Large 1.023044e-08
    ## 21        Large     Large 3.435503e-09
    ## 23        Large     Large 1.330980e-07
    ## 29        Large     Large 1.061502e-07
    ## 35        Large     Large 1.290127e-07
    ## 37        Large     Large 1.266401e-07
    ## 39        Large     Large 6.422536e-10
    ## 41        Large     Large 5.707141e-08
    ## 43        Large     Large 2.103794e-08
    ## 45        Large     Large 7.064790e-09
    ## 47        Large     Large 1.123951e-09
    ## 53        Large     Large 6.369012e-08
    ## 59        Large     Large 1.806178e-07
    ## 65        Small     Small 6.113966e-10
    ## 71        Small     Small 9.294596e-10
    ## 73        Small     Small 4.446369e-10
    ## 75        Small     Small 1.875749e-12
    ## 77        Small     Small 1.998238e-10
    ## 79        Small     Small 7.400352e-11
    ## 81        Small     Small 2.063324e-11
    ## 83        Small     Small 7.993718e-10
    ## 89        Small     Small 7.642902e-10
    ## 95        Small     Small 7.748358e-10
    ## 97        Small     Small 9.143543e-10
    ## 99        Small     Small 3.857303e-12
    ## 101       Small     Small 4.109189e-10
    ## 103       Small     Small 1.521813e-10
    ## 105       Small     Small 4.243033e-11
    ## 107       Small     Small 6.750323e-12
    ## 113       Small     Small 4.585895e-10
    ## 119       Small     Small 1.085000e-09
    ## 125       Solid     Solid 2.918985e-10
    ## 131       Solid     Solid 4.591951e-10
    ## 133       Solid     Solid 2.137437e-10
    ## 135       Solid     Solid 9.283237e-13
    ## 137       Solid     Solid 9.543198e-11
    ## 139       Solid     Solid 3.534486e-11
    ## 141       Solid     Solid 1.021156e-11
    ## 143       Solid     Solid 3.956157e-10
    ## 149       Solid     Solid 3.650103e-10
    ## 155       Solid     Solid 3.834726e-10
    ## 157       Solid     Solid 4.395440e-10
    ## 159       Solid     Solid 1.909011e-12
    ## 161       Solid     Solid 1.962470e-10
    ## 163       Solid     Solid 7.268340e-11
    ## 165       Solid     Solid 2.099912e-11
    ## 167       Solid     Solid 3.340790e-12
    ## 173       Solid     Solid 2.190534e-10
    ## 179       Solid     Solid 5.375111e-10

## Calculation of Wet Deposition rate constant for particulates

For wet deposition there are two steps where the particulates are first
scavenged into an intermediate cloud water compartment after which they
deposit to soil or surface water.

``` r
# #init default core (World) with classic states, and classic kaas
# substance <- "nAg_10nm"  #use a nano material, otherwise it only encounters Molecular
# excelReference <- "data/20210331 SimpleBox4nano_rev006.xlsx"
# source("baseScripts/initTestWorld.R")
# 
# lapply(c("rho_species", "rad_species"), function(FuName){
#   World$NewCalcVariable(FuName)
#   World$CalcVar(FuName)
# })
# World$fetchData("Temp")

World$fetchData("NaturalRho")
```

    ##            SubCompart Species NaturalRho
    ## 1                 air   Large       2000
    ## 2          cloudwater   Large       2000
    ## 4  freshwatersediment   Small       2000
    ## 6        lakesediment   Small       2000
    ## 8      marinesediment   Small       2000
    ## 9    agriculturalsoil   Large       2500
    ## 10   agriculturalsoil   Small       2000
    ## 11        naturalsoil   Large       2500
    ## 12        naturalsoil   Small       2000
    ## 13          othersoil   Large       2500
    ## 14          othersoil   Small       2000
    ## 16          deepocean   Large       2500
    ## 17          deepocean   Small       2000
    ## 19               lake   Large       2500
    ## 20               lake   Small       2000
    ## 22              river   Large       2500
    ## 23              river   Small       2000
    ## 25                sea   Large       2500
    ## 26                sea   Small       2000

``` r
World$fetchData("SettlingVelocity") 
```

    ##           Scale SubCompart Species SettlingVelocity
    ## 4        Arctic        air   Large     2.112548e-04
    ## 5        Arctic        air   Small     1.526439e-06
    ## 6        Arctic        air   Solid     7.237741e-07
    ## 7        Arctic cloudwater   Large     9.771989e-05
    ## 8        Arctic cloudwater   Solid     2.860122e-08
    ## 9        Arctic  deepocean   Large     2.940038e-05
    ## 10       Arctic  deepocean   Small     4.904986e-08
    ## 11       Arctic  deepocean   Solid     5.166489e-10
    ## 15       Arctic       lake   Large     2.940038e-05
    ## 16       Arctic       lake   Small     4.904986e-08
    ## 17       Arctic       lake   Solid     5.166489e-10
    ## 30       Arctic      river   Large     2.940038e-05
    ## 31       Arctic      river   Small     4.904986e-08
    ## 32       Arctic      river   Solid     5.166489e-10
    ## 33       Arctic        sea   Large     2.940038e-05
    ## 34       Arctic        sea   Small     4.904986e-08
    ## 35       Arctic        sea   Solid     5.166489e-10
    ## 39  Continental        air   Large     2.112548e-04
    ## 40  Continental        air   Small     1.526439e-06
    ## 41  Continental        air   Solid     7.237741e-07
    ## 42  Continental cloudwater   Large     9.771989e-05
    ## 43  Continental cloudwater   Solid     2.860122e-08
    ## 44  Continental  deepocean   Large     2.940038e-05
    ## 45  Continental  deepocean   Small     4.904986e-08
    ## 46  Continental  deepocean   Solid     5.166489e-10
    ## 50  Continental       lake   Large     2.940038e-05
    ## 51  Continental       lake   Small     4.904986e-08
    ## 52  Continental       lake   Solid     5.166489e-10
    ## 65  Continental      river   Large     2.940038e-05
    ## 66  Continental      river   Small     4.904986e-08
    ## 67  Continental      river   Solid     5.166489e-10
    ## 68  Continental        sea   Large     2.940038e-05
    ## 69  Continental        sea   Small     4.904986e-08
    ## 70  Continental        sea   Solid     5.166489e-10
    ## 74     Moderate        air   Large     2.112548e-04
    ## 75     Moderate        air   Small     1.526439e-06
    ## 76     Moderate        air   Solid     7.237741e-07
    ## 77     Moderate cloudwater   Large     9.771989e-05
    ## 78     Moderate cloudwater   Solid     2.860122e-08
    ## 79     Moderate  deepocean   Large     2.940038e-05
    ## 80     Moderate  deepocean   Small     4.904986e-08
    ## 81     Moderate  deepocean   Solid     5.166489e-10
    ## 85     Moderate       lake   Large     2.940038e-05
    ## 86     Moderate       lake   Small     4.904986e-08
    ## 87     Moderate       lake   Solid     5.166489e-10
    ## 100    Moderate      river   Large     2.940038e-05
    ## 101    Moderate      river   Small     4.904986e-08
    ## 102    Moderate      river   Solid     5.166489e-10
    ## 103    Moderate        sea   Large     2.940038e-05
    ## 104    Moderate        sea   Small     4.904986e-08
    ## 105    Moderate        sea   Solid     5.166489e-10
    ## 109    Regional        air   Large     2.112548e-04
    ## 110    Regional        air   Small     1.526439e-06
    ## 111    Regional        air   Solid     7.237741e-07
    ## 112    Regional cloudwater   Large     9.771989e-05
    ## 113    Regional cloudwater   Solid     2.860122e-08
    ## 114    Regional  deepocean   Large     2.940038e-05
    ## 115    Regional  deepocean   Small     4.904986e-08
    ## 116    Regional  deepocean   Solid     5.166489e-10
    ## 120    Regional       lake   Large     2.940038e-05
    ## 121    Regional       lake   Small     4.904986e-08
    ## 122    Regional       lake   Solid     5.166489e-10
    ## 135    Regional      river   Large     2.940038e-05
    ## 136    Regional      river   Small     4.904986e-08
    ## 137    Regional      river   Solid     5.166489e-10
    ## 138    Regional        sea   Large     2.940038e-05
    ## 139    Regional        sea   Small     4.904986e-08
    ## 140    Regional        sea   Solid     5.166489e-10
    ## 144      Tropic        air   Large     2.112548e-04
    ## 145      Tropic        air   Small     1.526439e-06
    ## 146      Tropic        air   Solid     7.237741e-07
    ## 147      Tropic cloudwater   Large     9.771989e-05
    ## 148      Tropic cloudwater   Solid     2.860122e-08
    ## 149      Tropic  deepocean   Large     2.940038e-05
    ## 150      Tropic  deepocean   Small     4.904986e-08
    ## 151      Tropic  deepocean   Solid     5.166489e-10
    ## 155      Tropic       lake   Large     2.940038e-05
    ## 156      Tropic       lake   Small     4.904986e-08
    ## 157      Tropic       lake   Solid     5.166489e-10
    ## 170      Tropic      river   Large     2.940038e-05
    ## 171      Tropic      river   Small     4.904986e-08
    ## 172      Tropic      river   Solid     5.166489e-10
    ## 173      Tropic        sea   Large     2.940038e-05
    ## 174      Tropic        sea   Small     4.904986e-08
    ## 175      Tropic        sea   Solid     5.166489e-10

``` r
World$fetchData("rhoMatrix")
```

    ##            SubCompart rhoMatrix
    ## 1                 air     1.225
    ## 2          cloudwater   998.000
    ## 3  freshwatersediment  2500.000
    ## 4        lakesediment  2500.000
    ## 5      marinesediment  2500.000
    ## 6    agriculturalsoil  2500.000
    ## 7         naturalsoil  2500.000
    ## 8           othersoil  2500.000
    ## 9           deepocean   998.000
    ## 10               lake   998.000
    ## 11              river   998.000
    ## 12                sea   998.000

``` r
World$fetchData("RAINrate")
```

    ##         Scale     RAINrate
    ## 1      Arctic 7.927448e-09
    ## 2 Continental 2.219685e-08
    ## 3    Moderate 2.219685e-08
    ## 4    Regional 2.219685e-08
    ## 5      Tropic 4.122273e-08

``` r
World$fetchData("FRACtwet")
```

    ##         Scale FRACtwet
    ## 1      Arctic        1
    ## 2 Continental        1
    ## 3    Moderate        1
    ## 4    Regional        1
    ## 5      Tropic        1

``` r
World$fetchData("tdry")
```

    ##         Scale   tdry
    ## 1      Arctic 285120
    ## 2 Continental 285120
    ## 3    Moderate 285120
    ## 4    Regional 285120
    ## 5      Tropic 285120

``` r
World$fetchData("twet")
```

    ##         Scale     twet
    ## 1      Arctic 18199.15
    ## 2 Continental 18199.15
    ## 3    Moderate 18199.15
    ## 4    Regional 18199.15
    ## 5      Tropic 18199.15

``` r
World$fetchData("COLLECTeff")
```

    ##         Scale COLLECTeff
    ## 1      Arctic      2e+05
    ## 2 Continental      2e+05
    ## 3    Moderate      2e+05
    ## 4    Regional      2e+05
    ## 5      Tropic      2e+05

``` r
World$FromDataAndTo("k_CWscavenging")
```

    ##    fromSubCompart        process toSubCompart   fromScale     toScale
    ## 21            air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 22     cloudwater k_CWscavenging   cloudwater      Arctic      Arctic
    ## 23            air k_CWscavenging   cloudwater Continental Continental
    ## 24     cloudwater k_CWscavenging   cloudwater Continental Continental
    ## 25            air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 26     cloudwater k_CWscavenging   cloudwater    Moderate    Moderate
    ## 27            air k_CWscavenging   cloudwater    Regional    Regional
    ## 28     cloudwater k_CWscavenging   cloudwater    Regional    Regional
    ## 29            air k_CWscavenging   cloudwater      Tropic      Tropic
    ## 30     cloudwater k_CWscavenging   cloudwater      Tropic      Tropic
    ## 31            air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 32     cloudwater k_CWscavenging   cloudwater      Arctic      Arctic
    ## 33            air k_CWscavenging   cloudwater Continental Continental
    ## 34     cloudwater k_CWscavenging   cloudwater Continental Continental
    ## 35            air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 36     cloudwater k_CWscavenging   cloudwater    Moderate    Moderate
    ## 37            air k_CWscavenging   cloudwater    Regional    Regional
    ## 38     cloudwater k_CWscavenging   cloudwater    Regional    Regional
    ## 39            air k_CWscavenging   cloudwater      Tropic      Tropic
    ## 40     cloudwater k_CWscavenging   cloudwater      Tropic      Tropic
    ## 41            air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 42     cloudwater k_CWscavenging   cloudwater      Arctic      Arctic
    ## 43            air k_CWscavenging   cloudwater Continental Continental
    ## 44     cloudwater k_CWscavenging   cloudwater Continental Continental
    ## 45            air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 46     cloudwater k_CWscavenging   cloudwater    Moderate    Moderate
    ## 47            air k_CWscavenging   cloudwater    Regional    Regional
    ## 48     cloudwater k_CWscavenging   cloudwater    Regional    Regional
    ## 49            air k_CWscavenging   cloudwater      Tropic      Tropic
    ## 50     cloudwater k_CWscavenging   cloudwater      Tropic      Tropic
    ##    fromSpecies toSpecies
    ## 21       Large     Large
    ## 22       Large     Large
    ## 23       Large     Large
    ## 24       Large     Large
    ## 25       Large     Large
    ## 26       Large     Large
    ## 27       Large     Large
    ## 28       Large     Large
    ## 29       Large     Large
    ## 30       Large     Large
    ## 31       Small     Small
    ## 32       Small     Small
    ## 33       Small     Small
    ## 34       Small     Small
    ## 35       Small     Small
    ## 36       Small     Small
    ## 37       Small     Small
    ## 38       Small     Small
    ## 39       Small     Small
    ## 40       Small     Small
    ## 41       Solid     Solid
    ## 42       Solid     Solid
    ## 43       Solid     Solid
    ## 44       Solid     Solid
    ## 45       Solid     Solid
    ## 46       Solid     Solid
    ## 47       Solid     Solid
    ## 48       Solid     Solid
    ## 49       Solid     Solid
    ## 50       Solid     Solid

``` r
testProc <- World$NewProcess("k_CWscavenging")
# debugonce(k_CWscavenging)
# testProc$execute(debugAt = list(fromScale = "Regional"))
testProc$execute()
```

    ## Warning in private$Execute(debugAt): input data ignored; not all rad_species in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all rho_species in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all to.rhoMatrix
    ## in FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all from.rhoMatrix
    ## in FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all from.DynVisc
    ## in FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all to.DynVisc in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all
    ## from.SettlingVelocity in FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all Matrix in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all SpeciesName in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all VertDistance
    ## in FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all SubCompartName
    ## in FromDataAndTo

    ##    fromSubCompart        process toSubCompart   fromScale     toScale
    ## 1             air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 3             air k_CWscavenging   cloudwater Continental Continental
    ## 5             air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 7             air k_CWscavenging   cloudwater    Regional    Regional
    ## 9             air k_CWscavenging   cloudwater      Tropic      Tropic
    ## 11            air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 13            air k_CWscavenging   cloudwater Continental Continental
    ## 15            air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 17            air k_CWscavenging   cloudwater    Regional    Regional
    ## 19            air k_CWscavenging   cloudwater      Tropic      Tropic
    ## 21            air k_CWscavenging   cloudwater      Arctic      Arctic
    ## 23            air k_CWscavenging   cloudwater Continental Continental
    ## 25            air k_CWscavenging   cloudwater    Moderate    Moderate
    ## 27            air k_CWscavenging   cloudwater    Regional    Regional
    ## 29            air k_CWscavenging   cloudwater      Tropic      Tropic
    ##    fromSpecies toSpecies            k
    ## 1        Large     Large 2.642483e-05
    ## 3        Large     Large 7.398951e-05
    ## 5        Large     Large 7.398951e-05
    ## 7        Large     Large 7.398951e-05
    ## 9        Large     Large 1.374091e-04
    ## 11       Small     Small 1.044477e-07
    ## 13       Small     Small 1.748115e-07
    ## 15       Small     Small 1.748115e-07
    ## 17       Small     Small 1.748115e-07
    ## 19       Small     Small 2.382617e-07
    ## 21       Solid     Solid 1.149450e-08
    ## 23       Solid     Solid 1.923438e-08
    ## 25       Solid     Solid 1.923438e-08
    ## 27       Solid     Solid 1.923438e-08
    ## 29       Solid     Solid 2.621240e-08

``` r
# debug(testProc$execute())

#calculation of kaas is by executing a process
# testClass <- World$NewProcess("k_CWscavenging")
# testClass$execute(list())



# debug(testClass$execute)
# testClass$execute(debugAt = list()) #an empty list always triggers
#testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
```

``` r
World$FromDataAndTo("k_WetDeposition")
```

    ##             process fromSubCompart     toSubCompart   fromScale     toScale
    ## 61  k_WetDeposition     cloudwater agriculturalsoil      Arctic      Arctic
    ## 62  k_WetDeposition     cloudwater             lake      Arctic      Arctic
    ## 63  k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 64  k_WetDeposition     cloudwater        othersoil      Arctic      Arctic
    ## 65  k_WetDeposition     cloudwater            river      Arctic      Arctic
    ## 66  k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 67  k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 68  k_WetDeposition     cloudwater             lake Continental Continental
    ## 69  k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 70  k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 71  k_WetDeposition     cloudwater            river Continental Continental
    ## 72  k_WetDeposition     cloudwater              sea Continental Continental
    ## 73  k_WetDeposition     cloudwater agriculturalsoil    Moderate    Moderate
    ## 74  k_WetDeposition     cloudwater             lake    Moderate    Moderate
    ## 75  k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 76  k_WetDeposition     cloudwater        othersoil    Moderate    Moderate
    ## 77  k_WetDeposition     cloudwater            river    Moderate    Moderate
    ## 78  k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 79  k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 80  k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 81  k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 82  k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 83  k_WetDeposition     cloudwater            river    Regional    Regional
    ## 84  k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 85  k_WetDeposition     cloudwater agriculturalsoil      Tropic      Tropic
    ## 86  k_WetDeposition     cloudwater             lake      Tropic      Tropic
    ## 87  k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 88  k_WetDeposition     cloudwater        othersoil      Tropic      Tropic
    ## 89  k_WetDeposition     cloudwater            river      Tropic      Tropic
    ## 90  k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ## 91  k_WetDeposition     cloudwater agriculturalsoil      Arctic      Arctic
    ## 92  k_WetDeposition     cloudwater             lake      Arctic      Arctic
    ## 93  k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 94  k_WetDeposition     cloudwater        othersoil      Arctic      Arctic
    ## 95  k_WetDeposition     cloudwater            river      Arctic      Arctic
    ## 96  k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 97  k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 98  k_WetDeposition     cloudwater             lake Continental Continental
    ## 99  k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 100 k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 101 k_WetDeposition     cloudwater            river Continental Continental
    ## 102 k_WetDeposition     cloudwater              sea Continental Continental
    ## 103 k_WetDeposition     cloudwater agriculturalsoil    Moderate    Moderate
    ## 104 k_WetDeposition     cloudwater             lake    Moderate    Moderate
    ## 105 k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 106 k_WetDeposition     cloudwater        othersoil    Moderate    Moderate
    ## 107 k_WetDeposition     cloudwater            river    Moderate    Moderate
    ## 108 k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 109 k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 110 k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 111 k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 112 k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 113 k_WetDeposition     cloudwater            river    Regional    Regional
    ## 114 k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 115 k_WetDeposition     cloudwater agriculturalsoil      Tropic      Tropic
    ## 116 k_WetDeposition     cloudwater             lake      Tropic      Tropic
    ## 117 k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 118 k_WetDeposition     cloudwater        othersoil      Tropic      Tropic
    ## 119 k_WetDeposition     cloudwater            river      Tropic      Tropic
    ## 120 k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ## 121 k_WetDeposition     cloudwater agriculturalsoil      Arctic      Arctic
    ## 122 k_WetDeposition     cloudwater             lake      Arctic      Arctic
    ## 123 k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 124 k_WetDeposition     cloudwater        othersoil      Arctic      Arctic
    ## 125 k_WetDeposition     cloudwater            river      Arctic      Arctic
    ## 126 k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 127 k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 128 k_WetDeposition     cloudwater             lake Continental Continental
    ## 129 k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 130 k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 131 k_WetDeposition     cloudwater            river Continental Continental
    ## 132 k_WetDeposition     cloudwater              sea Continental Continental
    ## 133 k_WetDeposition     cloudwater agriculturalsoil    Moderate    Moderate
    ## 134 k_WetDeposition     cloudwater             lake    Moderate    Moderate
    ## 135 k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 136 k_WetDeposition     cloudwater        othersoil    Moderate    Moderate
    ## 137 k_WetDeposition     cloudwater            river    Moderate    Moderate
    ## 138 k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 139 k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 140 k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 141 k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 142 k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 143 k_WetDeposition     cloudwater            river    Regional    Regional
    ## 144 k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 145 k_WetDeposition     cloudwater agriculturalsoil      Tropic      Tropic
    ## 146 k_WetDeposition     cloudwater             lake      Tropic      Tropic
    ## 147 k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 148 k_WetDeposition     cloudwater        othersoil      Tropic      Tropic
    ## 149 k_WetDeposition     cloudwater            river      Tropic      Tropic
    ## 150 k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ##     fromSpecies toSpecies
    ## 61        Large     Large
    ## 62        Large     Large
    ## 63        Large     Large
    ## 64        Large     Large
    ## 65        Large     Large
    ## 66        Large     Large
    ## 67        Large     Large
    ## 68        Large     Large
    ## 69        Large     Large
    ## 70        Large     Large
    ## 71        Large     Large
    ## 72        Large     Large
    ## 73        Large     Large
    ## 74        Large     Large
    ## 75        Large     Large
    ## 76        Large     Large
    ## 77        Large     Large
    ## 78        Large     Large
    ## 79        Large     Large
    ## 80        Large     Large
    ## 81        Large     Large
    ## 82        Large     Large
    ## 83        Large     Large
    ## 84        Large     Large
    ## 85        Large     Large
    ## 86        Large     Large
    ## 87        Large     Large
    ## 88        Large     Large
    ## 89        Large     Large
    ## 90        Large     Large
    ## 91        Small     Small
    ## 92        Small     Small
    ## 93        Small     Small
    ## 94        Small     Small
    ## 95        Small     Small
    ## 96        Small     Small
    ## 97        Small     Small
    ## 98        Small     Small
    ## 99        Small     Small
    ## 100       Small     Small
    ## 101       Small     Small
    ## 102       Small     Small
    ## 103       Small     Small
    ## 104       Small     Small
    ## 105       Small     Small
    ## 106       Small     Small
    ## 107       Small     Small
    ## 108       Small     Small
    ## 109       Small     Small
    ## 110       Small     Small
    ## 111       Small     Small
    ## 112       Small     Small
    ## 113       Small     Small
    ## 114       Small     Small
    ## 115       Small     Small
    ## 116       Small     Small
    ## 117       Small     Small
    ## 118       Small     Small
    ## 119       Small     Small
    ## 120       Small     Small
    ## 121       Solid     Solid
    ## 122       Solid     Solid
    ## 123       Solid     Solid
    ## 124       Solid     Solid
    ## 125       Solid     Solid
    ## 126       Solid     Solid
    ## 127       Solid     Solid
    ## 128       Solid     Solid
    ## 129       Solid     Solid
    ## 130       Solid     Solid
    ## 131       Solid     Solid
    ## 132       Solid     Solid
    ## 133       Solid     Solid
    ## 134       Solid     Solid
    ## 135       Solid     Solid
    ## 136       Solid     Solid
    ## 137       Solid     Solid
    ## 138       Solid     Solid
    ## 139       Solid     Solid
    ## 140       Solid     Solid
    ## 141       Solid     Solid
    ## 142       Solid     Solid
    ## 143       Solid     Solid
    ## 144       Solid     Solid
    ## 145       Solid     Solid
    ## 146       Solid     Solid
    ## 147       Solid     Solid
    ## 148       Solid     Solid
    ## 149       Solid     Solid
    ## 150       Solid     Solid

``` r
testProc <- World$NewProcess("k_WetDeposition")
testProc$execute()
```

    ## Warning in private$Execute(debugAt): input data ignored; not all to.Area in
    ## FromDataAndTo

    ## Warning in private$Execute(debugAt): input data ignored; not all from.Volume in
    ## FromDataAndTo

    ##            process fromSubCompart     toSubCompart   fromScale     toScale
    ## 3  k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 6  k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 7  k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 8  k_WetDeposition     cloudwater             lake Continental Continental
    ## 9  k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 10 k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 11 k_WetDeposition     cloudwater            river Continental Continental
    ## 12 k_WetDeposition     cloudwater              sea Continental Continental
    ## 15 k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 18 k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 19 k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 20 k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 21 k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 22 k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 23 k_WetDeposition     cloudwater            river    Regional    Regional
    ## 24 k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 27 k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 30 k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ## 33 k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 36 k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 37 k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 38 k_WetDeposition     cloudwater             lake Continental Continental
    ## 39 k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 40 k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 41 k_WetDeposition     cloudwater            river Continental Continental
    ## 42 k_WetDeposition     cloudwater              sea Continental Continental
    ## 45 k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 48 k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 49 k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 50 k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 51 k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 52 k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 53 k_WetDeposition     cloudwater            river    Regional    Regional
    ## 54 k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 57 k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 60 k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ## 63 k_WetDeposition     cloudwater      naturalsoil      Arctic      Arctic
    ## 66 k_WetDeposition     cloudwater              sea      Arctic      Arctic
    ## 67 k_WetDeposition     cloudwater agriculturalsoil Continental Continental
    ## 68 k_WetDeposition     cloudwater             lake Continental Continental
    ## 69 k_WetDeposition     cloudwater      naturalsoil Continental Continental
    ## 70 k_WetDeposition     cloudwater        othersoil Continental Continental
    ## 71 k_WetDeposition     cloudwater            river Continental Continental
    ## 72 k_WetDeposition     cloudwater              sea Continental Continental
    ## 75 k_WetDeposition     cloudwater      naturalsoil    Moderate    Moderate
    ## 78 k_WetDeposition     cloudwater              sea    Moderate    Moderate
    ## 79 k_WetDeposition     cloudwater agriculturalsoil    Regional    Regional
    ## 80 k_WetDeposition     cloudwater             lake    Regional    Regional
    ## 81 k_WetDeposition     cloudwater      naturalsoil    Regional    Regional
    ## 82 k_WetDeposition     cloudwater        othersoil    Regional    Regional
    ## 83 k_WetDeposition     cloudwater            river    Regional    Regional
    ## 84 k_WetDeposition     cloudwater              sea    Regional    Regional
    ## 87 k_WetDeposition     cloudwater      naturalsoil      Tropic      Tropic
    ## 90 k_WetDeposition     cloudwater              sea      Tropic      Tropic
    ##    fromSpecies toSpecies            k
    ## 3        Large     Large 1.056993e-05
    ## 6        Large     Large 1.585490e-05
    ## 7        Large     Large 2.149397e-05
    ## 8        Large     Large 8.955819e-08
    ## 9        Large     Large 9.672284e-06
    ## 10       Large     Large 3.582328e-06
    ## 11       Large     Large 9.851401e-07
    ## 12       Large     Large 3.816624e-05
    ## 15       Large     Large 3.699476e-05
    ## 18       Large     Large 3.699476e-05
    ## 19       Large     Large 4.420033e-05
    ## 20       Large     Large 1.841680e-07
    ## 21       Large     Large 1.989015e-05
    ## 22       Large     Large 7.366722e-06
    ## 23       Large     Large 2.025849e-06
    ## 24       Large     Large 3.222961e-07
    ## 27       Large     Large 4.122273e-05
    ## 30       Large     Large 9.618637e-05
    ## 33       Small     Small 1.056993e-05
    ## 36       Small     Small 1.585490e-05
    ## 37       Small     Small 2.149397e-05
    ## 38       Small     Small 8.955819e-08
    ## 39       Small     Small 9.672284e-06
    ## 40       Small     Small 3.582328e-06
    ## 41       Small     Small 9.851401e-07
    ## 42       Small     Small 3.816624e-05
    ## 45       Small     Small 3.699476e-05
    ## 48       Small     Small 3.699476e-05
    ## 49       Small     Small 4.420033e-05
    ## 50       Small     Small 1.841680e-07
    ## 51       Small     Small 1.989015e-05
    ## 52       Small     Small 7.366722e-06
    ## 53       Small     Small 2.025849e-06
    ## 54       Small     Small 3.222961e-07
    ## 57       Small     Small 4.122273e-05
    ## 60       Small     Small 9.618637e-05
    ## 63       Solid     Solid 1.056993e-05
    ## 66       Solid     Solid 1.585490e-05
    ## 67       Solid     Solid 2.149397e-05
    ## 68       Solid     Solid 8.955819e-08
    ## 69       Solid     Solid 9.672284e-06
    ## 70       Solid     Solid 3.582328e-06
    ## 71       Solid     Solid 9.851401e-07
    ## 72       Solid     Solid 3.816624e-05
    ## 75       Solid     Solid 3.699476e-05
    ## 78       Solid     Solid 3.699476e-05
    ## 79       Solid     Solid 4.420033e-05
    ## 80       Solid     Solid 1.841680e-07
    ## 81       Solid     Solid 1.989015e-05
    ## 82       Solid     Solid 7.366722e-06
    ## 83       Solid     Solid 2.025849e-06
    ## 84       Solid     Solid 3.222961e-07
    ## 87       Solid     Solid 4.122273e-05
    ## 90       Solid     Solid 9.618637e-05
