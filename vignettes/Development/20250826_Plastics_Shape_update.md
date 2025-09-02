Comparison shape update
================
Nadim Saadi, Valerie de Rijk, Anne Hids, Joris Quik
2025-09-02

# Explanation of update

This explains the way we include drag of particles with shapes different
to a sphere.

Several processes which depend on the settling velocity now are
dependant on the Setlling Velocity solver based on a specific Drag
method.

The updated functions are:

- f_SetVelWater and v_SettlingVelocity

  - For which several functions are introduced or changed to cope with
    shape:

  - R/f_DragCoefficient.R

  - R/f_SetVelSolver.R

  - R/f_PerimeterParticle.R

  - R/f_SurfaceAreaParticle.R

  - R/f_Vol.R

  - R/v_rad_species.R

  - R/v_rho_species.R

- f_Grav.R and R/k_HeteroAgglomeration.wsd.R

  - In future shape could also be included for SPM, now still sphere
    assumed representative

- k_Resuspension due to update of f_SetVelWater

- R/k_Sedimentation.R due to update of f_SetVelWater

<!-- -->

    ## [1] "Directory: SBzips created."

    ## [1] "The SimpleBox model can be found in SimpleBox"

As this update was only implemented for microplastics and tyre road wear
particles, we will test for these substances. To be sure nothing changed
for the other substances, we will also test one other substance.

    ## [1] "kdis is missing, setting kdis = 0"

Do the same for the other implementation.

