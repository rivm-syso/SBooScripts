Intermedia Partitioning
================

# Intermedia partitioning

There are multiple transfers for substances from one matrix to the other
(matrix in the sense of medium, like air or water). The speed of some of
these transfers are calculated as processes; you will find them in
SubCompartProcesses.csv. Other transfers are so quick and small that a
continuous equilibrium is assumed. In this vignette will will focus on
this intermedia partitioning. *\[… more detailed description to follow
…\] test*

## Partitioning coefficients of substances

If “World” has found data for the substance you initiated with, this is
perfect. But these properties are not always known. You can assess them
by “models”; for Ksw a model is given by the fKsw function. Mind you;
this is not not a variable defining function, and you will have to fetch
the parameters yourself, and put the result in the core-data. We
demonstrate how.

The function is given below, the parameters are: Kow, pKa, Corg, a, b,
ChemClass and RHOsolid; The code is not nicely formatted by Rmd.

Does the database contain Kow, pKa, Corg…? If not we can store the
result in the internal data of World by the function from the World
object (method) World\$SetConst()

Oeps, the CORG variable in the excel version is now a table in R of Corg
for all subcompartments, we need StandardCorgSoil

pKa could be missing (e.g. in the case of “default substance”). If the
substance is neutral, you can apply a value of 7. Variables a and b come
from the QSARtable. RHOsolid can be taken from the Rho from the matrix
of non-specific, standard soil, i.e. “othersoil” This “variable” is used
in multiple formulas in the excel version, but because it’s only a copy
it is more transparent to set it locally.

We now have all the parameters and can set the value for Ksw and know
that the system will use our modelled Ksw

Not in the data is Ksw for the alternative form. The same function f_Ksw
is applied by the defining function Ksw.alt, creating the SB variable:

## Fraction molecular species in original form (based on pKa)

This is the fraction of a substance that is int he original form
(non-disosciated) specific fraction that also relates to the pH of the
compartment.

The FRorig for Matrix “air” is the FRorig of aerosols in air. The pH of
“air” is set to 3 in the SubCompartSheet.csv, corresponding to “pH.aerw”
in the excel version.

## Partitioning coeficients Kp

FRorig is the FRaction original species, depending on pKa and pH for
some substances. The partitioning of a subcompartment / water is Kp,
which is also a OO state variable:

## Dimensionless partition coefficients per compartment/scale

The substance specific air/water partition coefficient at 25 degrees
Celsius (Kaw25) is required for the calculation of scale-specific
partition coefficients of air/water, aerosol water/air, and aerosol
solids/air. When not provided as input, it is calculated within the
functions for the scale specific partition coefficients (and not first
as a separate variable with CalcVar).

Calculating the partitioning between soil- or sediment and water
requires the fractions of water and air in soil, in addition to some of
the previously calculated variables such as Kp, Kacompw, and FRorig_spw.
The fractions of water and air in soil are provided as input (“FRACw”
and “FRACa”) in “ScaleSubCompartData.csv” and can differ between both
(combinations of) scale and compartment. The fraction of solids in soil
and sediment is calculated based on FRACw and FRACa, except for the
fraction of solids in air, where it is also provided as input. Input
data is provided as subFRAC, FRACx is calculated. See
[FRACwas.md](vignettes/5.%20Characteristics%20of%20the%20Environment/FRACwas.md "FRACwas.md").

## Fraction chemical in gas, water or solid phase

The fractions of the chemical in the gas, water and solid phase of a
compartment are calculated as variables with the following functions:

These variables described the partitioning constants. The speed in which
the equilibria are reached is modelled by diffusion processes, like
volatilisation and absorption. This is described in a separate vignette,
namely DiffusionProcesses.

A source script is available for testing purposes to prepare all
variables related to partitioning in one go. The script requires that
you first have defined a substance (if you want to run the model with a
substance other than the default) and that you have initialized the
“World”.
