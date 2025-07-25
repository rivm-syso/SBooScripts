Comparison water advection update
================
Anne Hids, Joris Quik
2025-05-27

The advection flow calculations for the freshwater compartments are
revised using a different implementation of advective flows related to
the lake compartment and some other changes (from v2025.4.0 and the
Excel implementation). Below the changes are outlined, and finally a
comparison between the rate constants (k’s) of the new and old version
is made.

## Update RainOnFreshwater function

In the previous version of SimpleBox, RainOnFreshwater was set to 0 for
lake compartments. This is resolved by using the same calculation for
lake as was already used for the river compartments.

This was the previous function:

``` r
# RainOnFreshwater
# World$fetchData("RainOnFreshwater") # new implementation provides

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

CalcVariable <- World$NewCalcVariable("RainOnFreshwater") # load the old function above
# CalcVariable
# CalcVariable$needVars
# CalcVariable$execute()
old <- World$CalcVar("RainOnFreshwater")
```

The updated function now also adds rain on lake freshwater and replaces
the 0’s for lake water at global scales with NA’s which causes them to
be filtered out automatically.

``` r
RainOnFreshwater <- function (RAINrate, Area, SubCompartName) {
  if (SubCompartName %in% c("river", "lake")) {
    # RAINrateToSI is generarted from units !
    return(RAINrate * Area)
  } else    return(NA)
}

CalcVariable <- World$NewCalcVariable("RainOnFreshwater") # load the old function above
# CalcVariable
# CalcVariable$needVars
# CalcVariable$execute()
World$CalcVar("RainOnFreshwater")
```

    ##         Scale SubCompart old_RainOnFreshwater RainOnFreshwater
    ## 1      Arctic       lake               0.0000               NA
    ## 2 Continental       lake               0.0000        193.43671
    ## 3 Continental      river            2127.8038       2127.80378
    ## 4    Moderate       lake               0.0000               NA
    ## 5    Regional       lake               0.0000         12.68384
    ## 6    Regional      river             139.5222        139.52221
    ## 7      Tropic       lake               0.0000               NA

## Optimisation of FracROWatComp

This function calculates the area fraction of river and lake of the
total freshwater area at Regional and Continental scales. This is needed
to calculate how much runoff goes from soil to the different water
compartments.

The new function calculates the same as the old function with two
exceptions: -The function is shorter -There are NA’s returned instead of
1’s for scales which are not Regional or Continental and the SubCompart
is not river or lake.

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


CalcVariable <- World$NewCalcVariable("FracROWatComp") # load the old function above
# CalcVariable
# CalcVariable$needVars
# CalcVariable$execute()
old <- World$CalcVar("FracROWatComp")
```

``` r
FracROWatComp <- function(all.landFRAC, all.Matrix, Matrix, SubCompartName, ScaleName) {
  # browser()
  
  if ((Matrix == "water") & (ScaleName %in% c("Regional", "Continental"))) {
    
    compFrac <- all.landFRAC$landFRAC[all.landFRAC$SubCompart == SubCompartName & all.landFRAC$Scale == ScaleName]
    mergeddata <- merge(all.landFRAC, all.Matrix)
    waterFrac <- sum(mergeddata$landFRAC[mergeddata$Matrix == "water" & mergeddata$Scale == ScaleName])
    return(compFrac / waterFrac)
    
  } else if ((SubCompartName == "sea") & (ScaleName %in% c("Tropic", "Moderate", "Arctic"))){ 
    return(1)
  }  else
  {
    return(NA)
  }
}

