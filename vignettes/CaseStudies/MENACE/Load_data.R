###############################################################
# Code to load, read, and work with a Python dictionary in R
###############################################################

# Install required packages (only needs to be done once)
#install.packages("reticulate")
#reticulate::py_install("pandas")

# Import reticulate and Python modules
library(reticulate)
pickle   <- import("pickle")
builtins <- import_builtins()

# Open and load the pickle file
DPMFA_path <- "/mnt/scratch_dir/mellinky/WURIVM_emission_model/WURIVM_April_2025_2/My_output_files_Module_2__2025-04-29--01-10"
name_DPMFA_pickle_file <- paste0(DPMFA_path,"/MassContributionsInTargets.pkl")
DPMFA_pickle_file      <- builtins$open(name_DPMFA_pickle_file, "rb")
DPMFA_emissions        <- pickle$load(DPMFA_pickle_file)

# (Optional but recommended) Close the file after loading
DPMFA_pickle_file$close()