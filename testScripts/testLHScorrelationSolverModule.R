source('baseScripts/initWorld_onlyPlastics.R')

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

# Call the steady state solver
World$NewSolver("SteadyStateSolver")

# Solve 
World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)), correlations = Correlations)

variable_values <- World$VariableValues()
print(head(vars))

# Plot correlation matrix to check
library(corrplot)

variable_values <- variable_values |>
  #filter(is.na(SubCompart) | SubCompart == "naturalsoil" | SubCompart == "sea" | SubCompart == "freshwatersediment") |>
  filter(is.na(Species) | Species == "Solid") |>
  mutate(varname = paste0(varName, "_", Scale, "_", SubCompart, "_", Species)) |>
  select(varname, Waarde,RUNs) |>
  pivot_wider(names_from = varname, values_from = Waarde) |>
  select(-RUNs)

transformed_lhs <- as.matrix(variable_values)

result_corr_matrix <- cor(transformed_lhs) # correlation matrix

# Compare actual vs. desired correlations
Correlations$actual_correlation <- NA
for (i in seq_len(nrow(Correlations))) {
  var_1 <- Correlations$varName_1[i]
  var_2 <- Correlations$varName_2[i]
  
  # Get corresponding columns
  col_1 <- which(colnames(transformed_lhs) == var_1)
  col_2 <- which(colnames(transformed_lhs) == var_2)
  
  if (length(col_1) > 0 & length(col_2) > 0) {
    Correlations$actual_correlation[i] <- result_corr_matrix[col_1, col_2]
  }
}

# Print the desired vs. actual correlations
print(Correlations)

### Step 6: Visualize Results
# Scatter plots of selected pairs for visual inspection
pairs(transformed_lhs, main = "Scatter Plots of Variables")

# Full correlation matrix heatmap
library(reshape2)
library(ggplot2)

melted_corr_matrix <- melt(result_corr_matrix)
ggplot(melted_corr_matrix, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0,
                       limit = c(-1, 1), name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  ggtitle("Correlation Matrix Heatmap")

