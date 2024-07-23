Molecular verification
================
Anne Hids
2024-07-23

*This vignettes demonstrates the verification process of the molecular
version of Simplebox. First, the k’s are compared between R and excel,
and consequently the steady state masses are compared. This is done for
5 molecular substances; each of a different chemical class (no class,
acid, base, neutral and metal).*

First, the world needs to be initialized for a substance.

``` r
# Create a list with the names of substances
Potential_substances <- c("1-aminoanthraquinone", # no class
                          "1-HYDROXYANTHRAQUINONE", # acid
                          "1-Hexadecanamine, N,N-dimethyl-", # base
                          "1-Chloro-2-nitro-propane", # neutral
                          "Sb(III)" # metal
                          ) 
              
substance <- Potential_substances[1]

source("baseScripts/initWorld_onlyMolec.R")
```

![](Molecular_verification_files/figure-gfm/Plot%20diagonal%20differences-1.png)<!-- -->![](Molecular_verification_files/figure-gfm/Plot%20diagonal%20differences-2.png)<!-- -->

    ## Warning in scale_color_gradient(low = "green", high = "red", trans = "log10"):
    ## log-10 transformation introduced infinite values.

![](Molecular_verification_files/figure-gfm/Plot%20k%20differences-1.png)<!-- -->![](Molecular_verification_files/figure-gfm/Plot%20k%20differences-2.png)<!-- -->

    ## # A tibble: 0 × 8
    ## # ℹ 8 variables: from <chr>, to <chr>, k_R <dbl>, fromto_R <chr>,
    ## #   k_Excel <dbl>, fromto_Excel <chr>, diff <dbl>, relDif <dbl>

    ## # A tibble: 0 × 8
    ## # ℹ 8 variables: from <chr>, to <chr>, k_R <dbl>, fromto_R <chr>,
    ## #   k_Excel <dbl>, fromto_Excel <chr>, diff <dbl>, relDif <dbl>

``` r
lake <- kaas |>
  filter(fromSubCompart == "lake") |>
  filter(toSubCompart == "lake")

lake2 <- kaas |>
  filter(fromSubCompart == "lake") |>
  filter(fromScale == "Continental")
# The relative difference in lake removal rate is caused by lake sedimentation
# being included in R but not in excel.

# To make an accurate comparison between R and excel, the test variable was used 
# to exclude flows to lake sediment in k_Sedimentation and k_Adsorption.
```

``` r
soil <- kaas |>
  filter(fromSubCompart == "agriculturalsoil") |>
  filter(toSubCompart == "agriculturalsoil") |>
  filter(fromScale == "Continental")

# If there is a slight difference in diagonal k's between excel and R, the difference 
# is caused by the input kdegs. If there are input kdegs for air/soil/sediment 
# (so they are not calculated using KdegDorC), these values have two decimals in R
# but more decimals in excel. This can cause relative differences between the k's
# that are slightly larger than the treshold value of 0.001. 

# This was tested by using the rounded kdeg value as input in excel and comparing
# the resulting k manually to the k in R. 
```

``` r
# Get the kaas from soil to air and see what processes are involved
airsoil <- kaas |>
  filter(fromScale == "Regional") |>
  filter(toSubCompart == "agriculturalsoil" | fromSubCompart == "othersoil") |>
  filter(fromSubCompart == "air")

# To calculate the Gasabs from air to soil, FRorig_spw for natural soil (and freshwater) was used also for other and agricultural soil (and seawater) 
# in excel. 
# In R however, the gasabs is calculated using the FRorig_spw for each specific soil type. By using the 'Test' variable, it was
# possible to temporarly change the FRorig_spw and FRorig in R to the value used in Excel. This fixed the large relative difference for this
# flux between excel and R. Conclusion: GASABS (used to calculate k_Adsorption) in R is calculated specifically for each 
# subcompartment, while in excel this variable is only calculated once for soil and once for water.  
```

