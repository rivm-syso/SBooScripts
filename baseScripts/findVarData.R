# grab variable data from SBoo csvs.
# 
# we need 
library(tidyverse)

DefKeys <- read.csv("data/Defs.csv")
#obtain (unique) Defs in this order
DefDups <- duplicated(DefKeys$Defs)
Defs <- DefKeys$Defs[!DefDups]

# #read them into a list of d.f
# MlikeWorkBook <- lapply(Defs, function (TheSheet) {
#   openxlsx::read.xlsx(xlsxFile = "data/ooMs.xlsx",
#                       sheet = TheSheet,
#                       startRow = 3) #two lines were for comments
# })

MlikeWorkBook <- lapply(Defs, function(tableName) {
  assign(tableName, read.csv(
    paste("data/", tableName, ".csv", sep = "")))
})
names(MlikeWorkBook) <- Defs

PullVar <- function(MlikeListDF, Look4Var){
  for (dsheet in Defs){ #dsheet = Defs[1]
    res <- NULL # future return variable
    DataSheet <- MlikeListDF[[dsheet]]
    Keys <- DefKeys$Key[DefKeys$Defs == dsheet]
    if ("VarName" %in% names(MlikeListDF[[dsheet]])){
      #is it wide format or long?
      if (length(Keys) == 1) {
        stop("can't be??, expected wide format")
      } else {
        RowsWithVar <- DataSheet$VarName == Look4Var
        if (any(RowsWithVar)){
          OtherKeys <- Keys[Keys != "VarName"]
          return(DataSheet[RowsWithVar, c(OtherKeys, "Waarde")])
        }
      }
    } else { #Varname not a column; either process, wide or monstrous
      if (length(Keys) == 1) {
        if (Look4Var %in% names(DataSheet)){
          return(DataSheet[, c(Keys, Look4Var)])
        } 
      } else { #process
        RowsWithVar <- DataSheet$process == Look4Var
        if (any(RowsWithVar)) {
          OtherKeys <- Keys[Keys != "process"]
          res <- DataSheet[RowsWithVar, OtherKeys]
          # TODO fetch other 2 dimensions for the exceptions
          return(res)
        }
      }
    }
  }
  cat("monstrous; deal with it")
  return(MlikeListDF["SomeFromTo"])
}
#debugonce(PullVar)
PullVar(MlikeWorkBook, "AEROSOLdeprate")
PullVar(MlikeWorkBook, "FRACa")
PullVar(MlikeWorkBook, "k_Advection_Air")

WithoutVar <- function(MlikeListDF, Look4Var){
  for (dsheet in Defs){ #dsheet = Defs[1]
    res <- NULL # future return variable
    DataSheet <- MlikeListDF[[dsheet]]
    Keys <- DefKeys$Key[DefKeys$Defs == dsheet]
    if ("VarName" %in% names(MlikeListDF[[dsheet]])){
      RowsWithVar <- DataSheet$VarName == Look4Var
      if (any(RowsWithVar)){
        MlikeListDF[[dsheet]] <- DataSheet[!RowsWithVar, ]
      }
    } else { #Varname not a column; either process, wide or monstrous
      if (length(Keys) == 1) {
        if (Look4Var %in% names(DataSheet)){
          AllBut <- names(DataSheet)[names(DataSheet) != Look4Var]
          MlikeListDF[[dsheet]] <- DataSheet[, AllBut] 
        } 
      } else { #process
        RowsWithVar <- DataSheet$process == Look4Var
        if (any(RowsWithVar)) {
          MlikeListDF[[dsheet]] <- DataSheet[!RowsWithVar,]
          # TODO remove other 2 dimensions for the exceptions
          
        }
      }
    }
  }
  return(MlikeListDF)
}

FRACaData <- PullVar(MlikeWorkBook,"FRACa")
nrow(FRACaData)
#debugonce(WithoutVar)
WithoutFRACa <- WithoutVar(MlikeWorkBook,"FRACa")
lapply(WithoutFRACa, nrow)
lapply(MlikeWorkBook, nrow)

