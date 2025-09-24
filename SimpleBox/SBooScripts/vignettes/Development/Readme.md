Development of SimpleBox object oriented (SBoo)
================
2025-03-27

There are several important conventions taken as basis for development
of SimpleBox in R. This folder contains different examples[^1] and other
help files aimed at an (advanced) user who wants to extend or modify the
current implementation of SBoo.

## Important starting documents to read:

- [Getting-Started](/vignettes/Getting-started.md) : Although not in
  this folder, before starting to develop it’s wise to understand how SB
  will be used by most users. In this vignette a default calculation is
  explained.
- [Basics for developers](/vignettes/Development/BasicsOfDevelopment.md)
  : This vignette is a good starting point for starting developers. The
  underlying structure of the repository is explained here, including
  the input data.
- [Quality assessment of
  SBoo](/vignettes/Development/QualityDocumentation.md "RIVM quality document")
  with relevant information using the RIVM quality framework “Quality
  and Transparancy of Models”.
- Verification vignette’s in the [Quality Control
  folder](/vignettes/Development/Quality%20control). For now these are
  based on a comparison with the Excel version of Excel. This will be
  updated in the future, see [Issue
  207](https://github.com/rivm-syso/SBoo/issues/207).

All other vignettes are useful for their own specific focus.

[^1]: Links are to github documents (.md), but when opening the code in
    R, the .Rmd files can be used directly and when updated or changes
    ‘knitted’ to the md files which are parsed visually on GitHub.
