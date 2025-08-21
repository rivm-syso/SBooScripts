LHS correlation
================
Anne Hids
2025-06-18

## Initialize World

``` r
source('baseScripts/initWorld_onlyPlastics.R')
```

## Load data

``` r
# Load the Excel file containing example distributions for variables
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Variable_data")
Correlations <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Correlation")

# Define functions for each row based on the distribution type
varFuns <- World$makeInvFuns(Example_vars)

load("data/Examples/example_uncertain_data.RData")

example_data <- example_data |>
  select(To_Compartment, `2023`, RUN) |>
  rename("Emis" = `2023`) |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-To_Compartment) 
```

## Explanation correlations

Important for using the LHS correlations is providing a correlation
table. This table specifies which variables are correlated, and how
strong the correlation is. The table should have this structure:

``` r
knitr::kable(Correlations)
```

| varName_1 | varName_2 | SubCompart_1 | SubCompart_2 | Species_1 | Species_2 | Scale_1 | Scale_2 | correlation |
|:---|:---|:---|:---|:---|:---|:---|:---|---:|
| kdeg | kdeg | Water | Sediment | NA | NA | NA | NA | 0.85 |
| kdeg | kdeg | Sediment | Soil | NA | NA | NA | NA | 0.85 |
| kdeg | kdeg | Soil | Water | NA | NA | NA | NA | 0.85 |
| alpha | alpha | Water | SoilSediment | Small | Small | NA | NA | 0.90 |
| alpha | alpha | SoilSediment | Water | Small | Small | NA | NA | 0.90 |
| alpha | alpha | Water | SoilSediment | Large | Large | NA | NA | 0.90 |
| alpha | alpha | SoilSediment | Water | Large | Large | NA | NA | 0.90 |
| alpha | alpha | Water | Water | Small | Large | NA | NA | 1.00 |
| alpha | alpha | SoilSediment | SoilSediment | Small | Large | NA | NA | 1.00 |
| alpha | alpha | Water | Water | Large | Small | NA | NA | 1.00 |
| alpha | alpha | SoilSediment | SoilSediment | Large | Small | NA | NA | 1.00 |

When entries in a column are NA, the same correlation is used for all
possible values of that column. In this example, Species and Scale is
NA. This means that the correlation is used for all species (Unbound,
Solid, Aggregated, Attached) and all scales (Regional, Continental,
Arctic, Moderate, Tropic).

Another possibility is to give a correlation for a compartment instead
of a subcompartment. The compartments are:

- Soil

- Water

- Sediment

- Soil_Sediment.

If any of these compartments is chosen, the correlation is used for all
corresponding subcompartments. For example, if Water is entered, the
correlation is used for river, lake, sea and deepocean.

| Compartment | SubCompartments |
|----|----|
| Soil | agriculturalsoil, naturalsoil, othersoil |
| Water | river, lake, sea, deepocean |
| Sediment | freshwatersediment, lakesediment, marinesediment |
| Soil_Sediment | agriculturalsoil, naturalsoil, othersoil, freshwatersediment, lakesediment, marinesediment |

Compartments and corresponding subcompartments

## Solve using correlations

``` r
# Call the steady state solver
World$NewSolver("SteadyStateSolver")

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)), correlations = Correlations)
```

## Plot the correlations

The heatmap below shows that the correlation worked! The variables we
specified in the correlation table are indeed strongly correlated to
each other.

