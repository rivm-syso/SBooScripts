Rho, Radia and settling velocity
================

## Rho, Radii and settling velocity

For several processes of particles and between particles the density
(rho) and radius of the particle are important, as are the density of
the matrix (medium) in which the particles are. The table in which the
data to be used depend on the key of the property. The key for the
density of the matrix is subcompartment. But it is “inherited” from the
datafile “matrix.csv”. This inheritance is performed in the
initialisation; if you look for rhoMatrix as a parameter for defining
function use World\$fetchdata()

``` r
#we initialize the test environment with a nano substance, and the nano excel version
substance <- "nAg_10nm"
excelReference <- "data/20210331 SimpleBox4nano_rev006.xlsx"
#script to initialize test environment, including faking a future 'library(sboo)'
source("baseScripts/initTestWorld.R")
World$fetchData("rhoMatrix")
```

    ##            SubCompart rhoMatrix
    ## 1                 air     1.225
    ## 2          cloudwater   998.000
    ## 3  freshwatersediment  2500.000
    ## 4        lakesediment  2500.000
    ## 5      marinesediment  2500.000
    ## 6    agriculturalsoil  2500.000
    ## 7         naturalsoil  2500.000
    ## 8           othersoil  2500.000
    ## 9           deepocean   998.000
    ## 10               lake   998.000
    ## 11              river   998.000
    ## 12                sea   998.000

## The density and radius of the nanomaterial

depend on the species. The density and radius of the nano material
itself is given by the substance properties RhoS and RadS. For the
aggregated and the properties of the “natural part” of the species;
CoarseParticulate for the Attached species and NaturalColloid for the
aggregated species. Those properties are RhoCP and RhoNC for density and
RadCP and RadNC for their radius. An overview of excel origines:

``` r
read_csv("data/SpeciesCompartments.csv")
```

    ## Rows: 13 Columns: 6
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (5): VarName, Compartment, Species, SB4N_name, Unit
    ## dbl (1): Waarde
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

    ## # A tibble: 13 × 6
    ##    VarName    Compartment Species        Waarde SB4N_name Unit 
    ##    <chr>      <chr>       <chr>           <dbl> <chr>     <chr>
    ##  1 NaturalRad air         Large      0.0000009  RadCP.a   m    
    ##  2 NaturalRad sediment    Large      0.000128   RadFP.sd  m    
    ##  3 NaturalRad sediment    Small      0.00000015 RadNC.sd  m    
    ##  4 NaturalRad soil        Large      0.000128   RadFP.s   m    
    ##  5 NaturalRad soil        Small      0.00000015 RadNC.s   m    
    ##  6 NaturalRad water       Large      0.000003   RadSPM.w  m    
    ##  7 NaturalRad water       Small      0.00000015 RadNC.w   m    
    ##  8 NaturalRho air         Large   2000          RhoCP.a   kg/m3
    ##  9 NaturalRho sediment    Small   2000          RhoNC.sd  kg/m3
    ## 10 NaturalRho soil        Large   2500          RhoFP.s   kg/m3
    ## 11 NaturalRho soil        Small   2000          RhoNC.s   kg/m3
    ## 12 NaturalRho water       Large   2500          RhoSPM.w  kg/m3
    ## 13 NaturalRho water       Small   2000          RhoNC.w   kg/m3

From these, we can derive the values for rho_species

``` r
rp <- World$NewCalcVariable("rho_species")
rho_species
```

    ## function (SpeciesName, SubCompartName, RhoS, RadS, NaturalRad, 
    ##     NaturalRho, RhoNuc, RadNuc, RhoAcc, RadAcc, NumConcNuc, NumConcAcc, 
    ##     Df) 
    ## {
    ##     if (SpeciesName == "Nanoparticle") {
    ##         return(RhoS)
    ##     }
    ##     if (SpeciesName == "Molecular") {
    ##         return(NA)
    ##     }
    ##     if (SpeciesName == "Aggregated" & SubCompartName == "air") {
    ##         SingleMass <- ((NumConcNuc * (RhoNuc * fVol(RadNuc) + 
    ##             RhoS * fVol(RadS))) + (NumConcAcc * (RhoAcc * (fVol(RadAcc)) + 
    ##             RhoS * fVol(RadS))))/(NumConcNuc + NumConcAcc)
    ##         SingleVol <- ((NumConcNuc * (fVol(RadS) + ((fVol(RadNuc))))) + 
    ##             (NumConcAcc * (fVol(RadS) + (fVol(RadAcc)))))/(NumConcNuc + 
    ##             NumConcAcc)
    ##     }
    ##     else {
    ##         SingleMass <- RhoS * fVol(RadS) + NaturalRho * fVol(NaturalRad)
    ##         SingleVol <- fVol((NaturalRad^3 + RadS^3)^(Df))
    ##     }
    ##     SingleMass/SingleVol
    ## }

