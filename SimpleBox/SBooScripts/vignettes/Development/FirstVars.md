Introduction to SB-variables
================
Jaap Slootweg, Valerie de Rijk
11/23/2022

# Variables in SimpleBox

are read initially, but you can add variables just by defining the
function how to calculate the variable. This vignette will demonstrate
how the variable “volume” is defined, how it can be retrieved, and how
to verify it against the values in the excel-version. First step is to
initiate testing objects by running a standard script
baseScripts/initTestWorld.R. We will use two objects that are created:
“World” and “ClassicExcel”. Note the class properties and the
inheritance of ClassicExcel.

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

``` r
class(World)
```

    ## [1] "SBcore" "R6"

SimpleBox Variables (SBVs) are defined by a function, and many of the
defining functions are present in the package. One of the variable
defining functions is “Volume”. The method NewCalcVariable adds the
SimpleBox variable; it needs the name (as character) of the function.

``` r
Volume
```

    ## function (VertDistance, Area, FRACcldw, SubCompartName) 
    ## {
    ##     if (SubCompartName == "air") {
    ##         VertDistance * Area * (1 - FRACcldw)
    ##     }
    ##     else if (SubCompartName == "cloudwater") {
    ##         VertDistance * Area * FRACcldw
    ##     }
    ##     else VertDistance * Area
    ## }
    ## <bytecode: 0x55951d5803f0>

``` r
World$NewCalcVariable("Volume")
```

R “knows” the parameters of a function, see the function formals(). The
names of these parameters are also SBVs, partly already read from data
in the initialisation. You can lookup which variables are known, and
their values by method fetchData(varname) of the class SBcore. World, as
initiated in the baseScript initWorld.R is of this class. An empty
varname (the parameter for this method) returns all known parameters.
Note that variable are usually data.frames (tables), with keyfields
indicating the domain of the variable.

## Atomic functions and tables

Note that variables are usually tables, including the key fields
defining their domain (except constants) but the parameters in the
functions are atomic. This means you can treat it as a simple number or
character; its not the table, not even a vector! This makes writing a
SBV defining function a lot easier, think of the “normal” if()
situations that need the ifelse() functions. The variable defining
functions are called by SBOO for each relevant combination of the
variables. Results, when not NA, are stored in the in-memory database of
SBOO.

``` r
formals(Volume)
```

    ## $VertDistance
    ## 
    ## 
    ## $Area
    ## 
    ## 
    ## $FRACcldw
    ## 
    ## 
    ## $SubCompartName

