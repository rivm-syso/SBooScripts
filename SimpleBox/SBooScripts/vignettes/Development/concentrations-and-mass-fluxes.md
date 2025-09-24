Concentrations and mass flux
================
Jaap Slootweg, Valerie de Rijk
2024-07-23

## Concentrations and mass fluxes

This vignette demonstrates how to obtain concentrations and mass fluxes
for a steady-state solution. We first initialize the world for molecules
and add arbitrary emissions to the regional air and river compartments.

``` r
#We need to initialize, by default a molecular substance is selected
source("baseScripts/initWorld_onlyMolec.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.0     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
    ## 
    ## Attaching package: 'ggdag'
    ## 
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter
    ## 
    ## 
    ## 
    ## Attaching package: 'rlang'
    ## 
    ## 
    ## The following objects are masked from 'package:purrr':
    ## 
    ##     %@%, flatten, flatten_chr, flatten_dbl, flatten_int, flatten_lgl,
    ##     flatten_raw, invoke, splice
    ## 
    ## 
    ## Joining with `by = join_by(Matrix)`
    ## Joining with `by = join_by(Compartment)`

``` r
Solvr <- World$NewSolver("SB1Solve")
Solution <- World$Solve(emissions = data.frame(
  Abbr = c( "aRU", "w1RU"),
  Emis = 10e6)
  )
```

## Calculating concentrations.

After computing the steady state solution we end up with equilibrium
masses for the compartments. To compute the concentration, we simply
divide by the Volume of the respective compartment.

``` r
Concentrations <- function(EqMass, Volume) {
  EqMass / Volume
}
World$NewCalcVariable("Concentrations")
ConcPM <- World$CalcVar("Concentrations")
pivot_wider(ConcPM[, c("SubCompart", "Scale", "Concentrations")],
            values_from = "Concentrations",
            values_fill = NULL,
            names_from = "Scale")
```

    ## # A tibble: 11 × 6
    ##    SubCompart            Arctic Continental   Moderate  Regional      Tropic
    ##    <chr>                  <dbl>       <dbl>      <dbl>     <dbl>       <dbl>
    ##  1 air                 0.000237     0.00189  0.000330     0.0105  0.000200  
    ##  2 deepocean           0.000561    NA        0.0000567   NA       0.00000433
    ##  3 marinesediment      0.0147       0.148    0.00131    457.      0.0000823 
    ##  4 naturalsoil         0.00514      0.0112   0.00196      0.0626  0.000610  
    ##  5 sea                 0.00186      0.00641  0.000571    19.8     0.000122  
    ##  6 agriculturalsoil   NA            0.00280 NA            0.0156 NA         
    ##  7 freshwatersediment NA            0.535   NA         7565.     NA         
    ##  8 lake               NA            0.00799 NA            0.0446 NA         
    ##  9 lakesediment       NA            0.160   NA            0.896  NA         
    ## 10 othersoil          NA            0.0112  NA            0.0626 NA         
    ## 11 river              NA            0.0201  NA          284.     NA

## Mass fluxes

Now, if we’re interested in the mass fluxes between the compartments, we
compute the mass fluxes. This is simply the value of the first order
rate constant k (or kaas) and the equilibrium mass of the from
compartment. As such, we end up with mass fluxes in weight per second.

``` r
World$fetchData("EqMass")
```

    ##          Scale         SubCompart Species       EqMass
    ## 2       Arctic                air Unbound 1.007532e+13
    ## 3       Arctic          deepocean Unbound 4.289284e+13
    ## 7       Arctic     marinesediment Unbound 1.122137e+10
    ## 8       Arctic        naturalsoil Unbound 4.371379e+09
    ## 11      Arctic                sea Unbound 4.753520e+12
    ## 12 Continental   agriculturalsoil Unbound 1.171721e+09
    ## 13 Continental                air Unbound 1.358082e+13
    ## 15 Continental freshwatersediment Unbound 1.538781e+09
    ## 16 Continental               lake Unbound 6.966244e+09
    ## 17 Continental       lakesediment Unbound 4.194507e+07
    ## 18 Continental     marinesediment Unbound 1.650568e+10
    ## 19 Continental        naturalsoil Unbound 5.272720e+08
    ## 20 Continental          othersoil Unbound 1.952859e+08
    ## 21 Continental              river Unbound 5.774303e+09
    ## 22 Continental                sea Unbound 4.757461e+12
    ## 24    Moderate                air Unbound 2.556638e+13
    ## 25    Moderate          deepocean Unbound 6.594625e+12
    ## 29    Moderate     marinesediment Unbound 1.525306e+09
    ## 30    Moderate        naturalsoil Unbound 3.796332e+09
    ## 33    Moderate                sea Unbound 2.215758e+12
    ## 34    Regional   agriculturalsoil Unbound 4.291206e+08
    ## 35    Regional                air Unbound 2.418788e+12
    ## 37    Regional freshwatersediment Unbound 1.426627e+12
    ## 38    Regional               lake Unbound 2.551256e+09
    ## 39    Regional       lakesediment Unbound 1.535282e+07
    ## 40    Regional     marinesediment Unbound 1.372471e+10
    ## 41    Regional        naturalsoil Unbound 1.931034e+08
    ## 42    Regional          othersoil Unbound 7.151976e+07
    ## 43    Regional              river Unbound 5.353442e+12
    ## 44    Regional                sea Unbound 1.977949e+11
    ## 46      Tropic                air Unbound 2.547386e+13
    ## 47      Tropic          deepocean Unbound 1.159682e+12
    ## 51      Tropic     marinesediment Unbound 2.204729e+08
    ## 52      Tropic        naturalsoil Unbound 1.166955e+09
    ## 55      Tropic                sea Unbound 1.092701e+12

``` r
MsFlux <- left_join(World$kaas, World$fetchData("EqMass"), 
                    join_by(fromScale == Scale, fromSubCompart == SubCompart, fromSpecies == Species))
