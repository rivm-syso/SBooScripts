
  library(tidyverse)
  library(ggdag) #for plotting DAG graphs
  library(R6)
  library(rlang)
  #path to the SBoo package
  
  Path2PackageSource <- paste0(SBInstallFolder,"SimpleBox/SBoo")
  SBooDataLocation <- paste0(SBInstallFolder,"SimpleBox/SBooScripts/")
  if(exists("SBdev")){
    if(SBdev){   
    Path2PackageSource <- paste0(SBInstallFolder,"/SBoo")
    SBooDataLocation <- paste0(SBInstallFolder,"/SBooScripts/")  
  }}
  
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
  

  
  #The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
  ClassicStateModule <- ClassicNanoWorld$new(paste0(SBooDataLocation,"data"), substance)
  
  #with this data we create an instance of the central "core" object,
  World <- SBcore$new(ClassicStateModule)
  
  ChemClass = World$fetchData("ChemClass")
  
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
      World$SetConst(Koc = NA)
    }
    if(anyNA(World$fetchData("KocAlt"))) {
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
      World$SetConst(Koc = NA)
    }
    if(anyNA(World$fetchData("KocAlt"))) {
      World$SetConst(KocAlt = NA)
    }
    
    # if(!anyNA(World$fetchData("kdeg"))) {
    #   if(!anyNA(World$fetchData("Kssdr"))) {
    #     message(paste0("initWorld: For " ,substance," Kssdr is being used instead of kdeg"))
    #   }
    # }
    if(anyNA(World$fetchData("Kssdr"))) {
      message(paste0("initWorld: For " ,substance," Kssdr is missing, to continue setting Kssdr to NA"))
      # message("Plese set Kssdr in SubstanceCompartments.csv")
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
  AllF <- ls() %>% sapply(FUN = get)
  ProcessDefFunctions <- names(AllF) %>% startsWith("k_")
  
  #call the particulate processes 
  Processes4SpeciesTp <- read.csv(paste0(SBooDataLocation,"data/Processes4SpeciesTp.csv"))
  
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
  