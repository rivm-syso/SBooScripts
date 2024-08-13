Microplastic verification
================
Anne Hids & Valerie de Rijk
2024-08-13

This vignette demonstrates the verification process of the particulate
version of Simplebox, in this case for microplastics. First, the k’s are
compared between R and excel and consequently the steady state masses
are compared.

The world needs to be initialized for a substance. In this case, that
substance is microplastic, which has a default radius of 2.5e-5 m.

We will first show the version of the model without adjustments to match
the excel version. This will show the differences between excel and R.
Consequently, we will show the version of the model that was adjusted to
match the excel version. This adjusted version should yield the same
results as the model in excel, except for rounding differences.

## Run the model without adjustments

``` r
substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")

World$substance <- substance
```

## Compare k’s

When comparing k’s between R and excel, the goal is that the relative
difference is less than 0.001 for each k. The reason is that smaller
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

![](Microplastic_verification_files/figure-gfm/Plot%20diagonal%20differences-1.png)<!-- -->![](Microplastic_verification_files/figure-gfm/Plot%20diagonal%20differences-2.png)<!-- -->

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
difference large than 0.001 between excel and R when Test=TRUE.

## Compare steady state emissions

The steady state masses in R and Excel were compared by calculating the
relative differences between the masses in R and Excel (Figure 7). The
figure shows that all masses between R and Excel relatively differ less
than 0.001.

![](Microplastic_verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->
