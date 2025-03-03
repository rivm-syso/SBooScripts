Solver use
================
Anne Hids, Jaap Slootweg, Joris Quik
2025-03-03

## Initialize World

First, we will load the necessary packages and initialize the world for
molecules.

``` r
library(lhs)
library(tidyverse)
library(treemapify)
library(gridExtra)

source("baseScripts/initWorld_onlyMolec.R")
```

If you would like to instead initialize the World for particulates or
microplastics, use:

- source(“baseScripts/initWorld_onlyParticulate.R”)

- source(“baseScripts/initWorld_onlyMicroplastics.R”)

## Steady state solver

A steady state solver calculates the masses in each environmental
compartment (i.e. air, riverwater, naturalsoil) at each scale (i.e.
Regional, Continental) and for each species (U, S, A, P) when the system
has reached an equilibrium.

There are two ways to use the steady state solver: deterministic (solve
once with one set of emissions and one set of substance variables), or
probabilistic (solve multiple times, once for each run with uncertain
substance variables and optionally uncertain emissions).

### Use the steady state solver deterministically

We already initialized the World in the previous chunk. This is not done
for a specific substances, the World was initialized for a ‘default
substance’, which behaves as a molecule.

As we will not vary any substance variables when using the deterministic
steady state solver, we only need to make a dataframe containing the
emissions for 1 or more emission compartments. This dataframe should
contain two columns:

- ‘Abbr’, which contains the abbreviations for the compartments

- ‘Emis’, which contains the emissions to the compartments, in kg/s.

To see the abbreviations and their meaning, you can run
\`World\$states\$asDataFrame\`.

``` r
# Create the steady state emission dataframe
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) 

# convert 1 t/y to si units: kg/s
emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 
```

Now we will initialize the solver, with is “SteadyODE” for all steady
state calculations. Consequently, we will use the `World$Solve()`
function to calculate the masses in each compartment.

``` r
# Define the solver function to use. For steady state calculations, this is always "SteadyODE"
World$NewSolver("SteadyStateSolver")

# Solve with the emissions we defined in the previous chunk
World$Solve(emissions = emissions)
```

Finally we can retrieve the masses, emissions and concentrations from
the World object by using the functions in the chunk below.

``` r
# Get the solution(=mass per compartment), emissions and concentrations from 'World'
solution <- World$Masses()
emission <- World$Emissions()
concentration <- World$Concentration()

knitr::kable(concentration)
```

| Abbr  | time | RUNs | Concentration | Unit    |
|:------|:-----|:-----|--------------:|:--------|
| aAU   | 0    | 1    |     0.0000000 | g/m3    |
| aCU   | 0    | 1    |     0.0000001 | g/m3    |
| aMU   | 0    | 1    |     0.0000000 | g/m3    |
| aRU   | 0    | 1    |     0.0000004 | g/m3    |
| aTU   | 0    | 1    |     0.0000000 | g/m3    |
| s1AU  | 0    | 1    |     0.0000102 | g/kg dw |
| s1CU  | 0    | 1    |     0.0000220 | g/kg dw |
| s1MU  | 0    | 1    |     0.0000038 | g/kg dw |
| s1RU  | 0    | 1    |     0.0001227 | g/kg dw |
| s1TU  | 0    | 1    |     0.0000012 | g/kg dw |
| s2CU  | 0    | 1    |     0.0000091 | g/kg dw |
| s2RU  | 0    | 1    |     0.1998416 | g/kg dw |
| s3CU  | 0    | 1    |     0.0000220 | g/kg dw |
| s3RU  | 0    | 1    |     0.0001227 | g/kg dw |
| sd0CU | 0    | 1    |     0.0000322 | g/kg dw |
| sd0RU | 0    | 1    |     0.0096379 | g/kg dw |
| sd1CU | 0    | 1    |     0.0001072 | g/kg dw |
| sd1RU | 0    | 1    |     1.2311868 | g/kg dw |
| sd2AU | 0    | 1    |     0.0000030 | g/kg dw |
| sd2CU | 0    | 1    |     0.0000277 | g/kg dw |
| sd2MU | 0    | 1    |     0.0000003 | g/kg dw |
| sd2RU | 0    | 1    |     0.0744787 | g/kg dw |
| sd2TU | 0    | 1    |     0.0000000 | g/kg dw |
| w0CU  | 0    | 1    |     0.0000000 | g/L     |
| w0RU  | 0    | 1    |     0.0000001 | g/L     |
| w1CU  | 0    | 1    |     0.0000000 | g/L     |
| w1RU  | 0    | 1    |     0.0000092 | g/L     |
| w2AU  | 0    | 1    |     0.0000000 | g/L     |
| w2CU  | 0    | 1    |     0.0000000 | g/L     |
| w2MU  | 0    | 1    |     0.0000000 | g/L     |
| w2RU  | 0    | 1    |     0.0000006 | g/L     |
| w2TU  | 0    | 1    |     0.0000000 | g/L     |
| w3AU  | 0    | 1    |     0.0000000 | g/L     |
| w3MU  | 0    | 1    |     0.0000000 | g/L     |
| w3TU  | 0    | 1    |     0.0000000 | g/L     |

Finally, we can plot the outcome using the predefined plot functions. If
there is no scale specified, the Regional scale will be selected.
Selecting one or more subcomparts is optional. If no subcomparts are
given, the outcome is plotted for all subcomparts.

``` r
# Plot concentrations at regional scale
World$PlotConcentration(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20deterministic%20outcome-1.png)<!-- -->

