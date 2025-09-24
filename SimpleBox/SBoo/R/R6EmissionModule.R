#' @title Emission module
#' @description to set/get emissions, possibly make into functions
#' @import R6
#' @export
EmissionModule <-
  R6::R6Class(
    "EmissionModule",
    public = list(
      initialize = function(emis, solvedAbbr) {
        
        private$solvedAbbr <- solvedAbbr # if NULL it should be given with emis
        
        if (is.character(emis)){ # read from file as data frame
          emis <- switch (tools::file_ext(emis,
                                          "csv" = private$readfromcsv(emis),
                                          "xlsx" = private$readFromExcel(emis)
          )) 
        }
        
        # Specify the type of emissions given to the emission module
        if ("matrix" %in% class(emis)) {
          stopifnot(all(colnames(emis) %in% private$solvedAbbr))
          private$emission_tp <- "runs_row"
        } else {
          if ("list" %in% class(emis) & all(is.function(emis))) {
            private$emission_tp <- "DynamicFun"
          } else {
            if ("data.frame" %in% class(emis)){
              private$emission_tp <- private$setEmissionDataFrame(emis)
            } else stop ("unknown format of emissions")
          }
          
        }
        private$Emissions <- emis          
      },
      
      emissions = function(scenario = NULL){ #scenario also used for "RUN"
        # browser()
        
        type <- private$emission_tp
        if (is.null(private$Emissions)) return (NULL)
        
        if (!private$emission_tp %in% c("Steady_det_df", "Steady_prob_df", "Dynamic_prob_df", "Dynamic_det_df", "runs_row")) {
          stop("emissions cannot be casted to a named vector")
        } 
        
        # When there are no runs: 
        if (is.null(scenario)) {
          if(private$emission_tp == "Steady_det_df") {
            emis <- rep(0, length(private$solvedAbbr))
            names(emis) <- private$solvedAbbr
            if(any(private$Emissions$Abbr %in% private$solvedAbbr == FALSE)){
              stop(paste(private$Emissions$Abbr[!private$Emissions$Abbr %in% private$solvedAbbr],
                         "is not one of the Abbreviated (Abbr) compartments in World"))}
            emis[private$Emissions$Abbr] <- private$Emissions$Emis
            
          } else if(private$emission_tp == "Dynamic_det_df"){
            emis <- self$emissionFunctions(private$Emissions, private$solvedAbbr)
          } else {
            stop("scenario/run is missing in emission data")
          }
          # When there are runs:          
        } else if (is.numeric(scenario)) {
          if(private$emission_tp == "Steady_prob_df"){
            
            emissions <- private$Emissions
            abbrs <- private$solvedAbbr
            filtered <- private$Emissions[private$Emissions$RUN == scenario, ]
            emis <- private$df2Vector(filtered, private$solvedAbbr)
          } else if (private$emission_tp == "Dynamic_prob_df"){
            filtered <- private$Emissions[private$Emissions$RUN == scenario, ]
            emis <- self$emissionFunctions(filtered, private$solvedAbbr)
          } else if (private$emission_tp == "runs_row"){
            rowNum <- scenario
            lhssamples <- private$Emissions[rowNum,]
            emis <- rep(0, length(private$solvedAbbr))
            names(emis) <- private$solvedAbbr
            emis[names(lhssamples)] <- lhssamples
          }
        }
        
        return(emis)
      },
      
      # return approx function 
      emissionFunctions = function(emissions, states) {
        
        if (private$emission_tp == "DynamicFun"){
          if (!all(names(emissions) %in% states)) {
            notfound <- as.list(names(emissions)[
              !names(emissions) %in% states])
            stop(do.call(paste,c(list("not all states in SB engine (the matrix)"), notfound)))
          }
          if (! is.na(private$uncertainFun)){
            stop("not possible to combine uncertain emissions with dynamic emissions, yet")
          }
          return(emissions)
        }
        
        if (private$emission_tp %in% c("Dynamic_det_df", "Dynamic_prob_df")) {
          #return the df as list of functions
          if(!(all(c("Abbr","Emis", "Time") %in% names(emissions)))){
            stop("Expected 'Abbr', 'Emis' and 'Time' columns in dataframe")
          }
          if (!is.null(private$uncertainFun) && !is.na(private$uncertainFun)) {
            stop("not possible to combine uncertain emissions with dynamic emissions, yet")
          }
          
          if(!all(as.character(states) %in% as.character(states))){
            stop("Abbreviations are not compatible with states")
          }
          #make 'm
          return(private$makeApprox(emissions))
        }
        # else
        stop("no dynamic emissions") #or make them a level line ???
      }
      
              ),
              
              private = list(
                emission_tp = NULL, # Character string containing the type of emissions
                Emissions = NULL, #vector / dataframe or list of functions, attributes as input at init
                solvedAbbr = NULL, #vector Abbr of solveStates
                UnitFactor = 1,
                Scenarios = NULL, 
                Times = NULL,
                uncertainFun = NULL,
                EmissionSource = NULL,
                
                # The use of the functions below is currently not implemented, but will be used in the future.
                
                # readFromClassicExcel = function(fn) {
                #   tryCatch(df <- openxlsx::read.xlsx(fn, sheet = "scenarios", startRow = 3),
                #            error = function(e) NULL)
                #   if (is.null(df)) stop ("Not a proper scenarios sheet in the xlsx")
                #   #clean a lot
                #   names(df)[c(3,4)] <- c("VarName", "Unit") #names(df) == "X3"
                #   df$current.settings <- NULL
                #   #remove all Xnames
                #   Xnames <- startsWith(names(df), "X")
                #   df <- df[startsWith(df$VarName, "E.") & !is.na(df$VarName),!Xnames]
                #   StateAbbr <- substr(df$VarName, start = 3, stop = 9)
                #   df$i <- private$MyCore$findState(StateAbbr)
                #   setEmissionDataFrame(df)
                # },
                
                # readfromexcel = function(fn){
                #   sheetNames <- openxlsx::getSheetNames(fn)
                #   #ignore the Sheetx names others are assumes to be scenario name
                #   sheetNames <- sheetNames[!grepl("Sheet[23]", sheetNames)]
                #   if (length(sheetNames) == 1){
                #     return(openxlsx::read.xlsx(fn, sheet = sheetNames))
                #   } else {
                #     dfs <- lapply(sheetNames, function(sheet){
                #       openxlsx::read.xlsx(fn, sheet = sheet)
                #     })
                #     for (i in 1:length(sheetNames)){
                #       df <- dfs[[i]]
                #       df$scenario <- sheetNames
                #     }
                #     return(do.call(rbind, dfs))
                #   }
                # },
                # 
                # readfromcsv = function(fn) {
                #   return (read.csv(fn))
                # },
                
                # Determine the format of the emission dataframe
                setEmissionDataFrame = function(emis) {
                  if (all(c("Abbr", "Emis", "Time", "RUN") %in% names(emis))) {
                    return("Dynamic_prob_df")
                  } else if(all(c("Abbr", "Emis", "Time") %in% names(emis))) {
                    return("Dynamic_det_df")
                  } else if(all(c("Abbr", "Emis", "RUN") %in% names(emis))) {
                    return("Steady_prob_df")
                  } else if(all(c("Abbr", "Emis") %in% names(emis))) {
                    return("Steady_det_df")
                  } else {
                    # it can be a data.frame with a run/scenario per row
                    if (all(names(emis) %in% private$solvedAbbr)) {
                      return("runs_row")
                      
                    } else stop ("at least columns with names Abbr, Emis or names equal to Abbr of states")
                  }
                },
                
                # Create function to make approx functions from data (input is a df with the columns Abbr, Time and Emis)
                makeApprox = function(vEmissions){
                  is.df.with(vEmissions, "EmissionModule$makeApprox", c("Time", "Emis", "Abbr"))
                  
                  vEmis <- 
                    vEmissions |> 
                    group_by(Abbr) |> 
                    summarise(n=n(),
                              EmisFun = list(
                                approxfun(
                                  data.frame(Time = c(Time), 
                                             Emis=c(Emis)),
                                  rule = 1:1)
                              )
                    )
                  funlist <- vEmis$EmisFun
                  names(funlist) <- vEmis$Abbr
                  return(funlist)
                },
                
                df2Vector = function(emis, solvedAbbr){
                  if ("data.frame" %in% class(emis) && all(c("Abbr","Emis") %in% names(emis))) {
                    vEmis <- rep(0.0, length.out = length(solvedAbbr))
                    names(vEmis) <- solvedAbbr
                    vEmis[match(emis$Abbr, solvedAbbr)] <- emis$Emis
                    private$EmissionSource <- vEmis
                    names(private$EmissionSource) <- solvedAbbr
                    return(private$EmissionSource)
                  } else {
                    stop("Dataframe does not contain columns Abbr and Emis")
                  }
                }
                
              )
    )