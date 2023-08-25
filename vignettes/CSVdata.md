sb oo data
================
JS
3/30/2022

## sb oo data

the sboo package depends on data, including “landscape variables”, but
also information where transfers (1rst order processes) take place. This
data is stored in csv files (for Dutch: literally comma delimited the .
as decimal delimiter). Each file has key columns that identify uniquely
identify a row and the combination of key columns is unique for the
file; i.e. if you know the key, you can find the proper file. Example of
keys are the “Dimensions” Scale, Subcompartment and Species, but also
“process” and “VarName”. The list of files (without extension) and their
keys is also in a csv file, in so-called long format, also known as the
“relational” model.

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

The files, and after reading them in the data.frames, do not have 2
keys. The reason for this is that one of the key would be “VarName”, and
this becomes a column name. These files are in a wider format, easier to
read if not too large. An example of columns where SubCompart is the
only key:

``` r
names(MlikeWorkBook[["SubCompartSheet"]])
```

    ##  [1] "Compartment"               "SubCompart"               
    ##  [3] "Matrix"                    "AbbrC"                    
    ##  [5] "Default"                   "SubCompartName"           
    ##  [7] "k_Removal"                 "k.HeteroAgglomeration.sd" 
    ##  [9] "k.HeteroAgglomeration.a"   "k_Advection_catchment"    
    ## [11] "k_AdvectionRiverSeaScales" "alpha.surf"               
    ## [13] "gamma.surf"                "ColRad"                   
    ## [15] "Udarcy"                    "Porosity"                 
    ## [17] "k_Advection_Air"           "EROSIONsoil"              
    ## [19] "pH"                        "SUSP"                     
    ## [21] "DefaultNETsedrate"

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
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✔ ggplot2 3.3.5     ✔ purrr   0.3.4
    ## ✔ tibble  3.1.2     ✔ dplyr   1.0.9
    ## ✔ tidyr   1.2.0     ✔ stringr 1.4.0
    ## ✔ readr   2.1.2     ✔ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

    ## 
    ## Attaching package: 'ggdag'

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## 
    ## Attaching package: 'rlang'

    ## The following objects are masked from 'package:purrr':
    ## 
    ##     %@%, as_function, flatten, flatten_chr, flatten_dbl, flatten_int,
    ##     flatten_lgl, flatten_raw, invoke, splice

    ## Joining, by = "Matrix"Joining, by = "Compartment"Joining, by = c("sheet", "row")

Data in SpeciesCompartments, for example RadOther (radius of “Other”,
natural particle before the attachement of this species) is transfered
to the children. Before:

``` r
SpeciesCompartments <- MlikeWorkBook[["SpeciesCompartments"]]
SpeciesCompartments[SpeciesCompartments$VarName == "NaturalRad",]
```

    ##      VarName Compartment Species   Waarde SB4N_name Unit
    ## 1 NaturalRad         air   Large 9.00e-07   RadCP.a    m
    ## 2 NaturalRad    sediment   Large 1.28e-04  RadFP.sd    m
    ## 3 NaturalRad    sediment   Small 1.50e-07  RadNC.sd    m
    ## 4 NaturalRad        soil   Large 1.28e-04   RadFP.s    m
    ## 5 NaturalRad        soil   Small 1.50e-07   RadNC.s    m
    ## 6 NaturalRad       water   Large 3.00e-06  RadSPM.w    m
    ## 7 NaturalRad       water   Small 1.50e-07   RadNC.w    m

and after (World as SBcore object is defined by initTestWorld):

``` r
World$fetchData("NaturalRad")
```

    ##            SubCompart Species NaturalRad
    ## 1                 air   Large   9.00e-07
    ## 2          cloudwater   Large   9.00e-07
    ## 3  freshwatersediment   Large   1.28e-04
    ## 4  freshwatersediment   Small   1.50e-07
    ## 5        lakesediment   Large   1.28e-04
    ## 6        lakesediment   Small   1.50e-07
    ## 7      marinesediment   Large   1.28e-04
    ## 8      marinesediment   Small   1.50e-07
    ## 9    agriculturalsoil   Large   1.28e-04
    ## 10   agriculturalsoil   Small   1.50e-07
    ## 11        naturalsoil   Large   1.28e-04
    ## 12        naturalsoil   Small   1.50e-07
    ## 13          othersoil   Large   1.28e-04
    ## 14          othersoil   Small   1.50e-07
    ## 15          deepocean   Large   3.00e-06
    ## 16          deepocean   Small   1.50e-07
    ## 17               lake   Large   3.00e-06
    ## 18               lake   Small   1.50e-07
    ## 19              river   Large   3.00e-06
    ## 20              river   Small   1.50e-07
    ## 21                sea   Large   3.00e-06
    ## 22                sea   Small   1.50e-07

In 99% of the cases you will only use the fetchData method to see or use
the data!

The csv files are versioned in git; It’s convenient to sort them when
you enter (copy-paste) new data. But it is even more covenient to
consistenly sort all files to trace the changes in git!!

# Please run the script below before commit, merge-master, push and merge-request your changes!!

``` r
source("baseScripts/ReorderCSV.R")
```

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames,
    ## UnorderedNames)], : attempt to set 'dec' ignored

## Units

As always units are boring and crucial to obtain proper results. Using
SI helps in quality assurance, but custom units are very custom… The
quantity of rainfall is normally expressed as mm/yr, and forcing SI can
add to the confusion. The choosen solution is to define a Units table,
stored in data/Units.csv . This file has columns for the name of the
variable, the unit in the csv file and the conversion, respectively
named

``` r
names(MlikeWorkBook[["Units"]])
```

    ## [1] "VarName"     "Unit"        "ToSI"        "table"       "Description"

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

From the units table we see the unit it is in, and how to covert in:

``` r
UnitTable <- MlikeWorkBook[["Units"]]
UnitTable[UnitTable$VarName == "RAINrate",]
```

    ##     VarName Unit                           ToSI      table
    ## 77 RAINrate mm/y RAINrate / (3600*24*365 *1000) ScaleSheet
    ##                             Description
    ## 77 annual precipitation (rain and snow)

When fetching the data (from within World) we receive the variable,
CONVERTED TO SI!

``` r
World$fetchData("RAINrate")
```

    ##         Scale     RAINrate
    ## 1      Arctic 7.927448e-09
    ## 2 Continental 2.219685e-08
    ## 3    Moderate 2.219685e-08
    ## 4    Regional 2.219685e-08
    ## 5      Tropic 4.122273e-08

The functions that use the variables do so by calling the fetchData
method. This way usage of SI has been made easy.

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

Happy calculations!
