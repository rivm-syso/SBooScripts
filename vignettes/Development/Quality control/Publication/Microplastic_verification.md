Verification of SimpleBox4Plastics - spreadsheet versus R implementation
================
Anne Hids, Valerie de Rijk, Matthis Hof and Joris Quik
2024-08-14

This vignette demonstrates the verification process of SimpleBox
implemented in R (version 2024.8.0) and in an Excel<sup>TM</sup>
spreadsheet (xl4plastic v4.0.5). To do this the 1<sup>st</sup> order
rate constants (k’s) and steady state masses are compared between the
two model implementations. The differences should be negligible and only
based on rounding errors. In this case we choose a relative difference
of the k’s or masses between the models to not exceed 0.1%.

# Verification method

``` r
substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
```

The SBoo world is initialized for a substance. In this case, that
substance is ``` r``World$fetchData("Substance") ```, which has a
default radius of 25 µm.

At release already improvements or developments have been implemented in
the R version of SimpleBox (SBoo) which are not implemented in Excel
which will result in differences between the spreadsheet and R
implementation. For this reason a TEST variable has been introduced to
the changed algorithms in R in order to verify the outcome of SimpleBox
in R with the original implementation in the spreadsheet version. So,
TEST variable is a boolean, that can be used to calculate some processes
in R the same way as in excel for the verification without removing the
improvements that are made. For this reason we show the verification in
two steps:

1.  Compare k’s and steady state masses of SBoo with updates to the
    spreadsheet.

2.  Compare k’s and steady state masses of adapted SBoo using TEST
    variable to the spreadsheet.

When comparing k’s and steady state masses between SimpleBox in R and
Excel<sup>TM</sup>, the goal is that the relative difference is less
than 0.1 percent for each k and steady state mass. The reason is that
smaller differences are almost inevitable due to differences in rounding
values between excel and R, and not the result of mistakes in
calculations or input values.

## Step 1. Compare SBoo (incl. updates) to spreadsheet

## Compare first order rate constants

Two approaches are taken to comparing the ‘engine’ matrix of k’s. First
only the diagonal is taken and compared because this consists of all the
k’s relevant for that ‘from’ compartment including the removal
processes. Second, the separate k’s are compared per ‘from’ and ‘to’
compartment.

In summary k’s are compared using:

1.  The diagonal sum of k’s (from + removal)

2.  The separate from-to k’s

### Diagonal sum of ‘from’ k’s

Diagonal k’s are k’s that are on the diagonal of the k matrix. They are
calculated as the sum of all the k’s leaving the subcompartment plus the
sum of the removal process k’s (i.e. degradation or burial).

#### Dry deposition

As can be seen in Figure 2 above, the only relative differences between
the diagonal k’s in excel and R are in the air compartment. This is
caused by a difference in the dry deposition process. In R, dry
deposition is implemented in a new manner, according to the Loteur v2
reference guide. See v.2.2002 <https://www.rivm.nl/lotos-euros>.

When using Test=TRUE, the implementation of dry deposition in R is
temporarily set to the old implementation that was used in excel.

### From-to k’s

![](Microplastic_verification_files/figure-gfm/Plot%20k%20differences-1.png)<!-- -->![](Microplastic_verification_files/figure-gfm/Plot%20k%20differences-2.png)<!-- -->

#### Dry deposition

As can be seen in Figure 4, the largest relative differences in k’s
between R and excel are in the k’s from air to soil and water. These
differences can also be attributed to the different implementation of
the dry deposition process between excel and R.

#### Thermal velocity heteroagglomeration

A smaller difference that was found between the k’s in R and excel is
the value for thermal velocity in heteroagglomeration. In excel, a
constant value of 285K was used. In R, this value was updated by
calculating the value specifically for the temperature of the current
scale.

## Run again with Test=TRUE

Now the value for the Test variable can be changed to TRUE, and the
difference in k’s between excel and R can be tested again:

    ##       x Test
    ## 1 FALSE TRUE

![](Microplastic_verification_files/figure-gfm/Plots%20test%20TRUE-1.png)<!-- -->![](Microplastic_verification_files/figure-gfm/Plots%20test%20TRUE-2.png)<!-- -->

As can be seen in Figures 5 and 6, there are no k’s with a relative
difference large than 1 percentile between excel and R when Test=TRUE.

## Compare steady state emissions

The steady state masses in R and Excel were compared by calculating the
relative differences between the masses in R and Excel (Figure 7). The
figure shows that all masses between R and Excel relatively differ less
than 1 percentile.

![](Microplastic_verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->