``` r
# Plot correlation matrix to check
library(corrplot)

variable_values <- World$VariableValues() |>
  mutate(varname = paste0(varName, "_", Scale, "_", SubCompart, "_", Species)) |>
  select(varname, Waarde,RUNs) |>
  pivot_wider(names_from = varname, values_from = Waarde)

transformed_lhs <- as.matrix(variable_values)

result_corr_matrix <- cor(transformed_lhs[,-1], 
                          method = "pearson") # correlation matrix

# Visualize Results

# Full correlation matrix heatmap
library(reshape2)
library(ggplot2)

melted_corr_matrix <- melt(result_corr_matrix)

# Calculate and print the mean correlations 
mean_correlations <- melted_corr_matrix |>
  separate(
    Var1, 
    into = c("VarName1", "Scale1", "SubCompart1", "Species1"), 
    sep = "_") |>
    separate(
    Var2, 
    into = c("VarName2", "Scale2", "SubCompart2", "Species2"), 
    sep = "_") |>
  mutate(Compartment1 = case_when(
    str_detect(SubCompart1, "soil") ~ "Soil",
    str_detect(SubCompart1, "sediment") ~ "Sediment",
    SubCompart1 %in% c("air", "cloudwater") ~ "Air", 
    str_detect(SubCompart1, "NA") ~ "NA",
    TRUE ~ "Water"
  )) |>
    mutate(Compartment2 = case_when(
    str_detect(SubCompart2, "soil") ~ "Soil",
    str_detect(SubCompart2, "sediment") ~ "Sediment",
    SubCompart2 %in% c("air", "cloudwater") ~ "Air", 
    str_detect(SubCompart2, "NA") ~ "NA",
    TRUE ~ "Water"
  )) |>
  group_by(VarName1, VarName2, Compartment1, Compartment2, Species1, Species2) |>
  summarise(Mean_correlation = mean(value))

knitr::kable(mean_correlations)
```