``` r
World$PlotConcentration(scale = "Continental", subcompart = c("agriculturalsoil", "naturalsoil", "othersoil"))
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20deterministic%20outcome-2.png)<!-- -->

``` r
# Plot solution at continental scale 
World$PlotMasses(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20deterministic%20outcome-3.png)<!-- -->

``` r
# Plot the mass distribution
World$PlotMassDistribution(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20deterministic%20outcome-4.png)<!-- -->

    ## TableGrob (2 x 1) "arrange": 2 grobs
    ##   z     cells    name           grob
    ## 1 1 (1-1,1-1) arrange gtable[layout]
    ## 2 2 (2-2,1-1) arrange gtable[layout]

### Use the steady state solver probabilistically

Here the steady state probabilistic solver is demonstrated for a
microplastic.

When the World is initialized for particulates or plastics, the
emissions go to the “S”, “A” and/or “P” species (this is unlike
emissions for molecules, where the emissions go to the “U” species).

| Abbreviation | Full species name |
|-------------:|-------------------|
|            U | Unbound           |
|            S | Solid             |
|            A | Aggregated        |
|            P | Attached          |

Table showing species abbreviations and the corresponding species names.

``` r
source('baseScripts/initWorld_onlyPlastics.R')
```

For the probabilistic steady state solver, the emissions need to be
given as a dataframe with three columns:

- ‘Abbr’, which contains the abbreviations for the compartments

- ‘Emis’, which contains the emissions to the compartments, in kg/s

- ‘RUN’, which contains the run number of the emission.

This example uses 20 output runs of a DPFMA (Dynamic Probabilistic
Material Flow Analysis) model. This data is loaded first, and then
transformed to the required format.

(Alternatively, if you want one set of emissions but vary the values for
variables, you can use one emission dataframe as in the example for the
deterministic steady state solver. Then the solver will use the same set
of emissions for each run, but vary variable values.)

``` r
load("data/Examples/example_uncertain_data.RData")

# Example of an emission dataframe formatted for for use in SimpleBox
example_data <- example_data |>
  # Select the emission compartment, year of analysis and RUN for one microplastic and scale.
  select(To_Compartment, `2023`, RUN) |>
  # Change the name of column with emission values to "Emis"
  rename("Emis" = `2023`) |>
  # Add the abreviations with the key for compartment, scale and species
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  # Convert kt/year to kg/s
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> 
  select(-To_Compartment) # leave out original compartment name
```

Variable values can be varied over runs by specifying the variable name,
the type of distribution and distribution parameters (optionally also
the Species, Scale and SubCompart). To see the variable names and which
other variables are needed for the value, see i.e.
`World$fetchData("kdeg")`.

In the chunk below, an Excel file is read in containing the needed
values for 2 variables. Consequently, a distribution is created for each
row in the dataframe.

``` r
# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

varFuns <- World$makeInvFuns(Example_vars)
```

World\$Solve needs the following variables to solve steady state
probabilistically:

- emissions: the emissions dataframe

- var_box_df: a dataframe with the example variables

- var_invFun: the functions created from the var_box_df in a list

- nRUNs: the number of runs (should match the number of RUNs in the
  emissions dataframe provided).

Now we can solve and get the solution, variable values, concentration
and emissions.

``` r
# Call the steady state solver
World$NewSolver("SteadyStateSolver")

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)))