``` r
resus <- kaas |>
  filter(from == "sd2C") |>
  filter(to == "w2C") 

# The processes involved are resuspension and desorption.

# Get the vertical distance of marinesediment at continental scale
VD <- World$fetchData("VertDistance") |>
  filter(Scale == "Continental") |>
  filter(SubCompart == "marinesediment")

# Multiply the kaas by VD to be able to compare them to excel
resus <- resus |>
  mutate(mult_kaas = k*VD$VertDistance)

# Desorption is more or less the same in excel as in R, there is a larger difference in resuspension. 

# There was a mistake in Excel: Netsedrate for continental seawater was set to 0, while this should have been 2.74*10^-11


# The Kacompw differs slightly from the kacompw in excel

#World$moduleList[["k_Desorption"]]$execute(debugAt = list())
```

``` r
# The advection differences between R and Excel were caused by different TotalArea in excel than R for the regional and continental scales. It looked like the values in ScaleSheet.csv were rounded, while the values in R were not. This problem was solved by changing the TotalArea values in ScaleSheet.csv to the values used in Excel and Hollander et al. (2015).
```

``` r
# Get kaas from water to sediment

w2s <- kaas |>
  filter(from == "w1C") |>
  filter(to == "sd1C")

# Get the vertical distance of marinesediment at continental scale
VD <- World$fetchData("VertDistance") |>
  filter(Scale == "Continental") |>
  filter(SubCompart == "freshwatersediment")

# Multiply the kaas by VD to be able to compare them to excel
w2s <- w2s |>
  mutate(mult_kaas = k*VD$VertDistance)

# The reason that the k's from w to sd are not the same in R as in excel is that the settling velocities are different, 
# because of a difference in calculation. In excel, the settling velocity is calculated as 2.5/(24*3600). In R, the 
# settling velocity is calculated using a function. 

# By using the test variable it was possible to temporarily use the same function for settling velocity in R as in excel. This
# solved the differences. 
```

``` r
# Get the kaas from air to lake

tolake <- kaas |>
  filter(fromSubCompart == "air") |>
  filter(toSubCompart == "lake") |>
  filter(fromScale == "Continental")

# Processes involved are adsorption and deposition

# Convert the k values in R so that they are the same as in Excel for comparison

# Get the areafrac lake
land <- World$fetchData("AreaLand") |>
  filter(Scale == "Continental")

sea <- World$fetchData("AreaSea") |>
  filter(Scale == "Continental")

area <- World$fetchData("Area") |>
  filter(Scale == "Continental") |>
  filter(SubCompart == "lake")

AreaFRAClake <- area$Area/(land$AreaLand+sea$AreaSea)

tolake <- tolake |>
  mutate(k_e = k/AreaFRAClake)

# k_Adsorption is exactly the same in R as in Excel, k_Deposition is slightly different

#World$moduleList[["Kaerw"]]$execute(debugAt = list())
```

``` r
library(stringi)

World$NewSolver("SB1Solve")

emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000) ) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(MW*365*24*60*60))

SSsolve.R <- World$Solve(emissions)
```

    ## Warning in private$solver$PrepKaasM(): 12 k values equal to 0; removed for
    ## solver

``` r
SSsolve.excel <- read.xlsx(SBExcelName,
                             sheet=11,
                             colNames=TRUE,
                             rows=c(44,45))

SSsolve.excel <- SSsolve.excel |>
  select(-c(STEADY.STATE, X2)) |>
  pivot_longer(names_to = "Abbr", values_to = "EqMass", cols = everything()) 

SSsolve.R <- SSsolve.R |> mutate(Abbr =  paste0(accronym_map[SubCompart], 
                            accronym_map2[Scale])) |>
  mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
  mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
  mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
  group_by(Scale, SubCompart, Species, Abbr) |>
  summarise(EqMass = sum(EqMass))

merged_SS_SB1 <- merge(SSsolve.R, SSsolve.excel, by="Abbr", suffixes = c(".R", ".Excel")) |>
  mutate(absdiff = EqMass.R-EqMass.Excel) |>
  mutate(reldiff = absdiff/EqMass.R)

print("Difference in emissions between R and Excel")
```

    ## [1] "Difference in emissions between R and Excel"