``` r
World$CalcVar("rho_species")
```

    ##           Scale         SubCompart Species rho_species
    ## 2        Arctic         cloudwater   Solid   10500.000
    ## 4        Arctic                sea   Small    2000.315
    ## 5        Arctic                air   Small    2007.444
    ## 6        Arctic          othersoil   Large    2500.000
    ## 7        Arctic     marinesediment   Small    2000.315
    ## 9        Arctic          othersoil   Solid   10500.000
    ## 10       Arctic     marinesediment   Solid   10500.000
    ## 11       Arctic                sea   Solid   10500.000
    ## 12       Arctic                air   Solid   10500.000
    ## 14       Arctic          othersoil   Small    2000.315
    ## 15       Arctic          deepocean   Large    2500.000
    ## 16       Arctic                sea   Large    2500.000
    ## 18       Arctic                air   Large    2000.001
    ## 19       Arctic          deepocean   Small    2000.315
    ## 21       Arctic         cloudwater   Large    2000.001
    ## 23       Arctic          deepocean   Solid   10500.000
    ## 24  Continental   agriculturalsoil   Large    2500.000
    ## 25  Continental         cloudwater   Solid   10500.000
    ## 26  Continental   agriculturalsoil   Small    2000.315
    ## 28  Continental                air   Small    2007.444
    ## 29  Continental   agriculturalsoil   Solid   10500.000
    ## 31  Continental              river   Large    2500.000
    ## 32  Continental        naturalsoil   Small    2000.315
    ## 33  Continental              river   Small    2000.315
    ## 34  Continental                air   Large    2000.001
    ## 35  Continental              river   Solid   10500.000
    ## 36  Continental     marinesediment   Solid   10500.000
    ## 37  Continental               lake   Small    2000.315
    ## 39  Continental         cloudwater   Large    2000.001
    ## 42  Continental freshwatersediment   Small    2000.315
    ## 43  Continental                air   Solid   10500.000
    ## 44  Continental freshwatersediment   Solid   10500.000
    ## 45  Continental          othersoil   Small    2000.315
    ## 47  Continental               lake   Large    2500.000
    ## 52  Continental               lake   Solid   10500.000
    ## 54  Continental          othersoil   Solid   10500.000
    ## 55  Continental                sea   Large    2500.000
    ## 57  Continental       lakesediment   Small    2000.315
    ## 58  Continental        naturalsoil   Large    2500.000
    ## 60  Continental       lakesediment   Solid   10500.000
    ## 61  Continental        naturalsoil   Solid   10500.000
    ## 63  Continental          othersoil   Large    2500.000
    ## 64  Continental                sea   Solid   10500.000
    ## 65  Continental     marinesediment   Small    2000.315
    ## 66  Continental                sea   Small    2000.315
    ## 67     Moderate          othersoil   Solid   10500.000
    ## 69     Moderate         cloudwater   Solid   10500.000
    ## 70     Moderate         cloudwater   Large    2000.001
    ## 71     Moderate     marinesediment   Solid   10500.000
    ## 72     Moderate          deepocean   Large    2500.000
    ## 73     Moderate                air   Large    2000.001
    ## 74     Moderate                air   Solid   10500.000
    ## 76     Moderate                sea   Large    2500.000
    ## 78     Moderate                air   Small    2007.444
    ## 79     Moderate          othersoil   Small    2000.315
    ## 80     Moderate     marinesediment   Small    2000.315
    ## 81     Moderate                sea   Solid   10500.000
    ## 84     Moderate                sea   Small    2000.315
    ## 85     Moderate          deepocean   Solid   10500.000
    ## 86     Moderate          deepocean   Small    2000.315
    ## 88     Moderate          othersoil   Large    2500.000
    ## 91     Regional         cloudwater   Solid   10500.000
    ## 92     Regional                air   Small    2007.444
    ## 93     Regional                air   Large    2000.001
    ## 95     Regional         cloudwater   Large    2000.001
    ## 96     Regional        naturalsoil   Small    2000.315
    ## 99     Regional              river   Solid   10500.000
    ## 102    Regional               lake   Solid   10500.000
    ## 103    Regional   agriculturalsoil   Solid   10500.000
    ## 105    Regional   agriculturalsoil   Large    2500.000
    ## 107    Regional                air   Solid   10500.000
    ## 108    Regional              river   Large    2500.000
    ## 109    Regional       lakesediment   Solid   10500.000
    ## 110    Regional     marinesediment   Solid   10500.000
    ## 111    Regional               lake   Large    2500.000
    ## 112    Regional               lake   Small    2000.315
    ## 113    Regional                sea   Small    2000.315
    ## 115    Regional          othersoil   Large    2500.000
    ## 117    Regional   agriculturalsoil   Small    2000.315
    ## 120    Regional freshwatersediment   Solid   10500.000
    ## 121    Regional       lakesediment   Small    2000.315
    ## 123    Regional          othersoil   Small    2000.315
    ## 124    Regional              river   Small    2000.315
    ## 125    Regional        naturalsoil   Solid   10500.000
    ## 126    Regional     marinesediment   Small    2000.315
    ## 127    Regional          othersoil   Solid   10500.000
    ## 128    Regional                sea   Large    2500.000
    ## 129    Regional                sea   Solid   10500.000
    ## 131    Regional freshwatersediment   Small    2000.315
    ## 132    Regional        naturalsoil   Large    2500.000
    ## 133      Tropic          othersoil   Small    2000.315
    ## 134      Tropic          deepocean   Large    2500.000
    ## 137      Tropic          deepocean   Solid   10500.000
    ## 139      Tropic                sea   Large    2500.000
    ## 140      Tropic          deepocean   Small    2000.315
    ## 141      Tropic                air   Small    2007.444
    ## 142      Tropic     marinesediment   Small    2000.315
    ## 143      Tropic     marinesediment   Solid   10500.000
    ## 145      Tropic         cloudwater   Solid   10500.000
    ## 146      Tropic                air   Solid   10500.000
    ## 148      Tropic          othersoil   Solid   10500.000
    ## 149      Tropic                sea   Solid   10500.000
    ## 150      Tropic                air   Large    2000.001
    ## 151      Tropic         cloudwater   Large    2000.001
    ## 152      Tropic          othersoil   Large    2500.000
    ## 154      Tropic                sea   Small    2000.315

