#################### Functions for solution plots

# Masses plot for deterministic steady state output
DetSSPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the solution
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(solution$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  if (!is.null(subcompart)) {
    
    solution <- solution[solution$SubCompart %in% subcompart, ]
  } else {
    solution <- solution
  }
  
  plot <- ggplot(solution, aes(x = SubCompart, y = Mass_kg, fill = SubCompart)) + 
    theme_bw() + 
    geom_col() +  # Use geom_col() to plot the actual values of Mass_kg
    labs(title = paste0("Steady state mass at ", scale, " scale"),
         x = "",
         y = paste0("Mass of ", World$substance, " [kg]")) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
      labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1)) 
}

# Masses plot for deterministic dynamic output
DetDynSolPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the solution
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'time', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(solution$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  if (!is.null(subcompart)) {
    solution <- solution[solution$SubCompart %in% subcompart, ]
  } else {
    solution <- solution
  }
  
  # Convert time from seconds to years
  solution$time <- as.numeric(solution$time)
  solution$Year <- solution$time / (365.25 * 24 * 3600)
  
  plot <- ggplot(solution, aes(x = Year, y = Mass_kg, group = SubCompart, color = SubCompart)) + 
    theme_bw() + 
    geom_line() +
    labs(title = paste0("Dynamic mass at ", scale, " scale"),
         x = "Year",
         y = paste0("Mass of ", World$substance, " [kg]")) +
    scale_y_continuous(labels = scales::label_scientific()) +
    guides(color = guide_legend(title = NULL))
}

# Masses plot for probabilistic dynamic output

ProbDynSolPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the solution
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'time', 'RUNs', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  if(length(subcompart) != 1){
    stop("Please select 1 subcompartment")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(solution$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  if (!is.null(subcompart)) {
    solution <- solution[solution$SubCompart %in% subcompart, ]
  } else {
    solution <- solution
  }
  
  # Convert time from seconds to years
  solution$time <- as.numeric(solution$time)
  solution$Year <- solution$time / (365.25 * 24 * 3600)
  
  summary_stats <- solution |>
    group_by(Year) |>
    summarise(
      Mean_Value = mean(Mass_kg, na.rm = TRUE),
      SD_Value = sd(Mass_kg, na.rm = TRUE),
      Lower_CI = Mean_Value - 1.96 * SD_Value / sqrt(n()),
      Upper_CI = Mean_Value + 1.96 * SD_Value / sqrt(n())
    ) |>
    ungroup()
  
  ggplot(summary_stats, aes(x = Year, y = Mean_Value)) +
    geom_line(color = "blue", size = 1) +
    geom_ribbon(aes(ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2, fill = "blue") +
    labs(title = paste0("Dynamic mean mass in ", subcompart, " at ", scale, " scale"),
         subtitle = "with uncertainty bands over time",
         x = "Year",
         y = paste0("Mass of ", World$substance, " [kg]")) +
    theme_minimal()+
    guides(color = guide_legend(title = NULL))
}

# Masses plot for probabilistic steady state output
ProbSSSolPlot <- function(scale = NULL){
  
  # Get the solution
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'RUNs', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  if (!is.null(scale)) {
    solution <- solution[solution$Scale %in% scale, ]
  } else {
    solution <- solution
  }
  
  ggplot(solution, aes(x = SubCompart, y = Mass_kg, fill = SubCompart)) +
    geom_violin()+
    theme_bw() +
    labs(title = paste0("Steady state mass at ", scale, "scale"),
         x = "",
         y = paste0("Mass of ", World$substance, " [kg]")) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
      labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    scale_fill_discrete() +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1))
}

#################### Functions for concentration plots

