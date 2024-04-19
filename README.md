# SimpleBox v4.0

This repository and its supporting repository [SBOO](https://github.com/rivm-syso/SBoo) are an implementation of the [SimpleBox model](https://www.rivm.nl/publicaties/simplebox-40-a-multimedia-mass-balance-model-for-evaluating-fate-of-chemical-substances), that was previously in Excel. SimpleBox (SB) is a multimedia mass balance model of the so-called 'Mackay type'. It simulates environmental fate of chemicals as fluxes (mass flows) between a series of well-mixed boxes of air, water, sediment and soil on regional, continental and global spatial scales. The model is capable of handling chemicals, nanomaterials and plastics.

## Installation

SB is split over two projects. In order to use SBOO you need two projects with the parent folder in common. This repository and the SBOO repository thus need to be stored in the same folder. The working directory of the project should always be set to this folder. More info on the R-servers at RIVM can be found [here](http://wiki.rivm.nl/inwiki/bin/view/StatNMod/RStudio%2BServer).

### Dependencies

Packages needed for both repositories are defined in [requirements](requirements.txt)

## Set-Up

This repository includes several vignettes detailing both the set-up of the [project](/vignettes/Development/Readme.md) and theoretical implementation of the [SB Model](/vignettes/Readme.md).

-   The Development folder details the technical construction of the project and is most suitable for developers. The vignette [start](/vignettes/Development/start.md) explains the basics of object-oriented modelling and how this is implemented in this repository. Multiple other vignettes are useful if aiming to develop, such as [CSV-reordering](/vignettes/Development/CSVdata.Rmd), [creating variables](vignettes/Development/FirstVars.Rmd), [creating and checking flows](/vignettes/Development/AirFlow.Rmd), [creating processes](vignettes/Development/processFlow.Rmd) and [testing new variables](/vignettes/Development/testRainDropRadius.Rmd).
-   The vignette folder outlines the theoretical implementation of the SimpleBox model, following the structure of Chapter 3 in [Schoorl et al. (2015)](https://www.rivm.nl/bibliotheek/rapporten/2015-0161.html)

## License

\*TODO add license
