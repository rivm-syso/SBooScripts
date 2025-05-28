Comparison water advection update
================
Anne Hids, Joris Quik
2025-05-27

The advection flow calculations for the water compartments were updated
from the Excel version of SimpleBox. Below the changes are outlined, and
finally a comparison between the k’s of the two version is made.

## Update RainOnFreshwater function

In the previous version of SimpleBox, RainOnFreshwater was set to 0 for
lake compartments. This is resolved by using the same calculation for
lake as was already used for the river compartments.

``` r
RainOnFreshwater <- function (RAINrate, Area, SubCompartName) {
  if (SubCompartName %in% c("river", "lake")) {
    #TODO resolve lake issues in waterflow; for now: old formulas
    if (SubCompartName == "lake"){
      return(0)
    } else {
      # RAINrateToSI is generated from units !
      return(RAINrate * Area)
    }     
  } else    return(NA)
}
```

``` r
RainOnFreshwater <- function (RAINrate, Area, FracROWatComp, SubCompartName) {
  if (SubCompartName %in% c("river", "lake")) {
    # RAINrateToSI is generarted from units !
    return(RAINrate * Area*FracROWatComp)
  } else    return(NA)
}
```

## Update FracROWatComp

This function calculates the area fraction of river and lake of the
total freshwater area at Regional and Continental scales. This is needed
to calculate how much runoff goes from soil to the different water
compartments.

The new function calculates the same as the old function with two
exceptions: -The function is shorter but calculates the same -If the
scale is not Regional or Continental and the SubCompart is not river or
lake, the function returns NA instead of 1 as it did before.

``` r
FracROWatComp <- function(all.landFRAC, all.Matrix, Matrix, SubCompartName, ScaleName) {
  compFrac <- all.landFRAC$landFRAC[all.landFRAC$SubCompart == SubCompartName & all.landFRAC$Scale ==  ScaleName]
  all.landFrac <- as_tibble(all.landFRAC)
  all.Matrix <- as_tibble(all.Matrix)
  mergeddata <- left_join(
    x = all.landFRAC,
    y = all.Matrix,
    by = join_by(SubCompart))

  if ((Matrix == "water") & (ScaleName %in% c("Regional", "Continental"))) {
    # total landfrac of (fresh) water compartments
    waterFrac <- mergeddata |>
      filter(Matrix == "water" & Scale == ScaleName) |>
      summarise(waterFrac = sum(landFRAC, na.rm = TRUE)) |>
      pull(waterFrac)
    return(compFrac / waterFrac)
  } else {
    return(1)
  }
}
```

``` r
FracROWatComp <- function(all.landFRAC, all.Matrix, Matrix, SubCompartName, ScaleName) {
  if ((Matrix == "water") & (ScaleName %in% c("Regional", "Continental"))) {
    compFrac <- all.landFRAC$landFRAC[all.landFRAC$SubCompart == SubCompartName & all.landFRAC$Scale ==  ScaleName]
    mergeddata <- merge(all.landFRAC,all.Matrix)
    waterFrac = sum(mergeddata$landFRAC[mergeddata$Matrix == "water" & mergeddata$Scale ==  ScaleName])
    return(compFrac / waterFrac)
  } else {
    return(NA)
  }
}
```

## Update ContRiver2Reg

For the ‘river’ SubCompart at ‘Continental’ Scale, the flow from
Continental to Regional river is now calculated as:

(sum of all runoff + the sum of all rain on freshwater) \*
dischargefraction between regional and continental scale.

The previously used function can be seen in the chunk below

``` r
x_ContRiver2Reg <- function (ScaleName, SubCompartName, 
                             all.Runoff, RainOnFreshwater, 
                             dischargeFRAC, LakeFracRiver){
  switch (ScaleName,
          "Continental" = {
            switch (SubCompartName,
                    "river" = {            SumRainRunoff <- sum(all.Runoff$Runoff[all.Runoff$Scale == "Continental"])
                    River2sea  <- RainOnFreshwater + SumRainRunoff * (1-dischargeFRAC)
                    Lake2River <- LakeFracRiver * River2sea

                    return((RainOnFreshwater + SumRainRunoff + Lake2River) * dischargeFRAC)
                    },
                    return(NA)
            )
          },
          return(NA)
            )
}
```