| VarName1 | VarName2 | Compartment1 | Compartment2 | Species1 | Species2 | Mean_correlation |
|:---------|:---------|:-------------|:-------------|:---------|:---------|-----------------:|
| RadS     | RadS     | NA           | NA           | NA       | NA       |        1.0000000 |
| RadS     | alpha    | NA           | Sediment     | NA       | Large    |       -0.2408724 |
| RadS     | alpha    | NA           | Sediment     | NA       | Small    |       -0.2429453 |
| RadS     | alpha    | NA           | Soil         | NA       | Large    |       -0.2408724 |
| RadS     | alpha    | NA           | Soil         | NA       | Small    |       -0.2429453 |
| RadS     | alpha    | NA           | Water        | NA       | Large    |       -0.2247911 |
| RadS     | alpha    | NA           | Water        | NA       | Small    |       -0.2674230 |
| RadS     | kdeg     | NA           | Soil         | NA       | Large    |        0.4305709 |
| RadS     | kdeg     | NA           | Soil         | NA       | Small    |        0.4305709 |
| RadS     | kdeg     | NA           | Soil         | NA       | Solid    |        0.4305709 |
| RadS     | kdeg     | NA           | Soil         | NA       | Unbound  |        0.4305709 |
| RadS     | kdeg     | NA           | Water        | NA       | Large    |        0.2651279 |
| RadS     | kdeg     | NA           | Water        | NA       | Small    |        0.2651279 |
| RadS     | kdeg     | NA           | Water        | NA       | Solid    |        0.2651279 |
| RadS     | kdeg     | NA           | Water        | NA       | Unbound  |        0.2651279 |
| alpha    | RadS     | Sediment     | NA           | Large    | NA       |       -0.2408724 |
| alpha    | RadS     | Sediment     | NA           | Small    | NA       |       -0.2429453 |
| alpha    | RadS     | Soil         | NA           | Large    | NA       |       -0.2408724 |
| alpha    | RadS     | Soil         | NA           | Small    | NA       |       -0.2429453 |
| alpha    | RadS     | Water        | NA           | Large    | NA       |       -0.2247911 |
| alpha    | RadS     | Water        | NA           | Small    | NA       |       -0.2674230 |
| alpha    | alpha    | Sediment     | Sediment     | Large    | Large    |        1.0000000 |
| alpha    | alpha    | Sediment     | Sediment     | Large    | Small    |        0.9987015 |
| alpha    | alpha    | Sediment     | Sediment     | Small    | Large    |        0.9987015 |
| alpha    | alpha    | Sediment     | Sediment     | Small    | Small    |        1.0000000 |
| alpha    | alpha    | Sediment     | Soil         | Large    | Large    |        1.0000000 |
| alpha    | alpha    | Sediment     | Soil         | Large    | Small    |        0.9987015 |
| alpha    | alpha    | Sediment     | Soil         | Small    | Large    |        0.9987015 |
| alpha    | alpha    | Sediment     | Soil         | Small    | Small    |        1.0000000 |
| alpha    | alpha    | Sediment     | Water        | Large    | Large    |        0.9004337 |
| alpha    | alpha    | Sediment     | Water        | Large    | Small    |        0.8984099 |
| alpha    | alpha    | Sediment     | Water        | Small    | Large    |        0.8996597 |
| alpha    | alpha    | Sediment     | Water        | Small    | Small    |        0.8992568 |
| alpha    | alpha    | Soil         | Sediment     | Large    | Large    |        1.0000000 |
| alpha    | alpha    | Soil         | Sediment     | Large    | Small    |        0.9987015 |
| alpha    | alpha    | Soil         | Sediment     | Small    | Large    |        0.9987015 |
| alpha    | alpha    | Soil         | Sediment     | Small    | Small    |        1.0000000 |
| alpha    | alpha    | Soil         | Soil         | Large    | Large    |        1.0000000 |
| alpha    | alpha    | Soil         | Soil         | Large    | Small    |        0.9987015 |
| alpha    | alpha    | Soil         | Soil         | Small    | Large    |        0.9987015 |
| alpha    | alpha    | Soil         | Soil         | Small    | Small    |        1.0000000 |
| alpha    | alpha    | Soil         | Water        | Large    | Large    |        0.9004337 |
| alpha    | alpha    | Soil         | Water        | Large    | Small    |        0.8984099 |
| alpha    | alpha    | Soil         | Water        | Small    | Large    |        0.8996597 |
| alpha    | alpha    | Soil         | Water        | Small    | Small    |        0.8992568 |
| alpha    | alpha    | Water        | Sediment     | Large    | Large    |        0.9004337 |
| alpha    | alpha    | Water        | Sediment     | Large    | Small    |        0.8996597 |
| alpha    | alpha    | Water        | Sediment     | Small    | Large    |        0.8984099 |
| alpha    | alpha    | Water        | Sediment     | Small    | Small    |        0.8992568 |
| alpha    | alpha    | Water        | Soil         | Large    | Large    |        0.9004337 |
| alpha    | alpha    | Water        | Soil         | Large    | Small    |        0.8996597 |
| alpha    | alpha    | Water        | Soil         | Small    | Large    |        0.8984099 |
| alpha    | alpha    | Water        | Soil         | Small    | Small    |        0.8992568 |
| alpha    | alpha    | Water        | Water        | Large    | Large    |        1.0000000 |
| alpha    | alpha    | Water        | Water        | Large    | Small    |        0.9958421 |
| alpha    | alpha    | Water        | Water        | Small    | Large    |        0.9958421 |
| alpha    | alpha    | Water        | Water        | Small    | Small    |        1.0000000 |
| alpha    | kdeg     | Sediment     | Soil         | Large    | Large    |       -0.3273685 |
| alpha    | kdeg     | Sediment     | Soil         | Large    | Small    |       -0.3273685 |
| alpha    | kdeg     | Sediment     | Soil         | Large    | Solid    |       -0.3273685 |
| alpha    | kdeg     | Sediment     | Soil         | Large    | Unbound  |       -0.3273685 |
| alpha    | kdeg     | Sediment     | Soil         | Small    | Large    |       -0.3358947 |
| alpha    | kdeg     | Sediment     | Soil         | Small    | Small    |       -0.3358947 |
| alpha    | kdeg     | Sediment     | Soil         | Small    | Solid    |       -0.3358947 |
| alpha    | kdeg     | Sediment     | Soil         | Small    | Unbound  |       -0.3358947 |
| alpha    | kdeg     | Sediment     | Water        | Large    | Large    |       -0.1019944 |
| alpha    | kdeg     | Sediment     | Water        | Large    | Small    |       -0.1019944 |
| alpha    | kdeg     | Sediment     | Water        | Large    | Solid    |       -0.1019944 |
| alpha    | kdeg     | Sediment     | Water        | Large    | Unbound  |       -0.1019944 |
| alpha    | kdeg     | Sediment     | Water        | Small    | Large    |       -0.1092134 |
| alpha    | kdeg     | Sediment     | Water        | Small    | Small    |       -0.1092134 |
| alpha    | kdeg     | Sediment     | Water        | Small    | Solid    |       -0.1092134 |
| alpha    | kdeg     | Sediment     | Water        | Small    | Unbound  |       -0.1092134 |
| alpha    | kdeg     | Soil         | Soil         | Large    | Large    |       -0.3273685 |
| alpha    | kdeg     | Soil         | Soil         | Large    | Small    |       -0.3273685 |
| alpha    | kdeg     | Soil         | Soil         | Large    | Solid    |       -0.3273685 |
| alpha    | kdeg     | Soil         | Soil         | Large    | Unbound  |       -0.3273685 |
| alpha    | kdeg     | Soil         | Soil         | Small    | Large    |       -0.3358947 |
| alpha    | kdeg     | Soil         | Soil         | Small    | Small    |       -0.3358947 |
| alpha    | kdeg     | Soil         | Soil         | Small    | Solid    |       -0.3358947 |
| alpha    | kdeg     | Soil         | Soil         | Small    | Unbound  |       -0.3358947 |
| alpha    | kdeg     | Soil         | Water        | Large    | Large    |       -0.1019944 |
| alpha    | kdeg     | Soil         | Water        | Large    | Small    |       -0.1019944 |
| alpha    | kdeg     | Soil         | Water        | Large    | Solid    |       -0.1019944 |
| alpha    | kdeg     | Soil         | Water        | Large    | Unbound  |       -0.1019944 |
| alpha    | kdeg     | Soil         | Water        | Small    | Large    |       -0.1092134 |
| alpha    | kdeg     | Soil         | Water        | Small    | Small    |       -0.1092134 |
| alpha    | kdeg     | Soil         | Water        | Small    | Solid    |       -0.1092134 |
| alpha    | kdeg     | Soil         | Water        | Small    | Unbound  |       -0.1092134 |
| alpha    | kdeg     | Water        | Soil         | Large    | Large    |       -0.2160745 |
| alpha    | kdeg     | Water        | Soil         | Large    | Small    |       -0.2160745 |
| alpha    | kdeg     | Water        | Soil         | Large    | Solid    |       -0.2160745 |
| alpha    | kdeg     | Water        | Soil         | Large    | Unbound  |       -0.2160745 |
| alpha    | kdeg     | Water        | Soil         | Small    | Large    |       -0.2212863 |
| alpha    | kdeg     | Water        | Soil         | Small    | Small    |       -0.2212863 |
| alpha    | kdeg     | Water        | Soil         | Small    | Solid    |       -0.2212863 |
| alpha    | kdeg     | Water        | Soil         | Small    | Unbound  |       -0.2212863 |
| alpha    | kdeg     | Water        | Water        | Large    | Large    |       -0.1248605 |
| alpha    | kdeg     | Water        | Water        | Large    | Small    |       -0.1248605 |
| alpha    | kdeg     | Water        | Water        | Large    | Solid    |       -0.1248605 |
| alpha    | kdeg     | Water        | Water        | Large    | Unbound  |       -0.1248605 |
| alpha    | kdeg     | Water        | Water        | Small    | Large    |       -0.1200155 |
| alpha    | kdeg     | Water        | Water        | Small    | Small    |       -0.1200155 |
| alpha    | kdeg     | Water        | Water        | Small    | Solid    |       -0.1200155 |
| alpha    | kdeg     | Water        | Water        | Small    | Unbound  |       -0.1200155 |
| kdeg     | RadS     | Soil         | NA           | Large    | NA       |        0.4305709 |
| kdeg     | RadS     | Soil         | NA           | Small    | NA       |        0.4305709 |
| kdeg     | RadS     | Soil         | NA           | Solid    | NA       |        0.4305709 |
| kdeg     | RadS     | Soil         | NA           | Unbound  | NA       |        0.4305709 |
| kdeg     | RadS     | Water        | NA           | Large    | NA       |        0.2651279 |
| kdeg     | RadS     | Water        | NA           | Small    | NA       |        0.2651279 |
| kdeg     | RadS     | Water        | NA           | Solid    | NA       |        0.2651279 |
| kdeg     | RadS     | Water        | NA           | Unbound  | NA       |        0.2651279 |
| kdeg     | alpha    | Soil         | Sediment     | Large    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Sediment     | Large    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Sediment     | Small    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Sediment     | Small    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Sediment     | Solid    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Sediment     | Solid    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Sediment     | Unbound  | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Sediment     | Unbound  | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Soil         | Large    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Soil         | Large    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Soil         | Small    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Soil         | Small    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Soil         | Solid    | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Soil         | Solid    | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Soil         | Unbound  | Large    |       -0.3273685 |
| kdeg     | alpha    | Soil         | Soil         | Unbound  | Small    |       -0.3358947 |
| kdeg     | alpha    | Soil         | Water        | Large    | Large    |       -0.2160745 |
| kdeg     | alpha    | Soil         | Water        | Large    | Small    |       -0.2212863 |
| kdeg     | alpha    | Soil         | Water        | Small    | Large    |       -0.2160745 |
| kdeg     | alpha    | Soil         | Water        | Small    | Small    |       -0.2212863 |
| kdeg     | alpha    | Soil         | Water        | Solid    | Large    |       -0.2160745 |
| kdeg     | alpha    | Soil         | Water        | Solid    | Small    |       -0.2212863 |
| kdeg     | alpha    | Soil         | Water        | Unbound  | Large    |       -0.2160745 |
| kdeg     | alpha    | Soil         | Water        | Unbound  | Small    |       -0.2212863 |
| kdeg     | alpha    | Water        | Sediment     | Large    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Sediment     | Large    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Sediment     | Small    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Sediment     | Small    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Sediment     | Solid    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Sediment     | Solid    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Sediment     | Unbound  | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Sediment     | Unbound  | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Soil         | Large    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Soil         | Large    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Soil         | Small    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Soil         | Small    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Soil         | Solid    | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Soil         | Solid    | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Soil         | Unbound  | Large    |       -0.1019944 |
| kdeg     | alpha    | Water        | Soil         | Unbound  | Small    |       -0.1092134 |
| kdeg     | alpha    | Water        | Water        | Large    | Large    |       -0.1248605 |
| kdeg     | alpha    | Water        | Water        | Large    | Small    |       -0.1200155 |
| kdeg     | alpha    | Water        | Water        | Small    | Large    |       -0.1248605 |
| kdeg     | alpha    | Water        | Water        | Small    | Small    |       -0.1200155 |
| kdeg     | alpha    | Water        | Water        | Solid    | Large    |       -0.1248605 |
| kdeg     | alpha    | Water        | Water        | Solid    | Small    |       -0.1200155 |
| kdeg     | alpha    | Water        | Water        | Unbound  | Large    |       -0.1248605 |
| kdeg     | alpha    | Water        | Water        | Unbound  | Small    |       -0.1200155 |
| kdeg     | kdeg     | Soil         | Soil         | Large    | Large    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Large    | Small    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Large    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Large    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Small    | Large    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Small    | Small    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Small    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Small    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Solid    | Large    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Solid    | Small    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Solid    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Solid    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Unbound  | Large    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Unbound  | Small    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Unbound  | Solid    |        1.0000000 |
| kdeg     | kdeg     | Soil         | Soil         | Unbound  | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Soil         | Water        | Large    | Large    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Large    | Small    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Large    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Large    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Small    | Large    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Small    | Small    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Small    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Small    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Solid    | Large    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Solid    | Small    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Solid    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Solid    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Unbound  | Large    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Unbound  | Small    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Unbound  | Solid    |        0.8490979 |
| kdeg     | kdeg     | Soil         | Water        | Unbound  | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Large    | Large    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Large    | Small    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Large    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Large    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Small    | Large    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Small    | Small    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Small    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Small    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Solid    | Large    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Solid    | Small    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Solid    | Solid    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Solid    | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Unbound  | Large    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Unbound  | Small    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Unbound  | Solid    |        0.8490979 |
| kdeg     | kdeg     | Water        | Soil         | Unbound  | Unbound  |        0.8490979 |
| kdeg     | kdeg     | Water        | Water        | Large    | Large    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Large    | Small    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Large    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Large    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Small    | Large    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Small    | Small    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Small    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Small    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Solid    | Large    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Solid    | Small    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Solid    | Solid    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Solid    | Unbound  |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Unbound  | Large    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Unbound  | Small    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Unbound  | Solid    |        1.0000000 |
| kdeg     | kdeg     | Water        | Water        | Unbound  | Unbound  |        1.0000000 |

``` r
ggplot(melted_corr_matrix, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0,
                       limit = c(-1, 1), name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  ggtitle("Correlation Matrix Heatmap")
```

![](LHS_correlation_files/figure-gfm/Plot-1.png)<!-- -->
