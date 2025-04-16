Getting started
================
Anne Hids
2025-03-04

This vignette demonstrates how to use SimpleBox Object-Oriented (SBoo).

## Initialize

Before starting, make sure your working directory is set to the
SBooScripts folder.

### Install required packages

``` r
source("baseScripts/installRequirements.R")
```

### Choose a substance

The first step is to initialize the model. Before initialization a
substance needs to be selected. A substance can be chosen from the
“Substance” column of the data frame created below. Note the substance
names are case-sensitive. Please use the exact name of the chemical as
mentioned in the column “Substance” in Substances.csv.

``` r
substances <- read.csv("data/Substances.csv")

# Assign a substance name from the Substance column to the variable "substance":
chosen_substance <- "1-aminoanthraquinone"
```

### Initialize the World object

The World object contains all variables and first order rate constants
(k’s) for the chosen substance. This object is needed later to calculate
the masses in each compartment on each scale.

To initialize the World object, one of three script is called:

- initWorld_onlyMolec.R (used for molecules)
- initWorld_onlyParticulate.R (used for particulates)
- initWorld_onlyPlastics.R (used for microplastics)

Choosing which script to use is dependent on the substance class of the
chosen substance (see “ChemClass” column in the “substances” data
frame). Each of these three classes require different initWorld scripts
because different processes and variables are used to calculate the k’s.
With the chunk below, the correct initWorld script is automatically
chosen and run based on the chosen substance:

``` r
chemclass <- substances |>
  filter(Substance == chosen_substance) |>
  select(ChemClass)

chemclass <- chemclass$ChemClass

if(chosen_substance == "microplastic"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if (chemclass == "particle") {
  source("baseScripts/initWorld_onlyParticulate.R")
} else {
  source("baseScripts/initWorld_onlyMolec.R")
}

World$substance <- chosen_substance
```

## Access variables

Now that the World is initialized, its variables and calculated flows
can be accessed. To access these variables and k’s, first the names of
the variables are needed. They can be accessed by using the code below.
The first 10 variable names are printed, but there are 195 variables in
total.

If you want to know more about the abbreviations of variables, their
units and descriptions please see Units.csv in the data folder.

``` r
varnames <- World$fetchData()

print(varnames[1:10])
```

    ##  [1] "a"              "a"              "AbbrC"          "AbbrP"         
    ##  [5] "AEROresist"     "AEROSOLdeprate" "AirFlow"        "alpha.surf"    
    ##  [9] "Area"           "AreaLand"

A specific variable (in this case AreaSea) can be accessed as follows:

``` r
knitr::kable(World$fetchData("AreaSea"))
```

| Scale       |      AreaSea |
|:------------|-------------:|
| Arctic      | 2.550000e+13 |
| Continental | 3.713410e+12 |
| Moderate    | 3.878559e+13 |
| Regional    | 1.000000e+09 |
| Tropic      | 8.925000e+13 |

## Access k’s

The “kaas” variable contains a data frame with the first order rate
constants (k’s), proccess name, to-subcompartment name
from-subcompartment name, to-scale name, from-scale name, to-species
name and from-species name. It can be accessed in the same way other
variables are accessed:

``` r
df_ks <- World$kaas
```

## Change a landscape variable

To change a landscape variables value(s), first get the current variable
with World\$fetchData. This is to see the dimensions of the variables
dataframe.

Variable values are changed using World\$MutateVars(). This function
expects the new variable values in a specific format:

- values should be in a column named ‘Waarde’
- the name of the variable should be in a column named ‘varName’
- the other columns can be ‘Scale’, ‘SubCompart’, ‘Species’ etc. You can
  see which columns need to be included by using fetchData() on the
  variable before using mutateVars()

``` r
# Get the current dataframe of the variable
knitr::kable(World$fetchData("TotalArea"))
```

| Scale       |   TotalArea |
|:------------|------------:|
| Arctic      | 4.25000e+13 |
| Continental | 7.42882e+12 |
| Moderate    | 8.50000e+13 |
| Regional    | 2.29570e+11 |
| Tropic      | 1.27500e+14 |

``` r
# Make a dataframe in the same format (also same column names)
TotalArea <- data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"),
  Waarde = c(4.25E+13, 7.43E+12, 8.50E+13, 4.13e+11, 1.27e+14),
  varName = "TotalArea")

# Replace TotalArea variable with new values
World$mutateVars(TotalArea)

# Check if it worked 
kable(World$fetchData("TotalArea"))
```

| Scale       | TotalArea |
|:------------|----------:|
| Arctic      |  4.25e+13 |
| Continental |  7.43e+12 |
| Moderate    |  8.50e+13 |
| Regional    |  4.13e+11 |
| Tropic      |  1.27e+14 |

``` r
# Recalulate all variables dependent on TotalArea
World$UpdateDirty("TotalArea")
```

## Change a substance variable

When using World\$fetchData(), sometimes a value is returned instead of
a dataframe. In that case we can still use the mutateVars() function,
but give the function a named value instead of a dataframe.

