Solver script
================
Valerie de Rijk, Joris Quik, Jaap Slootweg
2024-06-25

## Initiation

We assume you have the input data for a substance or material of
interest and all the data describing the SimpleBox world to be created
ready and thus can run the initWorld script.

``` r
library(dplyr)
substance <-  "GO-Chitosan"
source("baseScripts/initWorld_onlyParticulate.R")
```

## Computing Spherical equivalent diameter

We calculate the spherical equivalent diameter (deq) and subsequently
use it to overwrite radS. In this manner we include the shape of the
considered particles. We update the matrix in the chunk after. \[TODO:
In future this could be included in the initialization for relevant
particles that consist of multiple components\]

We need the following properties for the GO-Chitosan related particles:

- Shape

- Size

- Density

- Other ‘unknown’ variables, such as attachment efficiency, etc.

| Property             | GO-Chitosan     | GO              | Chitoson         |
|----------------------|-----------------|-----------------|------------------|
| Shape                | Sheet-like      | Flake           | Fragment         |
| Size - square (LxB)  | 70 - 90 (80) um | 70 - 90 (80) um | 100-200 (150) nm |
| Size - thickness (H) | 10-20 (15) nm   | 1-10 (5) nm     | 100-200 (150) nm |
| Density              | Calculated      | 0.35 g/ml       | 0.874 g/ml       |

The density of GO-chitosan is approximated by 1/8 \* dens_Graphene + 7/8
\* dens_Chitosan

``` r
# Longest <- World$fetchData("Longest_side")
# Intermediate <- World$fetchData("Intermediate_side")
# Shortest <- World$fetchData("Shortest_side")
Longest <- 80*1e-06
Intermediate <- 80*1e-06
Shortest <- 15*1e-9

Volume <- Longest*Intermediate*Shortest
d_eq <- ( 6/ pi * Volume)^(1/3)
rad_eq <- d_eq/2
print(rad_eq)
```

    ## [1] 2.840496e-06

``` r
World$SetConst(RadS = rad_eq)
```

    ##       x         RadS
    ## 1 4e-05 2.840496e-06

``` r
World$fetchData("RhoS")
```

    ## [1] 408

``` r
World$UpdateKaas(mergeExisting = F)
```

## Adjusting Parameters with Uncertainty

Since attachment efficiencies (alpha) are very uncertain, below is a
chunk where we can create distributions for these parameters. We start
however with a deterministic calculation using averages.

``` r
fwa_min <- 1e-4
fwa_max<- 0.1
n <- 100000
log_uniform_samples <- 10^runif(n, min = log10(fwa_min), max = log10(fwa_max))
fw_alpha_mean_log_samples <- mean(log_uniform_samples)


#Check with histogram 
hist(log_uniform_samples, breaks = 30, freq = FALSE,
     main = "Histogram of Log Uniform Distribution [10^-3, 10^-1]",
     xlab = "Value", ylab = "Density")
# Plot the probability density function (pdf) curve
curve(dunif(log10(x), min = log10(fwa_min), max = log10(fwa_max)) / x,
      from = fwa_min, to = fwa_max, add = TRUE, col = "blue", lwd = 2 )
```

![](x2CaseStudyChitosan_files/figure-gfm/Example%20Uncertain%20Alpha-1.png)<!-- -->

``` r
#marine 
ma_min <- 1e-3 
ma_max <- 1
log_uniform_samples <- 10^runif(n, min = log10(ma_min), max = log10(ma_max))
marine_alpha_mean_log_samples <- mean(log_uniform_samples)


subcompartsmarine <- c("sea", "marinesediment", "freshwatersediment", "deepocean")


subcomparts <- c("river", "lake", "water", "agriculturalsoil", "naturalsoil", "othersoil")
all_subcomparts <- c(subcomparts, subcompartsmarine)
#species <- rep(c("Large", "Small"), times = length(all_subcomparts))

alpha = data.frame(
SubCompart = c(subcomparts,subcompartsmarine),  
alpha = c(fw_alpha_mean_log_samples, marine_alpha_mean_log_samples))

World$fetchData("alpha")
```

    ##            SubCompart Species alpha
    ## 1    agriculturalsoil   Large  0.30
    ## 2    agriculturalsoil   Small  0.05
    ## 12          deepocean   Large  1.00
    ## 13          deepocean   Small  1.00
    ## 16 freshwatersediment   Large  0.30
    ## 17 freshwatersediment   Small  0.10
    ## 20               lake   Large  0.30
    ## 21               lake   Small  0.10
    ## 24       lakesediment   Large  0.40
    ## 25       lakesediment   Small  0.10
    ## 28     marinesediment   Large  1.00
    ## 29     marinesediment   Small  1.00
    ## 32        naturalsoil   Large  0.40
    ## 33        naturalsoil   Small  0.20
    ## 36          othersoil   Large  0.20
    ## 37          othersoil   Small  0.10
    ## 40              river   Large  0.30
    ## 41              river   Small  1.00
    ## 44                sea   Large  1.00
    ## 45                sea   Small  1.00

