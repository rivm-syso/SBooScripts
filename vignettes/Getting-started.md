Getting started
================
Anne Hids
2024-07-18

## Initialize

This vignette demonstrates how to use SimpleBox Object-Oriented (SBOO).

### Choose a substance

The first step is to initialize the model. Before initialization a
substance needs to be selected, otherwise the “default substance” is
used. To select another substance than “default substance”, a substance
can be chosen from the “Substance” column of the data frame created
below.

``` r
#substances <- read.csv("data/Substances.csv")
substances <- read.csv("~/GitHub/SimpleBox/SBooScripts/data/Substances.csv")

# Assign a substance name from the Substance column to the variable "substance":
substance <- "1-aminoanthraquinone"
```

### Initialize the World object

The World object contains all variables and first order rate constants
(k’s) for the chosen substance. This object is needed later to calculate
the masses in each compartment on each scale.

To initialize the World object, one of three script is called:

- initWorld_onlyMolec.R (used for molecules)
- initWorld_onlyParticulate.R (used for particulates)
- initWorld_onlyPlastics.R (used for microplastics)

Choosing which script to use is dependent on the ChemClass of the chosen
substance (see “ChemClass” column in the “substances” data frame). Each
of these three classes require different initWorld scripts because
different processes and variables are used to calculate the k’s. With
the chunk below, the correct initWorld script is automatically chosen
and run based on the chosen substance:

``` r
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
chemclass <- substances |>
  filter(Substance == substance) |>
  select(ChemClass)

chemclass <- chemclass$ChemClass

if(substance == "microplastic"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if (chemclass == "particle") {
  source("baseScripts/initWorld_onlyParticulate.R")
} else {
  source("baseScripts/initWorld_onlyMolec.R")
}
```

    ## 
    ## Attaching package: 'ggdag'
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter
    ## 
    ## 
    ## Attaching package: 'rlang'
    ## 
    ## The following objects are masked from 'package:purrr':
    ## 
    ##     %@%, flatten, flatten_chr, flatten_dbl, flatten_int, flatten_lgl,
    ##     flatten_raw, invoke, splice
    ## 
    ## Joining with `by = join_by(Matrix)`Joining with `by = join_by(Compartment)`

## Accessing variables and k’s

Now that the World is initialized, its variables and calculated flows
can be accessed. To access these variables and k’s, first the names of
the variables are needed:

``` r
varnames <- World$fetchData()

print(varnames)
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
    ## [195] "X"                         "X.1"                      
    ## [197] "X.1"                       "x_Advection_Air"          
    ## [199] "x_ContRiver2Reg"           "x_ContSea2Reg"            
    ## [201] "x_FromModerate2ArctWater"  "x_FromModerate2ContWater" 
    ## [203] "x_FromModerate2TropWater"  "x_LakeOutflow"            
    ## [205] "x_OceanMixing2Deep"        "x_OceanMixing2Sea"        
    ## [207] "x_RegSea2Cont"             "x_RiverDischarge"         
    ## [209] "x_ToModerateWater"

### Access variables

A specific variable (in this case AreaSea) can be accessed as follows:

``` r
World$fetchData("AreaSea")
```

    ##         Scale      AreaSea
    ## 1      Arctic 2.550000e+13
    ## 2 Continental 3.713410e+12
    ## 3    Moderate 3.878559e+13
    ## 4    Regional 1.000000e+09
    ## 5      Tropic 8.925000e+13

### Access k’s

The “kaas” variable contains a data frame with the k’s, proccess name,
to-subcompartment name from-subcompartment name, to-scale name,
from-scale name, to-species name and from-species name. It can be
accessed in the same way other variables are accessed:

``` r
df_ks <- World$fetchData("kaas")
```

## Calculate steady state output

To calculate steady state masses, emissions and a solver are needed. The
have to be given to the solver in a particular format.

### Create emissions data frame

To be able to calculate steady state masses, an emission data frame is
needed. The emissions data frame consists of one column with the
abbreviation of the scale-subcompartment-species combination, and
another column containing the emission to that compartment.

The abbreviations are as follows:

``` r
library(knitr)
scales <- data.frame(Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"), Abbreviation = c("A", "C", "M", "R", "T"))

subcompartments <- read.csv("data/SubCompartSheet.csv") |>
  select(SubCompartName, AbbrC) |>
  rename(Abbreviation = AbbrC) |>
  rename(SubCompartment = SubCompartName)

species <- read.csv("data/SpeciesSheet.csv") |>
  select(Species, AbbrP) |>
  rename(Abbreviation = AbbrP)

print(scales)
```

    ##         Scale Abbreviation
    ## 1      Arctic            A
    ## 2 Continental            C
    ## 3    Moderate            M
    ## 4    Regional            R
    ## 5      Tropic            T

``` r
print(subcompartments)
```

    ##        SubCompartment Abbreviation
    ## 1                 air            a
    ## 2          cloudwater           cw
    ## 3  freshwatersediment          sd1
    ## 4        lakesediment          sd0
    ## 5      marinesediment          sd2
    ## 6    agriculturalsoil           s2
    ## 7         naturalsoil           s1
    ## 8           othersoil           s3
    ## 9           deepocean           w3
    ## 10               lake           w0
    ## 11              river           w1
    ## 12                sea           w2

``` r
print(species)
```

    ##     Species Abbreviation
    ## 1 Dissolved            D
    ## 2       Gas            G
    ## 3     Large            P
    ## 4     Small            A
    ## 5     Solid            S
    ## 6   Unbound            U

*Notes:*

- *Compartment deepocean only exists on Global (Arctic, Moderate,
  Tropic) scale.*
- *Compartments lake, river, agriculturalsoil and othersoil only exist
  on regional and continental scale.*

The abbreviations used in the emissions data frame are built up as
follows:

1.  Abbreviation of the subcompartment
2.  Abbreviation of the scale
3.  Abbreviation of the species.

Now the emissions data frame can be created. The column named “Abbr”
contains the abbreviations, and the column “Emis” contains the
emissions. In the example below, emissions of 10000 t/y go into regional
air, regional agricultural soil and regional river water. These
emissions in tonnes per year are then converted to mol/s.

**Notice that because this script is using a molecular substance, the
abbreviation “U” for “Unbound” is used here to specify emissions. If the
substance is a particle, use “S” for “Solid”!**

``` r
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) 

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60)) # convert 1 t/y to mol/s

