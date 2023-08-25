sb oo data
================
JS
15 Mar 2022

## Documentation / metadata

Documentation of the data is basically in the same table as the units.
This means ALL variables should be in the list. It takes quite some
discipline to maintain this documentation. It might help to run a script
like below, to check how complete the units-table is.

``` r
#We need to initialize for a nano material to obtain all properties, including those only needed for nanomaterials
substance <- "nAg_10nm"
#Initialize World, but also the object NewstateModule. This object you don't use, normally. 
#It is internal, exposed through "injection" into World
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.0     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.1     ✔ tibble    3.1.8
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the ]8;;http://conflicted.r-lib.org/conflicted package]8;; to force all conflicts to become errors
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
    ## Joining with `by = join_by(sheet, row)`

``` r
AllVarnames <- World$fetchData() 
#There should be 1 place (table) for a variable; are there multiple?
table(AllVarnames)[table(AllVarnames)!=1]
```

    ## AllVarnames
    ##              a              b QSAR.ChemClass           Unit        VarName 
    ##              2              2              2              2              2

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
UnitTable <- NewstateModule$SB4N.data[["Units"]]

unique(AllVarnames)[!AllVarnames %in% UnitTable$VarName]
```

    ##  [1] "a"             "AEROresist"    "beta.a"        "C.OHrad"      
    ##  [5] "Corg"          "Description"   "Df"            "dischargeFRAC"
    ##  [9] "FRACaers"      "FRACaerw"      "gamma.surf"    "H0sol"        
    ## [13] "k0.OHrad"      "Kaw25"         "Matrix"        "MaxPvap"      
    ## [17] "mConcCol"      "NaturalRho"    "NumConcCP"     "RadNuc"       
    ## [21] "RadS"          "Shear"         "Sol25"         "subFRACs"     
    ## [25] "subFRACw"      "TAUsea"        "TotalArea"     "Udarcy"       
    ## [29] "VertDistance"

## Update Units table == Adding and Deleting

We determined the variables missing in Units; but if we overwrite the
current csv file, (old) variables will be deleted; is the user sure?

``` r
UnitTable$VarName[!UnitTable$VarName %in% unique(AllVarnames)]
```

    ## character(0)

If everything looks honky dori, we can find the table/sheet/csv filename
for each new variable add it to the units dataframe and overwrite the
existing data…

``` r
#The trail of variables is stored when reading it originally; in 
NewUnits <- left_join(UnitTable, NewstateModule$varOrigine)
```

    ## Joining with `by = join_by(VarName, table)`

``` r
AlfOrder <- order(NewUnits$VarName)
write.csv(NewUnits[AlfOrder,], file = "data/units.csv")
# source("baseScripts/ReorderCSV.R") not needed because already alphabetic
```

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
