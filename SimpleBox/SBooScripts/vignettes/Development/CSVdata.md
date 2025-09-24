CSV files and their units
================
JS
2024-07-23

## sb oo data

the sboo package depends on data, including “landscape variables”, but
also information where transfers (1st order processes) take place. This
data is stored in csv files. Each file has key columns that identify a
row and the combination of key columns is unique for the file; i.e. if
you know the key, you can find the proper file. Example of keys are the
*Dimensions* Scale, Subcompartment and Species, but also “process” and
“VarName”. The list of files (without extension) and their keys is also
in a csv file, in so-called long format, also known as the “relational”
model.

``` r
DefKeys <- read.csv("data/Defs.csv")
#obtain (unique) Defs in this!! order
DefDups <- duplicated(DefKeys$Defs)
Defs <- DefKeys$Defs[!DefDups]
head(DefKeys, 10)
```

    ##                   Defs     Key
    ## 1       ScaleProcesses process
    ## 2       ScaleProcesses    from
    ## 3       ScaleProcesses      to
    ## 4  SubCompartProcesses process
    ## 5  SubCompartProcesses    from
    ## 6  SubCompartProcesses      to
    ## 7     SpeciesProcesses process
    ## 8     SpeciesProcesses    from
    ## 9     SpeciesProcesses      to
    ## 10 ScaleSubCompartData VarName

## Read all the data from existing csv’s into a list

``` r
MlikeWorkBook <- lapply(Defs, function(tableName) {
  assign(tableName, read.csv(
    paste("data/", tableName, ".csv", sep = "")))
})
names(MlikeWorkBook) <- Defs
```

## Long or wide?

``` r
table(DefKeys$Defs)
```

    ## 
    ##                   Compartments                      CONSTANTS 
    ##                              1                              1 
    ##                         FlowIO                    MatrixSheet 
    ##                              1                              1 
    ##                      QSARtable                 ScaleProcesses 
    ##                              1                              3 
    ##                     ScaleSheet               ScaleSpeciesData 
    ##                              1                              3 
    ##            ScaleSubCompartData                     SomeFromTo 
    ##                              3                              5 
    ##            SpeciesCompartments               SpeciesProcesses 
    ##                              3                              3 
    ##                   SpeciesSheet            SubCompartProcesses 
    ##                              1                              3 
    ##                SubCompartSheet          SubCompartSpeciesData 
    ##                              1                              3 
    ##          SubstanceCompartments                     Substances 
    ##                              3                              1 
    ## SubstanceSubCompartSpeciesData                          Units 
    ##                              4                              1

The files, and after reading them in the data.frames, have 1 or up to 5
keys, except 2! The reason for this is that one of the key would be
“VarName”, and this becomes a column name. These files are in a wider
format, easier to read if not too large. An example of columns where
SubCompart is the only key:

``` r
names(MlikeWorkBook[["SubCompartSheet"]])
```

    ##  [1] "Compartment"               "SubCompart"               
    ##  [3] "Matrix"                    "AbbrC"                    
    ##  [5] "Default"                   "SubCompartName"           
    ##  [7] "SubCompartOrder"           "k_Removal"                
    ##  [9] "k_HeteroAgglomeration.wsd" "k_HeteroAgglomeration.a"  
    ## [11] "alpha.surf"                "gamma.surf"               
    ## [13] "ColRad"                    "NotInGlobal"              
    ## [15] "Udarcy"                    "Porosity"                 
    ## [17] "EROSIONsoil"               "pH"                       
    ## [19] "COL"                       "SUSP"                     
    ## [21] "DefaultNETsedrate"         "k_DryDeposition"          
    ## [23] "k_WetDeposition"           "RadCOL"                   
    ## [25] "RadCP"                     "RhoCOL"                   
    ## [27] "RhoCP"

Compartment is a nicety to prevent redundancy for sub-compartments;
variables defined for compartments are “inherited” by their
subcompartments according to:

