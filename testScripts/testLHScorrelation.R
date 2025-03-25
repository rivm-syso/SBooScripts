
####################### Preparation of input variables #########################
source('baseScripts/initWorld_onlyPlastics.R')

# Load the Excel file containing example distributions for variables
Example_vars <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Variable_data")
Correlations <- readxl::read_xlsx("data/Examples/Example_uncertain_variables_correlation.xlsx", sheet = "Correlation")

nruns = 100

varFuns <-  World$makeInvFuns(Example_vars)

################################ Solver module #################################
nvars = nrow(Example_vars)

# Pull the samples
lhs_samples <- randomLHS(nruns, nvars)

# Name the columns of the LHS matrix
colnames(lhs_samples) <- paste0(Example_vars$varName, "_", Example_vars$SubCompart)

# Filter correlations
correlations <- data.frame(varName_1 = paste0(Correlations$varName_1, "_", Correlations$SubCompart_1),
                              varName_2 = paste0(Correlations$varName_2, "_", Correlations$SubCompart_2),
                              correlation = Correlations$correlation)

Correlations <- correlations[
  correlations$varName_1 %in% colnames(lhs_samples) & correlations$varName_2 %in% colnames(lhs_samples),]

#### Split lhs columns and functions

# Get names of correlated columns
unique_correlated_columns <- unique(c(Correlations$varName_1, Correlations$varName_2))

# Get correlated columns
lhs_correlated <- as.matrix(lhs_samples[, unique_correlated_columns])
colnames(lhs_correlated) <- unique_correlated_columns

# Get non-correlated columns
all_columns <- colnames(lhs_samples)  # Get all column names from lhs_samples
non_correlated_columns <- setdiff(all_columns, unique_correlated_columns)
lhs_non_correlated <- as.matrix(lhs_samples[, non_correlated_columns])
colnames(lhs_non_correlated) <- non_correlated_columns

# Get the correlated and non-correlated column indices
correlated_column_indices <- which(colnames(lhs_samples) %in% unique_correlated_columns)
non_correlated_column_indices <- setdiff(1:ncol(lhs_samples), correlated_column_indices)

# Split the varFuns list into two based on the column indices
varFuns_correlated <- varFuns[correlated_column_indices]
varFuns_non_correlated <- varFuns[non_correlated_column_indices]

#### Scale correlated LHS samples
lhs_correlated <- correlatedLHS(
  lhs_correlated,  
  marginal_transform_function = function(W, ...) {
    # Apply varFuns
    for (i in seq_along(varFuns_correlated)) {
      W[, i] <- varFuns_correlated[[i]](W[, i])
    }
    return(W)
  },
  cost_function = function(W, ...) {

    cost <- 0
    
    # Loop through each desired correlation and compute the cost
    for (i in seq_len(nrow(Correlations))) {
      # Get variable names and desired correlation
      var_1 <- Correlations$varName_1[i]
      var_2 <- Correlations$varName_2[i]
      desired_corr <- Correlations$correlation[i]
      
      # Get corresponding column indices in the filtered data
      col_1 <- which(colnames(W) == var_1)
      col_2 <- which(colnames(W) == var_2)
      
      # If both columns exist, compute the correlation
      if (length(col_1) > 0 && length(col_2) > 0) {
        actual_corr <- cor(W[, col_1], W[, col_2])
        
        # Add the squared error to the cost
        cost <- cost + (actual_corr - desired_corr)^2
      }
    }
    
    return(cost)
  },
  debug = FALSE,  
  maxiter = 10000  
)

#### Scale the non-correlated LHS samples
lhs_non_correlated_transformed <- lhs_non_correlated

for (i in seq_along(varFuns_non_correlated)) {
  lhs_non_correlated_transformed[, i] <- varFuns_non_correlated[[i]](lhs_non_correlated_transformed[, i])
}

transformed_lhs <- cbind(lhs_non_correlated_transformed, lhs_correlated$transformed_lhs)

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



