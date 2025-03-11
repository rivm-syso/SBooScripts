Getting started
================
Anne Hids

2025-02-19

This vignette demonstrates how to use SimpleBox Object-Oriented (SBOO).

## Initialize

This vignette demonstrates how to use SimpleBox Object-Oriented (SBOO).

Before starting, make sure your working directory is set to the
SBooScripts folder.

### See if required packages are installed

``` r
check_and_install <- function(package) {
  tryCatch({
    # Load the package
    library(package, character.only = TRUE)
    message(paste("Package", package, "is already installed and loaded."))
  }, error = function(e) {
    # If an error occurs, install the package
    message(paste("Package", package, "is not installed. Installing now..."))
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
    message(paste("Package", package, "has been successfully installed and loaded."))
  })
}

# Install the required packages
check_and_install("ggplot2")
check_and_install("tidyverse")
check_and_install("constants")
check_and_install("deSolve")
check_and_install("knitr")
```

### Choose a substance

The first step is to initialize the model. Before initialization a
substance needs to be selected, otherwise the “default substance” is
used. To select another substance than “default substance”, a substance
can be chosen from the “Substance” column of the data frame created
below.

``` r
substances <- read.csv("data/Substances.csv")

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

Choosing which script to use is dependent on the substance class of the
chosen substance (see “ChemClass” column in the “substances” data
frame). Each of these three classes require different initWorld scripts
because different processes and variables are used to calculate the k’s.
With the chunk below, the correct initWorld script is automatically
chosen and run based on the chosen substance:

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

## Access variables

Now that the World is initialized, its variables and calculated flows
can be accessed. To access these variables and k’s, first the names of
the variables are needed. They can be accessed by using the code below.
The first 10 variable names are printed, but there are 201 variables in
total.

``` r
varnames <- World$fetchData()