``` r
SubCompartments <- MlikeWorkBook[["SubCompartSheet"]]
SubCompartments[,c("Compartment", "SubCompart")]
```

    ##    Compartment         SubCompart
    ## 1          air                air
    ## 2          air         cloudwater
    ## 3     sediment freshwatersediment
    ## 4     sediment       lakesediment
    ## 5     sediment     marinesediment
    ## 6         soil   agriculturalsoil
    ## 7         soil        naturalsoil
    ## 8         soil          othersoil
    ## 9        water          deepocean
    ## 10       water               lake
    ## 11       water              river
    ## 12       water                sea

To demonstrate we need to initialise sboo; a default script for this is

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

Data in SpeciesCompartments, for example RadOther (radius of “Other”,
natural particle before the attachement of this species) is transfered
to the children. Before:

``` r
SpeciesCompartments <- MlikeWorkBook[["SpeciesCompartments"]]
SpeciesCompartments[SpeciesCompartments$VarName == "BACTcomp",]
```

    ##    VarName Compartment Species Waarde SB4N_name     Unit
    ## 1 BACTcomp       water Unbound  40000    BACT.w CFU.mL-1

and after (World as SBcore object is defined by initTestWorld):

``` r
World$fetchData("BACTcomp")
```

    ##    SubCompart Species BACTcomp
    ## 3   deepocean Unbound    40000
    ## 5        lake Unbound    40000
    ## 10      river Unbound    40000
    ## 11        sea Unbound    40000

In 99% of the cases you will only use the fetchData method to see or use
the data! This is the data as it is used by the calculations.

## Git link

The csv files are versioned in git; It’s convenient to sort them when
you enter (copy-paste) new data. But it is even more covenient to
consistenly sort all files to trace the changes in git!!

Please run the script below before commit, merge-master, push and
merge-request your changes!!

``` r
source("baseScripts/ReorderCSV.R")
```

## Units and CSV data

As always units are boring and crucial to obtain proper results. Using
SI helps in quality assurance, but custom units are very custom… The
quantity of rainfall is normally expressed as mm/yr, and forcing SI can
add to the confusion. The choosen solution is to define a Units table,
stored in data/Units.csv . This file has columns for the name of the
variable, the unit in the csv file and the conversion, respectively
named “Unit” and “ToSI”. Use of the other columns (“table” and
“Description”) are described in the metadata vignette.

``` r
names(MlikeWorkBook[["Units"]])
```

    ## [1] "VarName"     "X.1"         "X"           "Unit"        "ToSI"       
    ## [6] "table"       "Description"

In the ToSI column is an R expression including the variable itself. As
an example RAINrate is defined per scale:

``` r
MlikeWorkBook[["ScaleSheet"]][,c("ScaleName", "RAINrate")]
```

    ##     ScaleName RAINrate
    ## 1      Arctic      250
    ## 2 Continental      700
    ## 3    Moderate      700
    ## 4    Regional      700
    ## 5      Tropic     1300

From the units table we see the unit it is in, and how to convert into
SI units:

``` r
UnitTable <- MlikeWorkBook[["Units"]]
UnitTable[UnitTable$VarName == "RAINrate",]
```

    ##     VarName X.1  X Unit                           ToSI      table
    ## 78 RAINrate  76 74 mm/y RAINrate / (3600*24*365 *1000) ScaleSheet
    ##                             Description
    ## 78 annual precipitation (rain and snow)

When fetching the data (from within World) we receive the variable
*converted to SI*

``` r
World$fetchData("RAINrate")
```

    ##         Scale     RAINrate
    ## 1      Arctic 7.927448e-09
    ## 2 Continental 2.219685e-08
    ## 3    Moderate 2.219685e-08
    ## 4    Regional 2.219685e-08
    ## 5      Tropic 4.122273e-08

## The constants package

Some global constants are imported from this package. For convenience
two functions are available, demonstrated below.

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
