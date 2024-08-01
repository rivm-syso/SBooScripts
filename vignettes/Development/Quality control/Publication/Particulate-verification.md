Particulate verification
================
Anne Hids & Valerie de Rijk
2024-08-01

This vignette demonstrates the verification process of the particulate
version of Simplebox, in this case for a particle that is not a
microplastic. First, the k’s are compared between R and excel, and
consequently the steady state masses are compared. This is done for 5
molecular substances; each of a different chemical class (no class,
acid, base, neutral and metal). The reason that the verification is
performed for each of these classes is that some processes differ per
class.

First, the world needs to be initialized for a substance. In this case,
that substance is nAg 10nm, which is a particle.

We will first show the version of the R-code that has been adjusted to
match the Excel Version. This means that the code is initialized with
the parameter Test = TRUE. As such, this code should match (except for
rounding differences) the results of the Excel version.

## Test = TRUE

``` r
substance <- "nAg_10nm"

source("baseScripts/initWorld_onlyParticulate.R")
```

``` r
library(openxlsx)
library(tidyverse)
library (ggplot2)
library(plotly)
```

    ## 
    ## Attaching package: 'plotly'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     last_plot

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## The following object is masked from 'package:graphics':
    ## 
    ##     layout

``` r
ProcessNanoFunctions <- c("k_Advection", "k_Burial",
                         "k_HeteroAgglomeration.a", "k_HeteroAgglomeration.wsd",
                         "k_CWscavenging", "k_Degradation",
                         "k_DryDeposition", "k_Erosion", "k_Escape",
                         "k_Leaching", "k_Resuspension", "k_Runoff", "k_Sedimentation",
                        "k_WetDeposition")

SBExcelName <- paste0("vignettes/Development/Quality control/SBExcel/SimpleBox4plastics_rev009-1_",substance,".xlsx") 

SBexcel.K <- read.xlsx(SBExcelName,
                  colNames = FALSE,
                  namedRegion = "K")
SBexcel.Names <- read.xlsx(SBExcelName,
                  colNames = FALSE,
                  namedRegion = "box_names")

colnames(SBexcel.K) <- SBexcel.Names

SBexcel.K$to <-  as.character(SBexcel.Names)

SBexcel.K <- pivot_longer(SBexcel.K, cols =  as.character(SBexcel.Names), values_to = "k", names_to = "from")

length(SBexcel.K$k)
```

    ## [1] 24025

``` r
#adding "from" and "to" acronyms to the R K matrix
kaas <- as_tibble(World$kaas)
unique(kaas$fromScale)
```

    ## [1] "Arctic"      "Continental" "Moderate"    "Regional"    "Tropic"

``` r
unique(kaas$fromSubCompart)
```

    ##  [1] "marinesediment"     "freshwatersediment" "lakesediment"      
    ##  [4] "air"                "naturalsoil"        "agriculturalsoil"  
    ##  [7] "othersoil"          "deepocean"          "lake"              
    ## [10] "river"              "sea"                "cloudwater"

