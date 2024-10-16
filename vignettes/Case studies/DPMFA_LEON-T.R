# Initialize

library(lhs)
library(readxl)
library(viridis)
library(doParallel)

source("baseScripts/initWorld_onlyPlastics.R")

World$substance <- "microplastic"

#### Load and reclassify DPMFA data ####
abspath <- "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/DPMFA_output/Baseline_PMFA_EU.RData"

load(abspath)

# Check if the loaded data is DPMFA or PMFA data
if(exists("DPMFA_stocks")) {
  type <- "DPMFA"
} else {
  type <- "PMFA"
}

# Convert to long format
data_long <- 
  DPMFA_sink |> unnest(Mass_Polymer_kt, keep_empty = TRUE) |> 
  pivot_longer(cols=-c(Type, Scale, Source, Polymer, To_Compartment, Material_Type, iD_source, RUN),
               names_to = "Year",
               values_to = "Mass_Polymer_kt")

# Choose a source of interest if you want, else write NA
source_of_interest <- "Tyre wear"

if(!is.na(source_of_interest)){
  if(!source_of_interest %in% unique(data_long$Source)){
    print("Selected source not in dataframe")
  } else {
    filtersource <- source_of_interest
  }
} else if (is.na(source_of_interest)){
  filtersource <- unique(data_long$Source)
}

# Calculate kg/s from kt/y 
data_summed <- data_long |>
  filter(Source %in% filtersource) |>
  #filter(between(RUN, 1, 10)) |>
  mutate(Mass_Polymer_kg_s = Mass_Polymer_kt*1000000/(365.25*24*3600)) |>
  filter(Material_Type == "micro") 

if(unique(data_long$Scale) == "EU"){
  SBscale <- "C"
} else if (unique(data_long$Scale) == "NL") {
  SBscale <- "R"
}

# Assign SB compartments to DPMFA compartments
data_filtered <- data_summed |>
  select(To_Compartment, Mass_Polymer_kg_s, Year, RUN, Polymer) |>
  mutate(Scale = SBscale) |>
  mutate(Compartment = case_when(
    str_detect(To_Compartment, "soil") ~ "s",
    str_detect(To_Compartment, "water") ~ "w",
    str_detect(To_Compartment, "air") ~ "a"
  )) |>
  mutate(Subcompartment = case_when(
    str_detect(To_Compartment, "Agricultural") ~ "2",
    str_detect(To_Compartment, "Natural") ~ "1",
    str_detect(To_Compartment, "Sub-surface") ~ "3",
    str_detect(To_Compartment, "Road side") ~ "3",
    str_detect(To_Compartment, "Residential") ~ "3",
    str_detect(To_Compartment, "Sea") ~ "2",
    str_detect(To_Compartment, "Surface") ~ "1",
    str_detect(To_Compartment, "Outdoor") ~ ""
  )) |>
  mutate(Species = "S") |>
  mutate(Abbr = paste0(Compartment, Subcompartment, Scale, Species)) |>
  group_by(Abbr, Year, RUN, Polymer) |>
  summarise(Mass_Polymer_kg_s = sum(Mass_Polymer_kg_s)) |>
  ungroup() |>
  rename(value = Mass_Polymer_kg_s) |>
  select(Abbr, Year, Polymer, value, RUN)

polymers <- unique(data_filtered$Polymer)

for(i in polymers){
  filtered <- data_filtered |>
    filter(Polymer == i)
  
  df_names <- c()
  
  if(type == "DPMFA"){
    # Make an emission dataframe for the dynamic uncertain solver
    emis_df_dyn <- filtered |>
      group_by(Abbr, Year) |>
      rename(Timed = Year) |>
      mutate(Timed = as.double(Timed)*(365.25*24*3600)) |>
      nest(Emis = c(RUN, value)) 
    
    df_name <- paste0("emis_dyn_", i)
    
    assign(df_name, emis_df_dyn)
    
    df_names <- c(df_names, df_name)
    
    ymin <- min(emis_df_dyn$Year)
    ymax <- max(emis_df_dyn$Year)
    
  } else if(type == "PMFA"){
    
    # Select data for 2019
    y <- 2019
    
    # Make an emission dataframe for the steady uncertain solver
    emis_df_ss <- filtered |>
      filter(Year == y) |>
      nest(Emis = c(RUN, value)) 
    
    df_name <- paste0("emis_ss_", i)
    
    assign(df_name, emis_df_ss)
    
    df_names <- c(df_names, df_name)
  }
}

