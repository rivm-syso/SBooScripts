Molecular verification - metal
================
Anne Hids
2024-08-13

This vignette demonstrates the verification process of the molecular
version of Simplebox for a substance of class ‘metal’. First, the k’s
are compared between R and excel, and consequently the steady state
masses are compared. This is done for 5 molecular substances; each of a
different chemical class (no class, acid, base, neutral and metal). The
reason that the verification is performed for each of these classes is
that some processes differ per class.

First, the world needs to be initialized for a substance. In this case,
that substance is Sb(III), which is a metal.

``` r
# Create a list with the names of substances
Potential_substances <- c("1-aminoanthraquinone", # no class
                          "1-HYDROXYANTHRAQUINONE", # acid
                          "1-Hexadecanamine, N,N-dimethyl-", # base
                          "1-Chloro-2-nitro-propane", # neutral
                          "Sb(III)" # metal
                          ) 
              
substance <- Potential_substances[5]

source("baseScripts/initWorld_onlyMolec.R")

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

![](Molecular-verification---metal_files/figure-gfm/Plot%20diagonal%20differences-1.png)<!-- -->![](Molecular-verification---metal_files/figure-gfm/Plot%20diagonal%20differences-2.png)<!-- -->

Figures 1 and 2 above show the absolute and relative differences in
diagonal k’s between R and excel. As can be seen in Figure 2, relative
differences larger than 0.001 are in the lake and sediment
subcompartments.

#### Lake difference

The relative difference in lake removal rate is caused by lake
sedimentation being included in R but not in excel. To make an accurate
comparison between R and excel, the Test variable was used to exclude
flows from lake to lakesediment in the processes k_Sedimentation and
k_Adsorption.

#### Settling velocity

The difference the diagonal k’s for sedimentation comes from a
difference in k’s for the sedimentation and resuspension processes.

This is caused by the use of different formulas to calculate settling
velocity between excel and R. In excel, settling velocity is always
calculated as:

$$ 
SetVel <- 2.5/(24*3600)
$$ While in R, an improved version of this formula is used:

$$ 
SetVel <- 2*(radius^2*(rhoParticle-rhoWater)*GN) / (9*DynViscWaterStandard)
$$ Using the Test variable, the settling velocity formula is temporarily
changed to the formula used in excel for the resuspension ans
sedimentation processes (K_resuspension and k_Sedimentation). This
solves the differences in diagonal k’s related to resuspension or
sedimentation.

#### Degradation

For some substances, the bulk standard degradation rate constant for
air/water/soil/sediment (kdeg) has an input value, while for other
substances this value is calculated. When an input value is available,
this value has 2 decimals in R but more decimals in excel. This can
cause slight differences the k’s where this value is used. Therefore,
these values were rounded in the excel files that were used for
comparison to the R output.

### From-to k’s

![](Molecular-verification---metal_files/figure-gfm/Plot%20k%20differences-1.png)<!-- -->![](Molecular-verification---metal_files/figure-gfm/Plot%20k%20differences-2.png)<!-- -->

#### Sedimentation and resuspension

As can be seen in Figure 4 above, the k’s that have a relative
difference larger than 0.001 go from water to sediment or from sediment
to water. Changing the formula for calculating settling velocity when
Test = TRUE for the sedimentation and resuspension processes (explained
above under ‘Settling velocity’) also solves these differences.

## Run again with Test=TRUE

Now the value for the Test variable can be changed to TRUE, and the
difference in k’s between excel and R can be tested again:

    ##       x Test
    ## 1 FALSE TRUE

![](Molecular-verification---metal_files/figure-gfm/Test%20TRUE-1.png)<!-- -->![](Molecular-verification---metal_files/figure-gfm/Test%20TRUE-2.png)<!-- -->

As can be seen in Figures 5 and 6, the temporary changes made using the
Test variable solved the large differences in k’s between R and excel
for both the diagonal and the from-to k’s. All relative differences are
now smaller than 0.001.

## Compare steady state emissions

The steady state masses in R and Excel were compared by calculating the
relative differences between the masses in R and Excel (Figure 7). The
figure shows that all masses between R and Excel relatively differ less
than 0.001.

![](Molecular-verification---metal_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->
