Solvers and Approxfun
================
Valerie de Rijk
2024-08-20

# Different ways of solving

SimpleBox offers various solving techniques tailored to different
scenarios, currently categorized into two core types:

1)  Steady-State
2)  Dynamic

Each strategy provides unique possibilities for solving problems. In
this vignette, we will explore the use of these techniques and highlight
the differences between them.

## Steady State Solving

We will first demonstrate solving the system assuming steady state. This
means we will obtain one output: the assumed equilibrium mass in each
compartment. We first initialize the world, in this case for a molecular
substance, after which we will creaty dummy input emission data.

``` r
Potential_substances <- c("1-aminoanthraquinone", # no class
                          "1-HYDROXYANTHRAQUINONE", # acid
                          "1-Hexadecanamine, N,N-dimethyl-", # base
                          "1-Chloro-2-nitro-propane", # neutral
                          "Sb(III)" # metal
                          ) 
              
substance <- Potential_substances[3]

source("baseScripts/initWorld_onlyMolec.R")

World$substance <- substance
```

For Steady State solving the emissions need to be provided in a
dataframe consisting of two columns (\$Abr (for abbreviation of the
compartment) and Emis (the emission to the compartment)). This dataframe
cannot be time-dependent, as this goes against the principles for
solving steady state. We will now create our dummy data.

The emissions are assumed to be going into the model as kg/s. In theory,
you can choose any mass/s (like tonnes or mol) unit; what you put in is
what you get out, as long as you are careful with unit conversions.
However, since the rate constants within the model are within seconds,
you should always adhere to the time unit of seconds.

``` r
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10, 10, 10) ) 
```

We provide two steady-state solvers: SB1Solve and SBsteady.

SB1Solve solves using base-R’s solve which solves our matrix through
solving the equation a %\*% x = b for x, where b is our matrix and we
assume x = 0. SBsteady takes a different approach and runs the system of
first-order kinetics at the rates determined by the matrix of rate
constants. The function runs the simulation until the system reaches a
steady state, where the amounts in each compartment no longer change
over time.

For non-extreme parameter values, we assume that these outputs are
relatively similar.

We initialize and solve for the two solvers in the following way:

``` r
World$NewSolver("SB1Solve")
SB1Solve_output <- World$Solve(emissions)
```

    ## Warning in private$solver$PrepKaasM(): 12 k values equal to 0; removed for
    ## solver

``` r
World$NewSolver("SBsteady")
SBsteady_output <- World$Solve(emissions)
```

    ## Warning in private$solver$PrepKaasM(): 12 k values equal to 0; removed for
    ## solver

``` r
# Rename columns
SB1Solve_output <- SB1Solve_output |>
  rename(Eqmass_SB1Solve = EqMass)

SBsteady_output <- SBsteady_output |>
  rename(Eqmass_SBsteady = y)

SB1Solve_output <- SB1Solve_output |>
  mutate(Eqmass_SBsteady = SBsteady_output$Eqmass_SBsteady)

# Display the updated SB1Solve_output table
print(SB1Solve_output)
```

    ##      Abbr       Scale         SubCompart Species Eqmass_SB1Solve
    ## 196   aRU    Regional                air Unbound    2.308353e+05
    ## 234  w1RU    Regional              river Unbound    5.145173e+06
    ## 226  w0RU    Regional               lake Unbound    7.295933e+04
    ## 210  w2RU    Regional                sea Unbound    1.733837e+05
    ## 213 sd1RU    Regional freshwatersediment Unbound    4.958499e+08
    ## 223 sd0RU    Regional       lakesediment Unbound    4.601130e+05
    ## 183 sd2RU    Regional     marinesediment Unbound    8.375062e+06
    ## 217  s1RU    Regional        naturalsoil Unbound    7.371362e+06
    ## 182  s2RU    Regional   agriculturalsoil Unbound    1.210563e+08
    ## 207  s3RU    Regional          othersoil Unbound    1.054481e+06
    ## 204   aCU Continental                air Unbound    2.998461e+04
    ## 208  w1CU Continental              river Unbound    1.897770e+03
    ## 221  w0CU Continental               lake Unbound    2.303486e+03
    ## 220  w2CU Continental                sea Unbound    3.027279e+06
    ## 195 sd1CU Continental freshwatersediment Unbound    1.828916e+05
    ## 192 sd0CU Continental       lakesediment Unbound    1.454002e+04
    ## 197 sd2CU Continental     marinesediment Unbound    7.311427e+06
    ## 235  s1CU Continental        naturalsoil Unbound    4.513088e+05
    ## 187  s2CU Continental   agriculturalsoil Unbound    6.255455e+05
    ## 233  s3CU Continental          othersoil Unbound    6.431937e+04
    ## 211   aAU      Arctic                air Unbound    1.441034e+01
    ## 215  w2AU      Arctic                sea Unbound    6.701284e+04
    ## 203  w3AU      Arctic          deepocean Unbound    8.450758e+05
    ## 219 sd2AU      Arctic     marinesediment Unbound    1.843849e+05
    ## 214  s1AU      Arctic        naturalsoil Unbound    4.064755e+03
    ## 224   aMU    Moderate                air Unbound    6.487956e+02
    ## 225  w2MU    Moderate                sea Unbound    3.033558e+05
    ## 231  w3MU    Moderate          deepocean Unbound    1.357311e+06
    ## 206 sd2MU    Moderate     marinesediment Unbound    2.185435e+05
    ## 188  s1MU    Moderate        naturalsoil Unbound    3.731115e+04
    ## 227   aTU      Tropic                air Unbound    5.465697e+00
    ## 193  w2TU      Tropic                sea Unbound    3.522227e+02
    ## 201  w3TU      Tropic          deepocean Unbound    1.490192e+04
    ## 228 sd2TU      Tropic     marinesediment Unbound    1.610563e+03
    ## 202  s1TU      Tropic        naturalsoil Unbound    5.839513e+01
    ##     Eqmass_SBsteady
    ## 196    2.308353e+05
    ## 234    5.145173e+06
    ## 226    7.295933e+04
    ## 210    1.733837e+05
    ## 213    4.958499e+08
    ## 223    4.601130e+05
    ## 183    8.375062e+06
    ## 217    7.371362e+06
    ## 182    1.210563e+08
    ## 207    1.054481e+06
    ## 204    2.998461e+04
    ## 208    1.897770e+03
    ## 221    2.303486e+03
    ## 220    3.027279e+06
    ## 195    1.828916e+05
    ## 192    1.454002e+04
    ## 197    7.311427e+06
    ## 235    4.513088e+05
    ## 187    6.255455e+05
    ## 233    6.431937e+04
    ## 211    1.441026e+01
    ## 215    6.701233e+04
    ## 203    8.450601e+05
    ## 219    1.843787e+05
    ## 214    4.064640e+03
    ## 224    6.487956e+02
    ## 225    3.033558e+05
    ## 231    1.357311e+06
    ## 206    2.185433e+05
    ## 188    3.731115e+04
    ## 227    5.465696e+00
    ## 193    3.522225e+02
    ## 201    1.490191e+04
    ## 228    1.610562e+03
    ## 202    5.839513e+01