#### Initialize distribution functions ####
# Define triangular distribution function
triangular <- function(u, a, b, c) {               # u = samples, a = min, b = max, c = peak
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

# Define uniform distribution function
uniform <- function(u, a, b) {                     # u = samples, a = min, b = max
  transformed_samples <- a + (b - a) * u
  return(transformed_samples)
}

# Define power law distribution function
power_law <- function(u, a, b, c){                 # u = samples, a = min, b = max, c = alpha
  
  # Ensure that samples are within [0, 1]
  samples <- pmin(pmax(u, 0), 1)
  
  # Transform samples to the power-law distribution
  scaled_samples <- a * ((b / a) ^ samples) ^ (1 / (1 - c))
  
  return(scaled_samples)
}

#### Make sample dataframes ####
# Path to excel file with distribution values
path_dist <- "N:/Documents/Simplebox/Microplastic_variables_v1.xlsx"

excel_df <- read_excel(path_dist, sheet = "Polymer_data")

materials <- unique(excel_df$Polymer)

water <- c("lake", "sea", "deepocean", "river")
soil <- c("naturalsoil", "agriculturalsoil", "othersoil")
sediment <- c("marinesediment", "freshwatersediment", "lakesediment")
soil_sediment <- c(soil, sediment)
air <- c("air", "cloudwater")
all_SC <- c(water, soil, sediment, air)
materials <- c("HDPE", "LDPE", "PP", "PS", "PVC", "Acryl", "PA", "PET", "ABS", "EPS", "PC", "PMMA", "PUR", "RUBBER", "OTHER")
species <- c("Large", "Small", "Solid")
small_large <- c("Small", "Large")

scales <- c("Arctic", "Tropic", "Moderate", "Regional", "Continental")

explode <- function(df, target_col, explode_value, new_values) {
  df %>%
    # Use mutate to create a new column if the target column equals explode_value
    mutate(!!sym(target_col) := ifelse(!!sym(target_col) == explode_value, list(new_values), !!sym(target_col))) %>%
    # Unnest the target column to duplicate rows
    unnest(!!sym(target_col))
}

suppressWarnings({
  var_df <- explode(excel_df, target_col = "Polymer", explode_value = "any", new_values = materials) |>
    mutate(a = as.numeric(a)) |>
    mutate(b = as.numeric(b)) |>
    mutate(c = as.numeric(c))
})

# Generate the correct number of samples
n_samples <- nrow(emis_df_ss$Emis[[1]]) # Number of emission runs 
sample_df_names <- c()

for(i in polymers){
  
  input_vars <- var_df |>
    filter(if_all(c(Distribution, a, b), ~ !is.na(.))) |>
    filter(Polymer == i) 
  
  varnames <- input_vars$VarName
  
  n_vars <- nrow(input_vars)
  
  # Generate LHS
  lhs_samples <- randomLHS(n_samples, n_vars)
  var_df_names <- c()
  
  for(j in 1:nrow(input_vars)){
    df <- input_vars[j, ]
    
    varname <- df$VarName
    
    var <- df |>
      select(VarName, Scale, SubCompart, Species, a, b, c)
    
    name <- paste0("var", j)
    var_df_names <- c(var_df_names, name)
    
    assign(name, var)
  }  
  
  params <- tibble(
    varName = sapply(var_df_names, function(v) get(v)$VarName),
    Scale = sapply(var_df_names, function(v) get(v)$Scale),
    SubCompart = sapply(var_df_names, function(v) get(v)$SubCompart),
    Species = sapply(var_df_names, function(v) get(v)$Species),
    data = lapply(var_df_names, function(v) {
      df <- get(v)
      tibble(id = c("a", "b", "c"), value = c(df$a, df$b, df$c))
    }))
  
  sample_df <- params
  
  # Transform each LHS sample column to the corresponding triangular distribution
  for (k in 1:n_vars) {
    a <- filter(params$data[[k]], id == "a") %>% pull(value)
    b <- filter(params$data[[k]], id == "b") %>% pull(value)
    c <- filter(params$data[[k]], id == "c") %>% pull(value)
    
    if(input_vars$Distribution[k] == "Triangular"){
      samples <- triangular(lhs_samples[, k], a, b, c)
    } else if(input_vars$Distribution[k] == "Uniform"){
      samples <- uniform(lhs_samples[, k], a, b)
    } else if(input_vars$Distribution[k] == "Powerlaw"){
      samples <- power_law(lhs_samples[, k], a, b, c)
    }
    
    # Create a new tibble for 'data' with samples replacing original values
    new_data <- tibble(value = samples)
    
    # Update the data column in the sample_df
    sample_df$data[[k]] <- new_data
  }
  
  # Save a separate dataframe for each material
  sample_df_name <- paste0("sample_df_",i)
  sample_df_names <- paste0(sample_df_names, sample_df_name)
  
  assign(sample_df_name, sample_df)
}

sample_dfs <- lapply(sample_df_names, get)

# Function to process each dataframe
process_sample_df <- function(sample_df) {
  exploded_scales <- explode(sample_df, target_col = "Scale", explode_value = "any", new_values = scales)
  exploded_water <- explode(exploded_scales, target_col = "SubCompart", explode_value = "water", new_values = water)
  exploded_soil_sediment <- explode(exploded_water, target_col = "SubCompart", explode_value = "soil_sediment", new_values = soil_sediment)
  exploded_species <- explode(exploded_soil_sediment, target_col = "Species", explode_value = "any", new_values = species)
  exploded_small_large <- explode(exploded_species, target_col = "Species", explode_value = "small_large", new_values = small_large)
  exploded_subcomparts <- explode(exploded_small_large, target_col = "SubCompart", explode_value = "any", new_values = all_SC)
  exploded_soil <- explode(exploded_subcomparts, target_col = "SubCompart", explode_value = "soil", new_values = soil)
  
  sample_df_cleaned <- exploded_soil
  
  return(sample_df_cleaned)
}

# Apply the processing function to each dataframe in the list
cleaned_dfs <- lapply(sample_dfs, process_sample_df)

# Assign the cleaned dataframes back to their original names in the global environment
names(cleaned_dfs) <- sample_df_names
list2env(cleaned_dfs, envir = .GlobalEnv)

#### Solve the matrix #### 
if(type == "PMFA"){
  World$NewSolver("UncertainSolver")
  
  for(i in polymers){
    # Get the emissions (kg)
    emis_df_name <- paste0("emis_ss_", i)
    sample_df_name <- paste0("sample_df_", i)
    
    solved <- World$Solve(get(emis_df_name), needdebug = FALSE, get(sample_df_name))
    assign(paste0("solved_ss_", i), solved)
    
    saveRDS(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/SimpleBoxData/", emis_df_name), solved)
    
    # Get the concentrations
    conc_df_name <- paste0("solution_", i)
    conc <- World$GetConcentration()
    
    saveRDS(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/SimpleBoxData/", conc_df_name), conc)
    
    assign(conc_df_name, conc)
  }
  
} else if(type == "DPMFA"){
  World$NewSolver("UncertainDynamicSolver")
  
  for(i in polymers){
    emis_df_name <- paste0("emis_dyn_", i)
    sample_df_name <- pasteo("sample_df_", i)
    
    solved <- World$Solve(World$Solve(get(i)), sample_df, tmax = tmax, needdebug = F)
    assign(paste0("solved_dyn_", i), solved)
    
    saveRDS(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/SimpleBoxData/", emis_df_name), solved)
    
    # Get the concentrations
    conc_df_name <- paste0("solution_", i)
    conc <- World$GetConcentration()
    
    assign(conc_df_name, conc)
  }
}

#### Make figures ####

# Create a plot theme
plot_theme <-  theme(
  axis.title.x = element_text(size = 14),    
  axis.title.y = element_text(size = 14),    
  axis.text.x = element_text(size = 12, angle = 45, hjust = 1),     
  axis.text.y = element_text(size = 12),
  title = element_text(size=20),
  panel.background = element_rect(fill = "white"),  # White background
  panel.grid.major = element_line(color = "lightgrey", size = 0.5),  # Major grid lines in light grey
  panel.grid.minor = element_line(color = "lightgrey", size = 0.25)
)

# Plot the data for each polymer separately, for all selected compartments (different plots depending on PMFA or DPMFA)
if(type == "PMFA"){
  for(mat in polymers){
    solution_name <- paste0("Solution_", mat)
    df_name <- paste0("solved_ss_", mat)
    
    Solution <- get(solution_name) |>
      mutate(RUN = as.integer(RUN)) |>
      mutate(EqMass = as.double(EqMass)) |>
      mutate(Concentration = as.double(Concentration)) 
    
    solved <- get(df_name)
    
    subt <- paste0(mat, ", ", y)
    
    # Prepare data for plots
    Input_Variables <- 
      solved$Input_Variables |> unnest(data) 
    Input_Emission <- 
      solved$Input_Emission |> unnest(Emis) 
    
    Plot_data <- 
      Input_Variables |> 
      pivot_wider(names_from = c(varName,Scale,SubCompart,Unit), values_from = value) |> 
      full_join(Solution) |>
      full_join(Input_Emission, by = c("Abbr", "RUN"))
    
    # Aggregate plot data for all species
    Plot_data_agg <- Plot_data |>
      group_by(Scale, SubCompart, RUN, Unit.x, Units_per_SubCompart) |>
      summarise(EqMass = sum(EqMass), Concentration = sum(Concentration))
    
    scales <- unique(Plot_data_agg$Scale)
    
    # Make plots for each scale, one with mass and one with concentrations
    for (scale in scales) {
      df <- Plot_data_agg |>
        filter(Scale == scale) |>
        mutate(concname = paste0(SubCompart, " (", Units_per_SubCompart, ")"))
      
      # Filter out the compartments without mass
      masscomps <- df |>
        filter(RUN == 1) |>
        filter(EqMass != 0)
      
      masscomps <- masscomps$SubCompart
      
      df <- df |>
        filter(SubCompart %in% masscomps)
      
      # Mass plot
      mass_p <- ggplot(df, mapping = aes(x = SubCompart, y = EqMass, fill = SubCompart)) +  
        geom_violin() + 
        labs(title = paste0("Masses at ", scale, " scale"),
             subtitle = subt,
             x = "Compartment",
             y = "Mass (kg)") +
        plot_theme +
        scale_y_continuous(trans = 'log10') +
        scale_fill_viridis_d() + 
        # Customize the legend for this plot as well
        theme(axis.text.x = element_blank(),  # Remove x-axis labels
              legend.position = "bottom") +   # Move legend to the bottom
        guides(fill = guide_legend(title = NULL))  # Remove legend title
      
      print(mass_p)
      
      ggsave(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/SimpleBoxData/Mass_plot_", scale, ".png"), plot=mass_p)
      
      # Concentration plot
      conc_p <- ggplot(df, mapping = aes(x = concname, y = Concentration, fill = concname)) +  
        geom_violin() +
        labs(title = paste0("Concentrations at ", scale, " scale"),
             subtitle = subt,
             x = "Compartment",
             y = "Concentration") +
        plot_theme +
        scale_y_continuous(trans = 'log10') +
        scale_fill_viridis_d() +
        theme(axis.text.x = element_blank(),  # Remove x-axis labels
              legend.position = "bottom") +   # Move legend to the bottom
        guides(fill = guide_legend(title = NULL))  # Remove legend title
      
      print(conc_p)
      
      ggsave(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/SimpleBoxData/Concentration_plot_", scale, ".png"), plot=conc_p)
    }
  }
  
} else if(type == "DPMFA"){        
  
  # TO DO: Make plots for DPMFA output
  
}

















