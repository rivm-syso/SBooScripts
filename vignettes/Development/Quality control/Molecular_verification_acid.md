Verification of SimpleBox - spreadsheet versus R implementation for acid
organic chemicals
================
Anne Hids, Valerie de Rijk, Matthias Hof and Joris Quik
2025-03-31

This vignette demonstrates the verification process of SimpleBox
implemented in R (version 2024.8.0) and in an Excel<sup>TM</sup>
spreadsheet (xl v4.0.5). To do this the 1<sup>st</sup> order rate
constants (k’s) and steady state masses are compared between the two
model implementations. The differences should be negligible and only
based on rounding errors. In this case we choose a relative difference
of the k’s or masses between the models to not exceed 0.1%.

# Verification method

``` r
# Create a list with the names of substances
Potential_substances <- c(
  "1-aminoanthraquinone", # no class
  "1-HYDROXYANTHRAQUINONE", # acid
  "1-Hexadecanamine, N,N-dimethyl-", # base
  "1-Chloro-2-nitro-propane", # neutral
  "Sb(III)" # metal
)

substance <- Potential_substances[2]

source("baseScripts/initWorld_onlyMolec.R")
```

The SBoo world is initialized for a substance. In this case, that
substance is air, cloudwater, marinesediment, freshwatersediment,
lakesediment, naturalsoil, othersoil, agriculturalsoil, deepocean,
river, sea, lake, which is of class: acid.

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

# Step 1. Compare SBoo (incl. updates) to spreadsheet

## preliminary matrix check

In the chunk below we check if our matrix is as large as we expect it to
be.

1)  Matrix The SimpleBox model operates over 5 scales, 12
    subcompartments and 4 different speciations. For molecules, this is
    already filtered to only include one species: Unbound. As such, we
    would expect our matrix to have 5 \* 12 \* 1 = 60 rows. However,
    some exceptions exist within our SB world:

- The Regional and Continental scale do now have a deepocean layer (w3),
  reducing the matrix by 2 \* 1 = 2 rows.
- The Global Scales (Arctic, Moderate, Tropic) only have one type of
  soil instead of 3, reducing the matrix by 3 \* 2 = 6 rows.
- The Global Scales (Arctic, Moderate, Tropic) only have one type of
  sediment instead of 3, reducing the matrix by 3 \* 2 = 6 rows.
- The Global Scales (Arctic, Moderate, Tropic) only have one type of
  water instead of 3, reducing the matrix by 3 \* 2 = 6 rows.
- Cloudwater (compartment) does not have any values, reducing our matrix
  by 5 \* 1 \* 1 = 5 rows.

With these exceptions, we expect our matrix to be 60- 25 = 35 rows. This
script will stop running if this is not the case.

2)  We expect all processes to be included in Processes4SpeciesTp.csv to
    also be calculated. Therefore, we compare the calculated unique
    processes with the processes defined in this csv.

<!-- -->

    ## character(0)

## Compare k’s

When comparing k’s between R and excel, the goal is that the relative
difference is less than 1 percentile for each k. The reason is that
smaller differences often are a result of differences in rounding values
between excel and R, and not the result of mistakes in calculations or
different input values. In this vignette two types of k’s are compared:
diagonal k’s and from-to k’s.

At the time of this verification, some improvements were already made in
the R version versus the excel version. This meant that some k’s differ
between R and excel, but not because the calculations or input values
are wrong. In order to still be able to compare the two versions, the
‘Test’ variable was created. This variable is a boolean that can be used
to calculate some processes in R the same way as in excel for the
verification without removing the improvements that are made. When this
test variable was used and why will be explained below.

### Diagonal k’s

Diagonal k’s are k’s that are on the diagonal of the k matrix. They are
calculated as the sum of all the k’s leaving the subcompartment plus the
sum of the removal process k’s (i.e. degradation or burial).

Figures 1 and 2 above show the absolute and relative differences in
diagonal k’s between R and excel. As can be seen in Figure 2, relative
differences larger than 1 percentile are in the lake, freshwater and
sediment subcompartments.

#### Lake difference

The relative difference in lake removal rate is caused by lake
sedimentation being included in R but not in excel. To make an accurate
comparison between R and excel, the Test variable was used to exclude
flows from lake to lakesediment in the processes k_Sedimentation and
k_Adsorption.

#### Settling velocity