CalcVariable <- World$NewCalcVariable("FracROWatComp") # load the old function above
# CalcVariable
# CalcVariable$needVars
# CalcVariable$execute()
World$CalcVar("FracROWatComp")
```

    ##          Scale         SubCompart old_FracROWatComp FracROWatComp
    ## 1       Arctic   agriculturalsoil        1.00000000            NA
    ## 2       Arctic                air        1.00000000            NA
    ## 3       Arctic         cloudwater        1.00000000            NA
    ## 4       Arctic          deepocean        1.00000000            NA
    ## 5       Arctic freshwatersediment        1.00000000            NA
    ## 6       Arctic               lake        1.00000000            NA
    ## 7       Arctic       lakesediment        1.00000000            NA
    ## 8       Arctic     marinesediment        1.00000000            NA
    ## 9       Arctic        naturalsoil        1.00000000            NA
    ## 10      Arctic          othersoil        1.00000000            NA
    ## 11      Arctic              river        1.00000000            NA
    ## 12      Arctic                sea        1.00000000    1.00000000
    ## 13 Continental   agriculturalsoil        1.00000000            NA
    ## 14 Continental                air        1.00000000            NA
    ## 15 Continental freshwatersediment        1.00000000            NA
    ## 16 Continental               lake        0.08333333    0.08333333
    ## 17 Continental       lakesediment        1.00000000            NA
    ## 18 Continental     marinesediment        1.00000000            NA
    ## 19 Continental        naturalsoil        1.00000000            NA
    ## 20 Continental          othersoil        1.00000000            NA
    ## 21 Continental              river        0.91666667    0.91666667
    ## 22    Moderate   agriculturalsoil        1.00000000            NA
    ## 23    Moderate                air        1.00000000            NA
    ## 24    Moderate         cloudwater        1.00000000            NA
    ## 25    Moderate          deepocean        1.00000000            NA
    ## 26    Moderate freshwatersediment        1.00000000            NA
    ## 27    Moderate               lake        1.00000000            NA
    ## 28    Moderate       lakesediment        1.00000000            NA
    ## 29    Moderate     marinesediment        1.00000000            NA
    ## 30    Moderate        naturalsoil        1.00000000            NA
    ## 31    Moderate          othersoil        1.00000000            NA
    ## 32    Moderate              river        1.00000000            NA
    ## 33    Moderate                sea        1.00000000    1.00000000
    ## 34    Regional   agriculturalsoil        1.00000000            NA
    ## 35    Regional                air        1.00000000            NA
    ## 36    Regional freshwatersediment        1.00000000            NA
    ## 37    Regional               lake        0.08333333    0.08333333
    ## 38    Regional       lakesediment        1.00000000            NA
    ## 39    Regional     marinesediment        1.00000000            NA
    ## 40    Regional        naturalsoil        1.00000000            NA
    ## 41    Regional          othersoil        1.00000000            NA
    ## 42    Regional              river        0.91666667    0.91666667
    ## 43      Tropic   agriculturalsoil        1.00000000            NA
    ## 44      Tropic                air        1.00000000            NA
    ## 45      Tropic         cloudwater        1.00000000            NA
    ## 46      Tropic          deepocean        1.00000000            NA
    ## 47      Tropic freshwatersediment        1.00000000            NA
    ## 48      Tropic               lake        1.00000000            NA
    ## 49      Tropic       lakesediment        1.00000000            NA
    ## 50      Tropic     marinesediment        1.00000000            NA
    ## 51      Tropic        naturalsoil        1.00000000            NA
    ## 52      Tropic          othersoil        1.00000000            NA
    ## 53      Tropic              river        1.00000000            NA
    ## 54      Tropic                sea        1.00000000    1.00000000

## Update ContRiver2Reg

For the ‘river’ SubCompart at ‘Continental’ Scale, the flow from
Continental to Regional river is now calculated as:

(sum of all runoff + the sum of all rain on freshwater) \*
dischargefraction between regional and continental scale.

The previously used function can be seen in the chunk below

``` r
f_MutateHelper(varName = "dischargeFRAC",
               varData = c(0.1,0))
```

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(varName)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(varName))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

    ## Warning in dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame, join_by(toScale == : Detected an unexpected many-to-many relationship between `x` and `y`.
    ## Detected an unexpected many-to-many relationship between `x` and `y`.
    ## Detected an unexpected many-to-many relationship between `x` and `y`.
    ## ℹ Row 1 of `x` matches multiple rows in `y`.
    ## ℹ Row 1 of `y` matches multiple rows in `x`.
    ## ℹ If a many-to-many relationship is expected, set `relationship =
    ##   "many-to-many"` to silence this warning.

    ## Warning in dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame, join_by(toScale == : Detected an unexpected many-to-many relationship between `x` and `y`.
    ## Detected an unexpected many-to-many relationship between `x` and `y`.
    ## ℹ Row 1 of `x` matches multiple rows in `y`.
    ## ℹ Row 48 of `y` matches multiple rows in `x`.
    ## ℹ If a many-to-many relationship is expected, set `relationship =
    ##   "many-to-many"` to silence this warning.

    ## Warning in dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame, join_by(toScale == : Detected an unexpected many-to-many relationship between `x` and `y`.
    ## ℹ Row 1 of `x` matches multiple rows in `y`.
    ## ℹ Row 142 of `y` matches multiple rows in `x`.
    ## ℹ If a many-to-many relationship is expected, set `relationship =
    ##   "many-to-many"` to silence this warning.

    ## Warning in private$Execute(debugAt): input data ignored; not all Volume in
    ## FromAndTo property

    ## Warning in private$Execute(debugAt): input data ignored; not all VertDistance
    ## in FromAndTo property

    ## Warning in private$Execute(debugAt): input data ignored; not all FRorig in
    ## FromAndTo property

    ## Warning in private$Execute(debugAt): input data ignored; not all to.Area in
    ## FromAndTo property

    ## Warning in private$Execute(debugAt): input data ignored; not all from.Area in
    ## FromAndTo property

    ##         Scale dischargeFRAC
    ## 2 Continental           0.1
    ## 4    Regional           0.0

``` r
x_ContRiver2Reg <- function (ScaleName, SubCompartName, 
                             all.RunoffFlow, RainOnFreshwater, 
                             dischargeFRAC, LakeFracRiver){
  switch (ScaleName,
          "Continental" = {
            switch (SubCompartName,
                    "river" = { 
                      SumRainRunoff <- sum(all.RunoffFlow$RunoffFlow[all.RunoffFlow$Scale == "Continental"])
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
# World$fetchData("RunoffFlow")
CalcVariable <- World$NewCalcVariable("x_ContRiver2Reg") # load the old function above
# World$fetchData("dischargeFRAC")

# World$fetchData("dischargeFRAC")

# World$fetchData("Runoff")

old <- World$CalcVar("x_ContRiver2Reg")
```

The updated function is simpler, more straightforward. the outflow
depends purely on the fraction of Rain and Runoff going to the regional
scale.