``` r
x_ContRiver2Reg <- function (ScaleName, SubCompartName, 
                             all.Runoff, all.RainOnFreshwater, 
                             dischargeFRAC){

  switch (ScaleName,
          "Continental" = {
            switch (SubCompartName,
                    "river" = {
                      SumRainRunoff <- sum(all.Runoff$Runoff[all.Runoff$Scale == ScaleName])+
                        sum(all.RainOnFreshwater$RainOnFreshwater[all.RainOnFreshwater$Scale == ScaleName])

                      return((SumRainRunoff) * dischargeFRAC)
                    },
                    return(NA)
            )
          },
          return(NA)
  )
}
```

## Update LakeOut function

The flow from lake to river at Regional and Continental scale is now
calculated as:

RainOnFreshwater + FracROWatComp\*SumRunoff

``` r
x_LakeOutflow <- function (all.x_RiverDischarge, 
                           all.x_ContRiver2Reg, 
                           LakeFracRiver, 
                           ScaleName){
  x_RiverDischarge <- all.x_RiverDischarge$flow[all.x_RiverDischarge$fromScale==ScaleName]
  if(ScaleName == "Continental"){
    return(LakeFracRiver * x_RiverDischarge)
  } 
  if(ScaleName == "Regional"){
    x_ContRiver2Reg <- all.x_ContRiver2Reg$flow
    return(LakeFracRiver * (x_RiverDischarge + x_ContRiver2Reg))
  } 
  else NA
}
```

``` r
x_LakeOut <- function (RainOnFreshwater,
                           all.Runoff,
                           FracROWatComp,
                       SubCompartName,
                           ScaleName){
  switch (SubCompartName, # if this is coded with if statement it fails as SubCompartName for Arctic is NA
          "lake" = {
            SumRunoff <- sum(all.Runoff$Runoff[all.Runoff$Scale == ScaleName])
            return(RainOnFreshwater + FracROWatComp*SumRunoff)
          },
          NA
  )
}
```

# Change in k values for advection flows

First remove all functions from the global environment to avoid errors

TO DO: fetch development at a certain date instead of most recent
version. This would ensure consequent outcomes of this comparison, no
matter when the script is run.

``` r
library(tidyverse)

# Define branches to test
branches <- c("development", "FLux_work")

# Specify file paths for saving results
result_files <- paste0("results_", branches, ".rds")

# Directory of your Git repository (modify this path to the correct repository location)
script_dir <-getwd()
repo_dir <- file.path(getwd(), "..", "SBoo")
```

As advection processes do not depend on substance variables, we only
need to compare the advection flows for one substance, in this case
1-aminoanthraquinone.

<!-- # ```{R} -->

<!-- # # Select 20 random substances from substances csv -->

<!-- # substances <- read.csv("data/Substances.csv") -->

<!-- # set.seed(123) -->

<!-- # index_substance <- round(runif(20, min=1, max=nrow(substances))) -->

<!-- #  -->

<!-- # # Get names of substances at the selected indeces -->

<!-- # substances <- substances[index_substance, ]   # Subset the rows -->

<!-- # substance_names <- substances$Substance    # Assuming the column for names is 'SubstanceName' -->

<!-- # ``` -->

<!-- # ```{R} -->

<!-- # substance_names <- c("1-aminoanthraquinone", # no class -->

<!-- #                          "1-HYDROXYANTHRAQUINONE", # acid -->

<!-- #                          "1-Hexadecanamine, N,N-dimethyl-", # base -->

<!-- #                          "1-Chloro-2-nitro-propane", # neutral -->

<!-- #                          "Sb(III)", # metal -->

<!-- #                          "microplastic", # microplastic -->

<!-- #                           "nAg_10nm" # particulate -->

<!-- #                           )  -->

<!-- # substances <- read.csv("data/Substances.csv") -->

<!-- # substances <- substances |> -->

<!-- #   filter(Substance %in% substance_names) -->

<!-- # ``` -->

``` r
substance_names <- "1-aminoanthraquinone" 
substances <- read.csv("data/Substances.csv")
substances <- substances |>
  filter(Substance %in% substance_names)
```