And the radii

``` r
rad_species
```

    ## function (SpeciesName, SubCompartName, NaturalRad, RadNuc, RadAcc, 
    ##     RadS, NumConcNuc, NumConcAcc, Df) 
    ## {
    ##     if (anyNA(c(RadNuc, RadAcc, NumConcNuc, NumConcAcc))) 
    ##         return(NA)
    ##     if (SpeciesName == "Aggregated" & SubCompartName == "air") {
    ##         SingleVol <- ((NumConcNuc * (fVol(RadS) + fVol(RadNuc))) + 
    ##             (NumConcAcc * (fVol(RadS) + fVol(RadAcc))))/(NumConcNuc + 
    ##             NumConcAcc)
    ##         rad_particle <- (SingleVol/((4/3) * pi))^(Df)
    ##         return(rad_particle)
    ##     }
    ##     else {
    ##         if (SpeciesName == "Nanoparticle") {
    ##             return(RadS)
    ##         }
    ##         else {
    ##             return((NaturalRad^3 + RadS^3)^(Df))
    ##         }
    ##     }
    ## }

``` r
rs <- World$NewCalcVariable("rad_species")
World$CalcVar("rad_species")
```

    ##           Scale         SubCompart Species  rad_species
    ## 2        Arctic          othersoil   Solid 5.000000e-09
    ## 4        Arctic     marinesediment   Small 1.500019e-07
    ## 5        Arctic          deepocean   Large 3.000000e-06
    ## 7        Arctic          othersoil   Small 1.500019e-07
    ## 8        Arctic                sea   Large 3.000000e-06
    ## 9        Arctic                sea   Small 1.500019e-07
    ## 11       Arctic          othersoil   Large 1.280000e-04
    ## 12       Arctic          deepocean   Small 1.500019e-07
    ## 13       Arctic         cloudwater   Large 9.000001e-07
    ## 14       Arctic     marinesediment   Solid 5.000000e-09
    ## 15       Arctic         cloudwater   Solid 5.000000e-09
    ## 16       Arctic                air   Small 4.537267e-08
    ## 18       Arctic                air   Large 9.000001e-07
    ## 19       Arctic     marinesediment   Large 1.280000e-04
    ## 20       Arctic          deepocean   Solid 5.000000e-09
    ## 21       Arctic                air   Solid 5.000000e-09
    ## 23       Arctic                sea   Solid 5.000000e-09
    ## 25  Continental          othersoil   Solid 5.000000e-09
    ## 27  Continental   agriculturalsoil   Solid 5.000000e-09
    ## 28  Continental   agriculturalsoil   Small 1.500019e-07
    ## 30  Continental     marinesediment   Small 1.500019e-07
    ## 31  Continental                air   Small 4.537267e-08
    ## 32  Continental              river   Large 3.000000e-06
    ## 33  Continental     marinesediment   Large 1.280000e-04
    ## 34  Continental               lake   Small 1.500019e-07
    ## 35  Continental   agriculturalsoil   Large 1.280000e-04
    ## 36  Continental     marinesediment   Solid 5.000000e-09
    ## 37  Continental freshwatersediment   Large 1.280000e-04
    ## 39  Continental                air   Solid 5.000000e-09
    ## 40  Continental         cloudwater   Large 9.000001e-07
    ## 41  Continental        naturalsoil   Large 1.280000e-04
    ## 43  Continental                air   Large 9.000001e-07
    ## 44  Continental       lakesediment   Large 1.280000e-04
    ## 45  Continental               lake   Large 3.000000e-06
    ## 46  Continental              river   Solid 5.000000e-09
    ## 49  Continental               lake   Solid 5.000000e-09
    ## 51  Continental freshwatersediment   Small 1.500019e-07
    ## 52  Continental        naturalsoil   Small 1.500019e-07
    ## 53  Continental                sea   Large 3.000000e-06
    ## 55  Continental       lakesediment   Small 1.500019e-07
    ## 56  Continental                sea   Solid 5.000000e-09
    ## 57  Continental       lakesediment   Solid 5.000000e-09
    ## 58  Continental              river   Small 1.500019e-07
    ## 59  Continental         cloudwater   Solid 5.000000e-09
    ## 60  Continental        naturalsoil   Solid 5.000000e-09
    ## 62  Continental          othersoil   Large 1.280000e-04
    ## 64  Continental          othersoil   Small 1.500019e-07
    ## 65  Continental freshwatersediment   Solid 5.000000e-09
    ## 66  Continental                sea   Small 1.500019e-07
    ## 67     Moderate         cloudwater   Large 9.000001e-07
    ## 68     Moderate                air   Solid 5.000000e-09
    ## 70     Moderate     marinesediment   Large 1.280000e-04
    ## 72     Moderate          deepocean   Small 1.500019e-07
    ## 73     Moderate     marinesediment   Small 1.500019e-07
    ## 75     Moderate                air   Small 4.537267e-08
    ## 76     Moderate         cloudwater   Solid 5.000000e-09
    ## 77     Moderate          othersoil   Solid 5.000000e-09
    ## 80     Moderate     marinesediment   Solid 5.000000e-09
    ## 81     Moderate          deepocean   Large 3.000000e-06
    ## 82     Moderate          othersoil   Large 1.280000e-04
    ## 83     Moderate                air   Large 9.000001e-07
    ## 84     Moderate          othersoil   Small 1.500019e-07
    ## 85     Moderate                sea   Small 1.500019e-07
    ## 86     Moderate                sea   Large 3.000000e-06
    ## 87     Moderate                sea   Solid 5.000000e-09
    ## 89     Moderate          deepocean   Solid 5.000000e-09
    ## 90     Regional   agriculturalsoil   Large 1.280000e-04
    ## 91     Regional         cloudwater   Solid 5.000000e-09
    ## 92     Regional   agriculturalsoil   Small 1.500019e-07
    ## 93     Regional     marinesediment   Large 1.280000e-04
    ## 94     Regional   agriculturalsoil   Solid 5.000000e-09
    ## 95     Regional freshwatersediment   Small 1.500019e-07
    ## 96     Regional                air   Solid 5.000000e-09
    ## 98     Regional     marinesediment   Small 1.500019e-07
    ## 99     Regional              river   Small 1.500019e-07
    ## 100    Regional                air   Large 9.000001e-07
    ## 101    Regional              river   Solid 5.000000e-09
    ## 102    Regional               lake   Small 1.500019e-07
    ## 105    Regional                air   Small 4.537267e-08
    ## 106    Regional                sea   Large 3.000000e-06
    ## 107    Regional         cloudwater   Large 9.000001e-07
    ## 108    Regional       lakesediment   Large 1.280000e-04
    ## 109    Regional          othersoil   Small 1.500019e-07
    ## 110    Regional freshwatersediment   Solid 5.000000e-09
    ## 112    Regional              river   Large 3.000000e-06
    ## 113    Regional               lake   Large 3.000000e-06
    ## 116    Regional                sea   Solid 5.000000e-09
    ## 117    Regional               lake   Solid 5.000000e-09
    ## 118    Regional          othersoil   Large 1.280000e-04
    ## 122    Regional       lakesediment   Solid 5.000000e-09
    ## 123    Regional       lakesediment   Small 1.500019e-07
    ## 124    Regional          othersoil   Solid 5.000000e-09
    ## 125    Regional        naturalsoil   Small 1.500019e-07
    ## 127    Regional freshwatersediment   Large 1.280000e-04
    ## 128    Regional        naturalsoil   Solid 5.000000e-09
    ## 130    Regional        naturalsoil   Large 1.280000e-04
    ## 131    Regional                sea   Small 1.500019e-07
    ## 132    Regional     marinesediment   Solid 5.000000e-09
    ## 133      Tropic                air   Small 4.537267e-08
    ## 134      Tropic         cloudwater   Large 9.000001e-07
    ## 135      Tropic          deepocean   Small 1.500019e-07
    ## 136      Tropic     marinesediment   Small 1.500019e-07
    ## 137      Tropic          othersoil   Small 1.500019e-07
    ## 138      Tropic     marinesediment   Solid 5.000000e-09
    ## 140      Tropic                sea   Large 3.000000e-06
    ## 141      Tropic         cloudwater   Solid 5.000000e-09
    ## 143      Tropic                sea   Small 1.500019e-07
    ## 145      Tropic          othersoil   Solid 5.000000e-09
    ## 146      Tropic                air   Large 9.000001e-07
    ## 147      Tropic                sea   Solid 5.000000e-09
    ## 148      Tropic     marinesediment   Large 1.280000e-04
    ## 149      Tropic                air   Solid 5.000000e-09
    ## 151      Tropic          deepocean   Large 3.000000e-06
    ## 152      Tropic          othersoil   Large 1.280000e-04
    ## 155      Tropic          deepocean   Solid 5.000000e-09

