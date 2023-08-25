Erosion
================
JS
3/31/2022

## Runoff and erosion

These processes are combined in the excel versions, like k = (RAINrate
\* FRACrun/Ks1w + EROSION) \* CORRrunoff / DEPTH

In the R version, if multiple processes are defined for the same
transfer, the k’s are automatically added. This makes it easier to
define and possibly re-define each process. In this case the factor
CORRrunoff / DEPTH will be executed twice. We believe the loss in
calculation speed is neclegtable. The factor CORRrunoff (Correction
factor depth dependent soil concentration) however is calculated as
EXP((-1/0.1) \* 0) \* (1/0.1) \* DEPTH / (1-EXP((-1/0.1) \* DEPTH)) for
the assumed pentration depth of 0.1 m \[REF\] To make sure this remains
the same for both Runoff and erosion, we define a variable to calculate
it. The only parameter, so far, is DEPTH, which has been renamed to
vertDistance in the R version (combined with height) We will define the
two processes separate, and demo the erosion process, with a variable
and a process defining function.

``` r
#Regular init for testing
source("baseScripts/initTestWorld.R")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.0     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.1     ✔ tibble    3.1.8
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the ]8;;http://conflicted.r-lib.org/conflicted package]8;; to force all conflicts to become errors
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
    ## Joining with `by = join_by(sheet, row)`

``` r
print("") #newline for anoying tidyverse Joining message
```

    ## [1] ""

``` r
source("newAlgorithmScripts/v_CORRrunoff.R")
CORRrunoff
```

    ## function (VertDistance, Compartment) 
    ## {
    ##     if (Compartment == "soil") {
    ##         pentration_depth = 0.1
    ##         return(exp((-1/pentration_depth) * 0) * (1/pentration_depth) * 
    ##             VertDistance/(1 - exp((-1/pentration_depth) * VertDistance)))
    ##     }
    ##     else {
    ##         return(NA)
    ##     }
    ## }

``` r
source("newAlgorithmScripts/k_Erosion.R")
k_Erosion
```

    ## function (CORRrunoff, EROSIONsoil, VertDistance) 
    ## {
    ##     EROSIONsoil * CORRrunoff/VertDistance
    ## }

Notice the convention of filenames and the function names. The
convention of filenames is given in the AAAreadme.R file in the sboo
project. (I think it will be on the top of your list when your sort the
filenames alphabetically) All filenames and function names are
identical, with two exceptions: 1. fGeneral.R contains some very general
functions. 2. defining functions of SBOO variables do not contain the
preposition v\_ which makes them easier to read and still distinguish
from flows or regular functions.

### We add both objects and calculate the variable

``` r
World$NewCalcVariable("CORRrunoff")
World$CalcVar("CORRrunoff")
```

    ##          SubCompart       Scale CORRrunoff
    ## 3  agriculturalsoil    Regional   2.313035
    ## 5  agriculturalsoil Continental   2.313035
    ## 42      naturalsoil Continental   1.270747
    ## 44      naturalsoil    Regional   1.270747
    ## 46        othersoil Continental   1.270747
    ## 47        othersoil      Arctic   1.270747
    ## 48        othersoil    Moderate   1.270747
    ## 49        othersoil    Regional   1.270747
    ## 50        othersoil      Tropic   1.270747

``` r
World$NewProcess("k_Erosion")
World$UpdateKaas("k_Erosion")
World$kaas
```

    ##         i   j            k   process   fromScale     fromSubCompart fromSpecies
    ## 27     27  52 1.099848e-11 k_Erosion Continental   agriculturalsoil       Large
    ## 29     29  54 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Large
    ## 32     32  52 2.416961e-11 k_Erosion Continental        naturalsoil       Large
    ## 34     34  54 2.416961e-11 k_Erosion    Regional        naturalsoil       Large
    ## 36     36  51 2.416961e-11 k_Erosion      Arctic          othersoil       Large
    ## 36.1   36  56 2.416961e-11 k_Erosion      Arctic          othersoil       Large
    ## 37     37  52 2.416961e-11 k_Erosion Continental          othersoil       Large
    ## 37.1   37  57 2.416961e-11 k_Erosion Continental          othersoil       Large
    ## 38     38  53 2.416961e-11 k_Erosion    Moderate          othersoil       Large
    ## 38.1   38  58 2.416961e-11 k_Erosion    Moderate          othersoil       Large
    ## 39     39  54 2.416961e-11 k_Erosion    Regional          othersoil       Large
    ## 39.1   39  59 2.416961e-11 k_Erosion    Regional          othersoil       Large
    ## 40     40  55 2.416961e-11 k_Erosion      Tropic          othersoil       Large
    ## 40.1   40  60 2.416961e-11 k_Erosion      Tropic          othersoil       Large
    ## 87     87 112 1.099848e-11 k_Erosion Continental   agriculturalsoil       Small
    ## 89     89 114 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Small
    ## 92     92 112 2.416961e-11 k_Erosion Continental        naturalsoil       Small
    ## 94     94 114 2.416961e-11 k_Erosion    Regional        naturalsoil       Small
    ## 96     96 111 2.416961e-11 k_Erosion      Arctic          othersoil       Small
    ## 96.1   96 116 2.416961e-11 k_Erosion      Arctic          othersoil       Small
    ## 97     97 112 2.416961e-11 k_Erosion Continental          othersoil       Small
    ## 97.1   97 117 2.416961e-11 k_Erosion Continental          othersoil       Small
    ## 98     98 113 2.416961e-11 k_Erosion    Moderate          othersoil       Small
    ## 98.1   98 118 2.416961e-11 k_Erosion    Moderate          othersoil       Small
    ## 99     99 114 2.416961e-11 k_Erosion    Regional          othersoil       Small
    ## 99.1   99 119 2.416961e-11 k_Erosion    Regional          othersoil       Small
    ## 100   100 115 2.416961e-11 k_Erosion      Tropic          othersoil       Small
    ## 100.1 100 120 2.416961e-11 k_Erosion      Tropic          othersoil       Small
    ## 147   147 172 1.099848e-11 k_Erosion Continental   agriculturalsoil       Solid
    ## 149   149 174 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Solid
    ## 152   152 172 2.416961e-11 k_Erosion Continental        naturalsoil       Solid
    ## 154   154 174 2.416961e-11 k_Erosion    Regional        naturalsoil       Solid
    ## 156   156 171 2.416961e-11 k_Erosion      Arctic          othersoil       Solid
    ## 156.1 156 176 2.416961e-11 k_Erosion      Arctic          othersoil       Solid
    ## 157   157 172 2.416961e-11 k_Erosion Continental          othersoil       Solid
    ## 157.1 157 177 2.416961e-11 k_Erosion Continental          othersoil       Solid
    ## 158   158 173 2.416961e-11 k_Erosion    Moderate          othersoil       Solid
    ## 158.1 158 178 2.416961e-11 k_Erosion    Moderate          othersoil       Solid
    ## 159   159 174 2.416961e-11 k_Erosion    Regional          othersoil       Solid
    ## 159.1 159 179 2.416961e-11 k_Erosion    Regional          othersoil       Solid
    ## 160   160 175 2.416961e-11 k_Erosion      Tropic          othersoil       Solid
    ## 160.1 160 180 2.416961e-11 k_Erosion      Tropic          othersoil       Solid
    ## 181   181 181 1.809525e-07  LoadKaas      Arctic                air     Unbound
    ## 181.1 181 183 6.923419e-07  LoadKaas      Arctic                air     Unbound
    ## 181.2 181 211 4.514746e-10  LoadKaas      Arctic                air     Unbound
    ## 181.3 181 231 1.126562e-07  LoadKaas      Arctic                air     Unbound
    ## 182   182 182 2.163047e-07  LoadKaas Continental                air     Unbound
    ## 182.1 182 183 1.381786e-06  LoadKaas Continental                air     Unbound
    ## 182.2 182 184 3.003899e-07  LoadKaas Continental                air     Unbound
    ## 182.3 182 202 3.988915e-10  LoadKaas Continental                air     Unbound
    ## 182.4 182 207 1.795012e-10  LoadKaas Continental                air     Unbound
    ## 182.5 182 212 6.648191e-11  LoadKaas Continental                air     Unbound
    ## 182.6 182 222 6.933810e-11  LoadKaas Continental                air     Unbound
    ## 182.7 182 227 7.627191e-10  LoadKaas Continental                air     Unbound
    ## 182.8 182 232 2.954591e-08  LoadKaas Continental                air     Unbound
    ## 183   183 181 3.793229e-07  LoadKaas    Moderate                air     Unbound
    ## 183.1 183 182 1.282412e-07  LoadKaas    Moderate                air     Unbound
    ## 183.2 183 183 2.163047e-07  LoadKaas    Moderate                air     Unbound
    ## 183.3 183 185 6.570066e-07  LoadKaas    Moderate                air     Unbound
    ## 183.4 183 213 6.865203e-10  LoadKaas    Moderate                air     Unbound
    ## 183.5 183 233 2.864058e-08  LoadKaas    Moderate                air     Unbound
    ## 184   184 182 9.420143e-06  LoadKaas    Regional                air     Unbound
    ## 184.1 184 184 2.163047e-07  LoadKaas    Regional                air     Unbound
    ## 184.2 184 204 8.202341e-10  LoadKaas    Regional                air     Unbound
    ## 184.3 184 209 3.691053e-10  LoadKaas    Regional                air     Unbound
    ## 184.4 184 214 1.367057e-10  LoadKaas    Regional                air     Unbound
    ## 184.5 184 224 1.425791e-10  LoadKaas    Regional                air     Unbound
    ## 184.6 184 229 1.568370e-09  LoadKaas    Regional                air     Unbound
    ## 184.7 184 234 2.495150e-10  LoadKaas    Regional                air     Unbound
    ## 185   185 183 3.997238e-07  LoadKaas      Tropic                air     Unbound
    ## 185.1 185 185 2.403663e-07  LoadKaas      Tropic                air     Unbound
    ## 185.2 185 215 5.146421e-10  LoadKaas      Tropic                air     Unbound
    ## 185.3 185 235 2.148645e-08  LoadKaas      Tropic                air     Unbound
    ## 192   187 187 1.254003e-08  LoadKaas Continental freshwatersediment     Unbound
    ## 192.1 187 227 7.181458e-08  LoadKaas Continental freshwatersediment     Unbound
    ## 194   189 189 1.256117e-08  LoadKaas    Regional freshwatersediment     Unbound
    ## 194.1 189 229 7.179344e-08  LoadKaas    Regional freshwatersediment     Unbound
    ## 201   196 196 2.105757e-09  LoadKaas      Arctic     marinesediment     Unbound
    ## 201.1 196 216 5.539657e-08  LoadKaas      Arctic     marinesediment     Unbound
    ## 202   197 197 9.665804e-09  LoadKaas Continental     marinesediment     Unbound
    ## 202.1 197 232 5.539869e-08  LoadKaas Continental     marinesediment     Unbound
    ## 203   198 198 9.668787e-09  LoadKaas    Moderate     marinesediment     Unbound
    ## 203.1 198 218 5.539570e-08  LoadKaas    Moderate     marinesediment     Unbound
    ## 204   199 199 1.058010e-08  LoadKaas    Regional     marinesediment     Unbound
    ## 204.1 199 234 5.448440e-08  LoadKaas    Regional     marinesediment     Unbound
    ## 205   200 200 2.380211e-08  LoadKaas      Tropic     marinesediment     Unbound
    ## 205.1 200 220 5.539657e-08  LoadKaas      Tropic     marinesediment     Unbound
    ## 207   202 182 5.020305e-08  LoadKaas Continental   agriculturalsoil     Unbound
    ## 207.1 202 202 4.347406e-08  LoadKaas Continental   agriculturalsoil     Unbound
    ## 207.2 202 227 1.099848e-11 k_Erosion Continental   agriculturalsoil     Unbound
    ## 207.3 202 227 2.764921e-09  LoadKaas Continental   agriculturalsoil     Unbound
    ## 209   204 184 5.020305e-08  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 209.1 204 204 4.347406e-08  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 209.2 204 229 1.099848e-11 k_Erosion    Regional   agriculturalsoil     Unbound
    ## 209.3 204 229 2.764921e-09  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 212   207 182 1.103232e-07  LoadKaas Continental        naturalsoil     Unbound
    ## 212.1 207 207 4.349628e-08  LoadKaas Continental        naturalsoil     Unbound
    ## 212.2 207 227 2.416961e-11 k_Erosion Continental        naturalsoil     Unbound
    ## 212.3 207 227 6.076026e-09  LoadKaas Continental        naturalsoil     Unbound
    ## 214   209 184 1.103232e-07  LoadKaas    Regional        naturalsoil     Unbound
    ## 214.1 209 209 4.349628e-08  LoadKaas    Regional        naturalsoil     Unbound
    ## 214.2 209 229 2.416961e-11 k_Erosion    Regional        naturalsoil     Unbound
    ## 214.3 209 229 6.076026e-09  LoadKaas    Regional        naturalsoil     Unbound
    ## 216   211 181 2.401728e-08  LoadKaas      Arctic          othersoil     Unbound
    ## 216.1 211 211 9.472124e-09  LoadKaas      Arctic          othersoil     Unbound
    ## 216.2 211 226 2.416961e-11 k_Erosion      Arctic          othersoil     Unbound
    ## 216.3 211 231 2.416961e-11 k_Erosion      Arctic          othersoil     Unbound
    ## 216.4 211 231 2.186727e-09  LoadKaas      Arctic          othersoil     Unbound
    ## 217   212 182 1.103232e-07  LoadKaas Continental          othersoil     Unbound
    ## 217.1 212 212 4.349628e-08  LoadKaas Continental          othersoil     Unbound
    ## 217.2 212 227 2.416961e-11 k_Erosion Continental          othersoil     Unbound
    ## 217.3 212 227 6.076026e-09  LoadKaas Continental          othersoil     Unbound
    ## 217.4 212 232 2.416961e-11 k_Erosion Continental          othersoil     Unbound
    ## 218   213 183 1.103232e-07  LoadKaas    Moderate          othersoil     Unbound
    ## 218.1 213 213 4.349628e-08  LoadKaas    Moderate          othersoil     Unbound
    ## 218.2 213 228 2.416961e-11 k_Erosion    Moderate          othersoil     Unbound
    ## 218.3 213 233 2.416961e-11 k_Erosion    Moderate          othersoil     Unbound
    ## 218.4 213 233 6.076026e-09  LoadKaas    Moderate          othersoil     Unbound
    ## 219   214 184 1.103232e-07  LoadKaas    Regional          othersoil     Unbound
    ## 219.1 214 214 4.349628e-08  LoadKaas    Regional          othersoil     Unbound
    ## 219.2 214 229 2.416961e-11 k_Erosion    Regional          othersoil     Unbound
    ## 219.3 214 229 6.076026e-09  LoadKaas    Regional          othersoil     Unbound
    ## 219.4 214 234 2.416961e-11 k_Erosion    Regional          othersoil     Unbound
    ## 220   215 185 2.715579e-07  LoadKaas      Tropic          othersoil     Unbound
    ## 220.1 215 215 1.070757e-07  LoadKaas      Tropic          othersoil     Unbound
    ## 220.2 215 230 2.416961e-11 k_Erosion      Tropic          othersoil     Unbound
    ## 220.3 215 235 2.416961e-11 k_Erosion      Tropic          othersoil     Unbound
    ## 220.4 215 235 1.125567e-08  LoadKaas      Tropic          othersoil     Unbound
    ## 221   216 196 1.499228e-11  LoadKaas      Arctic          deepocean     Unbound
    ## 221.1 216 216 1.890367e-08  LoadKaas      Arctic          deepocean     Unbound
    ## 221.2 216 218 1.960784e-09  LoadKaas      Arctic          deepocean     Unbound
    ## 221.3 216 231 8.975375e-09  LoadKaas      Arctic          deepocean     Unbound
    ## 223   218 198 1.499228e-11  LoadKaas    Moderate          deepocean     Unbound
    ## 223.1 218 216 0.000000e+00  LoadKaas    Moderate          deepocean     Unbound
    ## 223.2 218 218 8.685848e-08  LoadKaas    Moderate          deepocean     Unbound
    ## 223.3 218 220 1.289139e-09  LoadKaas    Moderate          deepocean     Unbound
    ## 223.4 218 233 8.303729e-09  LoadKaas    Moderate          deepocean     Unbound
    ## 225   220 200 1.499228e-11  LoadKaas      Tropic          deepocean     Unbound
    ## 225.1 220 218 0.000000e+00  LoadKaas      Tropic          deepocean     Unbound
    ## 225.2 220 220 2.138707e-07  LoadKaas      Tropic          deepocean     Unbound
    ## 225.3 220 235 7.574814e-09  LoadKaas      Tropic          deepocean     Unbound
    ## 227   222 182 5.123442e-08  LoadKaas Continental               lake     Unbound
    ## 227.1 222 222 8.688855e-08  LoadKaas Continental               lake     Unbound
    ## 227.2 222 227 2.397260e-09  LoadKaas Continental               lake     Unbound
    ## 227.3 222 232 0.000000e+00  LoadKaas Continental               lake     Unbound
    ## 229   224 184 5.123442e-08  LoadKaas    Regional               lake     Unbound
    ## 229.1 224 224 8.688855e-08  LoadKaas    Regional               lake     Unbound
    ## 229.2 224 229 2.397260e-08  LoadKaas    Regional               lake     Unbound
    ## 229.3 224 234 0.000000e+00  LoadKaas    Regional               lake     Unbound
    ## 232   227 182 1.705911e-06  LoadKaas Continental              river     Unbound
    ## 232.1 227 187 2.239282e-08  LoadKaas Continental              river     Unbound
    ## 232.2 227 222 0.000000e+00  LoadKaas Continental              river     Unbound
    ## 232.3 227 227 8.679173e-08  LoadKaas Continental              river     Unbound
    ## 232.4 227 229 0.000000e+00  LoadKaas Continental              river     Unbound
    ## 232.5 227 232 7.264425e-08  LoadKaas Continental              river     Unbound
    ## 234   229 184 1.705911e-06  LoadKaas    Regional              river     Unbound
    ## 234.1 229 189 2.239282e-08  LoadKaas    Regional              river     Unbound
    ## 234.2 229 224 0.000000e+00  LoadKaas    Regional              river     Unbound
    ## 234.3 229 229 8.679173e-08  LoadKaas    Regional              river     Unbound
    ## 234.4 229 234 7.264425e-08  LoadKaas    Regional              river     Unbound
    ## 236   231 181 4.969730e-08  LoadKaas      Arctic                sea     Unbound
    ## 236.1 231 216 2.692612e-07  LoadKaas      Arctic                sea     Unbound
    ## 236.2 231 231 1.890367e-08  LoadKaas      Arctic                sea     Unbound
    ## 236.3 231 233 0.000000e+00  LoadKaas      Arctic                sea     Unbound
    ## 237   232 182 2.560835e-08  LoadKaas Continental                sea     Unbound
    ## 237.1 232 197 2.248843e-10  LoadKaas Continental                sea     Unbound
    ## 237.2 232 232 8.685848e-08  LoadKaas Continental                sea     Unbound
    ## 237.3 232 233 3.169135e-08  LoadKaas Continental                sea     Unbound
    ## 237.4 232 234 1.660023e-11  LoadKaas Continental                sea     Unbound
    ## 238   233 183 5.121669e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.1 233 218 2.491119e-07  LoadKaas    Moderate                sea     Unbound
    ## 238.2 233 231 3.867416e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.3 233 232 6.068386e-09  LoadKaas    Moderate                sea     Unbound
    ## 238.4 233 233 8.685848e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.5 233 235 0.000000e+00  LoadKaas    Moderate                sea     Unbound
    ## 239   234 184 5.121669e-07  LoadKaas    Regional                sea     Unbound
    ## 239.1 234 199 4.497685e-09  LoadKaas    Regional                sea     Unbound
    ## 239.2 234 232 1.369854e-06  LoadKaas    Regional                sea     Unbound
    ## 239.3 234 234 8.685848e-08  LoadKaas    Regional                sea     Unbound
    ## 240   235 185 5.152637e-08  LoadKaas      Tropic                sea     Unbound
    ## 240.1 235 220 2.272444e-07  LoadKaas      Tropic                sea     Unbound
    ## 240.2 235 233 1.680672e-08  LoadKaas      Tropic                sea     Unbound
    ## 240.3 235 235 2.138707e-07  LoadKaas      Tropic                sea     Unbound
    ##       fromAbbr     toScale       toSubCompart toSpecies toAbbr
    ## 27        s2CP                          river             w1CP
    ## 29        s2RP                          river             w1RP
    ## 32        s1CP                          river             w1CP
    ## 34        s1RP                          river             w1RP
    ## 36        s3AP                          river             w1AP
    ## 36.1      s3AP                            sea             w2AP
    ## 37        s3CP                          river             w1CP
    ## 37.1      s3CP                            sea             w2CP
    ## 38        s3MP                          river             w1MP
    ## 38.1      s3MP                            sea             w2MP
    ## 39        s3RP                          river             w1RP
    ## 39.1      s3RP                            sea             w2RP
    ## 40        s3TP                          river             w1TP
    ## 40.1      s3TP                            sea             w2TP
    ## 87        s2CA                          river             w1CA
    ## 89        s2RA                          river             w1RA
    ## 92        s1CA                          river             w1CA
    ## 94        s1RA                          river             w1RA
    ## 96        s3AA                          river             w1AA
    ## 96.1      s3AA                            sea             w2AA
    ## 97        s3CA                          river             w1CA
    ## 97.1      s3CA                            sea             w2CA
    ## 98        s3MA                          river             w1MA
    ## 98.1      s3MA                            sea             w2MA
    ## 99        s3RA                          river             w1RA
    ## 99.1      s3RA                            sea             w2RA
    ## 100       s3TA                          river             w1TA
    ## 100.1     s3TA                            sea             w2TA
    ## 147       s2CS                          river             w1CS
    ## 149       s2RS                          river             w1RS
    ## 152       s1CS                          river             w1CS
    ## 154       s1RS                          river             w1RS
    ## 156       s3AS                          river             w1AS
    ## 156.1     s3AS                            sea             w2AS
    ## 157       s3CS                          river             w1CS
    ## 157.1     s3CS                            sea             w2CS
    ## 158       s3MS                          river             w1MS
    ## 158.1     s3MS                            sea             w2MS
    ## 159       s3RS                          river             w1RS
    ## 159.1     s3RS                            sea             w2RS
    ## 160       s3TS                          river             w1TS
    ## 160.1     s3TS                            sea             w2TS
    ## 181        aAU                                             aAU
    ## 181.1      aAU    Moderate                                 aMU
    ## 181.2      aAU                      othersoil             s3AU
    ## 181.3      aAU                            sea             w2AU
    ## 182        aCU                                             aCU
    ## 182.1      aCU    Moderate                                 aMU
    ## 182.2      aCU    Regional                                 aRU
    ## 182.3      aCU               agriculturalsoil             s2CU
    ## 182.4      aCU                    naturalsoil             s1CU
    ## 182.5      aCU                      othersoil             s3CU
    ## 182.6      aCU                           lake             w0CU
    ## 182.7      aCU                          river             w1CU
    ## 182.8      aCU                            sea             w2CU
    ## 183        aMU      Arctic                                 aAU
    ## 183.1      aMU Continental                                 aCU
    ## 183.2      aMU                                             aMU
    ## 183.3      aMU      Tropic                                 aTU
    ## 183.4      aMU                      othersoil             s3MU
    ## 183.5      aMU                            sea             w2MU
    ## 184        aRU Continental                                 aCU
    ## 184.1      aRU                                             aRU
    ## 184.2      aRU               agriculturalsoil             s2RU
    ## 184.3      aRU                    naturalsoil             s1RU
    ## 184.4      aRU                      othersoil             s3RU
    ## 184.5      aRU                           lake             w0RU
    ## 184.6      aRU                          river             w1RU
    ## 184.7      aRU                            sea             w2RU
    ## 185        aTU    Moderate                                 aMU
    ## 185.1      aTU                                             aTU
    ## 185.2      aTU                      othersoil             s3TU
    ## 185.3      aTU                            sea             w2TU
    ## 192      sd1CU                                           sd1CU
    ## 192.1    sd1CU                          river             w1CU
    ## 194      sd1RU                                           sd1RU
    ## 194.1    sd1RU                          river             w1RU
    ## 201      sd2AU                                           sd2AU
    ## 201.1    sd2AU                      deepocean             w3AU
    ## 202      sd2CU                                           sd2CU
    ## 202.1    sd2CU                            sea             w2CU
    ## 203      sd2MU                                           sd2MU
    ## 203.1    sd2MU                      deepocean             w3MU
    ## 204      sd2RU                                           sd2RU
    ## 204.1    sd2RU                            sea             w2RU
    ## 205      sd2TU                                           sd2TU
    ## 205.1    sd2TU                      deepocean             w3TU
    ## 207       s2CU                            air              aCU
    ## 207.1     s2CU                                            s2CU
    ## 207.2     s2CU                          river             w1CU
    ## 207.3     s2CU                          river             w1CU
    ## 209       s2RU                            air              aRU
    ## 209.1     s2RU                                            s2RU
    ## 209.2     s2RU                          river             w1RU
    ## 209.3     s2RU                          river             w1RU
    ## 212       s1CU                            air              aCU
    ## 212.1     s1CU                                            s1CU
    ## 212.2     s1CU                          river             w1CU
    ## 212.3     s1CU                          river             w1CU
    ## 214       s1RU                            air              aRU
    ## 214.1     s1RU                                            s1RU
    ## 214.2     s1RU                          river             w1RU
    ## 214.3     s1RU                          river             w1RU
    ## 216       s3AU                            air              aAU
    ## 216.1     s3AU                                            s3AU
    ## 216.2     s3AU                          river             w1AU
    ## 216.3     s3AU                            sea             w2AU
    ## 216.4     s3AU                            sea             w2AU
    ## 217       s3CU                            air              aCU
    ## 217.1     s3CU                                            s3CU
    ## 217.2     s3CU                          river             w1CU
    ## 217.3     s3CU                          river             w1CU
    ## 217.4     s3CU                            sea             w2CU
    ## 218       s3MU                            air              aMU
    ## 218.1     s3MU                                            s3MU
    ## 218.2     s3MU                          river             w1MU
    ## 218.3     s3MU                            sea             w2MU
    ## 218.4     s3MU                            sea             w2MU
    ## 219       s3RU                            air              aRU
    ## 219.1     s3RU                                            s3RU
    ## 219.2     s3RU                          river             w1RU
    ## 219.3     s3RU                          river             w1RU
    ## 219.4     s3RU                            sea             w2RU
    ## 220       s3TU                            air              aTU
    ## 220.1     s3TU                                            s3TU
    ## 220.2     s3TU                          river             w1TU
    ## 220.3     s3TU                            sea             w2TU
    ## 220.4     s3TU                            sea             w2TU
    ## 221       w3AU                 marinesediment            sd2AU
    ## 221.1     w3AU                                            w3AU
    ## 221.2     w3AU    Moderate                                w3MU
    ## 221.3     w3AU                            sea             w2AU
    ## 223       w3MU                 marinesediment            sd2MU
    ## 223.1     w3MU      Arctic                                w3AU
    ## 223.2     w3MU                                            w3MU
    ## 223.3     w3MU      Tropic                                w3TU
    ## 223.4     w3MU                            sea             w2MU
    ## 225       w3TU                 marinesediment            sd2TU
    ## 225.1     w3TU    Moderate                                w3MU
    ## 225.2     w3TU                                            w3TU
    ## 225.3     w3TU                            sea             w2TU
    ## 227       w0CU                            air              aCU
    ## 227.1     w0CU                                            w0CU
    ## 227.2     w0CU                          river             w1CU
    ## 227.3     w0CU                            sea             w2CU
    ## 229       w0RU                            air              aRU
    ## 229.1     w0RU                                            w0RU
    ## 229.2     w0RU                          river             w1RU
    ## 229.3     w0RU                            sea             w2RU
    ## 232       w1CU                            air              aCU
    ## 232.1     w1CU             freshwatersediment            sd1CU
    ## 232.2     w1CU                           lake             w0CU
    ## 232.3     w1CU                                            w1CU
    ## 232.4     w1CU    Regional                                w1RU
    ## 232.5     w1CU                            sea             w2CU
    ## 234       w1RU                            air              aRU
    ## 234.1     w1RU             freshwatersediment            sd1RU
    ## 234.2     w1RU                           lake             w0RU
    ## 234.3     w1RU                                            w1RU
    ## 234.4     w1RU                            sea             w2RU
    ## 236       w2AU                            air              aAU
    ## 236.1     w2AU                      deepocean             w3AU
    ## 236.2     w2AU                                            w2AU
    ## 236.3     w2AU    Moderate                                w2MU
    ## 237       w2CU                            air              aCU
    ## 237.1     w2CU                 marinesediment            sd2CU
    ## 237.2     w2CU                                            w2CU
    ## 237.3     w2CU    Moderate                                w2MU
    ## 237.4     w2CU    Regional                                w2RU
    ## 238       w2MU                            air              aMU
    ## 238.1     w2MU                      deepocean             w3MU
    ## 238.2     w2MU      Arctic                                w2AU
    ## 238.3     w2MU Continental                                w2CU
    ## 238.4     w2MU                                            w2MU
    ## 238.5     w2MU      Tropic                                w2TU
    ## 239       w2RU                            air              aRU
    ## 239.1     w2RU                 marinesediment            sd2RU
    ## 239.2     w2RU Continental                                w2CU
    ## 239.3     w2RU                                            w2RU
    ## 240       w2TU                            air              aTU
    ## 240.1     w2TU                      deepocean             w3TU
    ## 240.2     w2TU    Moderate                                w2MU
    ## 240.3     w2TU                                            w2TU

## process calculation and where does it take place?

Where a process takes place is usually stored in one of the three
process table, which of the three depending on the dimension that is
crossed by the process. In this case it’s in SubCompartProcesses. Note

``` r
SubCompartProcesses <- World$fetchData("SubCompartProcesses")
SubCompartProcesses[SubCompartProcesses$process == "k_Erosion",]
```

    ##      process             from    to
    ## 19 k_Erosion agriculturalsoil river
    ## 20 k_Erosion      naturalsoil river
    ## 21 k_Erosion        othersoil river
    ## 22 k_Erosion        othersoil   sea

How can erosion go to river AND to sea? This is because there is no
subcompartment river in the global scales. To solve this, we have to
adjust the function to correct this. This is where the parameters
ScaleName and to.SubCompartName will be used for. We return NA for cases
that do not exists. (BTW there is always an automated check on states
\[boxes\] that do not exist.) \[something on the to. preposition?\]

``` r
k_Erosion <- function(CORRrunoff, EROSIONsoil, VertDistance, ScaleName, to.SubCompartName){
  if (ScaleName %in% c("Tropic", "Moderate", "Arctic") & to.SubCompartName != "sea") {
    return(NA)
  } 
  if ((! ScaleName %in% c("Tropic", "Moderate", "Arctic")) & to.SubCompartName != "river") {
    return(NA)
  } 
  
  EROSIONsoil * CORRrunoff / VertDistance #[s-1]
}
World$NewProcess("k_Erosion")
World$UpdateKaas("k_Erosion")
World$kaas
```

    ##         i   j            k   process   fromScale     fromSubCompart fromSpecies
    ## 27     27  52 1.099848e-11 k_Erosion Continental   agriculturalsoil       Large
    ## 29     29  54 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Large
    ## 32     32  52 2.416961e-11 k_Erosion Continental        naturalsoil       Large
    ## 34     34  54 2.416961e-11 k_Erosion    Regional        naturalsoil       Large
    ## 36     36  56 2.416961e-11 k_Erosion      Arctic          othersoil       Large
    ## 37     37  52 2.416961e-11 k_Erosion Continental          othersoil       Large
    ## 38     38  58 2.416961e-11 k_Erosion    Moderate          othersoil       Large
    ## 39     39  54 2.416961e-11 k_Erosion    Regional          othersoil       Large
    ## 40     40  60 2.416961e-11 k_Erosion      Tropic          othersoil       Large
    ## 87     87 112 1.099848e-11 k_Erosion Continental   agriculturalsoil       Small
    ## 89     89 114 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Small
    ## 92     92 112 2.416961e-11 k_Erosion Continental        naturalsoil       Small
    ## 94     94 114 2.416961e-11 k_Erosion    Regional        naturalsoil       Small
    ## 96     96 116 2.416961e-11 k_Erosion      Arctic          othersoil       Small
    ## 97     97 112 2.416961e-11 k_Erosion Continental          othersoil       Small
    ## 98     98 118 2.416961e-11 k_Erosion    Moderate          othersoil       Small
    ## 99     99 114 2.416961e-11 k_Erosion    Regional          othersoil       Small
    ## 100   100 120 2.416961e-11 k_Erosion      Tropic          othersoil       Small
    ## 147   147 172 1.099848e-11 k_Erosion Continental   agriculturalsoil       Solid
    ## 149   149 174 1.099848e-11 k_Erosion    Regional   agriculturalsoil       Solid
    ## 152   152 172 2.416961e-11 k_Erosion Continental        naturalsoil       Solid
    ## 154   154 174 2.416961e-11 k_Erosion    Regional        naturalsoil       Solid
    ## 156   156 176 2.416961e-11 k_Erosion      Arctic          othersoil       Solid
    ## 157   157 172 2.416961e-11 k_Erosion Continental          othersoil       Solid
    ## 158   158 178 2.416961e-11 k_Erosion    Moderate          othersoil       Solid
    ## 159   159 174 2.416961e-11 k_Erosion    Regional          othersoil       Solid
    ## 160   160 180 2.416961e-11 k_Erosion      Tropic          othersoil       Solid
    ## 181   181 181 1.809525e-07  LoadKaas      Arctic                air     Unbound
    ## 181.1 181 183 6.923419e-07  LoadKaas      Arctic                air     Unbound
    ## 181.2 181 211 4.514746e-10  LoadKaas      Arctic                air     Unbound
    ## 181.3 181 231 1.126562e-07  LoadKaas      Arctic                air     Unbound
    ## 182   182 182 2.163047e-07  LoadKaas Continental                air     Unbound
    ## 182.1 182 183 1.381786e-06  LoadKaas Continental                air     Unbound
    ## 182.2 182 184 3.003899e-07  LoadKaas Continental                air     Unbound
    ## 182.3 182 202 3.988915e-10  LoadKaas Continental                air     Unbound
    ## 182.4 182 207 1.795012e-10  LoadKaas Continental                air     Unbound
    ## 182.5 182 212 6.648191e-11  LoadKaas Continental                air     Unbound
    ## 182.6 182 222 6.933810e-11  LoadKaas Continental                air     Unbound
    ## 182.7 182 227 7.627191e-10  LoadKaas Continental                air     Unbound
    ## 182.8 182 232 2.954591e-08  LoadKaas Continental                air     Unbound
    ## 183   183 181 3.793229e-07  LoadKaas    Moderate                air     Unbound
    ## 183.1 183 182 1.282412e-07  LoadKaas    Moderate                air     Unbound
    ## 183.2 183 183 2.163047e-07  LoadKaas    Moderate                air     Unbound
    ## 183.3 183 185 6.570066e-07  LoadKaas    Moderate                air     Unbound
    ## 183.4 183 213 6.865203e-10  LoadKaas    Moderate                air     Unbound
    ## 183.5 183 233 2.864058e-08  LoadKaas    Moderate                air     Unbound
    ## 184   184 182 9.420143e-06  LoadKaas    Regional                air     Unbound
    ## 184.1 184 184 2.163047e-07  LoadKaas    Regional                air     Unbound
    ## 184.2 184 204 8.202341e-10  LoadKaas    Regional                air     Unbound
    ## 184.3 184 209 3.691053e-10  LoadKaas    Regional                air     Unbound
    ## 184.4 184 214 1.367057e-10  LoadKaas    Regional                air     Unbound
    ## 184.5 184 224 1.425791e-10  LoadKaas    Regional                air     Unbound
    ## 184.6 184 229 1.568370e-09  LoadKaas    Regional                air     Unbound
    ## 184.7 184 234 2.495150e-10  LoadKaas    Regional                air     Unbound
    ## 185   185 183 3.997238e-07  LoadKaas      Tropic                air     Unbound
    ## 185.1 185 185 2.403663e-07  LoadKaas      Tropic                air     Unbound
    ## 185.2 185 215 5.146421e-10  LoadKaas      Tropic                air     Unbound
    ## 185.3 185 235 2.148645e-08  LoadKaas      Tropic                air     Unbound
    ## 192   187 187 1.254003e-08  LoadKaas Continental freshwatersediment     Unbound
    ## 192.1 187 227 7.181458e-08  LoadKaas Continental freshwatersediment     Unbound
    ## 194   189 189 1.256117e-08  LoadKaas    Regional freshwatersediment     Unbound
    ## 194.1 189 229 7.179344e-08  LoadKaas    Regional freshwatersediment     Unbound
    ## 201   196 196 2.105757e-09  LoadKaas      Arctic     marinesediment     Unbound
    ## 201.1 196 216 5.539657e-08  LoadKaas      Arctic     marinesediment     Unbound
    ## 202   197 197 9.665804e-09  LoadKaas Continental     marinesediment     Unbound
    ## 202.1 197 232 5.539869e-08  LoadKaas Continental     marinesediment     Unbound
    ## 203   198 198 9.668787e-09  LoadKaas    Moderate     marinesediment     Unbound
    ## 203.1 198 218 5.539570e-08  LoadKaas    Moderate     marinesediment     Unbound
    ## 204   199 199 1.058010e-08  LoadKaas    Regional     marinesediment     Unbound
    ## 204.1 199 234 5.448440e-08  LoadKaas    Regional     marinesediment     Unbound
    ## 205   200 200 2.380211e-08  LoadKaas      Tropic     marinesediment     Unbound
    ## 205.1 200 220 5.539657e-08  LoadKaas      Tropic     marinesediment     Unbound
    ## 207   202 182 5.020305e-08  LoadKaas Continental   agriculturalsoil     Unbound
    ## 207.1 202 202 4.347406e-08  LoadKaas Continental   agriculturalsoil     Unbound
    ## 207.2 202 227 1.099848e-11 k_Erosion Continental   agriculturalsoil     Unbound
    ## 207.3 202 227 2.764921e-09  LoadKaas Continental   agriculturalsoil     Unbound
    ## 209   204 184 5.020305e-08  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 209.1 204 204 4.347406e-08  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 209.2 204 229 1.099848e-11 k_Erosion    Regional   agriculturalsoil     Unbound
    ## 209.3 204 229 2.764921e-09  LoadKaas    Regional   agriculturalsoil     Unbound
    ## 212   207 182 1.103232e-07  LoadKaas Continental        naturalsoil     Unbound
    ## 212.1 207 207 4.349628e-08  LoadKaas Continental        naturalsoil     Unbound
    ## 212.2 207 227 2.416961e-11 k_Erosion Continental        naturalsoil     Unbound
    ## 212.3 207 227 6.076026e-09  LoadKaas Continental        naturalsoil     Unbound
    ## 214   209 184 1.103232e-07  LoadKaas    Regional        naturalsoil     Unbound
    ## 214.1 209 209 4.349628e-08  LoadKaas    Regional        naturalsoil     Unbound
    ## 214.2 209 229 2.416961e-11 k_Erosion    Regional        naturalsoil     Unbound
    ## 214.3 209 229 6.076026e-09  LoadKaas    Regional        naturalsoil     Unbound
    ## 216   211 181 2.401728e-08  LoadKaas      Arctic          othersoil     Unbound
    ## 216.1 211 211 9.472124e-09  LoadKaas      Arctic          othersoil     Unbound
    ## 216.2 211 231 2.416961e-11 k_Erosion      Arctic          othersoil     Unbound
    ## 216.3 211 231 2.186727e-09  LoadKaas      Arctic          othersoil     Unbound
    ## 217   212 182 1.103232e-07  LoadKaas Continental          othersoil     Unbound
    ## 217.1 212 212 4.349628e-08  LoadKaas Continental          othersoil     Unbound
    ## 217.2 212 227 2.416961e-11 k_Erosion Continental          othersoil     Unbound
    ## 217.3 212 227 6.076026e-09  LoadKaas Continental          othersoil     Unbound
    ## 218   213 183 1.103232e-07  LoadKaas    Moderate          othersoil     Unbound
    ## 218.1 213 213 4.349628e-08  LoadKaas    Moderate          othersoil     Unbound
    ## 218.2 213 233 2.416961e-11 k_Erosion    Moderate          othersoil     Unbound
    ## 218.3 213 233 6.076026e-09  LoadKaas    Moderate          othersoil     Unbound
    ## 219   214 184 1.103232e-07  LoadKaas    Regional          othersoil     Unbound
    ## 219.1 214 214 4.349628e-08  LoadKaas    Regional          othersoil     Unbound
    ## 219.2 214 229 2.416961e-11 k_Erosion    Regional          othersoil     Unbound
    ## 219.3 214 229 6.076026e-09  LoadKaas    Regional          othersoil     Unbound
    ## 220   215 185 2.715579e-07  LoadKaas      Tropic          othersoil     Unbound
    ## 220.1 215 215 1.070757e-07  LoadKaas      Tropic          othersoil     Unbound
    ## 220.2 215 235 2.416961e-11 k_Erosion      Tropic          othersoil     Unbound
    ## 220.3 215 235 1.125567e-08  LoadKaas      Tropic          othersoil     Unbound
    ## 221   216 196 1.499228e-11  LoadKaas      Arctic          deepocean     Unbound
    ## 221.1 216 216 1.890367e-08  LoadKaas      Arctic          deepocean     Unbound
    ## 221.2 216 218 1.960784e-09  LoadKaas      Arctic          deepocean     Unbound
    ## 221.3 216 231 8.975375e-09  LoadKaas      Arctic          deepocean     Unbound
    ## 223   218 198 1.499228e-11  LoadKaas    Moderate          deepocean     Unbound
    ## 223.1 218 216 0.000000e+00  LoadKaas    Moderate          deepocean     Unbound
    ## 223.2 218 218 8.685848e-08  LoadKaas    Moderate          deepocean     Unbound
    ## 223.3 218 220 1.289139e-09  LoadKaas    Moderate          deepocean     Unbound
    ## 223.4 218 233 8.303729e-09  LoadKaas    Moderate          deepocean     Unbound
    ## 225   220 200 1.499228e-11  LoadKaas      Tropic          deepocean     Unbound
    ## 225.1 220 218 0.000000e+00  LoadKaas      Tropic          deepocean     Unbound
    ## 225.2 220 220 2.138707e-07  LoadKaas      Tropic          deepocean     Unbound
    ## 225.3 220 235 7.574814e-09  LoadKaas      Tropic          deepocean     Unbound
    ## 227   222 182 5.123442e-08  LoadKaas Continental               lake     Unbound
    ## 227.1 222 222 8.688855e-08  LoadKaas Continental               lake     Unbound
    ## 227.2 222 227 2.397260e-09  LoadKaas Continental               lake     Unbound
    ## 227.3 222 232 0.000000e+00  LoadKaas Continental               lake     Unbound
    ## 229   224 184 5.123442e-08  LoadKaas    Regional               lake     Unbound
    ## 229.1 224 224 8.688855e-08  LoadKaas    Regional               lake     Unbound
    ## 229.2 224 229 2.397260e-08  LoadKaas    Regional               lake     Unbound
    ## 229.3 224 234 0.000000e+00  LoadKaas    Regional               lake     Unbound
    ## 232   227 182 1.705911e-06  LoadKaas Continental              river     Unbound
    ## 232.1 227 187 2.239282e-08  LoadKaas Continental              river     Unbound
    ## 232.2 227 222 0.000000e+00  LoadKaas Continental              river     Unbound
    ## 232.3 227 227 8.679173e-08  LoadKaas Continental              river     Unbound
    ## 232.4 227 229 0.000000e+00  LoadKaas Continental              river     Unbound
    ## 232.5 227 232 7.264425e-08  LoadKaas Continental              river     Unbound
    ## 234   229 184 1.705911e-06  LoadKaas    Regional              river     Unbound
    ## 234.1 229 189 2.239282e-08  LoadKaas    Regional              river     Unbound
    ## 234.2 229 224 0.000000e+00  LoadKaas    Regional              river     Unbound
    ## 234.3 229 229 8.679173e-08  LoadKaas    Regional              river     Unbound
    ## 234.4 229 234 7.264425e-08  LoadKaas    Regional              river     Unbound
    ## 236   231 181 4.969730e-08  LoadKaas      Arctic                sea     Unbound
    ## 236.1 231 216 2.692612e-07  LoadKaas      Arctic                sea     Unbound
    ## 236.2 231 231 1.890367e-08  LoadKaas      Arctic                sea     Unbound
    ## 236.3 231 233 0.000000e+00  LoadKaas      Arctic                sea     Unbound
    ## 237   232 182 2.560835e-08  LoadKaas Continental                sea     Unbound
    ## 237.1 232 197 2.248843e-10  LoadKaas Continental                sea     Unbound
    ## 237.2 232 232 8.685848e-08  LoadKaas Continental                sea     Unbound
    ## 237.3 232 233 3.169135e-08  LoadKaas Continental                sea     Unbound
    ## 237.4 232 234 1.660023e-11  LoadKaas Continental                sea     Unbound
    ## 238   233 183 5.121669e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.1 233 218 2.491119e-07  LoadKaas    Moderate                sea     Unbound
    ## 238.2 233 231 3.867416e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.3 233 232 6.068386e-09  LoadKaas    Moderate                sea     Unbound
    ## 238.4 233 233 8.685848e-08  LoadKaas    Moderate                sea     Unbound
    ## 238.5 233 235 0.000000e+00  LoadKaas    Moderate                sea     Unbound
    ## 239   234 184 5.121669e-07  LoadKaas    Regional                sea     Unbound
    ## 239.1 234 199 4.497685e-09  LoadKaas    Regional                sea     Unbound
    ## 239.2 234 232 1.369854e-06  LoadKaas    Regional                sea     Unbound
    ## 239.3 234 234 8.685848e-08  LoadKaas    Regional                sea     Unbound
    ## 240   235 185 5.152637e-08  LoadKaas      Tropic                sea     Unbound
    ## 240.1 235 220 2.272444e-07  LoadKaas      Tropic                sea     Unbound
    ## 240.2 235 233 1.680672e-08  LoadKaas      Tropic                sea     Unbound
    ## 240.3 235 235 2.138707e-07  LoadKaas      Tropic                sea     Unbound
    ##       fromAbbr     toScale       toSubCompart toSpecies toAbbr
    ## 27        s2CP                          river             w1CP
    ## 29        s2RP                          river             w1RP
    ## 32        s1CP                          river             w1CP
    ## 34        s1RP                          river             w1RP
    ## 36        s3AP                            sea             w2AP
    ## 37        s3CP                          river             w1CP
    ## 38        s3MP                            sea             w2MP
    ## 39        s3RP                          river             w1RP
    ## 40        s3TP                            sea             w2TP
    ## 87        s2CA                          river             w1CA
    ## 89        s2RA                          river             w1RA
    ## 92        s1CA                          river             w1CA
    ## 94        s1RA                          river             w1RA
    ## 96        s3AA                            sea             w2AA
    ## 97        s3CA                          river             w1CA
    ## 98        s3MA                            sea             w2MA
    ## 99        s3RA                          river             w1RA
    ## 100       s3TA                            sea             w2TA
    ## 147       s2CS                          river             w1CS
    ## 149       s2RS                          river             w1RS
    ## 152       s1CS                          river             w1CS
    ## 154       s1RS                          river             w1RS
    ## 156       s3AS                            sea             w2AS
    ## 157       s3CS                          river             w1CS
    ## 158       s3MS                            sea             w2MS
    ## 159       s3RS                          river             w1RS
    ## 160       s3TS                            sea             w2TS
    ## 181        aAU                                             aAU
    ## 181.1      aAU    Moderate                                 aMU
    ## 181.2      aAU                      othersoil             s3AU
    ## 181.3      aAU                            sea             w2AU
    ## 182        aCU                                             aCU
    ## 182.1      aCU    Moderate                                 aMU
    ## 182.2      aCU    Regional                                 aRU
    ## 182.3      aCU               agriculturalsoil             s2CU
    ## 182.4      aCU                    naturalsoil             s1CU
    ## 182.5      aCU                      othersoil             s3CU
    ## 182.6      aCU                           lake             w0CU
    ## 182.7      aCU                          river             w1CU
    ## 182.8      aCU                            sea             w2CU
    ## 183        aMU      Arctic                                 aAU
    ## 183.1      aMU Continental                                 aCU
    ## 183.2      aMU                                             aMU
    ## 183.3      aMU      Tropic                                 aTU
    ## 183.4      aMU                      othersoil             s3MU
    ## 183.5      aMU                            sea             w2MU
    ## 184        aRU Continental                                 aCU
    ## 184.1      aRU                                             aRU
    ## 184.2      aRU               agriculturalsoil             s2RU
    ## 184.3      aRU                    naturalsoil             s1RU
    ## 184.4      aRU                      othersoil             s3RU
    ## 184.5      aRU                           lake             w0RU
    ## 184.6      aRU                          river             w1RU
    ## 184.7      aRU                            sea             w2RU
    ## 185        aTU    Moderate                                 aMU
    ## 185.1      aTU                                             aTU
    ## 185.2      aTU                      othersoil             s3TU
    ## 185.3      aTU                            sea             w2TU
    ## 192      sd1CU                                           sd1CU
    ## 192.1    sd1CU                          river             w1CU
    ## 194      sd1RU                                           sd1RU
    ## 194.1    sd1RU                          river             w1RU
    ## 201      sd2AU                                           sd2AU
    ## 201.1    sd2AU                      deepocean             w3AU
    ## 202      sd2CU                                           sd2CU
    ## 202.1    sd2CU                            sea             w2CU
    ## 203      sd2MU                                           sd2MU
    ## 203.1    sd2MU                      deepocean             w3MU
    ## 204      sd2RU                                           sd2RU
    ## 204.1    sd2RU                            sea             w2RU
    ## 205      sd2TU                                           sd2TU
    ## 205.1    sd2TU                      deepocean             w3TU
    ## 207       s2CU                            air              aCU
    ## 207.1     s2CU                                            s2CU
    ## 207.2     s2CU                          river             w1CU
    ## 207.3     s2CU                          river             w1CU
    ## 209       s2RU                            air              aRU
    ## 209.1     s2RU                                            s2RU
    ## 209.2     s2RU                          river             w1RU
    ## 209.3     s2RU                          river             w1RU
    ## 212       s1CU                            air              aCU
    ## 212.1     s1CU                                            s1CU
    ## 212.2     s1CU                          river             w1CU
    ## 212.3     s1CU                          river             w1CU
    ## 214       s1RU                            air              aRU
    ## 214.1     s1RU                                            s1RU
    ## 214.2     s1RU                          river             w1RU
    ## 214.3     s1RU                          river             w1RU
    ## 216       s3AU                            air              aAU
    ## 216.1     s3AU                                            s3AU
    ## 216.2     s3AU                            sea             w2AU
    ## 216.3     s3AU                            sea             w2AU
    ## 217       s3CU                            air              aCU
    ## 217.1     s3CU                                            s3CU
    ## 217.2     s3CU                          river             w1CU
    ## 217.3     s3CU                          river             w1CU
    ## 218       s3MU                            air              aMU
    ## 218.1     s3MU                                            s3MU
    ## 218.2     s3MU                            sea             w2MU
    ## 218.3     s3MU                            sea             w2MU
    ## 219       s3RU                            air              aRU
    ## 219.1     s3RU                                            s3RU
    ## 219.2     s3RU                          river             w1RU
    ## 219.3     s3RU                          river             w1RU
    ## 220       s3TU                            air              aTU
    ## 220.1     s3TU                                            s3TU
    ## 220.2     s3TU                            sea             w2TU
    ## 220.3     s3TU                            sea             w2TU
    ## 221       w3AU                 marinesediment            sd2AU
    ## 221.1     w3AU                                            w3AU
    ## 221.2     w3AU    Moderate                                w3MU
    ## 221.3     w3AU                            sea             w2AU
    ## 223       w3MU                 marinesediment            sd2MU
    ## 223.1     w3MU      Arctic                                w3AU
    ## 223.2     w3MU                                            w3MU
    ## 223.3     w3MU      Tropic                                w3TU
    ## 223.4     w3MU                            sea             w2MU
    ## 225       w3TU                 marinesediment            sd2TU
    ## 225.1     w3TU    Moderate                                w3MU
    ## 225.2     w3TU                                            w3TU
    ## 225.3     w3TU                            sea             w2TU
    ## 227       w0CU                            air              aCU
    ## 227.1     w0CU                                            w0CU
    ## 227.2     w0CU                          river             w1CU
    ## 227.3     w0CU                            sea             w2CU
    ## 229       w0RU                            air              aRU
    ## 229.1     w0RU                                            w0RU
    ## 229.2     w0RU                          river             w1RU
    ## 229.3     w0RU                            sea             w2RU
    ## 232       w1CU                            air              aCU
    ## 232.1     w1CU             freshwatersediment            sd1CU
    ## 232.2     w1CU                           lake             w0CU
    ## 232.3     w1CU                                            w1CU
    ## 232.4     w1CU    Regional                                w1RU
    ## 232.5     w1CU                            sea             w2CU
    ## 234       w1RU                            air              aRU
    ## 234.1     w1RU             freshwatersediment            sd1RU
    ## 234.2     w1RU                           lake             w0RU
    ## 234.3     w1RU                                            w1RU
    ## 234.4     w1RU                            sea             w2RU
    ## 236       w2AU                            air              aAU
    ## 236.1     w2AU                      deepocean             w3AU
    ## 236.2     w2AU                                            w2AU
    ## 236.3     w2AU    Moderate                                w2MU
    ## 237       w2CU                            air              aCU
    ## 237.1     w2CU                 marinesediment            sd2CU
    ## 237.2     w2CU                                            w2CU
    ## 237.3     w2CU    Moderate                                w2MU
    ## 237.4     w2CU    Regional                                w2RU
    ## 238       w2MU                            air              aMU
    ## 238.1     w2MU                      deepocean             w3MU
    ## 238.2     w2MU      Arctic                                w2AU
    ## 238.3     w2MU Continental                                w2CU
    ## 238.4     w2MU                                            w2MU
    ## 238.5     w2MU      Tropic                                w2TU
    ## 239       w2RU                            air              aRU
    ## 239.1     w2RU                 marinesediment            sd2RU
    ## 239.2     w2RU Continental                                w2CU
    ## 239.3     w2RU                                            w2RU
    ## 240       w2TU                            air              aTU
    ## 240.1     w2TU                      deepocean             w3TU
    ## 240.2     w2TU    Moderate                                w2MU
    ## 240.3     w2TU                                            w2TU

While we’re at it, we can do Runoff in a similar way. Here the formula
is: RAINrate \* FRACrun / Ksw \* CORRrunoff / VertDistance So we need
Ksw, which can be in the data, or you can apply a formulas depending on
the type of substance. See the vignette partitioning.Rmd.

``` r
Substance_ChemClass <- World$fetchData("ChemClass")
QSARtable <- World$fetchData("QSARtable")
QSARrecord <- QSARtable[QSARtable$QSAR.ChemClass == Substance_ChemClass,]
```