``` r
World$fetchData()
```

    ##   [1] "a"                         "a"                        
    ##   [3] "AbbrC"                     "AbbrP"                    
    ##   [5] "AEROresist"                "AEROSOLdeprate"           
    ##   [7] "AirFlow"                   "alpha.surf"               
    ##   [9] "Area"                      "AreaLand"                 
    ##  [11] "AreaSea"                   "b"                        
    ##  [13] "b"                         "BACTcomp"                 
    ##  [15] "BACTtest"                  "beta.a"                   
    ##  [17] "Biodeg"                    "C.OHrad"                  
    ##  [19] "C.OHrad.n"                 "ChemClass"                
    ##  [21] "COL"                       "COLLECTeff"               
    ##  [23] "ColRad"                    "Compartment"              
    ##  [25] "ContinentalInModerate"     "Corg"                     
    ##  [27] "CORG.susp"                 "CorgStandard"             
    ##  [29] "D"                         "DefaultFRACarea"          
    ##  [31] "DefaultNETsedrate"         "DefaultpH"                
    ##  [33] "Description"               "Df"                       
    ##  [35] "Dimension"                 "dischargeFRAC"            
    ##  [37] "DragMethod"                "DynViscAirStandard"       
    ##  [39] "DynViscWaterStandard"      "Ea.OHrad"                 
    ##  [41] "epsilon"                   "Erosion"                  
    ##  [43] "EROSIONsoil"               "FlowName"                 
    ##  [45] "forWhich"                  "FRACa"                    
    ##  [47] "FRACcldw"                  "FRACinf"                  
    ##  [49] "FracROWatComp"             "FRACrun"                  
    ##  [51] "FRACs"                     "FRACsea"                  
    ##  [53] "FRACtwet"                  "FRACw"                    
    ##  [55] "FricVel"                   "FRinaers"                 
    ##  [57] "FRinaerw"                  "FRingas"                  
    ##  [59] "FRinw"                     "fromScale"                
    ##  [61] "fromSubCompart"            "FRorig"                   
    ##  [63] "FRorig_spw"                "gamma.surf"               
    ##  [65] "H0sol"                     "hamakerSP.w"              
    ##  [67] "Intermediate_side"         "k_Adsorption"             
    ##  [69] "k_CWscavenging"            "k_Deposition"             
    ##  [71] "k_DryDeposition"           "k_HeteroAgglomeration.a"  
    ##  [73] "k_HeteroAgglomeration.wsd" "k_Leaching"               
    ##  [75] "k_Removal"                 "k_Runoff"                 
    ##  [77] "k_Volatilisation"          "k_WetDeposition"          
    ##  [79] "k0.OHrad"                  "Kacompw"                  
    ##  [81] "Kaers"                     "Kaerw"                    
    ##  [83] "Kaw25"                     "kdeg"                     
    ##  [85] "KdegDorC"                  "Kow"                      
    ##  [87] "Kow_default"               "Kp"                       
    ##  [89] "Kp.col"                    "Kp.sed"                   
    ##  [91] "Kp.soil"                   "Kp.susp"                  
    ##  [93] "KpCOL"                     "Kscompw"                  
    ##  [95] "Ksdcompw"                  "Ksw"                      
    ##  [97] "Ksw.alt"                   "KswDorC"                  
    ##  [99] "kwsd"                      "kwsd.sed"                 
    ## [101] "kwsd.water"                "LakeFracRiver"            
    ## [103] "landFRAC"                  "Longest_side"             
    ## [105] "Mackay1"                   "Mackay2"                  
    ## [107] "Matrix"                    "MaxPvap"                  
    ## [109] "MOLMASSAIR"                "MTC_2a"                   
    ## [111] "MTC_2s"                    "MTC_2sd"                  
    ## [113] "MTC_2w"                    "MW"                       
    ## [115] "NaturalPart"               "NETsedrate"               
    ## [117] "NotInGlobal"               "NumConcAcc"               
    ## [119] "NumConcCP"                 "NumConcNuc"               
    ## [121] "OceanCurrent"              "OtherkAir"                
    ## [123] "outdated"                  "outdated.1"               
    ## [125] "outdated.2"                "penetration_depth_s"      
    ## [127] "pH"                        "pKa"                      
    ## [129] "Porosity"                  "Pvap25"                   
    ## [131] "Pvap25_default"            "Q.10"                     
    ## [133] "QSAR.ChemClass"            "QSAR.ChemClass"           
    ## [135] "rad_species"               "RadCOL"                   
    ## [137] "RadCP"                     "RadNuc"                   
    ## [139] "RadS"                      "RainOnFreshwater"         
    ## [141] "RAINrate"                  "relevant_depth_s"         
    ## [143] "rho_species"               "RhoCOL"                   
    ## [145] "RhoCP"                     "rhoMatrix"                
    ## [147] "RhoNuc"                    "RhoS"                     
    ## [149] "Runoff"                    "ScaleIsGlobal"            
    ## [151] "ScaleName"                 "ScaleOrder"               
    ## [153] "SettlingVelocity"          "SettlVelocitywater"       
    ## [155] "Shape"                     "Shear"                    
    ## [157] "Shortest_side"             "Sol25"                    
    ## [159] "SpeciesName"               "SpeciesOrder"             
    ## [161] "SubCompartName"            "SubCompartOrder"          
    ## [163] "subFRACa"                  "subFRACs"                 
    ## [165] "subFRACw"                  "Substance"                
    ## [167] "SUSP"                      "t_half_Escape"            
    ## [169] "T25"                       "table"                    
    ## [171] "TAUsea"                    "tdry"                     
    ## [173] "Temp"                      "Tempfactor"               
    ## [175] "Test"                      "Tm"                       
    ## [177] "Tm_default"                "toScale"                  
    ## [179] "ToSI"                      "toSubCompart"             
    ## [181] "TotalArea"                 "twet"                     
    ## [183] "Udarcy"                    "Unit"                     
    ## [185] "Unit"                      "VarName"                  
    ## [187] "VarName"                   "VertDistance"             
    ## [189] "Volume"                    "Waarde"                   
    ## [191] "WINDspeed"                 "X"                        
    ## [193] "X"                         "X"                        
    ## [195] "X"                         "x_Advection_Air"          
    ## [197] "x_ContRiver2Reg"           "x_ContSea2Reg"            
    ## [199] "x_FromModerate2ArctWater"  "x_FromModerate2ContWater" 
    ## [201] "x_FromModerate2TropWater"  "x_LakeOutflow"            
    ## [203] "x_OceanMixing2Deep"        "x_OceanMixing2Sea"        
    ## [205] "x_RegSea2Cont"             "x_RiverDischarge"         
    ## [207] "x_ToModerateWater"         "X.1"                      
    ## [209] "X.1"

