---
editor_options: 
  markdown: 
    wrap: sentence
---

# RIVM Quality Documentation (RIVM Kwaliteitskader voor Modellen)

This document provides an overview of information required to assess the quality of SimpleBox according to the RIVM Kwaliteitskader voor Modellen.
Although the Kwaliteitskader is written in Dutch, this document is currently written in English, as the information and overview provided might be useful to any user of SimpleBox v5.0.

--\> zouden er over na kunnen denken dit als README.md te doen, maar is misschien wel lang.
kan ook simpelwegweg vanaf de README hiernaar verwijzen.

To DO: Table of contents met klikbare verwijzingen naar chapters

# 1. Description of SimpleBox

# 1.1 General Introduction

SimpleBox is a multimedia mass balance model of the so-called ‘Mackay type’ (also called "box models").
It simulates environmental fate of chemicals, nanomaterials and plastics as fluxes (mass flows) between a series of well-mixed boxes of air, water, sediment and soil on regional, continental and global spatial scales.
SimpleBox was first developed in 1986 and since then has seen multiple versions.
The current version (SimpleBox v5.0) is the first implementation in R.
For a full overview of the history of SimpleBox development see chapter 5.2.
The primary use of SimpleBox is to calculate the expected environmental fate of specific chemicals or particles, given a certain emission into the environment.
Donald Mackay classified environmental fate models into four levels (Table 1).
SimpleBox is a level 3 and 4 model, meaning that SimpleBox can calculate concentrations for multiple environmental compartments (e.g. air, soil, water) and multiple scales (regional, continental, global) both at steady-state and dynamically, over time.

#### Table 1. Overview of the levels of environmental fate models, as defined by Mackay.

| Level   | Description                                                                                                                                            | Use                                                                                                                                                                                                                                                                                      |
|--------------|-----------------------------|-----------------------------|
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
For a detailed description of the use of SimpleBox and the evaluation of its functioning (sensitivity, uncertainty, fit for purpose) see Chapter 4.

![Figure 1. Concept of SimpleBox. where: e: Emission rates (ton/year), k: Rate constant (s-1) describing transport between environmental compartments (air, water sediment and soil) based on the relevant fate processes and degradation., A: Matrix of all rate constants, m: Mass in each environmental compartment of emitted compound](FiguresQualityDocumentation/SimpleBoxConcept.png)

#### Table 2. An overview of the assumptions made in SimpleBox