The default molecular weight for this substance is 0.223. After the
chuck below, the value should be 0.15.

``` r
# Make a dataframe where varName = MW and Waarde is 150 
MW_df <- data.frame(varName = "MW",
                        Waarde = 150) # In g/mol, will be converted to SI unit (kg/mol) in the core. 

# Use mutateVars() to update the variable
World$mutateVars(MW_df)

# Recalculate all variables dependent on MW
World$UpdateDirty("MW")
```

After changing the molecular weight, the value is 0.15.

**Note that the MW variable is only used for calculations if the
substance is a molecule. If you change the substance to a
particle/microplastic, the chunk above will still work but MW is not
used for calculations.**

## Calculate steady state output

To calculate steady state masses, emissions and a solver are needed.
They have to be given to the solver in a particular format. More details
on solvers can be found [here](vignettes/x.-Solver-use.md).

### Create emissions data frame

To be able to calculate steady state masses, an emission data frame is
needed. The emissions data frame consists of one column with the
abbreviation of the scale-subcompartment-species combination, and
another column containing the emission to that compartment.

Scales are spatial scales, such as “Regional” or “Continental”.
SubComparts are environmental subcompartments within the scales, such as
“river” or “agriculturalsoil”. Species are the form in which the
substance occurs. For molecules, the species is always “Unbound”. For
particulates, the species can be “Solid” (only the particle),
“Aggregated” or “Attached”.

The abbreviations are as follows:

``` r
scales <- data.frame(Scale = c("Arctic", "Continental", "Moderate", "Regional", "Tropic"), Abbreviation = c("A", "C", "M", "R", "T"))

subcompartments <- read.csv("data/SubCompartSheet.csv") |>
  select(SubCompartName, AbbrC) |>
  rename(Abbreviation = AbbrC) |>
  rename(SubCompartment = SubCompartName)

species <- read.csv("data/SpeciesSheet.csv") |>
  select(Species, AbbrP) |>
  rename(Abbreviation = AbbrP)

knitr::kable(scales)
```

| Scale       | Abbreviation |
|:------------|:-------------|
| Arctic      | A            |
| Continental | C            |
| Moderate    | M            |
| Regional    | R            |
| Tropic      | T            |

``` r
knitr::kable(subcompartments)
```

| SubCompartment     | Abbreviation |
|:-------------------|:-------------|
| air                | a            |
| cloudwater         | cw           |
| freshwatersediment | sd1          |
| lakesediment       | sd0          |
| marinesediment     | sd2          |
| agriculturalsoil   | s2           |
| naturalsoil        | s1           |
| othersoil          | s3           |
| deepocean          | w3           |
| lake               | w0           |
| river              | w1           |
| sea                | w2           |

``` r
knitr::kable(species)
```

| Species   | Abbreviation |
|:----------|:-------------|
| Dissolved | D            |
| Gas       | G            |
| Large     | P            |
| Small     | A            |
| Solid     | S            |
| Unbound   | U            |

You can access all abbreviations and their meanings like this:

``` r
All_abbrs <- World$states$asDataFrame
```

*Notes:*

- *Compartment deepocean only exists on Global (Arctic, Moderate,
  Tropic) scale.*
- *Compartments lake, river, agriculturalsoil and othersoil only exist
  on regional and continental scale.*

The abbreviations used in the emissions data frame are built up as
follows:

1.  Abbreviation of the subcompartment
2.  Abbreviation of the scale
3.  Abbreviation of the species.

For example:

aAU –\> “a” for air (subcompartment) + “A” for Arctic (scale) + U for
unbound (species).

Now the emissions data frame can be created. The column named “Abbr”
contains the abbreviations, and the column “Emis” contains the
emissions. In the example below, emissions of 10000 t/y go into regional
air, regional agricultural soil and regional river water. These
emissions in tonnes per year are then converted to mol/s.

**For the species abbreviation, use:**

- “U” for “Unbound”: Used when the substance is molecular (e.g., a
  chemical dissolved in water or air).

- “S” for “Solid”: Used when the substance is a particle (e.g.,
  microplastics, dust, or other solid-phase contaminants).

In this case we use U because we initialized the World for a molecule.

``` r
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10, 10, 10)) 

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) # convert t/y to mol/s

knitr::kable(emissions)
```

| Abbr |      Emis |
|:-----|----------:|
| aRU  | 0.0003171 |
| s2RU | 0.0003171 |
| w1RU | 0.0003171 |

### Solve the matrix

To solve the matrix, a solver first needs to be specified. To solve for
a steady state we can use “SteadyODE”. In this case the resulting steady
state masses are output but the `World$Solve()` function.

``` r
# Define the solver function to use. For steady state calculations, this is always "SteadyODE"
World$NewSolver("SteadyStateSolver")

# Solve with the emissions we defined in the previous chunk
World$Solve(emissions = emissions)

# Access the masses in each compartment
masses <- World$Masses()
concentrations <- World$Concentration()

knitr::kable(masses)
```

