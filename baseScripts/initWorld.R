library(tidyverse)
library(ggdag) #for plotting DAG graphs
library(R6)
library(rlang)

# Define if the local version or the package should be used. 
# To use the local version, set use_local_sboo = TRUE in your local environment.
if(!exists("use_local_sboo")){
  use_local_sboo = FALSE
}

if (isTRUE(use_local_sboo)) {
  message("Using local SBoo from ../SBoo")
  devtools::load_all("../SBoo")
} else {
  if (!requireNamespace("sboo", quietly = TRUE)) {
    stop(
      paste0(
        "The package 'SBoo' is required but not installed.\n\n",
        "How to install:\n",
        "  1) Install remotes (once):\n",
        "       install.packages('remotes')\n",
        "  2) Install SBoo from GitHub:\n",
        "       remotes::install_github('your-org/SBoo', ref = 'main')\n",
        "        or: source('baseScripts/Install_SBoo_package.R')\n\n",
        "To use local code instead, set:\n",
        "  options(sboo.use_local = TRUE)\n",
        "and ensure the path to the source project folder is correct.\n"
      ),
      call. = FALSE
    )
  }
}

if (!"package:sboo" %in% search()){
  library(sboo)
}

# ifelse(Type=="onlyPlastics",print("ok"),
# stop("function not yet implemented for this Type"))

#to run the script with another selection of substance / excel reference, #
#set the variables substance
if (!exists("substance")) {
  substance <- "microplastic"
}

message(paste("Running SimpleBox for",substance))

# The variable use_scenario_data is used to decide whether to use the default data or data for a specific scenario. 
# If use_scenario_data is TRUE, it is assumed that SBoo and SBooScripts were downloaded using the "InstallSBoo.R" script. 
# The standard location of the data folder if use_scenario_data == TRUE is therefore two folders down from your current working directory. 

if(!exists("scenario_data")){
  use_scenario_data <- NA
}