``` r
x_ContRiver2Reg <- function (ScaleName, SubCompartName, 
                             all.RunoffFlow, all.RainOnFreshwater, 
                             dischargeFRAC){
  
  switch (ScaleName,
          "Continental" = {
            switch (SubCompartName,
                    "river" = {
                      SumRainRunoff <- sum(all.RunoffFlow$RunoffFlow[all.RunoffFlow$Scale == ScaleName])+
                        sum(all.RainOnFreshwater$RainOnFreshwater[all.RainOnFreshwater$Scale == ScaleName])
                      # River2sea  <- RainOnFreshwater + SumRunoff * (1-dischargeFRAC)
                      # Lake2River <- LakeFracRiver * River2sea
                      
                      return((SumRainRunoff) * dischargeFRAC)
                    },
                    return(NA)
            )
          },
          return(NA)
  )
  
}
CalcVariable <- World$NewCalcVariable("x_ContRiver2Reg") # load the old function above
new <- World$CalcVar("x_ContRiver2Reg")

diff <- old$x_ContRiver2Reg - new$x_ContRiver2Reg
diff
```

    ## [1] 170.8046

``` r
# diff/old$x_ContRiver2Reg
# diff/new$x_ContRiver2Reg
```

The difference between the two functions is because in previous
itteration LakeFracRiver was used (World\$fetchData(“LakeFracRiver”)) to
calculate the flow from up stream fresh water (e.g. lake) (w0) to the
major downstream freshwater compartment, e.g. river (w1). This is now
done based on the calculated RunoffFlow going to w0 plus Rain on w0.
Details on the move away from using LakeFracRiver, see below.

## Update LakeOut function

The Lake compartment (w0) is an upstream compartment within a Scale that
has outflow to fresh water (w1). The outflow is dependent on the
fraction runoff going to lake (FracROWatComp) and the direct Rain on
lake fresh water (RainOnFreshwater). The flow from lake to river at
Regional and Continental scale is now calculated as:

RainOnFreshwater + FracROWatComp\*SumRunoff

``` r
x_LakeOutflow <- function(all.x_RiverDischarge, 
                          all.x_ContRiver2Reg, 
                          LakeFracRiver, 
                          ScaleName){
  x_RiverDischarge <- all.x_RiverDischarge$flow[all.x_RiverDischarge$fromScale==ScaleName]
  if(ScaleName == "Continental") {
    return(LakeFracRiver * x_RiverDischarge)
  } 
  if(ScaleName == "Regional"){
    x_ContRiver2Reg <- all.x_ContRiver2Reg$flow
    return(LakeFracRiver * (x_RiverDischarge + x_ContRiver2Reg))
  } 
  else NA
}


CalcVariable <- World$NewCalcVariable("x_LakeOutflow") # load the old function above
old <- World$CalcVar("x_LakeOutflow")
```

``` r
x_LakeOutflow <- function(RainOnFreshwater,
                          all.RunoffFlow,
                          FracROWatComp,
                          SubCompartName,
                          ScaleName){
  switch(SubCompartName, # if this is coded with if statement it fails as SubCompartName for Arctic is NA
         "lake" = {
           SumRunoff <- sum(all.RunoffFlow$RunoffFlow[all.RunoffFlow$Scale == ScaleName])
           return(RainOnFreshwater + FracROWatComp*SumRunoff)
         },
         NA
  )
}

CalcVariable <- World$NewCalcVariable("x_LakeOutflow") # load the old function above
World$CalcVar("x_LakeOutflow")
```

    ##         Scale old_x_LakeOutflow SubCompart x_LakeOutflow
    ## 1 Continental         1897.6141       lake     1757.0501
    ## 2    Regional          559.9459       lake      115.2115

``` r
# World$CalcVar("FracROWatComp")
```

The new implementation results in a lower LakeOut flow because it is not
fixed to a set fraction of the river discharge, but calculated based on
the fraction of Runoff going to lake which is based on the surface are
of the lake versus surface area of the river fresh water compartment.

# Compare new with previous implementation

The below scripts should be run to compare two versions of SBoo. This
uses a function for downloading and ordering the folders needed to
compare.

TO DO: fetch development at a certain date/commit hash instead of most
recent version in a branch. This would ensure consequent outcomes of
this comparison, no matter when the script is run or if a branch is
deleted.

``` r
source("vignettes/Development/Quality control/ComparisonFunctions.R")
# Release = "2025.04.0"
folderpaths <- CompareFilesPrep(Release = "2025.04.0", # specify the tag to compare to
                                Test_SBoo = "FLux_work", # the branch name
                                Test_SBooScripts = "Fluxwork", # the branch name
                                Temp_Folder = "C:/Temp") # test folder
```

As advection processes do not depend on substance variables, we only
need to compare the advection flows for one substance, in this case
1-aminoanthraquinone.

``` r
# substance_names <- "1-aminoanthraquinone" 
substances <- read.csv("data/Substances.csv")
# substances <- substances |>
#   filter(ChemClass != "particle")

substances <- substances |>
  filter(ChemClass == "")

substances <- substances[c(1,2),]
```

First remove all functions from the global environment to avoid errors

## Main version / development branch