print(varnames[1:10])
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
    ##  [29] "D"                         "DefaultNETsedrate"        
    ##  [31] "Description"               "Df"                       
    ##  [33] "Dimension"                 "dischargeFRAC"            
    ##  [35] "DragMethod"                "DynViscAirStandard"       
    ##  [37] "DynViscWaterStandard"      "Ea.OHrad"                 
    ##  [39] "epsilon"                   "Erosion"                  
    ##  [41] "EROSIONsoil"               "FlowName"                 
    ##  [43] "forWhich"                  "FRACa"                    
    ##  [45] "FRACcldw"                  "FRACinf"                  
    ##  [47] "FracROWatComp"             "FRACrun"                  
    ##  [49] "FRACs"                     "FRACsea"                  
    ##  [51] "FRACtwet"                  "FRACw"                    
    ##  [53] "FricVel"                   "FRinaers"                 
    ##  [55] "FRinaerw"                  "FRingas"                  
    ##  [57] "FRinw"                     "fromScale"                
    ##  [59] "fromSubCompart"            "FRorig"                   
    ##  [61] "FRorig_spw"                "gamma.surf"               
    ##  [63] "H0sol"                     "hamakerSP.w"              
    ##  [65] "Intermediate_side"         "k_Adsorption"             
    ##  [67] "k_CWscavenging"            "k_Deposition"             
    ##  [69] "k_DryDeposition"           "k_HeteroAgglomeration.a"  
    ##  [71] "k_HeteroAgglomeration.wsd" "k_Leaching"               
    ##  [73] "k_Removal"                 "k_Runoff"                 
    ##  [75] "k_Volatilisation"          "k_WetDeposition"          
    ##  [77] "k0.OHrad"                  "Kacompw"                  
    ##  [79] "Kaers"                     "Kaerw"                    
    ##  [81] "Kaw25"                     "kdeg"                     
    ##  [83] "KdegDorC"                  "kdis"                     
    ##  [85] "Kow"                       "Kp"                       
    ##  [87] "Kp.col"                    "Kp.sed"                   
    ##  [89] "Kp.soil"                   "Kp.susp"                  
    ##  [91] "KpCOL"                     "Kscompw"                  
    ##  [93] "Ksdcompw"                  "Ksw"                      
    ##  [95] "Ksw.alt"                   "KswDorC"                  
    ##  [97] "kwsd"                      "kwsd.sed"                 
    ##  [99] "kwsd.water"                "LakeFracRiver"            
    ## [101] "landFRAC"                  "Longest_side"             
    ## [103] "Mackay1"                   "Mackay2"                  
    ## [105] "Matrix"                    "MaxPvap"                  
    ## [107] "MTC_2a"                    "MTC_2s"                   
    ## [109] "MTC_2sd"                   "MTC_2w"                   
    ## [111] "MW"                        "NaturalPart"              
    ## [113] "NETsedrate"                "NotInGlobal"              
    ## [115] "NumConcAcc"                "NumConcCP"                
    ## [117] "NumConcNuc"                "OceanCurrent"             
    ## [119] "OtherkAir"                 "penetration_depth_s"      
    ## [121] "pH"                        "pKa"                      
    ## [123] "Porosity"                  "Pvap25"                   
    ## [125] "Q.10"                      "QSAR.ChemClass"           
    ## [127] "QSAR.ChemClass"            "rad_species"              
    ## [129] "RadCOL"                    "RadCP"                    
    ## [131] "RadNuc"                    "RadS"                     
    ## [133] "RainOnFreshwater"          "RAINrate"                 
    ## [135] "relevant_depth_s"          "rho_species"              
    ## [137] "RhoCOL"                    "RhoCP"                    
    ## [139] "rhoMatrix"                 "RhoNuc"                   
    ## [141] "RhoS"                      "Runoff"                   
    ## [143] "ScaleIsGlobal"             "ScaleName"                
    ## [145] "ScaleOrder"                "SettlingVelocity"         
    ## [147] "SettlVelocitywater"        "Shape"                    
    ## [149] "Shear"                     "Shortest_side"            
    ## [151] "Sol25"                     "SpeciesName"              
    ## [153] "SpeciesOrder"              "SubCompartName"           
    ## [155] "SubCompartOrder"           "subFRACa"                 
    ## [157] "subFRACs"                  "subFRACw"                 
    ## [159] "Substance"                 "SUSP"                     
    ## [161] "t_half_Escape"             "T25"                      
    ## [163] "table"                     "TAUsea"                   
    ## [165] "tdry"                      "Temp"                     
    ## [167] "Tempfactor"                "Test"                     
    ## [169] "Tm"                        "Tm_default"               
    ## [171] "toScale"                   "ToSI"                     
    ## [173] "toSubCompart"              "TotalArea"                
    ## [175] "twet"                      "Udarcy"                   
    ## [177] "Unit"                      "VarName"                  
    ## [179] "VarName"                   "VertDistance"             
    ## [181] "Volume"                    "Waarde"                   
    ## [183] "WINDspeed"                 "X"                        
    ## [185] "X"                         "X"                        
    ## [187] "X"                         "x_Advection_Air"          
    ## [189] "x_ContRiver2Reg"           "x_ContSea2Reg"            
    ## [191] "x_FromModerate2ArctWater"  "x_FromModerate2ContWater" 
    ## [193] "x_FromModerate2TropWater"  "x_LakeOutflow"            
    ## [195] "x_OceanMixing2Deep"        "x_OceanMixing2Sea"        
    ## [197] "x_RegSea2Cont"             "x_RiverDischarge"         
    ## [199] "x_ToModerateWater"         "X.1"                      
    ## [201] "X.1"

A specific variable (in this case AreaSea) can be accessed as follows:

``` r
knitr::kable(World$fetchData("AreaSea"))
```

| Scale       |      AreaSea |
|:------------|-------------:|
| Arctic      | 2.550000e+13 |
| Continental | 3.713410e+12 |
| Moderate    | 3.878559e+13 |
| Regional    | 1.000000e+09 |
| Tropic      | 8.925000e+13 |

## Access k’s

The “kaas” variable contains a data frame with the first order rate
constants (k’s), proccess name, to-subcompartment name
from-subcompartment name, to-scale name, from-scale name, to-species
name and from-species name. It can be accessed in the same way other
variables are accessed:

``` r
df_ks <- World$kaas
```

## Change a landscape variable

To change a landscape variables value(s), first get the current variable
with World\$fetchData. This is to see the dimensions of the variables
dataframe.

Variable values are changed using World\$MutateVars(). This function
expects the new variable values in a specific format:

- values should be in a column named ‘Waarde’
- the name of the variable should be in a column named ‘varName’
- the other columns can be ‘Scale’, ‘SubCompart’, ‘Species’ etc. You can
  see which columns need to be included by using fetchData() on the
  variable before using mutateVars()

``` r
# Get the current dataframe of the variable
kable(World$fetchData("TotalArea"))
```

| Scale       |   TotalArea |
|:------------|------------:|
| Arctic      | 4.25000e+13 |
| Continental | 7.42882e+12 |
| Moderate    | 8.50000e+13 |
| Regional    | 2.29570e+11 |
| Tropic      | 1.27500e+14 |

