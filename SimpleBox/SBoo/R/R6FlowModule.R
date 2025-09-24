#' @title R6 Flow module
#' @description the module computing all flows between compartments.
#' @import R6
#' @export
FlowModule <-
  R6::R6Class(
    "FlowModule",
    inherit = CalcGraphModule,
    
    public = list(
      initialize = function(TheCore, exeFunction, WithProcess){
        super$initialize(TheCore, exeFunction = exeFunction)
        private$flowName <- exeFunction
        private$withProcess <- WithProcess
      },
      
      execute = function(debugAt = NULL){ #debug can be list of (3D)names with values
        AllIO <- private$Execute(debugAt)
        if (all(is.na(AllIO$AllOut))) {
          browser()
        } else {
          AllIO$DimsIn$flow <- AllIO$AllOut
          return(AllIO$DimsIn[!is.na(AllIO$DimsIn$flow),])
        }
      }
    ),
    
    active = list(
      FlowName = function(value) {
        if (missing(value)) {
          private$flowName
        } else {
          stop("Property FlowName is readonly")
        }
      },
      WithProcess = function(value) {
        if (missing(value)) {
          private$withProcess
        } else {
          private$withProcess <- value
        }
      },
      
      FromAndTo = function(value) {
        if (missing(value)) {
          #filter FlowIO and adjust column names to the 2 dimensions involved
          FTable <- private$MyCore$fetchData("FlowIO")
          FTable <- FTable[FTable$FlowName == self$FlowName, 
                           -which(names(FTable) == "FlowName")]
          TransferDim <- unique(FTable$Dimension)
          FTable$Dimension <- NULL
          if(length(TransferDim) == 0) {
            stop(paste("There must be (correct) data for this flow in FlowIO,", self$FlowName))
          }
          if(length(TransferDim) > 1) {
            stop(paste("There can only be 1 dimension for this flow,", self$FlowName))
          }
         
          #expand compart to subcompartments?
          PrepMatrix <- private$MyCore$fetchData("Compartment")
          #do not join on SubCompart, no expansion needed there
          names(PrepMatrix) <- c("ExpandSubCompart", "compartment")
          if (all(FTable$from %in% PrepMatrix$compartment)){
            possExpand <- lapply(1:nrow(FTable), function (xrow){
              merge(FTable[xrow,], PrepMatrix, by.x = "from", by.y = "compartment")
            }) 
            #rbind and clean columnames
            FTable <- do.call(rbind, possExpand)
            
            FTable$from <- FTable$ExpandSubCompart
            FTable$ExpandSubCompart <- NULL
          }
          #dito expansion for to; make a function??
          if (all(FTable$to %in% PrepMatrix$compartment)){
            possExpand <- lapply(1:nrow(FTable), function (xrow){
              merge(FTable[xrow,], PrepMatrix, by.x = "to", by.y = "compartment")
            }) 
            #rbind and clean columnames
            FTable <- do.call(rbind, possExpand)
            FTable$to <- DTable$ExpandSubCompart
            FTable$ExpandSubCompart <- NULL
          }
          
          # loop to find the forWhich Dimension
          OtherDims <- sapply(The3D[!The3D == TransferDim], function (ThisDim){
            DimTable <- private$MyCore$fetchData(paste0(ThisDim, "Sheet"))
            sum(FTable$forWhich %in% DimTable[,ThisDim]) #sum counts each T as 1
          })
          OtherDim <- names(OtherDims)[OtherDims > 0]
          if (length(OtherDim) != 1) {
            stop(paste("none or multiple dimensions found in flowIO for", value))
          }
          names(FTable) <- c(paste("from", TransferDim, sep = ""), 
                             paste("to", TransferDim, sep = ""), 
                             paste("from", OtherDim, sep = ""))
          
          #create the otherDim and avoid NA
          FTable[, paste("to", OtherDim, sep = "")] <- FTable[, paste("from", OtherDim, sep = "")]
          
          #filter those states that exists
          #which states exist?
          WorldStates <- private$MyCore$states$asDataFrame
          exist.from <- apply(FTable, 1, function(othrow) {
            any(WorldStates$Scale == othrow["fromScale"] &
                  WorldStates$SubCompart == othrow["fromSubCompart"])
          })
          
          #either one to-dimension exists, the other dimension is identical to from
          if ("toScale" %in% names(FTable)) {
            exist.to <- apply(FTable, 1, function(othrow) {
              any(WorldStates$Scale == othrow["toScale"] &
                    WorldStates$SubCompart == othrow["fromSubCompart"])
            })
          } else {
            exist.to <- apply(FTable, 1, function(othrow) {
              any(WorldStates$Scale == othrow["fromScale"] &
                    WorldStates$SubCompart == othrow["toSubCompart"])
            })
          
          }
          return(FTable[exist.from & exist.to, ]) 
            
        } else {
          stop("`$FromAndTo` is set by SBcore$AllFromAndTo()", call. = FALSE)
        }
      }
    ),
    
    private = list(
      flowName = NA,
      withProcess = NULL
    )
  )