``` r
# Save the original working directory for later
original_wd <- getwd()

# Change the wd to the wd of the main branches
setwd(paste0(folderpaths[1], "/SBooScripts"))

# Calculate the kaas 
main_kaas <- data.frame()
# main_solution <- "start"

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
    # filter(process == "k_Advection") |>
    mutate(Substance = substance)
  
  main_kaas <- rbind(main_kaas, kaas)
  
  
  if(World$fetchData("ChemClass") == "particle"){
    emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), 
                            Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  } else {
    emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), 
                            Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: mol/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  }
  
  World$NewSolver("SteadyStateSolver")
  World$Solve(emissions)
  
  solution <- World$Masses()
  names(solution)[names(solution) == "Mass_kg"] <- "main_Mass_kg"
  solution$Substance <- substances$Substance[i]
  
  if(i == 1) main_solution <- solution else {
    main_solution <- merge(main_solution,solution,all = TRUE)}
  
  solution_conc <- World$Concentration()
  names(solution_conc)[names(solution_conc) == "Concentration"] <- "main_Conc."
  solution_conc$Substance <- substances$Substance[i]
  if(i == 1) main_solution_conc <- solution_conc else {
    main_solution_conc <- merge(main_solution_conc,solution_conc,all = TRUE)}
  
  
  
  MB_main <- MB_function1(kaas = as_tibble(World$kaas),
                          Masses =  World$Masses())
  
  if (i == 1) main_MassBalance <- MB_main else {
    main_MassBalance <- merge(main_MassBalance, MB_main, all = TRUE) 
  }
  
  Kmatrix <- World$exportEngineR()
  
  # Strange that there would be a value here
  # Kmatrix["s1TU","w2TU"]
  
  #       to     from
  Kmatrix["w2TU","s1TU"]
  
  # But no value here:
  kaas |> filter(toScale == "Tropic" & toSubCompart == "sea")
  # test to see why below we get a flow from soil to sea
  
  
  Masses_Korder <- solution[match(colnames(Kmatrix),solution$Abbr),]
  CompFlows <-  Kmatrix %*% diag(Masses_Korder$main_Mass_kg)
  colnames(CompFlows) <- row.names(CompFlows)
  CompFlows <-  as.data.frame(CompFlows)
  CompFlows$To <- colnames(CompFlows)
  CompFlows <-
    CompFlows |> as_tibble() |> 
    pivot_longer(-To,
                 names_to = "From",
                 values_to = "Flow_kg/s") |> 
    mutate( Substance = substances$Substance[i] )
  
  if (i == 1) main_CompFlows <- CompFlows else {
    main_CompFlows <- merge(main_CompFlows, CompFlows, all = TRUE) 
  }
  
}
```

| To | From | Substance | Flow_kg/s_main | Flow_kg/s_test | diff | reldiff |
|:---|:---|:---|:---|:---|:---|---:|
| s1AU | aAU | (4-chloro-2-methylphenoxy)acetic acid | 1.2e-01 | 3.6e-01 | 2.4e-01 | 0.4982982 |
| s1AU | aAU | 1-aminoanthraquinone | 3.9e-02 | 1.1e+00 | 1.1e+00 | 0.9334502 |
| s1MU | aMU | (4-chloro-2-methylphenoxy)acetic acid | 1.2e+00 | 2.7e+00 | 1.5e+00 | 0.3777706 |
| s1MU | aMU | 1-aminoanthraquinone | 4.5e-01 | 8.8e+00 | 8.3e+00 | 0.9021398 |
| s1TU | aTU | (4-chloro-2-methylphenoxy)acetic acid | 1.7e-02 | 3.2e-02 | 1.5e-02 | 0.3144034 |
| s1TU | aTU | 1-aminoanthraquinone | 5.2e-03 | 8.0e-02 | 7.4e-02 | 0.8775798 |
| w2AU | s1AU | (4-chloro-2-methylphenoxy)acetic acid | 1.3e-01 | 0.0e+00 | -1.3e-01 | -1.0000000 |
| w2AU | s1AU | 1-aminoanthraquinone | 4.9e-01 | 0.0e+00 | -4.9e-01 | -1.0000000 |
| w2MU | s1MU | (4-chloro-2-methylphenoxy)acetic acid | 4.7e-01 | 0.0e+00 | -4.7e-01 | -1.0000000 |
| w2MU | s1MU | 1-aminoanthraquinone | 1.8e+00 | 0.0e+00 | -1.8e+00 | -1.0000000 |
| w2TU | s1TU | (4-chloro-2-methylphenoxy)acetic acid | 9.5e-01 | 0.0e+00 | -9.5e-01 | -1.0000000 |
| w2TU | s1TU | 1-aminoanthraquinone | 3.6e+00 | 0.0e+00 | -3.6e+00 | -1.0000000 |