``` r
knitr::kable(merged_SS_SB1, format="markdown")
```

| Abbr | Scale       | SubCompart         | Species |     EqMass.R | EqMass.Excel |       absdiff |   reldiff |
|:-----|:------------|:-------------------|:--------|-------------:|-------------:|--------------:|----------:|
| aA   | Arctic      | air                | Unbound | 3.591242e+02 | 3.591310e+02 | -6.813300e-03 | -1.90e-05 |
| aC   | Continental | air                | Unbound | 6.707185e+04 | 6.707302e+04 | -1.165817e+00 | -1.74e-05 |
| aM   | Moderate    | air                | Unbound | 8.543227e+03 | 8.543441e+03 | -2.139318e-01 | -2.50e-05 |
| aR   | Regional    | air                | Unbound | 8.086733e+04 | 8.086809e+04 | -7.681820e-01 | -9.50e-06 |
| aT   | Tropic      | air                | Unbound | 5.140830e+02 | 5.141005e+02 | -1.753260e-02 | -3.41e-05 |
| s1C  | Continental | naturalsoil        | Unbound | 1.094862e+06 | 1.094893e+06 | -3.074297e+01 | -2.81e-05 |
| s1R  | Regional    | naturalsoil        | Unbound | 2.497622e+06 | 2.497652e+06 | -3.034130e+01 | -1.21e-05 |
| s2C  | Continental | agriculturalsoil   | Unbound | 5.072990e+06 | 5.073132e+06 | -1.424787e+02 | -2.81e-05 |
| s2R  | Regional    | agriculturalsoil   | Unbound | 6.151982e+07 | 6.151995e+07 | -1.346990e+02 | -2.20e-06 |
| s3C  | Continental | othersoil          | Unbound | 4.055044e+05 | 4.055158e+05 | -1.138628e+01 | -2.81e-05 |
| s3R  | Regional    | othersoil          | Unbound | 9.250451e+05 | 9.250563e+05 | -1.123752e+01 | -1.21e-05 |
| sd1C | Continental | freshwatersediment | Unbound | 8.627765e+04 | 8.628225e+04 | -4.602324e+00 | -5.33e-05 |
| sd1R | Regional    | freshwatersediment | Unbound | 1.245849e+06 | 1.245889e+06 | -3.959457e+01 | -3.18e-05 |
| sd2C | Continental | marinesediment     | Unbound | 5.977588e+04 | 5.977728e+04 | -1.400223e+00 | -2.34e-05 |
| sd2R | Regional    | marinesediment     | Unbound | 1.946351e+04 | 1.946309e+04 |  4.151897e-01 |  2.13e-05 |
| w0C  | Continental | lake               | Unbound | 7.114195e+06 | 7.114396e+06 | -2.011646e+02 | -2.83e-05 |
| w0R  | Regional    | lake               | Unbound | 5.705913e+07 | 5.705933e+07 | -2.019425e+02 | -3.50e-06 |
| w1C  | Continental | river              | Unbound | 3.036373e+06 | 3.036450e+06 | -7.681023e+01 | -2.53e-05 |
| w1R  | Regional    | river              | Unbound | 4.384522e+07 | 4.384539e+07 | -1.637763e+02 | -3.70e-06 |
| w2A  | Arctic      | sea                | Unbound | 1.102121e+08 | 1.102130e+08 | -8.475663e+02 | -7.70e-06 |
| w2C  | Continental | sea                | Unbound | 1.430368e+08 | 1.430378e+08 | -1.029441e+03 | -7.20e-06 |
| w2M  | Moderate    | sea                | Unbound | 1.403230e+08 | 1.403241e+08 | -1.077484e+03 | -7.70e-06 |
| w2R  | Regional    | sea                | Unbound | 2.328601e+06 | 2.328609e+06 | -8.448923e+00 | -3.60e-06 |
| w2T  | Tropic      | sea                | Unbound | 1.537175e+08 | 1.537186e+08 | -1.185858e+03 | -7.70e-06 |
| w3A  | Arctic      | deepocean          | Unbound | 2.701980e+09 | 2.702001e+09 | -2.077898e+04 | -7.70e-06 |
| w3M  | Moderate    | deepocean          | Unbound | 4.104167e+09 | 4.104198e+09 | -3.152051e+04 | -7.70e-06 |
| w3T  | Tropic      | deepocean          | Unbound | 4.962769e+09 | 4.962807e+09 | -3.826256e+04 | -7.70e-06 |

