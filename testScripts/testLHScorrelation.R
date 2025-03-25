
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
colnames(lhs_samples) <- paste0(Example_vars$varName, "_", Example_vars$Scale, "_", Example_vars$SubCompart, "_", Example_vars$Species)

# Filter correlations
correlations <- data.frame(varName_1 = paste0(Correlations$varName_1, "_", Correlations$Scale_1, "_", Correlations$SubCompart_1, "_", Correlations$Species_1),
                              varName_2 = paste0(Correlations$varName_2, "_", Correlations$Scale_2, "_", Correlations$SubCompart_2, "_", Correlations$Species_2),
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

################################# Expand columns ###############################

# Function to check which states are needed for the variable
check_states <- function(varname){
  var_df <- World$fetchData(varname)
  var_cnames <- colnames(var_df)
  var_cnames <- setdiff(var_cnames, varname)
  return(var_cnames)
}

# List of possible states
water_compartments <- c("deepocean", "lake", "river", "sea")
soil_compartments <- c("agriculturalsoil", "naturalsoil", "othersoil")
sediment_compartments <- c("freshwatersediment", "lakesediment", "marinesediment")
all_compartments <- unique(World$states$asDataFrame$SubCompart)
species <- c("Unbound", "Small", "Large", "Solid")
scales <- c("Tropic", "Moderate", "Arctic", "Continental", "Regional")

# Initialize a list to store expanded columns
expanded_lhs_list <- list()
expanded_lhs_colnames <- c()

# Loop through each column in transformed_lhs
for(i in seq_len(ncol(transformed_lhs))) {
  
  # Extract column name and data
  cname <- colnames(transformed_lhs)[i]
  lhs_col <- as.matrix(transformed_lhs[, i])
  
  # Extract varname, scale, subcompartment, and species from the column name
  name_parts <- strsplit(cname, "_")[[1]]
  varname <- name_parts[1]
  current_scale <- ifelse(length(name_parts) >= 2, name_parts[2], "NA")
  current_subcompart <- ifelse(length(name_parts) >= 3, name_parts[3], "NA")
  current_species <- ifelse(length(name_parts) >= 4, name_parts[4], "NA")
  
  # Check which states are required for varname
  needed_states <- check_states(varname)
  
  # Initialize a list to store expanded columns
  expanded_columns <- list()
  
  # If no expansion is needed, store as is
  if (is.null(needed_states)) {
    expanded_columns[[cname]] <- lhs_col
  } else {
    # Expansion for Species
    expanded_columns_species <- list()
    if ("Species" %in% needed_states && current_species == "NA") {
      for (species_type in species) {
        col_name <- paste(varname, current_scale, current_subcompart, species_type, sep = "_")
        expanded_columns_species[[col_name]] <- lhs_col
      }
    } else {
      expanded_columns_species[[cname]] <- lhs_col
    }
    
    # Expansion for Scale
    expanded_columns_scale <- list()
    for (expanded_col_name in names(expanded_columns_species)) {
      expanded_col_data <- expanded_columns_species[[expanded_col_name]]
      parts <- strsplit(expanded_col_name, "_")[[1]]
      scale <- parts[2]
      
      if ("Scale" %in% needed_states && scale == "NA") {
        for (scale_type in scales) {
          col_name <- paste(parts[1], scale_type, parts[3], parts[4], sep = "_")
          expanded_columns_scale[[col_name]] <- expanded_col_data
        }
      } else {
        expanded_columns_scale[[expanded_col_name]] <- expanded_col_data
      }
    }
    
    # Expansion for SubCompartments (Final Step - Add Names Here)
    expanded_columns_final <- list()
    for (expanded_col_name in names(expanded_columns_scale)) {
      expanded_col_data <- expanded_columns_scale[[expanded_col_name]]
      parts <- strsplit(expanded_col_name, "_")[[1]]
      subcompart <- parts[3]
      
      if ("SubCompart" %in% needed_states) {
        if (subcompart == "Soil") {
          for (soil in soil_compartments) {
            col_name <- paste(parts[1], parts[2], soil, parts[4], sep = "_")
            expanded_columns_final[[col_name]] <- expanded_col_data
          }
        } else if (subcompart == "Water") {
          for (water in water_compartments) {
            col_name <- paste(parts[1], parts[2], water, parts[4], sep = "_")
            expanded_columns_final[[col_name]] <- expanded_col_data
          }
        } else if (subcompart == "Sediment") {
          for (sediment in sediment_compartments) {
            col_name <- paste(parts[1], parts[2], sediment, parts[4], sep = "_")
            expanded_columns_final[[col_name]] <- expanded_col_data
          }
        } else if (subcompart == "NA") {
          for (comp in all_compartments) {
            col_name <- paste(parts[1], parts[2], comp, parts[4], sep = "_")
            expanded_columns_final[[col_name]] <- expanded_col_data
          }
        } else {
          expanded_columns_final[[expanded_col_name]] <- expanded_col_data
        }
      } else {
        expanded_columns_final[[expanded_col_name]] <- expanded_col_data
      }
    }
    
    # Store only the final column names now
    expanded_columns <- expanded_columns_final
  }
  
  # Add fully expanded columns to final matrix
  expanded_lhs_list[[length(expanded_lhs_list) + 1]] <- do.call(cbind, expanded_columns)
  
  # **NOW** update column names to avoid saving intermediate names
  expanded_lhs_colnames <- c(expanded_lhs_colnames, names(expanded_columns))
}

# Combine all expanded columns into a single matrix
expanded_lhs_matrix <- do.call(cbind, expanded_lhs_list)

# Now, set the column names of the expanded LHS matrix
if (length(expanded_lhs_colnames) == ncol(expanded_lhs_matrix)) {
  colnames(expanded_lhs_matrix) <- expanded_lhs_colnames
} else {
  stop("Mismatch between the number of column names and columns in the expanded LHS matrix.")
}

# The expanded_lhs_matrix now contains the expanded columns with correct names
View(expanded_lhs_matrix)


############################### Check the results ##############################

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