| Abbr  |      Mass_kg |
|:------|-------------:|
| aRU   | 2.114600e+01 |
| w1RU  | 1.007770e+04 |
| w0RU  | 1.341523e+04 |
| w2RU  | 5.355952e+02 |
| sd1RU | 2.865373e+02 |
| sd0RU | 1.104391e+01 |
| sd2RU | 4.478242e+00 |
| s1RU  | 6.655802e+02 |
| s2RU  | 1.422221e+04 |
| s3RU  | 2.465112e+02 |
| aCU   | 1.337775e+01 |
| w1CU  | 5.920031e+02 |
| w0CU  | 1.385796e+03 |
| w2CU  | 3.228415e+04 |
| sd1CU | 1.683231e+01 |
| sd0CU | 1.140910e+00 |
| sd2CU | 1.349678e+01 |
| s1CU  | 2.135451e+02 |
| s2CU  | 9.894505e+02 |
| s3CU  | 7.909077e+01 |
| aAU   | 6.939440e-02 |
| w2AU  | 2.482725e+04 |
| w3AU  | 6.086643e+05 |
| sd2AU | 1.697419e+01 |
| s1AU  | 1.058669e+01 |
| aMU   | 1.636127e+00 |
| w2MU  | 3.161333e+04 |
| w3MU  | 9.246048e+05 |
| sd2MU | 2.576948e+01 |
| s1MU  | 1.040952e+02 |
| aTU   | 1.011232e-01 |
| w2TU  | 3.455249e+04 |
| w3TU  | 1.115822e+06 |
| sd2TU | 3.106387e+01 |
| s1TU  | 2.049159e+00 |

``` r
knitr::kable(concentrations)
```

| Abbr  | Concentration | Unit    |
|:------|--------------:|:--------|
| aAU   |     0.0000000 | g/m3    |
| aCU   |     0.0000000 | g/m3    |
| aMU   |     0.0000000 | g/m3    |
| aRU   |     0.0000000 | g/m3    |
| aTU   |     0.0000000 | g/m3    |
| s1AU  |     0.0000000 | g/kg dw |
| s1CU  |     0.0000080 | g/kg dw |
| s1MU  |     0.0000001 | g/kg dw |
| s1RU  |     0.0001998 | g/kg dw |
| s1TU  |     0.0000000 | g/kg dw |
| s2CU  |     0.0000042 | g/kg dw |
| s2RU  |     0.0004804 | g/kg dw |
| s3CU  |     0.0000080 | g/kg dw |
| s3RU  |     0.0001998 | g/kg dw |
| sd0CU |     0.0000230 | g/kg dw |
| sd0RU |     0.0017905 | g/kg dw |
| sd1CU |     0.0000309 | g/kg dw |
| sd1RU |     0.0042232 | g/kg dw |
| sd2AU |     0.0000001 | g/kg dw |
| sd2CU |     0.0000006 | g/kg dw |
| sd2MU |     0.0000001 | g/kg dw |
| sd2RU |     0.0004149 | g/kg dw |
| sd2TU |     0.0000001 | g/kg dw |
| w0CU  |     0.0000000 | g/L     |
| w0RU  |     0.0000001 | g/L     |
| w1CU  |     0.0000000 | g/L     |
| w1RU  |     0.0000003 | g/L     |
| w2AU  |     0.0000000 | g/L     |
| w2CU  |     0.0000000 | g/L     |
| w2MU  |     0.0000000 | g/L     |
| w2RU  |     0.0000000 | g/L     |
| w2TU  |     0.0000000 | g/L     |
| w3AU  |     0.0000000 | g/L     |
| w3MU  |     0.0000000 | g/L     |
| w3TU  |     0.0000000 | g/L     |

We can now plot the masses and concentrations using the built-in plot
functions. The functions are called by using `World$PlotMasses` for
masses, and `World$PlotConcentration` for concentrations. You need to
specify which scale you want to plot the outcome for. If no scale is
specified, the Regional scale will be chosen for you. Additionally you
can define for which SubCompart(s) the outcomes should be plotted. If
you don’t specify this, the outcomes will be plotted for all SubComparts
in the Scale.

``` r
# Plot the masses and concentrations for all subcompartments at regional scale
World$PlotMasses(scale = "Regional")
```

![](Getting-started_files/figure-gfm/Plot%20the%20masses%20and%20concentrations-1.png)<!-- -->

``` r
World$PlotConcentration(scale = "Regional")
```

![](Getting-started_files/figure-gfm/Plot%20the%20masses%20and%20concentrations-2.png)<!-- -->

``` r
# Select multiple subcomparts to plot the masses for
World$PlotConcentration(scale = "Regional", subcompart = c("river", "lake", "sea"))
```

![](Getting-started_files/figure-gfm/Plot%20the%20masses%20and%20concentrations-3.png)<!-- -->

Finally, if you are interested in the other functions available in
World, you can use `ls(World)` to see them all.

**For more information on the different types of solvers and how to use
them, please see** [this vignette](vignettes/x.-Solver-use.Rmd).