``` r
ToPaste <- lapply(list(alpha), function(x) {
  varName <- names(x)[!names(x) %in% The3D]
  stopifnot(length(varName)==1)
  # one line with 2 disadvantages of tidyverse..:
  as.data.frame(pivot_longer(data = x, cols = all_of(varName), names_to = "varName", values_to = "Waarde"))
})

dfs <- do.call(bind_rows, ToPaste)

World$mutateVars(dfs)

World$UpdateKaas(mergeExisting = F)
World$fetchData("alpha")
```

    ##            SubCompart Species      alpha
    ## 1    agriculturalsoil   Large 0.14583167
    ## 2    agriculturalsoil   Small 0.14583167
    ## 12          deepocean   Large 0.14583167
    ## 13          deepocean   Small 0.14583167
    ## 16 freshwatersediment   Large 0.01436581
    ## 17 freshwatersediment   Small 0.01436581
    ## 20               lake   Large 0.14583167
    ## 21               lake   Small 0.14583167
    ## 24       lakesediment   Large 0.40000000
    ## 25       lakesediment   Small 0.10000000
    ## 28     marinesediment   Large 0.14583167
    ## 29     marinesediment   Small 0.14583167
    ## 32        naturalsoil   Large 0.01436581
    ## 33        naturalsoil   Small 0.01436581
    ## 36          othersoil   Large 0.14583167
    ## 37          othersoil   Small 0.14583167
    ## 40              river   Large 0.01436581
    ## 41              river   Small 0.01436581
    ## 44                sea   Large 0.01436581
    ## 45                sea   Small 0.01436581

## NewSolver

Different solvers are available, basically:

1.  Solving the steadystate of the SimpleBox world

2.  Solving in time the states of SimpleBox world

Both will be illustrated bellow, but it starts with defining the solver
you want to use by `world$NewSolver("[name of s_function]")`

### SBsteady

Currently there are two ways to solve the matrix in steady state, so
with constant emission and infinite time horizon. These are:

1.  `SB1solve` - using solve from base R

2.  `SBsteady` - using runsteady from the rootSolve package

Another option would be to set a time horizon using the ode solver from
the DeSolve package. This can be done using `SBsolve`.

``` r
# World$NewSolver("SBsteady")
# SB1Solve provides the best results, this uses the solve function in R.
World$NewSolver("SB1Solve") 
```

What solving means is that using matrix algebra a set of differential
equations is solved:

`K %*% m + e`

Where:

K is the matrix of rate constants for each process describing the mass
transfers to and from and out of a state (e.g. substance in freshwater
(w1U) or small heteroagglomerate in natural soil (s1A)).

m is the mass in each compartment, e.g. 0 at t=0.

e is the emission to each compartment per unit of time, e.g. 1 t/y.

Here, we define the emissions for a Steady State Calculation, based on
averages for 2035 for GO-Chitosan. We convert the emissions to kg/s

``` r
emissions <- data.frame(Abbr = c("aCS", "s2CS", "w1CS"), 
                        Emis = c(0.000047, 43, 150))
emissions$Emis<- emissions$Emis * 1000 / (365.25 * 24 * 60 * 60)


# TODO: explain what is the reason for this Abbr? Why is it not a relational table defining scale, compartment and species as for all other data?
```

Now we are ready to run the solver, which results in the mass in each
compartment.

``` r
Solution <- World$Solve(emissions)
Solution <- Solution |>
  filter(Species != "Unbound")
#Solution <- World$SolutionAsRelational(Solution)
```

``` r
TotalMass <- Solution |>
  group_by(Scale) |>
  summarise(TotalMass = sum(EqMass))

TotalMassSpecies <- Solution |>
  group_by(Scale, Species) |>
  summarise(TotalMassSpecies = sum(EqMass))
```

    ## `summarise()` has grouped output by 'Scale'. You can override using the
    ## `.groups` argument.

