#' @title ClassicNanoWorld
#' @description the centre object for running simple box with an R script.
#' @import R6
#' @export
ClassicNanoWorld <- R6::R6Class(
  "ClassicNanoWorld",
  inherit = StateModule,
  public = list(
    #' @description init
    #' @param MlikeFile location for standard input data
    #' @param Substance The substance for which all calculation are. 
    initialize = function(MlikeFile, Substance = "default substance") {
      #TODO private$Defs should be read from data/Defs.csv
      if (is.list(MlikeFile)) {
        if (!All(names(MlikeFile)) %in% private$Defs)
            stop("not all needed sheets in MlikeFile", call. = FALSE)
        
      }  else {#it must be a path to an excelfile with required sheets
        if (dir.exists(MlikeFile)) {
          MlikeWorkBook <- private$readMasCsvs(MlikeFile)
        } else {
          if (!file.exists(MlikeFile))
            stop("MlikeFile does not exist", call. = FALSE)
          MlikeWorkBook <- lapply(private$Defs, function (TheSheet) {
            openxlsx::read.xlsx(xlsxFile = MlikeFile,
                                sheet = TheSheet,
                                startRow = 3)
          })
        }
        if (length(MlikeWorkBook) != length(private$Defs))
            stop("data is incomplete; check the tables", call. = FALSE)
        names(MlikeWorkBook) <- private$Defs
        
      }
      self$substance <- Substance

      #sets states and SB4N data, after inheritance compart -> subcompart, etc.
      private$DeriveState(MlikeWorkBook)
      
    }

  ),
  active = list(
    #' @field varOrigine getter for r.o. property
    varOrigine = function(value) {
      if (missing(value)) {
        private$VarOrigine
      } else {
        stop("`$varOrigine` are set by new()", call. = FALSE)
      }
    }
  ),
  private = list(
    #With "inheriting", merging constants / substance properties etc
    #It's usefull to store the originating table/csv-filename of each variable
    #this private stuff should be injected in Core 
    VarOrigine = data.frame(
      VarName = c(""),
      table = c("")
    ),
    
    #initial dataframes from M 
    Defs = c(
      "ScaleSubCompartData",
      "ScaleSpeciesData",
      "SubCompartSpeciesData",
      "ScaleSheet",
      "SubCompartSheet",
      "SpeciesSheet",
      "ScaleProcesses",
      "SubCompartProcesses",
      "SpeciesProcesses",
      "Compartments",
      "Substances",
      "SpeciesCompartments",
      "SubstanceCompartments",
      "SubstanceSubCompartSpeciesData",
      "CONSTANTS",
      "MatrixSheet",
      "FlowIO",
      "QSARtable",
      "SomeFromTo",
      "Units"
    ),
    RowIdentifyers = c(
      The3D, "Species", 
      "to.Scale", "to.SubCompart", "to.Species", 
      "Substance", "process", "Matrix", "from", "to", "QSAR.ChemClass"
    ),
    readMasCsvs = function(MlikeFile){
      RetList <- list()
      VarOrigine = data.frame(
        VarName = c(""),
        table = c("")
      )
      AllDefs <- private$Defs
      for (Def in AllDefs[AllDefs != "Units"]) {
        tableName <- read.csv(
          paste(MlikeFile, "/", Def, ".csv", sep = ""))
        if("VarName" %in% names(tableName)) {
          VarNames <- unique(tableName$VarName)
        } else {
          VarNames <- names(tableName)[!names(tableName) %in% private$RowIdentifyers]
        }
        if (length(VarNames) > 0) {
          ToAdd <- data.frame(
            VarName = VarNames,
            table = Def
          )
          VarOrigine <- rbind(
            VarOrigine[VarOrigine$VarName > "",], #was
            ToAdd
          )
        }
        RetList[[Def]] <- tableName
      }
      RetList[["Units"]] <- read.csv(
        paste(MlikeFile, "/Units.csv", sep = ""))
      private$VarOrigine <- VarOrigine
      return(RetList)
    },

  # worker functions #####
  
  #local functions
  #' #description extend subcompart with compart properties
  ExpandCompart = function(ListOfFrames) { # to subcompartments in relevant data sheets
    Comparts <- ListOfFrames$Compartments
    SubComparts <- ListOfFrames$SubCompartSheet
    MatchSub <- match(SubComparts$Compartment, Comparts[,1])
    for(i in (2:ncol(Comparts))) {
      SubComparts$newcol <- Comparts[MatchSub,i]
      names(SubComparts)[names(SubComparts)=="newcol"] <- names(Comparts[i])
    }
    ListOfFrames$SubCompartSheet <- SubComparts
    ListOfFrames
    #SubComparts
  },
  
  DeriveState = function (InPutDataFrames) {
    # states are all permutations of the 3 dimensions, see 
    # speciessheet, subcompartsheet and scalesheet;
    # (for historic reasons `Default` attribute is used)
    # except some combinations excluded by logic in the code of this function

    # helper function FrameNumbers()
    #try convert data.frame to numbers, other levels to strings
    FrameNumbers <- function (xf) {
      #try trim variable names
      names(xf) <- trimws(names(xf), whitespace = "[ .\t\r\n]")
      newCols <- lapply(xf, function(xc){
        if (length(levels(xc)) > 0) {
          suppressWarnings(PosLevels <- as.numeric(levels(xc)))
          # is is numeric, possibly including NA's ? -> 
          if (all(is.na(PosLevels) == is.na(levels(xc)))) return(PosLevels[xc]) else 
            return (levels(xc)[xc])
        } else {
          if (is.logical(xc)) {
            # "F" / "T" are cast to logicals, but should not be
            return(ifelse(xc, "T", "F"))
          } else {
            suppressWarnings(testxc <- as.numeric(xc) )
            if (all(is.na(testxc) == is.na(xc))) return(testxc) else
              return(xc)
          }
        }
      })
      return(data.frame(newCols, stringsAsFactors = F))
    }
    
    #actual method DeriveState #####
    #browser()
    #expanding in The3D
    ToPermute <- lapply(The3D, function(TheD) {
      TheSheetName = paste0(TheD, "Sheet")
      TheSheet <- InPutDataFrames[[TheSheetName]]
      TheSheet[TheSheet$Default == 1, TheD]
    }) 
    States <- do.call(expand.grid.df, ToPermute)
    names(States) <- The3D
    
    #  not all combi's exist as State
    ##   there is no regional/continental deepocean
    ##   only at regional+continental scale there is agriculturalsoil, naturalsoil and freshwaters
    scalesGlobal <- InPutDataFrames[["ScaleSheet"]][,c("ScaleName", "ScaleIsGlobal")]
    subcompartNotGlobal <- InPutDataFrames[["SubCompartSheet"]][,c("SubCompartName", "NotInGlobal")]
    r.c.scales <- scalesGlobal$ScaleName[!(scalesGlobal$ScaleIsGlobal)]
    r.c.comparts <- subcompartNotGlobal$SubCompartName[subcompartNotGlobal$NotInGlobal]
    compInr.c.comparts <- States$SubCompart %in% r.c.comparts
    outSpM <- r.c.scales == F & compInr.c.comparts == T
    outSpM <- outSpM | (r.c.scales == T & (States$SubCompart == "deepocean"))
    States <- States[!outSpM,]
    #There's no Unbound in cloudwater
    States <- States[States$SubCompart!="cloudwater" |
                       States$Species!="Unbound",]
    #cleanup fase 1
    rm(r.c.scales,r.c.comparts,compInr.c.comparts,outSpM)
    
    # Matching codes for excel data; Not needed after converting into functions; future cleanup...
    # All parameters are matched to a State (SubCompart, Scale,Species) by abbreviations, see...
    # Here the matching is executed by an index: States$Abbr; mapping to this index by FindState()
    States$Abbr <- paste(
      InPutDataFrames[["SubCompartSheet"]]$AbbrC[match(States$SubCompart, InPutDataFrames[["SubCompartSheet"]]$SubCompart)],
      InPutDataFrames[["ScaleSheet"]]$AbbrS[match(States$Scale, InPutDataFrames[["ScaleSheet"]]$Scale)],
      InPutDataFrames[["SpeciesSheet"]]$AbbrP[match(States$Species, InPutDataFrames[["SpeciesSheet"]]$Species)], sep = "")
    
    #arrange data layer
    # inherite SubstanceCompartments to SubstanceSubCompart (new because no data entries on that key combinations)
    if (nrow(InPutDataFrames[["SubstanceCompartments"]] ) > 0) {
      Vars <- unique(InPutDataFrames[["SubstanceCompartments"]]$VarName)
      newDataFrame <-  merge(
        InPutDataFrames[["SubstanceCompartments"]], 
        InPutDataFrames[["SubCompartSheet"]][,c("Compartment", "SubCompart")])
      InPutDataFrames[["SubstanceSubCompart"]] <- newDataFrame[newDataFrame$Substance %in% self$substance,  c("VarName", "Substance", "Waarde", "SubCompart")]
    } 
    #  Substance properties to be pasted to CONSTANTS later
    ThisSubstance <- InPutDataFrames[["Substances"]][InPutDataFrames[["Substances"]]$Substance == self$substance,]
    # except:  
    ThisSubstance$Substance <- NULL
    
    #"inherit" Matrix to SubCompart
    SubCompartSheet <- InPutDataFrames[["SubCompartSheet"]] #NB also used in compartment inheritance
    MatrixSheet <- InPutDataFrames[["MatrixSheet"]]
    #check for common field .. can only be matrix
    theMatrix <- names(MatrixSheet)[names(MatrixSheet) %in% names(SubCompartSheet)]
    stopifnot(length(theMatrix) == 1)
    SubCompartSheet <- left_join(SubCompartSheet, MatrixSheet)

    #"inherit" Compartments to SubCompart
    Compartments <- InPutDataFrames[["Compartments"]]
    TheCompartment <- names(Compartments)[names(Compartments) %in% names(SubCompartSheet)]
    stopifnot(length(TheCompartment) == 1)
    SubCompartSheet <- left_join(SubCompartSheet, Compartments)
    #store the result back into InPutDataFrames
    InPutDataFrames[["SubCompartSheet"]] <- SubCompartSheet
    
    # move SubstanceSubCompartSpeciesData[substance] to SubCompartSpecies
    ToSubCompartSpecies <- InPutDataFrames[["SubstanceSubCompartSpeciesData"]][InPutDataFrames[["SubstanceSubCompartSpeciesData"]]$Substance == self$substance,]
    if (nrow(ToSubCompartSpecies) > 0 ){
      ToSubCompartSpecies$Substance <- NULL
      SubCompartSpeciesData <- rbind(InPutDataFrames[["SubCompartSpeciesData"]], ToSubCompartSpecies)
    } else SubCompartSpeciesData <- InPutDataFrames[["SubCompartSpeciesData"]]
    # Expand SpeciesCompartments to SubCompartSpeciesData
    #SubCompart	Species	VarName	Waarde	SB4N_name	Unit
    
    SpeciesCompartments <- InPutDataFrames[["SpeciesCompartments"]]
    eachCompart <- split(SpeciesCompartments, SpeciesCompartments$Compartment)
    foreachCompart <- lapply(eachCompart, function (x) {
      WasCompart <- x$Compartment[1]
      ShouldSubCompart <- SubCompartSheet$SubCompart[SubCompartSheet$Compartment == WasCompart]
      xs <- as.data.frame(lapply(x, rep, length(ShouldSubCompart)), stringsAsFactors = F)
      xs$SubCompart <- rep(ShouldSubCompart, each = nrow(xs) / length(ShouldSubCompart))
      xs
    })
    ExpdSpeciesCompartments <- do.call(rbind, foreachCompart)
    ExpdSpeciesCompartments$SB4N_name <- "missing"
    SubCompartSpeciesData <- rbind(SubCompartSpeciesData, ExpdSpeciesCompartments[,c(
      "SubCompart", "Species", "VarName", "Waarde", "SB4N_name", "Unit"
    )])
    InPutDataFrames[["SubCompartSpeciesData"]] <- SubCompartSpeciesData
    # convert relational tables into proper dataframe
    #TODO improve dealing with multiple keys and long format; not by table name...
    for (tab in c("SubCompartSpeciesData", "ScaleSpeciesData", "ScaleSubCompartData", "SubstanceSubCompart")) {
      SelNames <- names(InPutDataFrames[[tab]])[!names(InPutDataFrames[[tab]]) %in% c("SB4N_name", "Unit")]
      InPutDataFrames[[tab]] <- pivot_wider(InPutDataFrames[[tab]][,SelNames], 
                                            names_from = VarName, values_from = Waarde) %>%
        as.data.frame()
    }
    # "CONSTANTS" is too simple for pivot_wider? Add Substance properties as constants
    GlobAsList <- as.list(c(InPutDataFrames[["CONSTANTS"]]$Waarde, ThisSubstance))
    names(GlobAsList) <- c(InPutDataFrames[["CONSTANTS"]]$VarName, names(ThisSubstance))
    InPutDataFrames[["CONSTANTS"]] <- do.call(data.frame, GlobAsList)
    
    #thank you and goodbye for
    InPutDataFrames[["Compartments"]] <- NULL
    InPutDataFrames[["SpeciesCompartments"]] <- NULL
    #InPutDataFrames[["Substances"]] <- NULL
    #InPutDataFrames[["SubstanceCompartments"]] <- NULL
    
    #InPutDataFrames[["SubstanceSubCompartSpeciesData"]] <- NULL
    #InPutDataFrames[["CONSTANTS"]] <- NULL
    
    #alphanumbers 2 numbers and factors? to strings
    for (i in 1:length(InPutDataFrames)){
      InPutDataFrames[[i]] <- FrameNumbers(InPutDataFrames[[i]])
    }
    #A data table of the 3D combined is missing in the data tables. We create it..
    InPutDataFrames[[do.call(paste,as.list(c(The3D, "Data", sep = "")))]] <- States[F, The3D]
    
    #And the table for the special "flow" variable
    InPutDataFrames[["Flows"]] <- data.frame(
      FlowName = character(),
      fromScale = character(),
      toScale  = character(), 
      fromSubCompart = character(),
      toSubCompart = character(),
      flow = double()
    )
    
    #Cleanup - warnings; All data should have at least 1 entry in States
    for (tble in InPutDataFrames){
      WhichD <- The3D %in% names(tble)
      if (any(WhichD == T)) {
        Dims <- tble[,The3D[WhichD]]
        MergeT <- merge(Dims, States, all.x = T)
        MergeT <- MergeT[is.na(MergeT$Abbr),]
        if (nrow(MergeT>1)) {
          MergeT
          stop(paste(tble, "contains dimension(s) not in states"))
        }
      }
    }


    #We will need a separate table of 
    self$states <- States
    self$SB4N.data <- InPutDataFrames
    
  })
)