| To | From | Substance | Flow_kg/s_main | Flow_kg/s_test | diff | reldiff |
|:---|:---|:---|:---|:---|:---|---:|
| aAU | s1AU | (4-chloro-2-methylphenoxy)acetic acid | 1.3e-10 | 3.8e-10 | 2.5e-10 | 0.4982982 |
| aAU | s1AU | 1-aminoanthraquinone | 2.9e-10 | 8.4e-09 | 8.1e-09 | 0.9334502 |
| aMU | s1MU | (4-chloro-2-methylphenoxy)acetic acid | 1.9e-08 | 4.1e-08 | 2.3e-08 | 0.3777706 |
| aMU | s1MU | 1-aminoanthraquinone | 9.4e-08 | 1.8e-06 | 1.7e-06 | 0.9021398 |
| aTU | s1TU | (4-chloro-2-methylphenoxy)acetic acid | 1.8e-09 | 3.5e-09 | 1.7e-09 | 0.3144034 |
| aTU | s1TU | 1-aminoanthraquinone | 1.1e-08 | 1.7e-07 | 1.6e-07 | 0.8775798 |
| w2AU | s1AU | (4-chloro-2-methylphenoxy)acetic acid | 2.7e-04 | 0.0e+00 | -2.7e-04 | -1.0000000 |
| w2AU | s1AU | 1-aminoanthraquinone | 2.5e-04 | 0.0e+00 | -2.5e-04 | -1.0000000 |
| w2MU | s1MU | (4-chloro-2-methylphenoxy)acetic acid | 6.4e-03 | 0.0e+00 | -6.4e-03 | -1.0000000 |
| w2MU | s1MU | 1-aminoanthraquinone | 6.8e-03 | 0.0e+00 | -6.8e-03 | -1.0000000 |
| w2TU | s1TU | (4-chloro-2-methylphenoxy)acetic acid | 2.6e-04 | 0.0e+00 | -2.6e-04 | -1.0000000 |
| w2TU | s1TU | 1-aminoanthraquinone | 2.4e-04 | 0.0e+00 | -2.4e-04 | -1.0000000 |

## New implementation.

``` r
# Change the wd to the wd of the main branches
setwd(paste0(folderpaths[2], "/SBooScripts"))

test_kaas <- data.frame()
test_solution <- NA
test_MassBalance <- NA
test_CompFlows <- NA

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
  
  #   mutLandFrac <- World$fetchData("landFRAC")
  # mutLandFrac$landFRAC <- c(0.6000, 0.0050, 0.2700, 0.1000, 0.0250, 0.6000, 0.0050, 0.2700, 0.1000, 0.0250)
  # mutLandFrac <-
  #   mutLandFrac |> pivot_longer(cols = "landFRAC",
  #                             names_to = "varName",
  #                             values_to = "Waarde")
  # World$mutateVars(mutLandFrac)
  # World$UpdateDirty("landFRAC")
  
  
  kaas <- World$kaas |>
    # filter(process == "k_Advection") |>
    mutate(Substance = substance)
  
  test_kaas <- rbind(test_kaas, kaas)
  
  if(World$fetchData("ChemClass") == "particle"){
    emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), 
                            Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  } else {
    emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), 
                            Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: mol/s
    emissions <- emissions |>
      mutate(Emis = Emis * 1000 / (365 * 24 * 60 * 60))
  }
  
  World$NewSolver("SteadyStateSolver")
  World$Solve(emissions)
  
  solution <- World$Masses()
  names(solution)[names(solution) == "Mass_kg"] <- "test_Mass_kg"
  solution$Substance <- substances$Substance[i]
  if(i == 1) test_solution <- solution else {
    test_solution <- merge(test_solution,solution,all = TRUE)}
  
  solution_conc <- World$Concentration()
  names(solution_conc)[names(solution_conc) == "Concentration"] <- "test_Conc."
  solution_conc$Substance <- substances$Substance[i]
  if(i == 1) test_solution_conc <- solution_conc else {
    test_solution_conc <- merge(test_solution_conc,solution_conc,all = TRUE)}
  
  MB_test <- MB_function1(kaas = as_tibble(World$kaas),
                          Masses =  World$Masses())
  
  if (i == 1) test_MassBalance <- MB_test else {
    test_MassBalance <- merge(test_MassBalance, MB_test, all = TRUE) 
  }
  
  Kmatrix <- World$exportEngineR()
  Masses_Korder <- solution[match(colnames(Kmatrix),solution$Abbr),]
  
  # Masses_Korder$Abbr == colnames(Kmatrix)
  # Masses_Korder$Abbr == rownames(Kmatrix)
  
  
  
  Kmatrix["s1TU","w2TU"]
  
  Kmatrix["w2TU","s1TU"]
  
  CompFlows <-  Kmatrix %*% diag(Masses_Korder$test_Mass_kg)
  colnames(CompFlows) <- row.names(CompFlows)
  CompFlows <-  as.data.frame(CompFlows)
  CompFlows$To <- colnames(CompFlows)
  CompFlows <-
    CompFlows |> as_tibble() |> 
    pivot_longer(-To,
                 names_to = "From",
                 values_to = "Flow_kg/s") |> 
    mutate( Substance = substances$Substance[i] )
  
  if (i == 1) test_CompFlows <- CompFlows else {
    test_CompFlows <- merge(test_CompFlows, CompFlows, all = TRUE) 
  }
  
  
}

setwd(original_wd)
```

## Compare the two versions

The comparison is done for different outcomes. Starting the the rate
constants, followed by the relative difference in mass/concentration in
each compartment and the flows to and from compartments to further
understand the differences in mass.

### rate constants