print(emissions)
```

    ##   Abbr     Emis
    ## 1  aRU 1.421964
    ## 2 s2RU 1.421964
    ## 3 w1RU 1.421964

### Solve the matrix

To solve the matrix, a solver first needs to be specified. To solve for
a steady state we can use “SB1Solve”. In this case the resulting steady
state masses are reported in the data frame “masses”.

``` r
# Specify which solver to use to the World object
World$NewSolver("SB1Solve")

# Use the emissions data frame and solve the matrix
masses <- World$Solve(emissions)

print(masses)
```

    ##      Abbr       Scale         SubCompart Species       EqMass
    ## 196   aRU    Regional                air Unbound 8.086729e+04
    ## 234  w1RU    Regional              river Unbound 4.397418e+07
    ## 226  w0RU    Regional               lake Unbound 5.730855e+07
    ## 210  w2RU    Regional                sea Unbound 2.335443e+06
    ## 213 sd1RU    Regional freshwatersediment Unbound 1.250309e+06
    ## 223 sd0RU    Regional       lakesediment Unbound 4.717787e+04
    ## 183 sd2RU    Regional     marinesediment Unbound 1.952721e+04
    ## 217  s1RU    Regional        naturalsoil Unbound 2.497620e+06
    ## 182  s2RU    Regional   agriculturalsoil Unbound 6.189499e+07
    ## 207  s3RU    Regional          othersoil Unbound 9.250446e+05
    ## 204   aCU Continental                air Unbound 6.707175e+04
    ## 208  w1CU Continental              river Unbound 3.046926e+06
    ## 221  w0CU Continental               lake Unbound 7.132422e+06
    ## 220  w2CU Continental                sea Unbound 1.434258e+08
    ## 195 sd1CU Continental freshwatersediment Unbound 8.663267e+04
    ## 192 sd0CU Continental       lakesediment Unbound 5.872169e+03
    ## 197 sd2CU Continental     marinesediment Unbound 5.996089e+04
    ## 235  s1CU Continental        naturalsoil Unbound 1.094860e+06
    ## 187  s2CU Continental   agriculturalsoil Unbound 5.103918e+06
    ## 233  s3CU Continental          othersoil Unbound 4.055037e+05
    ## 211   aAU      Arctic                air Unbound 3.591206e+02
    ## 215  w2AU      Arctic                sea Unbound 1.105069e+08
    ## 203  w3AU      Arctic          deepocean Unbound 2.709207e+09
    ## 219 sd2AU      Arctic     marinesediment Unbound 7.555334e+04
    ## 214  s1AU      Arctic        naturalsoil Unbound 5.463468e+04
    ## 224   aMU    Moderate                air Unbound 8.543204e+03
    ## 225  w2MU    Moderate                sea Unbound 1.406985e+08
    ## 231  w3MU    Moderate          deepocean Unbound 4.115150e+09
    ## 206 sd2MU    Moderate     marinesediment Unbound 1.146926e+05
    ## 188  s1MU    Moderate        naturalsoil Unbound 5.396266e+05
    ## 227   aTU      Tropic                air Unbound 5.140824e+02
    ## 193  w2TU      Tropic                sea Unbound 1.541285e+08
    ## 201  w3TU      Tropic          deepocean Unbound 4.976039e+09
    ## 228 sd2TU      Tropic     marinesediment Unbound 1.385302e+05
    ## 202  s1TU      Tropic        naturalsoil Unbound 1.033855e+04

## Calculate dynamic output