MsFlux$mFlux <- MsFlux$k * MsFlux$EqMass
print(MsFlux)
```

    ##              process   fromScale     fromSubCompart fromSpecies     toScale
    ## 1           k_Burial      Arctic     marinesediment     Unbound      Arctic
    ## 2           k_Burial Continental freshwatersediment     Unbound Continental
    ## 3           k_Burial Continental       lakesediment     Unbound Continental
    ## 4           k_Burial Continental     marinesediment     Unbound Continental
    ## 5           k_Burial    Moderate     marinesediment     Unbound    Moderate
    ## 6           k_Burial    Regional freshwatersediment     Unbound    Regional
    ## 7           k_Burial    Regional       lakesediment     Unbound    Regional
    ## 8           k_Burial    Regional     marinesediment     Unbound    Regional
    ## 9           k_Burial      Tropic     marinesediment     Unbound      Tropic
    ## 10          k_Escape      Arctic                air     Unbound      Arctic
    ## 11          k_Escape Continental                air     Unbound Continental
    ## 12          k_Escape    Moderate                air     Unbound    Moderate
    ## 13          k_Escape    Regional                air     Unbound    Regional
    ## 14          k_Escape      Tropic                air     Unbound      Tropic
    ## 15         k_Erosion      Arctic        naturalsoil     Unbound      Arctic
    ## 16         k_Erosion Continental   agriculturalsoil     Unbound Continental
    ## 17         k_Erosion Continental   agriculturalsoil     Unbound Continental
    ## 18         k_Erosion Continental        naturalsoil     Unbound Continental
    ## 19         k_Erosion Continental        naturalsoil     Unbound Continental
    ## 20         k_Erosion Continental          othersoil     Unbound Continental
    ## 21         k_Erosion Continental          othersoil     Unbound Continental
    ## 22         k_Erosion    Moderate        naturalsoil     Unbound    Moderate
    ## 23         k_Erosion    Regional   agriculturalsoil     Unbound    Regional
    ## 24         k_Erosion    Regional   agriculturalsoil     Unbound    Regional
    ## 25         k_Erosion    Regional        naturalsoil     Unbound    Regional
    ## 26         k_Erosion    Regional        naturalsoil     Unbound    Regional
    ## 27         k_Erosion    Regional          othersoil     Unbound    Regional
    ## 28         k_Erosion    Regional          othersoil     Unbound    Regional
    ## 29         k_Erosion      Tropic        naturalsoil     Unbound      Tropic
    ## 30    k_Resuspension      Arctic     marinesediment     Unbound      Arctic
    ## 31    k_Resuspension Continental freshwatersediment     Unbound Continental
    ## 32    k_Resuspension Continental       lakesediment     Unbound Continental
    ## 33    k_Resuspension Continental     marinesediment     Unbound Continental
    ## 34    k_Resuspension    Moderate     marinesediment     Unbound    Moderate
    ## 35    k_Resuspension    Regional freshwatersediment     Unbound    Regional
    ## 36    k_Resuspension    Regional       lakesediment     Unbound    Regional
    ## 37    k_Resuspension    Regional     marinesediment     Unbound    Regional
    ## 38    k_Resuspension      Tropic     marinesediment     Unbound      Tropic
    ## 39      k_Adsorption      Arctic                air     Unbound      Arctic
    ## 40      k_Adsorption      Arctic                air     Unbound      Arctic
    ## 41      k_Adsorption      Arctic          deepocean     Unbound      Arctic
    ## 42      k_Adsorption Continental                air     Unbound Continental
    ## 43      k_Adsorption Continental                air     Unbound Continental
    ## 44      k_Adsorption Continental                air     Unbound Continental
    ## 45      k_Adsorption Continental                air     Unbound Continental
    ## 46      k_Adsorption Continental                air     Unbound Continental
    ## 47      k_Adsorption Continental                air     Unbound Continental
    ## 48      k_Adsorption Continental               lake     Unbound Continental
    ## 49      k_Adsorption Continental              river     Unbound Continental
    ## 50      k_Adsorption Continental                sea     Unbound Continental
    ## 51      k_Adsorption    Moderate                air     Unbound    Moderate
    ## 52      k_Adsorption    Moderate                air     Unbound    Moderate
    ## 53      k_Adsorption    Moderate          deepocean     Unbound    Moderate
    ## 54      k_Adsorption    Regional                air     Unbound    Regional
    ## 55      k_Adsorption    Regional                air     Unbound    Regional
    ## 56      k_Adsorption    Regional                air     Unbound    Regional
    ## 57      k_Adsorption    Regional                air     Unbound    Regional
    ## 58      k_Adsorption    Regional                air     Unbound    Regional
    ## 59      k_Adsorption    Regional                air     Unbound    Regional
    ## 60      k_Adsorption    Regional               lake     Unbound    Regional
    ## 61      k_Adsorption    Regional              river     Unbound    Regional
    ## 62      k_Adsorption    Regional                sea     Unbound    Regional
    ## 63      k_Adsorption      Tropic                air     Unbound      Tropic
    ## 64      k_Adsorption      Tropic                air     Unbound      Tropic
    ## 65      k_Adsorption      Tropic          deepocean     Unbound      Tropic
    ## 66     k_Degradation      Arctic                air     Unbound      Arctic
    ## 67     k_Degradation      Arctic          deepocean     Unbound      Arctic
    ## 68     k_Degradation      Arctic     marinesediment     Unbound      Arctic
    ## 69     k_Degradation      Arctic        naturalsoil     Unbound      Arctic
    ## 70     k_Degradation      Arctic                sea     Unbound      Arctic
    ## 71     k_Degradation Continental   agriculturalsoil     Unbound Continental
    ## 72     k_Degradation Continental                air     Unbound Continental
    ## 73     k_Degradation Continental freshwatersediment     Unbound Continental
    ## 74     k_Degradation Continental               lake     Unbound Continental
    ## 75     k_Degradation Continental       lakesediment     Unbound Continental
    ## 76     k_Degradation Continental     marinesediment     Unbound Continental
    ## 77     k_Degradation Continental        naturalsoil     Unbound Continental
    ## 78     k_Degradation Continental          othersoil     Unbound Continental
    ## 79     k_Degradation Continental              river     Unbound Continental
    ## 80     k_Degradation Continental                sea     Unbound Continental
    ## 81     k_Degradation    Moderate                air     Unbound    Moderate
    ## 82     k_Degradation    Moderate          deepocean     Unbound    Moderate
    ## 83     k_Degradation    Moderate     marinesediment     Unbound    Moderate
    ## 84     k_Degradation    Moderate        naturalsoil     Unbound    Moderate
    ## 85     k_Degradation    Moderate                sea     Unbound    Moderate
    ## 86     k_Degradation    Regional   agriculturalsoil     Unbound    Regional
    ## 87     k_Degradation    Regional                air     Unbound    Regional
    ## 88     k_Degradation    Regional freshwatersediment     Unbound    Regional
    ## 89     k_Degradation    Regional               lake     Unbound    Regional
    ## 90     k_Degradation    Regional       lakesediment     Unbound    Regional
    ## 91     k_Degradation    Regional     marinesediment     Unbound    Regional
    ## 92     k_Degradation    Regional        naturalsoil     Unbound    Regional
    ## 93     k_Degradation    Regional          othersoil     Unbound    Regional
    ## 94     k_Degradation    Regional              river     Unbound    Regional
    ## 95     k_Degradation    Regional                sea     Unbound    Regional
    ## 96     k_Degradation      Tropic                air     Unbound      Tropic
    ## 97     k_Degradation      Tropic          deepocean     Unbound      Tropic
    ## 98     k_Degradation      Tropic     marinesediment     Unbound      Tropic
    ## 99     k_Degradation      Tropic        naturalsoil     Unbound      Tropic
    ## 100    k_Degradation      Tropic                sea     Unbound      Tropic
    ## 101     k_Desorption      Arctic     marinesediment     Unbound      Arctic
    ## 102     k_Desorption Continental freshwatersediment     Unbound Continental
    ## 103     k_Desorption Continental       lakesediment     Unbound Continental
    ## 104     k_Desorption Continental     marinesediment     Unbound Continental
    ## 105     k_Desorption    Moderate     marinesediment     Unbound    Moderate
    ## 106     k_Desorption    Regional freshwatersediment     Unbound    Regional
    ## 107     k_Desorption    Regional       lakesediment     Unbound    Regional
    ## 108     k_Desorption    Regional     marinesediment     Unbound    Regional
    ## 109     k_Desorption      Tropic     marinesediment     Unbound      Tropic
    ## 110       k_Leaching      Arctic        naturalsoil     Unbound      Arctic
    ## 111       k_Leaching Continental   agriculturalsoil     Unbound Continental
    ## 112       k_Leaching Continental        naturalsoil     Unbound Continental
    ## 113       k_Leaching Continental          othersoil     Unbound Continental
    ## 114       k_Leaching    Moderate        naturalsoil     Unbound    Moderate
    ## 115       k_Leaching    Regional   agriculturalsoil     Unbound    Regional
    ## 116       k_Leaching    Regional        naturalsoil     Unbound    Regional
    ## 117       k_Leaching    Regional          othersoil     Unbound    Regional
    ## 118       k_Leaching      Tropic        naturalsoil     Unbound      Tropic
    ## 119         k_Runoff      Arctic        naturalsoil     Unbound      Arctic
    ## 120         k_Runoff Continental   agriculturalsoil     Unbound Continental
    ## 121         k_Runoff Continental   agriculturalsoil     Unbound Continental
    ## 122         k_Runoff Continental        naturalsoil     Unbound Continental
    ## 123         k_Runoff Continental        naturalsoil     Unbound Continental
    ## 124         k_Runoff Continental          othersoil     Unbound Continental
    ## 125         k_Runoff Continental          othersoil     Unbound Continental
    ## 126         k_Runoff    Moderate        naturalsoil     Unbound    Moderate
    ## 127         k_Runoff    Regional   agriculturalsoil     Unbound    Regional
    ## 128         k_Runoff    Regional   agriculturalsoil     Unbound    Regional
    ## 129         k_Runoff    Regional        naturalsoil     Unbound    Regional
    ## 130         k_Runoff    Regional        naturalsoil     Unbound    Regional
    ## 131         k_Runoff    Regional          othersoil     Unbound    Regional
    ## 132         k_Runoff    Regional          othersoil     Unbound    Regional
    ## 133         k_Runoff      Tropic        naturalsoil     Unbound      Tropic
    ## 134  k_Sedimentation      Arctic          deepocean     Unbound      Arctic
    ## 135  k_Sedimentation      Arctic                sea     Unbound      Arctic
    ## 136  k_Sedimentation Continental               lake     Unbound Continental
    ## 137  k_Sedimentation Continental              river     Unbound Continental
    ## 138  k_Sedimentation Continental                sea     Unbound Continental
    ## 139  k_Sedimentation Continental                sea     Unbound Continental
    ## 140  k_Sedimentation    Moderate          deepocean     Unbound    Moderate
    ## 141  k_Sedimentation    Moderate                sea     Unbound    Moderate
    ## 142  k_Sedimentation    Regional               lake     Unbound    Regional
    ## 143  k_Sedimentation    Regional              river     Unbound    Regional
    ## 144  k_Sedimentation    Regional                sea     Unbound    Regional
    ## 145  k_Sedimentation    Regional                sea     Unbound    Regional
    ## 146  k_Sedimentation      Tropic          deepocean     Unbound      Tropic
    ## 147  k_Sedimentation      Tropic                sea     Unbound      Tropic
    ## 148 k_Volatilisation      Arctic        naturalsoil     Unbound      Arctic
    ## 149 k_Volatilisation      Arctic                sea     Unbound      Arctic
    ## 150 k_Volatilisation Continental   agriculturalsoil     Unbound Continental
    ## 151 k_Volatilisation Continental               lake     Unbound Continental
    ## 152 k_Volatilisation Continental        naturalsoil     Unbound Continental
    ## 153 k_Volatilisation Continental          othersoil     Unbound Continental
    ## 154 k_Volatilisation Continental              river     Unbound Continental
    ## 155 k_Volatilisation Continental                sea     Unbound Continental
    ## 156 k_Volatilisation    Moderate        naturalsoil     Unbound    Moderate
    ## 157 k_Volatilisation    Moderate                sea     Unbound    Moderate
    ## 158 k_Volatilisation    Regional   agriculturalsoil     Unbound    Regional
    ## 159 k_Volatilisation    Regional               lake     Unbound    Regional
    ## 160 k_Volatilisation    Regional        naturalsoil     Unbound    Regional
    ## 161 k_Volatilisation    Regional          othersoil     Unbound    Regional
    ## 162 k_Volatilisation    Regional              river     Unbound    Regional
    ## 163 k_Volatilisation    Regional                sea     Unbound    Regional
    ## 164 k_Volatilisation      Tropic        naturalsoil     Unbound      Tropic
    ## 165 k_Volatilisation      Tropic                sea     Unbound      Tropic
    ## 166      k_Advection      Arctic          deepocean     Unbound      Arctic
    ## 167      k_Advection      Arctic                sea     Unbound      Arctic
    ## 168      k_Advection      Arctic                air     Unbound    Moderate
    ## 169      k_Advection      Arctic          deepocean     Unbound    Moderate
    ## 170      k_Advection      Arctic                sea     Unbound    Moderate
    ## 171      k_Advection Continental               lake     Unbound Continental
    ## 172      k_Advection Continental              river     Unbound Continental
    ## 173      k_Advection Continental                air     Unbound    Moderate
    ## 174      k_Advection Continental                sea     Unbound    Moderate
    ## 175      k_Advection Continental                air     Unbound    Regional
    ## 176      k_Advection Continental              river     Unbound    Regional
    ## 177      k_Advection Continental                sea     Unbound    Regional
    ## 178      k_Advection    Moderate                air     Unbound      Arctic
    ## 179      k_Advection    Moderate          deepocean     Unbound      Arctic
    ## 180      k_Advection    Moderate                sea     Unbound      Arctic
    ## 181      k_Advection    Moderate                air     Unbound Continental
    ## 182      k_Advection    Moderate                sea     Unbound Continental
    ## 183      k_Advection    Moderate          deepocean     Unbound    Moderate
    ## 184      k_Advection    Moderate                sea     Unbound    Moderate
    ## 185      k_Advection    Moderate                air     Unbound      Tropic
    ## 186      k_Advection    Moderate          deepocean     Unbound      Tropic
    ## 187      k_Advection    Moderate                sea     Unbound      Tropic
    ## 188      k_Advection    Regional                air     Unbound Continental
    ## 189      k_Advection    Regional                sea     Unbound Continental
    ## 190      k_Advection    Regional               lake     Unbound    Regional
    ## 191      k_Advection    Regional              river     Unbound    Regional
    ## 192      k_Advection      Tropic                air     Unbound    Moderate
    ## 193      k_Advection      Tropic          deepocean     Unbound    Moderate
    ## 194      k_Advection      Tropic                sea     Unbound    Moderate
    ## 195      k_Advection      Tropic          deepocean     Unbound      Tropic
    ## 196      k_Advection      Tropic                sea     Unbound      Tropic
    ## 197     k_Deposition      Arctic                air     Unbound      Arctic
    ## 198     k_Deposition      Arctic                air     Unbound      Arctic
    ## 199     k_Deposition Continental                air     Unbound Continental
    ## 200     k_Deposition Continental                air     Unbound Continental
    ## 201     k_Deposition Continental                air     Unbound Continental
    ## 202     k_Deposition Continental                air     Unbound Continental
    ## 203     k_Deposition Continental                air     Unbound Continental
    ## 204     k_Deposition Continental                air     Unbound Continental
    ## 205     k_Deposition    Moderate                air     Unbound    Moderate
    ## 206     k_Deposition    Moderate                air     Unbound    Moderate
    ## 207     k_Deposition    Regional                air     Unbound    Regional
    ## 208     k_Deposition    Regional                air     Unbound    Regional
    ## 209     k_Deposition    Regional                air     Unbound    Regional
    ## 210     k_Deposition    Regional                air     Unbound    Regional
    ## 211     k_Deposition    Regional                air     Unbound    Regional
    ## 212     k_Deposition    Regional                air     Unbound    Regional
    ## 213     k_Deposition      Tropic                air     Unbound      Tropic
    ## 214     k_Deposition      Tropic                air     Unbound      Tropic
    ##           toSubCompart toSpecies            k       EqMass        mFlux
    ## 1       marinesediment   Unbound 2.100000e-12 1.122137e+10 2.356488e-02
    ## 2   freshwatersediment   Unbound 2.866667e-09 1.538781e+09 4.411173e+00
    ## 3         lakesediment   Unbound 2.866667e-09 4.194507e+07 1.202425e-01
    ## 4       marinesediment   Unbound 9.133333e-10 1.650568e+10 1.507519e+01
    ## 5       marinesediment   Unbound 2.983333e-12 1.525306e+09 4.550497e-03
    ## 6   freshwatersediment   Unbound 2.900000e-09 1.426627e+12 4.137218e+03
    ## 7         lakesediment   Unbound 2.900000e-09 1.535282e+07 4.452318e-02
    ## 8       marinesediment   Unbound 9.000000e-10 1.372471e+10 1.235224e+01
    ## 9       marinesediment   Unbound 2.100000e-12 2.204729e+08 4.629932e-04
    ## 10                 air   Unbound 3.663259e-10 1.007532e+13 3.690849e+03
    ## 11                 air   Unbound 3.663259e-10 1.358082e+13 4.975004e+03
    ## 12                 air   Unbound 3.663259e-10 2.556638e+13 9.365625e+03
    ## 13                 air   Unbound 3.663259e-10 2.418788e+12 8.860648e+02
    ## 14                 air   Unbound 3.663259e-10 2.547386e+13 9.331735e+03
    ## 15                 sea   Unbound 9.510000e-10 4.371379e+09 4.157181e+00
    ## 16                lake   Unbound 7.925000e-11 1.171721e+09 9.285891e-02
    ## 17               river   Unbound 8.717500e-10 1.171721e+09 1.021448e+00
    ## 18                lake   Unbound 7.925000e-11 5.272720e+08 4.178631e-02
    ## 19               river   Unbound 8.717500e-10 5.272720e+08 4.596494e-01
    ## 20                lake   Unbound 7.925000e-11 1.952859e+08 1.547641e-02
    ## 21               river   Unbound 8.717500e-10 1.952859e+08 1.702405e-01
    ## 22                 sea   Unbound 9.510000e-10 3.796332e+09 3.610312e+00
    ## 23                lake   Unbound 7.925000e-11 4.291206e+08 3.400781e-02
    ## 24               river   Unbound 8.717500e-10 4.291206e+08 3.740859e-01
    ## 25                lake   Unbound 7.925000e-11 1.931034e+08 1.530344e-02
    ## 26               river   Unbound 8.717500e-10 1.931034e+08 1.683379e-01
    ## 27                lake   Unbound 7.925000e-11 7.151976e+07 5.667941e-03
    ## 28               river   Unbound 8.717500e-10 7.151976e+07 6.234735e-02
    ## 29                 sea   Unbound 9.510000e-10 1.166955e+09 1.109774e+00
    ## 30           deepocean   Unbound 9.798025e-09 1.122137e+10 1.099473e+02
    ## 31               river   Unbound 2.653371e-08 1.538781e+09 4.082958e+01
    ## 32                lake   Unbound 0.000000e+00 4.194507e+07 0.000000e+00
    ## 33                 sea   Unbound 8.886792e-09 1.650568e+10 1.466826e+02
    ## 34           deepocean   Unbound 9.797142e-09 1.525306e+09 1.494364e+01
    ## 35               river   Unbound 2.650038e-08 1.426627e+12 3.780615e+04
    ## 36                lake   Unbound 0.000000e+00 1.535282e+07 0.000000e+00
    ## 37                 sea   Unbound 8.900125e-09 1.372471e+10 1.221516e+02
    ## 38           deepocean   Unbound 9.798025e-09 2.204729e+08 2.160199e+00
    ## 39         naturalsoil   Unbound 3.318822e-10 1.007532e+13 3.343818e+03
    ## 40                 sea   Unbound 1.124710e-07 1.007532e+13 1.133180e+06
    ## 41      marinesediment   Unbound 9.169372e-12 4.289284e+13 3.933004e+02
    ## 42    agriculturalsoil   Unbound 3.270761e-10 1.358082e+13 4.441960e+03
    ## 43                lake   Unbound 6.904007e-11 1.358082e+13 9.376205e+02
    ## 44         naturalsoil   Unbound 1.471843e-10 1.358082e+13 1.998882e+03
    ## 45           othersoil   Unbound 5.451269e-11 1.358082e+13 7.403267e+02
    ## 46               river   Unbound 7.594408e-10 1.358082e+13 1.031383e+04
    ## 47                 sea   Unbound 2.941892e-08 1.358082e+13 3.995329e+05
    ## 48        lakesediment   Unbound 2.751764e-10 6.966244e+09 1.916946e+00
    ## 49  freshwatersediment   Unbound 9.162326e-09 5.774303e+09 5.290605e+01
    ## 50      marinesediment   Unbound 1.375406e-10 4.757461e+12 6.543439e+02
    ## 51         naturalsoil   Unbound 5.629209e-10 2.556638e+13 1.439185e+04
    ## 52                 sea   Unbound 2.851747e-08 2.556638e+13 7.290884e+05
    ## 53      marinesediment   Unbound 9.169372e-12 6.594625e+12 6.046857e+01
    ## 54    agriculturalsoil   Unbound 6.725626e-10 2.418788e+12 1.626787e+03
    ## 55                lake   Unbound 1.419663e-10 2.418788e+12 3.433863e+02
    ## 56         naturalsoil   Unbound 3.026532e-10 2.418788e+12 7.320540e+02
    ## 57           othersoil   Unbound 1.120938e-10 2.418788e+12 2.711311e+02
    ## 58               river   Unbound 1.561629e-09 2.418788e+12 3.777250e+03
    ## 59                 sea   Unbound 2.484425e-10 2.418788e+12 6.009299e+02
    ## 60        lakesediment   Unbound 2.751764e-10 2.551256e+09 7.020455e-01
    ## 61  freshwatersediment   Unbound 9.162326e-09 5.353442e+12 4.904998e+04
    ## 62      marinesediment   Unbound 2.750812e-09 1.977949e+11 5.440964e+02
    ## 63         naturalsoil   Unbound 4.415285e-10 2.547386e+13 1.124744e+04
    ## 64                 sea   Unbound 2.131698e-08 2.547386e+13 5.430257e+05
    ## 65      marinesediment   Unbound 9.169372e-12 1.159682e+12 1.063356e+01
    ## 66                 air   Unbound 1.805890e-07 1.007532e+13 1.819492e+06
    ## 67           deepocean   Unbound 1.890367e-08 4.289284e+13 8.108323e+05
    ## 68      marinesediment   Unbound 2.103643e-09 1.122137e+10 2.360575e+01
    ## 69         naturalsoil   Unbound 9.457553e-09 4.371379e+09 4.134255e+01
    ## 70                 sea   Unbound 1.890367e-08 4.753520e+12 8.985900e+04
    ## 71    agriculturalsoil   Unbound 4.345550e-08 1.171721e+09 5.091774e+01
    ## 72                 air   Unbound 2.159397e-07 1.358082e+13 2.932637e+06
    ## 73  freshwatersediment   Unbound 9.665804e-09 1.538781e+09 1.487356e+01
    ## 74                lake   Unbound 8.688855e-08 6.966244e+09 6.052869e+02
    ## 75        lakesediment   Unbound 9.665804e-09 4.194507e+07 4.054328e-01
    ## 76      marinesediment   Unbound 9.665804e-09 1.650568e+10 1.595407e+02
    ## 77         naturalsoil   Unbound 4.345550e-08 5.272720e+08 2.291287e+01
    ## 78           othersoil   Unbound 4.345550e-08 1.952859e+08 8.486249e+00
    ## 79               river   Unbound 8.679173e-08 5.774303e+09 5.011618e+02
    ## 80                 sea   Unbound 8.685848e-08 4.757461e+12 4.132258e+05
    ## 81                 air   Unbound 2.159397e-07 2.556638e+13 5.520795e+06
    ## 82           deepocean   Unbound 8.685848e-08 6.594625e+12 5.727991e+05
    ## 83      marinesediment   Unbound 9.665804e-09 1.525306e+09 1.474331e+01
    ## 84         naturalsoil   Unbound 4.345550e-08 3.796332e+09 1.649715e+02
    ## 85                 sea   Unbound 8.685848e-08 2.215758e+12 1.924574e+05
    ## 86    agriculturalsoil   Unbound 4.345550e-08 4.291206e+08 1.864765e+01
    ## 87                 air   Unbound 2.159397e-07 2.418788e+12 5.223123e+05
    ## 88  freshwatersediment   Unbound 9.665804e-09 1.426627e+12 1.378950e+04
    ## 89                lake   Unbound 8.688855e-08 2.551256e+09 2.216750e+02
    ## 90        lakesediment   Unbound 9.665804e-09 1.535282e+07 1.483974e-01
    ## 91      marinesediment   Unbound 9.665804e-09 1.372471e+10 1.326604e+02
    ## 92         naturalsoil   Unbound 4.345550e-08 1.931034e+08 8.391404e+00
    ## 93           othersoil   Unbound 4.345550e-08 7.151976e+07 3.107927e+00
    ## 94               river   Unbound 8.679173e-08 5.353442e+12 4.646345e+05
    ## 95                 sea   Unbound 8.685848e-08 1.977949e+11 1.718016e+04
    ## 96                 air   Unbound 2.400000e-07 2.547386e+13 6.113727e+06
    ## 97           deepocean   Unbound 2.138707e-07 1.159682e+12 2.480219e+05
    ## 98      marinesediment   Unbound 2.380000e-08 2.204729e+08 5.247256e+00
    ## 99         naturalsoil   Unbound 1.070000e-07 1.166955e+09 1.248642e+02
    ## 100                sea   Unbound 2.138707e-07 1.092701e+12 2.336966e+05
    ## 101          deepocean   Unbound 4.578657e-08 1.122137e+10 5.137880e+02
    ## 102              river   Unbound 4.578657e-08 1.538781e+09 7.045552e+01
    ## 103               lake   Unbound 4.578657e-08 4.194507e+07 1.920521e+00
    ## 104                sea   Unbound 4.578657e-08 1.650568e+10 7.557385e+02
    ## 105          deepocean   Unbound 4.578657e-08 1.525306e+09 6.983854e+01
    ## 106              river   Unbound 4.578657e-08 1.426627e+12 6.532035e+04
    ## 107               lake   Unbound 4.578657e-08 1.535282e+07 7.029530e-01
    ## 108                sea   Unbound 4.578657e-08 1.372471e+10 6.284074e+02
    ## 109          deepocean   Unbound 4.578657e-08 2.204729e+08 1.009470e+01
    ## 110        naturalsoil   Unbound 1.457115e-11 4.371379e+09 6.369600e-02
    ## 111   agriculturalsoil   Unbound 1.855576e-11 1.171721e+09 2.174218e-02
    ## 112        naturalsoil   Unbound 4.077704e-11 5.272720e+08 2.150059e-02
    ## 113          othersoil   Unbound 4.077704e-11 1.952859e+08 7.963182e-03
    ## 114        naturalsoil   Unbound 4.077704e-11 3.796332e+09 1.548032e-01
    ## 115   agriculturalsoil   Unbound 1.855576e-11 4.291206e+08 7.962661e-03
    ## 116        naturalsoil   Unbound 4.077704e-11 1.931034e+08 7.874182e-03
    ## 117          othersoil   Unbound 4.077704e-11 7.151976e+07 2.916364e-03
    ## 118        naturalsoil   Unbound 7.567718e-11 1.166955e+09 8.831187e-02
    ## 119                sea   Unbound 8.508970e-08 4.371379e+09 3.719593e+02
    ## 120               lake   Unbound 1.984347e-08 1.171721e+09 2.325102e+01
    ## 121              river   Unbound 2.182782e-07 1.171721e+09 2.557612e+02
    ## 122               lake   Unbound 1.984347e-08 5.272720e+08 1.046291e+01
    ## 123              river   Unbound 2.182782e-07 5.272720e+08 1.150920e+02
    ## 124               lake   Unbound 1.984347e-08 1.952859e+08 3.875152e+00
    ## 125              river   Unbound 2.182782e-07 1.952859e+08 4.262667e+01
    ## 126                sea   Unbound 2.381217e-07 3.796332e+09 9.039890e+02
    ## 127               lake   Unbound 1.984347e-08 4.291206e+08 8.515244e+00
    ## 128              river   Unbound 2.182782e-07 4.291206e+08 9.366769e+01
    ## 129               lake   Unbound 1.984347e-08 1.931034e+08 3.831841e+00
    ## 130              river   Unbound 2.182782e-07 1.931034e+08 4.215026e+01
    ## 131               lake   Unbound 1.984347e-08 7.151976e+07 1.419201e+00
    ## 132              river   Unbound 2.182782e-07 7.151976e+07 1.561121e+01
    ## 133                sea   Unbound 4.419247e-07 1.166955e+09 5.157063e+02
    ## 134     marinesediment   Unbound 5.923229e-12 4.289284e+13 2.540641e+02
    ## 135          deepocean   Unbound 0.000000e+00 4.753520e+12 0.000000e+00
    ## 136       lakesediment   Unbound 7.597354e-11 6.966244e+09 5.292503e-01
    ## 137 freshwatersediment   Unbound 1.344990e-08 5.774303e+09 7.766378e+01
    ## 138          deepocean   Unbound 0.000000e+00 4.757461e+12 0.000000e+00
    ## 139     marinesediment   Unbound 8.884844e-11 4.757461e+12 4.226930e+02
    ## 140     marinesediment   Unbound 5.923229e-12 6.594625e+12 3.906148e+01
    ## 141          deepocean   Unbound 0.000000e+00 2.215758e+12 0.000000e+00
    ## 142       lakesediment   Unbound 7.597354e-11 2.551256e+09 1.938280e-01
    ## 143 freshwatersediment   Unbound 1.344990e-08 5.353442e+12 7.200323e+04
    ## 144          deepocean   Unbound 0.000000e+00 1.977949e+11 0.000000e+00
    ## 145     marinesediment   Unbound 1.776969e-09 1.977949e+11 3.514753e+02
    ## 146     marinesediment   Unbound 5.923229e-12 1.159682e+12 6.869062e+00
    ## 147          deepocean   Unbound 0.000000e+00 1.092701e+12 0.000000e+00
    ## 148                air   Unbound 9.450064e-07 4.371379e+09 4.130981e+03
    ## 149                air   Unbound 4.969741e-08 4.753520e+12 2.362377e+05
    ## 150                air   Unbound 4.340881e-06 1.171721e+09 5.086303e+03
    ## 151                air   Unbound 5.123441e-08 6.966244e+09 3.569114e+02
    ## 152                air   Unbound 4.340881e-06 5.272720e+08 2.288825e+03
    ## 153                air   Unbound 4.340881e-06 1.952859e+08 8.477130e+02
    ## 154                air   Unbound 1.705911e-06 5.774303e+09 9.850446e+03
    ## 155                air   Unbound 2.560834e-08 4.757461e+12 1.218307e+05
    ## 156                air   Unbound 4.340881e-06 3.796332e+09 1.647942e+04
    ## 157                air   Unbound 5.121668e-08 2.215758e+12 1.134838e+05
    ## 158                air   Unbound 4.340881e-06 4.291206e+08 1.862762e+03
    ## 159                air   Unbound 5.123441e-08 2.551256e+09 1.307121e+02
    ## 160                air   Unbound 4.340881e-06 1.931034e+08 8.382387e+02
    ## 161                air   Unbound 4.340881e-06 7.151976e+07 3.104588e+02
    ## 162                air   Unbound 1.705911e-06 5.353442e+12 9.132494e+06
    ## 163                air   Unbound 5.121668e-07 1.977949e+11 1.013040e+05
    ## 164                air   Unbound 1.068497e-05 1.166955e+09 1.246888e+04
    ## 165                air   Unbound 5.152635e-08 1.092701e+12 5.630288e+04
    ## 166                sea   Unbound 8.975375e-09 4.289284e+13 3.849793e+05
    ## 167          deepocean   Unbound 2.692612e-07 4.753520e+12 1.279939e+06
    ## 168                air   Unbound 6.923419e-07 1.007532e+13 6.975563e+06
    ## 169          deepocean   Unbound 1.960784e-09 4.289284e+13 8.410361e+04
    ## 170                sea   Unbound 0.000000e+00 4.753520e+12 0.000000e+00
    ## 171              river   Unbound 2.397260e-09 6.966244e+09 1.669990e+01
    ## 172                sea   Unbound 7.264425e-08 5.774303e+09 4.194699e+02
    ## 173                air   Unbound 1.381786e-06 1.358082e+13 1.876578e+07
    ## 174                sea   Unbound 3.169135e-08 4.757461e+12 1.507703e+05
    ## 175                air   Unbound 3.003899e-07 1.358082e+13 4.079540e+06
    ## 176              river   Unbound 0.000000e+00 5.774303e+09 0.000000e+00
    ## 177                sea   Unbound 1.660023e-11 4.757461e+12 7.897493e+01
    ## 178                air   Unbound 3.793229e-07 2.556638e+13 9.697913e+06
    ## 179          deepocean   Unbound 0.000000e+00 6.594625e+12 0.000000e+00
    ## 180                sea   Unbound 3.867416e-08 2.215758e+12 8.569257e+04
    ## 181                air   Unbound 1.282412e-07 2.556638e+13 3.278663e+06
    ## 182                sea   Unbound 6.068386e-09 2.215758e+12 1.344607e+04
    ## 183                sea   Unbound 8.303729e-09 6.594625e+12 5.475998e+04
    ## 184          deepocean   Unbound 2.491119e-07 2.215758e+12 5.519716e+05
    ## 185                air   Unbound 6.570066e-07 2.556638e+13 1.679728e+07
    ## 186          deepocean   Unbound 1.289139e-09 6.594625e+12 8.501385e+03
    ## 187                sea   Unbound 0.000000e+00 2.215758e+12 0.000000e+00
    ## 188                air   Unbound 9.420143e-06 2.418788e+12 2.278533e+07
    ## 189                sea   Unbound 1.369854e-06 1.977949e+11 2.709501e+05
    ## 190              river   Unbound 2.397260e-09 2.551256e+09 6.116025e+00
    ## 191                sea   Unbound 7.264425e-08 5.353442e+12 3.888968e+05
    ## 192                air   Unbound 3.997238e-07 2.547386e+13 1.018251e+07
    ## 193          deepocean   Unbound 0.000000e+00 1.159682e+12 0.000000e+00
    ## 194                sea   Unbound 1.680672e-08 1.092701e+12 1.836472e+04
    ## 195                sea   Unbound 7.574814e-09 1.159682e+12 8.784375e+03
    ## 196          deepocean   Unbound 2.272444e-07 1.092701e+12 2.483102e+05
    ## 197        naturalsoil   Unbound 1.195680e-10 1.007532e+13 1.204686e+03
    ## 198                sea   Unbound 1.793520e-10 1.007532e+13 1.807029e+03
    ## 199   agriculturalsoil   Unbound 7.182250e-11 1.358082e+13 9.754082e+02
    ## 200               lake   Unbound 2.992604e-13 1.358082e+13 4.064201e+00
    ## 201        naturalsoil   Unbound 3.232013e-11 1.358082e+13 4.389337e+02
    ## 202          othersoil   Unbound 1.197042e-11 1.358082e+13 1.625680e+02
    ## 203              river   Unbound 3.291865e-12 1.358082e+13 4.470621e+01
    ## 204                sea   Unbound 1.275190e-10 1.358082e+13 1.731811e+03
    ## 205        naturalsoil   Unbound 1.236117e-10 2.556638e+13 3.160302e+03
    ## 206                sea   Unbound 1.236117e-10 2.556638e+13 3.160302e+03
    ## 207   agriculturalsoil   Unbound 1.476861e-10 2.418788e+12 3.572215e+02
    ## 208               lake   Unbound 6.153589e-13 2.418788e+12 1.488423e+00
    ## 209        naturalsoil   Unbound 6.645877e-11 2.418788e+12 1.607497e+02
    ## 210          othersoil   Unbound 2.461436e-11 2.418788e+12 5.953692e+01
    ## 211              river   Unbound 6.768948e-12 2.418788e+12 1.637265e+01
    ## 212                sea   Unbound 1.076885e-12 2.418788e+12 2.604757e+00
    ## 213        naturalsoil   Unbound 7.314216e-11 2.547386e+13 1.863213e+03
    ## 214                sea   Unbound 1.706650e-10 2.547386e+13 4.347498e+03
