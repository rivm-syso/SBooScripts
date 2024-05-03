Basics for new developers of SimpleBox
================
VR
5/1/2024

- <a href="#basics-for-new-developers"
  id="toc-basics-for-new-developers">Basics for new Developers</a>
  - <a href="#structure-of-model" id="toc-structure-of-model">Structure of
    model</a>
  - <a href="#repositories" id="toc-repositories">Repositories</a>
    - <a href="#basics-of-sboo-repository"
      id="toc-basics-of-sboo-repository">Basics of SBOO Repository</a>
    - <a href="#sbooscripts---overview-excel-files"
      id="toc-sbooscripts---overview-excel-files">SBOOScripts - Overview Excel
      Files</a>
    - <a href="#sbooscripts---initworld-scripts"
      id="toc-sbooscripts---initworld-scripts">SBOOScripts - InitWorld
      Scripts</a>
  - <a href="#accessing-world-data" id="toc-accessing-world-data">Accessing
    World Data</a>
  - <a href="#creating-new-variablesprocesses"
    id="toc-creating-new-variablesprocesses">Creating new
    variables/processes</a>
    - <a href="#variables-and-functions-v_-and-f_"
      id="toc-variables-and-functions-v_-and-f_">Variables and functions (v_
      and f_)</a>
    - <a href="#processes" id="toc-processes">Processes</a>
  - <a href="#adding-new-substances" id="toc-adding-new-substances">Adding
    new substances</a>
  - <a href="#debugging-strategies" id="toc-debugging-strategies">Debugging
    strategies</a>

# Basics for new Developers

The vignette and the development folders contain a lot of information
for specific processes and background information on the technical
details of some. For a description of the SimpleBox (SB)concept, please
look at the files starting with numbers in the vignette folder. These
follow the structure of Hollander et al. (2014) and are mostly focussed
on understanding conceptual processes. This vignette is aimed at
explaining the basic concepts, structure and tools needed for
successfully getting an insight into the development process. In this
vignette, the following things will be described:

- Structure of model

- Repository structure

## Structure of model

Several main parts of the model are important to understand:

- Compartments: The main 4 compartments (air, water, soil, sediment).
  These are also called ‘maxtrix’.