# Get the outcomes from World
solution = World$Masses()
variable_values = World$VariableValues()
concentration = World$Concentration()
emission = World$Emissions()
```

Finally, we can plot the outcome using the predefined plot functions.

``` r
# Plot concentrations at regional scale
World$PlotConcentration(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20probabilistic%20outcome-1.png)<!-- -->

``` r
# Plot solution at continental scale 
World$PlotMasses(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20probabilistic%20outcome-2.png)<!-- -->

``` r
# Plot the mass distribution
World$PlotMassDistribution(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20SS%20probabilistic%20outcome-3.png)<!-- -->

    ## TableGrob (2 x 1) "arrange": 2 grobs
    ##   z     cells    name           grob
    ## 1 1 (1-1,1-1) arrange gtable[layout]
    ## 2 2 (2-2,1-1) arrange gtable[layout]

## Dynamic solver

SimpleBox can also solve the K matrix with semi-dynamically using time
variable emissions. To do this, one needs to use the DynamicSolver. This
is demonstrated below or microplastics:

``` r
source('baseScripts/initWorld_onlyPlastics.R')
```

As in steady state, one can do dynamic analysis deterministically or
probabilistically.

### Use the dynamic solver deterministically

For the dynamic deterministic solver, the emissions need to be given as
a dataframe with three columns:

- ‘Abbr’, which contains the abbreviations for the compartments

- ‘Emis’, which contains the emissions to the compartments, in kg/s

- ‘Time’, which contains the time of the emission in seconds.

``` r
# Initialize emissions in t/y
emissions <- 
  # create emission scenario in time:
  data.frame(Emis = c(10,20, 1,0,0), # emission in tones per year
             Time = c(1,5,10,15,20))  # years from start
# apply emission scenario to intended species and compartments using hte Abbr:
emissions <- merge(emissions, data.frame(Abbr = c("aRS", "s2RS", "w1RS")))

# convert 1 t/y to si units: kg/s
emissions <- emissions |>
  mutate(Emis = Emis*1000,
    Time = Time*(365.25*24*60*60)) |> ungroup()
```

World\$Solve needs the following variables to solve dynamically
deterministically:

- emissions: the emissions dataframe

- tmax: the end time for running the solver, in seconds

- nTIMES: the number of calculation time steps.

Now we can solve and get the solution, concentration and emissions.

``` r
tmax <- max(emissions$Time) # set max solve time to last step in emission scenario
nTIMES <- 1+max(emissions$Time)/(365.25*24*60*60) # Sets the time step for output, e.g. for 20 year scenario, add t0 is 21 nTimes

# Initialize the dynamic solver
World$NewSolver("DynamicSolver")
World$Solve(emissions = emissions, tmax = tmax, nTIMES = nTIMES)
solution <- World$Masses()
emission <- World$Emissions()
```

Finally, we can plot the outcome using the predefined plot functions. If
there is no scale specified, the Regional scale will be selected.
Selecting one or more subcomparts is optional. If no subcomparts are
given, the outcome is plotted for all subcomparts.

``` r
# You can specify a scale and a subcompartment
World$PlotMasses(scale = "Regional", subcompart = "agriculturalsoil")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20outcome%20of%20the%20dynamic%20deterministic%20solver-1.png)<!-- -->

``` r
World$substance
```

    ## [1] "microplastic"

``` r
# Or just a scale and all subcompartments are plotted:
World$PlotMasses(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20outcome%20of%20the%20dynamic%20deterministic%20solver-2.png)<!-- -->

``` r
# Plot all concentrations at regional scale
World$PlotConcentration(scale = "Regional")
```

![](x.-Solver-use_files/figure-gfm/Plot%20the%20outcome%20of%20the%20dynamic%20deterministic%20solver-3.png)<!-- -->

## Use the dynamic solver probabilistically

For the dynamic deterministic solver, the emissions need to be given as
a dataframe with three columns:

- ‘Abbr’, which contains the abbreviations for the compartments

- ‘Emis’, which contains the emissions to the compartments, in kg/s

- ‘Time’, which contains the time of the emission in seconds,

- ‘RUN’, which contains the run number of the emission.

