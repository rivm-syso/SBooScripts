Verification of SimpleBox4Plastics - spreadsheet versus R implementation
================
Anne Hids, Valerie de Rijk, Matthis Hof and Joris Quik
2024-08-15

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

<figure>
<img
src="Microplastic_verification_files/figure-gfm/PlotsDiagonalk_1-1.png"
alt="Figure 1: Relative differences sum of from-k’s between R and Spreadsheet implementation of SimpleBox (Test=FALSE)" />
<figcaption aria-hidden="true">Figure 1: Relative differences sum of
from-k’s between R and Spreadsheet implementation of SimpleBox
(Test=FALSE)</figcaption>
</figure>

### From-to k’s

<figure>
<img
src="Microplastic_verification_files/figure-gfm/PlotFromTok_1-1.png"
alt="Figure 2: Relative differences from-to k’s between R and Spreadsheet implementation of SimpleBox (Test=FALSE)" />
<figcaption aria-hidden="true">Figure 2: Relative differences from-to
k’s between R and Spreadsheet implementation of SimpleBox
(Test=FALSE)</figcaption>
</figure>

#### Dry deposition

As can be seen in Figure 1 and 2 above, the only relative differences
larger than 0.1% (e.g. for the diagonal k’s in excel and R) are in the
air compartment. This is caused by a difference in the implementation of
the dry deposition process. In R, dry deposition is implemented in a new
manner, according to the Loteur v2 reference guide. See v.2.2002
<https://www.rivm.nl/lotos-euros>. Whereas in the spreadsheet
implementation a slightly more simplified approach was taken.

Below Test=TRUE will be used, setting the implementation of dry
deposition in R temporarily to the old implementation that was used in
the Spreadsheet implementation of SimpleBox.

We can filter out the exact k’s that have a relative difference larger
than 0.1%:

| from | to   |          k_R | fromto_R |      k_Excel | fromto_Excel |          diff |     relDif |
|:-----|:-----|-------------:|:---------|-------------:|:-------------|--------------:|-----------:|
| aRS  | w0RS | 2.440030e-07 | aRS_w0RS | 2.754229e-07 | aRS_w0RS     | -3.141987e-08 | 0.12876839 |
| aRS  | w1RS | 2.684033e-06 | aRS_w1RS | 3.029651e-06 | aRS_w1RS     | -3.456186e-07 | 0.12876839 |
| aCS  | w0CS | 1.186619e-07 | aCS_w0CS | 1.339418e-07 | aCS_w0CS     | -1.527990e-08 | 0.12876839 |
| aCS  | w1CS | 1.305281e-06 | aCS_w1CS | 1.473360e-06 | aCS_w1CS     | -1.680789e-07 | 0.12876839 |
| aRA  | w1RA | 2.684033e-06 | aRA_w1RA | 3.029651e-06 | aRA_w1RA     | -3.456185e-07 | 0.12876837 |
| aRA  | w0RA | 2.440030e-07 | aRA_w0RA | 2.754229e-07 | aRA_w0RA     | -3.141987e-08 | 0.12876837 |
| aCA  | w0CA | 1.186619e-07 | aCA_w0CA | 1.339418e-07 | aCA_w0CA     | -1.527990e-08 | 0.12876837 |
| aCA  | w1CA | 1.305281e-06 | aCA_w1CA | 1.473360e-06 | aCA_w1CA     | -1.680789e-07 | 0.12876837 |
| aRS  | s3RS | 1.010625e-05 | aRS_s3RS | 1.102032e-05 | aRS_s3RS     | -9.140716e-07 | 0.09044616 |
| aCS  | s3CS | 4.914804e-06 | aCS_s3CS | 5.359329e-06 | aCS_s3CS     | -4.445251e-07 | 0.09044616 |
| aRA  | s3RA | 1.010625e-05 | aRA_s3RA | 1.102032e-05 | aRA_s3RA     | -9.140714e-07 | 0.09044614 |
| aCA  | s3CA | 4.914804e-06 | aCA_s3CA | 5.359329e-06 | aCA_s3CA     | -4.445250e-07 | 0.09044614 |
| aTS  | w2TS | 6.861974e-05 | aTS_w2TS | 7.362872e-05 | aTS_w2TS     | -5.008982e-06 | 0.07299623 |
| aTA  | w2TA | 6.861974e-05 | aTA_w2TA | 7.362872e-05 | aTA_w2TA     | -5.008981e-06 | 0.07299621 |
| aCS  | w2CS | 5.056345e-05 | aCS_w2CS | 5.425372e-05 | aCS_w2CS     | -3.690272e-06 | 0.07298300 |
| aMS  | w2MS | 4.901410e-05 | aMS_w2MS | 5.259130e-05 | aMS_w2MS     | -3.577196e-06 | 0.07298300 |
| aCA  | w2CA | 5.056345e-05 | aCA_w2CA | 5.425372e-05 | aCA_w2CA     | -3.690271e-06 | 0.07298297 |
| aMA  | w2MA | 4.901410e-05 | aMA_w2MA | 5.259130e-05 | aMA_w2MA     | -3.577195e-06 | 0.07298297 |
| aRS  | w2RS | 4.270079e-07 | aRS_w2RS | 4.581722e-07 | aRS_w2RS     | -3.116430e-08 | 0.07298296 |
| aRA  | w2RA | 4.270079e-07 | aRA_w2RA | 4.581722e-07 | aRA_w2RA     | -3.116429e-08 | 0.07298294 |
| aAS  | w2AS | 5.881692e-05 | aAS_w2AS | 6.310790e-05 | aAS_w2AS     | -4.290977e-06 | 0.07295481 |
| aAA  | w2AA | 5.881692e-05 | aAA_w2AA | 6.310790e-05 | aAA_w2AA     | -4.290976e-06 | 0.07295478 |
| aRS  | s2RS | 6.416688e-05 | aRS_s2RS | 6.612193e-05 | aRS_s2RS     | -1.955058e-06 | 0.03046833 |
| aCS  | s2CS | 3.120520e-05 | aCS_s2CS | 3.215597e-05 | aCS_s2CS     | -9.507705e-07 | 0.03046833 |
| aRA  | s2RA | 6.416688e-05 | aRA_s2RA | 6.612193e-05 | aRA_s2RA     | -1.955057e-06 | 0.03046831 |
| aCA  | s2CA | 3.120520e-05 | aCA_s2CA | 3.215597e-05 | aCA_s2CA     | -9.507699e-07 | 0.03046831 |
| aTS  | sTS  | 3.241292e-05 | aTS_sTS  | 3.320588e-05 | aTS_sTS      | -7.929539e-07 | 0.02446413 |
| aTA  | sTA  | 3.241292e-05 | aTA_sTA  | 3.320588e-05 | aTA_sTA      | -7.929533e-07 | 0.02446411 |
| aRS  | s1RS | 2.904455e-05 | aRS_s1RS | 2.975487e-05 | aRS_s1RS     | -7.103179e-07 | 0.02445615 |
| aMS  | sMS  | 5.402152e-05 | aMS_sMS  | 5.534268e-05 | aMS_sMS      | -1.321158e-06 | 0.02445615 |
| aCS  | s1CS | 1.412475e-05 | aCS_s1CS | 1.447019e-05 | aCS_s1CS     | -3.454370e-07 | 0.02445615 |
| aRA  | s1RA | 2.904455e-05 | aRA_s1RA | 2.975487e-05 | aRA_s1RA     | -7.103173e-07 | 0.02445613 |
| aMA  | sMA  | 5.402153e-05 | aMA_sMA  | 5.534268e-05 | aMA_sMA      | -1.321157e-06 | 0.02445613 |
| aCA  | s1CA | 1.412475e-05 | aCA_s1CA | 1.447019e-05 | aCA_s1CA     | -3.454367e-07 | 0.02445613 |
| aAS  | sAS  | 4.321720e-05 | aAS_sAS  | 4.427339e-05 | aAS_sAS      | -1.056192e-06 | 0.02443915 |
| aAA  | sAA  | 4.321720e-05 | aAA_sAA  | 4.427339e-05 | aAA_sAA      | -1.056191e-06 | 0.02443913 |

