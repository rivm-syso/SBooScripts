Getting started
================
Anne Hids
2024-12-10

## Initialize

This vignette demonstrates how to use SimpleBox Object-Oriented (SBOO).

Before starting, make sure your working directory is set to the
SBooScripts folder.

### See if required packages are installed

``` r
check_and_install <- function(package) {
  tryCatch({
    # Load the package
    library(package, character.only = TRUE)
    message(paste("Package", package, "is already installed and loaded."))
  }, error = function(e) {
    # If an error occurs, install the package
    message(paste("Package", package, "is not installed. Installing now..."))
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
    message(paste("Package", package, "has been successfully installed and loaded."))
  })
}

# Install the required packages
check_and_install("ggplot2")
check_and_install("tidyverse")
check_and_install("constants")
check_and_install("deSolve")
check_and_install("knitr")
```

### Choose a substance

The first step is to initialize the model. Before initialization a
substance needs to be selected, otherwise the “default substance” is
used. To select another substance than “default substance”, a substance
can be chosen from the “Substance” column of the data frame created
below.

``` r
substances <- read.csv("data/Substances.csv")

# Assign a substance name from the Substance column to the variable "substance":
substance <- "1-aminoanthraquinone"
```

### Initialize the World object

The World object contains all variables and first order rate constants
(k’s) for the chosen substance. This object is needed later to calculate
the masses in each compartment on each scale.

To initialize the World object, one of three script is called:

- initWorld_onlyMolec.R (used for molecules)
- initWorld_onlyParticulate.R (used for particulates)
- initWorld_onlyPlastics.R (used for microplastics)

Choosing which script to use is dependent on the ChemClass of the chosen
substance (see “ChemClass” column in the “substances” data frame). Each
of these three classes require different initWorld scripts because
different processes and variables are used to calculate the k’s. With
the chunk below, the correct initWorld script is automatically chosen
and run based on the chosen substance:

``` r
chemclass <- substances |>
  filter(Substance == substance) |>
  select(ChemClass)

chemclass <- chemclass$ChemClass

if(substance == "microplastic"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if (chemclass == "particle") {
  source("baseScripts/initWorld_onlyParticulate.R")
} else {
  source("baseScripts/initWorld_onlyMolec.R")
}
```

## Accessing variables and k’s

Now that the World is initialized, its variables and calculated flows
can be accessed. To access these variables and k’s, first the names of
the variables are needed. They can be accessed by using the code below.
The first 10 variable names are printed, but there are 201 variables in
total.

``` r
varnames <- World$fetchData()

print(varnames[1:10])
```

    ##  [1] "a"              "a"              "AbbrC"          "AbbrP"         
    ##  [5] "AEROresist"     "AEROSOLdeprate" "AirFlow"        "alpha.surf"    
    ##  [9] "Area"           "AreaLand"

### Access variables

A specific variable (in this case AreaSea) can be accessed as follows:

``` r
kable(World$fetchData("AreaSea"))
```

| Scale       |      AreaSea |
|:------------|-------------:|
| Arctic      | 2.550000e+13 |
| Continental | 3.713410e+12 |
| Moderate    | 3.878559e+13 |
| Regional    | 1.000000e+09 |
| Tropic      | 8.925000e+13 |

### Access k’s

The “kaas” variable contains a data frame with the first order rate
constants (k’s), proccess name, to-subcompartment name
from-subcompartment name, to-scale name, from-scale name, to-species
name and from-species name. It can be accessed in the same way other
variables are accessed:

``` r
df_ks <- World$fetchData("kaas")
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
kable(World$fetchData("TotalArea"))
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
  Waarde = c(4.25E+13, 7.43E+12, 8.50E+13, 4.13e+11, 1.27e+14)) |>
  mutate(varName = "TotalArea")

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

The default molecular weight for this substance is 0.147. After the
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

## Calculate steady state output

To calculate steady state masses, emissions and a solver are needed. The
have to be given to the solver in a particular format.

### Create emissions data frame

To be able to calculate steady state masses, an emission data frame is
needed. The emissions data frame consists of one column with the
abbreviation of the scale-subcompartment-species combination, and
another column containing the emission to that compartment.

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

kable(scales)
```