# Concentration plot for deterministic dynamic output
DetSSConcPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the solution
  concentration <- merge(World$Concentration(), World$states$asDataFrame, by = "Abbr")
  concentration <- concentration[c('SubCompart', 'Scale', 'Species', 'Concentration', 'Unit')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(concentration$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(concentration$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(concentration)
  cnames <- cnames[!cnames %in% c("Species", "Concentration")]
  formula <- as.formula(paste("Concentration ~", paste(cnames, collapse = " + ")))
  concentration <- aggregate(formula, data = concentration, sum)
  
  if (!is.null(scale)) {
    concentration <- concentration[concentration$Scale %in% scale, ]
  } else {
    concentration <- concentration
  }
  
  if (!is.null(subcompart)) {
    concentration <- concentration[concentration$SubCompart %in% subcompart, ]
  } else {
    concentration <- concentration
  }
  
  concentration$SubCompartUnit <- paste0(concentration$SubCompart, " (", concentration$Unit, ")")
  
  plot <- ggplot(concentration, aes(x = SubCompartUnit, y = Concentration, fill = SubCompartUnit)) + 
    theme_bw() + 
    geom_col() +  
    labs(title = paste0("Steady state concentration at ", scale, " scale"),
         x = "",
         y = paste0("Concentration of ", World$substance)) +
    # scale_y_log10(
    #   breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
    #   labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1)) 
}

# Concentration plot for deterministic dynamic output
DetDynConcPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the solution
  concentration <- merge(World$Concentration(), World$states$asDataFrame, by = "Abbr")
  concentration <- concentration[c('SubCompart', 'Scale', 'Species', 'time', 'Concentration', 'Unit')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(concentration$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(concentration$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(concentration)
  cnames <- cnames[!cnames %in% c("Species", "Concentration")]
  formula <- as.formula(paste("Concentration ~", paste(cnames, collapse = " + ")))
  concentration <- aggregate(formula, data = concentration, sum)
  
  if (!is.null(scale)) {
    concentration <- concentration[concentration$Scale %in% scale, ]
  } else {
    concentration <- concentration
  }
  
  if (!is.null(subcompart)) {
    concentration <- concentration[concentration$SubCompart %in% subcompart, ]
  } else {
    concentration <- concentration
  }
  
  concentration$SubCompartUnit <- paste0(concentration$SubCompart, " (", concentration$Unit, ")")
  
  # Convert time from seconds to years
  concentration$time <- as.numeric(concentration$time)
  concentration$Year <- concentration$time / (365.25 * 24 * 3600)
  
  plot <- ggplot(concentration, aes(x = Year, y = Concentration, group = SubCompartUnit, color = SubCompartUnit)) + 
    theme_bw() + 
    geom_line() +
    labs(title = paste0("Dynamic concentration at ", scale, " scale"),
         x = "Year",
         y = paste0("Concentration of ", World$substance)) +
    scale_y_continuous(labels = scales::label_scientific()) +
    guides(color = guide_legend(title = NULL))
}

# Concentration plot for probabilistic dynamic output
ProbDynConcPlot <- function(scale = NULL, subcompart = NULL){
  
  # Get the concentration
  concentration <- merge(World$Concentration(), World$states$asDataFrame, by = "Abbr")
  concentration <- concentration[c('SubCompart', 'Scale', 'Species', 'time', 'RUNs', 'Concentration', 'Unit')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  if(length(subcompart) != 1){
    stop("Please select 1 subcompartment")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(concentration$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Make sure the selected subcompartments exist
  if (!is.null(subcompart) && !all(subcompart %in% unique(concentration$SubCompart))) {
    stop("One or more selected subcomparts do not exist")
  }
  
  # Aggregate over species
  cnames <- names(concentration)
  cnames <- cnames[!cnames %in% c("Species", "Concentration")]
  formula <- as.formula(paste("Concentration ~", paste(cnames, collapse = " + ")))
  concentration <- aggregate(formula, data = concentration, sum)
  
  if (!is.null(scale)) {
    concentration <- concentration[concentration$Scale %in% scale, ]
  } else {
    concentration <- concentration
  }
  
  if (!is.null(subcompart)) {
    concentration <- concentration[concentration$SubCompart %in% subcompart, ]
  } else {
    concentration <- concentration
  }
  
  unit <- unique(concentration$Unit)
  
  # Convert time from seconds to years
  concentration$time <- as.numeric(concentration$time)
  concentration$Year <- concentration$time / (365.25 * 24 * 3600)
  
  summary_stats <- concentration |>
    group_by(Year) |>
    summarise(
      Mean_Value = mean(Concentration, na.rm = TRUE),
      SD_Value = sd(Concentration, na.rm = TRUE),
      Lower_CI = Mean_Value - 1.96 * SD_Value / sqrt(n()),
      Upper_CI = Mean_Value + 1.96 * SD_Value / sqrt(n())
    ) |>
    ungroup()
  
  ggplot(summary_stats, aes(x = Year, y = Mean_Value)) +
    geom_line(color = "green", size = 1) +
    geom_ribbon(aes(ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2, fill = "green") +
    labs(title = paste0("Dynamic mean concentration in ", subcompart, " at ", scale, " scale"),
         subtitle = "with uncertainty bands over time",
         x = "Year",
         y = paste0("Concentration of ", World$substance," [", unit, "]")) +
    theme_minimal()+
    guides(color = guide_legend(title = NULL))
}

# Concentration plot for probabilistic steady state output
ProbSSConcPlot <- function(scale = NULL){
  
  # Get the concentrations
  concentration <- merge(World$Concentration(), World$states$asDataFrame, by = "Abbr")
  concentration <- concentration[c('SubCompart', 'Scale', 'Species', 'RUNs', 'Concentration', 'Unit')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(concentration$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Aggregate over species
  cnames <- names(concentration)
  cnames <- cnames[!cnames %in% c("Species", "Concentration")]
  formula <- as.formula(paste("Concentration ~", paste(cnames, collapse = " + ")))
  concentration <- aggregate(formula, data = concentration, sum)
  
  if (!is.null(scale)) {
    concentration <- concentration[concentration$Scale %in% scale, ]
  } else {
    concentration <- concentration
  }
  
  concentration$SubCompartUnit <- paste0(concentration$SubCompart, " (", concentration$Unit, ")")
  
  ggplot(concentration, aes(x = SubCompartUnit, y = Concentration, fill = SubCompart)) +
    geom_violin()+
    theme_bw() +
    labs(title = paste0("Steady state concentration at ", scale, " scale"),
         x = "",
         y = paste0("Concentration of ", World$substance)) +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x, n = 10),
      labels = scales::trans_format("log10", scales::math_format(10^.x))) +
    scale_fill_discrete() +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1))
}

######################## Mass distribution plot functions ######################

# For deterministic steady state masses
DetSSMassDist <- function(scale = NULL){
  
  # Get the solution and join to states df
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  solution <- solution[c('SubCompart', 'Scale', 'Species', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Aggregate over species
  cnames <- names(solution)
  cnames <- cnames[!cnames %in% c("Species", "Mass_kg")]
  formula <- as.formula(paste("Mass_kg ~", paste(cnames, collapse = " + ")))
  solution <- aggregate(formula, data = solution, sum)
  
  # Aggregate over scales
  scale_solution <- solution |>
    group_by(Scale) |>
    summarise(Mass_kg = sum(Mass_kg))
  
  # Calculate percentages from masses
  mass_sum <- sum(scale_solution$Mass_kg)
  scale_solution <- scale_solution |>
    mutate(Mass_percent = round(((Mass_kg/mass_sum)*100), 2)) |>
    mutate(Mass_percent_label = paste0(as.character(Mass_percent), "%"))
  
  scale_plot <- ggplot(scale_solution, aes(area = Mass_kg, fill = Scale, 
                                                     label = paste(Scale, Mass_percent_label, sep = "\n"))) +
    geom_treemap() +
    geom_treemap_text(colour = "white", place = "centre", size = 15) +
    scale_fill_discrete()+
    labs(title = paste0("Distribution of steady state masses over scales")) +
    theme(legend.position = "none")  
  
  # Filter for the chosen scale
  if (!is.null(scale)) {
    subcompart_solution <- solution[solution$Scale %in% scale, ]
  } else {
    subcompart_solution <- solution
  }
  
  # Calculate percentages from masses
  mass_sum <- sum(subcompart_solution$Mass_kg)
  subcompart_solution <- subcompart_solution |>
    mutate(Mass_percent = round(((Mass_kg/mass_sum)*100), 2)) |>
    mutate(Mass_percent_label = paste0(as.character(Mass_percent), "%"))
  
 subcompart_plot <- ggplot(subcompart_solution, aes(area = Mass_kg, fill = SubCompart, 
                     label = paste(SubCompart, Mass_percent_label, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(colour = "white", place = "centre", size = 15) +
  scale_fill_manual(values = subcompart_colors) +  
  labs(title = paste0("Distribution of steady state masses at ", scale, " scale")) +
  theme(legend.position = "none")  

 grid.arrange(scale_plot, subcompart_plot, ncol = 1)
}

# For probabilistic steady state masses
ProbSSMassDist <- function(scale = NULL){

  # Get the solution and join to states df
  solution <- merge(World$Masses(), World$states$asDataFrame, by = "Abbr")
  # solution <- solution[c('SubCompart', 'Scale', 'Species', 'RUNs', 'Mass_kg')]
  
  # Make sure 1 scale is selected
  if(length(scale) != 1){
    stop("Please select 1 scale")
  }
  
  # Make sure the selected scale and subcompartments exist
  if(!scale %in% unique(solution$Scale)){
    stop("Selected scale does not exist")
  }
  
  # Aggregate over species and take average

  nRUNs = length(unique(solution$RUNs))
  
  solution <- 
    solution |>
    ungroup() |> 
    group_by(SubCompart, Scale, RUNs) |>
    summarise(Mass_kg = sum(Mass_kg)) |> 
    ungroup() |> 
    group_by(SubCompart, Scale) |> 
    summarise(Mass_kg = mean(Mass_kg),
              n=n()) |>
    ungroup()
  
  if(nRUNs != unique(solution$n)){
    stop("nRUNs not equal to n in summarise")
  }
  
  # Aggregate over scales
  scale_solution <- solution |>
    group_by(Scale) |>
    summarise(Mass_kg = sum(Mass_kg))

  # Calculate percentages from masses
  scale_solution <- scale_solution |>
    mutate(TotalMass = sum(Mass_kg)) |> 
    mutate(Mass_percent = round(((Mass_kg/TotalMass)*100), 2)) |>
    mutate(Mass_percent_label = paste0(as.character(Mass_percent), "%"))
  
  scale_plot <- ggplot(scale_solution, aes(area = Mass_kg, fill = Scale, 
                                           label = paste(Scale, Mass_percent_label, sep = "\n"))) +
    geom_treemap() +
    geom_treemap_text(colour = "white", place = "centre", size = 15) +
    scale_fill_discrete()+
    labs(title = paste0("Distribution of average steady state masses over scales")) +
    theme(legend.position = "none")  
  
  if (!is.null(scale)) {
    subcompart_solution <- solution[solution$Scale %in% scale, ]
  } else {
    subcompart_solution <- solution
  }
  
  # Calculate percentages from masses
  subcompart_solution <- subcompart_solution |>
    mutate(TotalMass = sum(Mass_kg)) |> 
    mutate(Mass_percent = round(((Mass_kg/TotalMass)*100), 2)) |>
    mutate(Mass_percent_label = paste0(as.character(Mass_percent), "%"))
  
  subcompart_plot <- ggplot(subcompart_solution, aes(area = Mass_kg, fill = SubCompart, 
                                                     label = paste(SubCompart, Mass_percent_label, sep = "\n"))) +
    geom_treemap() +
    geom_treemap_text(colour = "white", place = "centre", size = 15) +
    scale_fill_manual(values = subcompart_colors) 
    if (!is.null(scale)) {
      subcompart_plot <-subcompart_plot +
      labs(title = paste0("Distribution of average steady state masses at ", scale, " scale"))
    } else {
      subcompart_plot <-subcompart_plot + 
      labs(title = paste0("Distribution of average steady state masses at all scales"))
    }
  subcompart_plot <-  subcompart_plot+theme(legend.position = "none")  
  
  grid.arrange(scale_plot, subcompart_plot, ncol = 1)
}

subcompart_colors <- c(
  "sea" = "dodgerblue4",
  "river" = "dodgerblue4",
  "lake" = "dodgerblue4",
  "deepocean" = "dodgerblue4",
  "cloudwater" = "slategray3",
  "air" = "slategray3",
  "agriculturalsoil" = "darkgoldenrod",
  "naturalsoil" = "darkgoldenrod",
  "othersoil" = "darkgoldenrod",
  "freshwatersediment" = "burlywood4",
  "marinesediment" = "burlywood4",
  "lakesediment" = "burlywood4" 
)

