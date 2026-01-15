library(openxlsx)
library(dplyr)
`%notin%` <- Negate(`%in%`)

file <- "vignettes/CaseStudies/FateFactorsUpdate/results_FF_CF.xlsx"

# Named list of sheets and their corresponding data frames
sheets_list <- list(
  "results_CF_mid_PAF_day"       = results_CF_mid_PAF_day,
  "results_CF_end_PDF_year"      = results_CF_end_PDF_year,
  "results_CF_end_species_year"  = results_CF_end_species_year,
  "results_CF_end_PDF_m2_year"   = results_CF_end_PDF_m2_year
)

###########
# World average CFs
###########

# Region weights
weights <- c(
  "North America"        = 0.00,
  "Latin America"        = 0.09,
  "Europe"               = 0.05,
  "Africa & Middle East" = 0.34,
  "Southeast Asia"       = 0.49,
  "Central Asia"         = 0.02,
  "Northern regions"     = 0.00,
  "Oceania"              = 0.00
)

# Global emission compartments to keep only world averages
global_compartments <- c(
  "global seawater surface",
  "global seawater column",
  "global marine sediments"
)

# Load workbook
wb <- loadWorkbook(file)

for (sheet_name in names(sheets_list)) {
  
  df_orig <- sheets_list[[sheet_name]]
  
  # Safe column names
  orig_names <- names(df_orig)
  tmp_names  <- make.names(orig_names, unique = TRUE)
  df <- df_orig
  names(df) <- tmp_names
  
  # Identify region, size, and emission_compartment columns
  region_col <- tmp_names[orig_names == "region"]
  size_col   <- tmp_names[orig_names == "size"]
  comp_col   <- tmp_names[orig_names == "emission_compartment"]
  
  # Identify CF numeric columns
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  cf_cols <- setdiff(numeric_cols, c(region_col, size_col))
  
  # Remove old World rows
  df <- df %>% filter(.data[[region_col]] != "World")
  
  # Filter only weighted regions
  df_filtered <- df %>% filter(.data[[region_col]] %in% names(weights))
  df_filtered$..weight <- weights[df_filtered[[region_col]]]
  
  # Grouping columns for World average (exclude region and CFs)
  group_cols <- c("polymer", "size", "shape", "emission_compartment")
  
  # Compute weighted World average
  df_world <- df_filtered %>%
    group_by(across(all_of(group_cols))) %>%
    summarise(across(all_of(cf_cols),
                     ~ sum(.x * ..weight, na.rm = TRUE),
                     .names = "{.col}"),
              .groups = "drop")
  
  # Assign region "World"
  df_world[[region_col]] <- "World"
  
  # Handle elementary_flowname (nomenclature)
  if ("elementary_flowname" %in% orig_names) {
    flow_col <- tmp_names[orig_names == "elementary_flowname"]
    
    # Create column in df_world if missing
    if (!(flow_col %in% names(df_world))) df_world[[flow_col]] <- ""
    
    # Map original elementary_flowname based on grouping keys
    idx <- match(
      paste(df_world$polymer, df_world$size, df_world$shape, df_world$emission_compartment),
      paste(df$polymer, df$size, df$shape, df$emission_compartment)
    )
    df_world[[flow_col]] <- df[[flow_col]][idx]
    
    # Replace last region in nomenclature with "World"
    df_world[[flow_col]] <- sub(", [^,]+$", ", World", df_world[[flow_col]])
  }
  
  # Reorder columns safely to match original df
  common_cols <- intersect(names(df), names(df_world))
  df_world <- df_world[common_cols]
  
  # CRITICAL NEW STEP: Remove regionalized data for global compartments BEFORE binding
  if (!is.na(comp_col)) {
    # Identify rows with global compartments (non-World region)
    global_regional_rows <- df %>% 
      filter(.data[[comp_col]] %in% global_compartments & .data[[region_col]] != "World")
    
    message("Sheet: ", sheet_name)
    message("  Removing ", nrow(global_regional_rows), 
            " regional rows for global compartments")
    
    # Keep only rows that are NOT regionalized global compartments
    df <- df %>% 
      filter(!(.data[[comp_col]] %in% global_compartments & .data[[region_col]] != "World"))
  }
  
  # Bind with original non-World rows (now filtered)
  df_out <- bind_rows(df, df_world)
  
  # Write updated sheet
  if (sheet_name %in% names(wb)) removeWorksheet(wb, sheet_name)
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet_name, df_out, withFilter = TRUE)
}