``` r
World$fetchData("VertDistance")
```

    ##          Scale         SubCompart VertDistance
    ## 2       Arctic                air        1e+03
    ## 3       Arctic         cloudwater        1e+03
    ## 4       Arctic          deepocean        3e+03
    ## 8       Arctic     marinesediment        3e-02
    ## 9       Arctic        naturalsoil        5e-02
    ## 12      Arctic                sea        1e+02
    ## 13 Continental   agriculturalsoil        2e-01
    ## 14 Continental                air        1e+03
    ## 15 Continental         cloudwater        1e+03
    ## 17 Continental freshwatersediment        3e-02
    ## 18 Continental               lake        1e+02
    ## 19 Continental       lakesediment        3e-02
    ## 20 Continental     marinesediment        3e-02
    ## 21 Continental        naturalsoil        5e-02
    ## 22 Continental          othersoil        5e-02
    ## 23 Continental              river        3e+00
    ## 24 Continental                sea        2e+02
    ## 26    Moderate                air        1e+03
    ## 27    Moderate         cloudwater        1e+03
    ## 28    Moderate          deepocean        3e+03
    ## 32    Moderate     marinesediment        3e-02
    ## 33    Moderate        naturalsoil        5e-02
    ## 36    Moderate                sea        1e+02
    ## 37    Regional   agriculturalsoil        2e-01
    ## 38    Regional                air        1e+03
    ## 39    Regional         cloudwater        1e+03
    ## 41    Regional freshwatersediment        3e-02
    ## 42    Regional               lake        1e+02
    ## 43    Regional       lakesediment        3e-02
    ## 44    Regional     marinesediment        3e-02
    ## 45    Regional        naturalsoil        5e-02
    ## 46    Regional          othersoil        5e-02
    ## 47    Regional              river        3e+00
    ## 48    Regional                sea        1e+01
    ## 50      Tropic                air        1e+03
    ## 51      Tropic         cloudwater        1e+03
    ## 52      Tropic          deepocean        3e+03
    ## 56      Tropic     marinesediment        3e-02
    ## 57      Tropic        naturalsoil        5e-02
    ## 60      Tropic                sea        1e+02

``` r
World$fetchData("FRACcldw")
```

    ##         Scale FRACcldw
    ## 1      Arctic    3e-07
    ## 2 Continental    3e-07
    ## 3    Moderate    3e-07
    ## 4    Regional    3e-07
    ## 5      Tropic    3e-07

