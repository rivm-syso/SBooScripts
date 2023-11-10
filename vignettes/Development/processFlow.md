processFlow
================
JS
3/31/2022

## sb oo data

the sboo package depends on data, including information where transfers
(1rst order processes) take place. This data is stored in csv files (for
Dutch: literally comma delimited!). This process flow information in not
straightforward due to possible exceptions. To help developers to enter
consistent process information in the csv files, the data concerned can
be entered in a special excel-file with named ranges. This vignettes
demonstrates how to use the excel, the example excel-file contains the
data for the burial process, with the name and defining function
k_Burial. These ranges are read, like:

``` r
ProcessXlsx <- "data/ExampleProcess.xlsx" 
processName <- unname(unlist(openxlsx::read.xlsx(ProcessXlsx, colNames=FALSE,
                                                 namedRegion = "process")))
TransDim <- unname(unlist(openxlsx::read.xlsx(ProcessXlsx, colNames=FALSE,
                                              namedRegion = "TransDim")))
fromTo <- openxlsx::read.xlsx(ProcessXlsx, colNames=TRUE,
                              namedRegion = "fromTo")
exceptions <- openxlsx::read.xlsx(ProcessXlsx, colNames=TRUE,
                                  namedRegion = "exceptions")
```

    ## Warning: No data found on worksheet.

## Test for consistency

To fully test, we need a initializing, then we test the “Dimensions”.
The3D is a vector with the key names for the three dimensions. The
dimension of the transfer and those for the exceptions should match
those in The3D.

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.4.0     ✔ purrr   1.0.1
    ## ✔ tibble  3.1.8     ✔ dplyr   1.1.0
    ## ✔ tidyr   1.3.0     ✔ stringr 1.5.0
    ## ✔ readr   2.1.3     ✔ forcats 1.0.0
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
source("baseScripts/fakeLib.R")
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

``` r
if (!TransDim %in% The3D) {
  stringsAsList <- as.list(c("TransDim should be one of", The3D))
  stop(do.call(paste, stringsAsList))
}
if(!all(names(exceptions) %in% The3D)) {
  stringsAsList <- as.list(c("exception columns should be empty or one of", The3D))
  stop(do.call(paste, stringsAsList))
}
if (TransDim %in% names(exceptions)) {
  stop("exception columns should differ from TransDim")
}
```

# Updating the sboo data with the data from the excel file

The update is simply: read all data; remove data for the process in the
excel; append the data from the excel; and properly save the data into
the csv-files. \## Reading the current data for sboo from the csv files

``` r
DefKeys <- read.csv("data/Defs.csv")
#obtain (unique) Defs in this!! order
DefDups <- duplicated(DefKeys$Defs)
Defs <- DefKeys$Defs[!DefDups]

MlikeWorkBook <- lapply(Defs, function(tableName) {
  assign(tableName, read.csv(
    paste("data/", tableName, ".csv", sep = "")))
})
names(MlikeWorkBook) <- Defs
```

## We remove the process flow data from the current version

``` r
for (TheDim in The3D) {#TheDim = The3D[1]
  dataFrameName <- paste(TheDim, "Processes", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  ThisProcessRows <- dataFrame$process == processName
  if (any(ThisProcessRows)) {
    cat(paste("process updated in", dataFrameName))
    MlikeWorkBook[[dataFrameName]] <- dataFrame[!ThisProcessRows,]
  }
  #exceptions; as columns of
  dataFrameName <- paste(TheDim, "Sheet", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  if (processName %in% names(dataFrame)) {
    cat(paste("exceptions updated in", dataFrameName))
    minCol <- match(processName, names(dataFrame))
    MlikeWorkBook[[dataFrameName]] <- dataFrame[, -minCol]
  }
}
```

    ## process updated in SubCompartProcesses

## and append the new data

``` r
dataFrameName <- paste(TransDim, "Processes", sep = "")
ReplacePart <- fromTo
ReplacePart$process <- processName
OldProcessData <- MlikeWorkBook[[dataFrameName]]
MlikeWorkBook[[dataFrameName]] <- rbind(
  OldProcessData,
  ReplacePart[,names(OldProcessData)])

#exceptions; as columns of
for (TheDim in names(exceptions)) {#TheDim = names(exceptions)[1]
  dataFrameName <- paste(TheDim, "Sheet", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  ToFalse <- dataFrame[,TheDim] %in% exceptions[,TheDim]
  MlikeWorkBook[[dataFrameName]] <- dataFrame %>%
    mutate({{processName}} := !ToFalse)
}
```

# RE-SORT CSVs (and save) BEFORE YOU COMMIT!!

