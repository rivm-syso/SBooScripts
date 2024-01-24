#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference,
#set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
if (!exists("substance")) {
  substance <- "default substance"
}

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

#We can calculate variables and fluxes available (fakeLib provided the functions:)
VarDefFunctions <- c("AirFlow", "AreaSea", "AreaLand", "Area", "Volume",
                     "D", "FRACa", "FRACs", "FRACw", "FRinaers",
                     "FRinaerw","FRingas","FRins","FRinw",
                     "FRorig", "FRorig_spw", "Kacompw", "Kaers", "Kaerw", "KdegDorC",
                     "Kp", "KpCOL", "Kscompw", "Ksdcompw", "Ksw.alt", "MasConc_Otherparticle",
                     "MTC_2a", "MTC_2s", "MTC_2sd", "MTC_2w", "OtherkAir",
                     "rad_species", "RainOnFreshwater", "Runoff", "rho_species", "SettlingVelocity",
                     "Tempfactor")

lapply(VarDefFunctions, function(FuName){
  World$NewCalcVariable(FuName)
  #World$CalcVar(FuName) #only needed if you want to debug or force an order; UpdateKaas finds the DAG
})

InitNodes <- World$nodelist
#only needs
InitNodes <- InitNodes[,c("Calc", "Params")]
fromData <- unique(InitNodes$Params[!InitNodes$Params %in% InitNodes$Calc])
DataIN <- aggregate(Params~Calc, data = InitNodes[InitNodes$Params %in% fromData,], FUN = paste)
#nodes depending on other nodes
TreeNodes <- InitNodes[!InitNodes$Params %in% fromData & InitNodes$Params %in% InitNodes$Calc,]

library(dagitty)
library(ggdag)

NodeAsText <- paste(TreeNodes$Params, "->" ,TreeNodes$Calc)
AllNodesAsText <- do.call(paste, c(as.list(NodeAsText), list(sep = ";")))
dag <- dagitty(paste("dag{", AllNodesAsText, "}"))
graphLayout(dag)
nudgedag <- tidy_dagitty(dag, seed = NULL, layout = "nicely") #fr, nicely, kk, "auto"
nudgexy <- nudgedag$data[, c("name","to","x","y")]
tdag <- tidy_dagitty(dag, seed = NULL, layout = "auto") #fr, nicely, kk, "auto"
factr = 0.1
tdag$data$y <- tdag$data$y + factr * nudgexy$y
#pw <- 0.9
#tdag$data$x <- sign(tdag$data$x) * abs(tdag$data$x)^pw
#tdag$data$xend <- sign(tdag$data$xend) * abs(tdag$data$xend)^pw
#tdag$data$y <- sign(tdag$data$y) * abs(tdag$data$y)^pw
#tdag$data$yend <- sign(tdag$data$yend) * abs(tdag$data$yend)^pw

ggplot(tdag, aes(x = x, y = y, xend = xend, yend = yend)) +
         geom_dag_node(alpha = 0.2) +
         geom_dag_text(color = "black") + #, check_overlap = T
         geom_dag_edges(mapping = aes(edge_alpha = 0.5)) +
         theme_dag() 
