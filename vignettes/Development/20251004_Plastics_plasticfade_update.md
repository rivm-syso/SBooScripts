Comparison shape update
================
Nadim Saadi, Anne Hids, Joris Quik
2026-01-19

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

The following code compares the kdeg of PET_sphere_example (defined in
the Substances.csv file). We use a PET spherical particles of 100um
diameter as an example. For the PET example, the plasticFADE empirical
constants are defined: deg_x=5.50E-03 deg_tau=1.37E-02 deg_y=1.72E-02
deg_theta=7.05E-01 deg_z=1.62E-05 deg_eta=4.42E-01

The SSDR is also defined.

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

    ## [1] "1-aminoanthraquinone"

    ## [1] "microplastic"

    ## [1] "nAg_10nm"

    ## [1] "PET_sphere_example"

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
    ## 16 k_Degradation Continental                air       Large Continental
    ## 17 k_Degradation Continental                air       Small Continental
    ## 18 k_Degradation Continental                air       Solid Continental
    ## 19 k_Degradation Continental freshwatersediment       Large Continental
    ## 20 k_Degradation Continental freshwatersediment       Small Continental
    ## 21 k_Degradation Continental freshwatersediment       Solid Continental
    ## 22 k_Degradation Continental               lake       Large Continental
    ## 23 k_Degradation Continental               lake       Small Continental
    ## 24 k_Degradation Continental               lake       Solid Continental
    ## 25 k_Degradation Continental       lakesediment       Large Continental
    ## 26 k_Degradation Continental       lakesediment       Small Continental
    ## 27 k_Degradation Continental       lakesediment       Solid Continental
    ## 28 k_Degradation Continental     marinesediment       Large Continental
    ## 29 k_Degradation Continental     marinesediment       Small Continental
    ## 30 k_Degradation Continental     marinesediment       Solid Continental
    ## 31 k_Degradation Continental        naturalsoil       Large Continental
    ## 32 k_Degradation Continental        naturalsoil       Small Continental
    ## 33 k_Degradation Continental        naturalsoil       Solid Continental
    ## 34 k_Degradation Continental          othersoil       Large Continental
    ## 35 k_Degradation Continental          othersoil       Small Continental
    ## 36 k_Degradation Continental          othersoil       Solid Continental
    ## 37 k_Degradation Continental              river       Large Continental
    ## 38 k_Degradation Continental              river       Small Continental
    ## 39 k_Degradation Continental              river       Solid Continental
    ## 40 k_Degradation Continental                sea       Large Continental
    ## 41 k_Degradation Continental                sea       Small Continental
    ## 42 k_Degradation Continental                sea       Solid Continental
    ## 43 k_Degradation    Moderate          deepocean       Large    Moderate
    ## 44 k_Degradation    Moderate          deepocean       Small    Moderate
    ## 45 k_Degradation    Moderate          deepocean       Solid    Moderate
    ## 46 k_Degradation    Moderate     marinesediment       Large    Moderate
    ## 47 k_Degradation    Moderate     marinesediment       Small    Moderate
    ## 48 k_Degradation    Moderate     marinesediment       Solid    Moderate
    ## 49 k_Degradation    Moderate        naturalsoil       Large    Moderate
    ## 50 k_Degradation    Moderate        naturalsoil       Small    Moderate
    ## 51 k_Degradation    Moderate        naturalsoil       Solid    Moderate
    ## 52 k_Degradation    Moderate                sea       Large    Moderate
    ## 53 k_Degradation    Moderate                sea       Small    Moderate
    ## 54 k_Degradation    Moderate                sea       Solid    Moderate
    ## 55 k_Degradation    Regional   agriculturalsoil       Large    Regional
    ## 56 k_Degradation    Regional   agriculturalsoil       Small    Regional
    ## 57 k_Degradation    Regional   agriculturalsoil       Solid    Regional
    ## 58 k_Degradation    Regional                air       Large    Regional
    ## 59 k_Degradation    Regional                air       Small    Regional
    ## 60 k_Degradation    Regional                air       Solid    Regional
    ## 61 k_Degradation    Regional freshwatersediment       Large    Regional
    ## 62 k_Degradation    Regional freshwatersediment       Small    Regional
    ## 63 k_Degradation    Regional freshwatersediment       Solid    Regional
    ## 64 k_Degradation    Regional               lake       Large    Regional
    ## 65 k_Degradation    Regional               lake       Small    Regional
    ## 66 k_Degradation    Regional               lake       Solid    Regional
    ## 67 k_Degradation    Regional       lakesediment       Large    Regional
    ## 68 k_Degradation    Regional       lakesediment       Small    Regional
    ## 69 k_Degradation    Regional       lakesediment       Solid    Regional
    ## 70 k_Degradation    Regional     marinesediment       Large    Regional
    ## 71 k_Degradation    Regional     marinesediment       Small    Regional
    ## 72 k_Degradation    Regional     marinesediment       Solid    Regional
    ## 73 k_Degradation    Regional        naturalsoil       Large    Regional
    ## 74 k_Degradation    Regional        naturalsoil       Small    Regional
    ## 75 k_Degradation    Regional        naturalsoil       Solid    Regional
    ## 76 k_Degradation    Regional          othersoil       Large    Regional
    ## 77 k_Degradation    Regional          othersoil       Small    Regional
    ## 78 k_Degradation    Regional          othersoil       Solid    Regional
    ## 79 k_Degradation    Regional              river       Large    Regional
    ## 80 k_Degradation    Regional              river       Small    Regional
    ## 81 k_Degradation    Regional              river       Solid    Regional
    ## 82 k_Degradation    Regional                sea       Large    Regional
    ## 83 k_Degradation    Regional                sea       Small    Regional
    ## 84 k_Degradation    Regional                sea       Solid    Regional
    ## 85 k_Degradation      Tropic          deepocean       Large      Tropic
    ## 86 k_Degradation      Tropic          deepocean       Small      Tropic
    ## 87 k_Degradation      Tropic          deepocean       Solid      Tropic
    ## 88 k_Degradation      Tropic     marinesediment       Large      Tropic
    ## 89 k_Degradation      Tropic     marinesediment       Small      Tropic
    ## 90 k_Degradation      Tropic     marinesediment       Solid      Tropic
    ## 91 k_Degradation      Tropic        naturalsoil       Large      Tropic
    ## 92 k_Degradation      Tropic        naturalsoil       Small      Tropic
    ## 93 k_Degradation      Tropic        naturalsoil       Solid      Tropic
    ## 94 k_Degradation      Tropic                sea       Large      Tropic
    ## 95 k_Degradation      Tropic                sea       Small      Tropic
    ## 96 k_Degradation      Tropic                sea       Solid      Tropic
    ##          toSubCompart toSpecies          Substance     k_Old        k_New
    ## 1           deepocean     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 2           deepocean     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 3           deepocean     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 4      marinesediment     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 5      marinesediment     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 6      marinesediment     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 7         naturalsoil     Large PET_sphere_example 1.504e-09 0.000000e+00
    ## 8         naturalsoil     Small PET_sphere_example 1.504e-09 0.000000e+00
    ## 9         naturalsoil     Solid PET_sphere_example 1.504e-09 0.000000e+00
    ## 10                sea     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 11                sea     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 12                sea     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 13   agriculturalsoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 14   agriculturalsoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 15   agriculturalsoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 16                air     Large PET_sphere_example 0.000e+00 6.060346e-09
    ## 17                air     Small PET_sphere_example 0.000e+00 6.060346e-09
    ## 18                air     Solid PET_sphere_example 0.000e+00 6.060346e-09
    ## 19 freshwatersediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 20 freshwatersediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 21 freshwatersediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 22               lake     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 23               lake     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 24               lake     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 25       lakesediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 26       lakesediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 27       lakesediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 28     marinesediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 29     marinesediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 30     marinesediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 31        naturalsoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 32        naturalsoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 33        naturalsoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 34          othersoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 35          othersoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 36          othersoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 37              river     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 38              river     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 39              river     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 40                sea     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 41                sea     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 42                sea     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 43          deepocean     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 44          deepocean     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 45          deepocean     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 46     marinesediment     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 47     marinesediment     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 48     marinesediment     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 49        naturalsoil     Large PET_sphere_example 1.504e-09 0.000000e+00
    ## 50        naturalsoil     Small PET_sphere_example 1.504e-09 0.000000e+00
    ## 51        naturalsoil     Solid PET_sphere_example 1.504e-09 0.000000e+00
    ## 52                sea     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 53                sea     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 54                sea     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 55   agriculturalsoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 56   agriculturalsoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 57   agriculturalsoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 58                air     Large PET_sphere_example 0.000e+00 6.060346e-09
    ## 59                air     Small PET_sphere_example 0.000e+00 6.060346e-09
    ## 60                air     Solid PET_sphere_example 0.000e+00 6.060346e-09
    ## 61 freshwatersediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 62 freshwatersediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 63 freshwatersediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 64               lake     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 65               lake     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 66               lake     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 67       lakesediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 68       lakesediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 69       lakesediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 70     marinesediment     Large PET_sphere_example 7.608e-10 3.658739e-10
    ## 71     marinesediment     Small PET_sphere_example 7.608e-10 3.658739e-10
    ## 72     marinesediment     Solid PET_sphere_example 7.608e-10 3.658739e-10
    ## 73        naturalsoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 74        naturalsoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 75        naturalsoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 76          othersoil     Large PET_sphere_example 1.504e-09 4.207419e-09
    ## 77          othersoil     Small PET_sphere_example 1.504e-09 4.207419e-09
    ## 78          othersoil     Solid PET_sphere_example 1.504e-09 4.207419e-09
    ## 79              river     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 80              river     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 81              river     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 82                sea     Large PET_sphere_example 7.608e-10 6.333243e-09
    ## 83                sea     Small PET_sphere_example 7.608e-10 6.333243e-09
    ## 84                sea     Solid PET_sphere_example 7.608e-10 6.333243e-09
    ## 85          deepocean     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 86          deepocean     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 87          deepocean     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 88     marinesediment     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 89     marinesediment     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 90     marinesediment     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ## 91        naturalsoil     Large PET_sphere_example 1.504e-09 0.000000e+00
    ## 92        naturalsoil     Small PET_sphere_example 1.504e-09 0.000000e+00
    ## 93        naturalsoil     Solid PET_sphere_example 1.504e-09 0.000000e+00
    ## 94                sea     Large PET_sphere_example 7.608e-10 0.000000e+00
    ## 95                sea     Small PET_sphere_example 7.608e-10 0.000000e+00
    ## 96                sea     Solid PET_sphere_example 7.608e-10 0.000000e+00
    ##             diff   rel_diff
    ## 1  -7.608000e-10       -Inf
    ## 2  -7.608000e-10       -Inf
    ## 3  -7.608000e-10       -Inf
    ## 4  -7.608000e-10       -Inf
    ## 5  -7.608000e-10       -Inf
    ## 6  -7.608000e-10       -Inf
    ## 7  -1.504000e-09       -Inf
    ## 8  -1.504000e-09       -Inf
    ## 9  -1.504000e-09       -Inf
    ## 10 -7.608000e-10       -Inf
    ## 11 -7.608000e-10       -Inf
    ## 12 -7.608000e-10       -Inf
    ## 13  2.703419e-09  0.6425362
    ## 14  2.703419e-09  0.6425362
    ## 15  2.703419e-09  0.6425362
    ## 16  6.060346e-09  1.0000000
    ## 17  6.060346e-09  1.0000000
    ## 18  6.060346e-09  1.0000000
    ## 19 -3.949261e-10 -1.0794050
    ## 20 -3.949261e-10 -1.0794050
    ## 21 -3.949261e-10 -1.0794050
    ## 22  5.572443e-09  0.8798720
    ## 23  5.572443e-09  0.8798720
    ## 24  5.572443e-09  0.8798720
    ## 25 -3.949261e-10 -1.0794050
    ## 26 -3.949261e-10 -1.0794050
    ## 27 -3.949261e-10 -1.0794050
    ## 28 -3.949261e-10 -1.0794050
    ## 29 -3.949261e-10 -1.0794050
    ## 30 -3.949261e-10 -1.0794050
    ## 31  2.703419e-09  0.6425362
    ## 32  2.703419e-09  0.6425362
    ## 33  2.703419e-09  0.6425362
    ## 34  2.703419e-09  0.6425362
    ## 35  2.703419e-09  0.6425362
    ## 36  2.703419e-09  0.6425362
    ## 37  5.572443e-09  0.8798720
    ## 38  5.572443e-09  0.8798720
    ## 39  5.572443e-09  0.8798720
    ## 40  5.572443e-09  0.8798720
    ## 41  5.572443e-09  0.8798720
    ## 42  5.572443e-09  0.8798720
    ## 43 -7.608000e-10       -Inf
    ## 44 -7.608000e-10       -Inf
    ## 45 -7.608000e-10       -Inf
    ## 46 -7.608000e-10       -Inf
    ## 47 -7.608000e-10       -Inf
    ## 48 -7.608000e-10       -Inf
    ## 49 -1.504000e-09       -Inf
    ## 50 -1.504000e-09       -Inf
    ## 51 -1.504000e-09       -Inf
    ## 52 -7.608000e-10       -Inf
    ## 53 -7.608000e-10       -Inf
    ## 54 -7.608000e-10       -Inf
    ## 55  2.703419e-09  0.6425362
    ## 56  2.703419e-09  0.6425362
    ## 57  2.703419e-09  0.6425362
    ## 58  6.060346e-09  1.0000000
    ## 59  6.060346e-09  1.0000000
    ## 60  6.060346e-09  1.0000000
    ## 61 -3.949261e-10 -1.0794050
    ## 62 -3.949261e-10 -1.0794050
    ## 63 -3.949261e-10 -1.0794050
    ## 64  5.572443e-09  0.8798720
    ## 65  5.572443e-09  0.8798720
    ## 66  5.572443e-09  0.8798720
    ## 67 -3.949261e-10 -1.0794050
    ## 68 -3.949261e-10 -1.0794050
    ## 69 -3.949261e-10 -1.0794050
    ## 70 -3.949261e-10 -1.0794050
    ## 71 -3.949261e-10 -1.0794050
    ## 72 -3.949261e-10 -1.0794050
    ## 73  2.703419e-09  0.6425362
    ## 74  2.703419e-09  0.6425362
    ## 75  2.703419e-09  0.6425362
    ## 76  2.703419e-09  0.6425362
    ## 77  2.703419e-09  0.6425362
    ## 78  2.703419e-09  0.6425362
    ## 79  5.572443e-09  0.8798720
    ## 80  5.572443e-09  0.8798720
    ## 81  5.572443e-09  0.8798720
    ## 82  5.572443e-09  0.8798720
    ## 83  5.572443e-09  0.8798720
    ## 84  5.572443e-09  0.8798720
    ## 85 -7.608000e-10       -Inf
    ## 86 -7.608000e-10       -Inf
    ## 87 -7.608000e-10       -Inf
    ## 88 -7.608000e-10       -Inf
    ## 89 -7.608000e-10       -Inf
    ## 90 -7.608000e-10       -Inf
    ## 91 -1.504000e-09       -Inf
    ## 92 -1.504000e-09       -Inf
    ## 93 -1.504000e-09       -Inf
    ## 94 -7.608000e-10       -Inf
    ## 95 -7.608000e-10       -Inf
    ## 96 -7.608000e-10       -Inf
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
    ## 16                               From air_Continental to air_Continental
    ## 17                               From air_Continental to air_Continental
    ## 18                               From air_Continental to air_Continental
    ## 19 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 20 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 21 From freshwatersediment_Continental to freshwatersediment_Continental
    ## 22                             From lake_Continental to lake_Continental
    ## 23                             From lake_Continental to lake_Continental
    ## 24                             From lake_Continental to lake_Continental
    ## 25             From lakesediment_Continental to lakesediment_Continental
    ## 26             From lakesediment_Continental to lakesediment_Continental
    ## 27             From lakesediment_Continental to lakesediment_Continental
    ## 28         From marinesediment_Continental to marinesediment_Continental
    ## 29         From marinesediment_Continental to marinesediment_Continental
    ## 30         From marinesediment_Continental to marinesediment_Continental
    ## 31               From naturalsoil_Continental to naturalsoil_Continental
    ## 32               From naturalsoil_Continental to naturalsoil_Continental
    ## 33               From naturalsoil_Continental to naturalsoil_Continental
    ## 34                   From othersoil_Continental to othersoil_Continental
    ## 35                   From othersoil_Continental to othersoil_Continental
    ## 36                   From othersoil_Continental to othersoil_Continental
    ## 37                           From river_Continental to river_Continental
    ## 38                           From river_Continental to river_Continental
    ## 39                           From river_Continental to river_Continental
    ## 40                               From sea_Continental to sea_Continental
    ## 41                               From sea_Continental to sea_Continental
    ## 42                               From sea_Continental to sea_Continental
    ## 43                         From deepocean_Moderate to deepocean_Moderate
    ## 44                         From deepocean_Moderate to deepocean_Moderate
    ## 45                         From deepocean_Moderate to deepocean_Moderate
    ## 46               From marinesediment_Moderate to marinesediment_Moderate
    ## 47               From marinesediment_Moderate to marinesediment_Moderate
    ## 48               From marinesediment_Moderate to marinesediment_Moderate
    ## 49                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 50                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 51                     From naturalsoil_Moderate to naturalsoil_Moderate
    ## 52                                     From sea_Moderate to sea_Moderate
    ## 53                                     From sea_Moderate to sea_Moderate
    ## 54                                     From sea_Moderate to sea_Moderate
    ## 55           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 56           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 57           From agriculturalsoil_Regional to agriculturalsoil_Regional
    ## 58                                     From air_Regional to air_Regional
    ## 59                                     From air_Regional to air_Regional
    ## 60                                     From air_Regional to air_Regional
    ## 61       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 62       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 63       From freshwatersediment_Regional to freshwatersediment_Regional
    ## 64                                   From lake_Regional to lake_Regional
    ## 65                                   From lake_Regional to lake_Regional
    ## 66                                   From lake_Regional to lake_Regional
    ## 67                   From lakesediment_Regional to lakesediment_Regional
    ## 68                   From lakesediment_Regional to lakesediment_Regional
    ## 69                   From lakesediment_Regional to lakesediment_Regional
    ## 70               From marinesediment_Regional to marinesediment_Regional
    ## 71               From marinesediment_Regional to marinesediment_Regional
    ## 72               From marinesediment_Regional to marinesediment_Regional
    ## 73                     From naturalsoil_Regional to naturalsoil_Regional
    ## 74                     From naturalsoil_Regional to naturalsoil_Regional
    ## 75                     From naturalsoil_Regional to naturalsoil_Regional
    ## 76                         From othersoil_Regional to othersoil_Regional
    ## 77                         From othersoil_Regional to othersoil_Regional
    ## 78                         From othersoil_Regional to othersoil_Regional
    ## 79                                 From river_Regional to river_Regional
    ## 80                                 From river_Regional to river_Regional
    ## 81                                 From river_Regional to river_Regional
    ## 82                                     From sea_Regional to sea_Regional
    ## 83                                     From sea_Regional to sea_Regional
    ## 84                                     From sea_Regional to sea_Regional
    ## 85                             From deepocean_Tropic to deepocean_Tropic
    ## 86                             From deepocean_Tropic to deepocean_Tropic
    ## 87                             From deepocean_Tropic to deepocean_Tropic
    ## 88                   From marinesediment_Tropic to marinesediment_Tropic
    ## 89                   From marinesediment_Tropic to marinesediment_Tropic
    ## 90                   From marinesediment_Tropic to marinesediment_Tropic
    ## 91                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 92                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 93                         From naturalsoil_Tropic to naturalsoil_Tropic
    ## 94                                         From sea_Tropic to sea_Tropic
    ## 95                                         From sea_Tropic to sea_Tropic
    ## 96                                         From sea_Tropic to sea_Tropic

As can be seen in the figures below, the new degradation rate constants
for microplastic, have a very large difference, max - % larger compared
to the previous default kdeg value’s. The figures below also show this
and and that the code still works as expected for the other compounds
for which no Kssdr is defined. The larger degradation rates for
microplastics is as expected due to the Kssdr implementation. Further
examples should illustrate the validity of this modification, e.g.
comparing to measuresments etc.

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
  
  print(absdif_plot)
  
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
  print(reldif_plot)
}
```

![](20251004_Plastics_plasticfade_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20251004_Plastics_plasticfade_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->
