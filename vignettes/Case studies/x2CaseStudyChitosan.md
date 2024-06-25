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
    ## 1    agriculturalsoil   Large 0.14520251
    ## 2    agriculturalsoil   Small 0.14520251
    ## 12          deepocean   Large 0.14520251
    ## 13          deepocean   Small 0.14520251
    ## 16 freshwatersediment   Large 0.01453975
    ## 17 freshwatersediment   Small 0.01453975
    ## 20               lake   Large 0.14520251
    ## 21               lake   Small 0.14520251
    ## 24       lakesediment   Large 0.40000000
    ## 25       lakesediment   Small 0.10000000
    ## 28     marinesediment   Large 0.14520251
    ## 29     marinesediment   Small 0.14520251
    ## 32        naturalsoil   Large 0.01453975
    ## 33        naturalsoil   Small 0.01453975
    ## 36          othersoil   Large 0.14520251
    ## 37          othersoil   Small 0.14520251
    ## 40              river   Large 0.01453975
    ## 41              river   Small 0.01453975
    ## 44                sea   Large 0.01453975
    ## 45                sea   Small 0.01453975

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
```

## SBdynamic \[WORK IN PROGRESS - needs some fixes\]

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