| Scale       | Abbreviation |
|:------------|:-------------|
| Arctic      | A            |
| Continental | C            |
| Moderate    | M            |
| Regional    | R            |
| Tropic      | T            |

``` r
kable(subcompartments)
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
kable(species)
```

| Species   | Abbreviation |
|:----------|:-------------|
| Dissolved | D            |
| Gas       | G            |
| Large     | P            |
| Small     | A            |
| Solid     | S            |
| Unbound   | U            |

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

Now the emissions data frame can be created. The column named “Abbr”
contains the abbreviations, and the column “Emis” contains the
emissions. In the example below, emissions of 10000 t/y go into regional
air, regional agricultural soil and regional river water. These
emissions in tonnes per year are then converted to mol/s.

**Notice that because this script is using a molecular substance, the
abbreviation “U” for “Unbound” is used here to specify emissions. If the
substance is a particle, use “S” for “Solid”!**

``` r
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) 

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60)) # convert 1 t/y to mol/s

kable(emissions)
```

| Abbr |     Emis |
|:-----|---------:|
| aRU  | 2.113986 |
| s2RU | 2.113986 |
| w1RU | 2.113986 |

### Solve the matrix

To solve the matrix, a solver first needs to be specified. To solve for
a steady state we can use “SB1Solve”. In this case the resulting steady
state masses are reported in the data frame “masses”.

``` r
# Specify which solver to use to the World object
World$NewSolver("SB1Solve")

# Use the emissions data frame and solve the matrix
masses <- World$Solve(emissions)

kable(masses)
```

|     | Abbr  | Scale       | SubCompart         | Species |       EqMass |
|:----|:------|:------------|:-------------------|:--------|-------------:|
| 196 | aRU   | Regional    | air                | Unbound | 9.376374e+05 |
| 234 | w1RU  | Regional    | river              | Unbound | 1.166945e+06 |
| 226 | w0RU  | Regional    | lake               | Unbound | 3.693672e+04 |
| 210 | w2RU  | Regional    | sea                | Unbound | 4.322630e+04 |
| 213 | sd1RU | Regional    | freshwatersediment | Unbound | 3.109767e+05 |
| 223 | sd0RU | Regional    | lakesediment       | Unbound | 2.222936e+02 |
| 183 | sd2RU | Regional    | marinesediment     | Unbound | 2.999413e+03 |
| 217 | s1RU  | Regional    | naturalsoil        | Unbound | 2.121241e+03 |
| 182 | s2RU  | Regional    | agriculturalsoil   | Unbound | 2.192734e+07 |
| 207 | s3RU  | Regional    | othersoil          | Unbound | 7.856450e+02 |
| 204 | aCU   | Continental | air                | Unbound | 3.800261e+06 |
| 208 | w1CU  | Continental | river              | Unbound | 1.516990e+03 |
| 221 | w0CU  | Continental | lake               | Unbound | 1.825295e+03 |
| 220 | w2CU  | Continental | sea                | Unbound | 1.215623e+06 |
| 195 | sd1CU | Continental | freshwatersediment | Unbound | 4.042593e+02 |
| 192 | sd0CU | Continental | lakesediment       | Unbound | 1.098902e+01 |
| 197 | sd2CU | Continental | marinesediment     | Unbound | 4.217522e+03 |
| 235 | s1CU  | Continental | naturalsoil        | Unbound | 4.065625e+03 |
| 187 | s2CU  | Continental | agriculturalsoil   | Unbound | 1.497912e+04 |
| 233 | s3CU  | Continental | othersoil          | Unbound | 1.505787e+03 |
| 211 | aAU   | Arctic      | air                | Unbound | 2.687867e+06 |
| 215 | w2AU  | Arctic      | sea                | Unbound | 1.237972e+06 |
| 203 | w3AU  | Arctic      | deepocean          | Unbound | 1.117070e+07 |
| 219 | sd2AU | Arctic      | marinesediment     | Unbound | 2.922411e+03 |
| 214 | s1AU  | Arctic      | naturalsoil        | Unbound | 3.333251e+04 |
| 224 | aMU   | Moderate    | air                | Unbound | 6.806503e+06 |
| 225 | w2MU  | Moderate    | sea                | Unbound | 5.739964e+05 |
| 231 | w3MU  | Moderate    | deepocean          | Unbound | 1.709557e+06 |
| 206 | sd2MU | Moderate    | marinesediment     | Unbound | 3.954127e+02 |
| 188 | s1MU  | Moderate    | naturalsoil        | Unbound | 2.864060e+04 |
| 227 | aTU   | Tropic      | air                | Unbound | 6.764081e+06 |
| 193 | w2TU  | Tropic      | sea                | Unbound | 2.829567e+05 |
| 201 | w3TU  | Tropic      | deepocean          | Unbound | 3.003941e+05 |
| 228 | sd2TU | Tropic      | marinesediment     | Unbound | 5.710943e+01 |
| 202 | s1TU  | Tropic      | naturalsoil        | Unbound | 8.750572e+03 |

