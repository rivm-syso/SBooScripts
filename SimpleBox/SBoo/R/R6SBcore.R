#' @title SBcore
#' @description the centre object for running simple box with an R script.
#' @import R6
#' @export
SBcore <- R6::R6Class("SBcore",
  public = list(
    #' @description init
    #' @param NewstateModule The stateModule with its States and standard input data
    initialize = function(NewstateModule){
      private$SB4Ndata <- NewstateModule$SB4N.data
      #hacked into SB4N.data directly, fetch routines are not yet available in this stage...
      ToBeSorted <- merge(NewstateModule$states, NewstateModule$SB4N.data[["ScaleSheet"]][,c("Scale", "ScaleOrder")]) %>%
        merge(NewstateModule$SB4N.data[["SubCompartSheet"]][,c("SubCompart", "SubCompartOrder")]) %>% 
        merge(NewstateModule$SB4N.data[["SpeciesSheet"]][,c("Species", "SpeciesOrder")])
      newOrder <- order(ToBeSorted$ScaleOrder, ToBeSorted$SubCompartOrder, ToBeSorted$SpeciesOrder)
      private$States <- SBstates$new(ToBeSorted[newOrder, c("Scale", "SubCompart", "Species", "Abbr")])
      private$States$myCore <- self
      private$Substance <- NewstateModule$substance
      private$ModuleList <- list()
      #prepare the names of variables that become dirty id substance is changed
      colnamesSubstaces <- names(NewstateModule$SB4N.data[["Substances"]])
      SubstanceCompartmentsVarNames <- unique(NewstateModule$SB4N.data[["SubstanceCompartments"]]$VarName)
      SubstanceCompartmentsSpeciesVarNames <- unique(NewstateModule$SB4N.data[["SubstanceSubCompartSpeciesData"]]$VarName)
      private$substanceproperties <- c(colnamesSubstaces, SubstanceCompartmentsSpeciesVarNames, SubstanceCompartmentsSpeciesVarNames)
    },
    #' @description add a process to the calculations
    #' @param ProcessFunction The name (as character) of the process defining function 
    #' see 
    NewProcess = function(ProcessFunction){
      #existing function?
      stopifnot("function" %in% class(match.fun(ProcessFunction)))
      #delete, if it exists (being updated)
      if (ProcessFunction %in% names(private$ModuleList)){
        private$ModuleList <- private$ModuleList[private$ModuleList != ProcessFunction]
        private$nodeList <- private$nodeList[private$nodeList$Calc != ProcessFunction,]
      }
      aNewProcessModule <- ProcessModule$new(self,ProcessFunction)
      private$storeNodes(aNewProcessModule)
      private$ModuleList[[ProcessFunction]] <- aNewProcessModule
      invisible(aNewProcessModule)
    },
    
    #' @description remove a set of SB items from the calculations, for later reprocessing
    #' @param VarFunctions The name (as character) of the process defining function 2be postponed
    #' @param FlowFunctions The name (as character) of the process defining function 2be postponed
    #' @param ProcesFunctions The name (as character) of the process defining function 2be postponed
    #' @details The SBitems will be removed from the internal structures, but the names of their defining functions 
    #' will be stored locally. The private method DoPostponed will add and execute them. (This is automised, 
    #' because it will be needed in sensitivity analyses etc.)
    PostponeVarProcess = function(VarFunctions = NULL, FlowFunctions = NULL, ProcesFunctions) {
      #test if all exist
      #browser()
      for (modname in c(VarFunctions, FlowFunctions, ProcesFunctions)){
        TheModule <- self$moduleList[[modname]]
        if (is.null(TheModule)) {
          stop(paste("Module", modname, "does not exist; define it before setting it as postpone"))
        }
      }
      private$l_postPoneList <- list(VarFunctions, FlowFunctions, ProcesFunctions)
    },
    
    #' @description add a flow to the calculations
    #' @param FlowFunction The name (as character) of the flow defining function 
    #' see 
    #' @param WithProcess The name (as character) of the process related to this function
    #' This is normally the k_Advection process; created if not already present
    NewFlow = function(FlowFunction, WithProcess = "k_Advection"){
      #existing function?
      stopifnot("function" %in% class(match.fun(FlowFunction)))
      
      #delete FlowModule, if it exists already (being updated)
      if (FlowFunction %in% names(private$ModuleList)){
        private$ModuleList <- private$ModuleList[private$ModuleList != FlowFunction]
        private$nodeList <- private$nodeList[private$nodeList$Calc != FlowFunction,]
      }
      aNewFlowModule <- FlowModule$new(self, FlowFunction, WithProcess)
      private$storeNodes(aNewFlowModule)

      # book-keeping for the WithProcess
      stopifnot("function" %in% class(match.fun(WithProcess)))
      # is it an advection process, i.e. proper parameter(s)
      stopifnot("flow" %in% formalArgs(WithProcess))
      # make the process, if not present
      if (WithProcess %in% names(private$ModuleList)) {
        nodeProcess <- private$ModuleList[[WithProcess]]
      } else {
        nodeProcess <- self$NewProcess(WithProcess)
      }
      if(length(nodeProcess$WithFlow)==1 && anyNA(nodeProcess$WithFlow)){
        nodeProcess$WithFlow <- FlowFunction
      } else {
        nodeProcess$WithFlow <- c(nodeProcess$WithFlow, FlowFunction) 
      }
      # update needVars and private$nodeList for WithProcess; 
      # replace flow (the parameter in the function) with all individual flows, for DAG
      OrigVars <- formalArgs(WithProcess)
      nodeProcess$needVars <- c(OrigVars[OrigVars != "flow"], nodeProcess$WithFlow)
      #possibly replace existing Params "flow", or add the new flowname
      indProcess <- which(WithProcess == private$nodeList$Calc)
      matchWithFlow <- match("flow", private$nodeList$Params[indProcess])
      if (!is.na(matchWithFlow) && matchWithFlow > 0) {
        private$nodeList$Params[indProcess[matchWithFlow]] <- FlowFunction
      } else {
        private$nodeList[nrow(private$nodeList)+1,] <- c(WithProcess, FlowFunction, "Process")
      }
      private$ModuleList[[FlowFunction]] <- aNewFlowModule
      invisible(aNewFlowModule)
      
    },
    
    #' @description add a SBVariable to the calculations
    #' @param VariableFunction The name (as character) of the SBvariable defining function 
    #' see 
    #' @param AggrBy exceptional parameter to aggregate over a dim (1 of The3D)
    #' @param AggrFun FUN to use in aggregation over a dim (1 of The3D)
    NewCalcVariable = function(VariableFunction, AggrBy = NA, AggrFun = NA){
      #delete, if it exists (being updated)
      if (VariableFunction %in% names(private$ModuleList)){
        private$ModuleList <- private$ModuleList[private$ModuleList != VariableFunction]
        private$nodeList <- private$nodeList[private$nodeList$Calc != VariableFunction,]
      }
      aNewVariableModule <- VariableModule$new(self,VariableFunction, AggrBy = AggrBy, AggrFun = AggrFun)
      private$storeNodes(aNewVariableModule)
      private$ModuleList[[VariableFunction]] <- aNewVariableModule
      invisible(aNewVariableModule)
      
    },
    
    #' @description create and set the solver (there can only be one)
    #' @param SolverFunction The (name of) the solver defining function 
    #' @param ... passed on to init of SolverModule i.e. to CalcGraphModule$MoreParams
    #' for use in the defining function
    NewSolver = function(SolverFunction, ...){
      #existing function?
      stopifnot("function" %in% class(match.fun(SolverFunction)))
      private$solvername <- SolverFunction
      private$solver <- SolverModule$new(self, SolverFunction, ...)
    },
    
    #find the indices + states from a dataFrame with columns "Scale" "SubCompart" "Species"   
    FindStatefrom3D = function(df3Ds){
      stopifnot(all(The3D %in% names(df3Ds)))
      ret <- sapply(1:nrow(df3Ds), function(i){
        which(private$States$asDataFrame$Scale == df3Ds$Scale[i] &
                private$States$asDataFrame$SubCompart == df3Ds$SubCompart[i] &
                private$States$asDataFrame$Species == df3Ds$Species[i])
      })
      if (anyNA(ret)) {
        cat(df3Ds[is.na(ret), c("Scale", "SubCompart", "Species")])
        stop("State(s) not found")
      } else {
        return(ret)
      }
    },
    #' @description Run the matrix with exchange constants; 
    #' the exact calculation is described in the function that defined the solve module.
    #' This can be solving for the steady state or running the system for a period of time.
    #' Results are available 
    #' @param emissions data.frame-ish with columns "Abbr" (state defining character) and 
    #' "emis" numbers
    #' @param needdebug if T the defining function will open in debugging modus
    Solve = function(emissions, needdebug = F, ...){
      
      if (is.null(private$solver)) {
        warning("No active solver")
        return(NULL)
      }
      #browser()
      # prepare the kaas
      private$solver$PrepKaasM()
      
      private$solver$execute(needdebug = needdebug, emissions, ...)
      
    },
    
    #' @description Creates inverse functions for each row of the given dataframe
    #' @param paramdf A dataframe with one row for eacht distribution. Must at 
    #' least contain the columns "Distribution" (which can contain "triangular", "uniform" or "normal"), 
    #' "a", "b", and "c".
    #' 
    #' "a", "b" and "c" contain the following:
    #' triangular: a = Minimum, b = Maximum, c = Peak value
    #' normal: a = Mean, b = Standard deviation 
    #' uniform: a = Minimum , b = Maximum
    makeInvFuns = function(paramdf){
      
      # Define functions for each row based on the distribution type
      varFuns <- apply(paramdf, 1, function(aRow) {
        dist_type <- aRow["Distribution"]
        
        if (dist_type == "triangular" || dist_type == "Triangular") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c")]))
          names(prepArgs) <- c("a", "b", "c")
        } else if (dist_type == "normal" || dist_type == "Normal") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b")]))
          names(prepArgs) <- c("a", "b")
        } else if (dist_type == "uniform" || dist_type == "Uniform") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b")]))
          names(prepArgs) <- c("a", "b")
        } else if (dist_type == "log uniform" || dist_type == "Log uniform") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b")]))
          names(prepArgs) <- c("a", "b")
        } else if (dist_type == "TRWP_size") {
          prepArgs <- as.list(as.character(aRow[c("d")]))
          names(prepArgs) <- c("d")
        } else if (dist_type == "weibull" || dist_type == "Weibull") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c")]))
          names(prepArgs) <- c("a", "b", "c")
        } else if (dist_type == "log normal" || dist_type == "Log normal") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c")]))
          names(prepArgs) <- c("a", "b", "c")
        } else if (dist_type == "power law" || dist_type == "Power law") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c")]))
          names(prepArgs) <- c("a", "b", "c")
        } else if (dist_type == "trapezoidal" || dist_type == "Trapezoidal") {
          prepArgs <- as.list(as.numeric(aRow[c("a", "b", "c", "d")]))
          names(prepArgs) <- c("a", "b", "c", "d")
        } else {
          stop("Unsupported distribution type")
        }
        
        # Create the inverse CDF function using the prepared arguments
        Make_inv_unif01(fun_type = dist_type, pars = prepArgs)
      })
      
      return(varFuns)
    },
    
    #' @description Export the matrix of speed constants, aka Engine, to an excel file
    exportEngine = function(excelFile) {
      if (is.null(private$solver)) {
        warning("No active solver")
        return(NULL)
      }
      ToExport <- private$solver$PrepKaasM()
      dframe2excel(as.data.frame(ToExport), outxlsx = excelFile)
    },
    
    #'@description Export the matrix to World 
    exportEngineR = function(){
      if (is.null(private$solver)) {
        warning("No active solver")
        return(NULL)
      }
      private$solver$PrepKaasM()
    },
    
    #'@description Save the last calculated masses in the core
    Masses = function(){
      #browser()
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetMasses()
    },
    
    VariableValues = function(){
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetVarValues()
    },
    
    #'@description Function to obtain steady state concentrations, using the solution saved in world.
    Concentration = function(){
      if (is.null(private$solver)) {
        stop("No active solver, (then Solve ..., then ask again)")
        return(NULL)
      }
      private$solver$GetConcentrations()
    },
    
    #'@description Save the last used emissions in the core
    Emissions = function(){
      #browser()
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetEmissions()
    },
    
    #' @description Return the appropriate concentration plot
    PlotConcentration = function(scale = NULL, subcompart = NULL){
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetConcentrationPlot(scale, subcompart)
    },
    
    #' @description Return the appropriate solution plot
    PlotMasses = function(scale = NULL, subcompart = NULL){
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetMassesPlot(scale, subcompart)
    },
    
    #' @description Return the appropriate mass distribution plot
    PlotMassDistribution = function(scale = NULL){
      if (is.null(private$solver)) {
        stop("No active solver")
      }
      private$solver$GetMassDist(scale)
    },
    
    #' @description Injection from SolverModule
    MassesAsRelational = function(...){
      if (is.null(private$solver)) {
        warning("No active solver")
        return(NULL)
      }
      private$solver$MassesAsRelational(...)
    },
    
    #' @description Obtain the names of the variables and tablename in which the data resides 
    #' Not needed in normal use
    #' see 
    metaData = function(){
      AllTables <- names(private$SB4Ndata)
      res <- data.frame(
        Tablenames = rep(AllTables, sapply(private$SB4Ndata, ncol)),
        AttributeNames = unname(unlist(sapply(private$SB4Ndata, names))
        ))
      res[!(res$Tablenames %in% c("Flows", "MatrixSheet", "Substances", "SubstanceCompartments", "SubstanceSubCompartSpeciesData")),]
    },
    
    fetchDims = function(vars){
      MetaData <- self$metaData()
      Attrn <- MetaData[MetaData$AttributeNames %in% vars,]
      unique(unlist(
        lapply(unique(Attrn$Tablenames), function(tname){
          allNames <- names(private$SB4Ndata[[tname]])
          allNames[allNames %in% The3D]
        })
      ))
      
    },
    
    #' @description Obtain the data for a SBvariable or a flow
    #' @param varname the name of the variable. Returns a list of variables if varname == "all"
    fetchData = function(varname="all"){
      private$FetchData(varname)
    },
    
    #' @description fetch specific values from core
    #' @param withoutValues data.frame-ish with columns `varname` and needed D 
    fetch_current = function(withoutValues) {
      
      pervar <- split(withoutValues, f = withoutValues$varName)
      toJoin <- lapply(names(pervar), private$FetchData)
      stillsplit <- lapply(1:length(pervar), function(i){
        specvar <- left_join(pervar[[i]], toJoin[[i]]) 
        names(specvar)[names(specvar) == names(pervar)[i]] <- "waarde"
        specvar
      })
      bind_rows(stillsplit)
    },
    
    #' @description function to obtain the data for a variable or flow, including the units whenever present in the Units csv
    #' @param varname name of the variable
    fetchDataUnits = function(varname="all"){
      #browser()
      fd <- private$FetchData(varname)
      
      if(varname != "all"){
        unitTable <- private$SB4Ndata[["Units"]]
        if(varname %in% unitTable$VarName){
          
          # Check if 'fd' is a data.frame or an atomic vector
          if (is.data.frame(fd)) {
            unit <- unitTable |> filter(VarName == varname)
            unit <- unit$Unit
            fd <- fd |> mutate(Unit = unit)
            
          } else if (is.atomic(fd) && length(fd) == 1) {
            # If fd is an atomic vector (e.g., a named number), attach unit as attribute
            unit <- unitTable |> filter(VarName == varname)
            unit <- unit$Unit
            
            # Add the unit attribute to the vector
            attr(fd, "unit") <- unit
          }
        }
      }
      return(fd)
    },
    
    #' @description Pseudo-inherit data; for instance from compartment to subcompartments.
    #' Not needed in normal use.
    #' @param fromData the name of the variable before copying
    #' @param toData the name of the variable after copying
    doInherit = function(fromData, toData) {
      private$DoInherit(fromData, toData)
    },
    
    
    #' @description returns the state for a state-name. Injected from States property
    #' @param abbr the name of the state
    findState = function (abbr){
      private$States$findState(abbr)
    },
    
    #' @description limits the states according to the filter
    #' @param ... the name of one of the dimensions of the states (ScaleName, SubCompartName, SpeciesName)
    filterStatesFrame = function(inDataFrame){
      if (!"data.frame" %in% class(inDataFrame)){
        #browser()
        stop("expected a data.frame as parameter, to apply the filterstatus PROPERTY")
      }
      theFilter <- private$filterstates
      outframe <- inDataFrame
      for (argName in names(theFilter)) {
        DimIdNames <- private$FetchData(argName)
        DimName <- names(DimIdNames)[names(DimIdNames) %in% The3D]
        if (any(endsWith(names(outframe), DimName))) {
          FilterDim <- DimIdNames[DimIdNames[,argName] == theFilter[[argName]],DimName]
          likeDimNames <- names(outframe)[endsWith(names(outframe), DimName)]
          for (likeDimName in likeDimNames){
            outframe <- outframe[(!is.na(outframe[,likeDimName])) & outframe[,likeDimName] %in% FilterDim,]
          }
        }
      }
      return(outframe)
    },
    
    #' @description returns the table, determined by the dimensions et al.
    #' @param KeyNames the dim (of The3D etc) determine which table
    whichDataTable = function(KeyNames){
      private$WhichDataTable (KeyNames)
    },
    
    #' @description runs (or tries to) the calculation graph, either the whole graph or 
    #' limited to a single process
    #' @param aProcessModule the name of the state
    #' @param mergeExisting normally leaves all other processes unchanged, but if 
    #' not mergeExisting, all process results (kaas) are cleared first
    UpdateKaas = function(aProcessModule = NULL, #(Default) NULL means calculate CalcTreeBack
                          mergeExisting = T){ 
      #browser()

      if (is.null(aProcessModule)) {
        NewKaas <- private$CalcTreeBack(aProcessModule = NULL)
      } else {
        if (! "ProcessModule" %in% class(aProcessModule)){ # assuming it's a string with the name of
          aProcessName <- aProcessModule
          aProcessModule <- private$ModuleList[[aProcessName]]
        }
        if (! "ProcessModule" %in% class(aProcessModule)){ # now it's an error
          stop(paste("unknown process", aProcessName))
        }
        NewKaas <- private$CalcTreeBack(aProcessModule)
      }
      
      NewKaas <- self$filterStatesFrame(NewKaas)
      
      if (is.null(private$SBkaas) | !mergeExisting){
          private$SBkaas <- NewKaas
      } else { #merge with existing kaas; update or append if new
        Processes2Update <- unique(NewKaas$process)
        private$SBkaas <- private$SBkaas[!private$SBkaas$process %in% Processes2Update,]
        private$SBkaas <- merge(NewKaas, private$SBkaas, all = T)
      }
      
      # do postponed if postponed exists
      private$DoPostponed()
      
      #return only for purpose of transparent update; side effect is done
      invisible(private$SBkaas)
    },
    
    #' @description Tries to create all variable modules that current processes and all flows need
    VarsFromprocesses = function(){
      TestTree <- private$nodeList[private$nodeList$ModuleType %in% c("Process", "Flow"),]
      
      AllWant <- unique(TestTree$Calc)
      MetaData <- self$metaData()
      TestTree$Params[TestTree$Params %in% MetaData$AttributeNames] <- ""
      TestTree <- TestTree[TestTree$Params != "" & !startsWith(TestTree$Params, "x_"),]
      
      #Loop until all vars are known
      totVarsToGet <- NULL
      while (nrow(TestTree)>0) {
        VarsToGet <- unique(TestTree$Params)
        totVarsToGet <- c(totVarsToGet, unique(TestTree$Params))
        #test if all totVarsToGet are known
        knownFun <- sapply(totVarsToGet, exists)
        knownData <- sapply(totVarsToGet, function(parName) {
          parName %in% MetaData$AttributeNames
        })
        known <- knownFun | knownData
        if (!all(known)) {
          stop(paste("unknown function", totVarsToGet[!known], "\n"))
        }
        sapply(VarsToGet, self$NewCalcVariable)
        TestTree <- private$nodeList[private$nodeList$Calc %in% VarsToGet,]
        TestTree$Params[TestTree$Params %in% c(MetaData$AttributeNames, "kaas")] <- "" #annoying deposition needing other kaas exception
        TestTree <- TestTree[TestTree$Params != "",]
      }
    },
    
    #' @description runs (or tries to) the calculation for a Variable and stores the results.
    #' After this, the SBvariable can be viewed with fetchData and this data will be used 
    #' when calculating processes, or other variables.
    #' @param aVariable the name of the Variable
    CalcVar = function(aVariable){
      TestTree <- private$nodeList[private$nodeList$ModuleType %in% c("Variable", "Flow"),]
      if (!aVariable %in% TestTree$Calc) stop(paste (aVariable, "not found"))
      private$UpdateDL(VarFunName = aVariable)
    },
    
    #' @description set a constant in the internal data, to enable use by SB variable etc.
    #' @param ... named value
    SetConst = function(...){
      #if ... is a list with a single data.frame, the const has dimensions
      Params <- list(...)
      #there can only be one at a time
      if (length(Params) != 1){
        stop("SetConst can deal with one Const at a time")
      }
      if (isa(Params, "list") && isa(Params[[1]], "data.frame")) {
        private$UpdateDL(Params[[1]])
      } else {
        private$UpdateDL(...)
      }
    },
    
    #' @description runs (or tries to) the calculation for Variables,
    #' and continues from there to update all processes and variables 
    #' that have a depency of any of the Variables, recursively.
    #' @param Variables the name(s) of the Variable(s) that are "dirty" 
    #' (Datalayer has been updated)
    UpdateDirty = function(Variables){#recalc DAG, starting onwards from vector of Variables
      #browser()
      NotUsed <- Variables[!Variables %in% private$nodeList$Params]
      if (length(NotUsed)> 0) warning(do.call(paste, as.list(
            c("Not all Variables are used:", NotUsed))))
      NewKaas <- private$CalcTreeForward(Variables[Variables %in% private$nodeList$Params])
      Processes2Update <- unique(NewKaas$process)
      private$SBkaas <- private$SBkaas[!private$SBkaas$process %in% Processes2Update,]
      private$SBkaas <- rbind(NewKaas[,names(private$SBkaas)], private$SBkaas)
      
      private$DoPostponed()
    },
    
    #' @description  Which Graph elements SBVars depend on?
    DependOn = function(SBVars){
      AllDependVar <- NULL
      DependVar <- SBVars
      numDepend <- 1 #anything > 0
      while (numDepend > 0) {
        DependVar <- unique(private$nodeList$Params[private$nodeList$Calc %in% DependVar])
        AllDependVar <- unique(c(AllDependVar, DependVar))
        numDepend <- length(DependVar)
      }
      return(AllDependVar)
    },
    
    #' @description Verifies the presence of needed variables for the calculation of 
    #' all processes
    whichUnresolved = function(){
      private$CheckTree()
    },

    #' @description removes variables appearently not needed in the calculation DAG
    #' starting from Varname upwards
    #' @param VarName the name of the Variable which inputs are cleaned, recursively
    CleanupCalcGraphAbove = function(VarName){
      private$cleanupCGAbove (VarName) 
    },
    
    #' @description if UpdateRows is a list of variables (each containing a fetchdata() result): see private$MutateVar,
    #' if UpdateRows is (a csv filename of) a single dataframe it will be converted before the call
    mutateVars = function(UpdateRows) {
      #browser()
      if ("character" %in% class(UpdateRows)) {
        stopifnot(endsWith(UpdateRows, ".csv") && file.exists(UpdateRows))
        UpdateRows <- read.csv(UpdateRows) #now it's a data.frame
      }
      if ("data.frame" %in% class(UpdateRows)) {
        # you cannot test enough..
        if (!all(c("varName", "Waarde") %in% names(UpdateRows))) {
          stop("UpdateRows should contain columns varName and Waarde; dimensions when needed")
        }
        # fetch all variables, empty the dataframes and make room for new rows
        uniqvNames <- unique(UpdateRows$varName)
        baseVars <- lapply(uniqvNames, private$FetchData)
        names(baseVars) <- uniqvNames
        Updated <- lapply(baseVars, function(x) {
          if ("data.frame" %in% class(x)) {
            x[F,]
          } else {
            unlist(unname(x))
          }
        }) 
        names(Updated) <- names(baseVars)
        
        #put rows in Updated
        for (vari in 1:nrow(UpdateRows)){ #loop vnamesDistSD rows 
          
          vname <- UpdateRows$varName[vari]
          if ("data.frame" %in% class(baseVars[[vname]])) {
            #apply to new row of data to Mutate
            Dees <- The3D[The3D %in% names(UpdateRows)]
            NeedDees <- Dees[!is.na(UpdateRows[vari,Dees])]
            newRow <- UpdateRows[vari, NeedDees, drop = F]
            newRow[,vname] <- UpdateRows$Waarde[vari]
            Updated[[vname]] <- rbind(Updated[[vname]], newRow)
          } else { #just a number
            Updated[[vname]] <- UpdateRows$Waarde[vari] 
          }
        }  
        UpdateRows <- Updated
      } # now its a list of data.frames / names list value, like fetchdata() results
      
      for (i in 1:length(UpdateRows)) {
        if ("data.frame" %in% class(UpdateRows[[i]])) {
          private$MutateVar(UpdateRows[[i]])
        } else {
          UR <- UpdateRows[i] #mind the single []; leaving atomic values as list
          if (is.list(UpdateRows[[1]])) {
            UR[[1]] <- UR[[1]][[1]]
          }
          private$MutateVar(UR) 
        }
      }
    },
    
    #' @description Replaces a complete table in the internal data system. 
    #' Use with care.
    #' @param UpdateDF the new table, replcing the previous
    #' @param keys dims that determines the table to be updated, see whichDataTable
    #' @param TableName alternative to keys: provide the tablename. Use with care!
    UpdateData = function(UpdateDF, keys, TableName = NULL){
      if (is.null(TableName)) {
        TableName <- private$WhichDataTable(names(keys))
        stopifnot(!is.null(TableName))
      } 
      nowTable <- private$SB4Ndata[[TableName]]
      #remove current rows for keys; exception for CONSTANTS: keys = T
      if (length(keys)==1 && keys){
        private$SB4Ndata[[TableName]] <- UpdateDF
      } else {#keys of the dimensions
        DelRows <- sapply(names(keys), function(filter){
          nowTable[,filter] == keys[[filter]]
        })
        if (ncol(DelRows) > 1) {
          DelRows <- apply(DelRows, 1, all)
        }
        private$SB4Ndata[[TableName]] <- rbind(
          nowTable[!DelRows,],
          UpdateDF[,names(nowTable)])
      }
    },
    
    #' @description derive transfer processes from datalayer
    #' @param processName the one you are looking for, or (default) for "all" processes 
    FromDataAndTo = function(processName = "all"){
      #Get all form-to state combination, given
      #[3D]Processes sheets and
      #Processes columns in [3D]Sheet
      #And restrict to existing states
      PrepMatrix <- private$FetchData("Compartment")
      #do not join on SubCompart, no expansion needed there
      names(PrepMatrix) <- c("ExpandSubCompart", "compartment")
      The3Process <- lapply(The3D, function (oneOf3) {
        DTable <- private$SB4Ndata[[(paste0(oneOf3,"Processes"))]]
        if (processName != "all") {
          DTable <- DTable[DTable$process == processName,]
        }
        if (nrow(DTable) > 0) {
          #expand matrix to subcompartments?
          if (all(DTable$from %in% PrepMatrix$compartment)){
            possExpand <- lapply(1:nrow(DTable), function (xrow){
              merge(DTable[xrow,], PrepMatrix, by.x = "from", by.y = "compartment")
            }) 
            #rbind and clean columnames
            DTable <- do.call(rbind, possExpand)
            DTable$from <- DTable$ExpandSubCompart
            DTable$ExpandSubCompart <- NULL
          }
          #dito expansion for to; make a function??
          if (all(DTable$to %in% PrepMatrix$compartment)){
            possExpand <- lapply(1:nrow(DTable), function (xrow){
              merge(DTable[xrow,], PrepMatrix, by.x = "to", by.y = "compartment")
            }) 
            #rbind and clean columnames
            DTable <- do.call(rbind, possExpand)
            DTable$to <- DTable$ExpandSubCompart
            DTable$ExpandSubCompart <- NULL
          }
          
        }
        
        colnames(DTable)[colnames(DTable)=="from"] <- paste0("from",oneOf3)
        colnames(DTable)[colnames(DTable)=="to"] <- paste0("to",oneOf3)
        DTable
      })
      
      names(The3Process) <- The3D
      The3Sheet <- lapply(The3D, function (oneOf3) {
        private$SB4Ndata[[(paste0(oneOf3,"Sheet"))]]
      })
      names(The3Sheet) <- The3D
      processes3D <-lapply(The3D, function(D){
        
        #The other two dimensions; readability
        Others <- which(names(The3Sheet)!=D,arr.ind = T)
        Others1 <- Others[1]
        Others2 <- Others[2]
        AllNames1 <- lapply(The3Sheet[Others1],FUN = names)
        AllNames2 <- lapply(The3Sheet[Others2],FUN = names)
        
        #loop over processes within a dimension
        #1) list of processes
        Processes <- unique(The3Process[[D]][,"process"])
        #2 restrictions on expand?
        #search process attribute, if present indicating 'T|F' (only F matters, actually)
        # else include all elements of the dimension
        lapply(Processes, function(p){
          
          Df0 <- The3Process[[D]][The3Process[[D]]$process == p,]
          
          Oth1 <- The3Sheet[[Others1]][[The3D[Others1]]]
          if(p %in% unlist(AllNames1)){
            Oth1T <- which(The3Sheet[[Others1]][[p]] != "F")
            Oth1 <- Oth1[Oth1T]
          }
          #append the from-to
          Df1 <- data.frame(
            from = Oth1,
            to = Oth1, stringsAsFactors = F
          )
          names(Df1) <- sapply(names(Df1),paste0,The3D[Others1])
          Oth2 <- The3Sheet[[Others2]][[The3D[Others2]]]
          if(p %in% unlist(AllNames2)){
            Oth2T <- which(The3Sheet[[Others2]][[p]] != "F")
            Oth2 <- Oth2[Oth2T]
          }
          #append the from-to
          Df2 <- data.frame(
            from = Oth2,
            to = Oth2, stringsAsFactors = F
          )
          names(Df2) <- sapply(names(Df2),paste0,The3D[Others2])
          Step1Expand <- expand.grid.df(Df0, Df1, Df2)
          #remove processes with F in ProcessName - column of 2D-combination-tables
          D2combn <- combn(The3D,2)
          dummy <- apply(D2combn, 2, function(D2v){
            TableName <- paste0(do.call(paste0,as.list(D2v)),"Data")
            D2others <- private$SB4Ndata[[TableName]]
            if (p %in% colnames(D2others)) {
              ToDel <- D2others[D2others[,p]=="F" & !is.na(D2others[,p]), c(D2v[1],D2v[2])]
              for (k in 1:nrow(ToDel)){
                which1 <- which(D2others[,Others1] == ToDel[k,D2v[1]])
                which2 <- which(D2others[,Others2] == ToDel[k,D2v[2]])
                bothwhiches <- which1 & which2
                if (length(bothwhiches) < 0)
                  Step1Expand <- Step1Expand[-bothwhiches,]
              }
            }
          })
          Step1Expand
        })
      })#next D
      #flatten processes3D; 1) rbind nested level 2 2) rbind the list of dataframes
      processes3DUnnest <- lapply(processes3D, function (InList) {
        if (length(InList) == 0) return(NULL)
        if (length(InList) == 1) return(InList[[1]])
        #else rbind
        do.call(rbind,InList)
      })
      AllKaasCalc <- do.call(rbind,processes3DUnnest)
      
      #which states exist?
      exist.from <- apply(AllKaasCalc, 1, function(othrow) {
        any(private$States$asDataFrame$Scale == othrow["fromScale"] &
              private$States$asDataFrame$SubCompart == othrow["fromSubCompart"] &
              private$States$asDataFrame$Species == othrow["fromSpecies"])
      })
      exist.to <- apply(AllKaasCalc, 1, function(othrow) {
        any(private$States$asDataFrame$Scale == othrow["toScale"] &
              private$States$asDataFrame$SubCompart == othrow["toSubCompart"] &
              private$States$asDataFrame$Species == othrow["toSpecies"])
      })
      return(AllKaasCalc[exist.from & exist.to, ]) 
      
    },
    
    #' @description states and all data-layer to an rds-file
    save_world = function(filename){
      whole_world <- list(
        substance = private$Substance,
        states = private$States$asDataFrame,
        SB4Ndata = private$SB4Ndata,
        filterstates = private$filterstates)
      saveRDS(whole_world, file = filename)
    },
    
    load_world = function(filename){
      whole_world <- readRDS(filename)
      private$Substance <- whole_world$substance
      private$States <- SBstates$new(whole_world$states)
      private$States$myCore <- self
      private$SB4Ndata <- whole_world$SB4Ndata
      private$filterstates <- whole_world$filterstates
    }
  ), 
  
  active = list(
    #' @field states getter for r.o. property
    states = function(value) {
      if (missing(value)) {
        private$States
      } else {
        stop("`$states` are set by new()", call. = FALSE)
      }
    },
    #' @field kaas getter for r.o. property (all k's)
    kaas = function(value) {
      if (missing(value)) {
        if (is.null(private$SBkaas)) return(NULL)
        #else
        private$SBkaas
      } else {
        warning("`$kaas` should be set by UpdateKaas(), format is strict!", call. = FALSE)
        private$SBkaas <- value
      }
    },
    #' @field nodelist getter for r.o. property
    nodelist = function(value) {
      if (missing(value)) {
        private$nodeList
      } else {
        stop("use the $NewProcess(), $NewCalcVariable() and $NewFlow() methods to construct a node-list", call. = FALSE)
      }
    },
    #' @field moduleList getter for r.o. property
    moduleList = function(value) {
      if (missing(value)) {
        private$ModuleList
      } else {
        stop("use the $NewProcess(), $NewCalcVariable() and $NewFlow() methods to construct a node-list", call. = FALSE)
      }
    },
    substance = function(value){
      if (missing(value)){
        private$Substance
      } else {
        if (!value %in% private$SB4Ndata[["Substances"]]$Substance) {
          stop(paste(value, "not in the database"))
        }
        private$Substance <- value
        
        ToSubCompartSpecies <- private$SB4Ndata[["SubstanceSubCompartSpeciesData"]][private$SB4Ndata[["SubstanceSubCompartSpeciesData"]]$Substance == self$substance,,]
          ToSubCompartSpecies$Substance <- NULL
          ToSubCompartSpecies$SB4N_name <- NULL
          ToSubCompartSpecies$Unit <- NULL
          for (SBVar in unique(ToSubCompartSpecies$VarName)) {
            OneVarDF <- pivot_wider(ToSubCompartSpecies[ToSubCompartSpecies$VarName == SBVar,], 
                        names_from = VarName, values_from = Waarde) %>%
              as.data.frame()
            private$UpdateDL(OneVarDF) #, keys = c("SubCompart", "Species") ,TableName = "SubCompartSpeciesData"
        }
        # Expand SpeciesCompartments to SubCompartSpeciesData
        
        # redo inheritance; make sure Substance properties are known, if not as NA
        if (nrow(private$SB4Ndata[["SubstanceCompartments"]] ) > 0) {
          Vars <- unique(private$SB4Ndata[["SubstanceCompartments"]]$VarName)
          newDataFrame <-  merge(
            private$SB4Ndata[["SubstanceCompartments"]], 
            private$SB4Ndata[["SubCompartSheet"]][,c("Compartment", "SubCompart")])
          newDataFrame <- newDataFrame[newDataFrame$Substance %in% self$substance,  c("VarName", "Waarde", "SubCompart")]
          
          private$SB4Ndata[["SubstanceSubCompart"]] <- pivot_wider(newDataFrame, 
                                                                   names_from = VarName, values_from = Waarde) %>%
            as.data.frame()
          
        } 
        #  Substance properties to be pasted to CONSTANTS later
        ThisSubstance <- private$SB4Ndata[["Substances"]][private$SB4Ndata[["Substances"]]$Substance == self$substance,]
        # except:  
        ThisSubstance$Substance <- NULL
        # update 
        for (nm in names(ThisSubstance)) {
          private$SB4Ndata[["CONSTANTS"]][,nm] <- ThisSubstance[,nm]
        }
        
        if (private$SB4Ndata[["CONSTANTS"]]$ChemClass == ""){
          private$SB4Ndata[["CONSTANTS"]]$ChemClass <- "neutral"
        }
        
        #update all other data that depends on the substance properties
        #this depence on the list of variables in substanceProperties
        self$UpdateDirty(private$substanceproperties)
        
      }
    },
    # description list?vector of properties that relate to substance; if substance is set, these properties become "dirty"
    substanceProperties = function(value){
      if (missing(value)) {
        return(private$substanceproperties)
      } else {
        warning("cannot set substanceProperties")
      }
    },
    
    #' @description Export everything in fetchdata
    exportMetadata = function() {
      #browser()
      fetchdatanames <- unique(self$fetchData())

      exclusions <- c("Dimension", "FlowName", "forWhich", "Unit", "VarName", "X", "DefaultFRACarea", "DefaultPH", "Kow_default", "MOLMASSAIR", "outdated", "outdated.1", "outdated.2", "Pvap25_default")
      
      # Initialize an empty tibble to store the results
      result_tibble <- tibble(
        varname = character(),  # Column for the variable name
        data = list()           # Column for nested tibbles
      )
      
      # Iterate through the fetched data names
      for(i in fetchdatanames) {
        if (!i %in% exclusions) {
          
          fd <- data.frame(self$fetchDataUnits(i))
          
          # Convert fd to a tibble if it's not already one
          fd_tibble <- as_tibble(fd)
          
          # Add a new row to the result_tibble
          result_tibble <- bind_rows(result_tibble, tibble(
            varname = i,       # Column for the variable name
            data = list(fd_tibble)  # Nest the tibble 
          ))
        }
      }
      
      result_tibble <- result_tibble |>
        distinct()
      
      # Get the kaas and format it the same as the fetchdata items
      kaas <- self$kaas
      kaas_tibble <- as_tibble(kaas)
      kaas_tibble <- tibble(varname = "kaas",
                            data = list(kaas))
      
      # Bind the fetchdata tibble and the kaas tibble together
      result_tibble <- rbind(result_tibble, kaas_tibble)
    },
    
    filterStates = function(value){
      if (missing(value)) {
        return(private$filterstates)
      } else {
        if (!"list" %in% class(value)) {
          stop("filterStates is expected a *list* of one or more values of ScaleName=, and/or SubCompartName=, and/or SpeciesName=")
        }
        if (!all(names(value) %in% c("ScaleName", "SubCompartName", "SpeciesName"))) {
          stop("filterStates is expected a list of one or more values of ScaleName=, and/or SubCompartName=, and/or SpeciesName=")
        }
        private$filterstates <- value
      }
    }
  ),
  
  private = list(
    SB4Ndata = NULL,
    States = NULL,
    Substance = NULL,
    solvername = NULL, 
    SBkaas = NULL,
    ModuleList =  NULL,
    nodeList = NULL,
    solver = NULL,
    l_postPoneList = NULL,
    concentration = NULL,
    filterstates = list(),
    substanceproperties = list(),

    DoInherit = function(fromDataName, toDataName){
      #browser() #ever called??
      #Inherits from global, Matrix, compartment, or a subset of dimensions The3D of the toData
      # parameters should be a fetch-able string
      fromData <- private$FetchData(fromDataName)
      
      toData <- self$fetchData(toDataName)
      stopifnot("data.frame" %in% class(toData))
      #toData should have 1 - 3 dimension
      toDataDims <- The3D %in% names(toData)
      stopifnot(any(toDataDims), sum(toDataDims) <= 3)
      fromTableNames <- c(The3D, "Matrix", "Compartment")
      fromDataDims <- fromTableNames %in% names(fromData)
      names(fromDataDims) <- fromTableNames
      # Include the NA rows (removed by fetchData)
      DimensionNames <- The3D[The3D %in% names(toData)]
      #The name
      FullScaffold <- self$whichDataTable(KeyNames = DimensionNames)
      #The actual data.frame
      FullScaffold <- private$SB4Ndata[[FullScaffold]][,DimensionNames, F] #don't drop frame
      #extend toData to the Full
      toData <- left_join(FullScaffold, toData)

      if (!any(fromDataDims)){
        #it's a constant, we hope?
        stopifnot ((is.numeric(fromData) && length(fromData) == 1) ) 
        toData$toRename = fromData
        names(toData)[names(toData)=="toRename"] <- fromDataName
        #toData
      } else { #it should be a data.frame
        stopifnot("data.frame" %in% class(fromData))
        if (!fromDataDims["Matrix"]) {
          toData <- left_join(toData, fromData)
        } # else #The from is already inherited to Subcompartment at initialisation
      }
      updateRows <- is.na(toData[,toDataName])
      toData[updateRows, toDataName] <- toData[updateRows, fromDataName]
      NeededNames <- names(toData)[names(toData) %in% c(The3D, toDataName)] 
      toData <- toData[!is.na(toData[,toDataName]), NeededNames]
      private$UpdateDL(VarFunName = toData)
      
    },
    
    storeNodes = function(aNewModule){
      moduleType <- switch (class(aNewModule)[1],
        "VariableModule" = "Variable",
        "FlowModule" = "Flow",
        "ProcessModule" = "Process"
      )
      aNeedVars <- unique(aNewModule$needVars) #there might be a from. AND a to. parameter!
      if (length(aNeedVars) == 0){
        NewNodes <- data.frame(Calc = aNewModule$myName, Params = "", ModuleType = moduleType)
      } else NewNodes <- data.frame(Calc = aNewModule$myName, Params = aNeedVars, ModuleType = moduleType)
      if (is.null(private$nodeList)) {
        private$nodeList <- NewNodes
      } else private$nodeList <- rbind(private$nodeList, NewNodes)

    },
    
    cleanupCGAbove = function(VarName) {
      #browser()
      VarNameVector <- VarName
      MoreVarNames <- VarName
      repeat {
        candidotes <- private$nodeList[private$nodeList$Calc %in% MoreVarNames,]
        NoCandid <- private$nodeList[private$nodeList$Params %in% candidotes$Params &
                                       !private$nodeList$Calc %in% VarNameVector,]
        MoreVarNames <- candidotes$Params[!candidotes$Params %in% NoCandid$Params]
        if (length(MoreVarNames) == 0) break
        VarNameVector <- unique(c(VarNameVector, MoreVarNames))
      }
      #TODO remove from data?
      cat (do.call(paste, c("removed nodes for", VarNameVector)))
      private$nodeList <- private$nodeList[private$nodeList$Calc %in% VarNameVector,]
    },
    
    CheckTree = function(){ #recursive checking the calculation of the DAG of processes/variables
      TestTree <- private$nodeList
      #remove the ones present in the data; these you have
      MetaData <- self$metaData()
      TestTree$Params[TestTree$Params %in% MetaData$AttributeNames] <- ""
      AllWant <- unique(TestTree$Calc)
      TestTree$Check <- TestTree$Params == "" 
      repeat{
        CountCantdo <- length(which(!TestTree$Check))
        CantDo <- unique(TestTree$Calc[!TestTree$Check])
        CanDo <- AllWant[!AllWant %in% CantDo]
        TestTree$Check <- TestTree$Check | TestTree$Params %in% CanDo
        if (CountCantdo == length(which(!TestTree$Check))) break
      }
      unique(TestTree$Params[!TestTree$Check])
    },
    
    CalcTreeForward = function(DirtyVariables){ #calculation of variables and kaas
      #browser()
      if (is.null(DirtyVariables)) stop("Cannot CalcTreeForward without a(starting/dirty)Variable")
      # determine modules that need updating by module dependencies, derived from params of SB vars etc.
      # loop until Trunc does not grow anymore
      TestTrunc <- NULL
      grow <- private$nodeList[private$nodeList$Params %in% DirtyVariables,]

      while (nrow(grow) != 0) {
        TestTrunc <- rbind(TestTrunc, grow)
        grow <- private$nodeList[private$nodeList$Params %in% grow$Calc,]
      }
      #clean doubles in TestTrunc, order by the last entry, reverse to set final calculation order
      ToCalculate <- rev(unique(rev(TestTrunc$Calc)))
      ToCalculate <- ToCalculate[!ToCalculate %in% private$l_postPoneList]
      
      #remove kaas from postpones!! 
      if (!is.null(private$l_postPoneList)) {
        postkaas <- unlist(private$l_postPoneList)[
          startsWith(unlist(private$l_postPoneList), "k_")]
        
        private$SBkaas <- private$SBkaas[!private$SBkaas$process %in% postkaas,]
      }
      kaaslist <- list()
      for (i in 1:length(ToCalculate)){ #these are in proper order, all should succeed
        ModName <- ToCalculate[i]
        CalcMod <- private$ModuleList[[ModName]]
        clcm <- class(CalcMod)
        if (exists("verbose") && verbose){
            cat(paste("calculating", ModName), "\n")
        }
        if ("VariableModule" %in% class(CalcMod) | "FlowModule" %in% class(CalcMod)) { #update DL
            private$UpdateDL(ModName)
        } else { # a process; add kaas to the list
            kaaslist[[CalcMod$myName]] <- CalcMod$execute() # Hier komt de error vandaan
        }
      }
      return(private$IntegrateKaaslist(kaaslist))
    },
    
    CalcTreeBack = function(aProcessModule){ #calculation of variables and kaas
     
      #treat the objects that do not use private$ModuleList separate
      if ("ClassicNanoProcess" %in% class(aProcessModule))   {
        return(aProcessModule$execute())
        
      } else {
        kaaslist <- list() # all the dataframes of (future) new kaas
        if (is.null(aProcessModule)) {
          #exception for the CalcGraph* that are calculated after the tree i.e. molecular deposition special
          TestTree <- private$nodeList[!private$nodeList$Calc %in% unlist(private$l_postPoneList),]
        } else {
          if (! "ProcessModule" %in% class(aProcessModule)){ # assuming it's a string with the name of
            aProcessModule <- private$nodeList[[aProcessModule]]
          }
          TestTree <- private$nodeList[private$nodeList$ModuleType %in%  c("Variable", "Flow") | 
                                         private$nodeList$Calc==aProcessModule$myName,]
        }
        AllWant <- unique(TestTree$Calc)
        MetaData <- self$metaData()
        TestTree$Params[TestTree$Params %in% MetaData$AttributeNames] <- ""
        #Hardcoded the "keyword" flow; assuming it will be calculated by all (relevant) FlowModules
        TestTree$Params[TestTree$Params == "flow"] <- ""
        #Loop until all TestTree$Params == "", if possible
        repeat{
          TestTree$Check <- TestTree$Params == ""
          CountCantdo <- length(which(!TestTree$Check))
          CantDo <- unique(TestTree$Calc[!TestTree$Check])
          CanDo <- AllWant[!AllWant %in% CantDo]
          if (length(CanDo > 0)){
            for (i in 1:length(CanDo)){
              CalcMod <- private$ModuleList[[CanDo[i]]]
              if (exists("verbose") && verbose){
                cat(paste("calculating", CanDo[i]), "\n")
              }
              if ("VariableModule" %in% class(CalcMod) | "FlowModule" %in% class(CalcMod)) { #update DL
                
                private$UpdateDL(CanDo[i])
              } else { # a process; add kaas to the list
                kaaslist[[CalcMod$myName]] <- CalcMod$execute()
              }
              #skip them from the "todo" list 
              TestTree$Params[TestTree$Params == CanDo[i]] <- ""
              TestTree <- TestTree[-which(TestTree$Calc == CanDo[i]),] 
              AllWant <- AllWant[-which(AllWant == CanDo[i])]
            }
          } else {
            #anything left; enough?
            if (length(CantDo)>0){
              NotToDo <- names(private$ModuleList[CantDo])
              if (exists("verbose") && verbose) {
                NotToDoString <- do.call(paste, as.list(NotToDo))
                cat (paste("Can't calculate", NotToDoString, "\n"))
                lapply(private$ModuleList[CantDo], function(aModule){
                  if("ProcessModule" %in% class(aModule) | "FlowModule" %in% class(aModule)){
                    pmissing <- TestTree$Params[TestTree$Calc == aModule$myName & TestTree$Params != ""]
                    stopifnot(length(pmissing)>0) #can't be, would have been calculated
                    missParams <- do.call(paste,as.list(pmissing))
                    cat(paste(aModule$myName, "is missing", missParams, "\n"))
                  } 
                })
              }
              warning("Can't calculate all needed modules !!")
            }
            break #repeat
          }
        }
      }
      private$IntegrateKaaslist(kaaslist)
    },

    IntegrateKaaslist = function(kaaslist){
      #select kaas names only for all kaaslist - data.frames
      kaaslist <- kaaslist[!sapply(kaaslist, anyNA)]
      kaaslist <- lapply(kaaslist, 
                         dplyr::select, c("process", "fromScale","fromSubCompart","fromSpecies",
                                          "toScale","toSubCompart","toSpecies","k"))
      VolleKaas <- do.call(rbind, kaaslist)
      
      if(length(VolleKaas) > 0) { #length is 0 if no processes 
        return(VolleKaas)
      } else {return(NULL)}
      
    },
    
    DoPostponed = function() {
      #browser()
      ppl <- private$l_postPoneList
      
      validPostPoneList <- Filter(Negate(is.null), private$l_postPoneList)
      
      if (!is.null(validPostPoneList)){
        for (postNames in validPostPoneList){ #force order??
          CalcMod <- private$ModuleList[[postNames]]
          if ("VariableModule" %in% class(CalcMod) | "FlowModule" %in% class(CalcMod)) { #update DL
            succes <- private$UpdateDL(postNames)
            if (nrow(succes) < 1) warning(paste(postNames,"; no rows calculated"))
          } else { # a process; add kaas to the list
            postKaas <- CalcMod$execute()
            if (!any(is.na(postKaas))) {
              private$SBkaas <- private$SBkaas[!private$SBkaas$process %in% postNames,]
              private$SBkaas <- rbind(private$SBkaas, postKaas)
            }
          }
        }
      }
      
    },
    
    #facilitate access to self$SB4Ndata
    
    #' description fetch the values for a dataframe with parameters/dimensions (any purpose),
    #' param varname name of variable to find
    ## '  @param ParamName.Dimensions data.frame with columns ParamName and the 3Dimensions() use merge x.all = T
    #' return vector values (if found; else NA)
    FetchData = function(varname) {
      #browser()
      #hack; because of ugly deposition dependency
      if (varname == "kaas") {
        return(self$kaas)
      }
      #Now for the actual fetching of variables; either calculated or data
      if (varname %in% names(private$SB4Ndata)) {
        #give the full table
        return(private$SB4Ndata[[varname]])
      } else {
        #is it a flow?
        fromFlows <- private$SB4Ndata[["Flows"]]
        if (any(fromFlows$FlowName == varname)) {
          fromFlows <- fromFlows[fromFlows$FlowName == varname,]
          attr(fromFlows, which = "isflow") <- T
          return(fromFlows)
        } else {
          QSARnames <- names(private$SB4Ndata[["QSARtable"]])
          if (varname %in% QSARnames) {
            ChemClassNow <- private$SB4Ndata[["CONSTANTS"]]$ChemClass
            res = private$SB4Ndata[["QSARtable"]][private$SB4Ndata[["QSARtable"]]$QSAR.ChemClass == ChemClassNow,varname]
            return(varname = res)
          } else {
            #normal behaviour: find the attribute and return its "view"
            MetaData <- self$metaData()
            if (varname=="all"){ #return an overview (listing of variables)
              return( #all flows and all attribute names excluding key fields
                sort(c(
                  unique(fromFlows$FlowName),
                  QSARnames,
                  MetaData$AttributeNames[!MetaData$AttributeNames %in% c(
                    The3D, paste("to.", The3D, sep = ""),
                    "Default", "from", "to", "process", "AbbrS"
                  )]
                ))
              )
            }
          }
          
          Attrn <- MetaData$Tablenames[which(varname == MetaData$AttributeNames)]
          if (length(Attrn)==0) {
            allVars <- MetaData[!MetaData$AttributeNames %in% c(
              The3D, paste("to.", The3D, sep = ""),
              "Default", "from", "to", "process", "AbbrS"
            ) & ! MetaData$Tablenames %in% c("SubstanceCompartments"),]
            grepVars <- do.call(paste,
                                as.list(allVars$AttributeNames[grep(varname, allVars$AttributeNames, ignore.case=TRUE)]))
            warning (paste("Cannot find property ", varname, "; but found", grepVars))
            return(NA)
          } 
          
          if(length(Attrn) > 1) {
            stop (paste0(varname, " in multiple tables: ", Attrn))
          } 
          subvec <- MetaData[MetaData$Tablenames == Attrn, "AttributeNames"]
          Dims <- c(The3D, paste("to.", The3D, sep = ""), "Substance") %in% subvec
          names(Dims)[Dims] <- c(The3D, paste("to.", The3D, sep = ""), "Substance")[Dims]
          DimsVarCols <- c(names(Dims)[Dims], varname)
          
          #browser()
          
          #Check if unit should be converted to SI
          unitTable <- private$SB4Ndata[["Units"]]
          SIexpression <- unitTable$ToSI[unitTable$VarName == varname]
          
          isExpression <-  length(SIexpression) == 1 &&
            !is.na(SIexpression) && 
            SIexpression != "" && 
            SIexpression != "NA"
          
          Doexpression <- function (varname, x, SIexpression){ #execute expression to convert to SI
            #NB varname is local here
            assign(varname, x)
            eval(parse(text = SIexpression))
          }
          
          if (any(Dims)) { #it's a data.frame with varname as column
            if ("Substance" %in% names(Dims) && Dims["Substance"]){
              res <- private$SB4Ndata[[Attrn]][private$SB4Ndata[[Attrn]]$Substance == private$Substance,DimsVarCols]
              ToDel <- FALSE
            } else {
              res <- private$SB4Ndata[[Attrn]][,DimsVarCols]
              #remove the NA's from the pivot_wider; NB not for substance related data
              ToDel <- is.na(res[,varname])
            }
            if (isExpression){
              # ADJUST TO SI UNITS!!!
              
              res[,varname] <- Doexpression(varname, res[,varname], SIexpression)
            }
            return(res[!ToDel, DimsVarCols[DimsVarCols!="Substance"]])
          } else { #it's atomic 
            res <- private$SB4Ndata[[Attrn]][,DimsVarCols[DimsVarCols!="Substance"]]
            if (isExpression){
              #  ADJUST TO SI UNITS!!!
              res <- Doexpression(varname, res, SIexpression)
            }
            return(varname = res)
          }
        }
      }
    },
    
    #' @description update rows of a variable in the "datalayer" (SB4Ndata-dataframes)
    #' @param UpdateRows the data.frame with the variable, dimensions should match and  
    #' 1 other column containing values, named as the var name
    #' @return side-effect; new "fetchdata()" is returned
    MutateVar = function(UpdateRows) {
      #browser()
      if ("data.frame" %in% class(UpdateRows)) {
        dims <- The3D[The3D %in% names(UpdateRows)]
        varName <- names(UpdateRows)[!names(UpdateRows) %in% dims]
        if (length(varName) != 1){
          stop(paste("illegal call to MutateVar; multiple variable names found:", varName))
        }
        nowVar <- private$FetchData(varName)
        if (anyNA(nowVar)) {
          stop(paste("non-existing variable:", varName))
        }
        if (varName %in% names(private$moduleList)) {
          stop(paste("illegal call to MutateVar; variable is a calculated value:", varName))
        }
        #merge the "newValue" to the nowVar
        names(UpdateRows)[names(UpdateRows) == varName] <- "newValue"
        wannebeVar <- merge(nowVar, UpdateRows, all.x = T) |>
          distinct()
        if (nrow(nowVar) < nrow(wannebeVar)) {
          #browser() #start debugging?
          stop("illegal UpdateRows in MutateVar")
        }
        #update wannebe, remove newValue
        wannebeVar[!is.na(wannebeVar$newValue), varName] <- wannebeVar$newValue[!is.na(wannebeVar$newValue)]
        wannebeVar$newValue <- NULL
        private$UpdateDL(wannebeVar)
        
      } else {# just a number
        do.call(private$UpdateDL, UpdateRows) #all the trouble to get the name in..
      }
    },

    #' @description calculate and update a variable in the "datalayer" (SB4Ndata-dataframes)
    #' @param VarFunName the name of the variable to be updated AND the name of the function
    #' @param DIMRestrict optional list of restrictions; each element is c(DimName, Comparator, Value)
    #' uh, not in use at this point in time
    #' return side-effect; vector?
    UpdateDL = function(VarFunName = NULL, DIMRestrict = NULL, ...) {
      #browser()
      MetaData <- self$metaData()
      if (is.null(VarFunName)) {
        inp <- list(...)
        VarFunName <- names(inp)
        NewData <- inp
        Attrn <- MetaData$Tablenames[match(VarFunName, MetaData$AttributeNames)]
      } else {
        if ("data.frame" %in% class(VarFunName)) { 
          NewData <- VarFunName
          VarFunName <- names(NewData)[length(NewData)]
          Attrn <- MetaData$Tablenames[match(VarFunName, MetaData$AttributeNames)]
        } else { #
          Attrn <- MetaData$Tablenames[match(VarFunName, MetaData$AttributeNames)]
          #exist VarFunName as VariableModule?
          if (! VarFunName %in% names(private$ModuleList)) stop(paste("Can't find", VarFunName, "as VariableModule"),call. = F)
          VarFun <- private$ModuleList[[VarFunName]]
          NewData <- VarFun$execute()
          if (exists("verbose") && verbose){
            cat(paste(VarFunName, nrow(NewData), "rows\n"))
          }
          if (anyNA(NewData) | (length(NewData) != 1 && nrow(NewData) < 1)) {
            warning(paste(VarFunName,"; no rows calculated"))
            #force the result, see below
            NewData <- data.frame(NA)
            names(NewData) <- VarFunName #for the flow that returns NA
          } else {
            #adjust column names 
            if ("FlowModule" %in% class(VarFun)  ) {
              #to conform the full Flows table)
              NewData$FlowName <- VarFunName
              if (!"toScale" %in% names(NewData)){
                NewData$toScale <- NewData$fromScale
              }
              if (!"toSubCompart" %in% names(NewData)){
                NewData$toSubCompart <- NewData$fromSubCompart
              }
            } 
            if ("VariableModule" %in% class(VarFun)){
              if(is.null(names(NewData))){
                names(NewData) <- VarFunName
              }
            }
          }
        }
      }
      
      # where should it go? flows or Where the dimensions are
      # and prep diff 
      if ("flow" %in% names(NewData)){
        Target.Table <- "Flows"
        if (VarFunName %in% private$SB4Ndata[["Flows"]]$FlowName){
          diffTable <- private$FetchData(VarFunName)
          names(diffTable)[names(diffTable)==VarFunName] <- paste("old",VarFunName,sep = "_")
        }
      } else {
        if (all(is.na(NewData))){}
          #set the result, as variable?!?! in the DataLayer (CONSTANTS), to have the graph continue
        #Target.Table <- private$WhichDataTable(names(NewData))
        if (!is.na(Attrn)){ #is already in the DL
          Target.Table <- Attrn
          diffTable <- private$FetchData(VarFunName)
          names(diffTable)[names(diffTable)==VarFunName] <- paste("old",VarFunName,sep = "_")
        } 
        else Target.Table <- private$WhichDataTable(names(NewData))
      }
      #Special Case a "constant" or substance property
      if (Target.Table == "CONSTANTS") {
        private$SB4Ndata[[Target.Table]][names(NewData)] <- NewData
        nd <- private$SB4Ndata[[Target.Table]][names(NewData)]
      } else {
        #delete and merge the DL-table
        if (Target.Table == "Flows") {
          WithoutPrevious <- private$SB4Ndata[[Target.Table]][
            private$SB4Ndata[[Target.Table]]$FlowName != VarFunName,]
          private$SB4Ndata[[Target.Table]] <- rbind(WithoutPrevious, NewData[,names(WithoutPrevious)])
        } else { #a SBvariable
          if (VarFunName %in% names(private$SB4Ndata[[Target.Table]])){
            #another exceptional case 
            if (Target.Table == "Substances") {
              private$SB4Ndata[[Target.Table]][private$SB4Ndata[[Target.Table]]$Substance == private$Substance, VarFunName] <- unlist(NewData)
            } else {
              numCol <- match(VarFunName, names(private$SB4Ndata[[Target.Table]]))
              private$SB4Ndata[[Target.Table]] <- private$SB4Ndata[[Target.Table]][,-numCol]
            }
          } 
          private$SB4Ndata[[Target.Table]] <- merge(private$SB4Ndata[[Target.Table]], NewData, all = T)
        }
      }
      
      #just to show, side effect is in DL
      if (!exists("diffTable")){ #new in the DL
        return(NewData)
      } else {
        mt <- merge(diffTable, NewData, all = T)
        return(merge(diffTable, NewData, all = T)) 
      }
    },
    
    WhichDataTable = function(KeyNames){# Which table ("1D"sheet or "2-3D"Data) in SB4N.data has identical dimensions?
      # Special case, a Flows has special keynames for easy merging when calculation processes; 
      # none of the actual keynames are in The3D
      if (length(KeyNames) == 0){ #either CONSTANTS or a flow
        if ("flow" %in% KeyNames){
          return("Flows")
        }
      }
        
      MetaData <- self$metaData()
      MetaDims <- data.frame(
        SB4N.Table = unique(MetaData$tablenm)
      )
      WhichD <- The3D[The3D %in% KeyNames]
      AppendString <- switch (length(WhichD)+1,
        "CONSTANTS",
        "Sheet",
        "Data",
        "Data")
      do.call(paste,as.list(c(WhichD, AppendString, sep = "")))
      
    }

  )
)

#' #S3 function TODO print method? see docs R6
#' #' @export
#' Summary.SBcore <- function(MySBcore) {
#'   stopifnot(all(sapply(c("kaas", "states"), `%in%`, names(SBWorld))))
#'   Scal <- table(SBWorld$states$Scale)
#'   Scales  <- Scal[Scal > 0]
#'   SubC <- table(SBWorld$states$SubCompart)
#'   SubCompartments <- SubC[SubC > 0]
#'   Specy <- table(SBWorld$states$Species)
#'   Species <- Specy[Specy > 0]
#'   BoxDimensions <- list(Scales = Scales, 
#'                         SubCompartments = SubCompartments,
#'                         Species = Species)
#'   processM <- GetProcesses(SBWorld$states)
#'   processkaas <- aggregate(fromSubCompart~process, 
#'                            data = processM, FUN = length)
#'   names(processkaas) <- c("process", "No.Kaas" )
#'   summlog10kaas <- table(round(log10(SBWorld$kaas$k)))
#'   list(BoxDimensions = BoxDimensions,
#'        processKaas = processkaas, log10kaasTafel = summlog10kaas)
#'   
#' }
