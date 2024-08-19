#This script initialises a standard 'World' environment for nano-particles

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference, #
#set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
if (!exists("substance")) {
  substance <- "nAg_10nm"
}
#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# We are interested in the particulate species only, so no need to filter like in the Molecular initWorld

World$SetConst(DragMethod = "Original")
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

#call the particulate processes 
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Particulate)]
sapply(paste("k", ParProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)
World$SetConst(Test = "FALSE")
#derive needed variables
World$SetConst(kdis = 0)
World$VarsFromprocesses()

World$UpdateKaas()
