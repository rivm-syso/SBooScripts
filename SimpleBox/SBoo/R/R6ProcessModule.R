#' @title Process module
#' @description Initializes processes with their from and to dimensions
#' @export
ProcessModule <-
  R6::R6Class(
    "ProcessModule",
    inherit = CalcGraphModule,
    
    public = list(
      execute = function(debugAt = NULL){ #debug can be list of (3D)names with values
        AllIO <- private$Execute(debugAt)
        if (all(is.na(AllIO$AllOut))) {
          #browser()
          return(data.frame(NA))
        } else {
          AllIO$DimsIn$k <- unlist(AllIO$AllOut)
          return(AllIO$DimsIn[!is.na(AllIO$DimsIn$k),])
        }
      }
    ),
    
    active = list(
      FromAndTo = function(value) {
        if (missing(value)) {
          if (anyNA(private$withFlow)){
            private$MyCore$FromDataAndTo(self$myName)
          } else { #it's an advection process; append all flows from withFlow
            all2from <- lapply(private$withFlow, function(flowname){
              theFlow <- private$MyCore$moduleList[[flowname]]
              theFlow$FromAndTo
            })
            all2D2 <- dplyr::bind_rows(all2from)
            #append process name
            all2D2$process <- self$myName
            #expand to all species, but toSpecies == fromSpecies; 
            #first get species, the internal key is easiest fetched via the name
            SpeciesKeys <- data.frame(
              fromSpecies = private$MyCore$fetchData("SpeciesName")$Species)
            #then the complete in-product, and append fromSpecies identical to-to
            res <- merge(all2D2, SpeciesKeys)
            res$toSpecies <- res$fromSpecies
            #a flow gives 3 dimensions, we might need to extend it to the 4th
            if (!"toSubCompart" %in% names(res)) {
              res$toSubCompart <- res$fromSubCompart
            }
            if (!"toScale" %in% names(res)) {
              res$toScale <- res$fromScale
            }
            res
            
          }
        } else {
          stop("`$FromAndTo` is readonly", call. = FALSE)
        }
      },
      WithFlow = function(value) {
        if (missing(value)) {
          private$withFlow
        } else {
          private$withFlow <- value
        }
      }
    ),
    
    private = list(
      withFlow = NA
    )
  )