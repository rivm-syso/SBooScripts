Getting Started for Developers
================
Jaap Slootweg, Valerie de Rijk
2024-07-24

## Introduction to SB, the OO version.

Chemical behavior in the environment is often modeled with multimedia
fate models. SimpleBox is one often-used multimedia fate model, firstly
developed in 1986. Since then, three updated versions were published and
the model got included within the EU chemical safety assessment referred
to as REACH. The SimpleBox 1.0, 2.0, 3.0 and 4.0 versions are
spreadsheet models available in MS Excel. Here we present the SimpleBox
5.0 version in R which is also the first SimpleBox Object Oriented
(SBOO) version.

### SBOO basic concept

This vignette explains how to manage the object oriented (OO) part of
SBOO. In practice you will not notice much from the OO part as you can
make R scripts like any other, so that you don’t need to thorough
understanding of the approach. However, a common understanding of the
basics of the SBOO is needed before you can get started. These basics
are explained here. An object is a data structure having some attributes
and methods which act on its attributes. As such, the objects have both
functions, which are called methods, and data. The conceptual structure
of SimpleBox are a fate matrix (A) and emission vector (e) to simulate
chemical mass (m) balance equations as m = -A^-1 \*e. The fate matrix A
holds rate constants derived for the environmental fate processes the
chemicals are subjected to. The derivation of these rate constants
consists of mathematical equations used in physics and chemistry to
express the interaction between the chemical substances and the
environment. The MS Excel versions of SB 1.0-4.0 include more than 900
of such equations as formulas. In SBOO these equations are described in
\<40 separate R scripts that can be used to simulate similar chemical
fate processes but under different conditions, e.g. the wet deposition
of chemicals at different rain rates or the advective transport in
different surface water bodies. These R scripts set up functions to (i)
directly derive a rate constant for an environmental fate process, (ii)
derive a value for a parameter used in the functions to derive a rate
constant or (iii) part of the computation of the mass balance equations
with fate matrix A and emission vector e. The methods described in the R
scripts need input data in order to run them. Within the data structure
of SBOO, these data are explicitly kept separate from the methods.
However, both can be accessed similar to dataframes using the \$ sign.
This will be demonstrated further below.

### Setting up you folders

In order to use SBOO you need two projects with the parent folder in
common. Once you have access and this setup completed, you can start
working, most likely only in the SBooScripts project.

### Making changes

Before changing anything, don’t forget to make a branch (under the Git
tab, right from the Environment tab, where you can see the variables in
your environment). After you made you brilliant update in your local
branch, commit it with comments and push it to the remote on Github. If
you want to append your changes to the main branches, create a pull
request. It is strongly advised to require at least one reviewer. This
reviewer will then be responsible for testing your changes and merging
your pull request.

### Folder structure

In the sbooScripts you will find the following folders: data,
baseScripts, vignettes, testScripts and newAlgoritmsScripts In the data
folder are the csv files, and two versions of the excel version, the
original (Molecular) and a Nano version. The baseScripts contains R
scripts to help initiating the objects you will use. Other scripts in
the folder are explained in other vignettes.For testing of (your) new
scripts and “defining functions” you will use testScripts.

### Data

SB uses data of substances, of compartments and so on. These data are
stored in csv files. A description of exactly how the data is stored can
be found in in vignette “CSVdata.Rmd”

### Calculation steps

The “Box” in SimpleBox (SB) is a combination of space and compartment.
The space is a subdivision of the nothern hemisphere into 3 “global”
scales, and a nested continental and regional scale. The compartments
are split into subcompartments like freshwaters and sea, and different
type of soil. SB calculates a first-order rate of mass flow (“k”) from
each box (subcompartment/scale) into any other. The rates are associated
with processes, like “Advection” or “Deposition”. The resulting matrix
can then be solved for a steady state. Processes in SBOO are a special
class. A method of this class executes a function typical to that
process for all the from- and to boxes where this process takes place.
Calculating the k’s of the processes is usually preceded by calculating
variables and flows. These depend on the data in the csv-files and are
input to the process-function. Variables and flows also execute a
function typical for the variable or flow at hand. How this operates is
explained in the vignette “FirstVars.Rmd”. If you want to know more
about how users will use this repository, access
[Getting-started](vignettes/Getting-started.md)
