#' @title states
#' @description object in both SBcore as in SolverModule (slimmed down to existing kaas). 
#' @import R6
#' @export
SBstates <- R6::R6Class("SBstates",
  public = list(
    #' @description init, based on 
    #' @param StatesAsDataFrame dataframe of states with columns The3D Abbr and counter i
    initialize = function(StatesAsDataFrame) {
      if (!all(The3D %in% names(StatesAsDataFrame))) {
        stop(paste("states should contain all of", The3D))
      }
      if (!all(c("Abbr") %in% names(StatesAsDataFrame))) {
        stop("states should contain Abbr")
      }
      private$AsDataFrame <- StatesAsDataFrame[,c("Abbr", The3D)]
    },
    
    #' @description map vector abbr for scale species subcompart to index in State
    #' @param abbr Oldschool abbreviation
    #' @return vector of indices
    findState = function (abbr) {
      #split at the centre == Scale
      m<-regexpr("[RCAMT]",abbr)
      ScaleAbbr <- substr(abbr,m,m)
      SUbCompartAbbr <- substr(abbr,1,m-1)
      #identical functioning; thus rename: s = soil -> s1 naturalsoil, sd = oceansediment -> sd2
      #lengthabbC <- sapply(CompartAbbr, nchar) #needed to detect missing Species
      SUbCompartAbbr[SUbCompartAbbr=="s"] <- "s3"
      SUbCompartAbbr[SUbCompartAbbr=="sd"] <- "sd2"
      Spec <- substr(abbr,m+1,m+1)
      #if all Spec equal "" it's data from the Molecular (pre Nano) version
      if (all(Spec == "")){ #put all to Unbound
        Spec <- rep("U", length(Spec))
      }
      #G=Gas, D=Dissolved -> U=unbound,
      Spec[Spec %in% c("D","G")] <- "U"
      PasteAndMatch <- function (abbrnr) {
        match(paste(SUbCompartAbbr[abbrnr],
                    ScaleAbbr[abbrnr],
                    Spec[abbrnr],sep=""), private$AsDataFrame$Abbr)
      }
      sapply(1:length(abbr),FUN = PasteAndMatch)
    },

    #' @description change any of the 3 Dim into factors and sort a data.frame accordingly
    #' @param aDFwithD a data.frame to sort
    #' @return sorted dataframe with dimensions from 3D as factor with levels/labels according data sheets
    sortFactors = function (aDFwithD) {
      Dcolumns <- The3D[The3D %in% names(aDFwithD)]
      if (length(Dcolumns) == 0 && "Abbr" %in% names(aDFwithD)) {
        aDFwithD <- merge(aDFwithD, private$AsDataFrame)
        Dcolumns <- The3D[The3D %in% names(aDFwithD)] 
      } else {
        if (length(Dcolumns) == 0) {
          stop("data.frame offered to sortFactors() does neither contain either of The3D, nore 'Abbr'")
        }
      }
      #replace the columns with the factor with key levels
      for (theD in Dcolumns) { #the3D = c(Scale, SubCompart, Species)
        theName <- paste(theD, "Name", sep = "")
        levs <- self$Dlevels[[theD]]
        aDFwithD[, theD] <- factor(aDFwithD[, theD], levels = levs[,theD],
                                   ordered = T, labels = levs[, theName])
      } 
      #and the sort
      OrderOfDcolumns <- do.call(order, as.list(Dcolumns))
      return(aDFwithD[OrderOfDcolumns,])
    },
    
    #' @description find an element in any dimension, or the name of a dimension NOT FINISHED
    #' @param aDimension a dimension or an element therein
    #' @return list(the found dimension = the member) or list(the found dimension = dimension). 
    #' The found dimension is 1 of the 3dim
    findDim = function (aDimension) {
      browser()
      InDims <- sapply(The3D, function(aDim) {
        match(aDimension, private$AsDataFrame[,aDim])
      })
      if (sum(InDims>0)){
        
      }
    }
    
  ),
  active = list(
    #' @field asDataFrame convienent returning states in a data.frame
    asDataFrame = function(value) {
      if (missing(value)) {
        private$AsDataFrame
      } else {
        stop("`$states` are set by new()", call. = FALSE)
      }
    },
    #' @field nStates just 4 convenience
    nStates = function(value) {
      if (missing(value)) {
        if (is.null(private$AsDataFrame)) return(0)
          nrow(private$AsDataFrame)
      } else {
        stop("property nStates is read-only", call. = FALSE)
      }
    },
    myCore = function(value) {
      if (missing(value)) {
        return(private$MyCore)
      } else {
        if ("SBcore" %in% class(value)) {
          private$MyCore = value
        } else {
          stop("Core object expected, but not provided")
        }
      }
    },
    Dlevels = function(value) {
      if (missing(value)) {
        if (is.null(private$dlevels)) {
          #make/save levels to factors (sorting, in ggplot)
          ScaleOrder <- private$MyCore$fetchData("ScaleSheet")
          SubCompartOrder <- private$MyCore$fetchData("SubCompartSheet")
          SpeciesOrder <- private$MyCore$fetchData("SpeciesSheet")
          private$dlevels <- list(
            Scale = ScaleOrder[order(ScaleOrder$ScaleOrder), c("Scale", "ScaleName")],
            SubCompart = SubCompartOrder[order(SubCompartOrder$SubCompartOrder), c("SubCompart", "SubCompartName")],
            Species = SpeciesOrder[order(SpeciesOrder$SpeciesOrder), c("Species", "SpeciesName")]
          )
        }
        return(private$dlevels)
      } else {
        warning("Dlevels cannot be set; late initialized")
      }
    }
    
  ),
  private = list(
    AsDataFrame = NULL,
    MyCore = NULL,
    dlevels = NULL
  )
)