- Subcompartments: Divide the 4 main compartments into different
  subcompartments with different properties (e.g. soil –\> naturalsoil,
  agriculturalsoil and othersoil.

- Scales: There are 5 scales in SB; regional and continental (with all
  subcompartments) and three simplified global scales (moderate,
  tropical and arctic). The regional and continental scale are nested
  within the moderate global scale and thus connected through certain
  flows.

- Substances: Individual substances can be called by the model. They are
  part of either one of the three substance classes: molecular, particle
  or plastic.

- Species: The particles and plastics are found in four speciations:
  Particle (Solid, S), Aggregated (Small, A) Attached (Large, P),
  Unbound (Molecular, U). In SBExcel, Unboud is split over Dissolved and
  Gaseous. *Note that each speciation has three different ways of
  calling it*

The concept of SimpleBox in R follows the long data method, meaning that
there is different nests in which properties are defined, e.g. the
attachment efficiency of a particular substance might differ per
subcompartment or even scale. As such it is important to understand the
basic ‘nests’. If you initialize the world and the core ‘looks’ for data
it follows a certain key such as (SubstanceName, SpeciesName,
from.SubCompartName, to.SubCompartName). It will need input data for all
of this.

## Repositories

During development, SB is split over two projects. This is easier to
maintain the future SBOO (SimpleBox Object-Oriented) package from the
data and the scripts that help the development.

The SBOOScripts repository contains all csv data files, vignettes and
scripts to initialize the SBOO-Worlds. SBOO-worlds are scripts that are
run that initialize all variables, fluxes and requirements based on the
input of several csv files. These CSV files will be discussed in a later
heading. Most of the bug fixes can be done within this repository.

The SBOO repository contains the core of the calculations, including all
processes, variable calculations and matrix calculations. The structure
of this repository is discussed in the next heading.

### Basics of SBOO Repository

The SBOO repository consists of several types of files, of which most
are part of the OO-matrix, which should not be adjusted. For a detailed
description of all types of files, please reference AAAreadme.R. The
following file types are relevant for development:

- k\_ : These files describe process modules, so files that describe a
  certain process between compartments, subcompartments and species.
  These use input data from all other files and data and are the only
  files capable of taking and calculating with ‘long input data’, such
  as which subcompartment it comes from or goes to.

- f\_ : These describe functions that are often called in the k\_ files
  for specific occasions. It can only calculate for specific cases,
  constants or be manipulated through all., which can get an entire
  matrix (explained in more detail later)

- v\_: Calculates variables, which can be accessed from the World
  object. Similar to the f\_ files they are often required in k_files.
  There’s not a specific difference between the two file types.

- x\_: describe flows; in this case mostly used for advection.

*note: All scripts in the SBOO repository are documented in roxygen2 ,
which creates in line documentation. Please make sure that you follow
these examples*.

### SBOOScripts - Overview Excel Files

The matrix calculates based on keys and process definitions that are
largely defined in the /data folder. Below you will find an overview of
the (relevant) Excel files:

- *Constants.csv* defines 42 constants and their respective SB4Excel
  names

- *Defs.csv* defines (partly) how the keys of the OO module are used and
  which data is retrieved for which part of the matrix calculation (this
  does not need to be adjusted).

- *FlowIO.csv* defines the advective flows for all scales and
  dimensions. (x_files) This does not need to be adjusted (unless
  another x\_ file is added).

- *MatrixSheet.csv* defines some constants for the different matrces,
  such as density and Corg.

- *Processes4SpeciesTp.csv* indicates which processes (k\_ files) should
  be called depending on the species (Molecular, particle, plastic).

- *QSAR.csv* defines relevant sorption parameters for molecular species.

- *ScaleProcesses.csv* Defines for which scales the advective process
  should take place (k\_ file).

- *ScaleSheet.csv* defines the ‘World’ parameters for the different
  scales. Should, in essence, not be adjusted.

- *ScaleSubCompartdata.csv* Defines ‘World’ parameters for the
  subcompartments.

- *SpeciesCompartments.csv* Includes bacterial concentration in water.

- *SpeciesProcesses.csv* Defines agglomeration between different
  speciations of particles, should not be adjusted.

- *SpeciesSheet.csv* Defines the speciation of particles, its
  abbrevation and defines relevant processes where this is necessary.

- *SubCompartProcesses.csv* Defines the direction of flow for all
  processes (k_files) and between which subcompartments this happens.

- *SubCompartSheet.csv* Defines subcompartments and its abbreviations,
  some constants and some definition on which processes are relevant.

- *SubstanceCompartments.csv:* Defines parameters that are different per
  compartment for all substances.

- *Substances.csv:* Defines all callable substances and its relevant
  parameters.

- *SubstanceSubCompartSpeciesdata.csv* Defines parameters that differ
  per subcompartment, substance and speciation.

- *Units.csv* Describes most variables, their unit and where they are
  called.

### SBOOScripts - InitWorld Scripts

Currently, there are three InitWorld Scripts based on the three
substance classes: molecular, particle and plastic. They can be found in
SbooScripts/BaseScripts/initWorld_SubstanceClass. They initialize the
core and the modules that construct the matrix for calculation. In some
cases, constants are set (that are usually not used). This needs to be
improved for newer versions. The constants that are set are not used in
calculations.

The processes that are added to these worlds are denoted in the
Processes4SpeciesTP.csv file. It subsequently checks if all variables
are present for these chosen processes.

## Accessing World Data

Different parts of World need to be accessed differently. To filter from
certain specific parts you can use the following syntax:

``` r
kaas |> filter(from == "aCP")
```

It gives output for all processes (k_files) and its respective from and
to information and its value.

To access specific variables/constants, you can use the following
syntax:

``` r
World$fetchData("variable")
```

This will give you the value of the variable (also per subcompartment,
scale and species if so defined). As it is printed as a Tibble, you can
use the dplyr syntax to filter the tibbles further.

To look at a specific process you can use the following syntax:

``` r
## to look at the process
World$moduleList[["k_CWscavenging"]]$execute
## to execute it for everything it is executed for
World$moduleList[["k_CWscavenging"]]$execute()
## to look between which compartments the process operates
World$moduleList[["k_CWscavenging"]]$FromAndTo
## to debug a process 
debugonce(k_CWscavenging)
```

## Creating new variables/processes

You can create new variables, functions and processes without needing to
access the SBOO core.

### Variables and functions (v\_ and f\_)

These can be added without adding much to the csv files (unless new
(constant) variables are needed. v\_ and f\_ files are initialized
before the processes \$from and \$to are initialized, hence you can not
use this information directly in these scripts. If this behavior is
needed, its best to create a placeholder variable that can be called
from a k\_ script, which does have access to this data.

However, if certain processes only hold for certain subcompartments you
can manipulate this through using the prescript all. , an example is
given below:

``` r
FRins <- function(Kp, SUSP, COL, KpCOL,
                FRACw, FRACa, FRACs, Kacompw, 
                FRorig_spw, all.rhoMatrix, Matrix){
  RHOsolid <- all.rhoMatrix$rhoMatrix[all.rhoMatrix$SubCompart == "naturalsoil"]
  switch(Matrix,
         "soil" =  
           FRACs/(FRACa*(Kacompw*FRorig_spw)/(Kp*RHOsolid/1000)+FRACw/(Kp*RHOsolid/1000)+FRACs),
         return(NA)
  )
}
```

For a function/variable to work it needs to be called by a process (k\_)
for it to be included in the matrix calculation. If input data is
missing in these functions or variables, sometimes the errors can be
very unclear. Therefore make sure to check beforehand if you have
specified all input data in csv files before you create a
function/variable which calls on them.  

### Processes

The processes can access the from and to information, as is examplified
below:

``` r
k_Erosion <- function(relevant_depth_s,penetration_depth_s, EROSIONsoil, VertDistance, ScaleName, to.SubCompartName, 
                      Matrix, all.landFRAC, all.Matrix ){
  if (ScaleName %in% c("Regional", "Continental") & to.SubCompartName == "sea") {
    return(NA)
  } 
  if ((ScaleName %in% c("Tropic", "Moderate", "Arctic")) & to.SubCompartName != "sea") {
    return(NA)
  } 
 # fraction <- FracROWatComp(all.landFRAC, all.Matrix, Matrix, SubCompartName, ScaleName)
  EROSIONsoil * f_CORRsoil(VertDistance, relevant_depth_s, penetration_depth_s) / VertDistance * FracROWatComp (all.landFRAC, all.Matrix, Matrix, SubCompartName = to.SubCompartName, ScaleName)   #[s-1]
}
```

For a process to work, a couple of things need to be checked:

- Processes4SpeciesTp needs to be updated with the new process and
  marked for the relevant substance classes
- SubCompartProcesses needs to specify between which subcompartments the
  process holds
- If certain exclusions need to be made, this can be done in the script
  through if statements, but input data needs to be available for
  everything that runs through the start of the script.

## Adding new substances

If the model is not running for a certain substance, chances are high
substance-specific input data is missing. Similarly to when you’re
wanting to add new substances, it is good to check and adjust the
following csv files:

- Substances.csv : All basic info needs to be present here.
- Substancecompartments.csv : Specific values for specific compartments,
  such as kdeg need to be present here.
- SubstanceSubCompartSpeciesdata: needed for variables such as
  attachment efficiency (alpha), kdis and kfrag and kmpdeg
  (microplastics)

## Debugging strategies

There’s several ways to start debugging. Due to the complicated
structure of the R6-core, sometimes it’s hard to identify where the
error comes from exactly. If you have a specific error, it’s good to
search for the location of this error in the R6 core scripts. However,
if you’re unsure of the outcome or the values of several variables, you
can use the following strategies:

The first option is to use \$NeedVars . For this strategy you need to
‘calculate’ the variable again so you can access its information. The
printing option gives you information on which function it comes from
and which variables are needed. See below:

``` r
CalcVariable <- World$NewCalcVariable("Area")
CalcVariable
CalcVariable$needVars
```

You can use the previously mentioned \$execute function also to debug
for certain specific subcompartments and scales like so:

``` r
CalcVariable$execute(debugAt = list(ScaleName = "Arctic", SubCompartName = "deepocean"))
```
