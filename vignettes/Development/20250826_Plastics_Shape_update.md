Comparison shape update
================
Nadim Saadi, Valerie de Rijk, Anne Hids, Joris Quik
2025-10-15

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

## Quantify changes based drag method chosen

Change drag method and recalculate k values

## Verification of previous and new implementation

    ##                       process   fromScale fromSubCompart fromSpecies
    ## 1              k_CWscavenging      Arctic            air       Small
    ## 2              k_CWscavenging      Arctic            air       Small
    ## 3              k_CWscavenging      Arctic            air       Solid
    ## 4              k_CWscavenging      Arctic            air       Solid
    ## 5              k_CWscavenging Continental            air       Small
    ## 6              k_CWscavenging Continental            air       Small
    ## 7              k_CWscavenging Continental            air       Solid
    ## 8              k_CWscavenging Continental            air       Solid
    ## 9              k_CWscavenging    Moderate            air       Small
    ## 10             k_CWscavenging    Moderate            air       Small
    ## 11             k_CWscavenging    Moderate            air       Solid
    ## 12             k_CWscavenging    Moderate            air       Solid
    ## 13             k_CWscavenging    Regional            air       Small
    ## 14             k_CWscavenging    Regional            air       Small
    ## 15             k_CWscavenging    Regional            air       Solid
    ## 16             k_CWscavenging    Regional            air       Solid
    ## 17             k_CWscavenging      Tropic            air       Small
    ## 18             k_CWscavenging      Tropic            air       Small
    ## 19             k_CWscavenging      Tropic            air       Solid
    ## 20             k_CWscavenging      Tropic            air       Solid
    ## 21            k_DryDeposition      Arctic            air       Small
    ## 22            k_DryDeposition      Arctic            air       Small
    ## 23            k_DryDeposition      Arctic            air       Small
    ## 24            k_DryDeposition      Arctic            air       Small
    ## 25            k_DryDeposition      Arctic            air       Small
    ## 26            k_DryDeposition      Arctic            air       Small
    ## 27            k_DryDeposition      Arctic            air       Solid
    ## 28            k_DryDeposition      Arctic            air       Solid
    ## 29            k_DryDeposition      Arctic            air       Solid
    ## 30            k_DryDeposition      Arctic            air       Solid
    ## 31            k_DryDeposition      Arctic            air       Solid
    ## 32            k_DryDeposition      Arctic            air       Solid
    ## 33            k_DryDeposition Continental            air       Small
    ## 34            k_DryDeposition Continental            air       Small
    ## 35            k_DryDeposition Continental            air       Small
    ## 36            k_DryDeposition Continental            air       Small
    ## 37            k_DryDeposition Continental            air       Small
    ## 38            k_DryDeposition Continental            air       Small
    ## 39            k_DryDeposition Continental            air       Small
    ## 40            k_DryDeposition Continental            air       Small
    ## 41            k_DryDeposition Continental            air       Small
    ## 42            k_DryDeposition Continental            air       Small
    ## 43            k_DryDeposition Continental            air       Small
    ## 44            k_DryDeposition Continental            air       Small
    ## 45            k_DryDeposition Continental            air       Small
    ## 46            k_DryDeposition Continental            air       Small
    ## 47            k_DryDeposition Continental            air       Small
    ## 48            k_DryDeposition Continental            air       Small
    ## 49            k_DryDeposition Continental            air       Small
    ## 50            k_DryDeposition Continental            air       Small
    ## 51            k_DryDeposition Continental            air       Solid
    ## 52            k_DryDeposition Continental            air       Solid
    ## 53            k_DryDeposition Continental            air       Solid
    ## 54            k_DryDeposition Continental            air       Solid
    ## 55            k_DryDeposition Continental            air       Solid
    ## 56            k_DryDeposition Continental            air       Solid
    ## 57            k_DryDeposition Continental            air       Solid
    ## 58            k_DryDeposition Continental            air       Solid
    ## 59            k_DryDeposition Continental            air       Solid
    ## 60            k_DryDeposition Continental            air       Solid
    ## 61            k_DryDeposition Continental            air       Solid
    ## 62            k_DryDeposition Continental            air       Solid
    ## 63            k_DryDeposition Continental            air       Solid
    ## 64            k_DryDeposition Continental            air       Solid
    ## 65            k_DryDeposition Continental            air       Solid
    ## 66            k_DryDeposition Continental            air       Solid
    ## 67            k_DryDeposition Continental            air       Solid
    ## 68            k_DryDeposition Continental            air       Solid
    ## 69            k_DryDeposition    Moderate            air       Small
    ## 70            k_DryDeposition    Moderate            air       Small
    ## 71            k_DryDeposition    Moderate            air       Small
    ## 72            k_DryDeposition    Moderate            air       Small
    ## 73            k_DryDeposition    Moderate            air       Small
    ## 74            k_DryDeposition    Moderate            air       Small
    ## 75            k_DryDeposition    Moderate            air       Solid
    ## 76            k_DryDeposition    Moderate            air       Solid
    ## 77            k_DryDeposition    Moderate            air       Solid
    ## 78            k_DryDeposition    Moderate            air       Solid
    ## 79            k_DryDeposition    Moderate            air       Solid
    ## 80            k_DryDeposition    Moderate            air       Solid
    ## 81            k_DryDeposition    Regional            air       Small
    ## 82            k_DryDeposition    Regional            air       Small
    ## 83            k_DryDeposition    Regional            air       Small
    ## 84            k_DryDeposition    Regional            air       Small
    ## 85            k_DryDeposition    Regional            air       Small
    ## 86            k_DryDeposition    Regional            air       Small
    ## 87            k_DryDeposition    Regional            air       Small
    ## 88            k_DryDeposition    Regional            air       Small
    ## 89            k_DryDeposition    Regional            air       Small
    ## 90            k_DryDeposition    Regional            air       Small
    ## 91            k_DryDeposition    Regional            air       Small
    ## 92            k_DryDeposition    Regional            air       Small
    ## 93            k_DryDeposition    Regional            air       Small
    ## 94            k_DryDeposition    Regional            air       Small
    ## 95            k_DryDeposition    Regional            air       Small
    ## 96            k_DryDeposition    Regional            air       Small
    ## 97            k_DryDeposition    Regional            air       Small
    ## 98            k_DryDeposition    Regional            air       Small
    ## 99            k_DryDeposition    Regional            air       Solid
    ## 100           k_DryDeposition    Regional            air       Solid
    ## 101           k_DryDeposition    Regional            air       Solid
    ## 102           k_DryDeposition    Regional            air       Solid
    ## 103           k_DryDeposition    Regional            air       Solid
    ## 104           k_DryDeposition    Regional            air       Solid
    ## 105           k_DryDeposition    Regional            air       Solid
    ## 106           k_DryDeposition    Regional            air       Solid
    ## 107           k_DryDeposition    Regional            air       Solid
    ## 108           k_DryDeposition    Regional            air       Solid
    ## 109           k_DryDeposition    Regional            air       Solid
    ## 110           k_DryDeposition    Regional            air       Solid
    ## 111           k_DryDeposition    Regional            air       Solid
    ## 112           k_DryDeposition    Regional            air       Solid
    ## 113           k_DryDeposition    Regional            air       Solid
    ## 114           k_DryDeposition    Regional            air       Solid
    ## 115           k_DryDeposition    Regional            air       Solid
    ## 116           k_DryDeposition    Regional            air       Solid
    ## 117           k_DryDeposition      Tropic            air       Small
    ## 118           k_DryDeposition      Tropic            air       Small
    ## 119           k_DryDeposition      Tropic            air       Small
    ## 120           k_DryDeposition      Tropic            air       Small
    ## 121           k_DryDeposition      Tropic            air       Small
    ## 122           k_DryDeposition      Tropic            air       Small
    ## 123           k_DryDeposition      Tropic            air       Solid
    ## 124           k_DryDeposition      Tropic            air       Solid
    ## 125           k_DryDeposition      Tropic            air       Solid
    ## 126           k_DryDeposition      Tropic            air       Solid
    ## 127           k_DryDeposition      Tropic            air       Solid
    ## 128           k_DryDeposition      Tropic            air       Solid
    ## 129 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 130 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 131 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 132 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 133 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 134 k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 135 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 136 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 137 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 138 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 139 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 140 k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 141 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 142 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 143 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 144 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 145 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 146 k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 147 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 148 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 149 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 150 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 151 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 152 k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 153 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 154 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 155 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 156 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 157 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 158 k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 159 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 160 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 161 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 162 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 163 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 164 k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 165 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 166 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 167 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 168 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 169 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 170 k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 171 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 172 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 173 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 174 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 175 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 176 k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 177 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 178 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 179 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 180 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 181 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 182 k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 183 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 184 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 185 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 186 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 187 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 188 k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 189 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 190 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 191 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 192 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 193 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 194 k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 195 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 196 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 197 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 198 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 199 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 200 k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 201           k_Sedimentation      Arctic      deepocean       Large
    ## 202           k_Sedimentation      Arctic      deepocean       Large
    ## 203           k_Sedimentation      Arctic      deepocean       Large
    ## 204           k_Sedimentation      Arctic      deepocean       Small
    ## 205           k_Sedimentation      Arctic      deepocean       Small
    ## 206           k_Sedimentation      Arctic      deepocean       Small
    ## 207           k_Sedimentation      Arctic      deepocean       Solid
    ## 208           k_Sedimentation      Arctic      deepocean       Solid
    ## 209           k_Sedimentation      Arctic      deepocean       Solid
    ## 210           k_Sedimentation      Arctic            sea       Large
    ## 211           k_Sedimentation      Arctic            sea       Large
    ## 212           k_Sedimentation      Arctic            sea       Large
    ## 213           k_Sedimentation      Arctic            sea       Small
    ## 214           k_Sedimentation      Arctic            sea       Small
    ## 215           k_Sedimentation      Arctic            sea       Small
    ## 216           k_Sedimentation      Arctic            sea       Solid
    ## 217           k_Sedimentation      Arctic            sea       Solid
    ## 218           k_Sedimentation      Arctic            sea       Solid
    ## 219           k_Sedimentation Continental           lake       Large
    ## 220           k_Sedimentation Continental           lake       Large
    ## 221           k_Sedimentation Continental           lake       Large
    ## 222           k_Sedimentation Continental           lake       Small
    ## 223           k_Sedimentation Continental           lake       Small
    ## 224           k_Sedimentation Continental           lake       Small
    ## 225           k_Sedimentation Continental           lake       Solid
    ## 226           k_Sedimentation Continental           lake       Solid
    ## 227           k_Sedimentation Continental           lake       Solid
    ## 228           k_Sedimentation Continental          river       Large
    ## 229           k_Sedimentation Continental          river       Large
    ## 230           k_Sedimentation Continental          river       Large
    ## 231           k_Sedimentation Continental          river       Small
    ## 232           k_Sedimentation Continental          river       Small
    ## 233           k_Sedimentation Continental          river       Small
    ## 234           k_Sedimentation Continental          river       Solid
    ## 235           k_Sedimentation Continental          river       Solid
    ## 236           k_Sedimentation Continental          river       Solid
    ## 237           k_Sedimentation Continental            sea       Large
    ## 238           k_Sedimentation Continental            sea       Large
    ## 239           k_Sedimentation Continental            sea       Large
    ## 240           k_Sedimentation Continental            sea       Small
    ## 241           k_Sedimentation Continental            sea       Small
    ## 242           k_Sedimentation Continental            sea       Small
    ## 243           k_Sedimentation Continental            sea       Solid
    ## 244           k_Sedimentation Continental            sea       Solid
    ## 245           k_Sedimentation Continental            sea       Solid
    ## 246           k_Sedimentation    Moderate      deepocean       Large
    ## 247           k_Sedimentation    Moderate      deepocean       Large
    ## 248           k_Sedimentation    Moderate      deepocean       Large
    ## 249           k_Sedimentation    Moderate      deepocean       Small
    ## 250           k_Sedimentation    Moderate      deepocean       Small
    ## 251           k_Sedimentation    Moderate      deepocean       Small
    ## 252           k_Sedimentation    Moderate      deepocean       Solid
    ## 253           k_Sedimentation    Moderate      deepocean       Solid
    ## 254           k_Sedimentation    Moderate      deepocean       Solid
    ## 255           k_Sedimentation    Moderate            sea       Large
    ## 256           k_Sedimentation    Moderate            sea       Large
    ## 257           k_Sedimentation    Moderate            sea       Large
    ## 258           k_Sedimentation    Moderate            sea       Small
    ## 259           k_Sedimentation    Moderate            sea       Small
    ## 260           k_Sedimentation    Moderate            sea       Small
    ## 261           k_Sedimentation    Moderate            sea       Solid
    ## 262           k_Sedimentation    Moderate            sea       Solid
    ## 263           k_Sedimentation    Moderate            sea       Solid
    ## 264           k_Sedimentation    Regional           lake       Large
    ## 265           k_Sedimentation    Regional           lake       Large
    ## 266           k_Sedimentation    Regional           lake       Large
    ## 267           k_Sedimentation    Regional           lake       Small
    ## 268           k_Sedimentation    Regional           lake       Small
    ## 269           k_Sedimentation    Regional           lake       Small
    ## 270           k_Sedimentation    Regional           lake       Solid
    ## 271           k_Sedimentation    Regional           lake       Solid
    ## 272           k_Sedimentation    Regional           lake       Solid
    ## 273           k_Sedimentation    Regional          river       Large
    ## 274           k_Sedimentation    Regional          river       Large
    ## 275           k_Sedimentation    Regional          river       Large
    ## 276           k_Sedimentation    Regional          river       Small
    ## 277           k_Sedimentation    Regional          river       Small
    ## 278           k_Sedimentation    Regional          river       Small
    ## 279           k_Sedimentation    Regional          river       Solid
    ## 280           k_Sedimentation    Regional          river       Solid
    ## 281           k_Sedimentation    Regional          river       Solid
    ## 282           k_Sedimentation    Regional            sea       Large
    ## 283           k_Sedimentation    Regional            sea       Large
    ## 284           k_Sedimentation    Regional            sea       Large
    ## 285           k_Sedimentation    Regional            sea       Small
    ## 286           k_Sedimentation    Regional            sea       Small
    ## 287           k_Sedimentation    Regional            sea       Small
    ## 288           k_Sedimentation    Regional            sea       Solid
    ## 289           k_Sedimentation    Regional            sea       Solid
    ## 290           k_Sedimentation    Regional            sea       Solid
    ## 291           k_Sedimentation      Tropic      deepocean       Large
    ## 292           k_Sedimentation      Tropic      deepocean       Large
    ## 293           k_Sedimentation      Tropic      deepocean       Large
    ## 294           k_Sedimentation      Tropic      deepocean       Small
    ## 295           k_Sedimentation      Tropic      deepocean       Small
    ## 296           k_Sedimentation      Tropic      deepocean       Small
    ## 297           k_Sedimentation      Tropic      deepocean       Solid
    ## 298           k_Sedimentation      Tropic      deepocean       Solid
    ## 299           k_Sedimentation      Tropic      deepocean       Solid
    ## 300           k_Sedimentation      Tropic            sea       Large
    ## 301           k_Sedimentation      Tropic            sea       Large
    ## 302           k_Sedimentation      Tropic            sea       Large
    ## 303           k_Sedimentation      Tropic            sea       Small
    ## 304           k_Sedimentation      Tropic            sea       Small
    ## 305           k_Sedimentation      Tropic            sea       Small
    ## 306           k_Sedimentation      Tropic            sea       Solid
    ## 307           k_Sedimentation      Tropic            sea       Solid
    ## 308           k_Sedimentation      Tropic            sea       Solid
    ##         toScale       toSubCompart toSpecies    Substance        k_Old
    ## 1        Arctic         cloudwater     Small microplastic 1.194489e-04
    ## 2        Arctic         cloudwater     Small         TRWP 1.194489e-04
    ## 3        Arctic         cloudwater     Solid microplastic 1.194489e-04
    ## 4        Arctic         cloudwater     Solid         TRWP 1.194489e-04
    ## 5   Continental         cloudwater     Small microplastic 2.314685e-04
    ## 6   Continental         cloudwater     Small         TRWP 2.314685e-04
    ## 7   Continental         cloudwater     Solid microplastic 2.314685e-04
    ## 8   Continental         cloudwater     Solid         TRWP 2.314685e-04
    ## 9      Moderate         cloudwater     Small microplastic 2.314685e-04
    ## 10     Moderate         cloudwater     Small         TRWP 2.314685e-04
    ## 11     Moderate         cloudwater     Solid microplastic 2.314685e-04
    ## 12     Moderate         cloudwater     Solid         TRWP 2.314685e-04
    ## 13     Regional         cloudwater     Small microplastic 2.314685e-04
    ## 14     Regional         cloudwater     Small         TRWP 2.314685e-04
    ## 15     Regional         cloudwater     Solid microplastic 2.314685e-04
    ## 16     Regional         cloudwater     Solid         TRWP 2.314685e-04
    ## 17       Tropic         cloudwater     Small microplastic 3.460916e-04
    ## 18       Tropic         cloudwater     Small         TRWP 3.460916e-04
    ## 19       Tropic         cloudwater     Solid microplastic 3.460916e-04
    ## 20       Tropic         cloudwater     Solid         TRWP 3.460916e-04
    ## 21       Arctic        naturalsoil     Small microplastic 4.321720e-05
    ## 22       Arctic        naturalsoil     Small     nAg_10nm 7.533075e-07
    ## 23       Arctic        naturalsoil     Small         TRWP 4.321720e-05
    ## 24       Arctic                sea     Small microplastic 5.881692e-05
    ## 25       Arctic                sea     Small     nAg_10nm 1.687410e-06
    ## 26       Arctic                sea     Small         TRWP 5.881692e-05
    ## 27       Arctic        naturalsoil     Solid microplastic 4.321720e-05
    ## 28       Arctic        naturalsoil     Solid     nAg_10nm 3.415423e-06
    ## 29       Arctic        naturalsoil     Solid         TRWP 4.321720e-05
    ## 30       Arctic                sea     Solid microplastic 5.881692e-05
    ## 31       Arctic                sea     Solid     nAg_10nm 5.605552e-06
    ## 32       Arctic                sea     Solid         TRWP 5.881692e-05
    ## 33  Continental   agriculturalsoil     Small microplastic 3.120520e-05
    ## 34  Continental   agriculturalsoil     Small     nAg_10nm 6.712053e-07
    ## 35  Continental   agriculturalsoil     Small         TRWP 3.120520e-05
    ## 36  Continental               lake     Small microplastic 1.186619e-07
    ## 37  Continental               lake     Small     nAg_10nm 3.513825e-09
    ## 38  Continental               lake     Small         TRWP 1.186619e-07
    ## 39  Continental        naturalsoil     Small microplastic 1.412475e-05
    ## 40  Continental        naturalsoil     Small     nAg_10nm 2.558862e-07
    ## 41  Continental        naturalsoil     Small         TRWP 1.412475e-05
    ## 42  Continental          othersoil     Small microplastic 4.914804e-06
    ## 43  Continental          othersoil     Small     nAg_10nm 9.488775e-08
    ## 44  Continental          othersoil     Small         TRWP 4.914804e-06
    ## 45  Continental              river     Small microplastic 1.305281e-06
    ## 46  Continental              river     Small     nAg_10nm 3.865207e-08
    ## 47  Continental              river     Small         TRWP 1.305281e-06
    ## 48  Continental                sea     Small microplastic 5.056345e-05
    ## 49  Continental                sea     Small     nAg_10nm 1.497289e-06
    ## 50  Continental                sea     Small         TRWP 5.056345e-05
    ## 51  Continental   agriculturalsoil     Solid microplastic 3.120520e-05
    ## 52  Continental   agriculturalsoil     Solid     nAg_10nm 2.621367e-06
    ## 53  Continental   agriculturalsoil     Solid         TRWP 3.120520e-05
    ## 54  Continental               lake     Solid microplastic 1.186619e-07
    ## 55  Continental               lake     Solid     nAg_10nm 1.144821e-08
    ## 56  Continental               lake     Solid         TRWP 1.186619e-07
    ## 57  Continental        naturalsoil     Solid microplastic 1.412475e-05
    ## 58  Continental        naturalsoil     Solid     nAg_10nm 1.134645e-06
    ## 59  Continental        naturalsoil     Solid         TRWP 1.412475e-05
    ## 60  Continental          othersoil     Solid microplastic 4.914804e-06
    ## 61  Continental          othersoil     Solid     nAg_10nm 4.203858e-07
    ## 62  Continental          othersoil     Solid         TRWP 4.914804e-06
    ## 63  Continental              river     Solid microplastic 1.305281e-06
    ## 64  Continental              river     Solid     nAg_10nm 1.259303e-07
    ## 65  Continental              river     Solid         TRWP 1.305281e-06
    ## 66  Continental                sea     Solid microplastic 5.056345e-05
    ## 67  Continental                sea     Solid     nAg_10nm 4.878240e-06
    ## 68  Continental                sea     Solid         TRWP 5.056345e-05
    ## 69     Moderate        naturalsoil     Small microplastic 5.402153e-05
    ## 70     Moderate        naturalsoil     Small     nAg_10nm 9.786626e-07
    ## 71     Moderate        naturalsoil     Small         TRWP 5.402153e-05
    ## 72     Moderate                sea     Small microplastic 4.901410e-05
    ## 73     Moderate                sea     Small     nAg_10nm 1.451409e-06
    ## 74     Moderate                sea     Small         TRWP 4.901410e-05
    ## 75     Moderate        naturalsoil     Solid microplastic 5.402152e-05
    ## 76     Moderate        naturalsoil     Solid     nAg_10nm 4.339563e-06
    ## 77     Moderate        naturalsoil     Solid         TRWP 5.402152e-05
    ## 78     Moderate                sea     Solid microplastic 4.901410e-05
    ## 79     Moderate                sea     Solid     nAg_10nm 4.728763e-06
    ## 80     Moderate                sea     Solid         TRWP 4.901410e-05
    ## 81     Regional   agriculturalsoil     Small microplastic 6.416688e-05
    ## 82     Regional   agriculturalsoil     Small     nAg_10nm 1.380191e-06
    ## 83     Regional   agriculturalsoil     Small         TRWP 6.416688e-05
    ## 84     Regional               lake     Small microplastic 2.440030e-07
    ## 85     Regional               lake     Small     nAg_10nm 7.225435e-09
    ## 86     Regional               lake     Small         TRWP 2.440030e-07
    ## 87     Regional        naturalsoil     Small microplastic 2.904455e-05
    ## 88     Regional        naturalsoil     Small     nAg_10nm 5.261758e-07
    ## 89     Regional        naturalsoil     Small         TRWP 2.904455e-05
    ## 90     Regional          othersoil     Small microplastic 1.010625e-05
    ## 91     Regional          othersoil     Small     nAg_10nm 1.951165e-07
    ## 92     Regional          othersoil     Small         TRWP 1.010625e-05
    ## 93     Regional              river     Small microplastic 2.684033e-06
    ## 94     Regional              river     Small     nAg_10nm 7.947979e-08
    ## 95     Regional              river     Small         TRWP 2.684033e-06
    ## 96     Regional                sea     Small microplastic 4.270079e-07
    ## 97     Regional                sea     Small     nAg_10nm 1.264459e-08
    ## 98     Regional                sea     Small         TRWP 4.270079e-07
    ## 99     Regional   agriculturalsoil     Solid microplastic 6.416688e-05
    ## 100    Regional   agriculturalsoil     Solid     nAg_10nm 5.390286e-06
    ## 101    Regional   agriculturalsoil     Solid         TRWP 6.416688e-05
    ## 102    Regional               lake     Solid microplastic 2.440030e-07
    ## 103    Regional               lake     Solid     nAg_10nm 2.354082e-08
    ## 104    Regional               lake     Solid         TRWP 2.440030e-07
    ## 105    Regional        naturalsoil     Solid microplastic 2.904455e-05
    ## 106    Regional        naturalsoil     Solid     nAg_10nm 2.333156e-06
    ## 107    Regional        naturalsoil     Solid         TRWP 2.904455e-05
    ## 108    Regional          othersoil     Solid microplastic 1.010625e-05
    ## 109    Regional          othersoil     Solid     nAg_10nm 8.644342e-07
    ## 110    Regional          othersoil     Solid         TRWP 1.010625e-05
    ## 111    Regional              river     Solid microplastic 2.684033e-06
    ## 112    Regional              river     Solid     nAg_10nm 2.589490e-07
    ## 113    Regional              river     Solid         TRWP 2.684033e-06
    ## 114    Regional                sea     Solid microplastic 4.270079e-07
    ## 115    Regional                sea     Solid     nAg_10nm 4.119670e-08
    ## 116    Regional                sea     Solid         TRWP 4.270079e-07
    ## 117      Tropic        naturalsoil     Small microplastic 3.241292e-05
    ## 118      Tropic        naturalsoil     Small     nAg_10nm 5.998438e-07
    ## 119      Tropic        naturalsoil     Small         TRWP 3.241292e-05
    ## 120      Tropic                sea     Small microplastic 6.861974e-05
    ## 121      Tropic                sea     Small     nAg_10nm 2.067768e-06
    ## 122      Tropic                sea     Small         TRWP 6.861974e-05
    ## 123      Tropic        naturalsoil     Solid microplastic 3.241292e-05
    ## 124      Tropic        naturalsoil     Solid     nAg_10nm 2.626922e-06
    ## 125      Tropic        naturalsoil     Solid         TRWP 3.241292e-05
    ## 126      Tropic                sea     Solid microplastic 6.861974e-05
    ## 127      Tropic                sea     Solid     nAg_10nm 6.664389e-06
    ## 128      Tropic                sea     Solid         TRWP 6.861974e-05
    ## 129      Arctic          deepocean     Large microplastic 2.177599e-04
    ## 130      Arctic          deepocean     Large     nAg_10nm 4.686613e-05
    ## 131      Arctic          deepocean     Large         TRWP 2.177599e-04
    ## 132      Arctic          deepocean     Small microplastic 3.636368e-01
    ## 133      Arctic          deepocean     Small     nAg_10nm 2.738980e-03
    ## 134      Arctic          deepocean     Small         TRWP 3.636368e-01
    ## 135      Arctic                sea     Large microplastic 2.177599e-04
    ## 136      Arctic                sea     Large     nAg_10nm 4.686613e-05
    ## 137      Arctic                sea     Large         TRWP 2.177599e-04
    ## 138      Arctic                sea     Small microplastic 3.636368e-01
    ## 139      Arctic                sea     Small     nAg_10nm 2.738980e-03
    ## 140      Arctic                sea     Small         TRWP 3.636368e-01
    ## 141 Continental               lake     Large microplastic 1.711767e-05
    ## 142 Continental               lake     Large     nAg_10nm 3.893333e-06
    ## 143 Continental               lake     Large         TRWP 1.711767e-05
    ## 144 Continental               lake     Small microplastic 2.961334e-01
    ## 145 Continental               lake     Small     nAg_10nm 5.250454e-04
    ## 146 Continental               lake     Small         TRWP 2.961334e-01
    ## 147 Continental              river     Large microplastic 2.050789e-03
    ## 148 Continental              river     Large     nAg_10nm 2.878207e-04
    ## 149 Continental              river     Large         TRWP 2.050789e-03
    ## 150 Continental              river     Small microplastic 1.038803e+00
    ## 151 Continental              river     Small     nAg_10nm 1.133822e-03
    ## 152 Continental              river     Small         TRWP 1.038803e+00
    ## 153 Continental                sea     Large microplastic 2.177603e-04
    ## 154 Continental                sea     Large     nAg_10nm 4.901753e-05
    ## 155 Continental                sea     Large         TRWP 2.177603e-04
    ## 156 Continental                sea     Small microplastic 3.636488e-01
    ## 157 Continental                sea     Small     nAg_10nm 2.967939e-03
    ## 158 Continental                sea     Small         TRWP 3.636488e-01
    ## 159    Moderate          deepocean     Large microplastic 2.177603e-04
    ## 160    Moderate          deepocean     Large     nAg_10nm 4.901753e-05
    ## 161    Moderate          deepocean     Large         TRWP 2.177603e-04
    ## 162    Moderate          deepocean     Small microplastic 3.636488e-01
    ## 163    Moderate          deepocean     Small     nAg_10nm 2.967939e-03
    ## 164    Moderate          deepocean     Small         TRWP 3.636488e-01
    ## 165    Moderate                sea     Large microplastic 2.177603e-04
    ## 166    Moderate                sea     Large     nAg_10nm 4.901753e-05
    ## 167    Moderate                sea     Large         TRWP 2.177603e-04
    ## 168    Moderate                sea     Small microplastic 3.636488e-01
    ## 169    Moderate                sea     Small     nAg_10nm 2.967939e-03
    ## 170    Moderate                sea     Small         TRWP 3.636488e-01
    ## 171    Regional               lake     Large microplastic 1.711767e-05
    ## 172    Regional               lake     Large     nAg_10nm 3.893333e-06
    ## 173    Regional               lake     Large         TRWP 1.711767e-05
    ## 174    Regional               lake     Small microplastic 2.961334e-01
    ## 175    Regional               lake     Small     nAg_10nm 5.250454e-04
    ## 176    Regional               lake     Small         TRWP 2.961334e-01
    ## 177    Regional              river     Large microplastic 2.050789e-03
    ## 178    Regional              river     Large     nAg_10nm 2.878207e-04
    ## 179    Regional              river     Large         TRWP 2.050789e-03
    ## 180    Regional              river     Small microplastic 1.038803e+00
    ## 181    Regional              river     Small     nAg_10nm 1.133822e-03
    ## 182    Regional              river     Small         TRWP 1.038803e+00
    ## 183    Regional                sea     Large microplastic 2.177603e-04
    ## 184    Regional                sea     Large     nAg_10nm 4.901753e-05
    ## 185    Regional                sea     Large         TRWP 2.177603e-04
    ## 186    Regional                sea     Small microplastic 3.636488e-01
    ## 187    Regional                sea     Small     nAg_10nm 2.967939e-03
    ## 188    Regional                sea     Small         TRWP 3.636488e-01
    ## 189      Tropic          deepocean     Large microplastic 2.177605e-04
    ## 190      Tropic          deepocean     Large     nAg_10nm 5.028882e-05
    ## 191      Tropic          deepocean     Large         TRWP 2.177605e-04
    ## 192      Tropic          deepocean     Small microplastic 3.636560e-01
    ## 193      Tropic          deepocean     Small     nAg_10nm 3.103232e-03
    ## 194      Tropic          deepocean     Small         TRWP 3.636560e-01
    ## 195      Tropic                sea     Large microplastic 2.177605e-04
    ## 196      Tropic                sea     Large     nAg_10nm 5.028882e-05
    ## 197      Tropic                sea     Large         TRWP 2.177605e-04
    ## 198      Tropic                sea     Small microplastic 3.636560e-01
    ## 199      Tropic                sea     Small     nAg_10nm 3.103232e-03
    ## 200      Tropic                sea     Small         TRWP 3.636560e-01
    ## 201      Arctic     marinesediment     Large microplastic 1.379344e-07
    ## 202      Arctic     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 203      Arctic     marinesediment     Large         TRWP 1.379344e-07
    ## 204      Arctic     marinesediment     Small microplastic 1.368379e-07
    ## 205      Arctic     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 206      Arctic     marinesediment     Small         TRWP 1.368379e-07
    ## 207      Arctic     marinesediment     Solid microplastic 1.368378e-07
    ## 208      Arctic     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 209      Arctic     marinesediment     Solid         TRWP 1.368378e-07
    ## 210      Arctic          deepocean     Large microplastic 4.138033e-06
    ## 211      Arctic          deepocean     Large     nAg_10nm 2.940038e-07
    ## 212      Arctic          deepocean     Large         TRWP 4.138033e-06
    ## 213      Arctic          deepocean     Small microplastic 4.105137e-06
    ## 214      Arctic          deepocean     Small     nAg_10nm 4.904987e-10
    ## 215      Arctic          deepocean     Small         TRWP 4.105137e-06
    ## 216      Arctic          deepocean     Solid microplastic 4.105135e-06
    ## 217      Arctic          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 218      Arctic          deepocean     Solid         TRWP 4.105135e-06
    ## 219 Continental       lakesediment     Large microplastic 4.138033e-06
    ## 220 Continental       lakesediment     Large     nAg_10nm 2.940038e-07
    ## 221 Continental       lakesediment     Large         TRWP 4.138033e-06
    ## 222 Continental       lakesediment     Small microplastic 4.105137e-06
    ## 223 Continental       lakesediment     Small     nAg_10nm 4.904987e-10
    ## 224 Continental       lakesediment     Small         TRWP 4.105137e-06
    ## 225 Continental       lakesediment     Solid microplastic 4.105135e-06
    ## 226 Continental       lakesediment     Solid     nAg_10nm 5.166489e-12
    ## 227 Continental       lakesediment     Solid         TRWP 4.105135e-06
    ## 228 Continental freshwatersediment     Large microplastic 1.379344e-04
    ## 229 Continental freshwatersediment     Large     nAg_10nm 9.800126e-06
    ## 230 Continental freshwatersediment     Large         TRWP 1.379344e-04
    ## 231 Continental freshwatersediment     Small microplastic 1.368379e-04
    ## 232 Continental freshwatersediment     Small     nAg_10nm 1.634996e-08
    ## 233 Continental freshwatersediment     Small         TRWP 1.368379e-04
    ## 234 Continental freshwatersediment     Solid microplastic 1.368378e-04
    ## 235 Continental freshwatersediment     Solid     nAg_10nm 1.722163e-10
    ## 236 Continental freshwatersediment     Solid         TRWP 1.368378e-04
    ## 237 Continental     marinesediment     Large microplastic 2.069016e-06
    ## 238 Continental     marinesediment     Large     nAg_10nm 1.470019e-07
    ## 239 Continental     marinesediment     Large         TRWP 2.069016e-06
    ## 240 Continental     marinesediment     Small microplastic 2.052569e-06
    ## 241 Continental     marinesediment     Small     nAg_10nm 2.452493e-10
    ## 242 Continental     marinesediment     Small         TRWP 2.052569e-06
    ## 243 Continental     marinesediment     Solid microplastic 2.052567e-06
    ## 244 Continental     marinesediment     Solid     nAg_10nm 2.583244e-12
    ## 245 Continental     marinesediment     Solid         TRWP 2.052567e-06
    ## 246    Moderate     marinesediment     Large microplastic 1.379344e-07
    ## 247    Moderate     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 248    Moderate     marinesediment     Large         TRWP 1.379344e-07
    ## 249    Moderate     marinesediment     Small microplastic 1.368379e-07
    ## 250    Moderate     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 251    Moderate     marinesediment     Small         TRWP 1.368379e-07
    ## 252    Moderate     marinesediment     Solid microplastic 1.368378e-07
    ## 253    Moderate     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 254    Moderate     marinesediment     Solid         TRWP 1.368378e-07
    ## 255    Moderate          deepocean     Large microplastic 4.138033e-06
    ## 256    Moderate          deepocean     Large     nAg_10nm 2.940038e-07
    ## 257    Moderate          deepocean     Large         TRWP 4.138033e-06
    ## 258    Moderate          deepocean     Small microplastic 4.105137e-06
    ## 259    Moderate          deepocean     Small     nAg_10nm 4.904987e-10
    ## 260    Moderate          deepocean     Small         TRWP 4.105137e-06
    ## 261    Moderate          deepocean     Solid microplastic 4.105135e-06
    ## 262    Moderate          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 263    Moderate          deepocean     Solid         TRWP 4.105135e-06
    ## 264    Regional       lakesediment     Large microplastic 4.138033e-06
    ## 265    Regional       lakesediment     Large     nAg_10nm 2.940038e-07
    ## 266    Regional       lakesediment     Large         TRWP 4.138033e-06
    ## 267    Regional       lakesediment     Small microplastic 4.105137e-06
    ## 268    Regional       lakesediment     Small     nAg_10nm 4.904987e-10
    ## 269    Regional       lakesediment     Small         TRWP 4.105137e-06
    ## 270    Regional       lakesediment     Solid microplastic 4.105135e-06
    ## 271    Regional       lakesediment     Solid     nAg_10nm 5.166489e-12
    ## 272    Regional       lakesediment     Solid         TRWP 4.105135e-06
    ## 273    Regional freshwatersediment     Large microplastic 1.379344e-04
    ## 274    Regional freshwatersediment     Large     nAg_10nm 9.800126e-06
    ## 275    Regional freshwatersediment     Large         TRWP 1.379344e-04
    ## 276    Regional freshwatersediment     Small microplastic 1.368379e-04
    ## 277    Regional freshwatersediment     Small     nAg_10nm 1.634996e-08
    ## 278    Regional freshwatersediment     Small         TRWP 1.368379e-04
    ## 279    Regional freshwatersediment     Solid microplastic 1.368378e-04
    ## 280    Regional freshwatersediment     Solid     nAg_10nm 1.722163e-10
    ## 281    Regional freshwatersediment     Solid         TRWP 1.368378e-04
    ## 282    Regional     marinesediment     Large microplastic 4.138033e-05
    ## 283    Regional     marinesediment     Large     nAg_10nm 2.940038e-06
    ## 284    Regional     marinesediment     Large         TRWP 4.138033e-05
    ## 285    Regional     marinesediment     Small microplastic 4.105137e-05
    ## 286    Regional     marinesediment     Small     nAg_10nm 4.904987e-09
    ## 287    Regional     marinesediment     Small         TRWP 4.105137e-05
    ## 288    Regional     marinesediment     Solid microplastic 4.105135e-05
    ## 289    Regional     marinesediment     Solid     nAg_10nm 5.166489e-11
    ## 290    Regional     marinesediment     Solid         TRWP 4.105135e-05
    ## 291      Tropic     marinesediment     Large microplastic 1.379344e-07
    ## 292      Tropic     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 293      Tropic     marinesediment     Large         TRWP 1.379344e-07
    ## 294      Tropic     marinesediment     Small microplastic 1.368379e-07
    ## 295      Tropic     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 296      Tropic     marinesediment     Small         TRWP 1.368379e-07
    ## 297      Tropic     marinesediment     Solid microplastic 1.368378e-07
    ## 298      Tropic     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 299      Tropic     marinesediment     Solid         TRWP 1.368378e-07
    ## 300      Tropic          deepocean     Large microplastic 4.138033e-06
    ## 301      Tropic          deepocean     Large     nAg_10nm 2.940038e-07
    ## 302      Tropic          deepocean     Large         TRWP 4.138033e-06
    ## 303      Tropic          deepocean     Small microplastic 4.105137e-06
    ## 304      Tropic          deepocean     Small     nAg_10nm 4.904987e-10
    ## 305      Tropic          deepocean     Small         TRWP 4.105137e-06
    ## 306      Tropic          deepocean     Solid microplastic 4.105135e-06
    ## 307      Tropic          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 308      Tropic          deepocean     Solid         TRWP 4.105135e-06
    ##            k_New          diff      rel_diff
    ## 1   1.194495e-04  6.407257e-10  5.363987e-06
    ## 2   1.194495e-04  6.407257e-10  5.363987e-06
    ## 3   1.194495e-04  6.407257e-10  5.363987e-06
    ## 4   1.194495e-04  6.407257e-10  5.363987e-06
    ## 5   2.314691e-04  6.215162e-10  2.685093e-06
    ## 6   2.314691e-04  6.215162e-10  2.685093e-06
    ## 7   2.314691e-04  6.215162e-10  2.685093e-06
    ## 8   2.314691e-04  6.215162e-10  2.685093e-06
    ## 9   2.314691e-04  6.215162e-10  2.685093e-06
    ## 10  2.314691e-04  6.215162e-10  2.685093e-06
    ## 11  2.314691e-04  6.215162e-10  2.685093e-06
    ## 12  2.314691e-04  6.215162e-10  2.685093e-06
    ## 13  2.314691e-04  6.215162e-10  2.685093e-06
    ## 14  2.314691e-04  6.215162e-10  2.685093e-06
    ## 15  2.314691e-04  6.215162e-10  2.685093e-06
    ## 16  2.314691e-04  6.215162e-10  2.685093e-06
    ## 17  3.460922e-04  6.142768e-10  1.774893e-06
    ## 18  3.460922e-04  6.142768e-10  1.774893e-06
    ## 19  3.460922e-04  6.142768e-10  1.774893e-06
    ## 20  3.460922e-04  6.142768e-10  1.774893e-06
    ## 21  4.068345e-05 -2.533755e-06 -6.227975e-02
    ## 22  7.530428e-07 -2.646830e-10 -3.514846e-04
    ## 23  4.068345e-05 -2.533755e-06 -6.227975e-02
    ## 24  5.510345e-05 -3.713470e-06 -6.739087e-02
    ## 25  1.577329e-06 -1.100812e-07 -6.978961e-02
    ## 26  5.510345e-05 -3.713470e-06 -6.739087e-02
    ## 27  4.068345e-05 -2.533755e-06 -6.227975e-02
    ## 28  3.411462e-06 -3.961492e-09 -1.161230e-03
    ## 29  4.068345e-05 -2.533755e-06 -6.227975e-02
    ## 30  5.510345e-05 -3.713470e-06 -6.739087e-02
    ## 31  5.072309e-06 -5.332431e-07 -1.051283e-01
    ## 32  5.510345e-05 -3.713470e-06 -6.739087e-02
    ## 33  2.935599e-05 -1.849215e-06 -6.299275e-02
    ## 34  6.708109e-07 -3.943320e-10 -5.878437e-04
    ## 35  2.935599e-05 -1.849215e-06 -6.299275e-02
    ## 36  1.111700e-07 -7.491846e-09 -6.739087e-02
    ## 37  3.286306e-09 -2.275184e-10 -6.923227e-02
    ## 38  1.111700e-07 -7.491846e-09 -6.739087e-02
    ## 39  1.329664e-05 -8.281103e-07 -6.227967e-02
    ## 40  2.557834e-07 -1.028687e-10 -4.021712e-04
    ## 41  1.329664e-05 -8.281103e-07 -6.227967e-02
    ## 42  4.602747e-06 -3.120568e-07 -6.779796e-02
    ## 43  9.493591e-08  4.816208e-11  5.073115e-04
    ## 44  4.602747e-06 -3.120568e-07 -6.779796e-02
    ## 45  1.222870e-06 -8.241030e-08 -6.739087e-02
    ## 46  3.614937e-08 -2.502703e-09 -6.923227e-02
    ## 47  1.222870e-06 -8.241030e-08 -6.739087e-02
    ## 48  4.737107e-05 -3.192378e-06 -6.739087e-02
    ## 49  1.400340e-06 -9.694871e-08 -6.923227e-02
    ## 50  4.737107e-05 -3.192378e-06 -6.739087e-02
    ## 51  2.935599e-05 -1.849215e-06 -6.299275e-02
    ## 52  2.618833e-06 -2.534010e-09 -9.676101e-04
    ## 53  2.935599e-05 -1.849215e-06 -6.299275e-02
    ## 54  1.111700e-07 -7.491846e-09 -6.739087e-02
    ## 55  1.038659e-08 -1.061627e-09 -1.022113e-01
    ## 56  1.111700e-07 -7.491846e-09 -6.739087e-02
    ## 57  1.329664e-05 -8.281103e-07 -6.227967e-02
    ## 58  1.133391e-06 -1.253774e-09 -1.106215e-03
    ## 59  1.329664e-05 -8.281103e-07 -6.227967e-02
    ## 60  4.602747e-06 -3.120568e-07 -6.779796e-02
    ## 61  4.204792e-07  9.334501e-11  2.219968e-04
    ## 62  4.602747e-06 -3.120568e-07 -6.779796e-02
    ## 63  1.222870e-06 -8.241030e-08 -6.739087e-02
    ## 64  1.142525e-07 -1.167790e-08 -1.022113e-01
    ## 65  1.222870e-06 -8.241030e-08 -6.739087e-02
    ## 66  4.737107e-05 -3.192378e-06 -6.739087e-02
    ## 67  4.425866e-06 -4.523737e-07 -1.022113e-01
    ## 68  4.737107e-05 -3.192378e-06 -6.739087e-02
    ## 69  5.085433e-05 -3.167191e-06 -6.227967e-02
    ## 70  9.782692e-07 -3.934317e-10 -4.021712e-04
    ## 71  5.085433e-05 -3.167191e-06 -6.227967e-02
    ## 72  4.591954e-05 -3.094558e-06 -6.739087e-02
    ## 73  1.357431e-06 -9.397805e-08 -6.923227e-02
    ## 74  4.591954e-05 -3.094558e-06 -6.739087e-02
    ## 75  5.085433e-05 -3.167191e-06 -6.227967e-02
    ## 76  4.334768e-06 -4.795183e-09 -1.106215e-03
    ## 77  5.085433e-05 -3.167191e-06 -6.227967e-02
    ## 78  4.591954e-05 -3.094558e-06 -6.739087e-02
    ## 79  4.290251e-06 -4.385122e-07 -1.022113e-01
    ## 80  4.591954e-05 -3.094558e-06 -6.739087e-02
    ## 81  6.036436e-05 -3.802517e-06 -6.299275e-02
    ## 82  1.379380e-06 -8.108600e-10 -5.878437e-04
    ## 83  6.036436e-05 -3.802517e-06 -6.299275e-02
    ## 84  2.285976e-07 -1.540539e-08 -6.739087e-02
    ## 85  6.757592e-09 -4.678434e-10 -6.923227e-02
    ## 86  2.285976e-07 -1.540539e-08 -6.739087e-02
    ## 87  2.734172e-05 -1.702833e-06 -6.227967e-02
    ## 88  5.259642e-07 -2.115277e-10 -4.021712e-04
    ## 89  2.734172e-05 -1.702833e-06 -6.227967e-02
    ## 90  9.464572e-06 -6.416787e-07 -6.779796e-02
    ## 91  1.952156e-07  9.903509e-11  5.073115e-04
    ## 92  9.464572e-06 -6.416787e-07 -6.779796e-02
    ## 93  2.514574e-06 -1.694593e-07 -6.739087e-02
    ## 94  7.433351e-08 -5.146277e-09 -6.923227e-02
    ## 95  2.514574e-06 -1.694593e-07 -6.739087e-02
    ## 96  4.000483e-07 -2.695960e-08 -6.739087e-02
    ## 97  1.182586e-08 -8.187311e-10 -6.923227e-02
    ## 98  4.000483e-07 -2.695960e-08 -6.739087e-02
    ## 99  6.036436e-05 -3.802517e-06 -6.299275e-02
    ## 100 5.385075e-06 -5.210653e-09 -9.676101e-04
    ## 101 6.036436e-05 -3.802517e-06 -6.299275e-02
    ## 102 2.285976e-07 -1.540539e-08 -6.739087e-02
    ## 103 2.135781e-08 -2.183010e-09 -1.022113e-01
    ## 104 2.285976e-07 -1.540539e-08 -6.739087e-02
    ## 105 2.734172e-05 -1.702833e-06 -6.227967e-02
    ## 106 2.330578e-06 -2.578120e-09 -1.106215e-03
    ## 107 2.734172e-05 -1.702833e-06 -6.227967e-02
    ## 108 9.464572e-06 -6.416786e-07 -6.779796e-02
    ## 109 8.646262e-07  1.919442e-10  2.219968e-04
    ## 110 9.464572e-06 -6.416786e-07 -6.779796e-02
    ## 111 2.514573e-06 -1.694593e-07 -6.739087e-02
    ## 112 2.349359e-07 -2.401311e-08 -1.022113e-01
    ## 113 2.514573e-06 -1.694593e-07 -6.739087e-02
    ## 114 4.000483e-07 -2.695960e-08 -6.739087e-02
    ## 115 3.737641e-08 -3.820292e-09 -1.022113e-01
    ## 116 4.000483e-07 -2.695960e-08 -6.739087e-02
    ## 117 3.051261e-05 -1.900314e-06 -6.227962e-02
    ## 118 5.995866e-07 -2.571751e-10 -4.289207e-04
    ## 119 3.051261e-05 -1.900314e-06 -6.227962e-02
    ## 120 6.428736e-05 -4.332381e-06 -6.739087e-02
    ## 121 1.934454e-06 -1.333149e-07 -6.891604e-02
    ## 122 6.428736e-05 -4.332381e-06 -6.739087e-02
    ## 123 3.051261e-05 -1.900314e-06 -6.227962e-02
    ## 124 2.624100e-06 -2.822355e-09 -1.075552e-03
    ## 125 3.051261e-05 -1.900314e-06 -6.227962e-02
    ## 126 6.428736e-05 -4.332381e-06 -6.739087e-02
    ## 127 6.055170e-06 -6.092188e-07 -1.006113e-01
    ## 128 6.428736e-05 -4.332381e-06 -6.739087e-02
    ## 129 1.797775e-04 -3.798247e-05 -2.112749e-01
    ## 130 4.686618e-05  5.039102e-11  1.075211e-06
    ## 131 1.797775e-04 -3.798247e-05 -2.112749e-01
    ## 132 3.023491e-01 -6.128767e-02 -2.027050e-01
    ## 133 2.738980e-03  2.681375e-10  9.789684e-08
    ## 134 3.023491e-01 -6.128767e-02 -2.027050e-01
    ## 135 1.797775e-04 -3.798247e-05 -2.112749e-01
    ## 136 4.686618e-05  5.039102e-11  1.075211e-06
    ## 137 1.797775e-04 -3.798247e-05 -2.112749e-01
    ## 138 3.023491e-01 -6.128767e-02 -2.027050e-01
    ## 139 2.738980e-03  2.681375e-10  9.789684e-08
    ## 140 3.023491e-01 -6.128767e-02 -2.027050e-01
    ## 141 1.331942e-05 -3.798247e-06 -2.851660e-01
    ## 142 3.893338e-06  4.535192e-12  1.164860e-06
    ## 143 1.331942e-05 -3.798247e-06 -2.851660e-01
    ## 144 2.348458e-01 -6.128767e-02 -2.609699e-01
    ## 145 5.250454e-04  4.746034e-11  9.039283e-08
    ## 146 2.348458e-01 -6.128767e-02 -2.609699e-01
    ## 147 1.936841e-03 -1.139474e-04 -5.883157e-02
    ## 148 2.878209e-04  1.360558e-10  4.727099e-07
    ## 149 1.936841e-03 -1.139474e-04 -5.883157e-02
    ## 150 9.775151e-01 -6.128767e-02 -6.269742e-02
    ## 151 1.133823e-03  1.018923e-10  8.986615e-08
    ## 152 9.775151e-01 -6.128767e-02 -6.269742e-02
    ## 153 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 154 4.901758e-05  5.039102e-11  1.028019e-06
    ## 155 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 156 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 157 2.967939e-03  2.681375e-10  9.034470e-08
    ## 158 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 159 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 160 4.901758e-05  5.039102e-11  1.028019e-06
    ## 161 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 162 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 163 2.967939e-03  2.681375e-10  9.034470e-08
    ## 164 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 165 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 166 4.901758e-05  5.039102e-11  1.028019e-06
    ## 167 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 168 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 169 2.967939e-03  2.681375e-10  9.034470e-08
    ## 170 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 171 1.331942e-05 -3.798247e-06 -2.851660e-01
    ## 172 3.893338e-06  4.535192e-12  1.164860e-06
    ## 173 1.331942e-05 -3.798247e-06 -2.851660e-01
    ## 174 2.348458e-01 -6.128767e-02 -2.609699e-01
    ## 175 5.250454e-04  4.746034e-11  9.039283e-08
    ## 176 2.348458e-01 -6.128767e-02 -2.609699e-01
    ## 177 1.936841e-03 -1.139474e-04 -5.883157e-02
    ## 178 2.878209e-04  1.360558e-10  4.727099e-07
    ## 179 1.936841e-03 -1.139474e-04 -5.883157e-02
    ## 180 9.775151e-01 -6.128767e-02 -6.269742e-02
    ## 181 1.133823e-03  1.018923e-10  8.986615e-08
    ## 182 9.775151e-01 -6.128767e-02 -6.269742e-02
    ## 183 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 184 4.901758e-05  5.039102e-11  1.028019e-06
    ## 185 1.797778e-04 -3.798247e-05 -2.112745e-01
    ## 186 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 187 2.967939e-03  2.681375e-10  9.034470e-08
    ## 188 3.023612e-01 -6.128767e-02 -2.026969e-01
    ## 189 1.797781e-04 -3.798247e-05 -2.112742e-01
    ## 190 5.028887e-05  5.039102e-11  1.002031e-06
    ## 191 1.797781e-04 -3.798247e-05 -2.112742e-01
    ## 192 3.023683e-01 -6.128767e-02 -2.026921e-01
    ## 193 3.103233e-03  2.681375e-10  8.640588e-08
    ## 194 3.023683e-01 -6.128767e-02 -2.026921e-01
    ## 195 1.797781e-04 -3.798247e-05 -2.112742e-01
    ## 196 5.028887e-05  5.039102e-11  1.002031e-06
    ## 197 1.797781e-04 -3.798247e-05 -2.112742e-01
    ## 198 3.023683e-01 -6.128767e-02 -2.026921e-01
    ## 199 3.103233e-03  2.681375e-10  8.640588e-08
    ## 200 3.023683e-01 -6.128767e-02 -2.026921e-01
    ## 201 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 202 9.795403e-09 -4.722405e-12 -4.821042e-04
    ## 203 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 204 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 205 1.639014e-11  4.018261e-14  2.451633e-03
    ## 206 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 207 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 208 1.138506e-13 -5.836566e-14 -5.126512e-01
    ## 209 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 210 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 211 2.938621e-07 -1.416722e-10 -4.821042e-04
    ## 212 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 213 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 214 4.917041e-10  1.205478e-12  2.451633e-03
    ## 215 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 216 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 217 3.415519e-12 -1.750970e-12 -5.126512e-01
    ## 218 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 219 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 220 2.938621e-07 -1.416722e-10 -4.821042e-04
    ## 221 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 222 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 223 4.917041e-10  1.205478e-12  2.451633e-03
    ## 224 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 225 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 226 3.415519e-12 -1.750970e-12 -5.126512e-01
    ## 227 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 228 1.363684e-04 -1.566037e-06 -1.148387e-02
    ## 229 9.795403e-06 -4.722405e-09 -4.821042e-04
    ## 230 1.363684e-04 -1.566037e-06 -1.148387e-02
    ## 231 1.352930e-04 -1.544914e-06 -1.141902e-02
    ## 232 1.639014e-08  4.018261e-11  2.451633e-03
    ## 233 1.352930e-04 -1.544914e-06 -1.141902e-02
    ## 234 1.352929e-04 -1.544912e-06 -1.141902e-02
    ## 235 1.138506e-10 -5.836566e-11 -5.126512e-01
    ## 236 1.352929e-04 -1.544912e-06 -1.141902e-02
    ## 237 2.045526e-06 -2.349055e-08 -1.148387e-02
    ## 238 1.469310e-07 -7.083608e-11 -4.821042e-04
    ## 239 2.045526e-06 -2.349055e-08 -1.148387e-02
    ## 240 2.029395e-06 -2.317371e-08 -1.141902e-02
    ## 241 2.458521e-10  6.027391e-13  2.451633e-03
    ## 242 2.029395e-06 -2.317371e-08 -1.141902e-02
    ## 243 2.029394e-06 -2.317368e-08 -1.141902e-02
    ## 244 1.707759e-12 -8.754849e-13 -5.126512e-01
    ## 245 2.029394e-06 -2.317368e-08 -1.141902e-02
    ## 246 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 247 9.795403e-09 -4.722405e-12 -4.821042e-04
    ## 248 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 249 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 250 1.639014e-11  4.018261e-14  2.451633e-03
    ## 251 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 252 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 253 1.138506e-13 -5.836566e-14 -5.126512e-01
    ## 254 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 255 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 256 2.938621e-07 -1.416722e-10 -4.821042e-04
    ## 257 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 258 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 259 4.917041e-10  1.205478e-12  2.451633e-03
    ## 260 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 261 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 262 3.415519e-12 -1.750970e-12 -5.126512e-01
    ## 263 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 264 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 265 2.938621e-07 -1.416722e-10 -4.821042e-04
    ## 266 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 267 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 268 4.917041e-10  1.205478e-12  2.451633e-03
    ## 269 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 270 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 271 3.415519e-12 -1.750970e-12 -5.126512e-01
    ## 272 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 273 1.363684e-04 -1.566037e-06 -1.148387e-02
    ## 274 9.795403e-06 -4.722405e-09 -4.821042e-04
    ## 275 1.363684e-04 -1.566037e-06 -1.148387e-02
    ## 276 1.352930e-04 -1.544914e-06 -1.141902e-02
    ## 277 1.639014e-08  4.018261e-11  2.451633e-03
    ## 278 1.352930e-04 -1.544914e-06 -1.141902e-02
    ## 279 1.352929e-04 -1.544912e-06 -1.141902e-02
    ## 280 1.138506e-10 -5.836566e-11 -5.126512e-01
    ## 281 1.352929e-04 -1.544912e-06 -1.141902e-02
    ## 282 4.091052e-05 -4.698110e-07 -1.148387e-02
    ## 283 2.938621e-06 -1.416722e-09 -4.821042e-04
    ## 284 4.091052e-05 -4.698110e-07 -1.148387e-02
    ## 285 4.058790e-05 -4.634742e-07 -1.141902e-02
    ## 286 4.917041e-09  1.205478e-11  2.451633e-03
    ## 287 4.058790e-05 -4.634742e-07 -1.141902e-02
    ## 288 4.058787e-05 -4.634737e-07 -1.141902e-02
    ## 289 3.415519e-11 -1.750970e-11 -5.126512e-01
    ## 290 4.058787e-05 -4.634737e-07 -1.141902e-02
    ## 291 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 292 9.795403e-09 -4.722405e-12 -4.821042e-04
    ## 293 1.363684e-07 -1.566037e-09 -1.148387e-02
    ## 294 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 295 1.639014e-11  4.018261e-14  2.451633e-03
    ## 296 1.352930e-07 -1.544914e-09 -1.141902e-02
    ## 297 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 298 1.138506e-13 -5.836566e-14 -5.126512e-01
    ## 299 1.352929e-07 -1.544912e-09 -1.141902e-02
    ## 300 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 301 2.938621e-07 -1.416722e-10 -4.821042e-04
    ## 302 4.091052e-06 -4.698110e-08 -1.148387e-02
    ## 303 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 304 4.917041e-10  1.205478e-12  2.451633e-03
    ## 305 4.058790e-06 -4.634742e-08 -1.141902e-02
    ## 306 4.058787e-06 -4.634737e-08 -1.141902e-02
    ## 307 3.415519e-12 -1.750970e-12 -5.126512e-01
    ## 308 4.058787e-06 -4.634737e-08 -1.141902e-02
    ##                                                    full_name
    ## 1                       From air_Arctic to cloudwater_Arctic
    ## 2                       From air_Arctic to cloudwater_Arctic
    ## 3                       From air_Arctic to cloudwater_Arctic
    ## 4                       From air_Arctic to cloudwater_Arctic
    ## 5             From air_Continental to cloudwater_Continental
    ## 6             From air_Continental to cloudwater_Continental
    ## 7             From air_Continental to cloudwater_Continental
    ## 8             From air_Continental to cloudwater_Continental
    ## 9                   From air_Moderate to cloudwater_Moderate
    ## 10                  From air_Moderate to cloudwater_Moderate
    ## 11                  From air_Moderate to cloudwater_Moderate
    ## 12                  From air_Moderate to cloudwater_Moderate
    ## 13                  From air_Regional to cloudwater_Regional
    ## 14                  From air_Regional to cloudwater_Regional
    ## 15                  From air_Regional to cloudwater_Regional
    ## 16                  From air_Regional to cloudwater_Regional
    ## 17                      From air_Tropic to cloudwater_Tropic
    ## 18                      From air_Tropic to cloudwater_Tropic
    ## 19                      From air_Tropic to cloudwater_Tropic
    ## 20                      From air_Tropic to cloudwater_Tropic
    ## 21                     From air_Arctic to naturalsoil_Arctic
    ## 22                     From air_Arctic to naturalsoil_Arctic
    ## 23                     From air_Arctic to naturalsoil_Arctic
    ## 24                             From air_Arctic to sea_Arctic
    ## 25                             From air_Arctic to sea_Arctic
    ## 26                             From air_Arctic to sea_Arctic
    ## 27                     From air_Arctic to naturalsoil_Arctic
    ## 28                     From air_Arctic to naturalsoil_Arctic
    ## 29                     From air_Arctic to naturalsoil_Arctic
    ## 30                             From air_Arctic to sea_Arctic
    ## 31                             From air_Arctic to sea_Arctic
    ## 32                             From air_Arctic to sea_Arctic
    ## 33      From air_Continental to agriculturalsoil_Continental
    ## 34      From air_Continental to agriculturalsoil_Continental
    ## 35      From air_Continental to agriculturalsoil_Continental
    ## 36                  From air_Continental to lake_Continental
    ## 37                  From air_Continental to lake_Continental
    ## 38                  From air_Continental to lake_Continental
    ## 39           From air_Continental to naturalsoil_Continental
    ## 40           From air_Continental to naturalsoil_Continental
    ## 41           From air_Continental to naturalsoil_Continental
    ## 42             From air_Continental to othersoil_Continental
    ## 43             From air_Continental to othersoil_Continental
    ## 44             From air_Continental to othersoil_Continental
    ## 45                 From air_Continental to river_Continental
    ## 46                 From air_Continental to river_Continental
    ## 47                 From air_Continental to river_Continental
    ## 48                   From air_Continental to sea_Continental
    ## 49                   From air_Continental to sea_Continental
    ## 50                   From air_Continental to sea_Continental
    ## 51      From air_Continental to agriculturalsoil_Continental
    ## 52      From air_Continental to agriculturalsoil_Continental
    ## 53      From air_Continental to agriculturalsoil_Continental
    ## 54                  From air_Continental to lake_Continental
    ## 55                  From air_Continental to lake_Continental
    ## 56                  From air_Continental to lake_Continental
    ## 57           From air_Continental to naturalsoil_Continental
    ## 58           From air_Continental to naturalsoil_Continental
    ## 59           From air_Continental to naturalsoil_Continental
    ## 60             From air_Continental to othersoil_Continental
    ## 61             From air_Continental to othersoil_Continental
    ## 62             From air_Continental to othersoil_Continental
    ## 63                 From air_Continental to river_Continental
    ## 64                 From air_Continental to river_Continental
    ## 65                 From air_Continental to river_Continental
    ## 66                   From air_Continental to sea_Continental
    ## 67                   From air_Continental to sea_Continental
    ## 68                   From air_Continental to sea_Continental
    ## 69                 From air_Moderate to naturalsoil_Moderate
    ## 70                 From air_Moderate to naturalsoil_Moderate
    ## 71                 From air_Moderate to naturalsoil_Moderate
    ## 72                         From air_Moderate to sea_Moderate
    ## 73                         From air_Moderate to sea_Moderate
    ## 74                         From air_Moderate to sea_Moderate
    ## 75                 From air_Moderate to naturalsoil_Moderate
    ## 76                 From air_Moderate to naturalsoil_Moderate
    ## 77                 From air_Moderate to naturalsoil_Moderate
    ## 78                         From air_Moderate to sea_Moderate
    ## 79                         From air_Moderate to sea_Moderate
    ## 80                         From air_Moderate to sea_Moderate
    ## 81            From air_Regional to agriculturalsoil_Regional
    ## 82            From air_Regional to agriculturalsoil_Regional
    ## 83            From air_Regional to agriculturalsoil_Regional
    ## 84                        From air_Regional to lake_Regional
    ## 85                        From air_Regional to lake_Regional
    ## 86                        From air_Regional to lake_Regional
    ## 87                 From air_Regional to naturalsoil_Regional
    ## 88                 From air_Regional to naturalsoil_Regional
    ## 89                 From air_Regional to naturalsoil_Regional
    ## 90                   From air_Regional to othersoil_Regional
    ## 91                   From air_Regional to othersoil_Regional
    ## 92                   From air_Regional to othersoil_Regional
    ## 93                       From air_Regional to river_Regional
    ## 94                       From air_Regional to river_Regional
    ## 95                       From air_Regional to river_Regional
    ## 96                         From air_Regional to sea_Regional
    ## 97                         From air_Regional to sea_Regional
    ## 98                         From air_Regional to sea_Regional
    ## 99            From air_Regional to agriculturalsoil_Regional
    ## 100           From air_Regional to agriculturalsoil_Regional
    ## 101           From air_Regional to agriculturalsoil_Regional
    ## 102                       From air_Regional to lake_Regional
    ## 103                       From air_Regional to lake_Regional
    ## 104                       From air_Regional to lake_Regional
    ## 105                From air_Regional to naturalsoil_Regional
    ## 106                From air_Regional to naturalsoil_Regional
    ## 107                From air_Regional to naturalsoil_Regional
    ## 108                  From air_Regional to othersoil_Regional
    ## 109                  From air_Regional to othersoil_Regional
    ## 110                  From air_Regional to othersoil_Regional
    ## 111                      From air_Regional to river_Regional
    ## 112                      From air_Regional to river_Regional
    ## 113                      From air_Regional to river_Regional
    ## 114                        From air_Regional to sea_Regional
    ## 115                        From air_Regional to sea_Regional
    ## 116                        From air_Regional to sea_Regional
    ## 117                    From air_Tropic to naturalsoil_Tropic
    ## 118                    From air_Tropic to naturalsoil_Tropic
    ## 119                    From air_Tropic to naturalsoil_Tropic
    ## 120                            From air_Tropic to sea_Tropic
    ## 121                            From air_Tropic to sea_Tropic
    ## 122                            From air_Tropic to sea_Tropic
    ## 123                    From air_Tropic to naturalsoil_Tropic
    ## 124                    From air_Tropic to naturalsoil_Tropic
    ## 125                    From air_Tropic to naturalsoil_Tropic
    ## 126                            From air_Tropic to sea_Tropic
    ## 127                            From air_Tropic to sea_Tropic
    ## 128                            From air_Tropic to sea_Tropic
    ## 129                From deepocean_Arctic to deepocean_Arctic
    ## 130                From deepocean_Arctic to deepocean_Arctic
    ## 131                From deepocean_Arctic to deepocean_Arctic
    ## 132                From deepocean_Arctic to deepocean_Arctic
    ## 133                From deepocean_Arctic to deepocean_Arctic
    ## 134                From deepocean_Arctic to deepocean_Arctic
    ## 135                            From sea_Arctic to sea_Arctic
    ## 136                            From sea_Arctic to sea_Arctic
    ## 137                            From sea_Arctic to sea_Arctic
    ## 138                            From sea_Arctic to sea_Arctic
    ## 139                            From sea_Arctic to sea_Arctic
    ## 140                            From sea_Arctic to sea_Arctic
    ## 141                From lake_Continental to lake_Continental
    ## 142                From lake_Continental to lake_Continental
    ## 143                From lake_Continental to lake_Continental
    ## 144                From lake_Continental to lake_Continental
    ## 145                From lake_Continental to lake_Continental
    ## 146                From lake_Continental to lake_Continental
    ## 147              From river_Continental to river_Continental
    ## 148              From river_Continental to river_Continental
    ## 149              From river_Continental to river_Continental
    ## 150              From river_Continental to river_Continental
    ## 151              From river_Continental to river_Continental
    ## 152              From river_Continental to river_Continental
    ## 153                  From sea_Continental to sea_Continental
    ## 154                  From sea_Continental to sea_Continental
    ## 155                  From sea_Continental to sea_Continental
    ## 156                  From sea_Continental to sea_Continental
    ## 157                  From sea_Continental to sea_Continental
    ## 158                  From sea_Continental to sea_Continental
    ## 159            From deepocean_Moderate to deepocean_Moderate
    ## 160            From deepocean_Moderate to deepocean_Moderate
    ## 161            From deepocean_Moderate to deepocean_Moderate
    ## 162            From deepocean_Moderate to deepocean_Moderate
    ## 163            From deepocean_Moderate to deepocean_Moderate
    ## 164            From deepocean_Moderate to deepocean_Moderate
    ## 165                        From sea_Moderate to sea_Moderate
    ## 166                        From sea_Moderate to sea_Moderate
    ## 167                        From sea_Moderate to sea_Moderate
    ## 168                        From sea_Moderate to sea_Moderate
    ## 169                        From sea_Moderate to sea_Moderate
    ## 170                        From sea_Moderate to sea_Moderate
    ## 171                      From lake_Regional to lake_Regional
    ## 172                      From lake_Regional to lake_Regional
    ## 173                      From lake_Regional to lake_Regional
    ## 174                      From lake_Regional to lake_Regional
    ## 175                      From lake_Regional to lake_Regional
    ## 176                      From lake_Regional to lake_Regional
    ## 177                    From river_Regional to river_Regional
    ## 178                    From river_Regional to river_Regional
    ## 179                    From river_Regional to river_Regional
    ## 180                    From river_Regional to river_Regional
    ## 181                    From river_Regional to river_Regional
    ## 182                    From river_Regional to river_Regional
    ## 183                        From sea_Regional to sea_Regional
    ## 184                        From sea_Regional to sea_Regional
    ## 185                        From sea_Regional to sea_Regional
    ## 186                        From sea_Regional to sea_Regional
    ## 187                        From sea_Regional to sea_Regional
    ## 188                        From sea_Regional to sea_Regional
    ## 189                From deepocean_Tropic to deepocean_Tropic
    ## 190                From deepocean_Tropic to deepocean_Tropic
    ## 191                From deepocean_Tropic to deepocean_Tropic
    ## 192                From deepocean_Tropic to deepocean_Tropic
    ## 193                From deepocean_Tropic to deepocean_Tropic
    ## 194                From deepocean_Tropic to deepocean_Tropic
    ## 195                            From sea_Tropic to sea_Tropic
    ## 196                            From sea_Tropic to sea_Tropic
    ## 197                            From sea_Tropic to sea_Tropic
    ## 198                            From sea_Tropic to sea_Tropic
    ## 199                            From sea_Tropic to sea_Tropic
    ## 200                            From sea_Tropic to sea_Tropic
    ## 201           From deepocean_Arctic to marinesediment_Arctic
    ## 202           From deepocean_Arctic to marinesediment_Arctic
    ## 203           From deepocean_Arctic to marinesediment_Arctic
    ## 204           From deepocean_Arctic to marinesediment_Arctic
    ## 205           From deepocean_Arctic to marinesediment_Arctic
    ## 206           From deepocean_Arctic to marinesediment_Arctic
    ## 207           From deepocean_Arctic to marinesediment_Arctic
    ## 208           From deepocean_Arctic to marinesediment_Arctic
    ## 209           From deepocean_Arctic to marinesediment_Arctic
    ## 210                      From sea_Arctic to deepocean_Arctic
    ## 211                      From sea_Arctic to deepocean_Arctic
    ## 212                      From sea_Arctic to deepocean_Arctic
    ## 213                      From sea_Arctic to deepocean_Arctic
    ## 214                      From sea_Arctic to deepocean_Arctic
    ## 215                      From sea_Arctic to deepocean_Arctic
    ## 216                      From sea_Arctic to deepocean_Arctic
    ## 217                      From sea_Arctic to deepocean_Arctic
    ## 218                      From sea_Arctic to deepocean_Arctic
    ## 219        From lake_Continental to lakesediment_Continental
    ## 220        From lake_Continental to lakesediment_Continental
    ## 221        From lake_Continental to lakesediment_Continental
    ## 222        From lake_Continental to lakesediment_Continental
    ## 223        From lake_Continental to lakesediment_Continental
    ## 224        From lake_Continental to lakesediment_Continental
    ## 225        From lake_Continental to lakesediment_Continental
    ## 226        From lake_Continental to lakesediment_Continental
    ## 227        From lake_Continental to lakesediment_Continental
    ## 228 From river_Continental to freshwatersediment_Continental
    ## 229 From river_Continental to freshwatersediment_Continental
    ## 230 From river_Continental to freshwatersediment_Continental
    ## 231 From river_Continental to freshwatersediment_Continental
    ## 232 From river_Continental to freshwatersediment_Continental
    ## 233 From river_Continental to freshwatersediment_Continental
    ## 234 From river_Continental to freshwatersediment_Continental
    ## 235 From river_Continental to freshwatersediment_Continental
    ## 236 From river_Continental to freshwatersediment_Continental
    ## 237       From sea_Continental to marinesediment_Continental
    ## 238       From sea_Continental to marinesediment_Continental
    ## 239       From sea_Continental to marinesediment_Continental
    ## 240       From sea_Continental to marinesediment_Continental
    ## 241       From sea_Continental to marinesediment_Continental
    ## 242       From sea_Continental to marinesediment_Continental
    ## 243       From sea_Continental to marinesediment_Continental
    ## 244       From sea_Continental to marinesediment_Continental
    ## 245       From sea_Continental to marinesediment_Continental
    ## 246       From deepocean_Moderate to marinesediment_Moderate
    ## 247       From deepocean_Moderate to marinesediment_Moderate
    ## 248       From deepocean_Moderate to marinesediment_Moderate
    ## 249       From deepocean_Moderate to marinesediment_Moderate
    ## 250       From deepocean_Moderate to marinesediment_Moderate
    ## 251       From deepocean_Moderate to marinesediment_Moderate
    ## 252       From deepocean_Moderate to marinesediment_Moderate
    ## 253       From deepocean_Moderate to marinesediment_Moderate
    ## 254       From deepocean_Moderate to marinesediment_Moderate
    ## 255                  From sea_Moderate to deepocean_Moderate
    ## 256                  From sea_Moderate to deepocean_Moderate
    ## 257                  From sea_Moderate to deepocean_Moderate
    ## 258                  From sea_Moderate to deepocean_Moderate
    ## 259                  From sea_Moderate to deepocean_Moderate
    ## 260                  From sea_Moderate to deepocean_Moderate
    ## 261                  From sea_Moderate to deepocean_Moderate
    ## 262                  From sea_Moderate to deepocean_Moderate
    ## 263                  From sea_Moderate to deepocean_Moderate
    ## 264              From lake_Regional to lakesediment_Regional
    ## 265              From lake_Regional to lakesediment_Regional
    ## 266              From lake_Regional to lakesediment_Regional
    ## 267              From lake_Regional to lakesediment_Regional
    ## 268              From lake_Regional to lakesediment_Regional
    ## 269              From lake_Regional to lakesediment_Regional
    ## 270              From lake_Regional to lakesediment_Regional
    ## 271              From lake_Regional to lakesediment_Regional
    ## 272              From lake_Regional to lakesediment_Regional
    ## 273       From river_Regional to freshwatersediment_Regional
    ## 274       From river_Regional to freshwatersediment_Regional
    ## 275       From river_Regional to freshwatersediment_Regional
    ## 276       From river_Regional to freshwatersediment_Regional
    ## 277       From river_Regional to freshwatersediment_Regional
    ## 278       From river_Regional to freshwatersediment_Regional
    ## 279       From river_Regional to freshwatersediment_Regional
    ## 280       From river_Regional to freshwatersediment_Regional
    ## 281       From river_Regional to freshwatersediment_Regional
    ## 282             From sea_Regional to marinesediment_Regional
    ## 283             From sea_Regional to marinesediment_Regional
    ## 284             From sea_Regional to marinesediment_Regional
    ## 285             From sea_Regional to marinesediment_Regional
    ## 286             From sea_Regional to marinesediment_Regional
    ## 287             From sea_Regional to marinesediment_Regional
    ## 288             From sea_Regional to marinesediment_Regional
    ## 289             From sea_Regional to marinesediment_Regional
    ## 290             From sea_Regional to marinesediment_Regional
    ## 291           From deepocean_Tropic to marinesediment_Tropic
    ## 292           From deepocean_Tropic to marinesediment_Tropic
    ## 293           From deepocean_Tropic to marinesediment_Tropic
    ## 294           From deepocean_Tropic to marinesediment_Tropic
    ## 295           From deepocean_Tropic to marinesediment_Tropic
    ## 296           From deepocean_Tropic to marinesediment_Tropic
    ## 297           From deepocean_Tropic to marinesediment_Tropic
    ## 298           From deepocean_Tropic to marinesediment_Tropic
    ## 299           From deepocean_Tropic to marinesediment_Tropic
    ## 300                      From sea_Tropic to deepocean_Tropic
    ## 301                      From sea_Tropic to deepocean_Tropic
    ## 302                      From sea_Tropic to deepocean_Tropic
    ## 303                      From sea_Tropic to deepocean_Tropic
    ## 304                      From sea_Tropic to deepocean_Tropic
    ## 305                      From sea_Tropic to deepocean_Tropic
    ## 306                      From sea_Tropic to deepocean_Tropic
    ## 307                      From sea_Tropic to deepocean_Tropic
    ## 308                      From sea_Tropic to deepocean_Tropic

