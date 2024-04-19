---
editor_options: 
  markdown: 
    wrap: 72
---

# Development readme

Jaap Slootweg, Joris Quik 2023/12/04 , Valerie de Rijk 5/4/2024

# Development of SimpleBox object oriented (SBoo)

There are several important conventions takes as basis for development
of SimpleBox in R. This folder contains different examples[^1] and other
help files aimed at an (advanced) user who wants to extend or modify the
current implementation of SBoo.

[^1]: Links are to github documents (.md), but when opening the code in
    R, the .Rmd files can be used directly and when updated or changes
    'knitted' to the md files which are parsed visually on GitHub.

There are two important requirements for SBoo, the algorithms which are
all available in SBoo and the data, which are all in SBooScripts.

## SBoo

Important starting documents to read:

-   Naming convention of files in SBoo/R:
    [AAAreadme.R](https://github.com/rivm-syso/SBoo/blob/main/R/AAAreadme.R "AAAreadme")

-   Basic concepts of object-oriented based modelling:
    [start](/vignettes/Development/start.Rmd)

-   Introduction to variables in SBOO:
    [variables](/vignettes/Development/FirstVars.Rmd)

-   Best practices for debugging:
    [debugging](/vignettes/Development/Debugging.Rmd)

-   Checking histories of flows: 
    [History of a flow](/vignettes/Development/Advective-Flows.md)
