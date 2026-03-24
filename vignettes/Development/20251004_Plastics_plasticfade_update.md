Comparison shape update
================
Nadim Saadi, Anne Hids, Joris Quik
2026-01-20

# Explanation of update

In this update, we introduce the PlasticFADE (Plastic Fragmentation And
Degradation in the Environment) degradation model, based on the work of
Tang & Boulay (under review). PlasticFADE was developed as an empirical
model to predict polymer-specific rate constants in various
environmental compartments.

For degradation, the model considers UV intensity and microbial
concentration in the various environmental compartments, as well as the
polymer specific empirical constants, to compute k_deg. The empirical
constants for each polymer can be found in the original publication.

with plasticFADE, the equation is:

kdeg = deg_x \* SAV^deg_tau \* (deg_y \* UVintensity^deg_theta + deg_z
\* MICROBconc^deg_eta) / (24*60*60)

to derive kdeg in s-1. UVintensity and MICROBconc are defined in
ScaleSubCompartData.csv

- v_KdegDorC is changed to include the new plasticFADE input parameters.

There is now a choice of three types of degradation input to be used:
Kssdr, plasticFADE and the Default by setting kdeg directly for all the
relevant compartments based on seperately estimated half lifes.

This is done using `World$SetConst(DegApproach = "Default")`.

- Degrading_enzyme: Further, the update returns a 0 kdeg in compartments
  without UV intensity, only for polymers that do not have naturally
  occurring degrading enzymes. For example, the degradation of
  polyolefins (PE, HDPE, LDPE, EPS, …) cannot be initiated in the
  absence of UV, but it can for polymers, such as PET, PA, PU, etc.
  (Chow et al., 2023, doi.org/10.1111/1751-7915.14135). This represented
  with the new boolean called “Degrading_ezyme” (TRUE or FALSE). TRUE
  means that degrading enzymes exist in the environment, and therefore
  SBoo will compute kdeg (based on default, Kssdr, or plasticFADE). If
  FALSE, the degradation function will test for the presence of UV
  before returning 0 or computing kdeg.

- DegApproach = “Default”, “Kssdr”, or “PlasticFADE”

The following code test the swithing between the different DegApproach
variables for PET_sphere_example (defined in the Substances.csv file).
We use a PET spherical particles of 100um diameter as an example. For
the PET example, the plasticFADE empirical constants are defined:
deg_x=5.50E-03 deg_tau=1.37E-02 deg_y=1.72E-02 deg_theta=7.05E-01
deg_z=1.62E-05 deg_eta=4.42E-01

The SSDR is also defined.

The results show that the model correctly switches between DegApproach
when setting this variable, as long as the input data was made available
at initialisation.

Furthermore we test below the difference between this new implementation
of degradation in this branch compared to the current development branch
( 2026-01-20).

    ## [1] "Directory: SBzips created."

    ## [1] "The SimpleBox model can be found in SimpleBox"

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

Do the same for the other implementation.