Note: Nu alleen nog voor nano, overgenomen van [OECD, 2021](https://one.oecd.org/document/ENV/CBC/MONO(2021)23/En/pdf)\|62-67\|

| **Model Feature**  | **Assumption**                                                                                                                                                                       |
|---------------------------------------|---------------------------------|
| **Compartment**    | \- Spatial resolution (pseudo-3D, conjoined cubic compartments) <br> - Physical media (Water, Air, Soil, Sediment) <br> - Homogeneous distribution of nanomaterial <br> - Well mixed |
| **Transfer**       | \- Pseudo-first order rate processes <br> - Mass Balance                                                                                                                             |
| **Transformation** | \- Pseudo-first order rate processes <br> - Stoke’s Law <br> - Brownian motion                                                                                                       |
| **Substance**      | \- Nanomaterials, particulate matter <br> - Particle size determines physical behaviour                                                                                              |
| **Time**           | \- Steady-state solution of mass balance equation (LTA) <br> - Re-evaluation of model parameters at each timestep for dynamics <br> - Variable time-step that can span years         |

# 2. Technical implementation

## SimpleBox 5.0 is Object Oriented

### What does Object Oriented mean?

To do: tekst met uitleg

![Figure 2. Schematic overview of the SimpleBox Object Oriented stucture](FiguresQualityDocumentation/SimpleBoxObjectOriented.png)

### The need for an object oriented SimpleBox 5.0 in R

The SimpleBox 1.0, 2.0, 3.0 and 4.0 versions are spreadsheet models available in MS Excel.
Over the years the number of boxes increased from 33 for the molecular version to 155 for the version for nano- and microparticles (SimpleBox4Plastics).
The rate constants included in fate matrix A are derived from mathematical equations for physical-chemical processes that express the interaction between the chemical substances and the environment.
The number of such equations in the latest MS Excel version of SimpleBox is over 900.
Consequentially, complex computation processes such as dynamic solving either are not precise, have long run times or require additional R scripts nonetheless.
These problems can be overcome by programming SimpleBox into an object oriented version in R.

## Documentation of SimpleBox features

SimpleBox has multiple features, such as environmental compartments, molecular or particle characteristics, and various environmental processes (Table 3).
The technical implementation of all SimpleBox features is described in R markdown documents, called [vignettes](/vignettes).
These vignettes explain what the feature is, how it is implemented in SimpleBox v5.0, and provide example code.
The vignettes follow the structure of [Schoorl et al. (2015)](https://www.rivm.nl/bibliotheek/rapporten/2015-0161.html), which is the technical description of SimpleBox 4.0.

#### Table 3. List of SimpleBox features and their accompanying vignette

To do: tabel maken

# 3. Description of parameters, variables, input and output

# 4. Evaluation of model functioning

## 4.1 sensitivity analysis

No sensitivity analysis has been performed for SimpleBox version 5.0.
There have been sensitivity analyses performed for previous version of SimpleBox.
Sensitivity analyses of previous versions of SimpleBox are largely applicable to version 5.0.
This is especially the case for previous assessments of version 4.0 (either molecular or nano), as the primary difference between version 4.0 and 5.0 is the program used (Excel and R, respectively).
Version 5.0 has been validated to provide near identical results to version 4.0, see Chapter 4.3.

### Summary of sensitivity analyses of previous versions of SimpleBox

For SimpleBox4nano, the most sensititive parameters are the radius of primary ENP, the emmision to air, and the ENP thermal velocity.

To do: tabel aanvullen, samenvatting van resultaten in tekst

Table x.
Sensitivity analyses performed on previous SimpleBox versions

| SimpleBox version      | Source                                                                                       | Page numbers or chapter |
|-------------------------|------------------|-----------------------------|
| SimpleBox4nano 4.01    | [OECD, 2021](https://one.oecd.org/document/ENV/CBC/MONO(2021)23/En/pdf)                      | 62-67                   |
| SimpleBox 4.0          | [Wang et al., 2020](https://www.sciencedirect.com/science/article/abs/pii/S0048969720310901) | 2.3 and                 |
| SimpleBox4nano Concept | Meesters et al. 2019                                                                         |                         |

## 4.2 uncertainty analysis

No uncertainty analysis has been performed for SimpleBox version 5.0.
There have been uncertainty analyses performed for previous version of SimpleBox.
Sensitivity analyses of previous versions of SimpleBox are largely applicable to version 5.0.
This is especially the case for previous assessments of version 4.0 (either molecular or nano), as the primary difference between version 4.0 and 5.0 is the program used (Excel and R, respectively).
Version 5.0 has been validated to provide near identical results to version 4.0, see Chapter 4.3.

### Summary of uncertainty analyses of previous versions of SimpleBox

To do: tabel aanvullen, samenvatting van resultaten in tekst

Table x.
Uncertainty analyses performed on previous SimpleBox versions

| SimpleBox version      | Source                                                                  | Page numbers or chapter |
|-------------------------|------------------|-----------------------------|
| SimpleBox4nano v.4.01  | [OECD, 2021](https://one.oecd.org/document/ENV/CBC/MONO(2021)23/En/pdf) | 58-61                   |
| SimpleBox4nano Concept | Meesters et.al. 2016                                                    |                         |
|                        | SimpleBox 2.0                                                           | Bakker et al., 2003     |

## 4.3 model validation

### Validation of previous SimpleBox versions

#### Validation of SimpleBox 2.0

SimpleBox 2.0 has been validated by [Bakker et al., 2003](http://hdl.handle.net/10029/9015).
Environmental concentrations of five substances, tetrachloroethylene, lindane, benzo[a]pyrene, fluoranthene and chrysene, are compared to predicted concentrations.
More specifically the monitoring data were used to derive concentration ratios for adjacent compartments, which were compared to modelled steady-state concentration ratios taking uncertainties in the model input parameters into account.
The results indicate that concentration ratios generally do not deviate much more than a factor of ten from 'observed' data.
The discrepancies between the computed and 'observed' ratios of concentrations in the air and soil compartments are much larger, exceeding a factor of thirty.

#### Validation of SimpleBox 4.0

SimpleBox 4.0 has been validated by [Wang et al., 2020](https://www.sciencedirect.com/science/article/abs/pii/S0048969720310901).
Model performance for the air compartment was reasonable as estimated concentrations were generally within a factor of five of measured concentrations.
SimpleBox suggested higher POP concentrations in Arctic oceans than in temperate oceans, contrary to the few measured data.
Discrepancies between estimations and measurements may be attributed to the variability in emission estimates and degradation rates of POPs, representativeness of monitoring data, and a missing snow and ice environmental compartment in SimpleBox.

![Figure x. From Wang et al., 2020: Time series of estimated (solid curves, in pg/m3) and measured concentrations (points, in pg/m3) at different sampling sites for α-HCH in the atmosphere. The red and blue solid curves show the estimated results for the temperate and Arctic climate zone respectively. The red and blue dotted curves show the exponential trend of measured concentrations in the temperate and Arctic climate zone.](https://ars.els-cdn.com/content/image/1-s2.0-S0048969720310901-gr4_lrg.jpg)

## 4.4 Overview of the use of SimpleBox

To do: aanvullen

| Use                                                       | Where/By who           | Type        | Reference                                                                                                                    |
|---------------|------------------------|-------------------|---------------|
| Environmental exposure estimation within EUSES            | ECHA, REACH applicants | Regulatory  | [ECHA, 2012](https://www.rivm.nl/documenten/guidance-on-information-requirements-and-chemical-safety-assessment-chapter-r16) |
| Comparative exposure assessment in Life Cycle Assessments | USEtox                 | Scientific? | [USEtox](https://usetox.org/)                                                                                                |
| Environmenal stock modelling for socio-economic analysis  | RIVM                   | Scientific  |                                                                                                                              |

## 4.5 Fitness for purpose

<!--# Here a discussion of the above sections is needed in comparison of the validation/uncertainty/sensitivty analysis in relation to the application of the model for background estimation of PECs, derivation of Fate Factors and performing stock calulcations for SEA -->

Note: dit blok uit het kwaliteitskader lijkt nogal dubbel.
Weet niet helemaal wat ze nog extra zouden willen.
Hieronder wat in het excelbestand vh kwaliteitskader staat:

\|Er is een algemene beschrijving van model 'fitness for purpose' \|hoofdoverwegingen \* referenties vergelijkbare aanpak/principe/methode\|relatie doel met test \* gevoeligheid \* onzekerheid \* validatie \* gebruik \| betrouwbaarheid \* nauwkeurigheid \* gebruikte data externe wetenschappelijke review\|

# 5. Continuing development

## 5.1

## 5.2 History of SimpleBox

-Timeline of major SB releases, including reference to supporting document.
To do: SB4nano and microplastics toevoegen

| Version        | Year | Software | Reference                                                                                                                                                           |
|----------------|----------------|-------------------|---------------------|
| SimpleBox      | 1986 | ??       | [van de Meent, 1993](https://www.rivm.nl/publicaties/simplebox-a-generic-multimedia-fate-evaluation-model)                                                          |
| SiimpleBox 2.0 | 1996 | Excel    | [Brandes, den Hollander, van de Meent, 1996](https://www.rivm.nl/publicaties/simplebox-20-a-nested-multimedia-fate-model-for-evaluating-environmental-fate-of)      |
| SimpleBox 3.0  | 2004 | Excel    | [den Hollander, van Eijkeren, van de Meent, 2004](https://www.rivm.nl/en/simplebox-30-multimedia-mass-balance-model-for-evaluating-fate-of-chemical-in-environment) |
| SimpleBox 4.0  | 2015 | Excel    | [Schoorl, Hollander, van de Meent, 2015](https://www.rivm.nl/publicaties/simplebox-40-a-multimedia-mass-balance-model-for-evaluating-fate-of-chemical-substances)   |
| 5.0            | 2024 | R        | to be determined                                                                                                                                                    |

# 6. Organisation

Issues can be submitted through GitHub

Contact: simplebox\@rivm.nl

RIVM leads the development in collaboration with others

RIVM team: names?

Institutes that have contributed:

-   Radboud University - Department of ENvironmental sciences

-   Wageningen University - Department of Aquatic Ecology and Water Quality management

-   .UseTox..?.
    ..

# 7. User guidelines

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

\-[Basics for developers](vignettes/Development/BasicsOfDevelopment.md) : This vignette is a good starting point for starting developers.
The underlying structure of the repository is explained here, including the input data.

## Guidance for developers

\-[Basics for developers](vignettes/Development/BasicsOfDevelopment.md) : This vignette is a good starting point for starting developers.
The underlying structure of the repository is explained here, including the input data.

The Development folder details the technical construction of the project and is most suitable for developers.
The vignette [start](/vignettes/Development/start.md) explains the basics of object-oriented modelling and how this is implemented in this repository.
Multiple other vignettes are useful if aiming to develop, such as [CSV-reordering](/vignettes/Development/CSVdata.Rmd), [creating variables](vignettes/Development/FirstVars.Rmd), [creating and checking flows](/vignettes/Development/AirFlow.Rmd), [creating processes](vignettes/Development/processFlow.Rmd) and [testing new variables](/vignettes/Development/testRainDropRadius.Rmd).
- The vignette folder outlines the theoretical implementation of the SimpleBox model, following the structure of Chapter 3 in [Schoorl et al. (2015)](https://www.rivm.nl/bibliotheek/rapporten/2015-0161.html)

## License

\*TODO add license