``` r
#Diff per "to" compartment
ggplot(merged_SS_SB1, aes (x = Abbr, y = reldiff)) +
  geom_boxplot() +
  ggtitle(paste0("Relative differences between steady state masses in excel and R (SB1solve) - ", substance)) +
  geom_hline(yintercept = 0.001, color="red") +
  geom_hline(yintercept = -0.001, color="red") 
```

![](Molecular_verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SB1Solve-1.png)<!-- -->

``` r
sum(merged_SS_SB1$absdiff)
```

    ## [1] -95762.78

``` r
sum(merged_SS_SB1$EqMass.R)
```

    ## [1] 12502672958

``` r
sum(merged_SS_SB1$EqMass.Excel)
```

    ## [1] 12502768721

``` r
lakenames <- data.frame(SubCompart = c("lakesediment", "lakesediment"), Scale = c("Regional", "Continental"), Abbr = c("sd0R", "sd0C"), Species = c("Unbound", "Unbound"))

names <- SSsolve.R |>
  select(SubCompart, Scale, Abbr, Species) 

names <- rbind(names, lakenames)
```

``` r
World$NewSolver("SBsteady")

SSsolve.R <- World$Solve(emissions)
```

    ## Warning in private$solver$PrepKaasM(): 12 k values equal to 0; removed for
    ## solver

``` r
SSsolve.excel <- read.xlsx(SBExcelName,
                             sheet=11,
                             colNames=TRUE,
                             rows=c(44,45))

SSsolve.excel <- SSsolve.excel |>
  select(-c(STEADY.STATE, X2)) |>
  pivot_longer(names_to = "Abbr", values_to = "EqMass", cols = everything()) 

SSsolve.R <- SSsolve.R |> mutate(Abbr =  paste0(accronym_map[SubCompart], 
                            accronym_map2[Scale])) |>
  mutate(SubCompart = str_replace(SubCompart, "lakesediment", "lake")) |>
  mutate(Abbr = str_replace(Abbr, "sd0R", "w0R")) |>
  mutate(Abbr = str_replace(Abbr, "sd0C", "w0C")) |>
  group_by(Scale, SubCompart, Species, Abbr) |>
  summarise(EqMass = sum(EqMass))

merged_SS_steady <- merge(SSsolve.R, SSsolve.excel, by="Abbr", suffixes = c(".R", ".Excel")) |>
  mutate(absdiff = EqMass.R-EqMass.Excel) |>
  mutate(reldiff =absdiff/EqMass.R)

print("Difference in emissions between R and Excel")
```

    ## [1] "Difference in emissions between R and Excel"

``` r
knitr::kable(merged_SS_steady, format="markdown")
```