``` r
kaas_comparison <- 
  merge(main_kaas |> 
          rename(
            k_Old = k
          ), 
        test_kaas |> 
          rename(
            k_New = k),
  all = TRUE) |>
  mutate(diff = k_New-k_Old) |> # If this number is positive, the New_k is higher than the Old_k (higher advection rate with new method)
  mutate(rel_diff = diff/k_Old) |> as_tibble()

changed_kaas <- 
  kaas_comparison |>
  filter(diff != 0) |>
  mutate(full_name = paste0("From ", fromSubCompart, "_", fromScale, " to ", toSubCompart, "_", toScale)) |> 
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

ggplot(changed_kaas, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
  geom_point(aes(shape = Substance)) + 
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

![](Comparison-water-advection-update_files/figure-gfm/Comparison%20of%20rate%20constants-1.png)<!-- -->

``` r
table_for_display <- changed_kaas |>
  select(fromScale, fromSubCompart, toScale, toSubCompart, Substance, k_Old, k_New, diff, rel_diff) |>
  mutate(diff = format(diff, scientific = TRUE, digits = 2)) |>
  mutate(rel_diff = format(rel_diff, scientific = TRUE, digits = 2))

knitr::kable(table_for_display)
```

It is clear that the rate constants related to flow from lake to river
water are changed the most, up to about 15%.

### mass

``` r
solution_comparison <- 
  merge(main_solution,test_solution) |> 
  mutate(diff = test_Mass_kg-main_Mass_kg) |> 
  mutate(rel_diff = diff/main_Mass_kg)

solution_comparison |>
  filter(rel_diff > 0.001) 
```

    ##    Abbr                             Substance main_Mass_kg test_Mass_kg
    ## 1 sd0CU (4-chloro-2-methylphenoxy)acetic acid     2095.594     2452.512
    ## 2 sd0CU                  1-aminoanthraquinone     1304.824     1527.378
    ## 3 sd0RU (4-chloro-2-methylphenoxy)acetic acid    11069.286    12954.553
    ## 4 sd0RU                  1-aminoanthraquinone    10464.588    12249.447
    ## 5  w0CU (4-chloro-2-methylphenoxy)acetic acid  1046487.224  1224723.137
    ## 6  w0CU                  1-aminoanthraquinone  1584893.254  1855217.570
    ## 7  w0RU (4-chloro-2-methylphenoxy)acetic acid  5528524.790  6470116.221
    ## 8  w0RU                  1-aminoanthraquinone 12711514.130 14879612.826
    ##           diff  rel_diff
    ## 1     356.9179 0.1703183
    ## 2     222.5548 0.1705631
    ## 3    1885.2669 0.1703151
    ## 4    1784.8589 0.1705618
    ## 5  178235.9131 0.1703183
    ## 6  270324.3162 0.1705631
    ## 7  941591.4314 0.1703151
    ## 8 2168098.6959 0.1705618

``` r
# ggplot(solution_comparison, mapping = aes(x = Abbr, y = diff, fill = Substance)) + 
#   geom_bar(stat = "identity", position = "dodge") +
#   labs(
#     title = "Difference between old and new steadystate mass",
#     x = "Compartment",  
#     y = "(Mass_new - Mass_old)"
#   ) +
#   theme(
#     axis.text.x = element_text(angle = 45, hjust = 1), 
#     panel.grid.major = element_line(size = 0.2, color = "gray90"),
#     panel.background = element_blank()  
#   )

ggplot(solution_comparison, mapping = aes(x = Abbr, y = rel_diff, fill = Substance)) + 
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Relative difference between old and new steadystate mass",
    x = "Compartment",  
    y = "(Mass_new-Mass_old)/Mass_old"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()  
  )
```

![](Comparison-water-advection-update_files/figure-gfm/comparison%20of%20mass-1.png)<!-- -->

And concentration.

``` r
con_solution_comparison <- 
  merge(main_solution_conc,test_solution_conc) |> 
  mutate(diff = test_Conc.-main_Conc.) |> 
  mutate(rel_diff = diff/main_Conc.)



ggplot(con_solution_comparison, mapping = aes(x = Abbr, y = rel_diff, fill = Substance)) + 
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Relative difference between old and new steadystate concentrations",
    x = "Compartment",  
    y = "(New-Previous)/Previous"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.major = element_line(size = 0.2, color = "gray90"),
    panel.background = element_blank()  
  )
```

![](Comparison-water-advection-update_files/figure-gfm/comparison%20of%20concentration%20(solution_conc)-1.png)<!-- -->

The longer residence time in lake water (w0), means higher
concentrations in lake sediment and lake water, up to 17.0563106 %.

### Flows

``` r
test_MassBalance$version <- "new"
main_MassBalance$version <- "2025.04.0"

MB_test_main <- rbind(test_MassBalance,main_MassBalance)

# flow overview figure
# ggplot(MB_test_main |> 
#          mutate(Trans_from = -1*Trans_from,
#                 Removal_kg_s = -1*Removal_kg_s) |> 
#          pivot_longer(!c(Compartment,Substance,version),
#                       names_to = "Flow",
#                       values_to = "Mass flow (kg/s)") , 
#        aes(x = Compartment, y = `Mass flow (kg/s)`, fill = Flow)) +
#   geom_bar(stat = "identity", position = "stack") +
#   facet_wrap(~Substance*version) +
#   theme_minimal() +
#   theme(
#     axis.text.x = element_text(angle = 90, vjust = 0.5),
#     panel.grid.major.y = element_line(color = "grey80", size = 0.7),
#     panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
#   ) +
#   scale_y_continuous(breaks = scales::extended_breaks(20))