### Model Output

For now the most reliably is to output masses and manually calculate
concentrations and other relevant output based on your needs
\[5-12-2024\]. We are working on the Concentration module and have
output of the mass flows and mass balance in preparation.

## Calculate dynamic output

It is also possible to calculate the masses in each compartment over
time using the ‘DynApproxSolve’ solver. The use of this solver is
demonstrated below.

### Make emission data frame

To use the dynamic solver, an emission dataframe is needed with three
columns: Abbr, Emis and Timed

The column named “Abbr” contains the abbreviations, and the column
“Emis” contains the emissions. In the example below, emissions in tonnes
per year are converted to mol/s. The column “Timed” contains the times
at which the emissions are emitted to the environment.

*Note: There should be at least two emissions at different times per
subcompartment for the solver to work*

``` r
# Make emission fata frame
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU","aRU", "s2RU", "w1RU"), Emis = c(5, 10, 15, 20, 25, 30), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> # Convert time from y to s
  ungroup() |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60)) # convert 1 t/y to mol/s

tmax <- 10*365.25*24*60*60 
times <- seq(0, tmax, length.out = 100)

World$NewSolver("DynApproxSolve")
solved <- World$Solve(tmax = tmax, emissions, needdebug = F)
```

## Prepare the output for plotting

A few things happen in the chunk below: - The matrix is converted to a
tibble - The tibble is converted from wide to long format - Year is
calculated from time in seconds - Based on the column Abbr, the States
dataframe is joined to the tibble

``` r
solved <- as_tibble(solved) 

solved_long <- solved |>
  select(!starts_with("emis")) |>
  pivot_longer(!time, names_to = "Abbr", values_to = "Mass") |>
  mutate(Year = time/(365.25*24*60*60)) |>
  left_join(World$states$asDataFrame, by="Abbr") # Join the abbreviations to more understandable Scale, SubCompart and Species
```

## Plot the dynamic masses at specific scales

The scales to choose from are “Regional”, “Continental”, “Moderate”,
“Tropic” and “Arctic”.

``` r
plot_scale <- function(mass_dataframe, scale){
  # Filter masses for the specific scale
  mass_data_scale <- mass_dataframe |>
    filter(Scale == scale)
  
  # Plot masses on the specific scale
  mass_plot <- ggplot(mass_data_scale, aes(x=Year, y=Mass, col=SubCompart)) + 
    geom_line() +
    ylab("Mass (kg)") +
    theme_bw() +
    ggtitle(paste0("Masses over time at ", scale, " scale")) +
    scale_y_continuous() +
    scale_x_continuous()
  
  return(mass_plot)
}

# Plot data for regional scale
regional_plot <- plot_scale(solved_long, "Regional")
print(regional_plot)
```

![](Getting-started_files/figure-gfm/Plot%20output-1.png)<!-- -->

``` r
# Plot data for continental scale
continental_plot <- plot_scale(solved_long, "Continental")
print(continental_plot)
```

![](Getting-started_files/figure-gfm/Plot%20output-2.png)<!-- -->