The variable Area is missing. Missing variables can be found by the
method whichUnresolved. Area is also a function, which needs other
variables. To complete the calculation of Volume we have four steps,
three in preparation. Area can (and will) be used by other functions. No
need to recalculate it.

``` r
#World$whichUnresolved()

lapply(c("AreaSea", "AreaLand", "Area"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})
```

    ## [[1]]
    ##         Scale  old_AreaSea      AreaSea
    ## 1      Arctic 2.550000e+13 2.550000e+13
    ## 2 Continental 3.713410e+12 3.713410e+12
    ## 3    Moderate 3.878559e+13 3.878559e+13
    ## 4    Regional 1.000000e+09 1.000000e+09
    ## 5      Tropic 8.925000e+13 8.925000e+13
    ## 
    ## [[2]]
    ##         Scale old_AreaLand     AreaLand
    ## 1      Arctic 1.700000e+13 1.700000e+13
    ## 2 Continental 3.485840e+12 3.485840e+12
    ## 3    Moderate 3.878559e+13 3.878559e+13
    ## 4    Regional 2.285700e+11 2.285700e+11
    ## 5      Tropic 3.825000e+13 3.825000e+13
    ## 
    ## [[3]]
    ##          Scale         SubCompart     old_Area         Area
    ## 1       Arctic                air 4.250000e+13 4.250000e+13
    ## 2       Arctic          deepocean 2.550000e+13 2.550000e+13
    ## 3       Arctic     marinesediment 2.550000e+13 2.550000e+13
    ## 4       Arctic        naturalsoil 1.700000e+13 1.700000e+13
    ## 5       Arctic                sea 2.550000e+13 2.550000e+13
    ## 6  Continental   agriculturalsoil 2.091504e+12 2.091504e+12
    ## 7  Continental                air 7.199250e+12 7.199250e+12
    ## 8  Continental freshwatersediment 9.586060e+10 9.586060e+10
    ## 9  Continental               lake 8.714600e+09 8.714600e+09
    ## 10 Continental       lakesediment 8.714600e+09 8.714600e+09
    ## 11 Continental     marinesediment 3.713410e+12 3.713410e+12
    ## 12 Continental        naturalsoil 9.411768e+11 9.411768e+11
    ## 13 Continental          othersoil 3.485840e+11 3.485840e+11
    ## 14 Continental              river 9.586060e+10 9.586060e+10
    ## 15 Continental                sea 3.713410e+12 3.713410e+12
    ## 16    Moderate                air 7.757118e+13 7.757118e+13
    ## 17    Moderate          deepocean 3.878559e+13 3.878559e+13
    ## 18    Moderate     marinesediment 3.878559e+13 3.878559e+13
    ## 19    Moderate        naturalsoil 3.878559e+13 3.878559e+13
    ## 20    Moderate                sea 3.878559e+13 3.878559e+13
    ## 21    Regional   agriculturalsoil 1.371420e+11 1.371420e+11
    ## 22    Regional                air 2.295700e+11 2.295700e+11
    ## 23    Regional freshwatersediment 6.285675e+09 6.285675e+09
    ## 24    Regional               lake 5.714250e+08 5.714250e+08
    ## 25    Regional       lakesediment 5.714250e+08 5.714250e+08
    ## 26    Regional     marinesediment 1.000000e+09 1.000000e+09
    ## 27    Regional        naturalsoil 6.171390e+10 6.171390e+10
    ## 28    Regional          othersoil 2.285700e+10 2.285700e+10
    ## 29    Regional              river 6.285675e+09 6.285675e+09
    ## 30    Regional                sea 1.000000e+09 1.000000e+09
    ## 31      Tropic                air 1.275000e+14 1.275000e+14
    ## 32      Tropic          deepocean 8.925000e+13 8.925000e+13
    ## 33      Tropic     marinesediment 8.925000e+13 8.925000e+13
    ## 34      Tropic        naturalsoil 3.825000e+13 3.825000e+13
    ## 35      Tropic                sea 8.925000e+13 8.925000e+13