MB_test_main_wide <-
  MB_test_main |> pivot_wider(names_from = version, values_from =  c(Trans_to,   Trans_from, Emission_kg_s, Removal_kg_s,Diff_Flows)) |> 
  mutate(reldiff_from = (Trans_from_new-Trans_from_2025.04.0)/Trans_from_2025.04.0,
         reldiff_to = (Trans_to_new-Trans_to_2025.04.0)/Trans_to_2025.04.0,
         reldiff_removal = (Removal_kg_s_new-Removal_kg_s_2025.04.0)/Removal_kg_s_2025.04.0)

ggplot(MB_test_main_wide |> 
         pivot_longer(cols = c(reldiff_from, reldiff_to, reldiff_removal),
                      names_to = "Flow type",
                      values_to = "RelDiffFlow") |> 
         select(Compartment, Substance, `Flow type`, RelDiffFlow), 
       aes(x = Compartment, y = RelDiffFlow, fill = `Flow type`)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Substance) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.major.y = element_line(color = "grey80", size = 0.7),
    panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
  ) +
  scale_y_continuous(breaks = scales::extended_breaks(20))
```

![](Comparison-water-advection-update_files/figure-gfm/Flows-1.png)<!-- -->

``` r
# test_CompFlows$version <- "new"
# main_CompFlows$version <- "2025.04.0"
# sum(main_CompFlows$`Flow_kg/s_main`) - sum(test_CompFlows$`Flow_kg/s_test`)


CompFlowsDiff <- 
  merge(main_CompFlows |> 
  rename(`Flow_kg/s_main` = `Flow_kg/s`), 
         test_CompFlows |> 
  rename(`Flow_kg/s_test` = `Flow_kg/s`)) |> 
  mutate(diff = `Flow_kg/s_test`-`Flow_kg/s_main`,
         reldiff = (`Flow_kg/s_test`-`Flow_kg/s_main`)/abs(`Flow_kg/s_main`+`Flow_kg/s_test`)) |> 
  filter(diff != 0,
         `Flow_kg/s_main` > 0,
         abs(reldiff)>0.0001)