## Verification of previous and new implementation

    ##          process   fromScale     fromSubCompart fromSpecies     toScale
    ## 1  k_Degradation      Arctic          deepocean       Large      Arctic
    ## 2  k_Degradation      Arctic          deepocean       Small      Arctic
    ## 3  k_Degradation      Arctic          deepocean       Solid      Arctic
    ## 4  k_Degradation      Arctic     marinesediment       Large      Arctic
    ## 5  k_Degradation      Arctic     marinesediment       Small      Arctic
    ## 6  k_Degradation      Arctic     marinesediment       Solid      Arctic
    ## 7  k_Degradation      Arctic        naturalsoil       Large      Arctic
    ## 8  k_Degradation      Arctic        naturalsoil       Small      Arctic
    ## 9  k_Degradation      Arctic        naturalsoil       Solid      Arctic
    ## 10 k_Degradation      Arctic                sea       Large      Arctic
    ## 11 k_Degradation      Arctic                sea       Small      Arctic
    ## 12 k_Degradation      Arctic                sea       Solid      Arctic
    ## 13 k_Degradation Continental   agriculturalsoil       Large Continental
    ## 14 k_Degradation Continental   agriculturalsoil       Small Continental
    ## 15 k_Degradation Continental   agriculturalsoil       Solid Continental
    ## 16 k_Degradation Continental freshwatersediment       Large Continental
    ## 17 k_Degradation Continental freshwatersediment       Small Continental
    ## 18 k_Degradation Continental freshwatersediment       Solid Continental
    ## 19 k_Degradation Continental               lake       Large Continental
    ## 20 k_Degradation Continental               lake       Small Continental
    ## 21 k_Degradation Continental               lake       Solid Continental
    ## 22 k_Degradation Continental       lakesediment       Large Continental
    ## 23 k_Degradation Continental       lakesediment       Small Continental
    ## 24 k_Degradation Continental       lakesediment       Solid Continental
    ## 25 k_Degradation Continental     marinesediment       Large Continental
    ## 26 k_Degradation Continental     marinesediment       Small Continental
    ## 27 k_Degradation Continental     marinesediment       Solid Continental
    ## 28 k_Degradation Continental        naturalsoil       Large Continental
    ## 29 k_Degradation Continental        naturalsoil       Small Continental
    ## 30 k_Degradation Continental        naturalsoil       Solid Continental
    ## 31 k_Degradation Continental          othersoil       Large Continental
    ## 32 k_Degradation Continental          othersoil       Small Continental
    ## 33 k_Degradation Continental          othersoil       Solid Continental
    ## 34 k_Degradation Continental              river       Large Continental
    ## 35 k_Degradation Continental              river       Small Continental
    ## 36 k_Degradation Continental              river       Solid Continental
    ## 37 k_Degradation Continental                sea       Large Continental
    ## 38 k_Degradation Continental                sea       Small Continental
    ## 39 k_Degradation Continental                sea       Solid Continental
    ## 40 k_Degradation    Moderate          deepocean       Large    Moderate
    ## 41 k_Degradation    Moderate          deepocean       Small    Moderate
    ## 42 k_Degradation    Moderate          deepocean       Solid    Moderate
    ## 43 k_Degradation    Moderate     marinesediment       Large    Moderate
    ## 44 k_Degradation    Moderate     marinesediment       Small    Moderate
    ## 45 k_Degradation    Moderate     marinesediment       Solid    Moderate
    ## 46 k_Degradation    Moderate        naturalsoil       Large    Moderate
    ## 47 k_Degradation    Moderate        naturalsoil       Small    Moderate
    ## 48 k_Degradation    Moderate        naturalsoil       Solid    Moderate
    ## 49 k_Degradation    Moderate                sea       Large    Moderate
    ## 50 k_Degradation    Moderate                sea       Small    Moderate
    ## 51 k_Degradation    Moderate                sea       Solid    Moderate
    ## 52 k_Degradation    Regional   agriculturalsoil       Large    Regional
    ## 53 k_Degradation    Regional   agriculturalsoil       Small    Regional
    ## 54 k_Degradation    Regional   agriculturalsoil       Solid    Regional
    ## 55 k_Degradation    Regional freshwatersediment       Large    Regional
    ## 56 k_Degradation    Regional freshwatersediment       Small    Regional
    ## 57 k_Degradation    Regional freshwatersediment       Solid    Regional
    ## 58 k_Degradation    Regional               lake       Large    Regional
    ## 59 k_Degradation    Regional               lake       Small    Regional
    ## 60 k_Degradation    Regional               lake       Solid    Regional
    ## 61 k_Degradation    Regional       lakesediment       Large    Regional
    ## 62 k_Degradation    Regional       lakesediment       Small    Regional
    ## 63 k_Degradation    Regional       lakesediment       Solid    Regional
    ## 64 k_Degradation    Regional     marinesediment       Large    Regional
    ## 65 k_Degradation    Regional     marinesediment       Small    Regional
    ## 66 k_Degradation    Regional     marinesediment       Solid    Regional
    ## 67 k_Degradation    Regional        naturalsoil       Large    Regional
    ## 68 k_Degradation    Regional        naturalsoil       Small    Regional
    ## 69 k_Degradation    Regional        naturalsoil       Solid    Regional
    ## 70 k_Degradation    Regional          othersoil       Large    Regional
    ## 71 k_Degradation    Regional          othersoil       Small    Regional
    ## 72 k_Degradation    Regional          othersoil       Solid    Regional
    ## 73 k_Degradation    Regional              river       Large    Regional
    ## 74 k_Degradation    Regional              river       Small    Regional
    ## 75 k_Degradation    Regional              river       Solid    Regional
    ## 76 k_Degradation    Regional                sea       Large    Regional
    ## 77 k_Degradation    Regional                sea       Small    Regional
    ## 78 k_Degradation    Regional                sea       Solid    Regional
    ## 79 k_Degradation      Tropic          deepocean       Large      Tropic
    ## 80 k_Degradation      Tropic          deepocean       Small      Tropic
    ## 81 k_Degradation      Tropic          deepocean       Solid      Tropic
    ## 82 k_Degradation      Tropic     marinesediment       Large      Tropic
    ## 83 k_Degradation      Tropic     marinesediment       Small      Tropic
    ## 84 k_Degradation      Tropic     marinesediment       Solid      Tropic
    ## 85 k_Degradation      Tropic        naturalsoil       Large      Tropic
    ## 86 k_Degradation      Tropic        naturalsoil       Small      Tropic
    ## 87 k_Degradation      Tropic        naturalsoil       Solid      Tropic
    ## 88 k_Degradation      Tropic                sea       Large      Tropic
    ## 89 k_Degradation      Tropic                sea       Small      Tropic
    ## 90 k_Degradation      Tropic                sea       Solid      Tropic
    ##          toSubCompart toSpecies    Substance        k_Old k_New          diff
    ## 1           deepocean     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 2           deepocean     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 3           deepocean     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 4      marinesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 5      marinesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 6      marinesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 7         naturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 8         naturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 9         naturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 10                sea     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 11                sea     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 12                sea     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 13   agriculturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 14   agriculturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 15   agriculturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 16 freshwatersediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 17 freshwatersediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 18 freshwatersediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 19               lake     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 20               lake     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 21               lake     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 22       lakesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 23       lakesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 24       lakesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 25     marinesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 26     marinesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 27     marinesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 28        naturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 29        naturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 30        naturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 31          othersoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 32          othersoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 33          othersoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 34              river     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 35              river     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 36              river     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 37                sea     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 38                sea     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 39                sea     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 40          deepocean     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 41          deepocean     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 42          deepocean     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 43     marinesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 44     marinesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 45     marinesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 46        naturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 47        naturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 48        naturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 49                sea     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 50                sea     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 51                sea     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 52   agriculturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 53   agriculturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 54   agriculturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 55 freshwatersediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 56 freshwatersediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 57 freshwatersediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 58               lake     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 59               lake     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 60               lake     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 61       lakesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 62       lakesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 63       lakesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 64     marinesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 65     marinesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 66     marinesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 67        naturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 68        naturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 69        naturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 70          othersoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 71          othersoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 72          othersoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 73              river     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 74              river     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 75              river     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 76                sea     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 77                sea     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 78                sea     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 79          deepocean     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 80          deepocean     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 81          deepocean     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 82     marinesediment     Large microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 83     marinesediment     Small microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 84     marinesediment     Solid microplastic 2.244992e-08 3e-11 -2.241992e-08
    ## 85        naturalsoil     Large microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 86        naturalsoil     Small microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 87        naturalsoil     Solid microplastic 3.031928e-07 3e-11 -3.031628e-07
    ## 88                sea     Large microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 89                sea     Small microplastic 4.186848e-08 1e-10 -4.176848e-08
    ## 90                sea     Solid microplastic 4.186848e-08 1e-10 -4.176848e-08
    ##       rel_diff
    ## 1    -417.6848
    ## 2    -417.6848
    ## 3    -417.6848
    ## 4    -747.3307
    ## 5    -747.3307
    ## 6    -747.3307
    ## 7  -10105.4267
    ## 8  -10105.4267
    ## 9  -10105.4267
    ## 10   -417.6848
    ## 11   -417.6848
    ## 12   -417.6848
    ## 13 -10105.4267
    ## 14 -10105.4267
    ## 15 -10105.4267
    ## 16   -747.3307
    ## 17   -747.3307
    ## 18   -747.3307
    ## 19   -417.6848
    ## 20   -417.6848
    ## 21   -417.6848
    ## 22   -747.3307
    ## 23   -747.3307
    ## 24   -747.3307
    ## 25   -747.3307
    ## 26   -747.3307
    ## 27   -747.3307
    ## 28 -10105.4267
    ## 29 -10105.4267
    ## 30 -10105.4267
    ## 31 -10105.4267
    ## 32 -10105.4267
    ## 33 -10105.4267
    ## 34   -417.6848
    ## 35   -417.6848
    ## 36   -417.6848
    ## 37   -417.6848
    ## 38   -417.6848
    ## 39   -417.6848
    ## 40   -417.6848
    ## 41   -417.6848
    ## 42   -417.6848
    ## 43   -747.3307
    ## 44   -747.3307
    ## 45   -747.3307
    ## 46 -10105.4267
    ## 47 -10105.4267
    ## 48 -10105.4267
    ## 49   -417.6848
    ## 50   -417.6848
    ## 51   -417.6848
    ## 52 -10105.4267
    ## 53 -10105.4267
    ## 54 -10105.4267
    ## 55   -747.3307
    ## 56   -747.3307
    ## 57   -747.3307
    ## 58   -417.6848
    ## 59   -417.6848
    ## 60   -417.6848
    ## 61   -747.3307
    ## 62   -747.3307
    ## 63   -747.3307
    ## 64   -747.3307
    ## 65   -747.3307
    ## 66   -747.3307
    ## 67 -10105.4267
    ## 68 -10105.4267
    ## 69 -10105.4267
    ## 70 -10105.4267
    ## 71 -10105.4267
    ## 72 -10105.4267
    ## 73   -417.6848
    ## 74   -417.6848
    ## 75   -417.6848
    ## 76   -417.6848
    ## 77   -417.6848
    ## 78   -417.6848
    ## 79   -417.6848
    ## 80   -417.6848
    ## 81   -417.6848
    ## 82   -747.3307
    ## 83   -747.3307
    ## 84   -747.3307
    ## 85 -10105.4267
    ## 86 -10105.4267
    ## 87 -10105.4267
    ## 88   -417.6848
    ## 89   -417.6848
    ## 90   -417.6848
    ##                                                                full_name
    ## 1                              From deepocean_Arctic to deepocean_Arctic
    ## 2                              From deepocean_Arctic to deepocean_Arctic
    ## 3                              From deepocean_Arctic to deepocean_Arctic
    ## 4                    From marinesediment_Arctic to marinesediment_Arctic
    ## 5                    From marinesediment_Arctic to marinesediment_Arctic
    ## 6                    From marinesediment_Arctic to marinesediment_Arctic
    ## 7                          From naturalsoil_Arctic to naturalsoil_Arctic
    ## 8                          From naturalsoil_Arctic to naturalsoil_Arctic
    ## 9                          From naturalsoil_Arctic to naturalsoil_Arctic
    ## 10                                         From sea_Arctic to sea_Arctic
    ## 11                                         From sea_Arctic to sea_Arctic
    ## 12                                         From sea_Arctic to sea_Arctic
    ## 13     From agriculturalsoil_Continental to agriculturalsoil_Continental
    ## 14     From agriculturalsoil_Continental to agriculturalsoil_Continental
    ## 15     From agriculturalsoil_Continental to agriculturalsoil_Continental
    ## 16 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 17 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 18 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 19                             From lake_Continental to lake_Continental
    ## 20                             From lake_Continental to lake_Continental
    ## 21                             From lake_Continental to lake_Continental
    ## 22             From lakesediment_Continental to lakesediment_Continental
    ## 23             From lakesediment_Continental to lakesediment_Continental
    ## 24             From lakesediment_Continental to lakesediment_Continental
    ## 25         From marinesediment_Continental to marinesediment_Continental
    ## 26         From marinesediment_Continental to marinesediment_Continental
    ## 27         From marinesediment_Continental to marinesediment_Continental
    ## 28               From naturalsoil_Continental to naturalsoil_Continental
    ## 29               From naturalsoil_Continental to naturalsoil_Continental
    ## 30               From naturalsoil_Continental to naturalsoil_Continental
    ## 31                   From othersoil_Continental to othersoil_Continental
    ## 32                   From othersoil_Continental to othersoil_Continental
    ## 33                   From othersoil_Continental to othersoil_Continental
    ## 34                           From river_Continental to river_Continental
    ## 35                           From river_Continental to river_Continental
    ## 36                           From river_Continental to river_Continental
    ## 37                               From sea_Continental to sea_Continental
    ## 38                               From sea_Continental to sea_Continental
    ## 39                               From sea_Continental to sea_Continental
    ## 40                         From deepocean_Moderate to deepocean_Moderate
    ## 41                         From deepocean_Moderate to deepocean_Moderate
    ## 42                         From deepocean_Moderate to deepocean_Moderate
    ## 43               From marinesediment_Moderate to marinesediment_Moderate
    ## 44               From marinesediment_Moderate to marinesediment_Moderate
    ## 45               From marinesediment_Moderate to marinesediment_Moderate
    ## 46                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 47                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 48                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 49                                     From sea_Moderate to sea_Moderate
    ## 50                                     From sea_Moderate to sea_Moderate
    ## 51                                     From sea_Moderate to sea_Moderate
    ## 52           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 53           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 54           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 55       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 56       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 57       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 58                                   From lake_Regional to lake_Regional
    ## 59                                   From lake_Regional to lake_Regional
    ## 60                                   From lake_Regional to lake_Regional
    ## 61                   From lakesediment_Regional to lakesediment_Regional
    ## 62                   From lakesediment_Regional to lakesediment_Regional
    ## 63                   From lakesediment_Regional to lakesediment_Regional
    ## 64               From marinesediment_Regional to marinesediment_Regional
    ## 65               From marinesediment_Regional to marinesediment_Regional
    ## 66               From marinesediment_Regional to marinesediment_Regional
    ## 67                     From naturalsoil_Regional to naturalsoil_Regional
    ## 68                     From naturalsoil_Regional to naturalsoil_Regional
    ## 69                     From naturalsoil_Regional to naturalsoil_Regional
    ## 70                         From othersoil_Regional to othersoil_Regional
    ## 71                         From othersoil_Regional to othersoil_Regional
    ## 72                         From othersoil_Regional to othersoil_Regional
    ## 73                                 From river_Regional to river_Regional
    ## 74                                 From river_Regional to river_Regional
    ## 75                                 From river_Regional to river_Regional
    ## 76                                     From sea_Regional to sea_Regional
    ## 77                                     From sea_Regional to sea_Regional
    ## 78                                     From sea_Regional to sea_Regional
    ## 79                             From deepocean_Tropic to deepocean_Tropic
    ## 80                             From deepocean_Tropic to deepocean_Tropic
    ## 81                             From deepocean_Tropic to deepocean_Tropic
    ## 82                   From marinesediment_Tropic to marinesediment_Tropic
    ## 83                   From marinesediment_Tropic to marinesediment_Tropic
    ## 84                   From marinesediment_Tropic to marinesediment_Tropic
    ## 85                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 86                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 87                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 88                                         From sea_Tropic to sea_Tropic
    ## 89                                         From sea_Tropic to sea_Tropic
    ## 90                                         From sea_Tropic to sea_Tropic

