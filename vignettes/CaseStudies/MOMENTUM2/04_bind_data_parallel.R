# Define the folder path
folder_path <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles"

if (!dir.exists(folder_path)) {
  # The folder does not exist, so create it
  dir.create(folder_path, recursive = TRUE)
  cat("Folder created:", folder_path, "\n")
} 

filepaths <- c()

#filepaths <- list()

pathname <- "vignettes/CaseStudies/MOMENTUM2/BatchFiles/"


materials <- c("ABS", "Acryl", "EPS", "HDPE", "LDPE", "OTHER", "PA", "PC", "PET", "PMMA", "PP", "PS", "PUR", "PVC", "RUBBER")

for(polymer in materials){
  # Read in the file
  file <- readLines("vignettes/CaseStudies/MOMENTUM2/03_bind_data.R")
  
  # Change the polymer to the current polymer
  target_string_polymer <- "pol <- "
  replacement_string_polymer <- paste0("pol <- ", '"', polymer, '"')
  
  line_index <- grep(paste0("^", target_string_polymer), file)
  
  if (length(line_index) > 0) {
    file[line_index] <- replacement_string_polymer
  } else {
    message("String not found in file.")
  }
  
  filename <- paste0("Bind_data_", polymer, ".R")
  
  filepath <- paste0(pathname, filename)
  filepaths <- c(filepaths, filepath)
  
  writeLines(file, filepath)
}


# Now write HPC commands into a txt file
mb <- 30000
time <- 500

# Make a string with the needed information for the cluster
LSF_string <- paste0("bsub -n 1 -e err.txt -o out.txt -W ", time, " -M ", mb, " Rscript")

# Paste the information to very string
LSF_vector <- paste(LSF_string, filepaths)

# Write to txt file to make copying easy
writeLines(LSF_vector, "vignettes/CaseStudies/MOMENTUM2/HPC_commands_bind_data.txt")