if(!is.na(use_scenario_data)){
  if (!dir.exists(scenario_data)) {
    stop("scenario_data is supposed to contain data, like SBooScripts/data")
  }
  cat("Using scenario data to setup World.")
  SBooDataLocation <- scenario_data
} else {
  cat("Using default data to setup World.")
  # assuming this script lives in SBooScripts/baseScripts
  SBooDataLocation <- "./data"
}

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new(SBooDataLocation, substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

ChemClass = World$fetchData("ChemClass")

# This constant turns deepocean at Regional and Continental scale off when TRUE
World$SetConst(Regional_and_Continental_deepocean = "FALSE")

# This constant turns the Arctic, Moderate and Tropic scales on and off
World$SetConst(Remove_global = "FALSE")

if(ChemClass != "particle") {
  World$filterStates <- list(SpeciesName = "Molecular")
  # To proceed with testing we set
  if(is.na(World$fetchData("kdis"))) {
    message(paste0("initWorld: For ", substance," kdis is missing (substance not a particle), setting kdis = NA"))
    World$SetConst(kdis = NA)
  }
  if(is.na(World$fetchData("Kssdr"))) {
    message(paste0("initWorld: For " ,substance," kssdr is missing (substance not a particle), setting kssdr = 0"))
    World$SetConst(Kssdr = 0)
  }
  
  if(World$fetchData("ChemClass")==("")) {
    warning(paste0("initWorld: For " ,substance," ChemClass is needed but missing, setting to neutral"), call. = FALSE)
    World$SetConst(ChemClass = "neutral")
  }
  if(anyNA(World$fetchData("Koc"))) {
    # message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
    # message("Plese set Kssdr in SubstanceCompartments.csv")
    World$SetConst(Koc = NA)
  }
  if(anyNA(World$fetchData("KocAlt"))) {
    # message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
    # message("Plese set Kssdr in SubstanceCompartments.csv")
    World$SetConst(KocAlt = NA)
  }
} else {
  if(anyNA(World$fetchData("kdis"))) {
    warning(paste0("initWorld: For " ,substance," kdis is missing, setting kdis = 0"), call. = FALSE)
    message("initWorld: Please set kdis in SubstanceCompartments.csv")
    World$SetConst(kdis = 0)
  }
  if(anyNA(World$fetchData("kfrag"))) {
    warning(paste0("initWorld: For " ,substance," kfrag is missing, setting kfrag = 0"), call. = FALSE)
    World$SetConst(kfrag = 0)
  }
  if(anyNA(World$fetchData("kdeag"))) {
    warning(paste0("initWorld: For " ,substance," kdeag is missing, setting kdeag = 0"), call. = FALSE)
    World$SetConst(kdeag = 0)
  }
  if(anyNA(World$fetchData("MinSettVel"))) {
    message(paste0("initWorld: For ", substance," MinSettVel is missing, setting to 0"))
    World$SetConst(MinSettVel = 0)
  }
  
  ##### Sorting out degradation #####  
  if(anyNA(World$fetchData("DegApproach"))){
    warning("initWorld: DegApproach not set, using Default", call. = FALSE)
    World$SetConst(DegApproach = "Default")
  }
  message(paste0("initWorld: Degradation calculation for particles uses ",World$fetchData("DegApproach")," approach."))
  message(paste0("initWorld: Drag method for calculation of particle settling velocities uses ",World$fetchData("DragMethod")," approach."))
  
  if(anyNA(World$fetchData("kdeg"))) {
    warning(paste0("initWorld: k_degradation - For " ,substance," kdeg is missing, setting default kdeg = 1e-20."))
    World$SetConst(kdeg = 1e-20)
  }
  if(anyNA(World$fetchData("Koc"))) {
    # message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
    # message("Please set Kssdr in SubstanceCompartments.csv")
    World$SetConst(Koc = NA)
  }
  if(anyNA(World$fetchData("KocAlt"))) {
    # message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
    # message("Please set Kssdr in SubstanceCompartments.csv")
    World$SetConst(KocAlt = NA)
  }
  
  # if(!anyNA(World$fetchData("kdeg"))) {
  #   if(!anyNA(World$fetchData("Kssdr"))) {
  #     message(paste0("initWorld: For " ,substance," Kssdr is being used instead of kdeg"))
  #   }
  # }
  if(anyNA(World$fetchData("Kssdr"))) {
    message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
    # message("Please set Kssdr in SubstanceCompartments.csv")
    World$SetConst(Kssdr = NA)
  }
  
  if(anyNA(World$fetchData("alpha"))) {
    warning(paste0("initWorld: For " ,substance," alpha is missing, setting alpha = 0.1"))
    message("initWorld: Plese set alpha in SubstanceCompartments.csv")
    World$SetConst(alpha = 0.1)
  }
  if(anyNA(World$fetchData("RadS")) && anyNA(World$fetchData("Shortest_side"))){
    stop(paste0("initWorld ERROR: For ",substance ," RadS or Shortest_side needed for running SimpleBox for particles"))
  }
}

if(anyNA(World$fetchData("DragMethod"))){
  World$SetConst(DragMethod = "Original")
}

if(anyNA(World$fetchData("Test"))){
  World$SetConst(Test = "FALSE")
}

AllF <- ls("package:sboo") %>% sapply(FUN = get)

# Load functions to global environment
ns <- asNamespace("sboo")          
objs <- ls(ns)                    

funs <- objs[sapply(objs, function(nm) is.function(get(nm, envir = ns)))]

for (nm in funs) {
  assign(nm, get(nm, envir = ns), envir = .GlobalEnv)
}

ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

#call the particulate processes 
Processes4SpeciesTp <- read.csv(file.path(SBooDataLocation, "Processes4SpeciesTp.csv"))

ifelse(ChemClass != "particle",
       {
         ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Molecular)]
       },
       {
         ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Particulate)]
       })

sapply(paste("k", ParProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)

#derive needed variables
World$VarsFromprocesses()

if(ChemClass != "particle") World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

World$UpdateKaas()

rm(ChemClass)