``` r
# Create the markdown table
markdown_table <- knitr::kable(SB1Solve_output)

# Print the markdown table
cat(markdown_table)
```

    ## |    |Abbr  |Scale       |SubCompart         |Species | Eqmass_SB1Solve| Eqmass_SBsteady| |:---|:-----|:-----------|:------------------|:-------|---------------:|---------------:| |196 |aRU   |Regional    |air                |Unbound |    2.308353e+05|    2.308353e+05| |234 |w1RU  |Regional    |river              |Unbound |    5.145173e+06|    5.145173e+06| |226 |w0RU  |Regional    |lake               |Unbound |    7.295933e+04|    7.295933e+04| |210 |w2RU  |Regional    |sea                |Unbound |    1.733837e+05|    1.733837e+05| |213 |sd1RU |Regional    |freshwatersediment |Unbound |    4.958499e+08|    4.958499e+08| |223 |sd0RU |Regional    |lakesediment       |Unbound |    4.601130e+05|    4.601130e+05| |183 |sd2RU |Regional    |marinesediment     |Unbound |    8.375062e+06|    8.375062e+06| |217 |s1RU  |Regional    |naturalsoil        |Unbound |    7.371362e+06|    7.371362e+06| |182 |s2RU  |Regional    |agriculturalsoil   |Unbound |    1.210563e+08|    1.210563e+08| |207 |s3RU  |Regional    |othersoil          |Unbound |    1.054481e+06|    1.054481e+06| |204 |aCU   |Continental |air                |Unbound |    2.998461e+04|    2.998461e+04| |208 |w1CU  |Continental |river              |Unbound |    1.897770e+03|    1.897770e+03| |221 |w0CU  |Continental |lake               |Unbound |    2.303486e+03|    2.303486e+03| |220 |w2CU  |Continental |sea                |Unbound |    3.027279e+06|    3.027279e+06| |195 |sd1CU |Continental |freshwatersediment |Unbound |    1.828916e+05|    1.828916e+05| |192 |sd0CU |Continental |lakesediment       |Unbound |    1.454002e+04|    1.454002e+04| |197 |sd2CU |Continental |marinesediment     |Unbound |    7.311427e+06|    7.311427e+06| |235 |s1CU  |Continental |naturalsoil        |Unbound |    4.513088e+05|    4.513088e+05| |187 |s2CU  |Continental |agriculturalsoil   |Unbound |    6.255455e+05|    6.255455e+05| |233 |s3CU  |Continental |othersoil          |Unbound |    6.431937e+04|    6.431937e+04| |211 |aAU   |Arctic      |air                |Unbound |    1.441034e+01|    1.441026e+01| |215 |w2AU  |Arctic      |sea                |Unbound |    6.701284e+04|    6.701233e+04| |203 |w3AU  |Arctic      |deepocean          |Unbound |    8.450758e+05|    8.450601e+05| |219 |sd2AU |Arctic      |marinesediment     |Unbound |    1.843849e+05|    1.843787e+05| |214 |s1AU  |Arctic      |naturalsoil        |Unbound |    4.064755e+03|    4.064640e+03| |224 |aMU   |Moderate    |air                |Unbound |    6.487956e+02|    6.487956e+02| |225 |w2MU  |Moderate    |sea                |Unbound |    3.033558e+05|    3.033558e+05| |231 |w3MU  |Moderate    |deepocean          |Unbound |    1.357311e+06|    1.357311e+06| |206 |sd2MU |Moderate    |marinesediment     |Unbound |    2.185435e+05|    2.185433e+05| |188 |s1MU  |Moderate    |naturalsoil        |Unbound |    3.731115e+04|    3.731115e+04| |227 |aTU   |Tropic      |air                |Unbound |    5.465696e+00|    5.465696e+00| |193 |w2TU  |Tropic      |sea                |Unbound |    3.522227e+02|    3.522225e+02| |201 |w3TU  |Tropic      |deepocean          |Unbound |    1.490192e+04|    1.490191e+04| |228 |sd2TU |Tropic      |marinesediment     |Unbound |    1.610563e+03|    1.610562e+03| |202 |s1TU  |Tropic      |naturalsoil        |Unbound |    5.839513e+01|    5.839513e+01|
