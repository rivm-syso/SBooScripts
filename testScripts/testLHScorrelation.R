source('baseScripts/initWorld_onlyPlastics.R')

load("data/Examples/example_uncertain_data.RData")
example_data <- example_data |>
  select(To_Compartment, `2020`, `2021`,`2022`, `2023`, RUN) |>
  pivot_longer(!c(To_Compartment, RUN), names_to = "year", values_to = "Emis") |>
  mutate(Abbr = case_when(
    To_Compartment == "Agricultural soil (micro)" ~ "s2RS",
    To_Compartment == "Residential soil (micro)" ~ "s3RS",
    To_Compartment == "Surface water (micro)" ~ "w1RS"
  )) |>
  select(-To_Compartment) |>
  mutate(Timed = ((as.numeric(year)-2019)*365.25*24*3600)) |>
  mutate(Emis = (Emis*1000000)/(365.25*24*3600)) |> # Convert kt/year to kg/s
  select(-year)

# Load the Excel file containing example distributions for variablese
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Variable_data")
Correlations <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Correlation")

# Correlations contains three columns: varName_1, varName_2 and correlation. correlation contains the correlation coefficient between the variables
# as some variables have a value for multiple subcompartments, varName_1 and varName_2 can also be the same varName. i.e. kdeg in water is correlated to
# kdeg in soil and sediment.

nruns = 100

# pull samples
lhs_samples <- optimumLHS(nruns, nrow(Example_vars))

# name cols
colnames(lhs_samples) <- paste0(Example_vars$varName, "_", Example_vars$SubCompart)

# Define functions for each row based on the distribution type
varFuns <-  World$makeInvFuns(Example_vars)

lhs_A <- correlatedLHS(lhs_samples,
                       marginal_transform_function = function(W, ...) {
                         for (i in seq_along(varFuns)) {
                           # Apply the ith distribution transformation
                           W[,i] <- varFuns[[i]](W[,i])
                         }
                         return(W)
                       },
                       cost_function = function(W, ...) {
                         # Initialize cost
                         cost <- 0
                         
                         # Compute the cost by iterating over each row of Correlations
                         for (i in seq_len(nrow(Correlations))) {
                           # Get variable names and desired correlation from Correlations
                           var_1 <- paste0(Correlations$varName_1[i], "_", Correlations$SubCompart_1[i])   # First variable
                           var_2 <- paste0(Correlations$varName_2[i], "_", Correlations$SubCompart_2[i])   # Second variable
                           desired_corr <- Correlations$correlation[i]  # Desired correlation
                           
                           # Find all matching columns for both variables in W
                           # colnames(W) now follow the naming format "varName_SubCompart"
                           col_1_matches <- which(grepl(var_1, colnames(W)))
                           col_2_matches <- which(grepl(var_2, colnames(W)))
                           
                           # Skip if no matches are found for this row in Correlations
                           if (length(col_1_matches) == 0 || length(col_2_matches) == 0) next
                           
                           # Calculate correlations between all pairs of matching columns
                           for (col_1 in col_1_matches) {
                             for (col_2 in col_2_matches) {
                               # Compute actual correlation between the two matching columns
                               actual_corr <- cor(W[, col_1], W[, col_2])
                               
                               # Update the cost with the squared error from the desired correlation
                               cost <- cost + (actual_corr - desired_corr)^2
                             }
                           }
                         }
                         
                         # Return the total cost
                         return(cost)
                       },
                       debug = FALSE, maxiter = 1000)

# Create a dataframe to compare desired vs. actual correlations
correlation_check <- Correlations  # Copy the correlations table
correlation_check$actual_correlation <- NA  # Add a column for actual correlations

transformed_samples <- lhs_A$transformed_lhs

# Check correlations for each pair in Correlations
for (i in seq_len(nrow(Correlations))) {
  var_1 <- Correlations$varName_1[i]
  var_2 <- Correlations$varName_2[i]
  
  # Find matching columns for each variable
  col_1_matches <- which(grepl(var_1, colnames(transformed_samples)))
  col_2_matches <- which(grepl(var_2, colnames(transformed_samples)))
  
  # Skip if no matches are found
  if (length(col_1_matches) == 0 || length(col_2_matches) == 0) next
  
  # Plot scatter plots for all pairs of matching columns
  for (col_1 in col_1_matches) {
    for (col_2 in col_2_matches) {
      # Scatter plot
      plot(transformed_samples[, col_1], transformed_samples[, col_2],
           xlab = colnames(transformed_samples)[col_1], ylab = colnames(transformed_samples)[col_2],
           main = paste("Scatter:", var_1, "vs.", var_2),
           pch = 19, col = "blue")
    }
  }
}

correlation_matrix <- cor(lhs_A$transformed_lhs)


library(ggplot2)
library(reshape2)

# Reshape correlation matrix
melted_corr_matrix <- melt(correlation_matrix)

# Plot heatmap
ggplot(melted_corr_matrix, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0,
                       limit = c(-1, 1), space = "Lab", name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  coord_fixed() +
  ggtitle("Correlation Heatmap")



# 
# tmax <- 365.25*24*60*60*10 # 10 years in seconds
# nTIMES <- 10 # Solve 10 times
# 
# # Initialize the dynamic solver
# World$NewSolver("ApproxODE")
# World$Solve(emissions = example_data, var_box_df = Example_vars, var_invFun = varFuns, nRUNs = length(unique(example_data$RUN)), tmax = tmax, nTIMES = nTIMES)
# 
# World$PlotSolution()
# World$PlotConcentration()
# 
# 
# 
# varFuns <- World$makeInvFuns(Example_vars)
# 
# 
# library(lhs)
lhs_A <- correlatedLHS(lhs::randomLHS(30, 4),
                       marginal_transform_function = function(W, ...) {
                         W[,1] <- qunif(W[,1], 2, 4)
                         W[,2] <- qnorm(W[,2], 1, 3)
                         W[,3] <- qexp(W[,3], 3)
                         W[,4] <- qlnorm(W[,4], 1, 1)
                         return(W)
                       },
                       cost_function = function(W, ...) {
                         (cor(W[,1], W[,2]) - 0.3)^2 + (cor(W[,3], W[,4]) - 0.5)^2
                       },
                       debug = FALSE, maxiter = 1000)