### Steadystate mass

<figure>
<img
src="Microplastic_verification_files/figure-gfm/PlotSteadyState_1-1.png"
alt="Figure 3: Relative differences in steady state mass per compartment between R (SB1solve) and Spreadsheet implementation of SimpleBox (Test=FALSE)" />
<figcaption aria-hidden="true">Figure 3: Relative differences in steady
state mass per compartment between R (SB1solve) and Spreadsheet
implementation of SimpleBox (Test=FALSE)</figcaption>
</figure>

The differences in k’s drives the model output: the steady state mass.
So a final check is to see how much the steady state masses differ
between both implementations of SimpleBox (Figure 3). From this it is
clear that there are differences up to 6.4%. This is larger than the
level we can consider negligible.

## Step 2. Compare SBoo and Spreadsheet excluding updates (Test=TRUE)

The verification’s goal is to make sure no mistakes are made in porting
SimpleBox from the spreadsheet implementation to R. For this reason the
Test variable was included in algorithms that already implemented
changes for specific variables or processes in SimpleBox. With the Test
variable changed to TRUE the difference in k’s and steady state masses
is shown again in relation to the intended 0.1% verification level.

<figure>
<img
src="Microplastic_verification_files/figure-gfm/PlotDiagonalk_2-1.png"
alt="Figure 4: Relative differences sum of from-k’s between R and Spreadsheet implementation of SimpleBox (Test=TRUE)" />
<figcaption aria-hidden="true">Figure 4: Relative differences sum of
from-k’s between R and Spreadsheet implementation of SimpleBox
(Test=TRUE)</figcaption>
</figure>

<figure>
<img
src="Microplastic_verification_files/figure-gfm/PlotFromTok_2-1.png"
alt="Figure 5: Relative differences from-to k’s between R and Spreadsheet implementation of SimpleBox (Test=TRUE)" />
<figcaption aria-hidden="true">Figure 5: Relative differences from-to
k’s between R and Spreadsheet implementation of SimpleBox
(Test=TRUE)</figcaption>
</figure>

As can be seen in Figures 4 and 5, there are no k’s with a relative
difference large than 0.1% between excel and R when Test=TRUE. Several
k’s have a relative difference between 0.1 and 0.01%. These are related
to: Heteroagglomeration in porous media between particulate (S) and
large heteroagglomerate/attached (P) species. Deposition from air to
water/soil Erosion from soil to water

### Steadystate mass

<figure>
<img
src="Microplastic_verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png"
alt="Figure 6: Relative differences in steady state mass per compartment between R (SB1solve) and Spreadsheet implementation of SimpleBox (Test=TRUE)" />
<figcaption aria-hidden="true">Figure 6: Relative differences in steady
state mass per compartment between R (SB1solve) and Spreadsheet
implementation of SimpleBox (Test=TRUE)</figcaption>
</figure>

    ## [1] 0.03

To test if the small differences (\<0.1%) in first order rate constants
is negligible (Figures 4 and 5), the steady state masses should also not
differ by more than 0.1% between the R and Spreadsheet implementations
of SimpleBox. This is indeed the case (Figure 6) as the max difference
in now only 0.03%. This proves that the port of SimpleBox4Plastics to R
is successful in reproducing the results from the original spreadsheet
implementation.