``` r
# Make a dataframe in the same format (also same column names)
TotalArea <- data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"),
  Waarde = c(4.25E+13, 7.43E+12, 8.50E+13, 4.13e+11, 1.27e+14)) |>
  mutate(varName = "TotalArea")

# Replace TotalArea variable with new values
World$mutateVars(TotalArea)

# Check if it worked 
kable(World$fetchData("TotalArea"))
```

| Scale       | TotalArea |
|:------------|----------:|
| Arctic      |  4.25e+13 |
| Continental |  7.43e+12 |
| Moderate    |  8.50e+13 |
| Regional    |  4.13e+11 |
| Tropic      |  1.27e+14 |

``` r
# Recalulate all variables dependent on TotalArea
World$UpdateDirty("TotalArea")
```

## Change a substance variable

When using World\$fetchData(), sometimes a value is returned instead of
a dataframe. In that case we can still use the mutateVars() function,
but give the function a named value instead of a dataframe.

The default molecular weight for this substance is 0.147. After the
chuck below, the value should be 0.15.

``` r
# Make a dataframe where varName = MW and Waarde is 150 
MW_df <- data.frame(varName = "MW",
                        Waarde = 150) # In g/mol, will be converted to SI unit (kg/mol) in the core. 

# Use mutateVars() to update the variable
World$mutateVars(MW_df)

# Recalculate all variables dependent on MW
World$UpdateDirty("MW")
```

