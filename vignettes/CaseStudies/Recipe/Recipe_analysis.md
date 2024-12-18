Recipe data analysis
================

## Load output data

``` r
folderpath <- "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/FF_other_test"

filepaths <- list.files(folderpath)

RData_files <- filepaths[endsWith(filepaths, '.RData')]

SS_masses_continental <- tibble()

for(file in RData_files){
  load(paste0(folderpath, "/", file))
  
  SS_masses_allScale <- Output |> 
    unnest(SBoutput) |> 
    mutate(OutputType = names(SBoutput)) |> 
    rename(EmisScale = Scale) |> 
    filter(OutputType == "SteadyStateMass") |> 
    unnest(SBoutput) |> 
    filter(Species != "Unbound") |> 
    ungroup() |> 
    group_by(Polymer, EmisComp, EmisScale, RUN, Scale, SubCompart, Unit) |> 
    summarise(EqMass_SAP = sum(EqMass)) 
  
  SS_masses_continental_pol <- SS_masses_allScale |> 
  filter(EmisScale == "Continental" & (Scale == c("Regional")|Scale == c("Continental"))) |> 
  ungroup() |> 
  group_by(Polymer, EmisComp, EmisScale, RUN, SubCompart, Unit) |> 
  summarise(EqMass_SAP = sum(EqMass_SAP)) |>  # sum nested regional mass and rest of EU mass
  mutate(
    CompartmentFF = case_when(
      SubCompart == "agriculturalsoil" ~ "otherSoil",
      SubCompart == "naturalsoil" ~ "otherSoil",
      #SubCompart == "othersoil" ~ "RoadSoil",
      SubCompart == "othersoil" ~ "otherSoil",
      SubCompart == "cloudwater" ~ "air",
      SubCompart == "lake" ~ "freshwater",
      SubCompart == "river" ~ "freshwater",
      SubCompart == "lakesediment" ~ "freshwatersediment",
      TRUE ~ SubCompart)) |> 
    ungroup() |>
    group_by(Polymer, EmisComp, EmisScale, RUN, CompartmentFF, Unit) |>
    summarise(EqMass_SAP = sum(EqMass_SAP)) |>
    ungroup()
  
  SS_masses_continental <- bind_rows(SS_masses_continental, SS_masses_continental_pol)

  emissions <- Output |> 
    unnest(SBoutput) |> 
    mutate(OutputType = names(SBoutput)) |> 
    rename(EmisScale = Scale) |> 
    filter(OutputType == "Input_Emission") |>
    unnest(SBoutput)
}
```

``` r
SS_masses_clean <- SS_masses_continental |>
  filter(EqMass_SAP > 0)
```

``` r
output_table <- SS_masses_clean |>
  group_by(Polymer,CompartmentFF,EmisComp) |> 
  summarise(FF_SteadyState_avg = mean(EqMass_SAP),
            FF_SteadyState_std = sd(EqMass_SAP),
            FF_SteadyState_p95 = quantile(EqMass_SAP, 0.95),
            FF_SteadyState_p75 = quantile(EqMass_SAP, 0.75),            
            FF_SteadyState_p25 = quantile(EqMass_SAP, 0.25),
            FF_SteadyState_p05 = quantile(EqMass_SAP, 0.05))|>
  mutate(Unit = "kg[ss]/kg[e] seconds")

knitr::kable(output_table)
```