``` r
# Switch to the correct Git directory
setwd(repo_dir)

# Checkout the branch
branch <- branches[1]
message("Switching to branch: ", branch)
system(paste("git checkout -f ", branch))
system("git pull", intern = TRUE)  # Ensure the branch is up-to-date
  
setwd(script_dir)

# Overwrite a LakeOut with LakeOutFlow and save
FlowIO <- read.csv("data/FlowIO.csv")
FlowIO <- FlowIO |>
  mutate(FlowName = if_else(FlowName == "x_LakeOut", "x_LakeOutflow", FlowName))

readr::write_excel_csv(FlowIO, file = "data/FlowIO.csv", quote = "needed")
```

``` r
dev_kaas <- data.frame()
  
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  
  if(substance == 'microplastic' | substance == "TRWP"){
    source("baseScripts/initWorld_onlyPlastics.R")
  } else if(cc == "particle"){
    source("baseScripts/initWorld_onlyParticulate.R")
  } else{
    source("baseScripts/initWorld_onlyMolec.R")
  }
  
  kaas <- World$kaas |>
    filter(process == "k_Advection") |>
    mutate(Substance = substance)
  
  dev_kaas <- rbind(dev_kaas, kaas)
}
```

Do the same for the new implementation.

``` r
# Switch to the correct Git directory
setwd(repo_dir)

# Checkout the branch
branch <- branches[2]
message("Switching to branch: ", branch)
system(paste("git checkout -f ", branch))
system("git pull", intern = TRUE)  # Ensure the branch is up-to-date
  
setwd(script_dir)

# Overwrite a LakeOut with LakeOutFlow and save
FlowIO <- read.csv("data/FlowIO.csv")
FlowIO <- FlowIO |>
  mutate(FlowName = if_else(FlowName == "x_LakeOutflow", "x_LakeOut", FlowName))

readr::write_excel_csv(FlowIO, file = "data/FlowIO.csv", quote = "needed")
```

``` r
updated_kaas <- data.frame()
  
for(i in 1:nrow(substances)){
  # Get the substance type
  subst_row <- substances[i, ]
  
  substance <- subst_row$Substance
  cc <- subst_row$ChemClass
  
  if(substance == 'microplastic' | substance == "TRWP"){
    source("baseScripts/initWorld_onlyPlastics.R")
  } else if(cc == "particle"){
    source("baseScripts/initWorld_onlyParticulate.R")
  } else{
    source("baseScripts/initWorld_onlyMolec.R")
  }
  
  kaas <- World$kaas |>
    filter(process == "k_Advection") |>
    mutate(Substance = substance)
  
  updated_kaas <- rbind(updated_kaas, kaas)
}
```

## Compare the k values for each of the substances

``` r
common_cols <- setdiff(intersect(colnames(dev_kaas), colnames(updated_kaas)), "k")

kaas_comparison <- merge(dev_kaas, updated_kaas, by=common_cols, suffixes = c("_Old", "_New"))

kaas_comparison <- kaas_comparison |>
  mutate(diff = k_New-k_Old) |> # If this number is positive, the New_k is higher than the Old_k (higher advection rate with new method)
  mutate(rel_diff = diff/k_New)

changed_kaas <- kaas_comparison |>
  filter(diff != 0) |>
  mutate(full_name = paste0("From ", fromSubCompart, "_", fromScale, " to ", toSubCompart, "_", toScale))
```

``` r
mean_diffs <- kaas_comparison |>
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

ggplot(mean_diffs, mapping = aes(x = toname, y = fromname, color = diff)) + 
  geom_point() + 
  labs(
    title = "Difference between old and new advection k's",
    x = "To",  
    y = "From",  
    color = "Difference"  
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.major = element_line(size = 0.2, color = "gray90"),  
    panel.background = element_blank() 
  )
```

![](Comparison-water-advection-update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->

``` r
ggplot(mean_diffs, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
  geom_point() + 
  labs(
    title = "Relative difference between old and new advection k's",
    x = "To",  
    y = "From",  
    color = "Relative difference"  
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()  
  )
```

![](Comparison-water-advection-update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->
