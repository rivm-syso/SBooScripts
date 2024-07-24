Metadata and Documentation
================
Jaap Slootweg, Valerie de Rijk
15 Mar 2022

## Metadata

Documentation of the data is basically in the same table as the units.
The information stems from the file *units.csv*. This means ALL
variables should be in the list. It takes quite some discipline to
maintain this documentation. It might help to run a script like below,
to check how complete the units-table is. New parameters should be added
to this file by developers, with the corresponding conversion to SI
units. As mentioned before, this column is read in by SBOO to convert
input parameters into SI units.

``` r
#We need to initialize for a nano material to obtain all properties, including those only needed for nanomaterials
substance <- "nAg_10nm"
source("baseScripts/initWorld_onlyParticulate.R")
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
AllVarnames <- World$fetchData() 
#There should be 1 place (table) for a variable; are there multiple?
table(AllVarnames)[table(AllVarnames)!=1]
```

    ## AllVarnames
    ##              a              b QSAR.ChemClass           Unit        VarName 
    ##              2              2              2              2              2 
    ##              X            X.1 
    ##              4              2

``` r
#Columns of the QSAR table are an exception, can be ignored here...
#Also ignore variable-names starting with k_. The are the exceptions to the described process from-and-to data
#Also ignore variable starting with Abbr, these are for old (excel) variable naming convention
#Also ignore "Waarde", "Dimension", "forWhich" and "unit", other technicalities...
AllVarnames <- AllVarnames[!startsWith(AllVarnames, prefix = "k_") & 
                             !startsWith(AllVarnames, prefix = "Abbr") &
                             !startsWith(AllVarnames, prefix = "outdated")]
AllVarnames <- AllVarnames[!AllVarnames %in% c("VarName", "Waarde", "Dimension", "forWhich", "Unit", "table")] 
#compare to the units table; which has been read into the World by 
UnitTable <-read.csv("data/Units.csv")
print(UnitTable$VarName)
```

    ##   [1] "AEROresist"            "AEROSOLdeprate"        "alpha"                
    ##   [4] "alpha.surf"            "beta.a"                "C.OHrad"              
    ##   [7] "C.OHrad.n"             "ChemClass"             "COL"                  
    ##  [10] "COLLECTeff"            "ColRad"                "ContinentalInModerate"
    ##  [13] "Corg"                  "CorgStandard"          "DefaultFRACarea"      
    ##  [16] "Df"                    "dischargeFRAC"         "DynViscAirStandard"   
    ##  [19] "DynViscWaterStandard"  "Ea.OHrad"              "EF"                   
    ##  [22] "epsilon"               "Erosion"               "FRACa"                
    ##  [25] "FRACcldw"              "FRACinf"               "FRACrun"              
    ##  [28] "FRACs"                 "FRACsea"               "FRACtwet"             
    ##  [31] "FRACw"                 "FricVel"               "gamma.surf"           
    ##  [34] "H0sol"                 "hamakerSP.w"           "Intermediate_side"    
    ##  [37] "k0.OHrad"              "Kaw25"                 "kdeg"                 
    ##  [40] "kdeg.air"              "kdeg.sed"              "kdeg.soil"            
    ##  [43] "kdeg.water"            "kdis"                  "Kow"                  
    ##  [46] "Kow_default"           "Kp.col"                "Kp.sed"               
    ##  [49] "Kp.soil"               "Kp.susp"               "Ksw"                  
    ##  [52] "kwsd"                  "kwsd"                  "LakeFracRiver"        
    ##  [55] "landFRAC"              "Longest_side"          "Mackay1"              
    ##  [58] "MaxPvap"               "MOLMASSAIR"            "MW"                   
    ##  [61] "NaturalRad"            "NaturalRho"            "NETsedrate"           
    ##  [64] "NumConcAcc"            "NumConcCP"             "NumConcNuc"           
    ##  [67] "OceanCurrent"          "penetration_depth_s"   "pH"                   
    ##  [70] "pKa"                   "Porosity"              "Pvap25"               
    ##  [73] "Pvap25_default"        "RadCOL"                "RadCP"                
    ##  [76] "RadNuc"                "RadS"                  "RAINrate"             
    ##  [79] "relevant_depth_s"      "RhoAcc"                "RhoCOL"               
    ##  [82] "RhoCP"                 "rhoMatrix"             "RhoNuc"               
    ##  [85] "RhoS"                  "SettlVelocitywater"    "Shear"                
    ##  [88] "Shortest_side"         "Sol25"                 "subFRACa"             
    ##  [91] "subFRACs"              "subFRACw"              "SUSP"                 
    ##  [94] "t_half_Escape"         "T25"                   "TAUsea"               
    ##  [97] "tdry"                  "Temp"                  "Tm"                   
    ## [100] "Tm_default"            "TotalArea"             "twet"                 
    ## [103] "Udarcy"                "VertDistance"          "WINDspeed"

