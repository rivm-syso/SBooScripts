Microplastic verification
================
Anne Hids & Valerie de Rijk
2024-08-05

This vignette demonstrates the verification process of the particulate
version of Simplebox, in this case for microplastics. First, the k’s are
compared between R and excel and consequently the steady state masses
are compared.

The world needs to be initialized for a substance. In this case, that
substance is microplastic, which has a default radius of 2.5e-5 m.

We will first show the version of the R-code that has been adjusted to
match the Excel Version. This means that the code is initialized with
the parameter Test = TRUE. As such, this code should match (except for
rounding differences) the results of the Excel version.

## Test = TRUE

``` r
substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
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

![](Microplastic-verification_files/figure-gfm/Plot%20diagonal%20differences-1.png)<!-- -->![](Microplastic-verification_files/figure-gfm/Plot%20diagonal%20differences-2.png)<!-- -->

Figures 1 and 2 above show the absolute and relative differences in
diagonal k’s between R and excel As can be observed, there’s no large
differences.

### From-to k’s

![](Microplastic-verification_files/figure-gfm/Plot%20k%20differences-1.png)<!-- -->![](Microplastic-verification_files/figure-gfm/Plot%20k%20differences-2.png)<!-- -->

As can be seen in Figure 4, there are no k’s with a relative difference
large than 1 percentile between excel and R.

## Compare steady state emissions

The steady state masses in R and Excel were compared by calculating the
relative differences between the masses in R and Excel (Figure 5). The
figure shows that all masses between R and Excel relatively differ less
than 1 percentile.

![](Microplastic-verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->

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

As can be observed from Figure 6 and 7, Relative differences become
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

![](Microplastic-verification_files/figure-gfm/comparison%20of%20fluxes%20with%20test%20FALSE-1.png)<!-- -->![](Microplastic-verification_files/figure-gfm/comparison%20of%20fluxes%20with%20test%20FALSE-2.png)<!-- -->