# MlikeListDF = MlikeWorkBook; VarName = "FRACa"; NewVarData = FRACaData
MergeVar <- function (WithoutFRACa, VarName, NewVarData){
  #keys in NewVarData
  PosNames <- sapply(names(NewVarData), function(InVec) {
    match(InVec, DefKeys$Key)
  })
  keys <- c("VarName", names(PosNames)[!is.na(PosNames)])
  HasKey <- DefKeys$Key %in% keys
  SumKeys <- table(DefKeys$Defs) %>% as.data.frame()
  AllKeys <- aggregate(HasKey, list(DefKeys$Defs), FUN = sum)
  TheOne <- which(SumKeys$Freq == length(keys) &
                    AllKeys$x  == length(keys))
  TableName <- levels(SumKeys$Var1)[SumKeys$Var1[TheOne]]
  NewVarData$VarName <- VarName
  WithoutFRACa[[TableName]] <- bind_rows(WithoutFRACa[[TableName]], NewVarData)
  return(WithoutFRACa)
}

Mdinge <- MergeVar(WithoutFRACa, "FRACa", FRACaData)


##### read process data from excel
ProcessXlsx <- "data/ExampleProcess.xlsx" 
processName <- unname(unlist(openxlsx::read.xlsx(ProcessXlsx, colNames=FALSE,
                                                 namedRegion = "process")))
TransDim <- unname(unlist(openxlsx::read.xlsx(ProcessXlsx, colNames=FALSE,
                                              namedRegion = "TransDim")))
fromTo <- openxlsx::read.xlsx(ProcessXlsx, colNames=TRUE,
                              namedRegion = "fromTo")
exceptions <- openxlsx::read.xlsx(ProcessXlsx, colNames=TRUE,
                                  namedRegion = "exceptions")

#helping hand; to fully test, we need a initializing (The3D)
source("baseScripts/fakeLib.R")
if (!TransDim %in% The3D) {
  stringsAsList <- as.list(c("TransDim should be one of", The3D))
  stop(do.call(paste, stringsAsList))
}
if(!all(names(exceptions) %in% The3D)) {
  stringsAsList <- as.list(c("exception columns should be empty or one of", The3D))
  stop(do.call(paste, stringsAsList))
}
if (TransDim %in% names(exceptions)) {
  stop("exception columns should differ from TransDim")
}

#possibly remove existing data for this process
for (TheDim in The3D) {#TheDim = The3D[1]
  dataFrameName <- paste(TheDim, "Processes", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  ThisProcessRows <- dataFrame$process == processName
  if (any(ThisProcessRows)) {
    cat(paste("process updated in", dataFrameName))
    MlikeWorkBook[[dataFrameName]] <- dataFrame[!ThisProcessRows,]
  }
  #exceptions; as columns of
  dataFrameName <- paste(TheDim, "Sheet", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  if (processName %in% names(dataFrame)) {
    cat(paste("exceptions updated in", dataFrameName))
    minCol <- match(processName, names(dataFrame))
    MlikeWorkBook[[dataFrameName]] <- dataFrame[, -minCol]
  }
}
#add new data
dataFrameName <- paste(TransDim, "Processes", sep = "")
ReplacePart <- fromTo
ReplacePart$process <- processName
OldProcessData <- MlikeWorkBook[[dataFrameName]]
MlikeWorkBook[[dataFrameName]] <- rbind(
  OldProcessData,
  ReplacePart[,names(OldProcessData)])

#exceptions; as columns of
for (TheDim in names(exceptions)) {#TheDim = names(exceptions)[1]
  dataFrameName <- paste(TheDim, "Sheet", sep = "")
  dataFrame <- MlikeWorkBook[[dataFrameName]]
  ToFalse <- dataFrame[,TheDim] %in% exceptions[,TheDim]
  MlikeWorkBook[[dataFrameName]] <- dataFrame %>%
    mutate({{processName}} := !ToFalse)
}

