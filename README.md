SimpleBox data and scripts
================
RIVM
2024-11-11

# 1. About SimpleBox

SimpleBox is a multimedia mass balance model of the so-called ‘Mackay
type’ (also called “box models”). It simulates environmental fate of
chemicals, nanomaterials and plastics as fluxes (mass flows) between a
series of well-mixed boxes of air, water, sediment and soil on regional,
continental and global spatial scales. SimpleBox was first developed in
1986 and since then has seen multiple versions. The current version
(SimpleBox v5.0) is the first implementation in R. The primary use of
SimpleBox is to calculate the expected environmental fate of specific
chemicals or particles, given a certain emission into the environment.
Donald Mackay classified environmental fate models into four levels
(Table 1). SimpleBox is a level 3 and 4 model, meaning that SimpleBox
can calculate concentrations for multiple environmental compartments
(e.g. air, soil, water) and multiple scales (regional, continental,
global) both at steady-state and dynamically, over time. More
information can be found
[here](vignettes/QualityDocumentation.md "More info on SimpleBox").

# 2. Installation and user guidelines

## Installation

SB is split over two repositories. In order to use
[SBOO](https://github.com/rivm-syso/SBoo) you need two projects with the
parent folder in common. This repository and the SBOO repository thus
need to be stored in the same folder. At the moment a sboo library is
mimicked as part of a script, this will change in the future. For now
starting point are scripts and R notebooks in SBooScripts. The preferred
approach is creating two R projects in R-Studio.

### Dependencies

SimpleBox 5.0 required the following packages to run:

tidyverse ggdag rmarkdown tidyxl openxlsx constants

## Getting started

- [Getting Started](vignettes/Getting-started.md) : this file includes
  all basics for users (not necessarily developers) to use and calculate
  with the R-implementation of SB.

- [x1 Solver use](vignettes/x.1%20Solver%20use.Rmd) : explains how to
  solve for both static and dynamic data.

## Guidance for developers

\-[Basics for developers](vignettes/Development/BasicsOfDevelopment.md)
: This vignette is a good starting point for starting developers. The
underlying structure of the repository is explained here, including the
input data.

The Development folder details the technical construction of the project
and is most suitable for developers. The vignette
[start](/vignettes/Development/start.md) explains the basics of
object-oriented modelling and how this is implemented in this
repository. Multiple other vignettes are useful if aiming to develop,
such as [CSV-reordering](/vignettes/Development/CSVdata.Rmd), [creating
variables](vignettes/Development/FirstVars.Rmd), [creating and checking
flows](/vignettes/Development/AirFlow.Rmd), [creating
processes](vignettes/Development/processFlow.Rmd) and [testing new
variables](/vignettes/Development/testRainDropRadius.Rmd). - The
vignette folder outlines the theoretical implementation of the SimpleBox
model, following the structure of Chapter 3 in [Schoorl et
al. (2015)](https://www.rivm.nl/bibliotheek/rapporten/2015-0161.html)

# 3. Contact information

Issues can be submitted through GitHub

RIVM leads the development of SimpleBox.

Contact: simplebox@rivm.nl

# 4. License

EUROPEAN UNION PUBLIC LICENCE v. 1.2