# Save workbook
saveWorkbook(wb, file, overwrite = TRUE)

###########
# Unknown polymers default CFs per density 
# Polymer emissions weighted
###########

# polymer weightings (as named numeric vectors)
weighting_low_density <- c(
  EPS = 0.00, PP = 0.37, LDPE = 0.35, PAN = 0.00, HDPE = 0.28, PS = 0.00,
  PHA = 0.00, PA_Nylon = 0.00, PLA = 0.00, starch_blend = 0.00,
  PBAT = 0.00, PET = 0.00, PVC = 0.00, TRWP = 0.00
)

weighting_high_density <- c(
  EPS = 0.00, PP = 0.00, LDPE = 0.00, PAN = 0.00, HDPE = 0.00, PS = 0.26,
  PHA = 0.00, PA_Nylon = 0.00, PLA = 0.00, starch_blend = 0.00,
  PBAT = 0.00, PET = 0.34, PVC = 0.40, TRWP = 0.00
)

weighting_all_density <- c(
  EPS = 0.00, PP = 0.242, LDPE = 0.230, PAN = 0.00, HDPE = 0.188,
  PS = 0.087, PHA = 0.00, PA_Nylon = 0.00, PLA = 0.00,
  starch_blend = 0.00, PBAT = 0.00, PET = 0.117, PVC = 0.136, TRWP = 0.00
)

# default polymer patterns - use patterns to catch ALL variations
default_patterns <- c(
  "default_low_density", "default_high_density", "default_all_density",
  "default low density", "default high density", "default all density",
  "^default.*"  # This catches anything starting with "default"
)

# Size mappings for shapes - as numeric values
size_mappings <- list(
  "sphere" = 1000,
  "Sphere" = 1000,
  "fragment" = 1000, 
  "Fragment" = 1000,
  "microsphere" = 1000,
  "Microsphere" = 1000,
  "fiber" = 10,
  "Fiber" = 10,
  "fibre" = 10,
  "Fibre" = 10,
  "cylinder" = 10,  # Added cylinder
  "Cylinder" = 10,
  "film" = 100,
  "Film" = 100
)

# helper for %notin%
`%notin%` <- Negate(`%in%`)

# start workbook
wb <- loadWorkbook(file)

