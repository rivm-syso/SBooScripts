---
title: "README"
output:
  html_document:
    toc: true
    toc_depth: 1
editor_options: 
  markdown: 
    wrap: sentence

---


# 1. Description of SimpleBox

SimpleBox is a multimedia mass balance model of the so-called ‘Mackay type’ (also called "box models").
It simulates environmental fate of chemicals, nanomaterials and plastics as fluxes (mass flows) between a series of well-mixed boxes of air, water, sediment and soil on regional, continental and global spatial scales.
SimpleBox was first developed in 1986 and since then has seen multiple versions.
The current version (SimpleBox v5.0) is the first implementation in R.
The primary use of SimpleBox is to calculate the expected environmental fate of specific chemicals or particles, given a certain emission into the environment.
Donald Mackay classified environmental fate models into four levels (Table 1).
SimpleBox is a level 3 and 4 model, meaning that SimpleBox can calculate concentrations for multiple environmental compartments (e.g. air, soil, water) and multiple scales (regional, continental, global) both at steady-state and dynamically, over time.

#### Table 1. Overview of the levels of environmental fate models, as defined by Mackay.

| Level   | Description                                                                                                                                            | Use                                                                                                                                                                                                                                                                                      |
|-----------------|----------------------------|----------------------------|
| Level 1 | Closed system in equilibrium. No degradation or removal processes, does not include input (immission) or output (degradation, transport) of a chemical | Provides insight into how a chemical partitions across environmental compartments at equilibrium                                                                                                                                                                                         |
| Level 2 | Open system, steady state at equilibrium. Constant in- and output                                                                                      | Long-term environmental fate under constant emissions                                                                                                                                                                                                                                    |
| Level 3 | Open system, steady state, but non-equilibrium. Constant in- and output.                                                                               | Long term environmental fate under constant emissions. More realistic than level 2, can account for differences in concentration between scales (e.g. regional, continental) in the same type of compartment (e.g. water or soil) as it does not assume equilibrium between compartments |
| Level 4 | Open system, non-steady state, non-equilibrium. Dynamic input.                                                                                         | In addition to level 3, level 4 models can model environmental fate dynamically over time                                                                                                                                                                                                |

Mackay-type or box models are very suitable for the estimation of concentrations in multiple environmental compartments taking into account chemical and/or particle properties.
The advantage of Mackay/box type models is that they are relatively simple.
They do not require detailed, spatially explicit information of the environment.
Box models calculate a concentration for the entire box, i.e a single value for the entire compartment, by assuming the compartment is well mixed.
This makes the model fit for the purpose of determining background concentrations at large (e.g continental) scales and/or over large timescales, or for research where differences at the very local scale (e.g. the concentration of a substance in soil at one locations vs the concentration 10m further) are not relevant.
An example of the latter are social-economic assessments of environmental impact of the emission of substances and the comparison of scenarios for life cycle assessments.
In addition to environmental fate, SimpleBox can also be used to study the factors that influence the environmental fate of substances or particles, or to identify and prioritize data gaps.
SimpleBox is used for policy, legislation and scientific purposes.

![Figure 1. Concept of SimpleBox. where: e: Emission rates (ton/year), k: Rate constant (s-1) describing transport between environmental compartments (air, water sediment and soil) based on the relevant fate processes and degradation., A: Matrix of all rate constants, m: Mass in each environmental compartment of emitted compound](FiguresQualityDocumentation/SimpleBoxConcept.png)


# 2. Installation and user guidelines

## Installation

SB is split over two repositories.
In order to use [SBOO](https://github.com/rivm-syso/SBoo) you need two projects with the parent folder in common.
This repository and the SBOO repository thus need to be stored in the same folder.
At the moment a sboo library is mimicked as part of a script, this will change in the future.
For now starting point are scripts and R notebooks in SBooScripts.
The preferred approach is creating two R projects in R-Studio.

### Dependencies

SimpleBox 5.0 required the following packages to run:

tidyverse ggdag rmarkdown tidyxl openxlsx constants

## Getting started

-   [Getting Started](vignettes/Getting-started.md) : this file includes all basics for users (not necessarily developers) to use and calculate with the R-implementation of SB.

-   [x1 Solver use](vignettes/x.1%20Solver%20use.Rmd) : explains how to solve for both static and dynamic data.


## Guidance for developers

\-[Basics for developers](vignettes/Development/BasicsOfDevelopment.md) : This vignette is a good starting point for starting developers.
The underlying structure of the repository is explained here, including the input data.

The Development folder details the technical construction of the project and is most suitable for developers.
The vignette [start](/vignettes/Development/start.md) explains the basics of object-oriented modelling and how this is implemented in this repository.
Multiple other vignettes are useful if aiming to develop, such as [CSV-reordering](/vignettes/Development/CSVdata.Rmd), [creating variables](vignettes/Development/FirstVars.Rmd), [creating and checking flows](/vignettes/Development/AirFlow.Rmd), [creating processes](vignettes/Development/processFlow.Rmd) and [testing new variables](/vignettes/Development/testRainDropRadius.Rmd).
- The vignette folder outlines the theoretical implementation of the SimpleBox model, following the structure of Chapter 3 in [Schoorl et al. (2015)](https://www.rivm.nl/bibliotheek/rapporten/2015-0161.html)


# 3. Contact information

Issues can be submitted through GitHub

RIVM leads the development of SimpleBox. 

Contact: simplebox\@rivm.nl

# 4. License

EUROPEAN UNION PUBLIC LICENCE v. 1.2
