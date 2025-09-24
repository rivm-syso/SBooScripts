#' @title State Module 
#' @description Checks if data is consistent with states
#' @export
StateModule <- R6::R6Class("StateModule",
  public = list(
    initialize = function(){print("A StateModule should implement 'initialize()'")},

    #to b set by initialize:
    states = NULL,
    substance = NULL,
    SB4N.data = NULL,
    CheckDataStates = function(){
      #check if SB4N.data is consistent with states
      for (tble in self$SB4N.data){
        whichDim <- The3D %in% names(tble)
        if (any(The3D %in% names(tble))){
          # TODO or in Core?
        }
      }
      
    }
    
  )
  
)