``` r
#R version does not us the acronyms of the excel version, set-up to convert them
#Note: this map creates the wrong acronym for soil and sediment at global scale, this is fixed afterwards
accronym_map <- c("marinesediment" = "sd2",
                "freshwatersediment" = "sd1",
                "lakesediment" = "sd0", #SB Excel does not have this compartment. To do: can we turn this off (exclude this compartment) for testing?
                "agriculturalsoil" = "s2",
                "naturalsoil" = "s1",
                "othersoil" = "s3",
                "air" = "a",
                "deepocean" = "w3",
                "sea" = "w2",
                "river" = "w1",
                "lake" = "w0", 
                "cloudwater" = "cw")

accronym_map2 <- c("Arctic" = "A",
                   "Moderate" = "M",
                   "Tropic" = "T",
                   "Continental" = "C",
                   "Regional" = "R")

accronym_map3 <- c("Dissolved" = "D", 
                   "Gas" = "G", 
                   "Large" = "P", 
                   "Small" = "A",
                   "Solid" = "S", 
                   "Unbound" = "U")

# kaas |> filter(fromScale == "Tropic" & process == "k_Degradation") |> print(n=50)

kaas <- kaas |> mutate(from =  paste0(accronym_map[fromSubCompart], 
                            accronym_map2[fromScale], 
                            accronym_map3[fromSpecies]),
               to = paste0(accronym_map[toSubCompart], 
                           accronym_map2[toScale], 
                           accronym_map3[toSpecies]))

kaas <-
  kaas |>
  mutate(from =
                   ifelse((fromScale == "Tropic" | fromScale == "Arctic" | fromScale == "Moderate") &
                            (fromSubCompart == "marinesediment" | fromSubCompart == "naturalsoil"),
                          str_replace_all(from, c("sd2"="sd","s1"="s")),
                          from)) |>
  mutate(to = ifelse((toScale == "Tropic" | toScale == "Arctic" | toScale == "Moderate") &
                       (toSubCompart == "marinesediment" | toSubCompart == "naturalsoil"), str_replace_all(to, c("sd2"="sd","s1"="s")), to))

kaas2 <- kaas |>  
  filter(from != to) |> #filtering the diagonals ou
  group_by(from, to) %>% summarize(k = sum(k)) #R version sometimes has multiple k's per fromto box; excel only has the summed k's per box

kaas2$fromto <- paste(sep = "_", kaas2$from, kaas2$to)

diagonal_excel <- SBexcel.K[SBexcel.K$from == SBexcel.K$to,] #all the diagonals in excel are negative values -> sums of all the "froms" of that compartment

#filter out dissolved and gas processes

filtered_excel <- diagonal_excel[!endsWith(diagonal_excel$from, "D"), ]
filtered_excel <- filtered_excel[!endsWith(filtered_excel$from, "G"), ]

#filter out molecular (unbound) state
#R model has k values per process, not per box. For the "diagonal" ("from = to") boxes, this is different than in the excel version. summing all the "froms" here to be able to compare them with excel matrix. This should result in one value for each compartment (scale-subcomp-species combo)

diagonal_R <-aggregate(k ~ from, data = kaas, FUN = sum) 
print(diagonal_R$from)
```

    ##   [1] "aAA"   "aAP"   "aAS"   "aAU"   "aCA"   "aCP"   "aCS"   "aCU"   "aMA"  
    ##  [10] "aMP"   "aMS"   "aMU"   "aRA"   "aRP"   "aRS"   "aRU"   "aTA"   "aTP"  
    ##  [19] "aTS"   "aTU"   "cwAA"  "cwAP"  "cwAS"  "cwCA"  "cwCP"  "cwCS"  "cwMA" 
    ##  [28] "cwMP"  "cwMS"  "cwRA"  "cwRP"  "cwRS"  "cwTA"  "cwTP"  "cwTS"  "s1CA" 
    ##  [37] "s1CP"  "s1CS"  "s1CU"  "s1RA"  "s1RP"  "s1RS"  "s1RU"  "s2CA"  "s2CP" 
    ##  [46] "s2CS"  "s2CU"  "s2RA"  "s2RP"  "s2RS"  "s2RU"  "s3CA"  "s3CP"  "s3CS" 
    ##  [55] "s3CU"  "s3RA"  "s3RP"  "s3RS"  "s3RU"  "sAA"   "sAP"   "sAS"   "sAU"  
    ##  [64] "sd0CA" "sd0CP" "sd0CS" "sd0CU" "sd0RA" "sd0RP" "sd0RS" "sd0RU" "sd1CA"
    ##  [73] "sd1CP" "sd1CS" "sd1CU" "sd1RA" "sd1RP" "sd1RS" "sd1RU" "sd2CA" "sd2CP"
    ##  [82] "sd2CS" "sd2CU" "sd2RA" "sd2RP" "sd2RS" "sd2RU" "sdAA"  "sdAP"  "sdAS" 
    ##  [91] "sdAU"  "sdMA"  "sdMP"  "sdMS"  "sdMU"  "sdTA"  "sdTP"  "sdTS"  "sdTU" 
    ## [100] "sMA"   "sMP"   "sMS"   "sMU"   "sTA"   "sTP"   "sTS"   "sTU"   "w0AU" 
    ## [109] "w0CA"  "w0CP"  "w0CS"  "w0CU"  "w0MU"  "w0RA"  "w0RP"  "w0RS"  "w0RU" 
    ## [118] "w0TU"  "w1CA"  "w1CP"  "w1CS"  "w1CU"  "w1RA"  "w1RP"  "w1RS"  "w1RU" 
    ## [127] "w2AA"  "w2AP"  "w2AS"  "w2AU"  "w2CA"  "w2CP"  "w2CS"  "w2CU"  "w2MA" 
    ## [136] "w2MP"  "w2MS"  "w2MU"  "w2RA"  "w2RP"  "w2RS"  "w2RU"  "w2TA"  "w2TP" 
    ## [145] "w2TS"  "w2TU"  "w3AA"  "w3AP"  "w3AS"  "w3AU"  "w3MA"  "w3MP"  "w3MS" 
    ## [154] "w3MU"  "w3TA"  "w3TP"  "w3TS"  "w3TU"