As can be seen in the figures below, the new degradation rate constants
for microplastic, have a very large difference, max -1.0105427^{6} %
larger compared to the previous default kdeg value’s. This is due to the
difference in DegApproach, where in the previous development version
kssdr is used when data is input and DegApproach could not be set.

``` r
all_diffs <- changed_kaas |>
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

for(i in unique(all_diffs$Substance)){
  diffs_substance <- all_diffs |>
    filter(Substance == i)
  
  absdif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = diff)) + 
    geom_point() + 
    labs(
      title = "Difference between old and new k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),  
      panel.background = element_blank() 
    )
  
  plot(absdif_plot)
  
  reldif_plot <- ggplot(diffs_substance, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
    geom_point() + 
    labs(
      title = "Relative difference between old and new k's",
      subtitle = i,
      x = "To",  
      y = "From",  
      color = "Relative difference"  
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1), 
      panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  plot(reldif_plot)
}
```

![](20251004_Plastics_plasticfade_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20251004_Plastics_plasticfade_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->

Now the difference should be gone when setting microplastics DegApproach
to kssdr. We test this below.

The results show that a relative difference of exactly -50% is found.
This is caused by an error in the previous Kssdr implementation using
the shortest_side (um) or diameter instead of the radius. This is now
correct and thus results in the difference of -50%.
