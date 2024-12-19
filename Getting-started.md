Getting started
================
Anne Hids
2024-12-19

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

Choosing which script to use is dependent on the ChemClass of the chosen
substance (see “ChemClass” column in the “substances” data frame). Each
of these three classes require different initWorld scripts because
different processes and variables are used to calculate the k’s. With
the chunk below, the correct initWorld script is automatically chosen
and run based on the chosen substance:

``` r
library(tidyverse)

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
    ## [185] "X"                         "x_Advection_Air"          
    ## [187] "x_ContRiver2Reg"           "x_ContSea2Reg"            
    ## [189] "x_FromModerate2ArctWater"  "x_FromModerate2ContWater" 
    ## [191] "x_FromModerate2TropWater"  "x_LakeOutflow"            
    ## [193] "x_OceanMixing2Deep"        "x_OceanMixing2Sea"        
    ## [195] "x_RegSea2Cont"             "x_RiverDischarge"         
    ## [197] "x_ToModerateWater"

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

The “kaas” variable contains a data frame with the first order rate
constants (k’s), proccess name, to-subcompartment name
from-subcompartment name, to-scale name, from-scale name, to-species
name and from-species name. It can be accessed in the same way other
variables are accessed:

``` r
df_ks <- World$fetchData("kaas")
```

## Calculate steady state output

To calculate steady state masses, emissions and a solver are needed. The
have to be given to the solver in a particular format. More details on
solvers can be found [here](vignettes/10.1-Solver-use.md).

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
    ## 1  aRU 2.157129
    ## 2 s2RU 2.157129
    ## 3 w1RU 2.157129

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
    ## 196   aRU    Regional                air Unbound 6.697008e+05
    ## 234  w1RU    Regional              river Unbound 1.185311e+06
    ## 226  w0RU    Regional               lake Unbound 3.735155e+04
    ## 210  w2RU    Regional                sea Unbound 4.381044e+04
    ## 213 sd1RU    Regional freshwatersediment Unbound 3.158710e+05
    ## 223 sd0RU    Regional       lakesediment Unbound 2.247901e+02
    ## 183 sd2RU    Regional     marinesediment Unbound 3.039946e+03
    ## 217  s1RU    Regional        naturalsoil Unbound 1.545975e+03
    ## 182  s2RU    Regional   agriculturalsoil Unbound 2.237280e+07
    ## 207  s3RU    Regional          othersoil Unbound 5.725835e+02
    ## 204   aCU Continental                air Unbound 3.757802e+06
    ## 208  w1CU Continental              river Unbound 1.574551e+03
    ## 221  w0CU Continental               lake Unbound 1.899574e+03
    ## 220  w2CU Continental                sea Unbound 1.212298e+06
    ## 195 sd1CU Continental freshwatersediment Unbound 4.195985e+02
    ## 192 sd0CU Continental       lakesediment Unbound 1.143621e+01
    ## 197 sd2CU Continental     marinesediment Unbound 4.205982e+03
    ## 235  s1CU Continental        naturalsoil Unbound 4.218642e+03
    ## 187  s2CU Continental   agriculturalsoil Unbound 1.554283e+04
    ## 233  s3CU Continental          othersoil Unbound 1.562460e+03
    ## 211   aAU      Arctic                air Unbound 2.786144e+06
    ## 215  w2AU      Arctic                sea Unbound 1.313178e+06
    ## 203  w3AU      Arctic          deepocean Unbound 1.184931e+07
    ## 219 sd2AU      Arctic     marinesediment Unbound 3.099945e+03
    ## 214  s1AU      Arctic        naturalsoil Unbound 3.525621e+04
    ## 224   aMU    Moderate                air Unbound 7.070864e+06
    ## 225  w2MU    Moderate                sea Unbound 6.046481e+05
    ## 231  w3MU    Moderate          deepocean Unbound 1.802514e+06
    ## 206 sd2MU    Moderate     marinesediment Unbound 4.169132e+02
    ## 188  s1MU    Moderate        naturalsoil Unbound 3.035969e+04
    ## 227   aTU      Tropic                air Unbound 7.043872e+06
    ## 193  w2TU      Tropic                sea Unbound 3.020686e+05
    ## 201  w3TU      Tropic          deepocean Unbound 3.204656e+05
    ## 228 sd2TU      Tropic     marinesediment Unbound 6.092532e+01
    ## 202  s1TU      Tropic        naturalsoil Unbound 9.298216e+03

### Model Output

For now the most reliably is to output masses and manually calculate
concentrations and other relevant output based on your needs
\[5-12-2024\]. We are working on the Concentration module and have
output of the mass flows and mass balance in preparation.

## Calculate dynamic output

It is also possible to calculate the masses in each compartment over
time using the ‘DynApproxSolve’ solver. The use of this solver is
demonstrated below.

### Make emission data frame

To use the dynamic solver, an emission dataframe is needed with three
columns: Abbr, Emis and Timed

The column named “Abbr” contains the abbreviations, and the column
“Emis” contains the emissions. In the example below, emissions in tonnes
per year are converted to mol/s. The column “Timed” contains the times
at which the emissions are emitted to the environment.

*Note: There should be at least two emissions at different times per
subcompartment for the solver to work*

``` r
# Make emission fata frame
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU","aRU", "s2RU", "w1RU"), Emis = c(5, 10, 15, 20, 25, 30), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> # Convert time from y to s
  ungroup() |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60)) # convert 1 t/y to mol/s

tmax <- 10*365.25*24*60*60 
times <- seq(0, tmax, length.out = 100)

World$NewSolver("DynApproxSolve")
solved <- World$Solve(tmax = tmax, emissions, needdebug = F)
```

## Prepare the output for plotting

A few things happen in the chunk below: - The matrix is converted to a
tibble - The tibble is converted from wide to long format - Year is
calculated from time in seconds - Based on the column Abbr, the States
dataframe is joined to the tibble

``` r
solved <- as_tibble(solved) 

solved_long <- solved |>
  select(!starts_with("emis")) |>
  pivot_longer(!time, names_to = "Abbr", values_to = "Mass") |>
  mutate(Year = time/(365.25*24*60*60)) |>
  left_join(World$states$asDataFrame, by="Abbr") # Join the abbreviations to more understandable Scale, SubCompart and Species
```

## Plot the dynamic masses at specific scales

The scales to choose from are “Regional”, “Continental”, “Moderate”,
“Tropic” and “Arctic”.

``` r
plot_scale <- function(mass_dataframe, scale){
  # Filter masses for the specific scale
  mass_data_scale <- mass_dataframe |>
    filter(Scale == scale)
  
  # Plot masses on the specific scale
  mass_plot <- ggplot(mass_data_scale, aes(x=Year, y=Mass, col=SubCompart)) + 
    geom_line() +
    ylab("Mass (kg)") +
    theme_bw() +
    ggtitle(paste0("Masses over time at ", scale, " scale")) +
    scale_y_continuous() +
    scale_x_continuous()
  
  return(mass_plot)
}

# Plot data for regional scale
regional_plot <- plot_scale(solved_long, "Regional")
print(regional_plot)
```

![](Getting-started_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
# Plot data for continental scale
continental_plot <- plot_scale(solved_long, "Continental")
print(continental_plot)
```

![](Getting-started_files/figure-gfm/unnamed-chunk-2-2.png)<!-- -->