``` r
filtered_R <- diagonal_R[!endsWith(diagonal_R$from, "U"), ]
      
#Check for any differences in what compartments there are between versions
diagonal_R$from[!diagonal_R$from %in% diagonal_excel$from] # "sd0C" "sd0R" were added in sboo v1
```

    ##  [1] "aAU"   "aCU"   "aMU"   "aRU"   "aTU"   "s1CU"  "s1RU"  "s2CU"  "s2RU" 
    ## [10] "s3CU"  "s3RU"  "sAU"   "sd0CU" "sd0RU" "sd1CU" "sd1RU" "sd2CU" "sd2RU"
    ## [19] "sdAU"  "sdMU"  "sdTU"  "sMU"   "sTU"   "w0AU"  "w0CU"  "w0MU"  "w0RU" 
    ## [28] "w0TU"  "w1CU"  "w1RU"  "w2AU"  "w2CU"  "w2MU"  "w2RU"  "w2TU"  "w3AU" 
    ## [37] "w3MU"  "w3TU"

``` r
filtered_R$from[!filtered_R$from %in% filtered_excel$from]
```

    ## character(0)

``` r
diagonal_excel$from[!diagonal_excel$from %in% diagonal_R$from] #all excel diagonals are in those of R
```

    ##  [1] "aRG"   "w0RD"  "w1RD"  "w2RD"  "sd0RD" "sd1RD" "sd2RD" "s1RD"  "s2RD" 
    ## [10] "s3RD"  "aCG"   "w0CD"  "w1CD"  "w2CD"  "sd0CD" "sd1CD" "sd2CD" "s1CD" 
    ## [19] "s2CD"  "s3CD"  "aMG"   "w2MD"  "w3MD"  "sdMD"  "sMD"   "aAG"   "w2AD" 
    ## [28] "w3AD"  "sdAD"  "sAD"   "aTG"   "w2TD"  "w3TD"  "sdTD"  "sTD"

``` r
filtered_excel$from[!filtered_excel$from %in% filtered_R$from]
```

    ## character(0)

``` r
#Single dataframe with both the R and excel diagonals
merged_diagonal <- merge(filtered_R, filtered_excel, by = "from", suffixes = c("_R", "_Excel")) 
merged_diagonal$k_Excel <- -merged_diagonal$k_Excel #Turning the "negative" values from the Excel matrix into positive ones
merged_diagonal$diff <- merged_diagonal$k_R - merged_diagonal$k_Excel 
sorted_diff <- merged_diagonal[order(abs(merged_diagonal$diff), decreasing = TRUE), ] |>
  mutate(reldif  = abs(diff/k_R))



SBexcel.K <- filter(SBexcel.K, k != 0 & SBexcel.K$from != SBexcel.K$to)
SBexcel.K$fromto <- paste(sep = "_", SBexcel.K$from, SBexcel.K$to)

mergedkaas <- merge(kaas2, SBexcel.K, by = c("from", "to"), suffixes = c("_R", "_Excel"))

mergedkaas$diff <- mergedkaas$k_R - mergedkaas$k_Excel #compare R k to Excel K

mergedkaas <- as_tibble(mergedkaas) |> mutate(relDif = diff/k_R)  
```

## Compare k’s

When comparing k’s between R and excel, the goal is that the difference
is less than 1 percentile for each k. The reason is that smaller
differences often are a result of differences in rounding values between
excel and R, and not the result of mistakes in calculations or different
input values. In this vignette two types of k’s are compared: diagonal
k’s and from-to k’s.

At the time of this verification, some improvements were already made in
the R version versus the excel version. This meant that some k’s differ
between R and excel, but not because the calculations or input values
are wrong. In order to still be able to compare the two versions, the
‘Test’ variable was created. This variable is a boolean, that can be
used to calculate some processes in R the same way as in excel for the
verification without removing the improvements that are made. When this
test variable was used and why will be explained below.

### Diagonal k’s

Diagonal k’s are k’s that are on the diagonal of the k matrix. They are
calculated as the sum of all the k’s leaving the subcompartment plus the
sum of the removal process k’s (i.e. degradation or burial).

