Partitioning constants, like Ksw
================

# introduction

There are multiple transfers for substances from one matrix to the other
(matrix in the sense of medium, like air or water). The speed of some of
these transfers are calculated as processes; you will find them in
SubCompartProcesses.csv. Other transfers are so quick and small that a
continuous equilibrium is assumed. In this vignette will will focus on
Ksw, …

``` r
#we initialize the test environment with the default substance, therefor we remove possible earlier value
rm(substance)
```

    ## Warning in rm(substance): object 'substance' not found

``` r
#script to initialize test environment, including faking a future 'library(sboo)'
source("baseScripts/initTestWorld.R")
World$fetchData("Ksw")
```

    ## [1] NA

## Partitioning coefficients of substances

If “World” has found data for the substance you initiated with, this is
perfect. But these properties are not always known. You can assess them
by “models”; for Ksw a model is given by the fKsw function. Mind you;
this is not not a variable defining function, and you will have to fetch
the parameters yourself, and put the result in the core-data. We
demonstrate how.

The function is given below, the parameters are: Kow, pKa, Corg, a, b,
ChemClass and RHOsolid; The code is not nicely formatted by Rmd.

``` r
fKsw
```

    ## function (Kow, pKa, Corg, a, b, ChemClass, RHOsolid, alt_form, 
    ##     Ksw_orig) 
    ## {
    ##     switch(ChemClass, acid = ifelse(alt_form, 10^(0.54 * log10(Kow) + 
    ##         1.11) * Corg * RHOsolid/1000, 10^(0.11 * log10(Kow) + 
    ##         1.54) * Corg * RHOsolid/1000), base = ifelse(alt_form, 
    ##         10^(0.37 * log10(Kow) + 1.7) * Corg * RHOsolid/1000, 
    ##         10^(pKa^0.65 * (Kow/(1 + Kow)^0.14)) * Corg * RHOsolid/1000), 
    ##         metal = ifelse(alt_form, Ksw_orig, stop("Ksw Should be in the data")), 
    ##         particle = ifelse(alt_form, Ksw_orig, stop("Ksw Should be in the data")), 
    ##         {
    ##             ifelse(alt_form, Ksw_orig, a * b^Kow * Corg * RHOsolid/1000)
    ##         })
    ## }

Does the database contain Kow, pKa, Corg…?

``` r
Kow <- World$fetchData("Kow")
World$fetchData("Corg")
```

    ##            SubCompart Corg
    ## 1                 air 0.10
    ## 2          cloudwater 0.10
    ## 3  freshwatersediment 0.05
    ## 4        lakesediment 0.05
    ## 5      marinesediment 0.05
    ## 6    agriculturalsoil 0.02
    ## 7         naturalsoil 0.02
    ## 8           othersoil 0.02
    ## 9           deepocean 0.10
    ## 10               lake 0.10
    ## 11              river 0.10
    ## 12                sea 0.10

Oeps, CORG is a table in R of Corg for all subcompartments, we need
StandardCorgSoil

``` r
CORG <- World$fetchData("CorgSoilStandard")
pKa <- World$fetchData("pKa")
```

pKa is missing… If the substance is neutral, you can apply a value of 7.
Variables a and b come from the QSARtable. RHOsolid can be taken from
the Rho from the matrix of non-specific, standard soil, i.e. “othersoil”

``` r
Substance_ChemClass <- World$fetchData("ChemClass")
QSARtable <- World$fetchData("QSARtable")
QSARrecord <- QSARtable[QSARtable$QSAR.ChemClass == Substance_ChemClass,]
RhoTable <- World$fetchData("rhoMatrix")
KswModelled <- fKsw(Kow, pKa = 7, Corg = CORG, 
                    a = QSARrecord$a, b = QSARrecord$b, Substance_ChemClass,
                    RHOsolid = RhoTable$rhoMatrix[RhoTable$SubCompart == "othersoil"],
                    alt_form = F)
```

We now have all the parameters, we can call the function, but how to
store the result for Kws, to make it available from the core? This kind
of action is unusual, but can be done by replacing the whole table, in
this case Globals

``` r
FromData <- World$fetchData("Globals")
FromData$Ksw <- KswModelled
World$UpdateData(FromData, keys = T, TableName = "Globals")
```

And now we know that the system will use our modelled Ksw

``` r
World$fetchData("Ksw")
```

    ## [1] 1.358759e-253