The difference in the diagonal k’s for sedimentation comes from a
difference in k’s for the sedimentation and resuspension processes.

This is caused by the use of different formulas to calculate settling
velocity between excel and R. In excel, settling velocity is always
calculated as:

`SetVel <- 2.5/(24*3600)`

While in R, an improved version of this formula is used:

`SetVel <- 2*(radius^2*(rhoParticle-rhoWater)*GN) / (9*DynViscWaterStandard)`

Using the Test variable, the settling velocity formula is temporarily
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
these values were rounded in the test files that were used for
comparison to the R output. There is an
[issue](https://github.com/rivm-syso/SBoo/issues/158) to fix this in a
future SBooScript update.

### From-to k’s

We can filter out the exact k’s that have a relative difference larger
than 0.1%:

#### Sedimentation and resuspension

As can be seen in Figure 2 and the table above, the k’s that have a
relative difference larger than 0.1% go from water to sediment or from
sediment to water. Changing the formula for calculating settling
velocity when Test = TRUE for the sedimentation and resuspension
processes (explained above under ‘Settling velocity’) also solves these
differences.

### Steadystate mass

    ## 12 rate constants (k values) equal to 0; removed for solver

    ## `summarise()` has grouped output by 'Scale', 'SubCompart', 'Species'. You can
    ## override using the `.groups` argument.

<figure>
<img
src="Molecular_verification_acid_files/figure-gfm/PlotSteadyState_1-1.png"
alt="Figure 3: Relative differences in steady state mass per compartment between R (SB1solve) and Spreadsheet implementation of SimpleBox (Test=FALSE)" />
<figcaption aria-hidden="true">Figure 3: Relative differences in steady
state mass per compartment between R (SB1solve) and Spreadsheet
implementation of SimpleBox (Test=FALSE)</figcaption>
</figure>

The differences in k’s drives the model output: the steady state mass.
So a final check is to see how much the steady state masses differ
between both implementations of SimpleBox (Figure 3). From this it is
clear that there are differences up to 0.7%.

# Step 2. Compare SBoo and Spreadsheet excluding updates (Test=TRUE)

Now the value for the Test variable can be changed to TRUE, and the
difference in k’s between excel and R can be tested again:

## Compare first order rate constants

<figure>
<img
src="Molecular_verification_acid_files/figure-gfm/PlotDiagonalk_2-1.png"
alt="Figure 4: Relative differences sum of from-k’s between R and Spreadsheet implementation of SimpleBox (Test=TRUE)" />
<figcaption aria-hidden="true">Figure 4: Relative differences sum of
from-k’s between R and Spreadsheet implementation of SimpleBox
(Test=TRUE)</figcaption>
</figure>

As can be seen in Figures 4 and 5, the temporary changes made using the
Test variable solved the large differences in k’s between R and excel
for both the diagonal and the from-to k’s. All relative differences are
now smaller than 1 percentile.

## Steadystate mass

    ## 12 rate constants (k values) equal to 0; removed for solver

    ## `summarise()` has grouped output by 'Scale', 'SubCompart', 'Species'. You can
    ## override using the `.groups` argument.

<figure>
<img
src="Molecular_verification_acid_files/figure-gfm/PlotSteadyState_2-1.png"
alt="Figure 6: Relative differences in steady state mass per compartment between R (SB1solve) and Spreadsheet implementation of SimpleBox (Test=TRUE)" />
<figcaption aria-hidden="true">Figure 6: Relative differences in steady
state mass per compartment between R (SB1solve) and Spreadsheet
implementation of SimpleBox (Test=TRUE)</figcaption>
</figure>

To test if the small differences (\<0.1%) in first order rate constants
is negligible (Figures 4 and 5), the steady state masses should also not
differ by more than 0.1% between the R and Spreadsheet implementations
of SimpleBox. This is indeed the case (Figure 6) as the max difference
in now only 0.016%. This proves that the port of SimpleBox to R is
successful in reproducing the results from the original spreadsheet
implementation for chemicals of class acid.

## Concentrations

The default concentrations are calculated using `World$Concentration()`.

# Step 3. Verify dynamic solver

The dynamic solver can use time explicit emissions and provide masses or
concentrations in time. This shows the increase in mass in each
compartment in time based on a specified emission, see
[here](vignettes/10.0-Solver-use.md "Solver documentation") for more
details. Below we verify that with constant emission in time the steady
state mass is approached as verified with Excel above.