As can be seen in the figures below, the new rate constants for the
substances, 1-aminoanthraquinone, microplastic, nAg_10nm, TRWP, have a
negligible difference of max 51.2651154 % difference to the previous
version. The figures below also show this and therefor this verification
of replicating the previous version with the new code is complete.

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
      panel.grid.major = element_line(size = 0.2, color = "gray90"),
      panel.background = element_blank()  
    )
  print(reldif_plot)
}
```

![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-1.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-2.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-3.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-4.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-5.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-6.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-7.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks-8.png)<!-- -->

## Quantify changes based on shape

Change shape and observe the difference (using Bagheri)

``` r
rm(list = ls()[sapply(ls(), function(x) is.function(get(x)))])
```

\##Run SBoo for a sphere Using Bagheri Dragmethod

    ## [1] "kdis is missing, setting kdis = 0"

\##Run SBoo for a fiber Using Bagheri drag method

## Change between shape (sphere and fiber)

    ##                       process   fromScale fromSubCompart fromSpecies
    ## 1   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 2   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 3   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 4   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 5   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 6   k_HeteroAgglomeration.wsd      Arctic      deepocean       Solid
    ## 7   k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 8   k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 9   k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 10  k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 11  k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 12  k_HeteroAgglomeration.wsd      Arctic            sea       Solid
    ## 13  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 14  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 15  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 16  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 17  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 18  k_HeteroAgglomeration.wsd Continental           lake       Solid
    ## 19  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 20  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 21  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 22  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 23  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 24  k_HeteroAgglomeration.wsd Continental          river       Solid
    ## 25  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 26  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 27  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 28  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 29  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 30  k_HeteroAgglomeration.wsd Continental            sea       Solid
    ## 31  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 32  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 33  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 34  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 35  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 36  k_HeteroAgglomeration.wsd    Moderate      deepocean       Solid
    ## 37  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 38  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 39  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 40  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 41  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 42  k_HeteroAgglomeration.wsd    Moderate            sea       Solid
    ## 43  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 44  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 45  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 46  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 47  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 48  k_HeteroAgglomeration.wsd    Regional           lake       Solid
    ## 49  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 50  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 51  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 52  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 53  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 54  k_HeteroAgglomeration.wsd    Regional          river       Solid
    ## 55  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 56  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 57  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 58  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 59  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 60  k_HeteroAgglomeration.wsd    Regional            sea       Solid
    ## 61  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 62  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 63  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 64  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 65  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 66  k_HeteroAgglomeration.wsd      Tropic      deepocean       Solid
    ## 67  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 68  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 69  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 70  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 71  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 72  k_HeteroAgglomeration.wsd      Tropic            sea       Solid
    ## 73            k_Sedimentation      Arctic      deepocean       Large
    ## 74            k_Sedimentation      Arctic      deepocean       Large
    ## 75            k_Sedimentation      Arctic      deepocean       Large
    ## 76            k_Sedimentation      Arctic      deepocean       Small
    ## 77            k_Sedimentation      Arctic      deepocean       Small
    ## 78            k_Sedimentation      Arctic      deepocean       Small
    ## 79            k_Sedimentation      Arctic      deepocean       Solid
    ## 80            k_Sedimentation      Arctic      deepocean       Solid
    ## 81            k_Sedimentation      Arctic      deepocean       Solid
    ## 82            k_Sedimentation      Arctic            sea       Large
    ## 83            k_Sedimentation      Arctic            sea       Large
    ## 84            k_Sedimentation      Arctic            sea       Large
    ## 85            k_Sedimentation      Arctic            sea       Small
    ## 86            k_Sedimentation      Arctic            sea       Small
    ## 87            k_Sedimentation      Arctic            sea       Small
    ## 88            k_Sedimentation      Arctic            sea       Solid
    ## 89            k_Sedimentation      Arctic            sea       Solid
    ## 90            k_Sedimentation      Arctic            sea       Solid
    ## 91            k_Sedimentation Continental           lake       Large
    ## 92            k_Sedimentation Continental           lake       Large
    ## 93            k_Sedimentation Continental           lake       Large
    ## 94            k_Sedimentation Continental           lake       Small
    ## 95            k_Sedimentation Continental           lake       Small
    ## 96            k_Sedimentation Continental           lake       Small
    ## 97            k_Sedimentation Continental           lake       Solid
    ## 98            k_Sedimentation Continental           lake       Solid
    ## 99            k_Sedimentation Continental           lake       Solid
    ## 100           k_Sedimentation Continental          river       Large
    ## 101           k_Sedimentation Continental          river       Large
    ## 102           k_Sedimentation Continental          river       Large
    ## 103           k_Sedimentation Continental          river       Small
    ## 104           k_Sedimentation Continental          river       Small
    ## 105           k_Sedimentation Continental          river       Small
    ## 106           k_Sedimentation Continental          river       Solid
    ## 107           k_Sedimentation Continental          river       Solid
    ## 108           k_Sedimentation Continental          river       Solid
    ## 109           k_Sedimentation Continental            sea       Large
    ## 110           k_Sedimentation Continental            sea       Large
    ## 111           k_Sedimentation Continental            sea       Large
    ## 112           k_Sedimentation Continental            sea       Small
    ## 113           k_Sedimentation Continental            sea       Small
    ## 114           k_Sedimentation Continental            sea       Small
    ## 115           k_Sedimentation Continental            sea       Solid
    ## 116           k_Sedimentation Continental            sea       Solid
    ## 117           k_Sedimentation Continental            sea       Solid
    ## 118           k_Sedimentation    Moderate      deepocean       Large
    ## 119           k_Sedimentation    Moderate      deepocean       Large
    ## 120           k_Sedimentation    Moderate      deepocean       Large
    ## 121           k_Sedimentation    Moderate      deepocean       Small
    ## 122           k_Sedimentation    Moderate      deepocean       Small
    ## 123           k_Sedimentation    Moderate      deepocean       Small
    ## 124           k_Sedimentation    Moderate      deepocean       Solid
    ## 125           k_Sedimentation    Moderate      deepocean       Solid
    ## 126           k_Sedimentation    Moderate      deepocean       Solid
    ## 127           k_Sedimentation    Moderate            sea       Large
    ## 128           k_Sedimentation    Moderate            sea       Large
    ## 129           k_Sedimentation    Moderate            sea       Large
    ## 130           k_Sedimentation    Moderate            sea       Small
    ## 131           k_Sedimentation    Moderate            sea       Small
    ## 132           k_Sedimentation    Moderate            sea       Small
    ## 133           k_Sedimentation    Moderate            sea       Solid
    ## 134           k_Sedimentation    Moderate            sea       Solid
    ## 135           k_Sedimentation    Moderate            sea       Solid
    ## 136           k_Sedimentation    Regional           lake       Large
    ## 137           k_Sedimentation    Regional           lake       Large
    ## 138           k_Sedimentation    Regional           lake       Large
    ## 139           k_Sedimentation    Regional           lake       Small
    ## 140           k_Sedimentation    Regional           lake       Small
    ## 141           k_Sedimentation    Regional           lake       Small
    ## 142           k_Sedimentation    Regional           lake       Solid
    ## 143           k_Sedimentation    Regional           lake       Solid
    ## 144           k_Sedimentation    Regional           lake       Solid
    ## 145           k_Sedimentation    Regional          river       Large
    ## 146           k_Sedimentation    Regional          river       Large
    ## 147           k_Sedimentation    Regional          river       Large
    ## 148           k_Sedimentation    Regional          river       Small
    ## 149           k_Sedimentation    Regional          river       Small
    ## 150           k_Sedimentation    Regional          river       Small
    ## 151           k_Sedimentation    Regional          river       Solid
    ## 152           k_Sedimentation    Regional          river       Solid
    ## 153           k_Sedimentation    Regional          river       Solid
    ## 154           k_Sedimentation    Regional            sea       Large
    ## 155           k_Sedimentation    Regional            sea       Large
    ## 156           k_Sedimentation    Regional            sea       Large
    ## 157           k_Sedimentation    Regional            sea       Small
    ## 158           k_Sedimentation    Regional            sea       Small
    ## 159           k_Sedimentation    Regional            sea       Small
    ## 160           k_Sedimentation    Regional            sea       Solid
    ## 161           k_Sedimentation    Regional            sea       Solid
    ## 162           k_Sedimentation    Regional            sea       Solid
    ## 163           k_Sedimentation      Tropic      deepocean       Large
    ## 164           k_Sedimentation      Tropic      deepocean       Large
    ## 165           k_Sedimentation      Tropic      deepocean       Large
    ## 166           k_Sedimentation      Tropic      deepocean       Small
    ## 167           k_Sedimentation      Tropic      deepocean       Small
    ## 168           k_Sedimentation      Tropic      deepocean       Small
    ## 169           k_Sedimentation      Tropic      deepocean       Solid
    ## 170           k_Sedimentation      Tropic      deepocean       Solid
    ## 171           k_Sedimentation      Tropic      deepocean       Solid
    ## 172           k_Sedimentation      Tropic            sea       Large
    ## 173           k_Sedimentation      Tropic            sea       Large
    ## 174           k_Sedimentation      Tropic            sea       Large
    ## 175           k_Sedimentation      Tropic            sea       Small
    ## 176           k_Sedimentation      Tropic            sea       Small
    ## 177           k_Sedimentation      Tropic            sea       Small
    ## 178           k_Sedimentation      Tropic            sea       Solid
    ## 179           k_Sedimentation      Tropic            sea       Solid
    ## 180           k_Sedimentation      Tropic            sea       Solid
    ##         toScale       toSubCompart toSpecies    Substance        k_Old
    ## 1        Arctic          deepocean     Large microplastic 2.177599e-04
    ## 2        Arctic          deepocean     Large     nAg_10nm 4.686613e-05
    ## 3        Arctic          deepocean     Large         TRWP 2.177599e-04
    ## 4        Arctic          deepocean     Small microplastic 3.636368e-01
    ## 5        Arctic          deepocean     Small     nAg_10nm 2.738980e-03
    ## 6        Arctic          deepocean     Small         TRWP 3.636368e-01
    ## 7        Arctic                sea     Large microplastic 2.177599e-04
    ## 8        Arctic                sea     Large     nAg_10nm 4.686613e-05
    ## 9        Arctic                sea     Large         TRWP 2.177599e-04
    ## 10       Arctic                sea     Small microplastic 3.636368e-01
    ## 11       Arctic                sea     Small     nAg_10nm 2.738980e-03
    ## 12       Arctic                sea     Small         TRWP 3.636368e-01
    ## 13  Continental               lake     Large microplastic 1.711767e-05
    ## 14  Continental               lake     Large     nAg_10nm 3.893333e-06
    ## 15  Continental               lake     Large         TRWP 1.711767e-05
    ## 16  Continental               lake     Small microplastic 2.961334e-01
    ## 17  Continental               lake     Small     nAg_10nm 5.250454e-04
    ## 18  Continental               lake     Small         TRWP 2.961334e-01
    ## 19  Continental              river     Large microplastic 2.050789e-03
    ## 20  Continental              river     Large     nAg_10nm 2.878207e-04
    ## 21  Continental              river     Large         TRWP 2.050789e-03
    ## 22  Continental              river     Small microplastic 1.038803e+00
    ## 23  Continental              river     Small     nAg_10nm 1.133822e-03
    ## 24  Continental              river     Small         TRWP 1.038803e+00
    ## 25  Continental                sea     Large microplastic 2.177603e-04
    ## 26  Continental                sea     Large     nAg_10nm 4.901753e-05
    ## 27  Continental                sea     Large         TRWP 2.177603e-04
    ## 28  Continental                sea     Small microplastic 3.636488e-01
    ## 29  Continental                sea     Small     nAg_10nm 2.967939e-03
    ## 30  Continental                sea     Small         TRWP 3.636488e-01
    ## 31     Moderate          deepocean     Large microplastic 2.177603e-04
    ## 32     Moderate          deepocean     Large     nAg_10nm 4.901753e-05
    ## 33     Moderate          deepocean     Large         TRWP 2.177603e-04
    ## 34     Moderate          deepocean     Small microplastic 3.636488e-01
    ## 35     Moderate          deepocean     Small     nAg_10nm 2.967939e-03
    ## 36     Moderate          deepocean     Small         TRWP 3.636488e-01
    ## 37     Moderate                sea     Large microplastic 2.177603e-04
    ## 38     Moderate                sea     Large     nAg_10nm 4.901753e-05
    ## 39     Moderate                sea     Large         TRWP 2.177603e-04
    ## 40     Moderate                sea     Small microplastic 3.636488e-01
    ## 41     Moderate                sea     Small     nAg_10nm 2.967939e-03
    ## 42     Moderate                sea     Small         TRWP 3.636488e-01
    ## 43     Regional               lake     Large microplastic 1.711767e-05
    ## 44     Regional               lake     Large     nAg_10nm 3.893333e-06
    ## 45     Regional               lake     Large         TRWP 1.711767e-05
    ## 46     Regional               lake     Small microplastic 2.961334e-01
    ## 47     Regional               lake     Small     nAg_10nm 5.250454e-04
    ## 48     Regional               lake     Small         TRWP 2.961334e-01
    ## 49     Regional              river     Large microplastic 2.050789e-03
    ## 50     Regional              river     Large     nAg_10nm 2.878207e-04
    ## 51     Regional              river     Large         TRWP 2.050789e-03
    ## 52     Regional              river     Small microplastic 1.038803e+00
    ## 53     Regional              river     Small     nAg_10nm 1.133822e-03
    ## 54     Regional              river     Small         TRWP 1.038803e+00
    ## 55     Regional                sea     Large microplastic 2.177603e-04
    ## 56     Regional                sea     Large     nAg_10nm 4.901753e-05
    ## 57     Regional                sea     Large         TRWP 2.177603e-04
    ## 58     Regional                sea     Small microplastic 3.636488e-01
    ## 59     Regional                sea     Small     nAg_10nm 2.967939e-03
    ## 60     Regional                sea     Small         TRWP 3.636488e-01
    ## 61       Tropic          deepocean     Large microplastic 2.177605e-04
    ## 62       Tropic          deepocean     Large     nAg_10nm 5.028882e-05
    ## 63       Tropic          deepocean     Large         TRWP 2.177605e-04
    ## 64       Tropic          deepocean     Small microplastic 3.636560e-01
    ## 65       Tropic          deepocean     Small     nAg_10nm 3.103232e-03
    ## 66       Tropic          deepocean     Small         TRWP 3.636560e-01
    ## 67       Tropic                sea     Large microplastic 2.177605e-04
    ## 68       Tropic                sea     Large     nAg_10nm 5.028882e-05
    ## 69       Tropic                sea     Large         TRWP 2.177605e-04
    ## 70       Tropic                sea     Small microplastic 3.636560e-01
    ## 71       Tropic                sea     Small     nAg_10nm 3.103232e-03
    ## 72       Tropic                sea     Small         TRWP 3.636560e-01
    ## 73       Arctic     marinesediment     Large microplastic 1.379344e-07
    ## 74       Arctic     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 75       Arctic     marinesediment     Large         TRWP 1.379344e-07
    ## 76       Arctic     marinesediment     Small microplastic 1.368379e-07
    ## 77       Arctic     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 78       Arctic     marinesediment     Small         TRWP 1.368379e-07
    ## 79       Arctic     marinesediment     Solid microplastic 1.368378e-07
    ## 80       Arctic     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 81       Arctic     marinesediment     Solid         TRWP 1.368378e-07
    ## 82       Arctic          deepocean     Large microplastic 4.138033e-06
    ## 83       Arctic          deepocean     Large     nAg_10nm 2.940038e-07
    ## 84       Arctic          deepocean     Large         TRWP 4.138033e-06
    ## 85       Arctic          deepocean     Small microplastic 4.105137e-06
    ## 86       Arctic          deepocean     Small     nAg_10nm 4.904987e-10
    ## 87       Arctic          deepocean     Small         TRWP 4.105137e-06
    ## 88       Arctic          deepocean     Solid microplastic 4.105135e-06
    ## 89       Arctic          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 90       Arctic          deepocean     Solid         TRWP 4.105135e-06
    ## 91  Continental       lakesediment     Large microplastic 4.138033e-06
    ## 92  Continental       lakesediment     Large     nAg_10nm 2.940038e-07
    ## 93  Continental       lakesediment     Large         TRWP 4.138033e-06
    ## 94  Continental       lakesediment     Small microplastic 4.105137e-06
    ## 95  Continental       lakesediment     Small     nAg_10nm 4.904987e-10
    ## 96  Continental       lakesediment     Small         TRWP 4.105137e-06
    ## 97  Continental       lakesediment     Solid microplastic 4.105135e-06
    ## 98  Continental       lakesediment     Solid     nAg_10nm 5.166489e-12
    ## 99  Continental       lakesediment     Solid         TRWP 4.105135e-06
    ## 100 Continental freshwatersediment     Large microplastic 1.379344e-04
    ## 101 Continental freshwatersediment     Large     nAg_10nm 9.800126e-06
    ## 102 Continental freshwatersediment     Large         TRWP 1.379344e-04
    ## 103 Continental freshwatersediment     Small microplastic 1.368379e-04
    ## 104 Continental freshwatersediment     Small     nAg_10nm 1.634996e-08
    ## 105 Continental freshwatersediment     Small         TRWP 1.368379e-04
    ## 106 Continental freshwatersediment     Solid microplastic 1.368378e-04
    ## 107 Continental freshwatersediment     Solid     nAg_10nm 1.722163e-10
    ## 108 Continental freshwatersediment     Solid         TRWP 1.368378e-04
    ## 109 Continental     marinesediment     Large microplastic 2.069016e-06
    ## 110 Continental     marinesediment     Large     nAg_10nm 1.470019e-07
    ## 111 Continental     marinesediment     Large         TRWP 2.069016e-06
    ## 112 Continental     marinesediment     Small microplastic 2.052569e-06
    ## 113 Continental     marinesediment     Small     nAg_10nm 2.452493e-10
    ## 114 Continental     marinesediment     Small         TRWP 2.052569e-06
    ## 115 Continental     marinesediment     Solid microplastic 2.052567e-06
    ## 116 Continental     marinesediment     Solid     nAg_10nm 2.583244e-12
    ## 117 Continental     marinesediment     Solid         TRWP 2.052567e-06
    ## 118    Moderate     marinesediment     Large microplastic 1.379344e-07
    ## 119    Moderate     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 120    Moderate     marinesediment     Large         TRWP 1.379344e-07
    ## 121    Moderate     marinesediment     Small microplastic 1.368379e-07
    ## 122    Moderate     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 123    Moderate     marinesediment     Small         TRWP 1.368379e-07
    ## 124    Moderate     marinesediment     Solid microplastic 1.368378e-07
    ## 125    Moderate     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 126    Moderate     marinesediment     Solid         TRWP 1.368378e-07
    ## 127    Moderate          deepocean     Large microplastic 4.138033e-06
    ## 128    Moderate          deepocean     Large     nAg_10nm 2.940038e-07
    ## 129    Moderate          deepocean     Large         TRWP 4.138033e-06
    ## 130    Moderate          deepocean     Small microplastic 4.105137e-06
    ## 131    Moderate          deepocean     Small     nAg_10nm 4.904987e-10
    ## 132    Moderate          deepocean     Small         TRWP 4.105137e-06
    ## 133    Moderate          deepocean     Solid microplastic 4.105135e-06
    ## 134    Moderate          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 135    Moderate          deepocean     Solid         TRWP 4.105135e-06
    ## 136    Regional       lakesediment     Large microplastic 4.138033e-06
    ## 137    Regional       lakesediment     Large     nAg_10nm 2.940038e-07
    ## 138    Regional       lakesediment     Large         TRWP 4.138033e-06
    ## 139    Regional       lakesediment     Small microplastic 4.105137e-06
    ## 140    Regional       lakesediment     Small     nAg_10nm 4.904987e-10
    ## 141    Regional       lakesediment     Small         TRWP 4.105137e-06
    ## 142    Regional       lakesediment     Solid microplastic 4.105135e-06
    ## 143    Regional       lakesediment     Solid     nAg_10nm 5.166489e-12
    ## 144    Regional       lakesediment     Solid         TRWP 4.105135e-06
    ## 145    Regional freshwatersediment     Large microplastic 1.379344e-04
    ## 146    Regional freshwatersediment     Large     nAg_10nm 9.800126e-06
    ## 147    Regional freshwatersediment     Large         TRWP 1.379344e-04
    ## 148    Regional freshwatersediment     Small microplastic 1.368379e-04
    ## 149    Regional freshwatersediment     Small     nAg_10nm 1.634996e-08
    ## 150    Regional freshwatersediment     Small         TRWP 1.368379e-04
    ## 151    Regional freshwatersediment     Solid microplastic 1.368378e-04
    ## 152    Regional freshwatersediment     Solid     nAg_10nm 1.722163e-10
    ## 153    Regional freshwatersediment     Solid         TRWP 1.368378e-04
    ## 154    Regional     marinesediment     Large microplastic 4.138033e-05
    ## 155    Regional     marinesediment     Large     nAg_10nm 2.940038e-06
    ## 156    Regional     marinesediment     Large         TRWP 4.138033e-05
    ## 157    Regional     marinesediment     Small microplastic 4.105137e-05
    ## 158    Regional     marinesediment     Small     nAg_10nm 4.904987e-09
    ## 159    Regional     marinesediment     Small         TRWP 4.105137e-05
    ## 160    Regional     marinesediment     Solid microplastic 4.105135e-05
    ## 161    Regional     marinesediment     Solid     nAg_10nm 5.166489e-11
    ## 162    Regional     marinesediment     Solid         TRWP 4.105135e-05
    ## 163      Tropic     marinesediment     Large microplastic 1.379344e-07
    ## 164      Tropic     marinesediment     Large     nAg_10nm 9.800126e-09
    ## 165      Tropic     marinesediment     Large         TRWP 1.379344e-07
    ## 166      Tropic     marinesediment     Small microplastic 1.368379e-07
    ## 167      Tropic     marinesediment     Small     nAg_10nm 1.634996e-11
    ## 168      Tropic     marinesediment     Small         TRWP 1.368379e-07
    ## 169      Tropic     marinesediment     Solid microplastic 1.368378e-07
    ## 170      Tropic     marinesediment     Solid     nAg_10nm 1.722163e-13
    ## 171      Tropic     marinesediment     Solid         TRWP 1.368378e-07
    ## 172      Tropic          deepocean     Large microplastic 4.138033e-06
    ## 173      Tropic          deepocean     Large     nAg_10nm 2.940038e-07
    ## 174      Tropic          deepocean     Large         TRWP 4.138033e-06
    ## 175      Tropic          deepocean     Small microplastic 4.105137e-06
    ## 176      Tropic          deepocean     Small     nAg_10nm 4.904987e-10
    ## 177      Tropic          deepocean     Small         TRWP 4.105137e-06
    ## 178      Tropic          deepocean     Solid microplastic 4.105135e-06
    ## 179      Tropic          deepocean     Solid     nAg_10nm 5.166489e-12
    ## 180      Tropic          deepocean     Solid         TRWP 4.105135e-06
    ##            k_New          diff      rel_diff
    ## 1   3.817803e-04  1.640203e-04  4.296197e-01
    ## 2   4.686586e-05 -2.677646e-10 -5.713426e-06
    ## 3   3.817803e-04  1.640203e-04  4.296197e-01
    ## 4   6.282963e-01  2.646596e-01  4.212337e-01
    ## 5   2.738979e-03 -1.424812e-09 -5.201984e-07
    ## 6   6.282963e-01  2.646596e-01  4.212337e-01
    ## 7   3.817803e-04  1.640203e-04  4.296197e-01
    ## 8   4.686586e-05 -2.677646e-10 -5.713426e-06
    ## 9   3.817803e-04  1.640203e-04  4.296197e-01
    ## 10  6.282963e-01  2.646596e-01  4.212337e-01
    ## 11  2.738979e-03 -1.424812e-09 -5.201984e-07
    ## 12  6.282963e-01  2.646596e-01  4.212337e-01
    ## 13  3.351970e-05  1.640203e-05  4.893251e-01
    ## 14  3.893309e-06 -2.409882e-11 -6.189803e-06
    ## 15  3.351970e-05  1.640203e-05  4.893251e-01
    ## 16  5.607930e-01  2.646596e-01  4.719381e-01
    ## 17  5.250451e-04 -2.521918e-10 -4.803240e-07
    ## 18  5.607930e-01  2.646596e-01  4.719381e-01
    ## 19  2.542850e-03  4.920610e-04  1.935077e-01
    ## 20  2.878200e-04 -7.229645e-10 -2.511863e-06
    ## 21  2.542850e-03  4.920610e-04  1.935077e-01
    ## 22  1.303462e+00  2.646596e-01  2.030435e-01
    ## 23  1.133822e-03 -5.414287e-10 -4.775253e-07
    ## 24  1.303462e+00  2.646596e-01  2.030435e-01
    ## 25  3.817806e-04  1.640203e-04  4.296193e-01
    ## 26  4.901727e-05 -2.677646e-10 -5.462659e-06
    ## 27  3.817806e-04  1.640203e-04  4.296193e-01
    ## 28  6.283084e-01  2.646596e-01  4.212256e-01
    ## 29  2.967937e-03 -1.424812e-09 -4.800682e-07
    ## 30  6.283084e-01  2.646596e-01  4.212256e-01
    ## 31  3.817806e-04  1.640203e-04  4.296193e-01
    ## 32  4.901727e-05 -2.677646e-10 -5.462659e-06
    ## 33  3.817806e-04  1.640203e-04  4.296193e-01
    ## 34  6.283084e-01  2.646596e-01  4.212256e-01
    ## 35  2.967937e-03 -1.424812e-09 -4.800682e-07
    ## 36  6.283084e-01  2.646596e-01  4.212256e-01
    ## 37  3.817806e-04  1.640203e-04  4.296193e-01
    ## 38  4.901727e-05 -2.677646e-10 -5.462659e-06
    ## 39  3.817806e-04  1.640203e-04  4.296193e-01
    ## 40  6.283084e-01  2.646596e-01  4.212256e-01
    ## 41  2.967937e-03 -1.424812e-09 -4.800682e-07
    ## 42  6.283084e-01  2.646596e-01  4.212256e-01
    ## 43  3.351970e-05  1.640203e-05  4.893251e-01
    ## 44  3.893309e-06 -2.409882e-11 -6.189803e-06
    ## 45  3.351970e-05  1.640203e-05  4.893251e-01
    ## 46  5.607930e-01  2.646596e-01  4.719381e-01
    ## 47  5.250451e-04 -2.521918e-10 -4.803240e-07
    ## 48  5.607930e-01  2.646596e-01  4.719381e-01
    ## 49  2.542850e-03  4.920610e-04  1.935077e-01
    ## 50  2.878200e-04 -7.229645e-10 -2.511863e-06
    ## 51  2.542850e-03  4.920610e-04  1.935077e-01
    ## 52  1.303462e+00  2.646596e-01  2.030435e-01
    ## 53  1.133822e-03 -5.414287e-10 -4.775253e-07
    ## 54  1.303462e+00  2.646596e-01  2.030435e-01
    ## 55  3.817806e-04  1.640203e-04  4.296193e-01
    ## 56  4.901727e-05 -2.677646e-10 -5.462659e-06
    ## 57  3.817806e-04  1.640203e-04  4.296193e-01
    ## 58  6.283084e-01  2.646596e-01  4.212256e-01
    ## 59  2.967937e-03 -1.424812e-09 -4.800682e-07
    ## 60  6.283084e-01  2.646596e-01  4.212256e-01
    ## 61  3.817809e-04  1.640203e-04  4.296191e-01
    ## 62  5.028855e-05 -2.677646e-10 -5.324564e-06
    ## 63  3.817809e-04  1.640203e-04  4.296191e-01
    ## 64  6.283155e-01  2.646596e-01  4.212208e-01
    ## 65  3.103231e-03 -1.424812e-09 -4.591383e-07
    ## 66  6.283155e-01  2.646596e-01  4.212208e-01
    ## 67  3.817809e-04  1.640203e-04  4.296191e-01
    ## 68  5.028855e-05 -2.677646e-10 -5.324564e-06
    ## 69  3.817809e-04  1.640203e-04  4.296191e-01
    ## 70  6.283155e-01  2.646596e-01  4.212208e-01
    ## 71  3.103231e-03 -1.424812e-09 -4.591383e-07
    ## 72  6.283155e-01  2.646596e-01  4.212208e-01
    ## 73  3.333333e-04  3.331954e-04  9.995862e-01
    ## 74  3.333333e-04  3.333235e-04  9.999706e-01
    ## 75  3.333333e-04  3.331954e-04  9.995862e-01
    ## 76  3.333333e-04  3.331965e-04  9.995895e-01
    ## 77  3.333333e-04  3.333333e-04  1.000000e+00
    ## 78  3.333333e-04  3.331965e-04  9.995895e-01
    ## 79  3.333333e-04  3.331965e-04  9.995895e-01
    ## 80  3.333333e-04  3.333333e-04  1.000000e+00
    ## 81  3.333333e-04  3.331965e-04  9.995895e-01
    ## 82  1.000000e-02  9.995862e-03  9.995862e-01
    ## 83  1.000000e-02  9.999706e-03  9.999706e-01
    ## 84  1.000000e-02  9.995862e-03  9.995862e-01
    ## 85  1.000000e-02  9.995895e-03  9.995895e-01
    ## 86  1.000000e-02  9.999999e-03  1.000000e+00
    ## 87  1.000000e-02  9.995895e-03  9.995895e-01
    ## 88  1.000000e-02  9.995895e-03  9.995895e-01
    ## 89  1.000000e-02  1.000000e-02  1.000000e+00
    ## 90  1.000000e-02  9.995895e-03  9.995895e-01
    ## 91  1.000000e-02  9.995862e-03  9.995862e-01
    ## 92  1.000000e-02  9.999706e-03  9.999706e-01
    ## 93  1.000000e-02  9.995862e-03  9.995862e-01
    ## 94  1.000000e-02  9.995895e-03  9.995895e-01
    ## 95  1.000000e-02  9.999999e-03  1.000000e+00
    ## 96  1.000000e-02  9.995895e-03  9.995895e-01
    ## 97  1.000000e-02  9.995895e-03  9.995895e-01
    ## 98  1.000000e-02  1.000000e-02  1.000000e+00
    ## 99  1.000000e-02  9.995895e-03  9.995895e-01
    ## 100 3.333333e-01  3.331954e-01  9.995862e-01
    ## 101 3.333333e-01  3.333235e-01  9.999706e-01
    ## 102 3.333333e-01  3.331954e-01  9.995862e-01
    ## 103 3.333333e-01  3.331965e-01  9.995895e-01
    ## 104 3.333333e-01  3.333333e-01  1.000000e+00
    ## 105 3.333333e-01  3.331965e-01  9.995895e-01
    ## 106 3.333333e-01  3.331965e-01  9.995895e-01
    ## 107 3.333333e-01  3.333333e-01  1.000000e+00
    ## 108 3.333333e-01  3.331965e-01  9.995895e-01
    ## 109 5.000000e-03  4.997931e-03  9.995862e-01
    ## 110 5.000000e-03  4.999853e-03  9.999706e-01
    ## 111 5.000000e-03  4.997931e-03  9.995862e-01
    ## 112 5.000000e-03  4.997947e-03  9.995895e-01
    ## 113 5.000000e-03  5.000000e-03  1.000000e+00
    ## 114 5.000000e-03  4.997947e-03  9.995895e-01
    ## 115 5.000000e-03  4.997947e-03  9.995895e-01
    ## 116 5.000000e-03  5.000000e-03  1.000000e+00
    ## 117 5.000000e-03  4.997947e-03  9.995895e-01
    ## 118 3.333333e-04  3.331954e-04  9.995862e-01
    ## 119 3.333333e-04  3.333235e-04  9.999706e-01
    ## 120 3.333333e-04  3.331954e-04  9.995862e-01
    ## 121 3.333333e-04  3.331965e-04  9.995895e-01
    ## 122 3.333333e-04  3.333333e-04  1.000000e+00
    ## 123 3.333333e-04  3.331965e-04  9.995895e-01
    ## 124 3.333333e-04  3.331965e-04  9.995895e-01
    ## 125 3.333333e-04  3.333333e-04  1.000000e+00
    ## 126 3.333333e-04  3.331965e-04  9.995895e-01
    ## 127 1.000000e-02  9.995862e-03  9.995862e-01
    ## 128 1.000000e-02  9.999706e-03  9.999706e-01
    ## 129 1.000000e-02  9.995862e-03  9.995862e-01
    ## 130 1.000000e-02  9.995895e-03  9.995895e-01
    ## 131 1.000000e-02  9.999999e-03  1.000000e+00
    ## 132 1.000000e-02  9.995895e-03  9.995895e-01
    ## 133 1.000000e-02  9.995895e-03  9.995895e-01
    ## 134 1.000000e-02  1.000000e-02  1.000000e+00
    ## 135 1.000000e-02  9.995895e-03  9.995895e-01
    ## 136 1.000000e-02  9.995862e-03  9.995862e-01
    ## 137 1.000000e-02  9.999706e-03  9.999706e-01
    ## 138 1.000000e-02  9.995862e-03  9.995862e-01
    ## 139 1.000000e-02  9.995895e-03  9.995895e-01
    ## 140 1.000000e-02  9.999999e-03  1.000000e+00
    ## 141 1.000000e-02  9.995895e-03  9.995895e-01
    ## 142 1.000000e-02  9.995895e-03  9.995895e-01
    ## 143 1.000000e-02  1.000000e-02  1.000000e+00
    ## 144 1.000000e-02  9.995895e-03  9.995895e-01
    ## 145 3.333333e-01  3.331954e-01  9.995862e-01
    ## 146 3.333333e-01  3.333235e-01  9.999706e-01
    ## 147 3.333333e-01  3.331954e-01  9.995862e-01
    ## 148 3.333333e-01  3.331965e-01  9.995895e-01
    ## 149 3.333333e-01  3.333333e-01  1.000000e+00
    ## 150 3.333333e-01  3.331965e-01  9.995895e-01
    ## 151 3.333333e-01  3.331965e-01  9.995895e-01
    ## 152 3.333333e-01  3.333333e-01  1.000000e+00
    ## 153 3.333333e-01  3.331965e-01  9.995895e-01
    ## 154 1.000000e-01  9.995862e-02  9.995862e-01
    ## 155 1.000000e-01  9.999706e-02  9.999706e-01
    ## 156 1.000000e-01  9.995862e-02  9.995862e-01
    ## 157 1.000000e-01  9.995895e-02  9.995895e-01
    ## 158 1.000000e-01  9.999999e-02  1.000000e+00
    ## 159 1.000000e-01  9.995895e-02  9.995895e-01
    ## 160 1.000000e-01  9.995895e-02  9.995895e-01
    ## 161 1.000000e-01  1.000000e-01  1.000000e+00
    ## 162 1.000000e-01  9.995895e-02  9.995895e-01
    ## 163 3.333333e-04  3.331954e-04  9.995862e-01
    ## 164 3.333333e-04  3.333235e-04  9.999706e-01
    ## 165 3.333333e-04  3.331954e-04  9.995862e-01
    ## 166 3.333333e-04  3.331965e-04  9.995895e-01
    ## 167 3.333333e-04  3.333333e-04  1.000000e+00
    ## 168 3.333333e-04  3.331965e-04  9.995895e-01
    ## 169 3.333333e-04  3.331965e-04  9.995895e-01
    ## 170 3.333333e-04  3.333333e-04  1.000000e+00
    ## 171 3.333333e-04  3.331965e-04  9.995895e-01
    ## 172 1.000000e-02  9.995862e-03  9.995862e-01
    ## 173 1.000000e-02  9.999706e-03  9.999706e-01
    ## 174 1.000000e-02  9.995862e-03  9.995862e-01
    ## 175 1.000000e-02  9.995895e-03  9.995895e-01
    ## 176 1.000000e-02  9.999999e-03  1.000000e+00
    ## 177 1.000000e-02  9.995895e-03  9.995895e-01
    ## 178 1.000000e-02  9.995895e-03  9.995895e-01
    ## 179 1.000000e-02  1.000000e-02  1.000000e+00
    ## 180 1.000000e-02  9.995895e-03  9.995895e-01
    ##                                                    full_name
    ## 1                  From deepocean_Arctic to deepocean_Arctic
    ## 2                  From deepocean_Arctic to deepocean_Arctic
    ## 3                  From deepocean_Arctic to deepocean_Arctic
    ## 4                  From deepocean_Arctic to deepocean_Arctic
    ## 5                  From deepocean_Arctic to deepocean_Arctic
    ## 6                  From deepocean_Arctic to deepocean_Arctic
    ## 7                              From sea_Arctic to sea_Arctic
    ## 8                              From sea_Arctic to sea_Arctic
    ## 9                              From sea_Arctic to sea_Arctic
    ## 10                             From sea_Arctic to sea_Arctic
    ## 11                             From sea_Arctic to sea_Arctic
    ## 12                             From sea_Arctic to sea_Arctic
    ## 13                 From lake_Continental to lake_Continental
    ## 14                 From lake_Continental to lake_Continental
    ## 15                 From lake_Continental to lake_Continental
    ## 16                 From lake_Continental to lake_Continental
    ## 17                 From lake_Continental to lake_Continental
    ## 18                 From lake_Continental to lake_Continental
    ## 19               From river_Continental to river_Continental
    ## 20               From river_Continental to river_Continental
    ## 21               From river_Continental to river_Continental
    ## 22               From river_Continental to river_Continental
    ## 23               From river_Continental to river_Continental
    ## 24               From river_Continental to river_Continental
    ## 25                   From sea_Continental to sea_Continental
    ## 26                   From sea_Continental to sea_Continental
    ## 27                   From sea_Continental to sea_Continental
    ## 28                   From sea_Continental to sea_Continental
    ## 29                   From sea_Continental to sea_Continental
    ## 30                   From sea_Continental to sea_Continental
    ## 31             From deepocean_Moderate to deepocean_Moderate
    ## 32             From deepocean_Moderate to deepocean_Moderate
    ## 33             From deepocean_Moderate to deepocean_Moderate
    ## 34             From deepocean_Moderate to deepocean_Moderate
    ## 35             From deepocean_Moderate to deepocean_Moderate
    ## 36             From deepocean_Moderate to deepocean_Moderate
    ## 37                         From sea_Moderate to sea_Moderate
    ## 38                         From sea_Moderate to sea_Moderate
    ## 39                         From sea_Moderate to sea_Moderate
    ## 40                         From sea_Moderate to sea_Moderate
    ## 41                         From sea_Moderate to sea_Moderate
    ## 42                         From sea_Moderate to sea_Moderate
    ## 43                       From lake_Regional to lake_Regional
    ## 44                       From lake_Regional to lake_Regional
    ## 45                       From lake_Regional to lake_Regional
    ## 46                       From lake_Regional to lake_Regional
    ## 47                       From lake_Regional to lake_Regional
    ## 48                       From lake_Regional to lake_Regional
    ## 49                     From river_Regional to river_Regional
    ## 50                     From river_Regional to river_Regional
    ## 51                     From river_Regional to river_Regional
    ## 52                     From river_Regional to river_Regional
    ## 53                     From river_Regional to river_Regional
    ## 54                     From river_Regional to river_Regional
    ## 55                         From sea_Regional to sea_Regional
    ## 56                         From sea_Regional to sea_Regional
    ## 57                         From sea_Regional to sea_Regional
    ## 58                         From sea_Regional to sea_Regional
    ## 59                         From sea_Regional to sea_Regional
    ## 60                         From sea_Regional to sea_Regional
    ## 61                 From deepocean_Tropic to deepocean_Tropic
    ## 62                 From deepocean_Tropic to deepocean_Tropic
    ## 63                 From deepocean_Tropic to deepocean_Tropic
    ## 64                 From deepocean_Tropic to deepocean_Tropic
    ## 65                 From deepocean_Tropic to deepocean_Tropic
    ## 66                 From deepocean_Tropic to deepocean_Tropic
    ## 67                             From sea_Tropic to sea_Tropic
    ## 68                             From sea_Tropic to sea_Tropic
    ## 69                             From sea_Tropic to sea_Tropic
    ## 70                             From sea_Tropic to sea_Tropic
    ## 71                             From sea_Tropic to sea_Tropic
    ## 72                             From sea_Tropic to sea_Tropic
    ## 73            From deepocean_Arctic to marinesediment_Arctic
    ## 74            From deepocean_Arctic to marinesediment_Arctic
    ## 75            From deepocean_Arctic to marinesediment_Arctic
    ## 76            From deepocean_Arctic to marinesediment_Arctic
    ## 77            From deepocean_Arctic to marinesediment_Arctic
    ## 78            From deepocean_Arctic to marinesediment_Arctic
    ## 79            From deepocean_Arctic to marinesediment_Arctic
    ## 80            From deepocean_Arctic to marinesediment_Arctic
    ## 81            From deepocean_Arctic to marinesediment_Arctic
    ## 82                       From sea_Arctic to deepocean_Arctic
    ## 83                       From sea_Arctic to deepocean_Arctic
    ## 84                       From sea_Arctic to deepocean_Arctic
    ## 85                       From sea_Arctic to deepocean_Arctic
    ## 86                       From sea_Arctic to deepocean_Arctic
    ## 87                       From sea_Arctic to deepocean_Arctic
    ## 88                       From sea_Arctic to deepocean_Arctic
    ## 89                       From sea_Arctic to deepocean_Arctic
    ## 90                       From sea_Arctic to deepocean_Arctic
    ## 91         From lake_Continental to lakesediment_Continental
    ## 92         From lake_Continental to lakesediment_Continental
    ## 93         From lake_Continental to lakesediment_Continental
    ## 94         From lake_Continental to lakesediment_Continental
    ## 95         From lake_Continental to lakesediment_Continental
    ## 96         From lake_Continental to lakesediment_Continental
    ## 97         From lake_Continental to lakesediment_Continental
    ## 98         From lake_Continental to lakesediment_Continental
    ## 99         From lake_Continental to lakesediment_Continental
    ## 100 From river_Continental to freshwatersediment_Continental
    ## 101 From river_Continental to freshwatersediment_Continental
    ## 102 From river_Continental to freshwatersediment_Continental
    ## 103 From river_Continental to freshwatersediment_Continental
    ## 104 From river_Continental to freshwatersediment_Continental
    ## 105 From river_Continental to freshwatersediment_Continental
    ## 106 From river_Continental to freshwatersediment_Continental
    ## 107 From river_Continental to freshwatersediment_Continental
    ## 108 From river_Continental to freshwatersediment_Continental
    ## 109       From sea_Continental to marinesediment_Continental
    ## 110       From sea_Continental to marinesediment_Continental
    ## 111       From sea_Continental to marinesediment_Continental
    ## 112       From sea_Continental to marinesediment_Continental
    ## 113       From sea_Continental to marinesediment_Continental
    ## 114       From sea_Continental to marinesediment_Continental
    ## 115       From sea_Continental to marinesediment_Continental
    ## 116       From sea_Continental to marinesediment_Continental
    ## 117       From sea_Continental to marinesediment_Continental
    ## 118       From deepocean_Moderate to marinesediment_Moderate
    ## 119       From deepocean_Moderate to marinesediment_Moderate
    ## 120       From deepocean_Moderate to marinesediment_Moderate
    ## 121       From deepocean_Moderate to marinesediment_Moderate
    ## 122       From deepocean_Moderate to marinesediment_Moderate
    ## 123       From deepocean_Moderate to marinesediment_Moderate
    ## 124       From deepocean_Moderate to marinesediment_Moderate
    ## 125       From deepocean_Moderate to marinesediment_Moderate
    ## 126       From deepocean_Moderate to marinesediment_Moderate
    ## 127                  From sea_Moderate to deepocean_Moderate
    ## 128                  From sea_Moderate to deepocean_Moderate
    ## 129                  From sea_Moderate to deepocean_Moderate
    ## 130                  From sea_Moderate to deepocean_Moderate
    ## 131                  From sea_Moderate to deepocean_Moderate
    ## 132                  From sea_Moderate to deepocean_Moderate
    ## 133                  From sea_Moderate to deepocean_Moderate
    ## 134                  From sea_Moderate to deepocean_Moderate
    ## 135                  From sea_Moderate to deepocean_Moderate
    ## 136              From lake_Regional to lakesediment_Regional
    ## 137              From lake_Regional to lakesediment_Regional
    ## 138              From lake_Regional to lakesediment_Regional
    ## 139              From lake_Regional to lakesediment_Regional
    ## 140              From lake_Regional to lakesediment_Regional
    ## 141              From lake_Regional to lakesediment_Regional
    ## 142              From lake_Regional to lakesediment_Regional
    ## 143              From lake_Regional to lakesediment_Regional
    ## 144              From lake_Regional to lakesediment_Regional
    ## 145       From river_Regional to freshwatersediment_Regional
    ## 146       From river_Regional to freshwatersediment_Regional
    ## 147       From river_Regional to freshwatersediment_Regional
    ## 148       From river_Regional to freshwatersediment_Regional
    ## 149       From river_Regional to freshwatersediment_Regional
    ## 150       From river_Regional to freshwatersediment_Regional
    ## 151       From river_Regional to freshwatersediment_Regional
    ## 152       From river_Regional to freshwatersediment_Regional
    ## 153       From river_Regional to freshwatersediment_Regional
    ## 154             From sea_Regional to marinesediment_Regional
    ## 155             From sea_Regional to marinesediment_Regional
    ## 156             From sea_Regional to marinesediment_Regional
    ## 157             From sea_Regional to marinesediment_Regional
    ## 158             From sea_Regional to marinesediment_Regional
    ## 159             From sea_Regional to marinesediment_Regional
    ## 160             From sea_Regional to marinesediment_Regional
    ## 161             From sea_Regional to marinesediment_Regional
    ## 162             From sea_Regional to marinesediment_Regional
    ## 163           From deepocean_Tropic to marinesediment_Tropic
    ## 164           From deepocean_Tropic to marinesediment_Tropic
    ## 165           From deepocean_Tropic to marinesediment_Tropic
    ## 166           From deepocean_Tropic to marinesediment_Tropic
    ## 167           From deepocean_Tropic to marinesediment_Tropic
    ## 168           From deepocean_Tropic to marinesediment_Tropic
    ## 169           From deepocean_Tropic to marinesediment_Tropic
    ## 170           From deepocean_Tropic to marinesediment_Tropic
    ## 171           From deepocean_Tropic to marinesediment_Tropic
    ## 172                      From sea_Tropic to deepocean_Tropic
    ## 173                      From sea_Tropic to deepocean_Tropic
    ## 174                      From sea_Tropic to deepocean_Tropic
    ## 175                      From sea_Tropic to deepocean_Tropic
    ## 176                      From sea_Tropic to deepocean_Tropic
    ## 177                      From sea_Tropic to deepocean_Tropic
    ## 178                      From sea_Tropic to deepocean_Tropic
    ## 179                      From sea_Tropic to deepocean_Tropic
    ## 180                      From sea_Tropic to deepocean_Tropic

As can be seen in the figures below, the new rate constants for the
substances, 1-aminoanthraquinone, microplastic, nAg_10nm, TRWP, have a
negligible difference of max 99.9999999 % difference to the previous
version. The figures below also show this and therefor this verification
of replicating the previous version with the new code is complete.

``` r
all_diffs_shape <- kaas_comparison_shape |>
  mutate(fromname = paste0(fromSubCompart, "_", fromScale)) |>
  mutate(toname = paste0(toSubCompart, "_", toScale))

for(i in unique(all_diffs_shape$Substance)){
  diffs_substance_shape <- all_diffs_shape |>
    filter(Substance == i)
  
  absdif_plot_shape <- ggplot(diffs_substance_shape, mapping = aes(x = toname, y = fromname, color = diff)) + 
    geom_point() + 
    labs(
      title = "Difference between sphere and fiber k's",
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
  
  print(absdif_plot_shape)
  
  reldif_plot_shape <- ggplot(diffs_substance_shape, mapping = aes(x = toname, y = fromname, color = rel_diff)) + 
    geom_point() + 
    labs(
      title = "Relative difference between sphere and fiber k's",
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
  print(reldif_plot_shape)
}
```

![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-1.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-2.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-3.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-4.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-5.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-6.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-7.png)<!-- -->![](20250826_Plastics_Shape_update_files/figure-gfm/Plot%20the%20differences%20between%20ks%20(shape)-8.png)<!-- -->