``` r
print(AllVarnames)
```

    ##   [1] "a"                        "a"                       
    ##   [3] "AEROresist"               "AEROSOLdeprate"          
    ##   [5] "AirFlow"                  "alpha"                   
    ##   [7] "alpha.surf"               "Area"                    
    ##   [9] "AreaLand"                 "AreaSea"                 
    ##  [11] "b"                        "b"                       
    ##  [13] "BACTcomp"                 "BACTtest"                
    ##  [15] "beta.a"                   "Biodeg"                  
    ##  [17] "C.OHrad"                  "C.OHrad.n"               
    ##  [19] "ChemClass"                "COL"                     
    ##  [21] "COLLECTeff"               "ColRad"                  
    ##  [23] "Compartment"              "ContinentalInModerate"   
    ##  [25] "Corg"                     "CORG.susp"               
    ##  [27] "CorgStandard"             "D"                       
    ##  [29] "DefaultFRACarea"          "DefaultNETsedrate"       
    ##  [31] "DefaultpH"                "Description"             
    ##  [33] "Df"                       "dischargeFRAC"           
    ##  [35] "DragMethod"               "DynViscAirStandard"      
    ##  [37] "DynViscWaterStandard"     "Ea.OHrad"                
    ##  [39] "EF"                       "epsilon"                 
    ##  [41] "Erosion"                  "EROSIONsoil"             
    ##  [43] "FlowName"                 "FRACa"                   
    ##  [45] "FRACcldw"                 "FRACinf"                 
    ##  [47] "FracROWatComp"            "FRACrun"                 
    ##  [49] "FRACs"                    "FRACsea"                 
    ##  [51] "FRACtwet"                 "FRACw"                   
    ##  [53] "FricVel"                  "FRingas"                 
    ##  [55] "FRinw"                    "fromScale"               
    ##  [57] "fromSubCompart"           "FRorig"                  
    ##  [59] "FRorig_spw"               "gamma.surf"              
    ##  [61] "H0sol"                    "hamakerSP.w"             
    ##  [63] "Intermediate_side"        "k0.OHrad"                
    ##  [65] "Kacompw"                  "Kaers"                   
    ##  [67] "Kaerw"                    "Kaw25"                   
    ##  [69] "kdeg"                     "KdegDorC"                
    ##  [71] "kdis"                     "Kow"                     
    ##  [73] "Kow_default"              "Kp"                      
    ##  [75] "Kp.col"                   "Kp.sed"                  
    ##  [77] "Kp.soil"                  "Kp.susp"                 
    ##  [79] "KpCOL"                    "Kscompw"                 
    ##  [81] "Ksw"                      "Ksw.alt"                 
    ##  [83] "KswDorC"                  "kwsd"                    
    ##  [85] "kwsd.sed"                 "kwsd.water"              
    ##  [87] "LakeFracRiver"            "landFRAC"                
    ##  [89] "Longest_side"             "Mackay1"                 
    ##  [91] "Mackay2"                  "Matrix"                  
    ##  [93] "MaxPvap"                  "MOLMASSAIR"              
    ##  [95] "MW"                       "NaturalPart"             
    ##  [97] "NETsedrate"               "NotInGlobal"             
    ##  [99] "NumConcAcc"               "NumConcCP"               
    ## [101] "NumConcNuc"               "OceanCurrent"            
    ## [103] "penetration_depth_s"      "pH"                      
    ## [105] "pKa"                      "Porosity"                
    ## [107] "Pvap25"                   "Pvap25_default"          
    ## [109] "Q.10"                     "QSAR.ChemClass"          
    ## [111] "QSAR.ChemClass"           "rad_species"             
    ## [113] "RadCOL"                   "RadCP"                   
    ## [115] "RadNuc"                   "RadS"                    
    ## [117] "RainOnFreshwater"         "RAINrate"                
    ## [119] "relevant_depth_s"         "rho_species"             
    ## [121] "RhoCOL"                   "RhoCP"                   
    ## [123] "rhoMatrix"                "RhoNuc"                  
    ## [125] "RhoS"                     "Runoff"                  
    ## [127] "ScaleIsGlobal"            "ScaleName"               
    ## [129] "ScaleOrder"               "SettlingVelocity"        
    ## [131] "SettlVelocitywater"       "Shape"                   
    ## [133] "Shear"                    "Shortest_side"           
    ## [135] "Sol25"                    "SpeciesName"             
    ## [137] "SpeciesOrder"             "SubCompartName"          
    ## [139] "SubCompartOrder"          "subFRACa"                
    ## [141] "subFRACs"                 "subFRACw"                
    ## [143] "Substance"                "SUSP"                    
    ## [145] "t_half_Escape"            "T25"                     
    ## [147] "TAUsea"                   "tdry"                    
    ## [149] "Temp"                     "Tempfactor"              
    ## [151] "Test"                     "Tm"                      
    ## [153] "Tm_default"               "toScale"                 
    ## [155] "ToSI"                     "toSubCompart"            
    ## [157] "TotalArea"                "twet"                    
    ## [159] "Udarcy"                   "VertDistance"            
    ## [161] "Volume"                   "WINDspeed"               
    ## [163] "X"                        "X"                       
    ## [165] "X"                        "X"                       
    ## [167] "x_Advection_Air"          "x_ContRiver2Reg"         
    ## [169] "x_ContSea2Reg"            "x_FromModerate2ArctWater"
    ## [171] "x_FromModerate2ContWater" "x_FromModerate2TropWater"
    ## [173] "x_LakeOutflow"            "x_OceanMixing2Deep"      
    ## [175] "x_OceanMixing2Sea"        "x_RegSea2Cont"           
    ## [177] "x_RiverDischarge"         "x_ToModerateWater"       
    ## [179] "X.1"                      "X.1"

## The constants package

Some global constants are imported from this package. For convenience
two functions are availeable, demonstrated below.

``` r
getConst("r")
```

    ## [1] 8.314463

``` r
ConstGrep("gravity")
```

    ##     symbol                         quantity           type   value uncertainty
    ## 255     gn standard acceleration of gravity Adopted values 9.80665           0
    ##      unit
    ## 255 m/s^2

``` r
# we were loooking for getConst("gn")
```

## Roxygen documentation

The \[roxygen package\]\[<https://roxygen2.r-lib.org/index.html>\]
allows for describing functions next to their definitions and
subsequently generates markdown files when help files are requested. It
is essential that these are created for all functions. An example is
that of the solver function. SB1 Solve:

\#’ @title SB1Solve

\#’ @name SB1Solve

\#’@description solve system of 1rst order k(i,j) and emissions,by
solving v = 0

\#’ @param ParentModule SBcore

\#’ @param tol tolerance for accepting as steady state

\#’ @return States (i) (=mass)

The roxygen package allows for a lot of functions, but please refer to
the package for all options. In principle, it is essential that each new
function has a title, a name, a description, a return function and a
description of each parameter.