``` r
MassFractions <- TotalMassSpecies |>
  left_join(TotalMass, by = "Scale") |>
  mutate(MassFraction = TotalMassSpecies / TotalMass)

ggplot(TotalMass, aes(x = Scale, y = TotalMass, fill = Scale)) +
  geom_bar(stat = "identity") +
  labs(x = "Scale", y = "Total Mass", title = "Total Mass per Scale") +
  theme_minimal()
```

![](x2CaseStudyChitosan_files/figure-gfm/Mass%20Fraction-1.png)<!-- -->

``` r
ggplot(MassFractions, aes(x = Scale, y = MassFraction, fill = Species)) +
  geom_bar(stat = "identity", position = "stack") +  # Adjust width as needed
  labs(x = "Scale", y = "Mass Fraction", title = "Mass Fraction of Species per Scale") +
  theme_minimal()
```

![](x2CaseStudyChitosan_files/figure-gfm/Mass%20Fraction-2.png)<!-- -->

We are also interested in concentrations per compartment. For this, we
need to ensure that we convert the Equilibrium Mass into the Equilibrium
concentration, which we will do below. We need to adjust the
concentrations to end up in respective units. We convert concentrations
in soil and sediment to ng/kg wet weight. Concentrations in water are
converted in ng/L. In air, concentrations are in ng/kg air. The output
is in the form of a table, with both the Equilibrium Mass and the
concentration in the compartment per species.