![](Particulate-verification_files/figure-gfm/Plot%20diagonal%20differences-1.png)<!-- -->![](Particulate-verification_files/figure-gfm/Plot%20diagonal%20differences-2.png)<!-- -->

``` r
soil <- kaas|>
  filter(fromSubCompart == "agriculturalsoil") |>
  filter(fromScale == "Continental") |>
  filter(fromSpecies == "Large")

subst <- read.csv("data/Substances.csv") |>
  filter(Substance == substance)
```

Figures 1 and 2 above show the absolute and relative differences in
diagonal k’s between R and excel. As can be seen in Figure 2, relative
differences larger than 1 percentile are soil, sediment and water
compartments.

#### Soil degradation

The large relative differences in the diagonal k’s for soil between R
and Excel can be attributed to a difference in kdeg values. In R, all
kdeg values are 1e-20 because R cannot solve the matrix when k’s are 0.
In Excel this is not a problem because the k’s coming from each
compartment are summed before the matrix is solved, and therefore some
k’s can be 0.

#### Soil dissolution

In the current version of R dissolution is not taken into account. In
Excel it is, which is another cause for some large relative differences
between R and Excel. The Test variable was used to add kdis to
k_Degragation in the k_Degradation function. This needs a more permanent
fix with its own function (k_Dissolution) for the relevant compartments.

### From-to k’s

![](Particulate-verification_files/figure-gfm/Plot%20k%20differences-1.png)<!-- -->![](Particulate-verification_files/figure-gfm/Plot%20k%20differences-2.png)<!-- -->

As can be seen in Figure 4, there are no k’s with a relative difference
large than 1 percentile between excel and R.

``` r
fromwater <- kaas |>
  filter(fromSubCompart == "sea") |>
  filter(fromScale == "Continental") |>
  filter(toSubCompart == "marinesediment")


lake <- kaas |>
  filter(fromSubCompart == "lakesediment")
```

## Run again with an altered copy of the excel file

An altered copy of the Excel file used for comparison was created. In
this file, all kdeg rates were changed from 0 to 1e-20.

    ## [1] 24025

    ## [1] "Arctic"      "Continental" "Moderate"    "Regional"    "Tropic"

    ##  [1] "marinesediment"     "freshwatersediment" "lakesediment"      
    ##  [4] "air"                "naturalsoil"        "agriculturalsoil"  
    ##  [7] "othersoil"          "deepocean"          "lake"              
    ## [10] "river"              "sea"                "cloudwater"

    ##   [1] "aAA"   "aAP"   "aAS"   "aAU"   "aCA"   "aCP"   "aCS"   "aCU"   "aMA"  
    ##  [10] "aMP"   "aMS"   "aMU"   "aRA"   "aRP"   "aRS"   "aRU"   "aTA"   "aTP"  
    ##  [19] "aTS"   "aTU"   "cwAA"  "cwAP"  "cwAS"  "cwCA"  "cwCP"  "cwCS"  "cwMA" 
    ##  [28] "cwMP"  "cwMS"  "cwRA"  "cwRP"  "cwRS"  "cwTA"  "cwTP"  "cwTS"  "s1CA" 
    ##  [37] "s1CP"  "s1CS"  "s1CU"  "s1RA"  "s1RP"  "s1RS"  "s1RU"  "s2CA"  "s2CP" 
    ##  [46] "s2CS"  "s2CU"  "s2RA"  "s2RP"  "s2RS"  "s2RU"  "s3CA"  "s3CP"  "s3CS" 
    ##  [55] "s3CU"  "s3RA"  "s3RP"  "s3RS"  "s3RU"  "sAA"   "sAP"   "sAS"   "sAU"  
    ##  [64] "sd0CA" "sd0CP" "sd0CS" "sd0CU" "sd0RA" "sd0RP" "sd0RS" "sd0RU" "sd1CA"
    ##  [73] "sd1CP" "sd1CS" "sd1CU" "sd1RA" "sd1RP" "sd1RS" "sd1RU" "sd2CA" "sd2CP"
    ##  [82] "sd2CS" "sd2CU" "sd2RA" "sd2RP" "sd2RS" "sd2RU" "sdAA"  "sdAP"  "sdAS" 
    ##  [91] "sdAU"  "sdMA"  "sdMP"  "sdMS"  "sdMU"  "sdTA"  "sdTP"  "sdTS"  "sdTU" 
    ## [100] "sMA"   "sMP"   "sMS"   "sMU"   "sTA"   "sTP"   "sTS"   "sTU"   "w0AU" 
    ## [109] "w0CA"  "w0CP"  "w0CS"  "w0CU"  "w0MU"  "w0RA"  "w0RP"  "w0RS"  "w0RU" 
    ## [118] "w0TU"  "w1CA"  "w1CP"  "w1CS"  "w1CU"  "w1RA"  "w1RP"  "w1RS"  "w1RU" 
    ## [127] "w2AA"  "w2AP"  "w2AS"  "w2AU"  "w2CA"  "w2CP"  "w2CS"  "w2CU"  "w2MA" 
    ## [136] "w2MP"  "w2MS"  "w2MU"  "w2RA"  "w2RP"  "w2RS"  "w2RU"  "w2TA"  "w2TP" 
    ## [145] "w2TS"  "w2TU"  "w3AA"  "w3AP"  "w3AS"  "w3AU"  "w3MA"  "w3MP"  "w3MS" 
    ## [154] "w3MU"  "w3TA"  "w3TP"  "w3TS"  "w3TU"

    ##  [1] "aAU"   "aCU"   "aMU"   "aRU"   "aTU"   "s1CU"  "s1RU"  "s2CU"  "s2RU" 
    ## [10] "s3CU"  "s3RU"  "sAU"   "sd0CU" "sd0RU" "sd1CU" "sd1RU" "sd2CU" "sd2RU"
    ## [19] "sdAU"  "sdMU"  "sdTU"  "sMU"   "sTU"   "w0AU"  "w0CU"  "w0MU"  "w0RU" 
    ## [28] "w0TU"  "w1CU"  "w1RU"  "w2AU"  "w2CU"  "w2MU"  "w2RU"  "w2TU"  "w3AU" 
    ## [37] "w3MU"  "w3TU"

    ## character(0)

    ##  [1] "aRG"   "w0RD"  "w1RD"  "w2RD"  "sd0RD" "sd1RD" "sd2RD" "s1RD"  "s2RD" 
    ## [10] "s3RD"  "aCG"   "w0CD"  "w1CD"  "w2CD"  "sd0CD" "sd1CD" "sd2CD" "s1CD" 
    ## [19] "s2CD"  "s3CD"  "aMG"   "w2MD"  "w3MD"  "sdMD"  "sMD"   "aAG"   "w2AD" 
    ## [28] "w3AD"  "sdAD"  "sAD"   "aTG"   "w2TD"  "w3TD"  "sdTD"  "sTD"

    ## character(0)