## Compare the k values for each of the substances

    ##             process   fromScale fromSubCompart fromSpecies     toScale
    ## 1    k_CWscavenging      Arctic            air       Small      Arctic
    ## 2    k_CWscavenging      Arctic            air       Small      Arctic
    ## 3    k_CWscavenging      Arctic            air       Small      Arctic
    ## 4    k_CWscavenging Continental            air       Small Continental
    ## 5    k_CWscavenging Continental            air       Small Continental
    ## 6    k_CWscavenging Continental            air       Small Continental
    ## 7    k_CWscavenging    Moderate            air       Small    Moderate
    ## 8    k_CWscavenging    Moderate            air       Small    Moderate
    ## 9    k_CWscavenging    Moderate            air       Small    Moderate
    ## 10   k_CWscavenging    Regional            air       Small    Regional
    ## 11   k_CWscavenging    Regional            air       Small    Regional
    ## 12   k_CWscavenging    Regional            air       Small    Regional
    ## 13   k_CWscavenging      Tropic            air       Small      Tropic
    ## 14   k_CWscavenging      Tropic            air       Small      Tropic
    ## 15   k_CWscavenging      Tropic            air       Small      Tropic
    ## 16  k_DryDeposition      Arctic            air       Small      Arctic
    ## 17  k_DryDeposition      Arctic            air       Small      Arctic
    ## 18  k_DryDeposition      Arctic            air       Small      Arctic
    ## 19  k_DryDeposition      Arctic            air       Small      Arctic
    ## 20  k_DryDeposition      Arctic            air       Small      Arctic
    ## 21  k_DryDeposition      Arctic            air       Small      Arctic
    ## 22  k_DryDeposition Continental            air       Small Continental
    ## 23  k_DryDeposition Continental            air       Small Continental
    ## 24  k_DryDeposition Continental            air       Small Continental
    ## 25  k_DryDeposition Continental            air       Small Continental
    ## 26  k_DryDeposition Continental            air       Small Continental
    ## 27  k_DryDeposition Continental            air       Small Continental
    ## 28  k_DryDeposition Continental            air       Small Continental
    ## 29  k_DryDeposition Continental            air       Small Continental
    ## 30  k_DryDeposition Continental            air       Small Continental
    ## 31  k_DryDeposition Continental            air       Small Continental
    ## 32  k_DryDeposition Continental            air       Small Continental
    ## 33  k_DryDeposition Continental            air       Small Continental
    ## 34  k_DryDeposition Continental            air       Small Continental
    ## 35  k_DryDeposition Continental            air       Small Continental
    ## 36  k_DryDeposition Continental            air       Small Continental
    ## 37  k_DryDeposition Continental            air       Small Continental
    ## 38  k_DryDeposition Continental            air       Small Continental
    ## 39  k_DryDeposition Continental            air       Small Continental
    ## 40  k_DryDeposition    Moderate            air       Small    Moderate
    ## 41  k_DryDeposition    Moderate            air       Small    Moderate
    ## 42  k_DryDeposition    Moderate            air       Small    Moderate
    ## 43  k_DryDeposition    Moderate            air       Small    Moderate
    ## 44  k_DryDeposition    Moderate            air       Small    Moderate
    ## 45  k_DryDeposition    Moderate            air       Small    Moderate
    ## 46  k_DryDeposition    Regional            air       Small    Regional
    ## 47  k_DryDeposition    Regional            air       Small    Regional
    ## 48  k_DryDeposition    Regional            air       Small    Regional
    ## 49  k_DryDeposition    Regional            air       Small    Regional
    ## 50  k_DryDeposition    Regional            air       Small    Regional
    ## 51  k_DryDeposition    Regional            air       Small    Regional
    ## 52  k_DryDeposition    Regional            air       Small    Regional
    ## 53  k_DryDeposition    Regional            air       Small    Regional
    ## 54  k_DryDeposition    Regional            air       Small    Regional
    ## 55  k_DryDeposition    Regional            air       Small    Regional
    ## 56  k_DryDeposition    Regional            air       Small    Regional
    ## 57  k_DryDeposition    Regional            air       Small    Regional
    ## 58  k_DryDeposition    Regional            air       Small    Regional
    ## 59  k_DryDeposition    Regional            air       Small    Regional
    ## 60  k_DryDeposition    Regional            air       Small    Regional
    ## 61  k_DryDeposition    Regional            air       Small    Regional
    ## 62  k_DryDeposition    Regional            air       Small    Regional
    ## 63  k_DryDeposition    Regional            air       Small    Regional
    ## 64  k_DryDeposition      Tropic            air       Small      Tropic
    ## 65  k_DryDeposition      Tropic            air       Small      Tropic
    ## 66  k_DryDeposition      Tropic            air       Small      Tropic
    ## 67  k_DryDeposition      Tropic            air       Small      Tropic
    ## 68  k_DryDeposition      Tropic            air       Small      Tropic
    ## 69  k_DryDeposition      Tropic            air       Small      Tropic
    ## 70  k_Sedimentation      Arctic      deepocean       Large      Arctic
    ## 71  k_Sedimentation      Arctic      deepocean       Large      Arctic
    ## 72  k_Sedimentation      Arctic      deepocean       Large      Arctic
    ## 73  k_Sedimentation      Arctic      deepocean       Small      Arctic
    ## 74  k_Sedimentation      Arctic      deepocean       Small      Arctic
    ## 75  k_Sedimentation      Arctic      deepocean       Small      Arctic
    ## 76  k_Sedimentation      Arctic            sea       Large      Arctic
    ## 77  k_Sedimentation      Arctic            sea       Large      Arctic
    ## 78  k_Sedimentation      Arctic            sea       Large      Arctic
    ## 79  k_Sedimentation      Arctic            sea       Small      Arctic
    ## 80  k_Sedimentation      Arctic            sea       Small      Arctic
    ## 81  k_Sedimentation      Arctic            sea       Small      Arctic
    ## 82  k_Sedimentation Continental           lake       Large Continental
    ## 83  k_Sedimentation Continental           lake       Large Continental
    ## 84  k_Sedimentation Continental           lake       Large Continental
    ## 85  k_Sedimentation Continental           lake       Small Continental
    ## 86  k_Sedimentation Continental           lake       Small Continental
    ## 87  k_Sedimentation Continental           lake       Small Continental
    ## 88  k_Sedimentation Continental          river       Large Continental
    ## 89  k_Sedimentation Continental          river       Large Continental
    ## 90  k_Sedimentation Continental          river       Large Continental
    ## 91  k_Sedimentation Continental          river       Small Continental
    ## 92  k_Sedimentation Continental          river       Small Continental
    ## 93  k_Sedimentation Continental          river       Small Continental
    ## 94  k_Sedimentation Continental            sea       Large Continental
    ## 95  k_Sedimentation Continental            sea       Large Continental
    ## 96  k_Sedimentation Continental            sea       Large Continental
    ## 97  k_Sedimentation Continental            sea       Small Continental
    ## 98  k_Sedimentation Continental            sea       Small Continental
    ## 99  k_Sedimentation Continental            sea       Small Continental
    ## 100 k_Sedimentation    Moderate      deepocean       Large    Moderate
    ## 101 k_Sedimentation    Moderate      deepocean       Large    Moderate
    ## 102 k_Sedimentation    Moderate      deepocean       Large    Moderate
    ## 103 k_Sedimentation    Moderate      deepocean       Small    Moderate
    ## 104 k_Sedimentation    Moderate      deepocean       Small    Moderate
    ## 105 k_Sedimentation    Moderate      deepocean       Small    Moderate
    ## 106 k_Sedimentation    Moderate            sea       Large    Moderate
    ## 107 k_Sedimentation    Moderate            sea       Large    Moderate
    ## 108 k_Sedimentation    Moderate            sea       Large    Moderate
    ## 109 k_Sedimentation    Moderate            sea       Small    Moderate
    ## 110 k_Sedimentation    Moderate            sea       Small    Moderate
    ## 111 k_Sedimentation    Moderate            sea       Small    Moderate
    ## 112 k_Sedimentation    Regional           lake       Large    Regional
    ## 113 k_Sedimentation    Regional           lake       Large    Regional
    ## 114 k_Sedimentation    Regional           lake       Large    Regional
    ## 115 k_Sedimentation    Regional           lake       Small    Regional
    ## 116 k_Sedimentation    Regional           lake       Small    Regional
    ## 117 k_Sedimentation    Regional           lake       Small    Regional
    ## 118 k_Sedimentation    Regional          river       Large    Regional
    ## 119 k_Sedimentation    Regional          river       Large    Regional
    ## 120 k_Sedimentation    Regional          river       Large    Regional
    ## 121 k_Sedimentation    Regional          river       Small    Regional
    ## 122 k_Sedimentation    Regional          river       Small    Regional
    ## 123 k_Sedimentation    Regional          river       Small    Regional
    ## 124 k_Sedimentation    Regional            sea       Large    Regional
    ## 125 k_Sedimentation    Regional            sea       Large    Regional
    ## 126 k_Sedimentation    Regional            sea       Large    Regional
    ## 127 k_Sedimentation    Regional            sea       Small    Regional
    ## 128 k_Sedimentation    Regional            sea       Small    Regional
    ## 129 k_Sedimentation    Regional            sea       Small    Regional
    ## 130 k_Sedimentation      Tropic      deepocean       Large      Tropic
    ## 131 k_Sedimentation      Tropic      deepocean       Large      Tropic
    ## 132 k_Sedimentation      Tropic      deepocean       Large      Tropic
    ## 133 k_Sedimentation      Tropic      deepocean       Small      Tropic
    ## 134 k_Sedimentation      Tropic      deepocean       Small      Tropic
    ## 135 k_Sedimentation      Tropic      deepocean       Small      Tropic
    ## 136 k_Sedimentation      Tropic            sea       Large      Tropic
    ## 137 k_Sedimentation      Tropic            sea       Large      Tropic
    ## 138 k_Sedimentation      Tropic            sea       Large      Tropic
    ## 139 k_Sedimentation      Tropic            sea       Small      Tropic
    ## 140 k_Sedimentation      Tropic            sea       Small      Tropic
    ## 141 k_Sedimentation      Tropic            sea       Small      Tropic
    ##           toSubCompart toSpecies    Substance        k_Old        k_New
    ## 1           cloudwater     Small microplastic 1.194489e-04 1.194489e-04
    ## 2           cloudwater     Small     nAg_10nm 1.090572e-07 1.090572e-07
    ## 3           cloudwater     Small         TRWP 1.194489e-04 1.194489e-04
    ## 4           cloudwater     Small microplastic 2.314685e-04 2.314685e-04
    ## 5           cloudwater     Small     nAg_10nm 1.748383e-07 1.748383e-07
    ## 6           cloudwater     Small         TRWP 2.314685e-04 2.314685e-04
    ## 7           cloudwater     Small microplastic 2.314685e-04 2.314685e-04
    ## 8           cloudwater     Small     nAg_10nm 1.748383e-07 1.748383e-07
    ## 9           cloudwater     Small         TRWP 2.314685e-04 2.314685e-04
    ## 10          cloudwater     Small microplastic 2.314685e-04 2.314685e-04
    ## 11          cloudwater     Small     nAg_10nm 1.748383e-07 1.748383e-07
    ## 12          cloudwater     Small         TRWP 2.314685e-04 2.314685e-04
    ## 13          cloudwater     Small microplastic 3.460916e-04 3.460916e-04
    ## 14          cloudwater     Small     nAg_10nm 2.322225e-07 2.322225e-07
    ## 15          cloudwater     Small         TRWP 3.460916e-04 3.460916e-04
    ## 16         naturalsoil     Small microplastic 4.321720e-05 4.321720e-05
    ## 17         naturalsoil     Small     nAg_10nm 7.533075e-07 7.533075e-07
    ## 18         naturalsoil     Small         TRWP 4.321720e-05 4.321720e-05
    ## 19                 sea     Small microplastic 5.881692e-05 5.881692e-05
    ## 20                 sea     Small     nAg_10nm 1.687410e-06 1.687410e-06
    ## 21                 sea     Small         TRWP 5.881692e-05 5.881692e-05
    ## 22    agriculturalsoil     Small microplastic 3.120520e-05 3.120520e-05
    ## 23    agriculturalsoil     Small     nAg_10nm 6.712053e-07 6.712052e-07
    ## 24    agriculturalsoil     Small         TRWP 3.120520e-05 3.120520e-05
    ## 25                lake     Small microplastic 1.186619e-07 1.186619e-07
    ## 26                lake     Small     nAg_10nm 3.513825e-09 3.513825e-09
    ## 27                lake     Small         TRWP 1.186619e-07 1.186619e-07
    ## 28         naturalsoil     Small microplastic 1.412475e-05 1.412475e-05
    ## 29         naturalsoil     Small     nAg_10nm 2.558862e-07 2.558862e-07
    ## 30         naturalsoil     Small         TRWP 1.412475e-05 1.412475e-05
    ## 31           othersoil     Small microplastic 4.914804e-06 4.914804e-06
    ## 32           othersoil     Small     nAg_10nm 9.488775e-08 9.488775e-08
    ## 33           othersoil     Small         TRWP 4.914804e-06 4.914804e-06
    ## 34               river     Small microplastic 1.305281e-06 1.305281e-06
    ## 35               river     Small     nAg_10nm 3.865207e-08 3.865207e-08
    ## 36               river     Small         TRWP 1.305281e-06 1.305281e-06
    ## 37                 sea     Small microplastic 5.056345e-05 5.056345e-05
    ## 38                 sea     Small     nAg_10nm 1.497289e-06 1.497289e-06
    ## 39                 sea     Small         TRWP 5.056345e-05 5.056345e-05
    ## 40         naturalsoil     Small microplastic 5.402153e-05 5.402153e-05
    ## 41         naturalsoil     Small     nAg_10nm 9.786626e-07 9.786626e-07
    ## 42         naturalsoil     Small         TRWP 5.402153e-05 5.402153e-05
    ## 43                 sea     Small microplastic 4.901410e-05 4.901410e-05
    ## 44                 sea     Small     nAg_10nm 1.451409e-06 1.451409e-06
    ## 45                 sea     Small         TRWP 4.901410e-05 4.901410e-05
    ## 46    agriculturalsoil     Small microplastic 6.416688e-05 6.416688e-05
    ## 47    agriculturalsoil     Small     nAg_10nm 1.380191e-06 1.380191e-06
    ## 48    agriculturalsoil     Small         TRWP 6.416688e-05 6.416688e-05
    ## 49                lake     Small microplastic 2.440030e-07 2.440030e-07
    ## 50                lake     Small     nAg_10nm 7.225435e-09 7.225435e-09
    ## 51                lake     Small         TRWP 2.440030e-07 2.440030e-07
    ## 52         naturalsoil     Small microplastic 2.904455e-05 2.904455e-05
    ## 53         naturalsoil     Small     nAg_10nm 5.261758e-07 5.261758e-07
    ## 54         naturalsoil     Small         TRWP 2.904455e-05 2.904455e-05
    ## 55           othersoil     Small microplastic 1.010625e-05 1.010625e-05
    ## 56           othersoil     Small     nAg_10nm 1.951165e-07 1.951165e-07
    ## 57           othersoil     Small         TRWP 1.010625e-05 1.010625e-05
    ## 58               river     Small microplastic 2.684033e-06 2.684033e-06
    ## 59               river     Small     nAg_10nm 7.947979e-08 7.947979e-08
    ## 60               river     Small         TRWP 2.684033e-06 2.684033e-06
    ## 61                 sea     Small microplastic 4.270079e-07 4.270079e-07
    ## 62                 sea     Small     nAg_10nm 1.264459e-08 1.264459e-08
    ## 63                 sea     Small         TRWP 4.270079e-07 4.270079e-07
    ## 64         naturalsoil     Small microplastic 3.241292e-05 3.241292e-05
    ## 65         naturalsoil     Small     nAg_10nm 5.998438e-07 5.998438e-07
    ## 66         naturalsoil     Small         TRWP 3.241292e-05 3.241292e-05
    ## 67                 sea     Small microplastic 6.861974e-05 6.861974e-05
    ## 68                 sea     Small     nAg_10nm 2.067768e-06 2.067768e-06
    ## 69                 sea     Small         TRWP 6.861974e-05 6.861974e-05
    ## 70      marinesediment     Large microplastic 1.379344e-07 1.379344e-07
    ## 71      marinesediment     Large     nAg_10nm 9.800126e-09 9.800125e-09
    ## 72      marinesediment     Large         TRWP 1.379344e-07 1.379344e-07
    ## 73      marinesediment     Small microplastic 1.368379e-07 1.368379e-07
    ## 74      marinesediment     Small     nAg_10nm 1.634996e-11 1.634995e-11
    ## 75      marinesediment     Small         TRWP 1.368379e-07 1.368379e-07
    ## 76           deepocean     Large microplastic 4.138033e-06 4.138032e-06
    ## 77           deepocean     Large     nAg_10nm 2.940038e-07 2.940038e-07
    ## 78           deepocean     Large         TRWP 4.138033e-06 4.138032e-06
    ## 79           deepocean     Small microplastic 4.105137e-06 4.105137e-06
    ## 80           deepocean     Small     nAg_10nm 4.904987e-10 4.904986e-10
    ## 81           deepocean     Small         TRWP 4.105137e-06 4.105137e-06
    ## 82        lakesediment     Large microplastic 4.138033e-06 4.138032e-06
    ## 83        lakesediment     Large     nAg_10nm 2.940038e-07 2.940038e-07
    ## 84        lakesediment     Large         TRWP 4.138033e-06 4.138032e-06
    ## 85        lakesediment     Small microplastic 4.105137e-06 4.105137e-06
    ## 86        lakesediment     Small     nAg_10nm 4.904987e-10 4.904986e-10
    ## 87        lakesediment     Small         TRWP 4.105137e-06 4.105137e-06
    ## 88  freshwatersediment     Large microplastic 1.379344e-04 1.379344e-04
    ## 89  freshwatersediment     Large     nAg_10nm 9.800126e-06 9.800125e-06
    ## 90  freshwatersediment     Large         TRWP 1.379344e-04 1.379344e-04
    ## 91  freshwatersediment     Small microplastic 1.368379e-04 1.368379e-04
    ## 92  freshwatersediment     Small     nAg_10nm 1.634996e-08 1.634995e-08
    ## 93  freshwatersediment     Small         TRWP 1.368379e-04 1.368379e-04
    ## 94      marinesediment     Large microplastic 2.069016e-06 2.069016e-06
    ## 95      marinesediment     Large     nAg_10nm 1.470019e-07 1.470019e-07
    ## 96      marinesediment     Large         TRWP 2.069016e-06 2.069016e-06
    ## 97      marinesediment     Small microplastic 2.052569e-06 2.052568e-06
    ## 98      marinesediment     Small     nAg_10nm 2.452493e-10 2.452493e-10
    ## 99      marinesediment     Small         TRWP 2.052569e-06 2.052568e-06
    ## 100     marinesediment     Large microplastic 1.379344e-07 1.379344e-07
    ## 101     marinesediment     Large     nAg_10nm 9.800126e-09 9.800125e-09
    ## 102     marinesediment     Large         TRWP 1.379344e-07 1.379344e-07
    ## 103     marinesediment     Small microplastic 1.368379e-07 1.368379e-07
    ## 104     marinesediment     Small     nAg_10nm 1.634996e-11 1.634995e-11
    ## 105     marinesediment     Small         TRWP 1.368379e-07 1.368379e-07
    ## 106          deepocean     Large microplastic 4.138033e-06 4.138032e-06
    ## 107          deepocean     Large     nAg_10nm 2.940038e-07 2.940038e-07
    ## 108          deepocean     Large         TRWP 4.138033e-06 4.138032e-06
    ## 109          deepocean     Small microplastic 4.105137e-06 4.105137e-06
    ## 110          deepocean     Small     nAg_10nm 4.904987e-10 4.904986e-10
    ## 111          deepocean     Small         TRWP 4.105137e-06 4.105137e-06
    ## 112       lakesediment     Large microplastic 4.138033e-06 4.138032e-06
    ## 113       lakesediment     Large     nAg_10nm 2.940038e-07 2.940038e-07
    ## 114       lakesediment     Large         TRWP 4.138033e-06 4.138032e-06
    ## 115       lakesediment     Small microplastic 4.105137e-06 4.105137e-06
    ## 116       lakesediment     Small     nAg_10nm 4.904987e-10 4.904986e-10
    ## 117       lakesediment     Small         TRWP 4.105137e-06 4.105137e-06
    ## 118 freshwatersediment     Large microplastic 1.379344e-04 1.379344e-04
    ## 119 freshwatersediment     Large     nAg_10nm 9.800126e-06 9.800125e-06
    ## 120 freshwatersediment     Large         TRWP 1.379344e-04 1.379344e-04
    ## 121 freshwatersediment     Small microplastic 1.368379e-04 1.368379e-04
    ## 122 freshwatersediment     Small     nAg_10nm 1.634996e-08 1.634995e-08
    ## 123 freshwatersediment     Small         TRWP 1.368379e-04 1.368379e-04
    ## 124     marinesediment     Large microplastic 4.138033e-05 4.138032e-05
    ## 125     marinesediment     Large     nAg_10nm 2.940038e-06 2.940038e-06
    ## 126     marinesediment     Large         TRWP 4.138033e-05 4.138032e-05
    ## 127     marinesediment     Small microplastic 4.105137e-05 4.105137e-05
    ## 128     marinesediment     Small     nAg_10nm 4.904987e-09 4.904986e-09
    ## 129     marinesediment     Small         TRWP 4.105137e-05 4.105137e-05
    ## 130     marinesediment     Large microplastic 1.379344e-07 1.379344e-07
    ## 131     marinesediment     Large     nAg_10nm 9.800126e-09 9.800125e-09
    ## 132     marinesediment     Large         TRWP 1.379344e-07 1.379344e-07
    ## 133     marinesediment     Small microplastic 1.368379e-07 1.368379e-07
    ## 134     marinesediment     Small     nAg_10nm 1.634996e-11 1.634995e-11
    ## 135     marinesediment     Small         TRWP 1.368379e-07 1.368379e-07
    ## 136          deepocean     Large microplastic 4.138033e-06 4.138032e-06
    ## 137          deepocean     Large     nAg_10nm 2.940038e-07 2.940038e-07
    ## 138          deepocean     Large         TRWP 4.138033e-06 4.138032e-06
    ## 139          deepocean     Small microplastic 4.105137e-06 4.105137e-06
    ## 140          deepocean     Small     nAg_10nm 4.904987e-10 4.904986e-10
    ## 141          deepocean     Small         TRWP 4.105137e-06 4.105137e-06
    ##              diff      rel_diff
    ## 1    1.355911e-12  1.135139e-08
    ## 2   -2.424064e-17 -2.222746e-10
    ## 3    1.355911e-12  1.135139e-08
    ## 4    2.508019e-12  1.083525e-08
    ## 5    8.916157e-17  5.099660e-10
    ## 6    2.508019e-12  1.083525e-08
    ## 7    2.508019e-12  1.083525e-08
    ## 8    8.916157e-17  5.099660e-10
    ## 9    2.508019e-12  1.083525e-08
    ## 10   2.508019e-12  1.083525e-08
    ## 11   8.916157e-17  5.099660e-10
    ## 12   2.508019e-12  1.083525e-08
    ## 13   3.634969e-12  1.050291e-08
    ## 14   2.238247e-16  9.638374e-10
    ## 15   3.634969e-12  1.050291e-08
    ## 16   8.478991e-13  1.961948e-08
    ## 17  -1.083979e-14 -1.438960e-08
    ## 18   8.478991e-13  1.961948e-08
    ## 19   1.244649e-12  2.116142e-08
    ## 20  -2.151259e-14 -1.274888e-08
    ## 21   1.244649e-12  2.116142e-08
    ## 22   6.186975e-13  1.982674e-08
    ## 23  -8.974735e-15 -1.337107e-08
    ## 24   6.186975e-13  1.982674e-08
    ## 25   2.511053e-15  2.116142e-08
    ## 26  -4.442033e-17 -1.264159e-08
    ## 27   2.511053e-15  2.116142e-08
    ## 28   2.771199e-13  1.961946e-08
    ## 29  -3.658905e-15 -1.429895e-08
    ## 30   2.771199e-13  1.961946e-08
    ## 31   1.045350e-13  2.126940e-08
    ## 32  -1.355318e-15 -1.428338e-08
    ## 33   1.045350e-13  2.126940e-08
    ## 34   2.762159e-14  2.116142e-08
    ## 35  -4.886237e-16 -1.264159e-08
    ## 36   2.762159e-14  2.116142e-08
    ## 37   1.069994e-12  2.116142e-08
    ## 38  -1.892811e-14 -1.264159e-08
    ## 39   1.069994e-12  2.116142e-08
    ## 40   1.059873e-12  1.961946e-08
    ## 41  -1.399385e-14 -1.429895e-08
    ## 42   1.059873e-12  1.961946e-08
    ## 43   1.037208e-12  2.116142e-08
    ## 44  -1.834812e-14 -1.264159e-08
    ## 45   1.037208e-12  2.116142e-08
    ## 46   1.272220e-12  1.982674e-08
    ## 47  -1.845464e-14 -1.337107e-08
    ## 48   1.272220e-12  1.982674e-08
    ## 49   5.163449e-15  2.116142e-08
    ## 50  -9.134099e-17 -1.264159e-08
    ## 51   5.163449e-15  2.116142e-08
    ## 52   5.698383e-13  1.961946e-08
    ## 53  -7.523763e-15 -1.429895e-08
    ## 54   5.698383e-13  1.961946e-08
    ## 55   2.149539e-13  2.126940e-08
    ## 56  -2.786924e-15 -1.428338e-08
    ## 57   2.149539e-13  2.126940e-08
    ## 58   5.679794e-14  2.116142e-08
    ## 59  -1.004751e-15 -1.264159e-08
    ## 60   5.679794e-14  2.116142e-08
    ## 61   9.036092e-15  2.116142e-08
    ## 62  -1.598477e-16 -1.264159e-08
    ## 63   9.036092e-15  2.116142e-08
    ## 64   6.359234e-13  1.961944e-08
    ## 65  -8.546167e-15 -1.424732e-08
    ## 66   6.359234e-13  1.961944e-08
    ## 67   1.452091e-12  2.116142e-08
    ## 68  -2.601445e-14 -1.258093e-08
    ## 69   1.452091e-12  2.116142e-08
    ## 70  -1.585270e-14 -1.149293e-07
    ## 71  -3.730519e-16 -3.806603e-08
    ## 72  -1.585270e-14 -1.149293e-07
    ## 73  -1.582539e-14 -1.156506e-07
    ## 74  -1.024285e-18 -6.264756e-08
    ## 75  -1.582539e-14 -1.156506e-07
    ## 76  -4.755811e-13 -1.149293e-07
    ## 77  -1.119156e-14 -3.806603e-08
    ## 78  -4.755811e-13 -1.149293e-07
    ## 79  -4.747617e-13 -1.156506e-07
    ## 80  -3.072854e-17 -6.264756e-08
    ## 81  -4.747617e-13 -1.156506e-07
    ## 82  -4.755811e-13 -1.149293e-07
    ## 83  -1.119156e-14 -3.806603e-08
    ## 84  -4.755811e-13 -1.149293e-07
    ## 85  -4.747617e-13 -1.156506e-07
    ## 86  -3.072854e-17 -6.264756e-08
    ## 87  -4.747617e-13 -1.156506e-07
    ## 88  -1.585270e-11 -1.149293e-07
    ## 89  -3.730519e-13 -3.806603e-08
    ## 90  -1.585270e-11 -1.149293e-07
    ## 91  -1.582539e-11 -1.156506e-07
    ## 92  -1.024285e-15 -6.264756e-08
    ## 93  -1.582539e-11 -1.156506e-07
    ## 94  -2.377905e-13 -1.149293e-07
    ## 95  -5.595778e-15 -3.806603e-08
    ## 96  -2.377905e-13 -1.149293e-07
    ## 97  -2.373809e-13 -1.156506e-07
    ## 98  -1.536427e-17 -6.264756e-08
    ## 99  -2.373809e-13 -1.156506e-07
    ## 100 -1.585270e-14 -1.149293e-07
    ## 101 -3.730519e-16 -3.806603e-08
    ## 102 -1.585270e-14 -1.149293e-07
    ## 103 -1.582539e-14 -1.156506e-07
    ## 104 -1.024285e-18 -6.264756e-08
    ## 105 -1.582539e-14 -1.156506e-07
    ## 106 -4.755811e-13 -1.149293e-07
    ## 107 -1.119156e-14 -3.806603e-08
    ## 108 -4.755811e-13 -1.149293e-07
    ## 109 -4.747617e-13 -1.156506e-07
    ## 110 -3.072854e-17 -6.264756e-08
    ## 111 -4.747617e-13 -1.156506e-07
    ## 112 -4.755811e-13 -1.149293e-07
    ## 113 -1.119156e-14 -3.806603e-08
    ## 114 -4.755811e-13 -1.149293e-07
    ## 115 -4.747617e-13 -1.156506e-07
    ## 116 -3.072854e-17 -6.264756e-08
    ## 117 -4.747617e-13 -1.156506e-07
    ## 118 -1.585270e-11 -1.149293e-07
    ## 119 -3.730519e-13 -3.806603e-08
    ## 120 -1.585270e-11 -1.149293e-07
    ## 121 -1.582539e-11 -1.156506e-07
    ## 122 -1.024285e-15 -6.264756e-08
    ## 123 -1.582539e-11 -1.156506e-07
    ## 124 -4.755811e-12 -1.149293e-07
    ## 125 -1.119156e-13 -3.806603e-08
    ## 126 -4.755811e-12 -1.149293e-07
    ## 127 -4.747617e-12 -1.156506e-07
    ## 128 -3.072854e-16 -6.264756e-08
    ## 129 -4.747617e-12 -1.156506e-07
    ## 130 -1.585270e-14 -1.149293e-07
    ## 131 -3.730519e-16 -3.806603e-08
    ## 132 -1.585270e-14 -1.149293e-07
    ## 133 -1.582539e-14 -1.156506e-07
    ## 134 -1.024285e-18 -6.264756e-08
    ## 135 -1.582539e-14 -1.156506e-07
    ## 136 -4.755811e-13 -1.149293e-07
    ## 137 -1.119156e-14 -3.806603e-08
    ## 138 -4.755811e-13 -1.149293e-07
    ## 139 -4.747617e-13 -1.156506e-07
    ## 140 -3.072854e-17 -6.264756e-08
    ## 141 -4.747617e-13 -1.156506e-07
    ##                                                    full_name
    ## 1                       From air_Arctic to cloudwater_Arctic
    ## 2                       From air_Arctic to cloudwater_Arctic
    ## 3                       From air_Arctic to cloudwater_Arctic
    ## 4             From air_Continental to cloudwater_Continental
    ## 5             From air_Continental to cloudwater_Continental
    ## 6             From air_Continental to cloudwater_Continental
    ## 7                   From air_Moderate to cloudwater_Moderate
    ## 8                   From air_Moderate to cloudwater_Moderate
    ## 9                   From air_Moderate to cloudwater_Moderate
    ## 10                  From air_Regional to cloudwater_Regional
    ## 11                  From air_Regional to cloudwater_Regional
    ## 12                  From air_Regional to cloudwater_Regional
    ## 13                      From air_Tropic to cloudwater_Tropic
    ## 14                      From air_Tropic to cloudwater_Tropic
    ## 15                      From air_Tropic to cloudwater_Tropic
    ## 16                     From air_Arctic to naturalsoil_Arctic
    ## 17                     From air_Arctic to naturalsoil_Arctic
    ## 18                     From air_Arctic to naturalsoil_Arctic
    ## 19                             From air_Arctic to sea_Arctic
    ## 20                             From air_Arctic to sea_Arctic
    ## 21                             From air_Arctic to sea_Arctic
    ## 22      From air_Continental to agriculturalsoil_Continental
    ## 23      From air_Continental to agriculturalsoil_Continental
    ## 24      From air_Continental to agriculturalsoil_Continental
    ## 25                  From air_Continental to lake_Continental
    ## 26                  From air_Continental to lake_Continental
    ## 27                  From air_Continental to lake_Continental
    ## 28           From air_Continental to naturalsoil_Continental
    ## 29           From air_Continental to naturalsoil_Continental
    ## 30           From air_Continental to naturalsoil_Continental
    ## 31             From air_Continental to othersoil_Continental
    ## 32             From air_Continental to othersoil_Continental
    ## 33             From air_Continental to othersoil_Continental
    ## 34                 From air_Continental to river_Continental
    ## 35                 From air_Continental to river_Continental
    ## 36                 From air_Continental to river_Continental
    ## 37                   From air_Continental to sea_Continental
    ## 38                   From air_Continental to sea_Continental
    ## 39                   From air_Continental to sea_Continental
    ## 40                 From air_Moderate to naturalsoil_Moderate
    ## 41                 From air_Moderate to naturalsoil_Moderate
    ## 42                 From air_Moderate to naturalsoil_Moderate
    ## 43                         From air_Moderate to sea_Moderate
    ## 44                         From air_Moderate to sea_Moderate
    ## 45                         From air_Moderate to sea_Moderate
    ## 46            From air_Regional to agriculturalsoil_Regional
    ## 47            From air_Regional to agriculturalsoil_Regional
    ## 48            From air_Regional to agriculturalsoil_Regional
    ## 49                        From air_Regional to lake_Regional
    ## 50                        From air_Regional to lake_Regional
    ## 51                        From air_Regional to lake_Regional
    ## 52                 From air_Regional to naturalsoil_Regional
    ## 53                 From air_Regional to naturalsoil_Regional
    ## 54                 From air_Regional to naturalsoil_Regional
    ## 55                   From air_Regional to othersoil_Regional
    ## 56                   From air_Regional to othersoil_Regional
    ## 57                   From air_Regional to othersoil_Regional
    ## 58                       From air_Regional to river_Regional
    ## 59                       From air_Regional to river_Regional
    ## 60                       From air_Regional to river_Regional
    ## 61                         From air_Regional to sea_Regional
    ## 62                         From air_Regional to sea_Regional
    ## 63                         From air_Regional to sea_Regional
    ## 64                     From air_Tropic to naturalsoil_Tropic
    ## 65                     From air_Tropic to naturalsoil_Tropic
    ## 66                     From air_Tropic to naturalsoil_Tropic
    ## 67                             From air_Tropic to sea_Tropic
    ## 68                             From air_Tropic to sea_Tropic
    ## 69                             From air_Tropic to sea_Tropic
    ## 70            From deepocean_Arctic to marinesediment_Arctic
    ## 71            From deepocean_Arctic to marinesediment_Arctic
    ## 72            From deepocean_Arctic to marinesediment_Arctic
    ## 73            From deepocean_Arctic to marinesediment_Arctic
    ## 74            From deepocean_Arctic to marinesediment_Arctic
    ## 75            From deepocean_Arctic to marinesediment_Arctic
    ## 76                       From sea_Arctic to deepocean_Arctic
    ## 77                       From sea_Arctic to deepocean_Arctic
    ## 78                       From sea_Arctic to deepocean_Arctic
    ## 79                       From sea_Arctic to deepocean_Arctic
    ## 80                       From sea_Arctic to deepocean_Arctic
    ## 81                       From sea_Arctic to deepocean_Arctic
    ## 82         From lake_Continental to lakesediment_Continental
    ## 83         From lake_Continental to lakesediment_Continental
    ## 84         From lake_Continental to lakesediment_Continental
    ## 85         From lake_Continental to lakesediment_Continental
    ## 86         From lake_Continental to lakesediment_Continental
    ## 87         From lake_Continental to lakesediment_Continental
    ## 88  From river_Continental to freshwatersediment_Continental
    ## 89  From river_Continental to freshwatersediment_Continental
    ## 90  From river_Continental to freshwatersediment_Continental
    ## 91  From river_Continental to freshwatersediment_Continental
    ## 92  From river_Continental to freshwatersediment_Continental
    ## 93  From river_Continental to freshwatersediment_Continental
    ## 94        From sea_Continental to marinesediment_Continental
    ## 95        From sea_Continental to marinesediment_Continental
    ## 96        From sea_Continental to marinesediment_Continental
    ## 97        From sea_Continental to marinesediment_Continental
    ## 98        From sea_Continental to marinesediment_Continental
    ## 99        From sea_Continental to marinesediment_Continental
    ## 100       From deepocean_Moderate to marinesediment_Moderate
    ## 101       From deepocean_Moderate to marinesediment_Moderate
    ## 102       From deepocean_Moderate to marinesediment_Moderate
    ## 103       From deepocean_Moderate to marinesediment_Moderate
    ## 104       From deepocean_Moderate to marinesediment_Moderate
    ## 105       From deepocean_Moderate to marinesediment_Moderate
    ## 106                  From sea_Moderate to deepocean_Moderate
    ## 107                  From sea_Moderate to deepocean_Moderate
    ## 108                  From sea_Moderate to deepocean_Moderate
    ## 109                  From sea_Moderate to deepocean_Moderate
    ## 110                  From sea_Moderate to deepocean_Moderate
    ## 111                  From sea_Moderate to deepocean_Moderate
    ## 112              From lake_Regional to lakesediment_Regional
    ## 113              From lake_Regional to lakesediment_Regional
    ## 114              From lake_Regional to lakesediment_Regional
    ## 115              From lake_Regional to lakesediment_Regional
    ## 116              From lake_Regional to lakesediment_Regional
    ## 117              From lake_Regional to lakesediment_Regional
    ## 118       From river_Regional to freshwatersediment_Regional
    ## 119       From river_Regional to freshwatersediment_Regional
    ## 120       From river_Regional to freshwatersediment_Regional
    ## 121       From river_Regional to freshwatersediment_Regional
    ## 122       From river_Regional to freshwatersediment_Regional
    ## 123       From river_Regional to freshwatersediment_Regional
    ## 124             From sea_Regional to marinesediment_Regional
    ## 125             From sea_Regional to marinesediment_Regional
    ## 126             From sea_Regional to marinesediment_Regional
    ## 127             From sea_Regional to marinesediment_Regional
    ## 128             From sea_Regional to marinesediment_Regional
    ## 129             From sea_Regional to marinesediment_Regional
    ## 130           From deepocean_Tropic to marinesediment_Tropic
    ## 131           From deepocean_Tropic to marinesediment_Tropic
    ## 132           From deepocean_Tropic to marinesediment_Tropic
    ## 133           From deepocean_Tropic to marinesediment_Tropic
    ## 134           From deepocean_Tropic to marinesediment_Tropic
    ## 135           From deepocean_Tropic to marinesediment_Tropic
    ## 136                      From sea_Tropic to deepocean_Tropic
    ## 137                      From sea_Tropic to deepocean_Tropic
    ## 138                      From sea_Tropic to deepocean_Tropic
    ## 139                      From sea_Tropic to deepocean_Tropic
    ## 140                      From sea_Tropic to deepocean_Tropic
    ## 141                      From sea_Tropic to deepocean_Tropic

As can be seen in the figures below, the new rate constants for the
substances, 1-aminoanthraquinone, microplastic, nAg_10nm, TRWP, have a
negligible difference of max 1.1565065^{-5} % difference to the previous
version. The figures below also show this and therefor this verification
is complete.

``` r
all_diffs <- kaas_comparison |>
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
      panel.grid.major = element_line(size = 0.2, color = "gray90"),  
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
      panel.grid.major = element_line(size = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  print(reldif_plot)
}
```

![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-7.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-8.png)<!-- -->