``` r
# library(knitr)
# library(kableExtra)
# Fetch necessary data
Volume <- World$fetchData("Volume")
Area <- World$fetchData("Area")
FRACw <- World$fetchData("FRACw")
FRACa <- World$fetchData("FRACa")
Fractrial <- FRACa$FRACa[FRACa$SubCompart =="air" & FRACa$Scale =="Arctic" ]
Rho <- World$fetchData("rhoMatrix")
Concentration_eq <- merge(Solution, Volume, by = c("SubCompart", "Scale"))
Concentration_eq$Concentration <- Concentration_eq$EqMass / Concentration_eq$Volume
RhoWater_value <- Rho$rhoMatrix[Rho$SubCompart == "river"]

f_adjust_concentration <- function(Concentration, FRACw, FRACa, SubCompart, Scale, Rho, RhoWater_value) {
  # Fetch Fracw based on SubCompart and Scale
  Fracw <- FRACw$FRACw[FRACw$SubCompart == SubCompart & FRACw$Scale == Scale]
  
  # Fetch Fraca based on SubCompart and Scale
  Fraca <- FRACa$FRACa[FRACa$SubCompart == SubCompart & FRACa$Scale == Scale]
  
  # Fetch RHOsolid based on SubCompart
  RHOsolid <- Rho$rhoMatrix[Rho$SubCompart == SubCompart]
  
  # Check if any of Fracw, Fraca, or RHOsolid are N
  
  Concentration * 1000 / (Fracw * RhoWater_value + (1 - Fracw - Fraca) * RHOsolid)
}

subcomparts <- c("agriculturalsoil", "naturalsoil", "othersoil", "freshwatersediment", "marinesediment")

filtered_data <- Concentration_eq[Concentration_eq$SubCompart %in% subcomparts, ]

# Apply the adjustment function to the filtered data
adjusted_concentrations <- apply(filtered_data, 1, function(row) {
  f_adjust_concentration(
    Concentration = as.numeric(row["Concentration"]),
    FRACw = subset(FRACw, SubCompart == row["SubCompart"] & Scale == row["Scale"]),
    FRACa = subset(FRACa, SubCompart == row["SubCompart"] & Scale == row["Scale"]),
    Rho = subset(Rho, SubCompart == row["SubCompart"]),
    RhoWater_value = 998,  # Replace with your actual RhoWater_value
    SubCompart = row["SubCompart"],
    Scale = row["Scale"]
  )
})
# Update Concentration_eq with adjusted concentrations
Concentration_eq[Concentration_eq$SubCompart %in% subcomparts, "Concentration"] <- adjusted_concentrations

#Define the units
subcompart <- c("agriculturalsoil", "naturalsoil", "othersoil", "freshwatersediment", "marinesediment",  "lakesediment", "air", "deepocean", "lake" , "river", "sea", "cloudwater")
units <- c("g/kg w", "g/kg w", "g/kg w", "g/kg w", "g/kg w", "g/kg w",
           "kg/kg", "kg/L", "kg/L", "kg/L", "kg/L", "kg/L", "kg/L")

# Combine into a named list
subcompart_units <- setNames(units, subcompart)


Concentration_eq <- Concentration_eq |>
  mutate(Units_per_SubCompart = subcompart_units[SubCompart])

convert_units <- function(concentration, unit) {
  if (unit == "g/kg w") {
    return(concentration * 1e9)
  } else if (unit == "kg/kg") {
    return(concentration * 1e12)
  } else if (unit == "kg/L") {
    return(concentration * 1e12)
  } else {
    return(concentration)
  }
}

# Convert concentrations to ng/kg or ng/L and update units
Concentration_eq <- Concentration_eq |>
  mutate(
         Concentration = mapply(convert_units, Concentration, Units_per_SubCompart),
         Units_per_SubCompart = ifelse(Units_per_SubCompart == "g/kg w", "ng/kg w", 
                                       ifelse(Units_per_SubCompart == "kg/kg", "ng/kg", "ng/L")))
Concentration_eq <- Concentration_eq |>
  mutate(across(where(is.numeric), ~ format(., scientific = TRUE)))

#Concentration_eq <- subset(Concentration_eq, select = -old_EqMass)
Concentration_eq<- Concentration_eq |> rename(Unit = Units_per_SubCompart)
# Create the table with kable and style it with kableExtra
# kable(Concentration_eq, format = "markdown", align = "c", caption = "Concentration per Compartment") |>
#   kable_styling(full_width = T)
print(Concentration_eq)
```

    ##             SubCompart       Scale  Abbr Species       EqMass       Volume
    ## 1     agriculturalsoil Continental  s2CS   Solid 1.910904e-08 4.183202e+11
    ## 2     agriculturalsoil Continental  s2CA   Small 2.122787e+04 4.183202e+11
    ## 3     agriculturalsoil Continental  s2CP   Large 7.767049e-01 4.183202e+11
    ## 4     agriculturalsoil    Regional  s2RS   Solid 7.956214e-28 2.747978e+10
    ## 5     agriculturalsoil    Regional  s2RA   Small 2.484933e-04 2.747978e+10
    ## 6     agriculturalsoil    Regional  s2RP   Large 5.689352e-03 2.747978e+10
    ## 7                  air      Arctic   aAS   Solid 3.940017e-39 4.249999e+16
    ## 8                  air      Arctic   aAA   Small 1.412815e-05 4.249999e+16
    ## 9                  air      Arctic   aAP   Large 9.598941e-11 4.249999e+16
    ## 10                 air Continental   aCS   Solid 2.516678e-15 7.199998e+15
    ## 11                 air Continental   aCA   Small 3.075643e-04 7.199998e+15
    ## 12                 air Continental   aCP   Large 3.921763e-07 7.199998e+15
    ## 13                 air    Moderate   aMS   Solid 5.874839e-27 7.756998e+16
    ## 14                 air    Moderate   aMA   Small 1.160883e-04 7.756998e+16
    ## 15                 air    Moderate   aMP   Large 7.115163e-09 7.756998e+16
    ## 16                 air    Regional   aRS   Solid 1.278521e-27 2.299999e+14
    ## 17                 air    Regional   aRA   Small 7.121547e-06 2.299999e+14
    ## 18                 air    Regional   aRP   Large 1.396944e-09 2.299999e+14
    ## 19                 air      Tropic   aTS   Solid 6.359984e-39 1.275000e+17
    ## 20                 air      Tropic   aTA   Small 2.685557e-05 1.275000e+17
    ## 21                 air      Tropic   aTP   Large 3.367774e-11 1.275000e+17
    ## 22          cloudwater      Arctic  cwAS   Solid 1.021508e-29 1.275000e+10
    ## 23          cloudwater      Arctic  cwAA   Small 5.830827e-08 1.275000e+10
    ## 24          cloudwater      Arctic  cwAP   Large 9.598941e-11 1.275000e+10
    ## 25          cloudwater Continental  cwCS   Solid 2.526542e-06 2.160000e+09
    ## 26          cloudwater Continental  cwCA   Small 7.267690e-07 2.160000e+09
    ## 27          cloudwater Continental  cwCP   Large 3.921763e-07 2.160000e+09
    ## 28          cloudwater    Moderate  cwMS   Solid 5.897866e-18 2.327100e+10
    ## 29          cloudwater    Moderate  cwMA   Small 2.743147e-07 2.327100e+10
    ## 30          cloudwater    Moderate  cwMP   Large 7.115163e-09 2.327100e+10
    ## 31          cloudwater    Regional  cwRS   Solid 1.283532e-18 6.900000e+07
    ## 32          cloudwater    Regional  cwRA   Small 1.682809e-08 6.900000e+07
    ## 33          cloudwater    Regional  cwRP   Large 1.396944e-09 6.900000e+07
    ## 34          cloudwater      Tropic  cwTS   Solid 3.596209e-30 3.825000e+10
    ## 35          cloudwater      Tropic  cwTA   Small 4.538497e-08 3.825000e+10
    ## 36          cloudwater      Tropic  cwTP   Large 3.367774e-11 3.825000e+10
    ## 37           deepocean      Arctic  w3AS   Solid 1.532412e-40 7.650000e+16
    ## 38           deepocean      Arctic  w3AA   Small 9.200193e+09 7.650000e+16
    ## 39           deepocean      Arctic  w3AP   Large 2.130885e+08 7.650000e+16
    ## 40           deepocean    Moderate  w3MS   Solid 2.214695e-31 1.163550e+17
    ## 41           deepocean    Moderate  w3MA   Small 1.399381e+10 1.163550e+17
    ## 42           deepocean    Moderate  w3MP   Large 3.241150e+08 1.163550e+17
    ## 43           deepocean      Tropic  w3TS   Solid 3.805490e-43 2.677500e+17
    ## 44           deepocean      Tropic  w3TA   Small 3.457661e+10 2.677500e+17
    ## 45           deepocean      Tropic  w3TP   Large 8.008394e+08 2.677500e+17
    ## 46  freshwatersediment Continental sd1CS   Solid 0.000000e+00 2.875952e+09
    ## 47  freshwatersediment Continental sd1CA   Small 0.000000e+00 2.875952e+09
    ## 48  freshwatersediment Continental sd1CP   Large 0.000000e+00 2.875952e+09
    ## 49  freshwatersediment    Regional sd1RS   Solid 0.000000e+00 1.889235e+08
    ## 50  freshwatersediment    Regional sd1RA   Small 0.000000e+00 1.889235e+08
    ## 51  freshwatersediment    Regional sd1RP   Large 0.000000e+00 1.889235e+08
    ## 52                lake Continental  w0CS   Solid 3.171525e-16 8.715005e+11
    ## 53                lake Continental  w0CA   Small 4.736419e+04 8.715005e+11
    ## 54                lake Continental  w0CP   Large 4.950111e-04 8.715005e+11
    ## 55                lake    Regional  w0RS   Solid 3.311777e-28 5.724953e+10
    ## 56                lake    Regional  w0RA   Small 8.801498e-04 5.724953e+10
    ## 57                lake    Regional  w0RP   Large 3.625258e-06 5.724953e+10
    ## 58        lakesediment Continental sd0CS   Solid 0.000000e+00 2.614501e+08
    ## 59        lakesediment Continental sd0CA   Small 0.000000e+00 2.614501e+08
    ## 60        lakesediment Continental sd0CP   Large 0.000000e+00 2.614501e+08
    ## 61        lakesediment    Regional sd0RS   Solid 0.000000e+00 1.717486e+07
    ## 62        lakesediment    Regional sd0RA   Small 0.000000e+00 1.717486e+07
    ## 63        lakesediment    Regional sd0RP   Large 0.000000e+00 1.717486e+07
    ## 64      marinesediment      Arctic sd2AS   Solid 0.000000e+00 7.650000e+11
    ## 65      marinesediment      Arctic sd2AA   Small 0.000000e+00 7.650000e+11
    ## 66      marinesediment      Arctic sd2AP   Large 0.000000e+00 7.650000e+11
    ## 67      marinesediment Continental sd2CS   Solid 0.000000e+00 1.114199e+11
    ## 68      marinesediment Continental sd2CA   Small 0.000000e+00 1.114199e+11
    ## 69      marinesediment Continental sd2CP   Large 0.000000e+00 1.114199e+11
    ## 70      marinesediment    Moderate sd2MS   Solid 0.000000e+00 1.163550e+12
    ## 71      marinesediment    Moderate sd2MA   Small 0.000000e+00 1.163550e+12
    ## 72      marinesediment    Moderate sd2MP   Large 0.000000e+00 1.163550e+12
    ## 73      marinesediment    Regional sd2RS   Solid 0.000000e+00 3.005619e+07
    ## 74      marinesediment    Regional sd2RA   Small 0.000000e+00 3.005619e+07
    ## 75      marinesediment    Regional sd2RP   Large 0.000000e+00 3.005619e+07
    ## 76      marinesediment      Tropic sd2TS   Solid 0.000000e+00 2.677500e+12
    ## 77      marinesediment      Tropic sd2TA   Small 0.000000e+00 2.677500e+12
    ## 78      marinesediment      Tropic sd2TP   Large 0.000000e+00 2.677500e+12
    ## 79         naturalsoil      Arctic  s1AS   Solid 1.665708e-38 8.500000e+11
    ## 80         naturalsoil      Arctic  s1AA   Small 3.669671e-04 8.500000e+11
    ## 81         naturalsoil      Arctic  s1AP   Large 4.356519e-05 8.500000e+11
    ## 82         naturalsoil Continental  s1CS   Solid 3.478976e-15 4.706103e+10
    ## 83         naturalsoil Continental  s1CA   Small 1.142934e-03 4.706103e+10
    ## 84         naturalsoil Continental  s1CP   Large 1.590572e-01 4.706103e+10
    ## 85         naturalsoil    Moderate  s1MS   Solid 3.106211e-26 1.939250e+12
    ## 86         naturalsoil    Moderate  s1MA   Small 1.401571e-03 1.939250e+12
    ## 87         naturalsoil    Moderate  s1MP   Large 1.103743e-02 1.939250e+12
    ## 88         naturalsoil    Regional  s1RS   Solid 3.634466e-27 3.091475e+09
    ## 89         naturalsoil    Regional  s1RA   Small 4.622731e-05 3.091475e+09
    ## 90         naturalsoil    Regional  s1RP   Large 1.165091e-03 3.091475e+09
    ## 91         naturalsoil      Tropic  s1TS   Solid 2.018395e-38 1.912500e+12
    ## 92         naturalsoil      Tropic  s1TA   Small 1.077133e-04 1.912500e+12
    ## 93         naturalsoil      Tropic  s1TP   Large 5.785505e-05 1.912500e+12
    ## 94           othersoil Continental  s3CS   Solid 1.269305e-16 1.743001e+10
    ## 95           othersoil Continental  s3CA   Small 4.273234e-04 1.743001e+10
    ## 96           othersoil Continental  s3CP   Large 5.891006e-02 1.743001e+10
    ## 97           othersoil    Regional  s3RS   Solid 1.326036e-28 1.144991e+09
    ## 98           othersoil    Regional  s3RA   Small 1.731238e-05 1.144991e+09
    ## 99           othersoil    Regional  s3RP   Large 4.315153e-04 1.144991e+09
    ## 100              river Continental  w1CS   Solid 6.569706e-05 2.875952e+11
    ## 101              river Continental  w1CA   Small 8.228243e+04 2.875952e+11
    ## 102              river Continental  w1CP   Large 1.905769e+03 2.875952e+11
    ## 103              river    Regional  w1RS   Solid 3.593952e-26 1.889235e+10
    ## 104              river    Regional  w1RA   Small 3.485522e-04 1.889235e+10
    ## 105              river    Regional  w1RP   Large 1.435655e-06 1.889235e+10
    ## 106                sea      Arctic  w2AS   Solid 3.782331e-31 2.550000e+15
    ## 107                sea      Arctic  w2AA   Small 3.736732e+08 2.550000e+15
    ## 108                sea      Arctic  w2AP   Large 8.654759e+06 2.550000e+15
    ## 109                sea Continental  w2CS   Solid 1.426461e-12 7.427996e+14
    ## 110                sea Continental  w2CA   Small 8.952510e+07 7.427996e+14
    ## 111                sea Continental  w2CP   Large 2.073518e+06 7.427996e+14
    ## 112                sea    Moderate  w2MS   Solid 6.402737e-22 3.878500e+15
    ## 113                sea    Moderate  w2MA   Small 4.664685e+08 3.878500e+15
    ## 114                sea    Moderate  w2MP   Large 1.080402e+07 3.878500e+15
    ## 115                sea    Regional  w2RS   Solid 3.401739e-25 1.001873e+10
    ## 116                sea    Regional  w2RA   Small 1.086747e+03 1.001873e+10
    ## 117                sea    Regional  w2RP   Large 2.517047e+01 1.001873e+10
    ## 118                sea      Tropic  w2TS   Solid 4.662958e-36 8.925000e+15
    ## 119                sea      Tropic  w2TA   Small 1.073182e+09 8.925000e+15
    ## 120                sea      Tropic  w2TP   Large 2.485630e+07 8.925000e+15
    ##     Concentration    Unit
    ## 1    2.687715e-11 ng/kg w
    ## 2    2.687715e-11 ng/kg w
    ## 3    2.687715e-11 ng/kg w
    ## 4    2.687715e-11 ng/kg w
    ## 5    2.687715e-11 ng/kg w
    ## 6    2.687715e-11 ng/kg w
    ## 7    9.270630e-44   ng/kg
    ## 8    3.324272e-10   ng/kg
    ## 9    2.258575e-15   ng/kg
    ## 10   3.495387e-19   ng/kg
    ## 11   4.271727e-08   ng/kg
    ## 12   5.446895e-11   ng/kg
    ## 13   7.573599e-32   ng/kg
    ## 14   1.496563e-09   ng/kg
    ## 15   9.172573e-14   ng/kg
    ## 16   5.558787e-30   ng/kg
    ## 17   3.096326e-08   ng/kg
    ## 18   6.073673e-12   ng/kg
    ## 19   4.988224e-44   ng/kg
    ## 20   2.106320e-10   ng/kg
    ## 21   2.641392e-16   ng/kg
    ## 22   8.011825e-28    ng/L
    ## 23   4.573198e-06    ng/L
    ## 24   7.528581e-09    ng/L
    ## 25   1.169695e-03    ng/L
    ## 26   3.364671e-04    ng/L
    ## 27   1.815631e-04    ng/L
    ## 28   2.534427e-16    ng/L
    ## 29   1.178783e-05    ng/L
    ## 30   3.057523e-07    ng/L
    ## 31   1.860191e-14    ng/L
    ## 32   2.438854e-04    ng/L
    ## 33   2.024557e-05    ng/L
    ## 34   9.401852e-29    ng/L
    ## 35   1.186535e-06    ng/L
    ## 36   8.804639e-10    ng/L
    ## 37   2.003153e-45    ng/L
    ## 38   1.202640e+05    ng/L
    ## 39   2.785471e+03    ng/L
    ## 40   1.903395e-36    ng/L
    ## 41   1.202682e+05    ng/L
    ## 42   2.785570e+03    ng/L
    ## 43   1.421285e-48    ng/L
    ## 44   1.291377e+05    ng/L
    ## 45   2.990997e+03    ng/L
    ## 46   2.687715e-11 ng/kg w
    ## 47   2.687715e-11 ng/kg w
    ## 48   2.687715e-11 ng/kg w
    ## 49   2.687715e-11 ng/kg w
    ## 50   2.687715e-11 ng/kg w
    ## 51   2.687715e-11 ng/kg w
    ## 52   3.639155e-16    ng/L
    ## 53   5.434787e+04    ng/L
    ## 54   5.679986e-04    ng/L
    ## 55   5.784811e-27    ng/L
    ## 56   1.537392e-02    ng/L
    ## 57   6.332380e-05    ng/L
    ## 58   0.000000e+00 ng/kg w
    ## 59   0.000000e+00 ng/kg w
    ## 60   0.000000e+00 ng/kg w
    ## 61   0.000000e+00 ng/kg w
    ## 62   0.000000e+00 ng/kg w
    ## 63   0.000000e+00 ng/kg w
    ## 64   2.687715e-11 ng/kg w
    ## 65   2.687715e-11 ng/kg w
    ## 66   2.687715e-11 ng/kg w
    ## 67   2.687715e-11 ng/kg w
    ## 68   2.687715e-11 ng/kg w
    ## 69   2.687715e-11 ng/kg w
    ## 70   2.687715e-11 ng/kg w
    ## 71   2.687715e-11 ng/kg w
    ## 72   2.687715e-11 ng/kg w
    ## 73   2.687715e-11 ng/kg w
    ## 74   2.687715e-11 ng/kg w
    ## 75   2.687715e-11 ng/kg w
    ## 76   2.687715e-11 ng/kg w
    ## 77   2.687715e-11 ng/kg w
    ## 78   2.687715e-11 ng/kg w
    ## 79   2.687715e-11 ng/kg w
    ## 80   2.687715e-11 ng/kg w
    ## 81   2.687715e-11 ng/kg w
    ## 82   2.687715e-11 ng/kg w
    ## 83   2.687715e-11 ng/kg w
    ## 84   2.687715e-11 ng/kg w
    ## 85   2.687715e-11 ng/kg w
    ## 86   2.687715e-11 ng/kg w
    ## 87   2.687715e-11 ng/kg w
    ## 88   2.687715e-11 ng/kg w
    ## 89   2.687715e-11 ng/kg w
    ## 90   2.687715e-11 ng/kg w
    ## 91   2.687715e-11 ng/kg w
    ## 92   2.687715e-11 ng/kg w
    ## 93   2.687715e-11 ng/kg w
    ## 94   2.687715e-11 ng/kg w
    ## 95   2.687715e-11 ng/kg w
    ## 96   2.687715e-11 ng/kg w
    ## 97   2.687715e-11 ng/kg w
    ## 98   2.687715e-11 ng/kg w
    ## 99   2.687715e-11 ng/kg w
    ## 100  2.284359e-04    ng/L
    ## 101  2.861051e+05    ng/L
    ## 102  6.626567e+03    ng/L
    ## 103  1.902332e-24    ng/L
    ## 104  1.844939e-02    ng/L
    ## 105  7.599136e-05    ng/L
    ## 106  1.483267e-34    ng/L
    ## 107  1.465385e+05    ng/L
    ## 108  3.394023e+03    ng/L
    ## 109  1.920384e-15    ng/L
    ## 110  1.205239e+05    ng/L
    ## 111  2.791491e+03    ng/L
    ## 112  1.650828e-25    ng/L
    ## 113  1.202703e+05    ng/L
    ## 114  2.785619e+03    ng/L
    ## 115  3.395379e-23    ng/L
    ## 116  1.084715e+05    ng/L
    ## 117  2.512342e+03    ng/L
    ## 118  5.224603e-40    ng/L
    ## 119  1.202445e+05    ng/L
    ## 120  2.785019e+03    ng/L

