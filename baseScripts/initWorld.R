library(tidyverse)
library(ggdag) #for plotting DAG graphs
library(R6)
library(rlang)
#path to the SBoo package
Temp_Folder <- NULL

Path2PackageSource <- paste0("..","/SBoo")

#source all R files and load data from the package
Dfiles <- list.files(paste(Path2PackageSource, "data", sep = "/"), pattern = "\\.rda$")
Rded <- lapply(Dfiles, function(x) {
  Dfilename <- paste(Path2PackageSource, "data", x, sep = "/")
  if (exists("verbose") && verbose) cat(Dfilename, "\n")
  load(Dfilename, envir = global_env())
})
Rfiles <- list.files(paste(Path2PackageSource, "R", sep = "/"), pattern = "\\.R$")
sourced <- lapply(Rfiles, function(x) {
  Rfilename <- paste(Path2PackageSource, "R", x, sep = "/")
  if (exists("verbose") && verbose) cat(Rfilename, "\n")
  source(Rfilename)
})

# ifelse(Type=="onlyPlastics",print("ok"),
# stop("function not yet implemented for this Type"))

#to run the script with another selection of substance / excel reference, #
#set the variables substance
if (!exists("substance")) {
  substance <- "microplastic"
}

SBooDataLocation <- paste0(Temp_Folder)

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new(paste0(SBooDataLocation,"data"), substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

ChemClass = World$fetchData("ChemClass")

if(ChemClass != "particle") {
  World$filterStates <- list(SpeciesName = "Molecular")
  # To proceed with testing we set
  if(is.na(World$fetchData("kdis"))) {
    message(paste0("For " ,substance," kdis is missing (substance not a particle), setting kdis = 0"))
    World$SetConst(kdis = 0)
  }
  if(is.na(World$fetchData("Kssdr"))) {
    message(paste0("For " ,substance," kssdr is missing (substance not a particle), setting kssdr = 0"))
    World$SetConst(Kssdr = 0)
  }
  
  if(World$fetchData("ChemClass")==("")) {
    warning(paste0("For " ,substance," ChemClass is needed but missing, setting to neutral"))
    World$SetConst(ChemClass = "neutral")
  }
  
} else {
  if(anyNA(World$fetchData("kdis"))) {
    warning(paste0("For " ,substance," kdis is missing, setting kdis = 0"))
    message("Please set kdis in SubstanceCompartments.csv")
    World$SetConst(kdis = 0)
  }
  if(anyNA(World$fetchData("kfrag"))) {
    warning(paste0("For " ,substance," kfrag is missing, setting kfrag = 0"))
    World$SetConst(kfrag = 0)
  }
  if(anyNA(World$fetchData("kdeag"))) {
    warning(paste0("For " ,substance," kdeag is missing, setting kdeag = 0"))
    World$SetConst(kdeag = 0)
  }
  if(anyNA(World$fetchData("MinSettVel"))) {
    message(paste0("For " ,substance," MinSettVel is missing, setting to 0"))
    World$SetConst(MinSettVel = 0)
  }

  ##### Sorting out degradation #####  
  if(anyNA(World$fetchData("kdeg"))) {
    warning(paste0("For " ,substance," kdeg is missing, setting kdeg = 1e-20"))
    message("Plese set kdeg in SubstanceCompartments.csv")
    World$SetConst(kdeg = 1e-20)
  }
  if(!anyNA(World$fetchData("kdeg"))) {
    if(!anyNA(World$fetchData("Kssdr"))) {
      message(paste0("For " ,substance," Kssdr is being used instead of kdeg"))
    }
  }
  if(!anyNA(World$fetchData("kdeg"))) { 
    if(anyNA(World$fetchData("Kssdr"))) {
      message(paste0("For " ,substance," Using kdeg, setting Kssdr to NA"))
      # message("Plese set Kssdr in SubstanceCompartments.csv")
      World$SetConst(Kssdr = NA)
    }
  }
  
  if(anyNA(World$fetchData("alpha"))) {
    warning(paste0("For " ,substance," alpha is missing, setting alpha = 0.1"))
    message("Plese set alpha in SubstanceCompartments.csv")
    World$SetConst(alpha = 0.1)
  }
  if(anyNA(World$fetchData("RadS")) && anyNA(World$fetchData("Shortest_side"))){
    stop(paste0("ERROR: For ",substance ," RadS or Shortest_side needed for running SimpleBox for particles"))
  }
}

World$SetConst(DragMethod = "Original")
World$SetConst(Test = "FALSE")
World$SetConst(Test_surface_water = "FALSE")
World$SetConst(Remove_global = "FALSE")
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

#call the particulate processes 
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")

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