``` r
source('baseScripts/initWorld_onlyPlastics.R')

load("data/Examples/example_uncertain_data.RData")

example_data <- example_data |>
  select(To_Compartment, `2020`, `2021`,`2022`, `2023`, RUN) |>
  pivot_longer(!c(To_Compartment, RUN), names_to = "year", values_to = "Emis") |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  select(-To_Compartment) |>
  mutate(Time = ((as.numeric(year)-2019)*365.25*24*3600)) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-year)
```

Prepare the variables the same way as used for the variables in the
steady state probabilistic solver.

``` r
# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

varFuns <- World$makeInvFuns(Example_vars)
```

`World$Solve` needs the following variables to solve steady state
probabilistically:

- emissions: the emissions dataframe

- var_box_df: a dataframe with the example variables

- var_invFun: the functions created from the var_box_df in a list

- nRUNs: the number of runs (should match the number of RUNs in the
  emissions dataframe provided)

- tmax: the end time for running the solver, in seconds

- nTIMES: the number of calculation time steps.

Now we can solve and get the solution, variable values, concentration
and emissions. NOTE: These calculations take a bit longer than the
previous calculations.

``` r
World$NewSolver("DynamicSolver")

tmax <- 365.25*24*60*60*length(unique(example_data$Time))
nTIMES <- length(seq(0, tmax, length.out = 10))

World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)), tmax = tmax, nTIMES = nTIMES)

solution = World$Masses()
emission = World$Emissions()
variable_values = World$VariableValues()
concentrations = World$Concentration()
```

Finally, we can plot the outcome using the predefined plot functions. If
there is no scale specified, the Regional scale will be selected. If
there is no subcompart specified, “ägriculturalsoil” will be selected.

``` r
World$PlotConcentration(scale = "Regional", subcompart = "agriculturalsoil")
```

![](x.-Solver-use_files/figure-gfm/Plot%20outcome%20with%20uncertainty-1.png)<!-- -->

``` r
World$PlotMasses(scale = "Regional", subcompart = "agriculturalsoil")
```

![](x.-Solver-use_files/figure-gfm/Plot%20outcome%20with%20uncertainty-2.png)<!-- -->

## Steady state probabilistically with emissions as a set of functions

World\$Solve needs the following variables to solve steady state
probabilistically with a set of emission functions:

- emissions: a set of emission functions

- var_box_df: a dataframe with the example variables

- var_invFun: the functions created from the var_box_df in a list

- nRUNs: the number of runs (should match the number of RUNs in the
  emissions dataframe provided).

Now we can solve and get the solution, variable values, concentration
and emissions.

### Prepare variable samples

For each variable that is uncertain you can define the distribution type
(triangular, uniform or normal) and the corresponding parameters. For
this example, an example excel file will be read in containing the
necessary parameters for the variables we want to vary.

``` r
source("baseScripts/initWorld_onlyPlastics.R")

# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables.xlsx", sheet = "Variable_data")

# Define functions for each row based on the distribution type
varFuns <- World$makeInvFuns(Example_vars)
```

### Prepare emission data

In this example, we will take a steady state emission data frame as the
starting point for creating the triangular distributions.

``` r
# Create the steady state emission dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10000, 10000, 10000))

# convert 1 t/y to si units: kg/s
emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60))
```

We can take the emission dataframe in the chunk above and define a
(min), b (max) and c (peak) and the distribution type for each
compartment. Consequently, the `World$makeInvFuns()` function is used to
create the emission functions.

``` r
emissions$a <- emissions$Emis * 0.7
emissions$b <- emissions$Emis * 1.3
emissions$c <- emissions$Emis
emissions$Distribution <- "triangular"

emisFuns <- World$makeInvFuns(emissions)
names(emisFuns) <- emissions$Abbr
```

Now we can solve and get the solution, variable values, concentration
and emissions. We can also plot the outcome using the built-in plot
functions.

``` r
# The number of samples you want to pull from the distributions for each variable
n_samples <- 20

World$NewSolver("SteadyStateSolver")

World$Solve(emissions = emisFuns, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = n_samples)

sol <- World$Masses()
conc <- World$Concentration()
World$PlotConcentration()
```

    ## [1] "No scale was given to function, Regional scale is selected"

![](x.-Solver-use_files/figure-gfm/Test%20steady%20state%20uncertain%20solver-1.png)<!-- -->