## SBdynamic \[WORK IN PROGRESS - needs some fixes\]

*This part is still Work In Progress and in need of additional
development.*

### Adjusting Parameters to Match considered Scale

In this case study we are considering emission data only for Europe. By
default the ‘World’ is represented by a nested regional scale, which is
not relevant for the current assessment using emissions data only for
Europe. Here we use the option to allocate part of the emissions to the
regional scale based on the fraction of surface area in order to mimic
not having a nested scale. In future one would be interested for
instance in including a local or national scale as well. One could
adjust the regional scale for this purpose.

The code is commented out, but this is an example of adjusting the
regional scale to represent Switzerland. You can only adjust parameters
that are initial input data, not variables that are calculated later in
SBOO. The adjusted dataframes are printed below. Note, at this point the
input is already converted to SI units, so new data also needs to be put
in this format.

We can also solve the differential equations dynamically in time, but
the optimal implementation is still work in progress, see
[issue](https://github.com/rivm-syso/SBoo/issues/111).

### Prepare DPMFA data

Data from an DPMFA model should be prepared to fit the SBoo world. For
instance the time unit should be correct, the mass unit is not as
important as this will be the same in the output then, but for good
measure we use kg. This is the quick and dirty way, a more elegant way
is till in progress as mentioned above.

We define the compartments of the emission based on the DMPFA model.

### Scaling Emission data based on material density

When running for only GO or only Chitosan, you want to correct for the
fact that it’s partly Chitosan and partly GO through using the
densities.

### Scaling Input Data based on World (Regional nested in Continental)

In this chunk, we adjust for the fact that the input data for the DMPFA
model is all Europe based. Hence we scale by the factor fracReg and
fracCont to still include the current regional scale (could alse be done
differently). The regional data is thus a portion of the EU emission,
scaled based on the land surface area.

### make time dependant emission functions

### Dynamic solving for deterministic input data

The chunk below gives the opportunity to Solve for constant input data.
The chunk after that gives the opportunity to also vary SB Input data

### Output Processing

To move from the solution of the ODE solver to usable output data we
need to split the output into corresponding mass data per compartment
over time and emission signals over time. The first chunk is for one
output, the latter chunk for varying input or emission data.

### Plotting of Output

Below you can create a plot for one output for mass, the chunk after
that represents uncertainty based on multiple outputs.

From mass to concentration In this chunk we will convert the mass output
into concentration output by calculating the respective volumes and
calculating by this value.

Plotting Of Concentrations Here we append all concentrations per
compartment for species A, S and P. Subsequently, we plot these results