![](Particulate-verification_files/figure-gfm/Test%20TRUE-1.png)<!-- -->![](Particulate-verification_files/figure-gfm/Test%20TRUE-2.png)<!-- -->

As can be seen in Figures 5 and 6, the changes made to the copy of the
excel file solved the large differences in k’s between R and excel for
the diagonal k’s. All relative differences are now smaller than 1
percentile.

## Compare steady state emissions

The steady state masses in R and Excel were compared by calculating the
relative differences between the masses in R and Excel (Figure 7). The
figure shows that all masses between R and Excel relatively differ less
than 1 percentile.

![](Particulate-verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->

## Test = FALSE

Now, we will observe the differences made to the code for the R-version
by returning to Test = False. This excludes any adjustments to the
DragCoefficient options for the settling velocity, which are highlighted
in the vignette about Sedimentation. The following adjustments are then
initialized:

- kdis is not included

- Dry Deposition is implemented in a new manner, according to the Loteur
  v2 reference guide. See v.2.2002 <https://www.rivm.nl/lotos-euros>

- Thermal velocity in heteroagglomeration is now calculated according to
  the temperature of the scale, instead of a constant value of T = 285K.

As can be observed from Figure 8 and 9, Relative differences become
large (\>0.8). Most of these differences are attributed to the
adjustments in the Dry Deposition implementation.

    ##      x  Test
    ## 1 TRUE FALSE

    ## [1] 24025

    ## [1] "Arctic"      "Continental" "Moderate"    "Regional"    "Tropic"

    ##  [1] "marinesediment"     "freshwatersediment" "lakesediment"      
    ##  [4] "air"                "deepocean"          "naturalsoil"       
    ##  [7] "sea"                "agriculturalsoil"   "lake"              
    ## [10] "othersoil"          "river"              "cloudwater"

    ##   [1] "aAA"   "aAP"   "aAS"   "aAU"   "aCA"   "aCP"   "aCS"   "aCU"   "aMA"  
    ##  [10] "aMP"   "aMS"   "aMU"   "aRA"   "aRP"   "aRS"   "aRU"   "aTA"   "aTP"  
    ##  [19] "aTS"   "aTU"   "cwAA"  "cwAP"  "cwAS"  "cwCA"  "cwCP"  "cwCS"  "cwMA" 
    ##  [28] "cwMP"  "cwMS"  "cwRA"  "cwRP"  "cwRS"  "cwTA"  "cwTP"  "cwTS"  "s1CA" 
    ##  [37] "s1CP"  "s1CS"  "s1CU"  "s1RA"  "s1RP"  "s1RS"  "s1RU"  "s2CA"  "s2CP" 
    ##  [46] "s2CS"  "s2CU"  "s2RA"  "s2RP"  "s2RS"  "s2RU"  "s3CA"  "s3CP"  "s3CS" 
    ##  [55] "s3CU"  "s3RA"  "s3RP"  "s3RS"  "s3RU"  "sAA"   "sAP"   "sAS"   "sAU"  
    ##  [64] "sd0CA" "sd0CP" "sd0CS" "sd0CU" "sd0RA" "sd0RP" "sd0RS" "sd0RU" "sd1CA"
    ##  [73] "sd1CP" "sd1CS" "sd1CU" "sd1RA" "sd1RP" "sd1RS" "sd1RU" "sd2CA" "sd2CP"
    ##  [82] "sd2CS" "sd2CU" "sd2RA" "sd2RP" "sd2RS" "sd2RU" "sdAA"  "sdAP"  "sdAS" 
    ##  [91] "sdAU"  "sdMA"  "sdMP"  "sdMS"  "sdMU"  "sdTA"  "sdTP"  "sdTS"  "sdTU" 
    ## [100] "sMA"   "sMP"   "sMS"   "sMU"   "sTA"   "sTP"   "sTS"   "sTU"   "w0CA" 
    ## [109] "w0CP"  "w0CS"  "w0CU"  "w0RA"  "w0RP"  "w0RS"  "w0RU"  "w1CA"  "w1CP" 
    ## [118] "w1CS"  "w1CU"  "w1RA"  "w1RP"  "w1RS"  "w1RU"  "w2AA"  "w2AP"  "w2AS" 
    ## [127] "w2AU"  "w2CA"  "w2CP"  "w2CS"  "w2CU"  "w2MA"  "w2MP"  "w2MS"  "w2MU" 
    ## [136] "w2RA"  "w2RP"  "w2RS"  "w2RU"  "w2TA"  "w2TP"  "w2TS"  "w2TU"  "w3AA" 
    ## [145] "w3AP"  "w3AS"  "w3AU"  "w3MA"  "w3MP"  "w3MS"  "w3MU"  "w3TA"  "w3TP" 
    ## [154] "w3TS"  "w3TU"

    ##  [1] "aAU"   "aCU"   "aMU"   "aRU"   "aTU"   "s1CU"  "s1RU"  "s2CU"  "s2RU" 
    ## [10] "s3CU"  "s3RU"  "sAU"   "sd0CU" "sd0RU" "sd1CU" "sd1RU" "sd2CU" "sd2RU"
    ## [19] "sdAU"  "sdMU"  "sdTU"  "sMU"   "sTU"   "w0CU"  "w0RU"  "w1CU"  "w1RU" 
    ## [28] "w2AU"  "w2CU"  "w2MU"  "w2RU"  "w2TU"  "w3AU"  "w3MU"  "w3TU"

    ## character(0)

    ##  [1] "aRG"   "w0RD"  "w1RD"  "w2RD"  "sd0RD" "sd1RD" "sd2RD" "s1RD"  "s2RD" 
    ## [10] "s3RD"  "aCG"   "w0CD"  "w1CD"  "w2CD"  "sd0CD" "sd1CD" "sd2CD" "s1CD" 
    ## [19] "s2CD"  "s3CD"  "aMG"   "w2MD"  "w3MD"  "sdMD"  "sMD"   "aAG"   "w2AD" 
    ## [28] "w3AD"  "sdAD"  "sAD"   "aTG"   "w2TD"  "w3TD"  "sdTD"  "sTD"

    ## character(0)

![](Particulate-verification_files/figure-gfm/comparison%20of%20fluxes%20with%20test%20FALSE-1.png)<!-- -->![](Particulate-verification_files/figure-gfm/comparison%20of%20fluxes%20with%20test%20FALSE-2.png)<!-- -->