| Polymer | CompartmentFF      | EmisComp | FF_SteadyState_avg | FF_SteadyState_std | FF_SteadyState_p95 | FF_SteadyState_p75 | FF_SteadyState_p25 | FF_SteadyState_p05 | Unit                     |
|:--------|:-------------------|:---------|-------------------:|-------------------:|-------------------:|-------------------:|-------------------:|-------------------:|:-------------------------|
| ABS     | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| ABS     | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| ABS     | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwater         | Air      |       1.089554e+06 |       1.353171e+06 |       3.327963e+06 |       1.119411e+06 |       3.919376e+05 |       2.049300e+05 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwater         | Soil     |       2.243702e+06 |       2.804364e+06 |       6.878661e+06 |       2.300543e+06 |       8.022419e+05 |       4.189930e+05 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwater         | Water    |       1.769350e+06 |       1.775590e+06 |       4.730678e+06 |       1.973525e+06 |       7.882441e+05 |       4.221237e+05 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwatersediment | Air      |       1.317425e+08 |       2.437030e+07 |       1.549139e+08 |       1.472486e+08 |       1.264696e+08 |       9.375343e+07 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwatersediment | Soil     |       2.690975e+08 |       4.977037e+07 |       3.162164e+08 |       3.006940e+08 |       2.586901e+08 |       1.914114e+08 | kg\[ss\]/kg\[e\] seconds |
| ABS     | freshwatersediment | Water    |       2.768399e+08 |       4.333170e+07 |       3.200284e+08 |       3.042127e+08 |       2.640541e+08 |       2.098526e+08 | kg\[ss\]/kg\[e\] seconds |
| ABS     | marinesediment     | Air      |       1.494809e+08 |       7.423110e+07 |       2.556284e+08 |       1.705921e+08 |       9.877803e+07 |       6.351016e+07 | kg\[ss\]/kg\[e\] seconds |
| ABS     | marinesediment     | Soil     |       1.582671e+07 |       4.843560e+06 |       2.263708e+07 |       1.831053e+07 |       1.183849e+07 |       9.605448e+06 | kg\[ss\]/kg\[e\] seconds |
| ABS     | marinesediment     | Water    |       1.600489e+07 |       4.741984e+06 |       2.250427e+07 |       1.866163e+07 |       1.177415e+07 |       1.010686e+07 | kg\[ss\]/kg\[e\] seconds |
| ABS     | otherSoil          | Air      |       1.673579e+07 |       5.003920e+06 |       2.432690e+07 |       2.056374e+07 |       1.377332e+07 |       1.116296e+07 | kg\[ss\]/kg\[e\] seconds |
| ABS     | otherSoil          | Soil     |       3.007722e+07 |       1.055302e+07 |       4.610227e+07 |       3.811800e+07 |       2.388829e+07 |       1.833501e+07 | kg\[ss\]/kg\[e\] seconds |
| ABS     | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| ABS     | sea                | Air      |       1.151639e+07 |       4.467071e+06 |       1.844729e+07 |       1.329316e+07 |       8.486852e+06 |       6.026596e+06 | kg\[ss\]/kg\[e\] seconds |
| ABS     | sea                | Soil     |       2.767294e+06 |       3.830312e+06 |       9.276233e+06 |       2.801678e+06 |       6.662519e+05 |       2.603126e+05 | kg\[ss\]/kg\[e\] seconds |
| ABS     | sea                | Water    |       2.491891e+06 |       3.200727e+06 |       7.968622e+06 |       2.635515e+06 |       6.656522e+05 |       2.612891e+05 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | air                | Soil     |       0.000000e+00 |                 NA |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwater         | Air      |       6.312647e+03 |       4.643070e+03 |       1.422379e+04 |       8.391449e+03 |       3.087745e+03 |       2.256486e+03 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwater         | Soil     |       1.288480e+04 |       9.475899e+03 |       2.903001e+04 |       1.713379e+04 |       6.296681e+03 |       4.613991e+03 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwater         | Water    |       1.342062e+04 |       9.818578e+03 |       3.002765e+04 |       1.816669e+04 |       6.477050e+03 |       4.848032e+03 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwatersediment | Air      |       1.486189e+08 |       1.283059e+07 |       1.652567e+08 |       1.584504e+08 |       1.390536e+08 |       1.309391e+08 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwatersediment | Soil     |       3.036181e+08 |       2.590603e+07 |       3.372419e+08 |       3.234850e+08 |       2.842058e+08 |       2.680078e+08 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | freshwatersediment | Water    |       3.094971e+08 |       2.403747e+07 |       3.398944e+08 |       3.274713e+08 |       2.936356e+08 |       2.746299e+08 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | marinesediment     | Air      |       3.869476e+08 |       7.465118e+07 |       4.944858e+08 |       4.334901e+08 |       3.306288e+08 |       2.903856e+08 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | marinesediment     | Soil     |       5.046417e+05 |       3.854476e+05 |       1.187712e+06 |       5.704626e+05 |       2.947115e+05 |       1.316403e+05 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | marinesediment     | Water    |       5.259504e+05 |       3.988972e+05 |       1.229924e+06 |       6.068071e+05 |       3.076439e+05 |       1.390154e+05 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | otherSoil          | Air      |       1.856937e+07 |       7.615387e+06 |       2.910437e+07 |       2.520116e+07 |       1.213314e+07 |       1.097803e+07 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | otherSoil          | Soil     |       3.396145e+07 |       1.606460e+07 |       5.619259e+07 |       4.792208e+07 |       2.033399e+07 |       1.797327e+07 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | otherSoil          | Water    |       0.000000e+00 |                 NA |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | sea                | Air      |       3.009401e+05 |       2.212604e+05 |       6.853787e+05 |       3.724624e+05 |       1.683838e+05 |       9.249257e+04 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | sea                | Soil     |       5.694600e+02 |       7.617731e+02 |       1.967425e+03 |       6.319165e+02 |       1.079474e+02 |       4.118704e+01 | kg\[ss\]/kg\[e\] seconds |
| Acryl   | sea                | Water    |       5.678118e+02 |       7.563262e+02 |       1.952543e+03 |       6.421345e+02 |       1.065341e+02 |       4.134569e+01 | kg\[ss\]/kg\[e\] seconds |
| EPS     | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| EPS     | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| EPS     | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwater         | Air      |       2.069549e+07 |       2.512750e+06 |       2.426939e+07 |       2.276639e+07 |       1.914940e+07 |       1.797760e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwater         | Soil     |       4.227248e+07 |       5.220410e+06 |       4.940775e+07 |       4.724494e+07 |       3.899331e+07 |       3.669570e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwater         | Water    |       4.183397e+07 |       1.116637e+07 |       5.336645e+07 |       4.736126e+07 |       4.193979e+07 |       2.468345e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwatersediment | Air      |       2.099625e+06 |                 NA |       2.099625e+06 |       2.099625e+06 |       2.099625e+06 |       2.099625e+06 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwatersediment | Soil     |       6.603457e+05 |                 NA |       6.603457e+05 |       6.603457e+05 |       6.603457e+05 |       6.603457e+05 | kg\[ss\]/kg\[e\] seconds |
| EPS     | freshwatersediment | Water    |       1.225095e+08 |                 NA |       1.225095e+08 |       1.225095e+08 |       1.225095e+08 |       1.225095e+08 | kg\[ss\]/kg\[e\] seconds |
| EPS     | marinesediment     | Air      |       3.629177e+07 |                 NA |       3.629177e+07 |       3.629177e+07 |       3.629177e+07 |       3.629177e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | marinesediment     | Soil     |       2.669099e+05 |                 NA |       2.669099e+05 |       2.669099e+05 |       2.669099e+05 |       2.669099e+05 | kg\[ss\]/kg\[e\] seconds |
| EPS     | marinesediment     | Water    |       4.701164e+06 |                 NA |       4.701164e+06 |       4.701164e+06 |       4.701164e+06 |       4.701164e+06 | kg\[ss\]/kg\[e\] seconds |
| EPS     | otherSoil          | Air      |       2.190937e+07 |       1.628908e+07 |       5.015528e+07 |       2.044141e+07 |       1.358473e+07 |       1.119977e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | otherSoil          | Soil     |       4.096527e+07 |       3.432606e+07 |       1.004671e+08 |       3.784501e+07 |       2.338587e+07 |       1.838146e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| EPS     | sea                | Air      |       3.391571e+07 |       3.620633e+06 |       3.980114e+07 |       3.617947e+07 |       3.164003e+07 |       3.080521e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | sea                | Soil     |       3.393763e+07 |       4.086053e+06 |       4.064730e+07 |       3.639243e+07 |       3.137934e+07 |       3.023612e+07 | kg\[ss\]/kg\[e\] seconds |
| EPS     | sea                | Water    |       3.285510e+07 |       4.520549e+06 |       3.998011e+07 |       3.411325e+07 |       3.167470e+07 |       2.740177e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | freshwater         | Air      |       2.126106e+07 |       1.833374e+06 |       2.332684e+07 |       2.259756e+07 |       2.031276e+07 |       1.840330e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | freshwater         | Soil     |       4.336113e+07 |       3.751266e+06 |       4.757945e+07 |       4.609963e+07 |       4.143695e+07 |       3.750782e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | freshwater         | Water    |       4.732700e+07 |       4.096487e+06 |       5.191497e+07 |       5.028342e+07 |       4.490934e+07 |       4.118130e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | otherSoil          | Air      |       1.691634e+07 |       6.211588e+06 |       2.703297e+07 |       1.932244e+07 |       1.204571e+07 |       1.077469e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | otherSoil          | Soil     |       3.051614e+07 |       1.311360e+07 |       5.184077e+07 |       3.562818e+07 |       2.023700e+07 |       1.755149e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | sea                | Air      |       3.377496e+07 |       1.970744e+06 |       3.642440e+07 |       3.501100e+07 |       3.249734e+07 |       3.107703e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | sea                | Soil     |       3.359247e+07 |       2.186595e+06 |       3.647385e+07 |       3.499897e+07 |       3.232111e+07 |       3.047132e+07 | kg\[ss\]/kg\[e\] seconds |
| HDPE    | sea                | Water    |       3.435656e+07 |       2.212648e+06 |       3.726918e+07 |       3.575249e+07 |       3.283473e+07 |       3.139768e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | freshwater         | Air      |       2.156831e+07 |       2.143020e+06 |       2.420169e+07 |       2.273566e+07 |       2.030068e+07 |       1.829277e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | freshwater         | Soil     |       4.396432e+07 |       4.361261e+06 |       4.937015e+07 |       4.630387e+07 |       4.135239e+07 |       3.733057e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | freshwater         | Water    |       4.795351e+07 |       5.013126e+06 |       5.396035e+07 |       5.170391e+07 |       4.444469e+07 |       4.054250e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | otherSoil          | Air      |       1.765016e+07 |       1.232164e+07 |       3.840489e+07 |       1.765403e+07 |       1.051483e+07 |       1.011392e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | otherSoil          | Soil     |       3.204155e+07 |       2.599300e+07 |       7.584149e+07 |       3.207498e+07 |       1.695671e+07 |       1.611061e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | sea                | Air      |       3.463803e+07 |       3.102645e+06 |       3.961793e+07 |       3.601944e+07 |       3.252922e+07 |       3.102960e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | sea                | Soil     |       3.448204e+07 |       3.246980e+06 |       3.970539e+07 |       3.560385e+07 |       3.238001e+07 |       3.057442e+07 | kg\[ss\]/kg\[e\] seconds |
| LDPE    | sea                | Water    |       3.523979e+07 |       3.479744e+06 |       4.063061e+07 |       3.723283e+07 |       3.267778e+07 |       3.117006e+07 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwater         | Air      |       1.100795e+07 |       1.155168e+07 |       2.471091e+07 |       2.105765e+07 |       1.256080e+03 |       1.359810e+02 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwater         | Soil     |       2.242350e+07 |       2.352965e+07 |       5.034326e+07 |       4.287816e+07 |       2.561884e+03 |       2.775852e+02 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwater         | Water    |       2.419046e+07 |       2.549134e+07 |       5.441811e+07 |       4.658860e+07 |       2.639981e+03 |       2.875001e+02 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwatersediment | Air      |       1.518599e+08 |       1.394882e+07 |       1.659971e+08 |       1.641201e+08 |       1.409339e+08 |       1.359622e+08 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwatersediment | Soil     |       3.101245e+08 |       2.822132e+07 |       3.387237e+08 |       3.349379e+08 |       2.876737e+08 |       2.780762e+08 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | freshwatersediment | Water    |       3.141576e+08 |       2.700789e+07 |       3.415793e+08 |       3.379809e+08 |       2.930299e+08 |       2.834324e+08 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | marinesediment     | Air      |       3.652019e+08 |       1.601848e+08 |       5.055188e+08 |       4.847149e+08 |       3.066490e+08 |       1.543733e+08 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | marinesediment     | Soil     |       4.552636e+06 |       9.923102e+06 |       1.792301e+07 |       4.110925e+05 |       1.768062e+04 |       8.942433e+03 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | marinesediment     | Water    |       4.492975e+06 |       9.782428e+06 |       1.767611e+07 |       4.225764e+05 |       1.814861e+04 |       9.296464e+03 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | otherSoil          | Air      |       1.541939e+07 |       4.927958e+06 |       2.246384e+07 |       1.955487e+07 |       1.123004e+07 |       1.083003e+07 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | otherSoil          | Soil     |       2.728261e+07 |       1.037547e+07 |       4.215054e+07 |       3.595426e+07 |       1.845029e+07 |       1.765482e+07 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | sea                | Air      |       1.981686e+07 |       1.897359e+07 |       4.395423e+07 |       3.312057e+07 |       6.739614e+04 |       6.831536e+03 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | sea                | Soil     |       1.864202e+07 |       1.972738e+07 |       4.423732e+07 |       3.304429e+07 |       4.719443e+01 |       2.015370e-01 | kg\[ss\]/kg\[e\] seconds |
| OTHER   | sea                | Water    |       1.885821e+07 |       2.000285e+07 |       4.477734e+07 |       3.357543e+07 |       4.663346e+01 |       1.995187e-01 | kg\[ss\]/kg\[e\] seconds |
| PA      | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PA      | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PA      | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwater         | Air      |       1.447071e+06 |       3.350993e+06 |       6.891866e+06 |       6.265640e+05 |       6.959448e+04 |       2.068699e+04 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwater         | Soil     |       2.995361e+06 |       6.951329e+06 |       1.428810e+07 |       1.281917e+06 |       1.420763e+05 |       4.219440e+04 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwater         | Water    |       1.710295e+06 |       3.355036e+06 |       7.381897e+06 |       1.205421e+06 |       1.494793e+05 |       4.341090e+04 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwatersediment | Air      |       1.321464e+08 |       3.854921e+07 |       1.618943e+08 |       1.547247e+08 |       1.356552e+08 |       6.348442e+07 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwatersediment | Soil     |       2.698066e+08 |       7.906462e+07 |       3.304547e+08 |       3.158446e+08 |       2.774918e+08 |       1.289967e+08 | kg\[ss\]/kg\[e\] seconds |
| PA      | freshwatersediment | Water    |       2.798747e+08 |       6.634155e+07 |       3.334250e+08 |       3.198827e+08 |       2.829817e+08 |       1.615264e+08 | kg\[ss\]/kg\[e\] seconds |
| PA      | marinesediment     | Air      |       2.437100e+08 |       1.380452e+08 |       4.435917e+08 |       3.066419e+08 |       1.548602e+08 |       5.249106e+07 | kg\[ss\]/kg\[e\] seconds |
| PA      | marinesediment     | Soil     |       8.620242e+06 |       6.085979e+06 |       1.835930e+07 |       1.117300e+07 |       3.997815e+06 |       1.904658e+06 | kg\[ss\]/kg\[e\] seconds |
| PA      | marinesediment     | Water    |       8.777857e+06 |       6.099936e+06 |       1.828871e+07 |       1.172846e+07 |       4.241673e+06 |       1.964602e+06 | kg\[ss\]/kg\[e\] seconds |
| PA      | otherSoil          | Air      |       1.693991e+07 |       1.028228e+07 |       3.419125e+07 |       1.680807e+07 |       1.195416e+07 |       1.116861e+07 | kg\[ss\]/kg\[e\] seconds |
| PA      | otherSoil          | Soil     |       3.050501e+07 |       2.167806e+07 |       6.684918e+07 |       3.031049e+07 |       2.001622e+07 |       1.833106e+07 | kg\[ss\]/kg\[e\] seconds |
| PA      | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PA      | sea                | Air      |       8.212896e+06 |       8.503363e+06 |       2.261077e+07 |       1.083740e+07 |       2.646012e+06 |       1.046541e+06 | kg\[ss\]/kg\[e\] seconds |
| PA      | sea                | Soil     |       3.444215e+06 |       8.126838e+06 |       1.690301e+07 |       1.427273e+06 |       3.779259e+04 |       4.519508e+03 | kg\[ss\]/kg\[e\] seconds |
| PA      | sea                | Water    |       2.948783e+06 |       6.805657e+06 |       1.426623e+07 |       1.401205e+06 |       3.816696e+04 |       4.475615e+03 | kg\[ss\]/kg\[e\] seconds |
| PC      | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PC      | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PC      | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwater         | Air      |       4.283825e+05 |       4.991935e+05 |       1.210196e+06 |       8.286137e+05 |       5.549171e+04 |       3.489142e+04 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwater         | Soil     |       8.801717e+05 |       1.027806e+06 |       2.490947e+06 |       1.702606e+06 |       1.132621e+05 |       7.125829e+04 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwater         | Water    |       7.219781e+05 |       7.778306e+05 |       1.884140e+06 |       1.418999e+06 |       1.169996e+05 |       7.397582e+04 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwatersediment | Air      |       1.452746e+08 |       1.207303e+07 |       1.604028e+08 |       1.558391e+08 |       1.342147e+08 |       1.310510e+08 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwatersediment | Soil     |       2.967122e+08 |       2.454475e+07 |       3.274158e+08 |       3.182077e+08 |       2.742109e+08 |       2.677468e+08 | kg\[ss\]/kg\[e\] seconds |
| PC      | freshwatersediment | Water    |       3.022411e+08 |       2.239301e+07 |       3.304803e+08 |       3.215492e+08 |       2.816624e+08 |       2.767224e+08 | kg\[ss\]/kg\[e\] seconds |
| PC      | marinesediment     | Air      |       2.514009e+08 |       1.141486e+08 |       3.768003e+08 |       3.432999e+08 |       1.264067e+08 |       1.114775e+08 | kg\[ss\]/kg\[e\] seconds |
| PC      | marinesediment     | Soil     |       1.060504e+07 |       7.598325e+06 |       2.089358e+07 |       1.768132e+07 |       3.981301e+06 |       2.421963e+06 | kg\[ss\]/kg\[e\] seconds |
| PC      | marinesediment     | Water    |       1.056410e+07 |       7.233535e+06 |       1.987871e+07 |       1.761313e+07 |       4.162847e+06 |       2.532227e+06 | kg\[ss\]/kg\[e\] seconds |
| PC      | otherSoil          | Air      |       1.624043e+07 |       6.754085e+06 |       2.723722e+07 |       1.760390e+07 |       1.169568e+07 |       1.032460e+07 | kg\[ss\]/kg\[e\] seconds |
| PC      | otherSoil          | Soil     |       2.898756e+07 |       1.421053e+07 |       5.211172e+07 |       3.189164e+07 |       1.937944e+07 |       1.649262e+07 | kg\[ss\]/kg\[e\] seconds |
| PC      | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PC      | sea                | Air      |       6.684446e+06 |       5.115150e+06 |       1.372108e+07 |       1.162372e+07 |       2.350897e+06 |       1.485144e+06 | kg\[ss\]/kg\[e\] seconds |
| PC      | sea                | Soil     |       9.866501e+05 |       1.360351e+06 |       3.214547e+06 |       1.899013e+06 |       2.684136e+04 |       1.097156e+04 | kg\[ss\]/kg\[e\] seconds |
| PC      | sea                | Water    |       8.951817e+05 |       1.200594e+06 |       2.822579e+06 |       1.784206e+06 |       2.684374e+04 |       1.095423e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PET     | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwater         | Air      |       5.650308e+05 |       7.714929e+05 |       1.859594e+06 |       7.343088e+05 |       5.766106e+04 |       3.624970e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwater         | Soil     |       1.161233e+06 |       1.590381e+06 |       3.831466e+06 |       1.504008e+06 |       1.175993e+05 |       7.404044e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwater         | Water    |       9.095437e+05 |       1.079378e+06 |       2.681636e+06 |       1.320629e+06 |       1.202540e+05 |       7.684711e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwatersediment | Air      |       1.467244e+08 |       1.420058e+07 |       1.638235e+08 |       1.564078e+08 |       1.342177e+08 |       1.276363e+08 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwatersediment | Soil     |       2.995601e+08 |       2.891792e+07 |       3.343270e+08 |       3.193189e+08 |       2.741705e+08 |       2.605854e+08 | kg\[ss\]/kg\[e\] seconds |
| PET     | freshwatersediment | Water    |       3.053023e+08 |       2.536618e+07 |       3.369652e+08 |       3.225273e+08 |       2.820540e+08 |       2.719435e+08 | kg\[ss\]/kg\[e\] seconds |
| PET     | marinesediment     | Air      |       2.448007e+08 |       1.219912e+08 |       4.141780e+08 |       3.470926e+08 |       1.567287e+08 |       9.585524e+07 | kg\[ss\]/kg\[e\] seconds |
| PET     | marinesediment     | Soil     |       1.207577e+07 |       8.553027e+06 |       2.219154e+07 |       2.042421e+07 |       4.828061e+06 |       2.464399e+06 | kg\[ss\]/kg\[e\] seconds |
| PET     | marinesediment     | Water    |       1.199777e+07 |       8.204369e+06 |       2.142526e+07 |       2.011602e+07 |       5.033514e+06 |       2.577059e+06 | kg\[ss\]/kg\[e\] seconds |
| PET     | otherSoil          | Air      |       1.591194e+07 |       5.511673e+06 |       2.454439e+07 |       1.821975e+07 |       1.214454e+07 |       1.096184e+07 | kg\[ss\]/kg\[e\] seconds |
| PET     | otherSoil          | Soil     |       2.827408e+07 |       1.163925e+07 |       4.654315e+07 |       3.302220e+07 |       2.036432e+07 |       1.783470e+07 | kg\[ss\]/kg\[e\] seconds |
| PET     | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PET     | sea                | Air      |       7.593950e+06 |       5.772111e+06 |       1.540158e+07 |       1.233749e+07 |       2.683276e+06 |       1.524642e+06 | kg\[ss\]/kg\[e\] seconds |
| PET     | sea                | Soil     |       1.418912e+06 |       2.270024e+06 |       5.216657e+06 |       1.807035e+06 |       3.284463e+04 |       1.150388e+04 | kg\[ss\]/kg\[e\] seconds |
| PET     | sea                | Water    |       1.273434e+06 |       1.948539e+06 |       4.528971e+06 |       1.713034e+06 |       3.259534e+04 |       1.148634e+04 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwater         | Air      |       1.275582e+07 |       4.183707e+06 |       1.831925e+07 |       1.556036e+07 |       9.476206e+06 |       7.148937e+06 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwater         | Soil     |       2.652948e+07 |       8.770022e+06 |       3.817743e+07 |       3.245973e+07 |       1.961233e+07 |       1.479819e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwater         | Water    |       1.117592e+07 |       1.976532e+06 |       1.352997e+07 |       1.247123e+07 |       1.024706e+07 |       8.087981e+06 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwatersediment | Air      |       3.425836e+07 |       2.039428e+07 |       6.664672e+07 |       4.697698e+07 |       1.761503e+07 |       1.446186e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwatersediment | Soil     |       6.796851e+07 |       4.224643e+07 |       1.348249e+08 |       9.465918e+07 |       3.372355e+07 |       2.660472e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | freshwatersediment | Water    |       1.341667e+08 |       2.712188e+07 |       1.759104e+08 |       1.506468e+08 |       1.134454e+08 |       1.042419e+08 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | marinesediment     | Air      |       4.881670e+07 |       6.016833e+06 |       5.713656e+07 |       5.309135e+07 |       4.450122e+07 |       4.167163e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | marinesediment     | Soil     |       1.049112e+07 |       3.015895e+06 |       1.465820e+07 |       1.256674e+07 |       7.756905e+06 |       7.311640e+06 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | marinesediment     | Water    |       9.347701e+06 |       2.513462e+06 |       1.297800e+07 |       1.091499e+07 |       6.996201e+06 |       6.786960e+06 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | otherSoil          | Air      |       2.345012e+07 |       1.647184e+07 |       5.061427e+07 |       2.346971e+07 |       1.270788e+07 |       1.050372e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | otherSoil          | Soil     |       4.394152e+07 |       3.471063e+07 |       1.011998e+08 |       4.403738e+07 |       2.136966e+07 |       1.674750e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | sea                | Air      |       2.896657e+07 |       3.585312e+06 |       3.507272e+07 |       2.946416e+07 |       2.703267e+07 |       2.587150e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | sea                | Soil     |       2.692776e+07 |       5.027992e+06 |       3.417157e+07 |       2.978712e+07 |       2.349017e+07 |       2.032242e+07 | kg\[ss\]/kg\[e\] seconds |
| PMMA    | sea                | Water    |       2.036510e+07 |       3.401770e+06 |       2.510321e+07 |       2.221777e+07 |       1.729835e+07 |       1.609333e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PP      | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PP      | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwater         | Air      |       2.155207e+07 |       1.498082e+06 |       2.334028e+07 |       2.269810e+07 |       2.061415e+07 |       1.931997e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwater         | Soil     |       4.417112e+07 |       2.911007e+06 |       4.752132e+07 |       4.627221e+07 |       4.206821e+07 |       3.979916e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwater         | Water    |       3.865368e+07 |       1.588154e+07 |       5.146031e+07 |       4.991021e+07 |       2.655451e+07 |       1.369172e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwatersediment | Air      |       1.780145e+06 |       8.771924e+05 |       2.643442e+06 |       2.104524e+06 |       1.281132e+06 |       1.161337e+06 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwatersediment | Soil     |       7.074703e+05 |       5.780466e+05 |       1.275195e+06 |       9.275226e+05 |       3.801490e+05 |       2.899225e+05 | kg\[ss\]/kg\[e\] seconds |
| PP      | freshwatersediment | Water    |       9.865653e+07 |       4.401383e+07 |       1.420318e+08 |       1.144769e+08 |       7.352452e+07 |       6.831759e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | marinesediment     | Air      |       3.403392e+07 |       1.201507e+07 |       4.465189e+07 |       4.017091e+07 |       2.816481e+07 |       2.304091e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | marinesediment     | Soil     |       3.343740e+05 |       1.801999e+05 |       4.916989e+05 |       4.275413e+05 |       2.476919e+05 |       1.679699e+05 | kg\[ss\]/kg\[e\] seconds |
| PP      | marinesediment     | Water    |       2.589930e+06 |       1.751172e+06 |       4.311606e+06 |       3.111338e+06 |       1.579058e+06 |       1.553504e+06 | kg\[ss\]/kg\[e\] seconds |
| PP      | otherSoil          | Air      |       2.524623e+07 |       2.631999e+07 |       6.783674e+07 |       2.347817e+07 |       1.271064e+07 |       1.109020e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | otherSoil          | Soil     |       4.796630e+07 |       5.539927e+07 |       1.375978e+08 |       4.425715e+07 |       2.161567e+07 |       1.816607e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PP      | sea                | Air      |       3.372359e+07 |       1.797088e+06 |       3.617509e+07 |       3.498456e+07 |       3.264694e+07 |       3.128824e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | sea                | Soil     |       3.408111e+07 |       1.699993e+06 |       3.630972e+07 |       3.528449e+07 |       3.270623e+07 |       3.176989e+07 | kg\[ss\]/kg\[e\] seconds |
| PP      | sea                | Water    |       3.157942e+07 |       5.669175e+06 |       3.682017e+07 |       3.549773e+07 |       2.893437e+07 |       2.207977e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PS      | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PS      | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwater         | Air      |       1.540740e+07 |       2.432241e+06 |       1.875716e+07 |       1.682702e+07 |       1.432875e+07 |       1.186030e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwater         | Soil     |       3.208901e+07 |       5.102951e+06 |       3.911427e+07 |       3.513337e+07 |       2.974849e+07 |       2.470056e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwater         | Water    |       1.222507e+07 |       1.537768e+06 |       1.413300e+07 |       1.326394e+07 |       1.136126e+07 |       9.987200e+06 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwatersediment | Air      |       1.759568e+07 |       5.805570e+06 |       2.521496e+07 |       2.107910e+07 |       1.224017e+07 |       1.110528e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwatersediment | Soil     |       3.397872e+07 |       1.200343e+07 |       4.987687e+07 |       4.105234e+07 |       2.296321e+07 |       2.066981e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | freshwatersediment | Water    |       9.895267e+07 |       1.027594e+07 |       1.125405e+08 |       1.059836e+08 |       8.965094e+07 |       8.644081e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | marinesediment     | Air      |       4.424552e+07 |       4.654117e+06 |       5.108691e+07 |       4.594427e+07 |       4.116466e+07 |       3.916232e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | marinesediment     | Soil     |       5.709702e+06 |       1.421897e+06 |       7.864982e+06 |       6.028267e+06 |       4.902501e+06 |       3.789966e+06 | kg\[ss\]/kg\[e\] seconds |
| PS      | marinesediment     | Water    |       5.498744e+06 |       1.101636e+06 |       7.139097e+06 |       5.798879e+06 |       5.125055e+06 |       3.922625e+06 | kg\[ss\]/kg\[e\] seconds |
| PS      | otherSoil          | Air      |       1.782544e+07 |       5.102754e+06 |       2.546815e+07 |       1.893464e+07 |       1.441932e+07 |       1.227427e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | otherSoil          | Soil     |       3.226944e+07 |       1.076902e+07 |       4.837019e+07 |       3.454803e+07 |       2.503945e+07 |       2.052752e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PS      | sea                | Air      |       3.177532e+07 |       4.239553e+06 |       3.902720e+07 |       3.303014e+07 |       2.936825e+07 |       2.751197e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | sea                | Soil     |       3.174009e+07 |       4.844158e+06 |       3.983516e+07 |       3.369501e+07 |       2.959273e+07 |       2.648888e+07 | kg\[ss\]/kg\[e\] seconds |
| PS      | sea                | Water    |       2.492303e+07 |       3.297723e+06 |       3.032415e+07 |       2.603329e+07 |       2.357129e+07 |       2.092155e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PUR     | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PUR     | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PUR     | freshwater         | Air      |       2.165783e+07 |       1.424083e+06 |       2.381814e+07 |       2.233454e+07 |       2.101865e+07 |       1.980940e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | freshwater         | Soil     |       4.409810e+07 |       2.900733e+06 |       4.852882e+07 |       4.544042e+07 |       4.272933e+07 |       4.038179e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | freshwater         | Water    |       4.926613e+07 |       4.014956e+06 |       5.458114e+07 |       5.279536e+07 |       4.690415e+07 |       4.398875e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | freshwatersediment | Soil     |       0.000000e+00 |                 NA |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PUR     | otherSoil          | Air      |       3.920148e+07 |       4.217420e+07 |       1.186338e+08 |       2.557723e+07 |       1.784633e+07 |       1.418867e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | otherSoil          | Soil     |       7.742572e+07 |       8.884122e+07 |       2.447826e+08 |       4.870883e+07 |       3.242321e+07 |       2.469791e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PUR     | sea                | Air      |       3.514078e+07 |       3.017114e+06 |       4.033307e+07 |       3.603318e+07 |       3.330570e+07 |       3.212223e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | sea                | Soil     |       3.458598e+07 |       2.805477e+06 |       3.938519e+07 |       3.533782e+07 |       3.319575e+07 |       3.180398e+07 | kg\[ss\]/kg\[e\] seconds |
| PUR     | sea                | Water    |       3.623189e+07 |       3.860263e+06 |       4.246368e+07 |       3.873444e+07 |       3.372514e+07 |       3.247551e+07 | kg\[ss\]/kg\[e\] seconds |
| PVC     | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| PVC     | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PVC     | air                | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwater         | Air      |       7.645091e+05 |       9.576415e+05 |       2.386456e+06 |       1.014572e+06 |       1.856863e+05 |       1.217183e+05 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwater         | Soil     |       1.575887e+06 |       1.981081e+06 |       4.934495e+06 |       2.084790e+06 |       3.797943e+05 |       2.485701e+05 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwater         | Water    |       1.131716e+06 |       1.138824e+06 |       2.977888e+06 |       1.711433e+06 |       3.814979e+05 |       2.525403e+05 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwatersediment | Air      |       1.347432e+08 |       1.829335e+07 |       1.602245e+08 |       1.452969e+08 |       1.232564e+08 |       1.092475e+08 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwatersediment | Soil     |       2.751714e+08 |       3.744863e+07 |       3.270348e+08 |       2.969282e+08 |       2.520883e+08 |       2.225447e+08 | kg\[ss\]/kg\[e\] seconds |
| PVC     | freshwatersediment | Water    |       2.858511e+08 |       2.873083e+07 |       3.295084e+08 |       3.016195e+08 |       2.646505e+08 |       2.515699e+08 | kg\[ss\]/kg\[e\] seconds |
| PVC     | marinesediment     | Air      |       1.904739e+08 |       8.930427e+07 |       3.051440e+08 |       2.728034e+08 |       1.117064e+08 |       8.454696e+07 | kg\[ss\]/kg\[e\] seconds |
| PVC     | marinesediment     | Soil     |       1.294145e+07 |       5.579026e+06 |       2.095018e+07 |       1.714241e+07 |       8.295770e+06 |       7.108554e+06 | kg\[ss\]/kg\[e\] seconds |
| PVC     | marinesediment     | Water    |       1.261912e+07 |       4.645426e+06 |       1.912518e+07 |       1.629747e+07 |       8.662228e+06 |       7.561075e+06 | kg\[ss\]/kg\[e\] seconds |
| PVC     | otherSoil          | Air      |       2.071277e+07 |       1.289617e+07 |       4.249963e+07 |       2.661887e+07 |       1.158278e+07 |       1.038979e+07 | kg\[ss\]/kg\[e\] seconds |
| PVC     | otherSoil          | Soil     |       3.842550e+07 |       2.718258e+07 |       8.425592e+07 |       5.102776e+07 |       1.919936e+07 |       1.660409e+07 | kg\[ss\]/kg\[e\] seconds |
| PVC     | otherSoil          | Water    |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| PVC     | sea                | Air      |       9.165342e+06 |       5.036225e+06 |       1.672126e+07 |       1.287631e+07 |       5.432215e+06 |       4.379188e+06 | kg\[ss\]/kg\[e\] seconds |
| PVC     | sea                | Soil     |       1.935601e+06 |       2.956581e+06 |       6.948405e+06 |       2.501692e+06 |       2.006750e+05 |       1.081329e+05 | kg\[ss\]/kg\[e\] seconds |
| PVC     | sea                | Water    |       1.585239e+06 |       2.251053e+06 |       5.308959e+06 |       2.319894e+06 |       2.019544e+05 |       1.078837e+05 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | air                | Air      |       2.613890e+04 |       0.000000e+00 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 |       2.613890e+04 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | air                | Soil     |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 |       0.000000e+00 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwater         | Air      |       1.182569e+04 |       3.466073e+04 |       6.313336e+04 |       1.463119e+03 |       2.501283e+01 |       1.665401e+01 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwater         | Soil     |       2.418318e+04 |       7.088914e+04 |       1.291141e+05 |       2.984263e+03 |       5.101191e+01 |       3.401325e+01 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwater         | Water    |       2.502319e+04 |       7.330679e+04 |       1.335896e+05 |       3.076867e+03 |       5.253887e+01 |       3.554398e+01 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwatersediment | Air      |       1.504943e+08 |       1.302690e+07 |       1.637897e+08 |       1.615948e+08 |       1.422532e+08 |       1.302422e+08 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwatersediment | Soil     |       3.074367e+08 |       2.630305e+07 |       3.342811e+08 |       3.298601e+08 |       2.907839e+08 |       2.665552e+08 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | freshwatersediment | Water    |       3.122607e+08 |       2.455100e+07 |       3.371901e+08 |       3.328826e+08 |       2.972871e+08 |       2.737074e+08 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | marinesediment     | Air      |       3.963976e+08 |       8.783591e+07 |       4.878124e+08 |       4.678756e+08 |       3.458785e+08 |       2.576200e+08 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | marinesediment     | Soil     |       5.821890e+05 |       1.632427e+06 |       3.036262e+06 |       1.415001e+05 |       2.404395e+03 |       1.239331e+03 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | marinesediment     | Water    |       6.157765e+05 |       1.729533e+06 |       3.215020e+06 |       1.457131e+05 |       2.483012e+03 |       1.293796e+03 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | otherSoil          | Air      |       1.518948e+07 |       4.409518e+06 |       2.167362e+07 |       1.759460e+07 |       1.202719e+07 |       1.060612e+07 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | otherSoil          | Soil     |       2.682952e+07 |       9.302619e+06 |       4.050532e+07 |       3.187689e+07 |       2.019709e+07 |       1.713033e+07 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | sea                | Air      |       3.967674e+05 |       1.126827e+06 |       2.086143e+06 |       7.831799e+04 |       1.369877e+03 |       7.845155e+02 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | sea                | Soil     |       7.828775e+03 |       2.465244e+04 |       4.301159e+04 |       2.696310e+01 |       7.245500e-03 |       2.608400e-03 | kg\[ss\]/kg\[e\] seconds |
| RUBBER  | sea                | Water    |       7.886643e+03 |       2.483534e+04 |       4.333002e+04 |       2.664834e+01 |       7.154000e-03 |       2.604400e-03 | kg\[ss\]/kg\[e\] seconds |

``` r
for(pol in unique(SS_masses_clean$Polymer)){
  plot_data <- SS_masses_clean |>
    filter(Polymer == pol) |>
    filter(EqMass_SAP > 10e-25) |>
    filter(!is.na(EqMass_SAP)) |>
    filter(EqMass_SAP != 0)
  
  plot <- ggplot(plot_data, aes(y=EqMass_SAP, x=CompartmentFF))+
    geom_violin()+
      scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
    facet_wrap(~EmisComp) +
  theme_bw() +
  labs(title = pol,
       x = "Compartment",
       y = "Steady state mass (kg)")
  
  print(plot)
  
   for(emiscomp in unique(plot_data$EmisComp)){
    plot_data_emiscomp <- plot_data |>
      filter(EmisComp == emiscomp)
  }
}
```

![](Recipe_analysis_files/figure-gfm/Make%20figures-1.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-2.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-3.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-4.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-5.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-6.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-7.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-8.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-9.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-10.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-11.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-12.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-13.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-14.png)<!-- -->![](Recipe_analysis_files/figure-gfm/Make%20figures-15.png)<!-- -->