| Abbr | Scale       | SubCompart         | Species |     EqMass.R | EqMass.Excel |       absdiff |    reldiff |
|:-----|:------------|:-------------------|:--------|-------------:|-------------:|--------------:|-----------:|
| aA   | Arctic      | air                | Unbound | 3.591241e+02 | 3.591310e+02 | -6.897700e-03 | -0.0000192 |
| aC   | Continental | air                | Unbound | 6.707185e+04 | 6.707302e+04 | -1.165916e+00 | -0.0000174 |
| aM   | Moderate    | air                | Unbound | 8.543226e+03 | 8.543441e+03 | -2.152079e-01 | -0.0000252 |
| aR   | Regional    | air                | Unbound | 8.086733e+04 | 8.086809e+04 | -7.681837e-01 | -0.0000095 |
| aT   | Tropic      | air                | Unbound | 5.140733e+02 | 5.141005e+02 | -2.721270e-02 | -0.0000529 |
| s1C  | Continental | naturalsoil        | Unbound | 1.094862e+06 | 1.094893e+06 | -3.074459e+01 | -0.0000281 |
| s1R  | Regional    | naturalsoil        | Unbound | 2.497622e+06 | 2.497652e+06 | -3.034135e+01 | -0.0000121 |
| s2C  | Continental | agriculturalsoil   | Unbound | 5.072990e+06 | 5.073132e+06 | -1.424863e+02 | -0.0000281 |
| s2R  | Regional    | agriculturalsoil   | Unbound | 6.151982e+07 | 6.151995e+07 | -1.346991e+02 | -0.0000022 |
| s3C  | Continental | othersoil          | Unbound | 4.055044e+05 | 4.055158e+05 | -1.138689e+01 | -0.0000281 |
| s3R  | Regional    | othersoil          | Unbound | 9.250451e+05 | 9.250563e+05 | -1.123754e+01 | -0.0000121 |
| sd1C | Continental | freshwatersediment | Unbound | 8.627765e+04 | 8.628225e+04 | -4.602505e+00 | -0.0000533 |
| sd1R | Regional    | freshwatersediment | Unbound | 1.245849e+06 | 1.245889e+06 | -3.959498e+01 | -0.0000318 |
| sd2C | Continental | marinesediment     | Unbound | 5.949637e+04 | 5.977728e+04 | -2.809141e+02 | -0.0047215 |
| sd2R | Regional    | marinesediment     | Unbound | 1.946344e+04 | 1.946309e+04 |  3.474304e-01 |  0.0000179 |
| w0C  | Continental | lake               | Unbound | 7.114195e+06 | 7.114396e+06 | -2.012287e+02 | -0.0000283 |
| w0R  | Regional    | lake               | Unbound | 5.705913e+07 | 5.705933e+07 | -2.023654e+02 | -0.0000035 |
| w1C  | Continental | river              | Unbound | 3.036373e+06 | 3.036450e+06 | -7.681659e+01 | -0.0000253 |
| w1R  | Regional    | river              | Unbound | 4.384522e+07 | 4.384539e+07 | -1.637908e+02 | -0.0000037 |
| w2A  | Arctic      | sea                | Unbound | 1.070065e+08 | 1.102130e+08 | -3.206443e+06 | -0.0299649 |
| w2C  | Continental | sea                | Unbound | 1.423686e+08 | 1.430378e+08 | -6.692221e+05 | -0.0047006 |
| w2M  | Moderate    | sea                | Unbound | 1.368469e+08 | 1.403241e+08 | -3.477126e+06 | -0.0254089 |
| w2R  | Regional    | sea                | Unbound | 2.328592e+06 | 2.328609e+06 | -1.654770e+01 | -0.0000071 |
| w2T  | Tropic      | sea                | Unbound | 1.476992e+08 | 1.537186e+08 | -6.019439e+06 | -0.0407547 |
| w3A  | Arctic      | deepocean          | Unbound | 2.620894e+09 | 2.702001e+09 | -8.110658e+07 | -0.0309461 |
| w3M  | Moderate    | deepocean          | Unbound | 3.995938e+09 | 4.104198e+09 | -1.082602e+08 | -0.0270926 |
| w3T  | Tropic      | deepocean          | Unbound | 4.768716e+09 | 4.962807e+09 | -1.940913e+08 | -0.0407010 |

``` r
#Diff per "to" compartment
ggplot(merged_SS_steady, aes (x = Abbr, y = reldiff)) +
  geom_boxplot() +
  ggtitle(paste0("Relative differences between steady state masses in excel and R (SBsteady) - ", substance)) +
  geom_hline(yintercept = 0.001, color="red") +
  geom_hline(yintercept = -0.001, color="red")
```

![](Molecular_verification_files/figure-gfm/comparison%20of%20steady%20state%20emissions%20using%20SBsteady-1.png)<!-- -->

``` r
sum(merged_SS_steady$absdiff)
```

    ## [1] -396831706

``` r
sum(merged_SS_steady$EqMass.R)
```

    ## [1] 12105937015

``` r
sum(merged_SS_steady$EqMass.Excel)
```

    ## [1] 12502768721