ggplot(CompFlowsDiff |> 
         mutate(FlowName = paste0(From,"->",To)), mapping = aes(x = FlowName, y = reldiff, color = Substance)) + 
  geom_jitter() + 
  labs(
    title = "Relative difference between old and new flow's",
    x = "To",  
    y = "From",  
    color = "Relative difference"  
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )
```

![](Comparison-water-advection-update_files/figure-gfm/Flows-2.png)<!-- -->

``` r
ggplot(CompFlowsDiff, mapping = aes(x = To, y = From, color = reldiff)) + 
  geom_point(aes(shape = Substance)) + 
  labs(
    title = "Relative difference between old and new flow's",
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

![](Comparison-water-advection-update_files/figure-gfm/Flows-3.png)<!-- -->

``` r
table_for_display <- CompFlowsDiff |>
  filter(abs(reldiff)>0.001) |>
  mutate(diff = format(diff, scientific = TRUE, digits = 2),
         # rel_diff = format(rel_diff, scientific = TRUE, digits = 2),
         `Flow_kg/s_main` = format(`Flow_kg/s_main`, scientific = TRUE, digits = 2),
         `Flow_kg/s_test` = format(`Flow_kg/s_test`, scientific = TRUE, digits = 2))

knitr::kable(table_for_display)
```

| To | From | Substance | Flow_kg/s_main | Flow_kg/s_test | diff | reldiff |
|:---|:---|:---|:---|:---|:---|---:|
| aCU | w0CU | (4-chloro-2-methylphenoxy)acetic acid | 6.5e-10 | 7.6e-10 | 1.1e-10 | 0.0784762 |
| aCU | w0CU | 1-aminoanthraquinone | 4.5e-09 | 5.3e-09 | 7.7e-10 | 0.0785801 |
| aCU | w1CU | (4-chloro-2-methylphenoxy)acetic acid | 9.2e-09 | 9.1e-09 | -9.5e-11 | -0.0051849 |
| aCU | w1CU | 1-aminoanthraquinone | 6.4e-08 | 6.3e-08 | -6.6e-10 | -0.0051856 |
| aRU | w0RU | (4-chloro-2-methylphenoxy)acetic acid | 3.4e-09 | 4.0e-09 | 5.8e-10 | 0.0784748 |
| aRU | w0RU | 1-aminoanthraquinone | 3.6e-08 | 4.2e-08 | 6.1e-09 | 0.0785796 |
| aRU | w1RU | (4-chloro-2-methylphenoxy)acetic acid | 1.4e-07 | 1.4e-07 | -1.3e-09 | -0.0047937 |
| aRU | w1RU | 1-aminoanthraquinone | 9.2e-07 | 9.1e-07 | -9.0e-09 | -0.0049203 |
| aRU | w2RU | (4-chloro-2-methylphenoxy)acetic acid | 2.2e-09 | 2.2e-09 | -2.1e-11 | -0.0047889 |
| aRU | w2RU | 1-aminoanthraquinone | 1.5e-08 | 1.5e-08 | -1.4e-10 | -0.0049158 |
| sd0CU | w0CU | (4-chloro-2-methylphenoxy)acetic acid | 3.1e-04 | 3.6e-04 | 5.2e-05 | 0.0784762 |
| sd0CU | w0CU | 1-aminoanthraquinone | 4.4e-04 | 5.2e-04 | 7.6e-05 | 0.0785801 |
| sd0RU | w0RU | (4-chloro-2-methylphenoxy)acetic acid | 1.6e-03 | 1.9e-03 | 2.8e-04 | 0.0784748 |
| sd0RU | w0RU | 1-aminoanthraquinone | 3.6e-03 | 4.2e-03 | 6.1e-04 | 0.0785796 |
| sd1CU | w1CU | (4-chloro-2-methylphenoxy)acetic acid | 5.8e-03 | 5.7e-03 | -6.0e-05 | -0.0051849 |
| sd1CU | w1CU | 1-aminoanthraquinone | 7.1e-03 | 7.0e-03 | -7.3e-05 | -0.0051856 |
| sd1RU | w1RU | (4-chloro-2-methylphenoxy)acetic acid | 8.7e-02 | 8.6e-02 | -8.3e-04 | -0.0047937 |
| sd1RU | w1RU | 1-aminoanthraquinone | 1.0e-01 | 1.0e-01 | -1.0e-03 | -0.0049203 |
| sd2RU | w2RU | (4-chloro-2-methylphenoxy)acetic acid | 1.1e-03 | 1.1e-03 | -1.1e-05 | -0.0047889 |
| sd2RU | w2RU | 1-aminoanthraquinone | 1.5e-03 | 1.5e-03 | -1.5e-05 | -0.0049158 |
| w0CU | sd0CU | (4-chloro-2-methylphenoxy)acetic acid | 3.0e-04 | 3.5e-04 | 5.1e-05 | 0.0784762 |
| w0CU | sd0CU | 1-aminoanthraquinone | 4.4e-04 | 5.1e-04 | 7.5e-05 | 0.0785801 |
| w0RU | sd0RU | (4-chloro-2-methylphenoxy)acetic acid | 1.6e-03 | 1.9e-03 | 2.7e-04 | 0.0784748 |
| w0RU | sd0RU | 1-aminoanthraquinone | 3.5e-03 | 4.1e-03 | 6.0e-04 | 0.0785796 |
| w1CU | sd1CU | (4-chloro-2-methylphenoxy)acetic acid | 5.7e-03 | 5.6e-03 | -5.9e-05 | -0.0051849 |
| w1CU | sd1CU | 1-aminoanthraquinone | 7.0e-03 | 6.9e-03 | -7.2e-05 | -0.0051856 |
| w1CU | w0CU | (4-chloro-2-methylphenoxy)acetic acid | 2.5e-03 | 2.5e-03 | -3.9e-05 | -0.0079144 |
| w1CU | w0CU | 1-aminoanthraquinone | 3.8e-03 | 3.7e-03 | -5.9e-05 | -0.0078098 |
| w1RU | sd1RU | (4-chloro-2-methylphenoxy)acetic acid | 8.5e-02 | 8.4e-02 | -8.1e-04 | -0.0047937 |
| w1RU | sd1RU | 1-aminoanthraquinone | 1.0e-01 | 1.0e-01 | -9.9e-04 | -0.0049203 |
| w1RU | w0RU | (4-chloro-2-methylphenoxy)acetic acid | 1.3e-02 | 1.3e-02 | -2.1e-04 | -0.0079158 |
| w1RU | w0RU | 1-aminoanthraquinone | 3.0e-02 | 3.0e-02 | -4.7e-04 | -0.0078104 |
| w2RU | sd2RU | (4-chloro-2-methylphenoxy)acetic acid | 1.1e-03 | 1.1e-03 | -1.1e-05 | -0.0047889 |
| w2RU | sd2RU | 1-aminoanthraquinone | 1.5e-03 | 1.5e-03 | -1.5e-05 | -0.0049158 |
| w2RU | w2CU | (4-chloro-2-methylphenoxy)acetic acid | 3.8e-04 | 3.9e-04 | 3.4e-06 | 0.0044306 |
| w2RU | w2CU | 1-aminoanthraquinone | 5.3e-04 | 5.3e-04 | 4.6e-06 | 0.0043103 |

### Mass balance

``` r
ggplot(rbind(main_MassBalance,test_MassBalance), 
       aes(x = Compartment, y = Diff_Flows, fill = Substance)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~version) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    panel.grid.major.y = element_line(color = "grey80", size = 0.7),
    panel.grid.minor.y = element_line(color = "grey90", size = 0.5)
  ) +
  scale_y_continuous(breaks = scales::extended_breaks(20))
```

![](Comparison-water-advection-update_files/figure-gfm/Mass%20balance%20check-1.png)<!-- -->

From the mass balance test (flows into and out of a compartment should
be in balance (sum = 0)) it can be seen that there are some much larger
differences in the mass balance of the previous release “2025.04.0”.
This is mainly due to small tweaks in the solver by lowering stol
variable in rootSolve::runsteady. In next release we might also change
to rootSolve::steady. See SteadyStateSolver2.