## settling velocity

The settling velocity is best calculated according Stokes \[ref?\], like
the regular R function. This is not a SB defining function, because it
is used not only for species, but also their natural parts, and
aerosols. But we use this function to as part of the defining function
for natural particles, as used for sedimentation rate of molecular
species

``` r
f_SettlingVelocity
```

    ## function (rad_species, rho_species, matrix.Rho, DynVisc, Matrix) 
    ## {
    ##     stopifnot(is.numeric(rho_species), is.numeric(matrix.Rho), 
    ##         is.numeric(DynVisc))
    ##     switch(Matrix, water = {
    ##         2 * (rad_species^2 * (rho_species - matrix.Rho) * getConst("gn"))/(9 * 
    ##             DynVisc)
    ##     }, air = {
    ##         Cunningham <- fCunningham(rad_species)
    ##         2 * (rad_species^2 * (rho_species - matrix.Rho) * getConst("gn") * 
    ##             Cunningham)/(9 * DynVisc)
    ##     }, NA)
    ## }

``` r
source("newAlgorithmScripts/v_SettVellNat.R")
World$NewCalcVariable("SettVellNat")
World$CalcVar("SettVellNat")
```

    ##    SubCompart  SettVellNat
    ## 2         air 2.707692e-03
    ## 3  cloudwater 1.627579e-03
    ## 4   deepocean 2.940038e-05
    ## 6        lake 2.940038e-05
    ## 11      river 2.940038e-05
    ## 12        sea 2.940038e-05

## Sedimentation

The settlingvelocity is essential for the calculation of
k_sedimentation.

``` r
source("newAlgorithmScripts/k_Sedimentation.R")
World$NewProcess("k_Sedimentation")
World$whichUnresolved()
```

    ## character(0)

``` r
World$UpdateKaas("k_Sedimentation") 
```