After changing the molecular weight, the value is 0.15.

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
scales <- data.frame(Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"), Abbreviation = c("A", "C", "M", "R", "T"))

subcompartments <- read.csv("data/SubCompartSheet.csv") |>
  select(SubCompartName, AbbrC) |>
  rename(Abbreviation = AbbrC) |>
  rename(SubCompartment = SubCompartName)

species <- read.csv("data/SpeciesSheet.csv") |>
  select(Species, AbbrP) |>
  rename(Abbreviation = AbbrP)

knitr::kable(scales)
```

| Scale       | Abbreviation |
|:------------|:-------------|
| Arctic      | A            |
| Continental | C            |
| Moderate    | M            |
| Regional    | R            |
| Tropic      | T            |

``` r
knitr::kable(subcompartments)
```

| SubCompartment     | Abbreviation |
|:-------------------|:-------------|
| air                | a            |
| cloudwater         | cw           |
| freshwatersediment | sd1          |
| lakesediment       | sd0          |
| marinesediment     | sd2          |
| agriculturalsoil   | s2           |
| naturalsoil        | s1           |
| othersoil          | s3           |
| deepocean          | w3           |
| lake               | w0           |
| river              | w1           |
| sea                | w2           |

``` r
knitr::kable(species)
```

| Species   | Abbreviation |
|:----------|:-------------|
| Dissolved | D            |
| Gas       | G            |
| Large     | P            |
| Small     | A            |
| Solid     | S            |
| Unbound   | U            |

You can access all abbreviations and their meanings like this:

``` r
All_abbrs <- World$states$asDataFrame
```

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

knitr::kable(emissions)
```

| Abbr |     Emis |
|:-----|---------:|
| aRU  | 2.157129 |
| s2RU | 2.157129 |
| w1RU | 2.157129 |

### Solve the matrix

To solve the matrix, a solver first needs to be specified. To solve for
a steady state we can use “SB1Solve”. In this case the resulting steady
state masses are reported in the data frame “masses”.

``` r
# Define the solver function to use. For steady state calculations, this is always "SteadyODE"
World$NewSolver("SteadyODE")

# Solve with the emissions we defined in the previous chunk
World$Solve(emissions = emissions)

# Access the masses in each compartment
masses <- World$Solution()
concentrations <- World$Concentration()

knitr::kable(masses)
```

| time | Abbr  | RUNs |      Mass_kg |
|:-----|:------|:-----|-------------:|
| 0    | aRU   | 1    | 6.697008e+05 |
| 0    | w1RU  | 1    | 1.185311e+06 |
| 0    | w0RU  | 1    | 3.735155e+04 |
| 0    | w2RU  | 1    | 4.381044e+04 |
| 0    | sd1RU | 1    | 3.158710e+05 |
| 0    | sd0RU | 1    | 2.247901e+02 |
| 0    | sd2RU | 1    | 3.039946e+03 |
| 0    | s1RU  | 1    | 1.545975e+03 |
| 0    | s2RU  | 1    | 2.237280e+07 |
| 0    | s3RU  | 1    | 5.725835e+02 |
| 0    | aCU   | 1    | 3.757802e+06 |
| 0    | w1CU  | 1    | 1.574551e+03 |
| 0    | w0CU  | 1    | 1.899574e+03 |
| 0    | w2CU  | 1    | 1.212298e+06 |
| 0    | sd1CU | 1    | 4.195985e+02 |
| 0    | sd0CU | 1    | 1.143621e+01 |
| 0    | sd2CU | 1    | 4.205982e+03 |
| 0    | s1CU  | 1    | 4.218642e+03 |
| 0    | s2CU  | 1    | 1.554283e+04 |
| 0    | s3CU  | 1    | 1.562460e+03 |
| 0    | aAU   | 1    | 2.786144e+06 |
| 0    | w2AU  | 1    | 1.313177e+06 |
| 0    | w3AU  | 1    | 1.184929e+07 |
| 0    | sd2AU | 1    | 3.099939e+03 |
| 0    | s1AU  | 1    | 3.525621e+04 |
| 0    | aMU   | 1    | 7.070864e+06 |
| 0    | w2MU  | 1    | 6.046481e+05 |
| 0    | w3MU  | 1    | 1.802514e+06 |
| 0    | sd2MU | 1    | 4.169131e+02 |
| 0    | s1MU  | 1    | 3.035969e+04 |
| 0    | aTU   | 1    | 7.043872e+06 |
| 0    | w2TU  | 1    | 3.020686e+05 |
| 0    | w3TU  | 1    | 3.204656e+05 |
| 0    | sd2TU | 1    | 6.092532e+01 |
| 0    | s1TU  | 1    | 9.298216e+03 |

``` r
knitr::kable(concentrations)
```

| Abbr  | time | RUNs | Concentration | Unit    |
|:------|:-----|:-----|--------------:|:--------|
| aAU   | 0    | 1    |     0.0000001 | g/m3    |
| aCU   | 0    | 1    |     0.0000005 | g/m3    |
| aMU   | 0    | 1    |     0.0000001 | g/m3    |
| aRU   | 0    | 1    |     0.0000029 | g/m3    |
| aTU   | 0    | 1    |     0.0000001 | g/m3    |
| s1AU  | 0    | 1    |     0.0000691 | g/kg dw |
| s1CU  | 0    | 1    |     0.0001494 | g/kg dw |
| s1MU  | 0    | 1    |     0.0000261 | g/kg dw |
| s1RU  | 0    | 1    |     0.0008350 | g/kg dw |
| s1TU  | 0    | 1    |     0.0000081 | g/kg dw |
| s2CU  | 0    | 1    |     0.0000619 | g/kg dw |
| s2RU  | 0    | 1    |     1.3594667 | g/kg dw |
| s3CU  | 0    | 1    |     0.0001494 | g/kg dw |
| s3RU  | 0    | 1    |     0.0008350 | g/kg dw |
| sd0CU | 0    | 1    |     0.0002187 | g/kg dw |
| sd0RU | 0    | 1    |     0.0655642 | g/kg dw |
| sd1CU | 0    | 1    |     0.0007295 | g/kg dw |
| sd1RU | 0    | 1    |     8.3754203 | g/kg dw |
| sd2AU | 0    | 1    |     0.0000203 | g/kg dw |
| sd2CU | 0    | 1    |     0.0001888 | g/kg dw |
| sd2MU | 0    | 1    |     0.0000018 | g/kg dw |
| sd2RU | 0    | 1    |     0.5066576 | g/kg dw |
| sd2TU | 0    | 1    |     0.0000001 | g/kg dw |
| w0CU  | 0    | 1    |     0.0021798 | g/L     |
| w0RU  | 0    | 1    |     0.6536562 | g/L     |
| w1CU  | 0    | 1    |     0.0054751 | g/L     |
| w1RU  | 0    | 1    |    62.8578158 | g/L     |
| w2AU  | 0    | 1    |     0.0005150 | g/L     |
| w2CU  | 0    | 1    |     0.0016323 | g/L     |
| w2MU  | 0    | 1    |     0.0001559 | g/L     |
| w2RU  | 0    | 1    |     4.3810435 | g/L     |
| w2TU  | 0    | 1    |     0.0000338 | g/L     |
| w3AU  | 0    | 1    |     0.0001549 | g/L     |
| w3MU  | 0    | 1    |     0.0000155 | g/L     |
| w3TU  | 0    | 1    |     0.0000012 | g/L     |

**For more information on the different types of solvers and how to use
them, please see SBooScripts/vignettes/x. Solver use.md.**