``` r
source("baseScripts/ordWrite2csv.R")
```

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

    ## Warning in write.csv(tabledata.frame[SaveOrder, c(orderNames, UnorderedNames)],
    ## : attempt to set 'dec' ignored

## And testing testing…

``` r
source("baseScripts/initTestWorld.R")
```

    ## Joining with `by = join_by(sheet, row)`

``` r
World$FromDataAndTo("k_Burial")
```

    ##     process     fromSubCompart       toSubCompart   fromScale     toScale
    ## 33 k_Burial     marinesediment     marinesediment      Arctic      Arctic
    ## 34 k_Burial freshwatersediment freshwatersediment Continental Continental
    ## 35 k_Burial       lakesediment       lakesediment Continental Continental
    ## 36 k_Burial     marinesediment     marinesediment Continental Continental
    ## 39 k_Burial     marinesediment     marinesediment    Moderate    Moderate
    ## 40 k_Burial freshwatersediment freshwatersediment    Regional    Regional
    ## 41 k_Burial       lakesediment       lakesediment    Regional    Regional
    ## 42 k_Burial     marinesediment     marinesediment    Regional    Regional
    ## 45 k_Burial     marinesediment     marinesediment      Tropic      Tropic
    ## 48 k_Burial     marinesediment     marinesediment      Arctic      Arctic
    ## 49 k_Burial freshwatersediment freshwatersediment Continental Continental
    ## 50 k_Burial       lakesediment       lakesediment Continental Continental
    ## 51 k_Burial     marinesediment     marinesediment Continental Continental
    ## 54 k_Burial     marinesediment     marinesediment    Moderate    Moderate
    ## 55 k_Burial freshwatersediment freshwatersediment    Regional    Regional
    ## 56 k_Burial       lakesediment       lakesediment    Regional    Regional
    ## 57 k_Burial     marinesediment     marinesediment    Regional    Regional
    ## 60 k_Burial     marinesediment     marinesediment      Tropic      Tropic
    ## 63 k_Burial     marinesediment     marinesediment      Arctic      Arctic
    ## 64 k_Burial freshwatersediment freshwatersediment Continental Continental
    ## 65 k_Burial       lakesediment       lakesediment Continental Continental
    ## 66 k_Burial     marinesediment     marinesediment Continental Continental
    ## 69 k_Burial     marinesediment     marinesediment    Moderate    Moderate
    ## 70 k_Burial freshwatersediment freshwatersediment    Regional    Regional
    ## 71 k_Burial       lakesediment       lakesediment    Regional    Regional
    ## 72 k_Burial     marinesediment     marinesediment    Regional    Regional
    ## 75 k_Burial     marinesediment     marinesediment      Tropic      Tropic
    ## 78 k_Burial     marinesediment     marinesediment      Arctic      Arctic
    ## 79 k_Burial freshwatersediment freshwatersediment Continental Continental
    ## 80 k_Burial       lakesediment       lakesediment Continental Continental
    ## 81 k_Burial     marinesediment     marinesediment Continental Continental
    ## 84 k_Burial     marinesediment     marinesediment    Moderate    Moderate
    ## 85 k_Burial freshwatersediment freshwatersediment    Regional    Regional
    ## 86 k_Burial       lakesediment       lakesediment    Regional    Regional
    ## 87 k_Burial     marinesediment     marinesediment    Regional    Regional
    ## 90 k_Burial     marinesediment     marinesediment      Tropic      Tropic
    ##    fromSpecies toSpecies
    ## 33       Large     Large
    ## 34       Large     Large
    ## 35       Large     Large
    ## 36       Large     Large
    ## 39       Large     Large
    ## 40       Large     Large
    ## 41       Large     Large
    ## 42       Large     Large
    ## 45       Large     Large
    ## 48       Small     Small
    ## 49       Small     Small
    ## 50       Small     Small
    ## 51       Small     Small
    ## 54       Small     Small
    ## 55       Small     Small
    ## 56       Small     Small
    ## 57       Small     Small
    ## 60       Small     Small
    ## 63       Solid     Solid
    ## 64       Solid     Solid
    ## 65       Solid     Solid
    ## 66       Solid     Solid
    ## 69       Solid     Solid
    ## 70       Solid     Solid
    ## 71       Solid     Solid
    ## 72       Solid     Solid
    ## 75       Solid     Solid
    ## 78     Unbound   Unbound
    ## 79     Unbound   Unbound
    ## 80     Unbound   Unbound
    ## 81     Unbound   Unbound
    ## 84     Unbound   Unbound
    ## 85     Unbound   Unbound
    ## 86     Unbound   Unbound
    ## 87     Unbound   Unbound
    ## 90     Unbound   Unbound