for (sheet in names(sheets_list)) {
  message("\n=== Processing sheet: ", sheet, " ===")
  
  # read sheet (original names may contain duplicates)
  df_orig <- readWorkbook(wb, sheet = sheet, detectDates = TRUE)
  
  # 1) FIRST: Remove ALL existing default rows from original data
  # Find the polymer column in original data
  polymer_col_orig <- names(df_orig)[tolower(names(df_orig)) == "polymer"][1]
  
  if (!is.na(polymer_col_orig)) {
    # Count defaults before removal
    default_count_before <- sum(grepl("default", df_orig[[polymer_col_orig]], ignore.case = TRUE))
    message("  Found ", default_count_before, " default rows before removal")
    
    # Remove ANY row where polymer starts with "default" (case insensitive)
    df_orig_no_defaults <- df_orig %>%
      filter(!grepl("^default", !!sym(polymer_col_orig), ignore.case = TRUE))
    
    # Also check for other default patterns
    for (pattern in default_patterns) {
      df_orig_no_defaults <- df_orig_no_defaults %>%
        filter(!grepl(pattern, !!sym(polymer_col_orig), ignore.case = TRUE))
    }
    
    default_count_after <- sum(grepl("default", df_orig_no_defaults[[polymer_col_orig]], ignore.case = TRUE))
    message("  Remaining after removal: ", default_count_after, " default rows")
    
  } else {
    df_orig_no_defaults <- df_orig
    message("  No polymer column found in sheet")
  }
  
  # Now work with cleaned data
  # tmp unique names for safe dplyr handling
  orig_names <- names(df_orig_no_defaults)
  tmp_names  <- make.names(orig_names, unique = TRUE)
  df <- df_orig_no_defaults
  names(df) <- tmp_names
  
  # identify key columns (by original names -> tmp names)
  region_col <- tmp_names[which(orig_names == "region")[1]]
  polymer_col <- tmp_names[which(orig_names == "polymer")[1]]
  elem_col <- tmp_names[which(orig_names == "elementary_flowname")[1]]
  size_tmp <- tmp_names[which(orig_names == "size")[1]]
  shape_tmp <- tmp_names[which(orig_names == "shape")[1]]
  comp_col <- tmp_names[which(orig_names == "emission_compartment")[1]]
  
  # Check if we have polymer column
  if (is.na(polymer_col)) {
    message("  No polymer column found - skipping default calculation")
    df_out <- df_orig_no_defaults
  } else {
    # 2) detect numeric CF columns (exclude identifier 'region' and 'size')
    numeric_cols <- names(df)[sapply(df, is.numeric)]
    # ensure 'size' is not included as numeric CF
    if (!is.na(size_tmp)) numeric_cols <- setdiff(numeric_cols, size_tmp)
    # exclude region if it is numeric (very unlikely)
    numeric_cols <- setdiff(numeric_cols, region_col)
    
    # if no numeric columns, skip this sheet
    if (length(numeric_cols) == 0) {
      message("  No numeric CF columns found - skipping calculation")
      df_out <- df_orig_no_defaults
    } else {
      # 3) keep only rows that have a region value (safety)
      df <- df[!is.na(df[[region_col]]), , drop = FALSE]
      
      # 4) Identify grouping columns - ALL non-numeric, non-polymer columns
      group_cols <- setdiff(
        names(df), 
        c(polymer_col, numeric_cols, "..poly_weight")
      )
      
      message("  Rows available for calculation: ", nrow(df))
      message("  Numeric columns: ", paste(numeric_cols, collapse = ", "))
      
      # We'll create a helper that given a polymer-weight vector computes defaults
      compute_defaults_for_weights <- function(df_in, poly_weights, label_text) {
        # Create a copy to avoid modifying original
        dfw <- df_in
        
        # Map polymer values to weight
        dfw$..poly_weight <- ifelse(
          as.character(dfw[[polymer_col]]) %in% names(poly_weights),
          poly_weights[as.character(dfw[[polymer_col]])],
          0
        )
        
        # Filter out groups where all weights are zero BEFORE grouping
        dfw <- dfw %>%
          group_by(across(all_of(group_cols))) %>%
          mutate(has_weights = any(..poly_weight > 0)) %>%
          ungroup() %>%
          filter(has_weights) %>%
          dplyr::select(-has_weights)
        
        # If no rows with weights, return empty dataframe
        if (nrow(dfw) == 0) {
          message("    No data for '", label_text, "' weights")
          return(data.frame())
        }
        
        message("    Computing '", label_text, "' defaults from ", nrow(dfw), " rows")
        
        # Perform grouping
        df_agg <- dfw %>%
          group_by(across(all_of(group_cols))) %>%
          summarise(
            # pick a representative elementary_flowname (first one)
            ..rep_elem = first(.data[[elem_col]]),
            # compute weighted means for every numeric CF column
            across(
              all_of(numeric_cols),
              ~ {
                # Get weights for this column
                weights_vec <- .data$..poly_weight
                
                # Check if we have valid data
                valid_idx <- !is.na(.x) & weights_vec > 0
                
                if (sum(valid_idx) == 0) {
                  return(NA_real_)
                }
                
                # Weighted average
                sum(.x[valid_idx] * weights_vec[valid_idx]) / sum(weights_vec[valid_idx])
              },
              .names = "{.col}"
            ),
            .groups = "drop"
          )
        
        # Check if we got any rows
        if (nrow(df_agg) == 0) {
          return(data.frame())
        }
        
        # Create new elementary_flowname
        rep_elem_tmp <- df_agg$..rep_elem
        new_elem <- ifelse(
          grepl("\\(", rep_elem_tmp),
          sub(" - [^-]+\\s*(\\()", paste0(" - default ", label_text, " \\1"), rep_elem_tmp),
          sub(" - [^-]+", paste0(" - default ", label_text), rep_elem_tmp)
        )
        
        # Assemble final df
        df_final <- df_agg %>%
          mutate(
            !!polymer_col := paste0("default_", gsub(" ", "_", label_text)),
            !!elem_col    := new_elem
          ) %>%
          dplyr::select(-any_of("..rep_elem"))
        
        # Ensure all original columns are present
        missing_cols <- setdiff(names(df_in), names(df_final))
        for (mc in missing_cols) {
          if (mc %in% c(polymer_col, elem_col)) next
          df_final[[mc]] <- if (mc %in% group_cols) {
            df_agg[[mc]]
          } else {
            NA
          }
        }
        
        # Reorder to match original
        df_final <- df_final[names(df_in)]
        
        return(df_final)
      }
      
      # Compute three default sets
      df_def_low  <- compute_defaults_for_weights(df, weighting_low_density, "low density")
      df_def_high <- compute_defaults_for_weights(df, weighting_high_density, "high density")
      df_def_all  <- compute_defaults_for_weights(df, weighting_all_density, "all density")
      
      # Combine the regular defaults
      df_defaults_list <- list(df_def_low, df_def_high, df_def_all)
      df_defaults_list <- df_defaults_list[sapply(df_defaults_list, nrow) > 0]
      
      # NEW: Create rows with modified elementary_flowname (REMOVE size completely)
      create_modified_defaults <- function(default_df, density_label) {
        if (nrow(default_df) == 0) {
          return(data.frame())
        }
        
        # Check if we have shape and size columns
        if (is.na(shape_tmp) || is.na(size_tmp)) {
          message("    Missing shape or size column")
          return(data.frame())
        }
        
        # Debug: show what shapes and sizes we have
        message("    Available shapes in ", density_label, ": ", 
                paste(unique(default_df[[shape_tmp]]), collapse = ", "))
        message("    Available sizes in ", density_label, ": ", 
                paste(unique(default_df[[size_tmp]]), collapse = ", "))
        
        modified_rows <- list()
        
        # For each shape in our mapping
        for (shape_pattern in names(size_mappings)) {
          message("    Looking for shape: '", shape_pattern, "'")
          
          # Get target size for this shape (as numeric)
          target_size_num <- size_mappings[[shape_pattern]]
          
          # Find rows with EXACT shape match 
          shape_rows <- default_df %>%
            filter(.data[[shape_tmp]] == shape_pattern)
          
          if (nrow(shape_rows) > 0) {
            message("      Found ", nrow(shape_rows), " rows with shape '", shape_pattern, "'")
            
            # Get unique regions for this shape
            shape_regions <- shape_rows %>%
              distinct(.data[[region_col]]) %>%
              pull(.data[[region_col]])
            
            message("      Regions with this shape: ", paste(shape_regions, collapse = ", "))
            
            # For each region
            for (region_val in shape_regions) {
              # Find rows with this EXACT shape, region, and target size
              target_rows <- default_df %>%
                filter(.data[[shape_tmp]] == shape_pattern &
                         .data[[region_col]] == region_val &
                         .data[[size_tmp]] == target_size_num)
              
              if (nrow(target_rows) > 0) {
                message("      Found ", nrow(target_rows), " rows for ", shape_pattern, 
                        " in ", region_val, " with size ", target_size_num)
                
                # Create modified versions (DO NOT change the size column - keep it numeric!)
                new_rows <- target_rows
                
                # Determine the replacement text based on shape
                replacement_text <- ifelse(
                  tolower(shape_pattern) %in% c("film", "Film"),
                  "default thickness",
                  "default diameter"
                )
                
                # Modify elementary_flowname to REMOVE the size and add replacement text
                for (i in 1:nrow(new_rows)) {
                  elem_name <- new_rows[[elem_col]][i]
                  
                  # Convert target_size_num to string for pattern matching
                  target_size_str <- as.character(target_size_num)
                  
                  # Remove size patterns completely and replace with appropriate text
                  
                  # Pattern 1: (10 µm diameter) or (100 µm diameter) etc.
                  if (grepl(paste0("\\(", target_size_str, " µm (diameter|thickness)\\)"), elem_name)) {
                    elem_name <- gsub(
                      paste0("\\(", target_size_str, " µm (diameter|thickness)\\)"),
                      paste0("(", replacement_text, ")"),
                      elem_name
                    )
                  }
                  # Pattern 2: (10 µm) or (100 µm) etc.
                  else if (grepl(paste0("\\(", target_size_str, " µm\\)"), elem_name)) {
                    elem_name <- gsub(
                      paste0("\\(", target_size_str, " µm\\)"),
                      paste0("(", replacement_text, ")"),
                      elem_name
                    )
                  }
                  # Pattern 3: (10) or (100) etc.
                  else if (grepl(paste0("\\(", target_size_str, "\\)"), elem_name)) {
                    elem_name <- gsub(
                      paste0("\\(", target_size_str, "\\)"),
                      paste0("(", replacement_text, ")"),
                      elem_name
                    )
                  }
                  # Pattern 4: (10um) or (100um) etc.
                  else if (grepl(paste0("\\(", target_size_str, "um\\)"), elem_name)) {
                    elem_name <- gsub(
                      paste0("\\(", target_size_str, "um\\)"),
                      paste0("(", replacement_text, ")"),
                      elem_name
                    )
                  }
                  # Pattern 5: - 10 µm diameter or - 100 µm thickness etc.
                  else if (grepl(paste0("- ", target_size_str, " µm (diameter|thickness)"), elem_name)) {
                    elem_name <- gsub(
                      paste0("- ", target_size_str, " µm (diameter|thickness)"),
                      paste0("- ", replacement_text),
                      elem_name
                    )
                  }
                  # Pattern 6: - 10 µm or - 100 µm etc.
                  else if (grepl(paste0("- ", target_size_str, " µm"), elem_name)) {
                    elem_name <- gsub(
                      paste0("- ", target_size_str, " µm"),
                      paste0("- ", replacement_text),
                      elem_name
                    )
                  }
                  # Pattern 7: - 10 or - 100 etc.
                  else if (grepl(paste0("- ", target_size_str), elem_name)) {
                    elem_name <- gsub(
                      paste0("- ", target_size_str),
                      paste0("- ", replacement_text),
                      elem_name
                    )
                  }
                  # Pattern 8: - 10um or - 100um etc.
                  else if (grepl(paste0("- ", target_size_str, "um"), elem_name)) {
                    elem_name <- gsub(
                      paste0("- ", target_size_str, "um"),
                      paste0("- ", replacement_text),
                      elem_name
                    )
                  }
                  # If no pattern matches, just add (default diameter/thickness) at the end
                  else {
                    # Check if there's already something in parentheses at the end
                    if (grepl("\\([^)]+\\)$", elem_name)) {
                      # Replace whatever is in the last parentheses
                      elem_name <- sub("\\([^)]+\\)$", paste0("(", replacement_text, ")"), elem_name)
                    } else {
                      # Add (default diameter/thickness) at the end
                      elem_name <- paste0(elem_name, " (", replacement_text, ")")
                    }
                  }
                  
                  new_rows[[elem_col]][i] <- elem_name
                }
                
                # Make sure size column stays numeric
                if (is.character(new_rows[[size_tmp]])) {
                  new_rows[[size_tmp]] <- as.numeric(new_rows[[size_tmp]])
                }
                
                modified_rows[[length(modified_rows) + 1]] <- new_rows
              } else {
                message("      No rows found for ", shape_pattern, " in ", region_val, 
                        " with size ", target_size_num)
              }
            }
          } else {
            message("      No rows found with exact shape '", shape_pattern, "'")
          }
        }
        
        if (length(modified_rows) > 0) {
          modified_df <- bind_rows(modified_rows) %>%
            distinct()  # Remove duplicates
          
          # Ensure size column is numeric
          if (!is.na(size_tmp) && size_tmp %in% names(modified_df)) {
            modified_df[[size_tmp]] <- as.numeric(modified_df[[size_tmp]])
          }
          
          message("    Created ", nrow(modified_df), " modified rows for '", density_label, "'")
          return(modified_df)
        } else {
          message("    No modified rows created for '", density_label, "'")
          return(data.frame())
        }
      }
      
      # Create modified rows for each density type
      df_modified_low <- create_modified_defaults(df_def_low, "low density")
      df_modified_high <- create_modified_defaults(df_def_high, "high density")
      df_modified_all <- create_modified_defaults(df_def_all, "all density")
      
      # Combine ALL defaults (regular + modified)
      all_defaults_list <- list(
        df_def_low, df_def_high, df_def_all,
        df_modified_low, df_modified_high, df_modified_all
      )
      
      # Filter out empty dataframes
      all_defaults_list <- all_defaults_list[sapply(all_defaults_list, nrow) > 0]
      
      if (length(all_defaults_list) > 0) {
        df_all_defaults <- bind_rows(all_defaults_list)
        
        # Restore original column names
        names(df_all_defaults) <- orig_names
        
        # Bind (cleaned original + all defaults)
        df_out <- bind_rows(df_orig_no_defaults, df_all_defaults)
        message("  Added ", nrow(df_all_defaults), " total default rows")
      } else {
        # No defaults created, use cleaned original
        df_out <- df_orig_no_defaults
        message("  No new defaults added")
      }
    }
  }
  
  # Write back
  if (sheet %in% names(wb)) removeWorksheet(wb, sheet)
  addWorksheet(wb, sheet)
  writeData(wb, sheet, df_out, withFilter = TRUE)
  
  message("  Final row count: ", nrow(df_out))
}

# save workbook after loop
saveWorkbook(wb, file, overwrite = TRUE)

message("\n=== Processing complete ===")