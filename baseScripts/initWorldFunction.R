

InitiateWorld_other <- function(Temp_Folder=NULL, # make sure path ends in /
                                substance = "1-aminoanthraquinone"){
  
  library(tidyverse)
  library(ggdag) #for plotting DAG graphs
  library(R6)
  library(rlang)
  #path to the SBoo package
  Path2PackageSource <- paste0(Temp_Folder,"SimpleBox/SBoo")
  
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
  
  SBooDataLocation <- paste0(Temp_Folder,"SimpleBox/SBooScripts/")
  
  #The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
  ClassicStateModule <- ClassicNanoWorld$new(paste0(SBooDataLocation,"data"), substance)
  
  #with this data we create an instance of the central "core" object,
  World <- SBcore$new(ClassicStateModule)
  
  ChemClass = World$fetchData("ChemClass")
  
  if(ChemClass != "Particle") {
    World$filterStates <- list(SpeciesName = "Molecular")
    # To proceed with testing we set
    if(is.na(World$fetchData("kdis"))) {
      warning("kdis is missing, setting kdis = 0")
      World$SetConst(kdis = 0)
    }
    
    if (World$fetchData("ChemClass")==("")) {
      warning("ChemClass is needed but missing, setting to neutral")
      World$SetConst(ChemClass = "neutral")
    }
    
  }
  
  World$SetConst(DragMethod = "Original")
  World$SetConst(Test = "FALSE")
  AllF <- ls() %>% sapply(FUN = get)
  ProcessDefFunctions <- names(AllF) %>% startsWith("k_")
  
  #call the particulate processes 
  Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
  
  ifelse(ChemClass != "Particle",
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
  
  if(ChemClass != "Particle") World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")
  
  World$UpdateKaas()
  
}