``` r
World$CalcVar("Volume")
```

    ##          Scale         SubCompart   old_Volume       Volume
    ## 1       Arctic                air 4.249999e+16 4.249999e+16
    ## 2       Arctic          deepocean 7.650000e+16 7.650000e+16
    ## 3       Arctic     marinesediment 7.650000e+11 7.650000e+11
    ## 4       Arctic        naturalsoil 8.500000e+11 8.500000e+11
    ## 5       Arctic                sea 2.550000e+15 2.550000e+15
    ## 6  Continental   agriculturalsoil 4.183008e+11 4.183008e+11
    ## 7  Continental                air 7.199248e+15 7.199248e+15
    ## 8  Continental freshwatersediment 2.875818e+09 2.875818e+09
    ## 9  Continental               lake 8.714600e+11 8.714600e+11
    ## 10 Continental       lakesediment 2.614380e+08 2.614380e+08
    ## 11 Continental     marinesediment 1.114023e+11 1.114023e+11
    ## 12 Continental        naturalsoil 4.705884e+10 4.705884e+10
    ## 13 Continental          othersoil 1.742920e+10 1.742920e+10
    ## 14 Continental              river 2.875818e+11 2.875818e+11
    ## 15 Continental                sea 7.426820e+14 7.426820e+14
    ## 16    Moderate                air 7.757116e+16 7.757116e+16
    ## 17    Moderate          deepocean 1.163568e+17 1.163568e+17
    ## 18    Moderate     marinesediment 1.163568e+12 1.163568e+12
    ## 19    Moderate        naturalsoil 1.939280e+12 1.939280e+12
    ## 20    Moderate                sea 3.878559e+15 3.878559e+15
    ## 21    Regional   agriculturalsoil 2.742840e+10 2.742840e+10
    ## 22    Regional                air 2.295699e+14 2.295699e+14
    ## 23    Regional freshwatersediment 1.885702e+08 1.885702e+08
    ## 24    Regional               lake 5.714250e+10 5.714250e+10
    ## 25    Regional       lakesediment 1.714275e+07 1.714275e+07
    ## 26    Regional     marinesediment 3.000000e+07 3.000000e+07
    ## 27    Regional        naturalsoil 3.085695e+09 3.085695e+09
    ## 28    Regional          othersoil 1.142850e+09 1.142850e+09
    ## 29    Regional              river 1.885702e+10 1.885702e+10
    ## 30    Regional                sea 1.000000e+10 1.000000e+10
    ## 31      Tropic                air 1.275000e+17 1.275000e+17
    ## 32      Tropic          deepocean 2.677500e+17 2.677500e+17
    ## 33      Tropic     marinesediment 2.677500e+12 2.677500e+12
    ## 34      Tropic        naturalsoil 1.912500e+12 1.912500e+12
    ## 35      Tropic                sea 8.925000e+15 8.925000e+15

The calculation differs slightly from the excel version. This is
because: + the automation of the calculation demands a much more formal
approach + a stricter differentiation between data and calculations +
simplifications are applied like renaming both depth and height into
VertDistance

The variables as functions/tables and the automated dependencies can be
confusing initially, but the concept is powerful and helps documenting
the model as a whole. We can even create a graph showcasing all
relationships between the variables.

``` r
library(ggdag)
NodeAsText <- paste(World$nodelist$Params, "->" ,World$nodelist$Calc)
AllNodesAsText <- do.call(paste, c(as.list(NodeAsText), list(sep = ";")))
dag <- dagitty::dagitty(paste("dag{", AllNodesAsText, "}"))
plot(dagitty::graphLayout(dag))
```

![](FirstVars_files/figure-gfm/theDAG-1.png)<!-- -->
