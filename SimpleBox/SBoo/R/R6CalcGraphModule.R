#' @title CalcGraphModule
#' @description Mother of all Modules where all defining functions will be called
#' @import R6
#' @export
CalcGraphModule <-
  R6::R6Class(
    "CalcGraphModule",
    public = list(
      #' @description init
      #' @param TheCore the SBcore, parent object of self
      #' @param exeFunction defining function, usually the name of, as character, 
      #' for identification (a function does not know its own name)
      #' @param ... other parameters for various uses, end up in private$MoreParams
      initialize = function(TheCore, exeFunction, ...) {      
        try(private$Function <- get(exeFunction),silent = T)
        if (is.null(private$Function)) {
          try(private$Function <- private[[exeFunction]],silent = T) }
        if (is.null(private$Function)) { #still?
          stop("`exeFunction` is unknown", call. = FALSE)
        }
        private$MyName <- exeFunction
        private$MyCore <- TheCore
        private$MoreParams <- list(...)
      },
      
      #' @description fetch specific values from core
      #' @param withoutValues data.frame-ish with columns `varname` and needed D 
      fetch_current = function(withoutValues) {
        
        pervar <- split(withoutValues, f = withoutValues$varName)
        toJoin <- lapply(names(pervar), private$MyCore$fetchData)
        stillsplit <- lapply(1:length(pervar), function(i){
          specvar <- left_join(pervar[[i]], toJoin[[i]]) 
          names(specvar)[names(specvar) == names(pervar)[i]] <- "waarde"
          specvar
        })
        bind_rows(stillsplit)
      }
    ),
    active = list(
      #' @field myName the name of the defining function AND used to identify self
      myName = function(value) {
        if (missing(value)) {
          private$MyName
        } else {
          stop("`$MyName` is set at initialize()", call. = FALSE)
        }
      },
      #' @field exeFunction r.o. property: the actual function that will be called
      exeFunction = function(value) {
        if (missing(value)) {
          private$Function
        } else {
          stop("`$exeFunction` is set at initialize()", call. = FALSE)
        }
      },
      #' @field myCore r.o. property, see parameter TheCore at initialize
      myCore = function(value) {
        if (missing(value)) {
          private$MyCore
        } else {
          stop("`$myCore` is set at initialize()", call. = FALSE)
        }
      },
      #' @field needVars parameter names of exefunction; used for the calculation graph
      needVars = function(value) {
        if (missing(value)) {
          if (is.null(private$NeedVars)) {
            private$NeedVars <- private$initNeedVars()
          } 
          private$NeedVars
        } else {
          private$NeedVars <- value
        }
      },
      #' @field FromAndTo used for processes and flows; from which state(box) to what other state
      FromAndTo = function(value) {
        if (missing(value)) {
          stop("Property FromAndTo must be overruled")
        } else {
          stop("FromAndTo is a property")
        }
      }
    ),
    
    private = list(
      
      MyCore = NULL,
      MyName = NULL,
      Function = NULL,
      MoreParams = NULL,
      NeedVars = NULL,

      Execute = function(debugAt = NULL){ #debug can be list of (3D)names with values
        #All transfers from an to states for which the exefunction is called
        #TODO remove this wizard mode
        #to debug the assembly of data 
        if ("assembly" %in% names(debugAt)) {
          browser()
        }
        
        AllIn <- try(self$FromAndTo)
        NeededNames <- names(AllIn)
        #Limit to the actual states; Mind the relevant dimensions
        #Species are included for processes; NOT for flows; 
        #For flows a single to dimension is relevant and present
        if ("FlowModule" %in% class(self)) {
          AllIn <- dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame,
                                     join_by(fromScale == Scale,
                                             fromSubCompart == SubCompart))
          if ("toScale" %in% names(AllIn)) {
            AllIn <- dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame,
                                       join_by(toScale == Scale))
          } else {
            AllIn <- dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame,
                                       join_by(toSubCompart == SubCompart))
          }
          AllIn <- unique(AllIn[, NeededNames])
        } else {
          AllIn <- dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame,
                                     join_by(fromScale == Scale,
                                             fromSubCompart == SubCompart,
                                             fromSpecies == Species))
          AllIn <- dplyr::inner_join(AllIn, private$MyCore$states$asDataFrame,
                                     join_by(toScale == Scale,
                                             toSubCompart == SubCompart,
                                             toSpecies == Species))
          AllIn <- unique(AllIn[, NeededNames])
        }
        
        if (!isa(AllIn, "data.frame") || nrow(AllIn) == 0) {
          warning(paste("No transfers found for", private$MyName))
          return(list(DimsIn = NA, AllIn = AllIn, AllOut = data.frame(NA)))
        }
        NArows <- AllIn[rowSums(is.na(AllIn))!=0,]
        if (nrow(NArows) > 0 ){
          #browser()
          warning(paste("FromAndTo for ", private$MyName, "has NA in its dimensions;", length(NArows), "rows are removed"))
          AllIn <- complete.cases(AllIn)
        }
        #only the dimensions, for future use
        DimsIn <- AllIn
        
        # prepare which parameters(variables) are needed for the process function and their properties
        Fpars <- formalArgs(private$Function)
        #stopifnot("..." %in% Fpars)
        Fpars <- Fpars[Fpars!="..."] #not needed for Fpars
        if (!is.null(self$Withflow) && !anyNA(self$WithFlow)){ #special case of an advection process
          #the body of the exeFunction is actually using flow from Flows
          Fpars <- Fpars[Fpars!="flow"]
        }
        
        #Cnts <- sapply(Fpars, length)
        
        Fpars <- data.frame(
          FullName = unlist(Fpars),
          from = as.logical(startsWith(unlist(Fpars), "from.")),
          to = as.logical(startsWith(unlist(Fpars), "to.")),
          all = as.logical(startsWith(unlist(Fpars), "all.")),
          stringsAsFactors = F
        )
        Fpars$AttrName <- case_when( #strip the to. from. all. if present
          Fpars$from ~ substring(Fpars$FullName,6),
          Fpars$to ~ substring(Fpars$FullName,4),
          Fpars$all ~ substring(Fpars$FullName,5),
          T ~ Fpars$FullName)
        # deal with .all separately:
        all.tables <- list() #can remain empty => no lapply but for loop
        for (allParRow in which(Fpars$all)) {
          all.tables[[Fpars$FullName[allParRow]]] <- private$MyCore$fetchData(Fpars$AttrName[allParRow])
        }
        #continue with all other Fpars
        Fpars <- Fpars[!Fpars$all,]
        # get table name with attribute; each line separate, 
        # because from. and to. can have identical AttrName
        MetaData <- private$MyCore$metaData()
        Fpars$Tables <- sapply(Fpars$AttrName, function(x){
          MetaData$Tablenames[MetaData$AttributeNames == x]
        })
        #get the flows from the Flows table
        flows <- private$MyCore$fetchData("Flows")
        FlowNames <- private$withFlow
        if ("flow" %in% Fpars$FullName | (!anyNA(FlowNames)) && length(FlowNames) > 0) {
          if ("flow" %in% Fpars$FullName) { #the process
            AllIn <- merge(AllIn, flows[,names(flows)[names(flows) != "FlowName"]])
          } else {
            flowTables <- lapply(FlowNames, function(aFlow){
              Aflowtable = private$MyCore$fetchData(aFlow)
              names(Aflowtable)[names(Aflowtable) == "from.ScaleName"] <- "fromScaleName"
              names(Aflowtable)[names(Aflowtable) == "to.ScaleName"] <- "toScaleName"
              names(Aflowtable)[names(Aflowtable) == "from.SubCompart"] <- "fromSubCompart"
              names(Aflowtable)[names(Aflowtable) == "to.SubCompart"] <- "toSubCompart"
              Aflowtable
            })
            flowTable <- do.call(rbind, flowTables)
            # future precaution; can there be multiple flows with identical from-to states?
            Doubleflow <- aggregate(FlowName ~ fromScale + fromSubCompart + toScale + toSubCompart, data = flowTable, FUN = length)
            if (any(Doubleflow$FlowName > 1)){
              browser()
            }
            flowTable$FlowName <- NULL
            # flowTables are limiting the dimensions, for processes: expanding to species!
            AllIn <- merge(AllIn, flowTable) #
          }
          if (nrow(AllIn) == 0) {
            warning(paste("No more inputs in", self$myName, "after merge with flows"))
            return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = data.frame(NA)))
          }
          #no longer needed in Fpars
          Fpars <- Fpars[Fpars$AttrName != "flow",]
        }

        #quite an exception, but what to do if fpars is empty? skip those parameters!
        if (nrow(Fpars) > 0) {
          MultTable <- sapply(Fpars$Tables, length)
          if (!all(MultTable > 0)) {
            ErrorRow <- which(MultTable != 1)
            #browser()
            warning(paste("error: variable not found in tables;", Fpars$FullName[ErrorRow], ":" ,Fpars$Tables[ErrorRow]))
            return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = data.frame(NA)))
          }
          
          # Which of the dimensions are key-field for the parameters; excluding the "all." tables
          Dims <- as.data.frame(t(sapply(Fpars$Tables, function(x){
            The3D %in% MetaData$AttributeNames[MetaData$Tablenames == x]
          })))
          names(Dims) <- The3D
          
          Fpars <- cbind(Fpars, Dims)
          Fpars$Scale <- ifelse(Fpars$Scale==T,
                                ifelse(Fpars$to, "toScale", "fromScale"),
                                NA)
          Fpars$SubCompart <- ifelse(Fpars$SubCompart==T,
                                     ifelse(Fpars$to, "toSubCompart", "fromSubCompart"),
                                     NA)
          #Species are included for processes; NOT for flows; prevent permutations?
          if (!"FlowModule" %in% class(self)) {
            Fpars$Species <- ifelse(Fpars$Species==T,
                                    ifelse(Fpars$to, "toSpecies", "fromSpecies"),
                                    NA)
          }
          if (nrow(Fpars) == 0) { 
            #browser() #should go out?
            warning(paste("no data for ", private$MyName))
            return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = data.frame(NA)))
          }

          # fetch the data
          for (i in 1:nrow(Fpars)) {
            TheDataColumn <- private$MyCore$fetchData(Fpars$AttrName[i]) 
            if (length(TheDataColumn) == 1) {#from Global (atomic, not a dataframe)
              AllIn[,Fpars$AttrName[i]] <- TheDataColumn
              #rename from the name in datalayer to argument name, potentially including to. (or from. )
              names(AllIn)[names(AllIn) == Fpars$AttrName[i]] <- Fpars$FullName[i] 
            } else {
              TheDataColumn <- private$MyCore$filterStatesFrame(TheDataColumn)
              # rename column to FullName, also if default from. was used
              names(TheDataColumn)[names(TheDataColumn) == Fpars$AttrName[i]] <- Fpars$FullName[i]
              # merge, handling the to. and/or from. naming
              ByX <- Fpars[i, names(TheDataColumn)[names(TheDataColumn)!=Fpars$FullName[i]]]
              ByX <- ByX[!is.na(ByX)]
              ByY <- The3D[The3D %in% names(TheDataColumn)]
              names(ByY) <- ByX
              AllIn <- dplyr::full_join(AllIn, TheDataColumn, by = ByY)#, by.x = ByX, by.y = ByY) 
              if (anyNA(AllIn$process)) {
                warning(paste("input data ignored; not all ", Fpars$FullName[i], "in FromAndTo property"))
                AllIn <- AllIn[!is.na(AllIn$process),]
              }
            }
          }
        }
        #filter?
        AllIn <- private$MyCore$filterStatesFrame(AllIn)
        #The columns from AllIn are not used in the exefunction, will be removed; stored in DimsIn:
        ColumnsToKeep <- names(AllIn)[!names(AllIn) %in% names(DimsIn)]
        ColumnsForDims <- names(AllIn)[names(AllIn) %in% names(DimsIn)]
        #redo DimsIn, because tidy reorders !
        DimsIn <- AllIn[,ColumnsForDims, drop = FALSE]
        AllIn <- AllIn[,ColumnsToKeep, drop = FALSE]

        if (nrow(AllIn) == 0){  #what's going on??
          warning(paste("no input rows for ", private$MyName))
          return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = data.frame(NA)))
        }
        #prep debugnames for use in loop; empty if only "assembly" is active
        if (!is.null(debugAt)) {
          namesdebugAt <- names(debugAt)[names(debugAt) != "assembly"]
          if (length(namesdebugAt) == 0) {
            debugAt <- list()
          } else {
            debugAt <- debugAt[namesdebugAt]
          }
        }
        #Call function for each row; debug-mode if indicated by debugAt
        res <- list()
        for (i in 1:nrow(AllIn)){
          #list of regular parameters, i.e. either to. or from. type
          vCalc <- lapply(AllIn, function (x){ x[i] })
          if (!is.null(debugAt)){
            ToDebug <- T
            if (length(namesdebugAt) > 0){
              for (j in 1:length(namesdebugAt)){
                if (!names(debugAt)[[j]] %in% names(vCalc)){
                  stop(paste(names(debugAt)[[j]], "not in", names(vCalc)))
                }
                if (vCalc[[names(debugAt)[[j]]]] != debugAt[[j]]){
                  ToDebug <- F
                  break
                }
              }
            }
            if (ToDebug) debugonce(self$exeFunction)
          }
          res[[i]] <- do.call(self$exeFunction, c(vCalc, all.tables))
        }
        #check for anomalies
        resLength <- sapply(res, length)
        if(any(resLength != 1)) {
          #browser()
          warning(paste ("error in row(s)", which(resLength != 1, arr.ind = T)), "check in AllIn")
          return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = data.frame(NA)))
        } else {
          
          return(list(DimsIn = DimsIn, AllIn = AllIn, AllOut = unlist(res)))
        }
      },
      
      initNeedVars = function(){
        p.args <- formalArgs(private$Function)
        #cut from. and to.
        Puntfrom <- as.logical(startsWith(unlist(p.args), "from."))
        Puntto <- as.logical(startsWith(unlist(p.args), "to."))
        Puntall <- as.logical(startsWith(unlist(p.args), "all."))
        p.args <- case_when(
          Puntfrom ~ substring(p.args,6),
          Puntto ~ substring(p.args,4),
          Puntall ~ substring(p.args,5),
          T ~ p.args
        )
        #exclude the ... -> always used for Dimensions
        excld <- p.args == "..."
        #special for those from the Mlike excel base to put them in the nodelist for the DAG
        #ToDo elswhere ?
        #MetaData <- private$MyCore$metaData()
        #InSBdata <- sapply(p.args, function(x){
        #  x %in% MetaData$AttributeNames
        #})
        #p.args[!InSBdata]
        p.args[!excld]
      }
      
    )
  )